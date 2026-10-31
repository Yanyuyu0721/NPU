#ifndef EDGE_NPU_RUNTIME_H
#define EDGE_NPU_RUNTIME_H
#include <stddef.h>
#include <stdint.h>
#include "npu_views.h"

#define EDGE_NPU_MMIO_BASE 0xC0000000U
#define EDGE_NPU_SCRATCH_BASE 0xA000C000U
#define EDGE_NPU_SCRATCH_BYTES 0x00010000U
#define EDGE_NPU_CODE_BASE 0xA001C000U
#define EDGE_NPU_CODE_BYTES 0x00010000U
#define EDGE_NPU_CACHE_ENTRIES 96U
#define EDGE_NPU_IRQ_ID 61U
#define EDGE_NPU_LAYOUT_VERSION 1U
#define EDGE_NPU_DMA_MAX_WORDS 4096U
#ifndef EDGE_NPU_CACHE_ENABLED
#define EDGE_NPU_CACHE_ENABLED 1
#endif
#ifndef NPU_PLATFORM
#define NPU_PLATFORM 0
#endif
#define EDGE_NPU_BACKEND_ID ((NPU_PLATFORM == 0) ? 0U : (EDGE_NPU_CACHE_ENABLED ? 2U : 1U))

typedef enum {
    NPU_OK=0, NPU_EINVAL=-1, NPU_ECAPACITY=-2, NPU_EBUSY=-3,
    NPU_ETIMEOUT=-4, NPU_EFAULT=-5, NPU_ERESET_REQUIRED=-6, NPU_EUNSUPPORTED=-7
} npu_result_t;

/* Zero-initialize keys: exact struct equality plus content fingerprints.
 * Addresses describe the fixed scratch layout, never scratch contents. */
typedef struct {
    uint64_t model_version, layer_quant_hash, parameter_hash;
    uint32_t model_id, layer_id, layout_version;
    uint32_t a_addr, w_addr, insize, outsize, a_num, w_num;
    uint32_t rescale_enable, act_enable, act_type;
    int32_t out_zp;
} npu_cache_key_t;
typedef struct {
    void *opaque;
    uint64_t (*now_us)(void *);
    void (*flush)(void *, uintptr_t, size_t);
    void (*invalidate)(void *, uintptr_t, size_t);
    void (*barrier)(void *);
    void (*irq_lock)(void *);
    void (*irq_unlock)(void *);
    void (*clear_irq)(void *);
    void (*mask_irq)(void *);
    void (*unmask_irq)(void *);
    void (*dma)(void *, uint32_t, uint32_t); /* second arg = count - 1 */
    void (*poll)(void *);
    int (*reset)(void *); /* must reset all PL datapath/FIFOs/DMA, not just IRQ */
} npu_hal_t;
typedef struct {
    uint8_t *cpu;
    uint32_t physical, words, epoch;
} npu_program_t;
typedef struct {
    npu_cache_key_t key;
    npu_program_t program;
    uint8_t valid;
} npu_cache_entry_t;
typedef struct {
    npu_hal_t hal;
    npu_views_t views;
    uint8_t *code;
    uint32_t code_physical;
    size_t code_capacity, code_used;
    npu_cache_entry_t entries[EDGE_NPU_CACHE_ENTRIES];
    uint32_t entry_count, epoch;
    uint64_t hits, misses, generations, evictions, submissions, timeouts, stray_irqs;
    volatile uint8_t inflight, completed, completed_tag;
    uint8_t expected_tag, next_tag, faulted, ready;
} npu_runtime_t;
typedef int (*npu_generator_t)(void *, void *, uint32_t, uint32_t *);

uint64_t npu_hash_bytes(uint64_t seed, const void *data, size_t bytes);
int npu_runtime_open(npu_runtime_t *, const npu_hal_t *, void *, uint32_t, size_t);
int npu_cache_invalidate(npu_runtime_t *);
int npu_cache_prepare(npu_runtime_t *, const npu_cache_key_t *, uint32_t,
                      npu_generator_t, void *, npu_program_t *);
void npu_runtime_irq(npu_runtime_t *, uint8_t);
int npu_runtime_submit(npu_runtime_t *, const npu_program_t *, uintptr_t,
                       size_t, uintptr_t, size_t, uint64_t);
int npu_runtime_recover(npu_runtime_t *);
int npu_runtime_submit_views(npu_runtime_t *,const npu_program_t *,uintptr_t,size_t,uintptr_t,size_t,uintptr_t,size_t,uint32_t,uint64_t);
int npu_register_buffers(const void *,size_t,void *,size_t);
int npu_native_enable(unsigned); /* 0 legacy/default, 1 native software, 2 HWC hardware */
unsigned npu_native_mode(void);
int npu_native_layer(uintptr_t,size_t,uintptr_t,size_t,uintptr_t,size_t);
int npu_window_hardware(uintptr_t,uintptr_t,const npu_window_shape_t *,uint64_t);

/* Singleton used by the TinyMaix compatibility adapter. */
extern npu_runtime_t edge_npu_runtime;
int npu_platform_init(void);
void npu_set_model(const void *, size_t, uint32_t);
void npu_set_layer(uint32_t, const void *, size_t);
int npu_submit_prepared(uint64_t timeout_us);
int npu_last_result(void);
uint32_t npu_prepared_physical(void);
#endif
