#include "npu_runtime.h"
#include <string.h>

uint64_t npu_hash_bytes(uint64_t seed, const void *data, size_t bytes)
{
    const uint8_t *p = (const uint8_t *)data;
    uint64_t h = seed ? seed : UINT64_C(14695981039346656037);
    while (bytes--) { h ^= *p++; h *= UINT64_C(1099511628211); }
    return h;
}
int npu_runtime_open(npu_runtime_t *r, const npu_hal_t *hal, void *code,
                     uint32_t physical, size_t bytes)
{
    if (!r || !hal || !code || !bytes || (physical & 63U) ||
        ((uintptr_t)code & 63U) || bytes > UINT32_MAX - physical ||
        !hal->now_us || !hal->dma || !hal->flush || !hal->invalidate ||
        !hal->barrier || !hal->clear_irq || !hal->irq_lock || !hal->irq_unlock || !hal->mask_irq || !hal->unmask_irq)
        return NPU_EINVAL;
    memset(r, 0, sizeof(*r));
#ifdef EDGE_VEX_EURO_PROFILE
    npu_views_init(&r->views,1);
#else
    npu_views_init(&r->views,0);
#endif
    r->hal = *hal; r->code = (uint8_t *)code;
    r->code_physical = physical; r->code_capacity = bytes; r->ready = 1;
    return NPU_OK;
}
int npu_cache_invalidate(npu_runtime_t *r)
{
    if (!r || !r->ready) return NPU_EINVAL;
    if (r->inflight) return NPU_EBUSY;
    memset(r->entries, 0, sizeof(r->entries));
    r->entry_count = 0; r->code_used = 0; ++r->epoch;
    return NPU_OK;
}
typedef uint32_t npu_key_word __attribute__((__may_alias__));
static int key_equal(const npu_cache_key_t *a,const npu_cache_key_t *b){
 _Static_assert(sizeof(*a)%4==0,"key must contain whole words");
 const npu_key_word *x=(const npu_key_word*)a,*y=(const npu_key_word*)b;
 for(unsigned i=0;i<sizeof(*a)/4;++i)if(x[i]!=y[i])return 0;
 return 1;
}
int npu_cache_prepare(npu_runtime_t *r, const npu_cache_key_t *key, uint32_t words,
                      npu_generator_t gen, void *arg, npu_program_t *out)
{
    size_t bytes;
    uint32_t written = 0;
    if (!r || !r->ready || !key || !gen || !out || !words) return NPU_EINVAL;
    if (r->faulted) return NPU_EFAULT;
    if (r->inflight) return NPU_EBUSY;
    if (words > EDGE_NPU_DMA_MAX_WORDS) return NPU_ECAPACITY;
    bytes = ((size_t)words * 8U + 63U) & ~(size_t)63U;
    if (bytes > r->code_capacity) return NPU_ECAPACITY;
#if EDGE_NPU_CACHE_ENABLED
    for (uint32_t i = 0; i < r->entry_count; ++i) {
        if (r->entries[i].valid && key_equal(&r->entries[i].key,key)) {
            *out = r->entries[i].program; ++r->hits; return NPU_OK;
        }
    }
#endif
    ++r->misses;
#if !EDGE_NPU_CACHE_ENABLED
    npu_cache_invalidate(r);
#endif
    if (r->entry_count == EDGE_NPU_CACHE_ENTRIES || bytes > r->code_capacity - r->code_used) {
        npu_cache_invalidate(r); ++r->evictions;
    }
    npu_program_t p = {r->code + r->code_used, r->code_physical + (uint32_t)r->code_used, words, r->epoch};
    int status = gen(arg, p.cpu, words, &written);
    if (status != NPU_OK || written != words) return NPU_EINVAL;
    /* The final word must be a global-sync instruction before patching tags. */
    uint32_t *tail = (uint32_t *)(p.cpu + (words - 1U) * 8U);
    if ((tail[0] & 0xFU) != 0xFU) return NPU_EINVAL;
    npu_cache_entry_t *e = &r->entries[r->entry_count++];
    e->key = *key; e->program = p; e->valid = 1;
    r->code_used += bytes; ++r->generations; *out = p;
    return NPU_OK;
}
void npu_runtime_irq(npu_runtime_t *r, uint8_t tag)
{
    if (r->inflight && tag == r->expected_tag && !r->completed) {
        r->completed_tag = tag; r->completed = 1;
    } else ++r->stray_irqs;
}
static int in_scratch(uintptr_t start, size_t bytes)
{
    return bytes && start >= EDGE_NPU_SCRATCH_BASE &&
        start - EDGE_NPU_SCRATCH_BASE < EDGE_NPU_SCRATCH_BYTES &&
        bytes <= EDGE_NPU_SCRATCH_BYTES - (start - EDGE_NPU_SCRATCH_BASE);
}
static int submit_ranges(npu_runtime_t *r, const npu_program_t *p,
                       uintptr_t inputs, size_t input_bytes, uintptr_t weights,size_t weight_bytes,
                       uintptr_t outputs, size_t output_bytes, uint32_t generation,int native,uint64_t timeout_us)
{
    if (!r || !r->ready || !p || !p->words || p->words > EDGE_NPU_DMA_MAX_WORDS ||
        !timeout_us || !in_scratch(outputs, output_bytes) ||
        (native ? npu_views_validate(&r->views,weights,weight_bytes,inputs,input_bytes,outputs,output_bytes,generation)!=0 : !in_scratch(inputs,input_bytes)))
        return NPU_EINVAL;
    if (r->faulted) return NPU_EFAULT;
    if (r->inflight) return NPU_EBUSY;
    if (p->epoch != r->epoch || p->physical < r->code_physical || p->physical - r->code_physical > r->code_used ||
        (size_t)p->words * 8U > r->code_used - (p->physical - r->code_physical) ||
        p->cpu != r->code + (p->physical - r->code_physical)) return NPU_EINVAL;
    uint32_t *tail = (uint32_t *)(p->cpu + (p->words - 1U) * 8U);
    if ((tail[0] & 0xFU) != 0xFU) return NPU_EINVAL;
    /* Both ranges are cleaned before DMA, including any dirty boundary lines.
     * No CPU writes into scratch are permitted until submission completes. */
    if(native) r->hal.flush(r->hal.opaque,weights,weight_bytes);
    r->hal.flush(r->hal.opaque, inputs, input_bytes);
    r->hal.flush(r->hal.opaque, outputs, output_bytes);
    uint8_t tag = ++r->next_tag;
    if (!tag) tag = ++r->next_tag;
    tail[1] = (tail[1] & 0x00FFFFFFU) | ((uint32_t)tag << 24);
    r->hal.flush(r->hal.opaque, (uintptr_t)p->cpu, (size_t)p->words * 8U);
    r->hal.barrier(r->hal.opaque);
    r->hal.irq_lock(r->hal.opaque);
    r->hal.clear_irq(r->hal.opaque);
    r->completed = 0; r->completed_tag = 0; r->expected_tag = tag; r->inflight = 1;
    uint64_t start = r->hal.now_us(r->hal.opaque);
    r->hal.dma(r->hal.opaque, p->physical, p->words - 1U);
    r->hal.barrier(r->hal.opaque);
    r->hal.irq_unlock(r->hal.opaque);
    ++r->submissions;
    while (!r->completed) {
        if (r->hal.poll) r->hal.poll(r->hal.opaque);
        if (r->completed) break;
        if (r->hal.now_us(r->hal.opaque) - start >= timeout_us) {
            r->hal.irq_lock(r->hal.opaque);
            r->faulted = 1; r->inflight = 0;
            r->hal.mask_irq(r->hal.opaque); r->hal.clear_irq(r->hal.opaque);
            r->hal.irq_unlock(r->hal.opaque);
            ++r->timeouts; npu_cache_invalidate(r);
            return NPU_ETIMEOUT;
        }
    }
    r->hal.barrier(r->hal.opaque);
    r->hal.invalidate(r->hal.opaque, outputs, output_bytes);
    r->hal.barrier(r->hal.opaque);
    r->inflight = 0;
    return NPU_OK;
}
int npu_runtime_recover(npu_runtime_t *r)
{
    if (!r || !r->ready || r->inflight) return NPU_EBUSY;
    if (!r->faulted) return NPU_OK;
    if (!r->hal.reset || r->hal.reset(r->hal.opaque) != NPU_OK) return NPU_ERESET_REQUIRED;
    r->hal.clear_irq(r->hal.opaque); r->hal.barrier(r->hal.opaque);
    npu_cache_invalidate(r); r->completed = 0; r->faulted = 0;
    r->hal.unmask_irq(r->hal.opaque);
    return NPU_OK;
}

int npu_runtime_submit(npu_runtime_t *r,const npu_program_t *p,uintptr_t in,size_t n,uintptr_t out,size_t m,uint64_t timeout) {
 return submit_ranges(r,p,in,n,0,0,out,m,0,0,timeout);
}
int npu_runtime_submit_views(npu_runtime_t *r,const npu_program_t *p,uintptr_t w,size_t wn,uintptr_t a,size_t an,uintptr_t o,size_t on,uint32_t generation,uint64_t timeout) {
 return submit_ranges(r,p,a,an,w,wn,o,on,generation,1,timeout);
}
