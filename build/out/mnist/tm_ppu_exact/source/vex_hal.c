#include "npu_runtime.h"
#include "vex_platform.h"
#include "xil_io.h"

/* This generated Vex uses IBusSimple/DBusSimple, without data cache. Fence
 * callbacks retain real ordering; there is no ARM/GIC or emulated completion. */
static uint64_t now_us(void *p) { (void)p; return vex_cycles()/50U; }
static void ordered(void *p) { (void)p; vex_fence(); }
static void cache_range(void *p, uintptr_t a, size_t n) { (void)p;(void)a;(void)n;vex_fence(); }
static void clear_irq(void *p) { (void)p; Xil_Out32(EDGE_NPU_MMIO_BASE+0x20U,1);vex_fence(); }
static void mask_irq(void *p) { (void)p; Xil_Out32(EDGE_NPU_MMIO_BASE+0x18U,1); }
static void unmask_irq(void *p) { (void)p; Xil_Out32(EDGE_NPU_MMIO_BASE+0x18U,0); }
static void dma(void *p,uint32_t a,uint32_t len) {
    (void)p; a=vex_dma_addr(a);
    Xil_Out32(EDGE_NPU_MMIO_BASE,4U|((a&0x7FFFFFU)<<9));
    Xil_Out32(EDGE_NPU_MMIO_BASE,((a>>23)&0x1FFU)|((len&0xFFFU)<<9));
}
static void poll(void *p) {
    (void)p;
    uint8_t tag=(uint8_t)Xil_In32(EDGE_NPU_MMIO_BASE+0x30U);
    if (edge_npu_runtime.inflight && tag==edge_npu_runtime.expected_tag) {
        clear_irq(0); npu_runtime_irq(&edge_npu_runtime,tag);
    }
}
int npu_platform_init(void) {
    /* Reopening this singleton is not a hardware reset. Preserve the ownership
     * quarantine before runtime_open can clear state, or any MMIO is touched. */
    if (edge_npu_runtime.faulted) return NPU_ERESET_REQUIRED;
    if (edge_npu_runtime.inflight) return NPU_EBUSY;
    npu_hal_t hal={0};
    hal.now_us=now_us;hal.flush=cache_range;hal.invalidate=cache_range;
    hal.barrier=ordered;hal.irq_lock=ordered;hal.irq_unlock=ordered;
    hal.clear_irq=clear_irq;hal.mask_irq=mask_irq;hal.unmask_irq=unmask_irq;
    hal.dma=dma;hal.poll=poll;
    /* No software-controlled complete PL reset is wired on this platform.
     * Leave reset NULL: fault recovery must return NPU_ERESET_REQUIRED. */
    int rc=npu_runtime_open(&edge_npu_runtime,&hal,(void *)(uintptr_t)EDGE_NPU_CODE_BASE,
                            EDGE_NPU_CODE_BASE,EDGE_NPU_CODE_BYTES);
    clear_irq(0);unmask_irq(0);return rc;
}

/* HWC extension v1. CPU aliases are translated exactly once, at the CSR
 * boundary. Error/timeout quarantines the whole backend until shared reset. */
