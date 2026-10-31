#include "npu_views.h"
#include <string.h>
#define BAD (-1)
#define ALIAS 0xA0000000U
static int extent(uintptr_t a,size_t n) { return n && a<=UINT32_MAX && n<=UINT32_MAX-a; }
int npu_span_contains(npu_span_t s,uintptr_t a,size_t n) {
 return extent(a,n) && s.bytes && a>=s.base && a-s.base<s.bytes && n<=s.bytes-(a-s.base);
}
int npu_span_disjoint(uintptr_t a,size_t n,uintptr_t b,size_t m) {
 return extent(a,n)&&extent(b,m)&&(a+n<=b||b+m<=a);
}
static int beat_in(npu_span_t lease,uintptr_t a,size_t n) {
 if(!extent(a,n)||a+n>UINT32_MAX-7U)return 0;
 uintptr_t lo=a&~(uintptr_t)7U,hi=(a+n+7U)&~(uintptr_t)7U;
 return npu_span_contains(lease,lo,hi-lo);
}
void npu_views_init(npu_views_t *v,int euro) {
 memset(v,0,sizeof(*v));v->generation=1;
 v->model_end=ALIAS+(euro?0x68000U:0x80000U);
 v->scratch_base=ALIAS+(euro?0x88000U:0xA0000U);
 v->graph_end=v->scratch_base-64U;
 v->scratch_bytes=ALIAS+0xF0000U-v->scratch_base-64U;
}
void npu_views_clear_layer(npu_views_t *v) {
 ++v->generation;v->view_generation=0;v->w.bytes=v->a.bytes=v->input.bytes=0;v->mode=0;
}
int npu_views_register(npu_views_t *v,uintptr_t m,size_t mn,uintptr_t g,size_t gn) {
 npu_views_clear_layer(v);v->model.bytes=v->graph.bytes=0;
 npu_span_t mr={ALIAS,v->model_end-ALIAS},gr={v->model_end,v->graph_end-v->model_end};
 if(!npu_span_contains(mr,m,mn)||!npu_span_contains(gr,g,gn)||!npu_span_disjoint(m,mn,g,gn))return BAD;
 v->model=(npu_span_t){(uint32_t)m,(uint32_t)mn};v->graph=(npu_span_t){(uint32_t)g,(uint32_t)gn};return 0;
}
int npu_views_layer(npu_views_t *v,uintptr_t w,size_t wn,uintptr_t in,size_t in_n,uintptr_t a,size_t an,uint32_t mode) {
 npu_views_clear_layer(v);
 npu_span_t scratch={v->scratch_base,v->scratch_bytes};
 if((mode!=1&&mode!=2)||!npu_span_contains(v->model,w,wn)||!beat_in(v->model,w,wn)||
    !npu_span_contains(v->graph,in,in_n)||!beat_in(v->graph,in,in_n))return BAD;
 if(a==in) {if(an!=in_n)return BAD;}
 else if(!npu_span_contains(scratch,a,an)||!beat_in(scratch,a,an))return BAD;
 v->w=(npu_span_t){(uint32_t)w,(uint32_t)wn};v->input=(npu_span_t){(uint32_t)in,(uint32_t)in_n};
 v->a=(npu_span_t){(uint32_t)a,(uint32_t)an};v->mode=mode;v->view_generation=v->generation;return 0;
}
int npu_views_validate(const npu_views_t *v,uintptr_t w,size_t wn,uintptr_t a,size_t an,uintptr_t o,size_t on,uint32_t generation) {
 npu_span_t scratch={v->scratch_base,v->scratch_bytes};
 if(!v->mode||generation!=v->generation||v->view_generation!=generation||
    !npu_span_contains(v->w,w,wn)||!npu_span_contains(v->a,a,an)||
    !npu_span_contains(scratch,o,on)||!npu_span_disjoint(w,wn,o,on)||!npu_span_disjoint(a,an,o,on)||
    !npu_span_disjoint(v->input.base,v->input.bytes,o,on))return BAD;
 return 0;
}
int npu_window_sizes(const npu_window_shape_t *s,size_t *in,size_t *out) {
 if(!s||!in||!out||!s->h||!s->w||!s->c||!s->oh||!s->ow||s->h>65535||s->w>65535||s->c>65535||s->oh>65535||s->ow>65535||
    (s->k!=1&&s->k!=3&&s->k!=4&&s->k!=5)||(s->s!=1&&s->s!=2)||s->pt>2||s->pb>2||s->pl>2||s->pr>2||
    s->h+s->pt+s->pb<s->k||s->w+s->pl+s->pr<s->k||
    (s->h+s->pt+s->pb-s->k)/s->s+1!=s->oh||(s->w+s->pl+s->pr-s->k)/s->s+1!=s->ow)return BAD;
 uint64_t n=(uint64_t)s->h*s->w*s->c,m=(uint64_t)s->oh*s->ow*s->c*s->k*s->k;
 if(n>UINT32_MAX||m>UINT32_MAX)return BAD;
 *in=(size_t)n;*out=(size_t)m;return 0;
}
int npu_window_direct(const npu_window_shape_t *s) {
 size_t n,m;return !npu_window_sizes(s,&n,&m)&&s->k==1&&s->s==1&&!s->pt&&!s->pb&&!s->pl&&!s->pr&&s->h==s->oh&&s->w==s->ow;
}
int npu_window_native(const int8_t *in,int8_t *out,size_t capacity,const npu_window_shape_t *s) {
 size_t n,m,j=0;if(npu_window_sizes(s,&n,&m)||m>capacity||!in||!out)return BAD;
 for(uint32_t y=0;y<s->oh;++y)for(uint32_t x=0;x<s->ow;++x)for(uint32_t c=0;c<s->c;++c)
 for(uint32_t ky=0;ky<s->k;++ky)for(uint32_t kx=0;kx<s->k;++kx){
  int32_t iy=(int32_t)(y*s->s+ky)-(int32_t)s->pt,ix=(int32_t)(x*s->s+kx)-(int32_t)s->pl;
  out[j++]=(iy<0||ix<0||iy>=(int32_t)s->h||ix>=(int32_t)s->w)?s->pad:in[((uint32_t)iy*s->w+(uint32_t)ix)*s->c+c];
 }return 0;
}
