/* Cortex-A9 standalone BSP adapter. MMIO/cache/GIC effects stay here. */
#include "npu_runtime.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "xil_exception.h"
#include "xparameters.h"
#include "xscugic.h"
#include "xstatus.h"

/* The runtime clock must not depend on each app's historical xtime_l.h.
 * Read the Cortex-A9 global timer, clocked at half the CPU frequency. */
#if defined(XPAR_CPU_CORE_CLOCK_FREQ_HZ)
#define EDGE_NPU_TIMER_HZ (XPAR_CPU_CORE_CLOCK_FREQ_HZ / 2U)
#elif defined(XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ)
#define EDGE_NPU_TIMER_HZ (XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ / 2U)
#elif defined(XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ)
#define EDGE_NPU_TIMER_HZ (XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ / 2U)
#else
#error "Cortex-A9 CPU frequency is required for bounded NPU timeouts"
#endif
#if defined(XPAR_GLOBAL_TIMER_BASEADDR)
#define EDGE_NPU_TIMER_BASE XPAR_GLOBAL_TIMER_BASEADDR
#elif defined(XPAR_GLOBAL_TMR_BASEADDR)
#define EDGE_NPU_TIMER_BASE XPAR_GLOBAL_TMR_BASEADDR
#else
#define EDGE_NPU_TIMER_BASE 0xF8F00200U /* Zynq-7000 Cortex-A9 global timer */
#endif

static XScuGic edge_gic;
static int platform_open;
static uint64_t zynq_now(void *p) {
    uint32_t high, low; (void)p;
    do {
        high = Xil_In32(EDGE_NPU_TIMER_BASE + 4U);
        low = Xil_In32(EDGE_NPU_TIMER_BASE);
    } while (Xil_In32(EDGE_NPU_TIMER_BASE + 4U) != high);
    uint64_t t = ((uint64_t)high << 32) | low;
    return (t / EDGE_NPU_TIMER_HZ) * 1000000U +
           (t % EDGE_NPU_TIMER_HZ) * 1000000U / EDGE_NPU_TIMER_HZ;
}
static void zynq_barrier(void *p) { (void)p; __asm__ volatile("dsb sy" ::: "memory"); }
static void zynq_flush(void *p, uintptr_t a, size_t n) {
    (void)p; uintptr_t first = a & ~(uintptr_t)63U;
    Xil_DCacheFlushRange((INTPTR)first, (u32)(((a + n + 63U) & ~(uintptr_t)63U) - first));
}
static void zynq_invalidate(void *p, uintptr_t a, size_t n) {
    (void)p; uintptr_t first = a & ~(uintptr_t)63U;
    Xil_DCacheInvalidateRange((INTPTR)first, (u32)(((a + n + 63U) & ~(uintptr_t)63U) - first));
}
static void zynq_lock(void *p) { (void)p; XScuGic_Disable(&edge_gic, EDGE_NPU_IRQ_ID); }
static void zynq_unlock(void *p) { (void)p; XScuGic_Enable(&edge_gic, EDGE_NPU_IRQ_ID); }
static void zynq_clear(void *p) {
    (void)p; Xil_Out32(EDGE_NPU_MMIO_BASE + 0x20U, 1U);
    zynq_barrier(NULL);
}
static void zynq_mask(void *p) {
    (void)p; Xil_Out32(EDGE_NPU_MMIO_BASE + 0x18U, 1U);
}
static void zynq_unmask(void *p) {
    (void)p; Xil_Out32(EDGE_NPU_MMIO_BASE + 0x18U, 0U);
    XScuGic_Enable(&edge_gic, EDGE_NPU_IRQ_ID);
}
static void zynq_dma(void *p, uint32_t a, uint32_t len) {
    (void)p;
    Xil_Out32(EDGE_NPU_MMIO_BASE, 4U | ((a & 0x7FFFFFU) << 9));
    Xil_Out32(EDGE_NPU_MMIO_BASE, ((a >> 23) & 0x1FFU) | ((len & 0xFFFU) << 9));
}
static void zynq_isr(void *p) {
    (void)p;
    uint8_t tag = (uint8_t)Xil_In32(EDGE_NPU_MMIO_BASE + 0x30U);
    zynq_clear(NULL); npu_runtime_irq(&edge_npu_runtime, tag);
}
int npu_platform_init(void)
{
    if (platform_open) return edge_npu_runtime.faulted ? NPU_EFAULT : NPU_OK;
    /* Enable without resetting an already-running counter. */
    Xil_Out32(EDGE_NPU_TIMER_BASE + 8U, Xil_In32(EDGE_NPU_TIMER_BASE + 8U) | 1U);
#if defined(SDT)
    XScuGic_Config *cfg = XScuGic_LookupConfig(XPAR_XSCUGIC_0_BASEADDR);
#else
    XScuGic_Config *cfg = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
#endif
    if (!cfg || XScuGic_CfgInitialize(&edge_gic, cfg, cfg->CpuBaseAddress) != XST_SUCCESS ||
        XScuGic_SelfTest(&edge_gic) != XST_SUCCESS) return NPU_EFAULT;
    npu_hal_t hal = {0};
    hal.now_us=zynq_now; hal.flush=zynq_flush; hal.invalidate=zynq_invalidate;
    hal.barrier=zynq_barrier; hal.irq_lock=zynq_lock; hal.irq_unlock=zynq_unlock;
    hal.clear_irq=zynq_clear; hal.mask_irq=zynq_mask; hal.unmask_irq=zynq_unmask; hal.dma=zynq_dma;
    /* c59406b has no reset CSR: a timed-out PL needs board/PL reinitialization.
     * reset stays NULL, so IRQ clear can never masquerade as recovery. */
    int rc = npu_runtime_open(&edge_npu_runtime, &hal, (void *)(uintptr_t)EDGE_NPU_CODE_BASE,
                               EDGE_NPU_CODE_BASE, EDGE_NPU_CODE_BYTES);
    if (rc != NPU_OK) return rc;
    if (XScuGic_Connect(&edge_gic, EDGE_NPU_IRQ_ID, (Xil_InterruptHandler)zynq_isr, NULL) != XST_SUCCESS)
        return NPU_EFAULT;
    XScuGic_SetPriorityTriggerType(&edge_gic, EDGE_NPU_IRQ_ID, 0xA0U, 0x01U);
    zynq_clear(NULL); Xil_Out32(EDGE_NPU_MMIO_BASE + 0x18U, 0U);
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &edge_gic);
    XScuGic_Enable(&edge_gic, EDGE_NPU_IRQ_ID); Xil_ExceptionEnable();
    platform_open = 1;
    return NPU_OK;
}