int npu_window_hardware(uintptr_t source,uintptr_t dest,const npu_window_shape_t *shape,uint64_t timeout) {
 npu_runtime_t *r=&edge_npu_runtime;size_t input_bytes,output_bytes;
 const uintptr_t base=0xC0000100U;
 if(!r->ready||r->faulted)return NPU_EFAULT;
 if(r->inflight)return NPU_EBUSY;
 if(!timeout||npu_window_sizes(shape,&input_bytes,&output_bytes)||shape->k==1||
    r->views.mode!=2||r->views.view_generation!=r->views.generation||
    !npu_span_contains(r->views.input,source,input_bytes)||
    !npu_span_contains(r->views.a,dest,output_bytes)||dest<EDGE_NPU_SCRATCH_BASE||
    !npu_span_disjoint(source,input_bytes,dest,output_bytes)||(dest&7U))return NPU_EINVAL;
 if(Xil_In32(base+0x30U)!=1U)return NPU_EUNSUPPORTED;
 if(Xil_In32(base)&1U)return NPU_EBUSY;
 r->hal.flush(r->hal.opaque,source,input_bytes);
 r->hal.flush(r->hal.opaque,dest,output_bytes);
 r->hal.barrier(r->hal.opaque);
 Xil_Out32(base+4U,vex_dma_addr(source));Xil_Out32(base+8U,vex_dma_addr(dest));
 Xil_Out32(base+0xcU,shape->c);Xil_Out32(base+0x10U,shape->h);Xil_Out32(base+0x14U,shape->w);
 Xil_Out32(base+0x18U,shape->oh);Xil_Out32(base+0x1cU,shape->ow);
 Xil_Out32(base+0x20U,shape->k|(shape->s<<4)|((uint32_t)(uint8_t)shape->pad<<16));
 Xil_Out32(base+0x28U,1U);
 Xil_Out32(base+0x2cU,shape->pt|(shape->pb<<8)|(shape->pl<<16)|(shape->pr<<24));
 r->hal.barrier(r->hal.opaque);Xil_Out32(base,1U);r->hal.barrier(r->hal.opaque);
 uint64_t begin=r->hal.now_us(r->hal.opaque);
 for(;;) {
  uint32_t status=Xil_In32(base);
  if(status&4U){r->faulted=1;npu_cache_invalidate(r);return NPU_EFAULT;}
  /* Busy includes owner and outstanding write responses. DONE alone is unsafe. */
  if((status&3U)==2U)break;
  if(r->hal.now_us(r->hal.opaque)-begin>=timeout){r->faulted=1;++r->timeouts;npu_cache_invalidate(r);return NPU_ETIMEOUT;}
 }
 r->hal.barrier(r->hal.opaque);r->hal.invalidate(r->hal.opaque,dest,output_bytes);r->hal.barrier(r->hal.opaque);
 return NPU_OK;
}

/* The A7 graph is in low external BRAM; this path keeps the existing scratch
 * weight preparation and only offloads window generation. No model/view alias. */
uint32_t edge_hw_windows;
int npu_window_bram_available(void){return Xil_In32(0xC0000130U)==1U;}
int npu_window_bram(uintptr_t source,uintptr_t dest,const npu_window_shape_t *s,uint64_t timeout){
 size_t in_bytes,out_bytes;
 if(npu_window_sizes(s,&in_bytes,&out_bytes)||!timeout||s->k==1)return NPU_EUNSUPPORTED;
 if(source<0xA0000000U||source>=EDGE_NPU_SCRATCH_BASE||in_bytes>EDGE_NPU_SCRATCH_BASE-source||
    dest<EDGE_NPU_SCRATCH_BASE||(dest&7)||dest>=EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES||
    out_bytes>EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES-dest)return NPU_EINVAL;
 npu_runtime_t *r=&edge_npu_runtime;const uintptr_t base=0xC0000100U;
 if(!r->ready||r->faulted||r->inflight)return NPU_EFAULT;
 if(Xil_In32(base+0x30)!=1)return NPU_EUNSUPPORTED;
 if(Xil_In32(base)&1)return NPU_EBUSY;
 r->hal.flush(r->hal.opaque,source,in_bytes);r->hal.barrier(r->hal.opaque);
 Xil_Out32(base+4,vex_dma_addr(source));Xil_Out32(base+8,vex_dma_addr(dest));
 Xil_Out32(base+12,s->c);Xil_Out32(base+16,s->h);Xil_Out32(base+20,s->w);
 Xil_Out32(base+24,s->oh);Xil_Out32(base+28,s->ow);
 Xil_Out32(base+32,s->k|(s->s<<4)|((uint32_t)(uint8_t)s->pad<<16));
 Xil_Out32(base+40,1);Xil_Out32(base+44,s->pt|(s->pb<<8)|(s->pl<<16)|(s->pr<<24));
 r->hal.barrier(r->hal.opaque);Xil_Out32(base,1);r->hal.barrier(r->hal.opaque);
 uint64_t begin=r->hal.now_us(0);
 for(;;){uint32_t st=Xil_In32(base);
  if(st&4){r->faulted=1;npu_cache_invalidate(r);return NPU_EFAULT;}
  if((st&3)==2)break;
  if(r->hal.now_us(0)-begin>=timeout){r->faulted=1;++r->timeouts;npu_cache_invalidate(r);return NPU_ETIMEOUT;}
 }
 r->hal.barrier(r->hal.opaque);r->hal.invalidate(0,dest,out_bytes);r->hal.barrier(r->hal.opaque);++edge_hw_windows;return NPU_OK;
}
