/* Persistent-cache adapter around the common instruction encoder. */
npu_runtime_t edge_npu_runtime;
static npu_cache_key_t active_key;
static npu_program_t prepared;
static uintptr_t prepared_output;
static size_t prepared_output_bytes, prepared_input_bytes;
static int prepared_valid, last_result;
static unsigned native_mode,prepared_native;
static uintptr_t prepared_a,prepared_w;
static size_t prepared_a_bytes,prepared_w_bytes;
static uint32_t prepared_generation;
unsigned npu_native_mode(void) { return native_mode; }
int npu_native_enable(unsigned mode) {
 if(mode>2)return NPU_EINVAL;
 if(edge_npu_runtime.inflight)return NPU_EBUSY;
 if(edge_npu_runtime.faulted)return NPU_EFAULT;
 prepared_valid=0;native_mode=mode;npu_views_clear_layer(&edge_npu_runtime.views);return NPU_OK;
}
int npu_register_buffers(const void *m,size_t mn,void *g,size_t gn) {
 if(!edge_npu_runtime.ready||edge_npu_runtime.faulted)return NPU_EFAULT;
 if(edge_npu_runtime.inflight)return NPU_EBUSY;
 prepared_valid=0;return npu_views_register(&edge_npu_runtime.views,(uintptr_t)m,mn,(uintptr_t)g,gn);
}
int npu_native_layer(uintptr_t w,size_t wn,uintptr_t input,size_t in_n,uintptr_t a,size_t an) {
 if(!edge_npu_runtime.ready||edge_npu_runtime.faulted)return NPU_EFAULT;
 if(edge_npu_runtime.inflight)return NPU_EBUSY;
 prepared_valid=0;return npu_views_layer(&edge_npu_runtime.views,w,wn,input,in_n,a,an,native_mode);
}

