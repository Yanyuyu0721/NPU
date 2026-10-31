#ifndef EDGE_NPU_VIEWS_H
#define EDGE_NPU_VIEWS_H
#include <stddef.h>
#include <stdint.h>
/* CPU alias only. No physical-address aliases accepted by this API. All spans
 * are half-open, and the aligned DMA read envelope must stay in its lease. */
typedef struct { uint32_t base,bytes; } npu_span_t;
typedef struct {
    npu_span_t model,graph,w,a,input;
    uint32_t generation,view_generation,mode;
    uint32_t model_end,graph_end,scratch_base,scratch_bytes;
} npu_views_t;
void npu_views_init(npu_views_t *,int euro);
int npu_views_register(npu_views_t *,uintptr_t,size_t,uintptr_t,size_t);
int npu_views_layer(npu_views_t *,uintptr_t,size_t,uintptr_t,size_t,uintptr_t,size_t,uint32_t);
void npu_views_clear_layer(npu_views_t *);
int npu_span_contains(npu_span_t,uintptr_t,size_t);
int npu_span_disjoint(uintptr_t,size_t,uintptr_t,size_t);
int npu_views_validate(const npu_views_t *,uintptr_t,size_t,uintptr_t,size_t,uintptr_t,size_t,uint32_t);
/* Native [p][ci][ky][kx], independent of channel count. Geometry checked before
 * writing any destination byte; callers must validate leases before invoking. */
typedef struct { uint32_t h,w,c,oh,ow,k,s,pt,pb,pl,pr; int8_t pad; } npu_window_shape_t;
int npu_window_sizes(const npu_window_shape_t *,size_t *,size_t *);
int npu_window_direct(const npu_window_shape_t *);
int npu_window_native(const int8_t *,int8_t *,size_t,const npu_window_shape_t *);
#endif
