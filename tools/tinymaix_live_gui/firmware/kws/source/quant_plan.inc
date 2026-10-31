/* Model parameters are immutable between npu_set_model calls, as for the
 * instruction cache. Cache the original double-precision denominator expression
 * exactly; input tensors are never cached here. First creation stays timed. */
typedef struct{
 const sctype_t *weights;uint32_t in_bits,out_bits,channels;
 int32_t outscale,denominator[TM_MAX_CSIZE];
 uint32_t reciprocal[TM_MAX_CSIZE];
 uint8_t valid;
}npu_quant_plan;
static npu_quant_plan quant_plans[8];
const uint32_t *edge_active_reciprocal;
void npu_quant_reset(void){for(unsigned i=0;i<8;++i)quant_plans[i].valid=0;edge_active_reciprocal=0;}
static int32_t npu_quant_prepare(unsigned channels,const sctype_t *ws,sctype_t in_s,sctype_t out_s){
 union{float f;uint32_t u;}in={in_s},out={out_s};unsigned layer=net_pref_info.total_layers;
 edge_active_reciprocal=0;
 if(layer>=8||channels>TM_MAX_CSIZE){
  for(unsigned c=0;c<channels;++c)sumscale[c]=1.0/ws[c]/in_s;
  return (1<<TM_FASTSCALE_SHIFT)/out_s;
 }
 npu_quant_plan *p=&quant_plans[layer];
 if(!p->valid||p->weights!=ws||p->in_bits!=in.u||p->out_bits!=out.u||p->channels!=channels){
  p->weights=ws;p->in_bits=in.u;p->out_bits=out.u;p->channels=channels;
  p->outscale=(1<<TM_FASTSCALE_SHIFT)/out_s;
  for(unsigned c=0;c<channels;++c){
   p->denominator[c]=1.0/ws[c]/in_s;
   uint32_t d=(uint32_t)p->denominator[c];
   p->reciprocal[c]=d>1&&d<=INT32_MAX?(uint32_t)((UINT64_C(0x100000000)+d-1)/d):0;
  }p->valid=1;
 }
 memcpy(sumscale,p->denominator,channels*sizeof(*sumscale));edge_active_reciprocal=p->reciprocal;return p->outscale;
}