void npu_set_model(const void *model, size_t bytes, uint32_t id)
{
    extern void npu_quant_reset(void);npu_quant_reset();
    prepared_valid = 0;
    npu_views_clear_layer(&edge_npu_runtime.views);
    memset(&active_key, 0, sizeof(active_key));
    active_key.model_version = npu_hash_bytes(0, model, bytes);
    active_key.model_id = id; active_key.layout_version = EDGE_NPU_LAYOUT_VERSION;
}
void npu_set_layer(uint32_t id, const void *layer, size_t bytes)
{
    prepared_valid = 0;
    npu_views_clear_layer(&edge_npu_runtime.views);
    active_key.layer_id = id;
    active_key.layer_quant_hash = npu_hash_bytes(0, layer, bytes);
}
typedef struct {
    uint32_t a, w, *bias, *rescale, *out;
    uint8_t rescale_enable;
    uint32_t act_enable, act_type;
    int32_t out_zp;
    uint32_t insize, outsize, a_num, w_num;
} edge_mac_args_t;
static int encode_mac(void *arg, void *dest, uint32_t capacity, uint32_t *written)
{
    edge_mac_args_t *a = (edge_mac_args_t *)arg;
    uint8_t tag;
    (void)capacity; /* exact preflight word count established before call */
    return npu_mac_generate(dest,a->a,a->w,a->bias,a->rescale_enable,a->rescale,
               a->act_enable,a->act_type,a->out_zp,a->out,a->insize,a->outsize,a->a_num,a->w_num,&tag,written);
}
int npu_mac_engine(void *unused_scratch_code, uint32_t a_addr, uint32_t w_addr,
    uint32_t bias[], uint8_t rescale_enable, uint32_t rescale[], uint32_t act_enable,
    uint32_t act_type, int32_t out_zp, uint32_t out_addr[], uint32_t insize,
    uint32_t outsize, uint32_t a_num, uint32_t w_num, uint8_t *exp_tag, uint32_t *inst_len)
{
    (void)unused_scratch_code;
    prepared_valid = 0;
    if (exp_tag) *exp_tag = 0;
    if (inst_len) *inst_len = 0;
    if (!exp_tag || !inst_len || !bias || !out_addr || (rescale_enable && !rescale) ||
        !insize || !outsize || !a_num || !w_num || w_num > 1024U || outsize != a_num ||
        act_type > 7U || out_zp < -256 || out_zp > 255) return last_result = NPU_EINVAL;
    /* Every host-touched scratch range is bounded BEFORE weight/im2col copies by
     * the operator adapter, and again here before hardware submission. */
    unsigned active_native=edge_npu_runtime.views.mode;
    size_t width = rescale_enable ? 1U : 4U;
    uint64_t end_a=(uint64_t)a_addr+(uint64_t)insize*a_num;
    uint64_t end_w=(uint64_t)w_addr+(uint64_t)insize*w_num;
    uint32_t out_first=UINT32_MAX; uint64_t out_end=0;
    for (uint32_t i=0;i<w_num;++i) {
        uint64_t end=(uint64_t)out_addr[i]+(uint64_t)outsize*width;
        if (out_addr[i]<out_first) out_first=out_addr[i];
        if (end>out_end) out_end=end;
        if ((out_addr[i]&7U) || out_addr[i] < EDGE_NPU_SCRATCH_BASE || end > (uint64_t)EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES) return last_result=NPU_EINVAL;
        /* Positive TinyMaix coefficients must fit SIGNED 18-bit Q16. */
        if (rescale_enable && rescale[i] >= (1U<<17)) return last_result=NPU_EUNSUPPORTED;
    }
    if(end_a>UINT32_MAX||end_w>UINT32_MAX)return last_result=NPU_EINVAL;
    if(active_native) {
      if(npu_views_validate(&edge_npu_runtime.views,w_addr,(size_t)(end_w-w_addr),a_addr,(size_t)(end_a-a_addr),out_first,(size_t)(out_end-out_first),edge_npu_runtime.views.generation))return last_result=NPU_EINVAL;
    } else if(a_addr<EDGE_NPU_SCRATCH_BASE || w_addr<EDGE_NPU_SCRATCH_BASE ||
       end_a>(uint64_t)EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES || end_w>(uint64_t)EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES) return last_result=NPU_EINVAL;
    int ordered_outputs=1;
    for(uint32_t i=1;i<w_num;++i)if((uint64_t)out_addr[i-1]+outsize*width>out_addr[i])ordered_outputs=0;
    for(uint32_t i=0;i<w_num;++i) {
      if(!npu_span_disjoint(a_addr,(size_t)(end_a-a_addr),out_addr[i],outsize*width)||
         !npu_span_disjoint(w_addr,(size_t)(end_w-w_addr),out_addr[i],outsize*width))return last_result=NPU_EINVAL;
      if(!ordered_outputs)for(uint32_t j=0;j<i;++j)if(!npu_span_disjoint(out_addr[i],outsize*width,out_addr[j],outsize*width))return last_result=NPU_EINVAL;
    }
    uint64_t words=2; /* one PPU cfg and one final global sync */
    uint32_t chunks=(insize+1023U)/1024U;
    uint32_t out_chunks=(outsize+1023U)/1024U;
    for(uint32_t oc=0;oc<w_num;oc+=8U) {
        uint32_t cols=w_num-oc; if(cols>8U) cols=8U;
        words+=(uint64_t)cols*out_chunks*2U;
        if(insize<=1024U) words+=1U+((uint64_t)a_num+7U)/8U*3U;
        else for(uint32_t ac=0;ac<a_num;ac+=8U) {
            uint32_t rows=a_num-ac; if(rows>8U) rows=8U;
            words+=(uint64_t)chunks*(cols+rows+2U);
        }
    }
    if(words>EDGE_NPU_DMA_MAX_WORDS) return last_result=NPU_ECAPACITY;
    if (!edge_npu_runtime.ready) return last_result=NPU_EFAULT;
    npu_cache_key_t key=active_key;
    key.layout_version=active_native ? (0x100U+active_native) : EDGE_NPU_LAYOUT_VERSION;
    key.a_addr=a_addr; key.w_addr=w_addr; key.insize=insize; key.outsize=outsize;
    key.a_num=a_num; key.w_num=w_num; key.rescale_enable=rescale_enable;
    key.act_enable=act_enable; key.act_type=act_type; key.out_zp=out_zp;
    key.parameter_hash=npu_hash_bytes(0,bias,(size_t)w_num*sizeof(*bias));
    if(rescale_enable) key.parameter_hash=npu_hash_bytes(key.parameter_hash,rescale,(size_t)w_num*sizeof(*rescale));
    if(act_type==7)key.parameter_hash=npu_hash_bytes(key.parameter_hash,&edge_ppu_outscale,sizeof(edge_ppu_outscale));
    key.parameter_hash=npu_hash_bytes(key.parameter_hash,out_addr,(size_t)w_num*sizeof(*out_addr));
    edge_mac_args_t args={a_addr,w_addr,bias,rescale,out_addr,rescale_enable,
        act_enable,act_type,out_zp,insize,outsize,a_num,w_num};
    last_result=npu_cache_prepare(&edge_npu_runtime,&key,(uint32_t)words,encode_mac,&args,&prepared);
    if(last_result!=NPU_OK) return last_result;
    prepared_native=active_native;prepared_a=a_addr;prepared_w=w_addr;prepared_a_bytes=(size_t)(end_a-a_addr);prepared_w_bytes=(size_t)(end_w-w_addr);
    prepared_generation=edge_npu_runtime.views.generation;
    prepared_output=out_first; prepared_output_bytes=(size_t)(out_end-out_first);
    /* Flush all scratch inputs including packed-weight/activation boundaries.
     * Scratch stays mutable between requests; only CODE memory is cached. */
    uint64_t input_end=end_a>end_w?end_a:end_w;
    prepared_input_bytes=(size_t)(input_end-EDGE_NPU_SCRATCH_BASE);
    *inst_len=prepared.words;
    *exp_tag=(uint8_t)(edge_npu_runtime.next_tag+1U); if(!*exp_tag) *exp_tag=1;
    prepared_valid=1;
    return NPU_OK;
}
int npu_submit_prepared(uint64_t timeout_us)
{
    if(!prepared_valid) return last_result ? last_result : NPU_EINVAL;
    prepared_valid=0;
    last_result=prepared_native ? npu_runtime_submit_views(&edge_npu_runtime,&prepared,prepared_w,prepared_w_bytes,
        prepared_a,prepared_a_bytes,prepared_output,prepared_output_bytes,prepared_generation,timeout_us) :
        npu_runtime_submit(&edge_npu_runtime,&prepared,EDGE_NPU_SCRATCH_BASE,
        prepared_input_bytes,prepared_output,prepared_output_bytes,timeout_us);
    sync_flag=(last_result==NPU_OK); sync_tag=edge_npu_runtime.completed_tag;
    return last_result;
}
int npu_last_result(void) { return last_result; }
uint32_t npu_prepared_physical(void) { return prepared.physical; }

typedef struct {uint32_t a,w,o,as,ws,os,k,n,c;const int32_t *bias;} dw_batch_args;
static int encode_dw_batch(void *arg,void *dest,uint32_t capacity,uint32_t *written){
 dw_batch_args *p=arg;uint8_t *at=dest;uint32_t total=0;
 for(uint32_t c=0;c<p->c;++c){
  uint32_t output=p->o+c*p->os,rescale=0,count=0;uint8_t tag;
  int rc=npu_mac_generate(at,p->a+c*p->as,p->w+c*p->ws,(uint32_t*)(p->bias+c),0,&rescale,0,0,0,&output,p->k,p->n,p->n,1,&tag,&count);
  if(rc||count>capacity-total)return NPU_ECAPACITY;
  /* Intermediate barriers drain every datapath and reset ping-pong state.
   * Tag zero cannot match any runtime completion tag (which is always 1..255). */
  ((uint32_t*)at)[count*2-1]&=0x00FFFFFFU;
  total+=count;at+=count*8;
 }
 *written=total;return NPU_OK;
}
int npu_dw_batch_prepare(uint32_t a,uint32_t w,uint32_t o,uint32_t as,uint32_t ws,uint32_t os,uint32_t k,uint32_t n,uint32_t c,const int32_t *bias){
 prepared_valid=0;
 if(!edge_npu_runtime.ready||edge_npu_runtime.faulted||edge_npu_runtime.inflight||native_mode)return last_result=NPU_EFAULT;
 if(!c||c>64||!n||n>1024||!k||k>16||as<n*k||ws<k||os<n*4||(a&63)||(w&63)||(o&63)||(as&63)||(ws&63)||(os&63))return last_result=NPU_EINVAL;
 uintptr_t top=EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES;
 if(a<EDGE_NPU_SCRATCH_BASE||w<EDGE_NPU_SCRATCH_BASE||o<EDGE_NPU_SCRATCH_BASE||
    (uint64_t)a+as*c>top||(uint64_t)w+ws*c>top||(uint64_t)o+os*c>top||
    !npu_span_disjoint(a,as*c,o,os*c)||!npu_span_disjoint(w,ws*c,o,os*c)||!npu_span_disjoint(a,as*c,w,ws*c))return last_result=NPU_EINVAL;
 uint32_t words=c*(5+3*((n+7)/8));if(words>EDGE_NPU_DMA_MAX_WORDS)return last_result=NPU_ECAPACITY;
 npu_cache_key_t key=active_key;key.layout_version=0xD001;
 key.a_addr=a;key.w_addr=w;key.insize=k;key.outsize=n;key.a_num=n;key.w_num=c;
 uint32_t layout[4]={o,as,ws,os};key.parameter_hash=npu_hash_bytes(0,bias,c*4);
 key.parameter_hash=npu_hash_bytes(key.parameter_hash,layout,sizeof(layout));
 dw_batch_args args={a,w,o,as,ws,os,k,n,c,bias};
 last_result=npu_cache_prepare(&edge_npu_runtime,&key,words,encode_dw_batch,&args,&prepared);
 if(last_result)return last_result;
 prepared_native=0;prepared_output=o;prepared_output_bytes=os*c;
 uintptr_t end=a+as*c;if(w+ws*c>end)end=w+ws*c;
 prepared_input_bytes=end-EDGE_NPU_SCRATCH_BASE;prepared_valid=1;return NPU_OK;
}
