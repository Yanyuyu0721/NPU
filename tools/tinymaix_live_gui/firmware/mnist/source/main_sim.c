#include "tinymaix.h"
#include "tiny_npu.h"
#include "vex_platform.h"
#include "model_blob.h"
#include "fixture.h"
#include "identity.h"

extern tm_err_t tm_run_cpu(tm_mdl_t *,tm_mat_t *,tm_mat_t *);
static uint8_t model_buffer[MDL_BUF_LEN] __attribute__((aligned(64)));
static volatile uint32_t *const uart=(void *)0xF0000000U;
static void tx(char c){*(volatile uint32_t *)0xA002B040U=(uint8_t)c;}
static void put(const char *s){while(*s)tx(*s++);}
static void hex(uint32_t v){for(int i=7;i>=0;--i)tx("0123456789ABCDEF"[(v>>(i*4))&15U]);}
void *bench_malloc(size_t n){(void)n;return 0;}
void bench_free(void *p){(void)p;}

typedef struct {uint64_t cycles;uint32_t mode,rep,hits,misses,submissions,scores[3];} Row;
static Row rows[17];
static uint32_t expected[3],layer_hash[2][32];
static int validate_layer=-1;
static uint32_t layer_seen[2];
static tm_err_t layer_cb(tm_mdl_t *mdl,tml_head_t *h){
 if(validate_layer<0)return TM_OK;
 if(mdl->layer_i>=32)return TM_ERR;
 unsigned n=h->out_dims[1]*h->out_dims[2]*h->out_dims[3];
 if(h->type==TML_SOFTMAX)n*=4;
 const uint8_t *p=mdl->buf+h->out_oft;uint32_t v=2166136261U;
 while(n--){v^=*p++;v*=16777619U;}
 layer_hash[validate_layer][mdl->layer_i]=v;layer_seen[validate_layer]++;
 return TM_OK;
}
static int input_ready(tm_mdl_t *mdl,tm_mat_t *in){
 memset(model_buffer,0,sizeof(model_buffer));
 tm_mat_t raw=*in;raw.data=(mtype_t *)fixture_input;
 return tm_preprocess(mdl,TMPP_UINT2INT,&raw,in);
}
static int score_bits(tm_mat_t *out,uint32_t result[3]){
 if(out->h*out->w*out->c!=3)return 1;
 for(unsigned j=0;j<3;++j){union {float f;uint32_t u;}v;v.f=out->dataf[j];result[j]=v.u;}
 return 0;
}
static int run(void){
 tm_mdl_t mdl={0};tm_mat_t in={0},out[1]={{0}};
 int rc=tm_load(&mdl,mdl_data,model_buffer,layer_cb,&in);if(rc)return 100+rc;
 if(mdl.b->buf_size>sizeof(model_buffer)||mdl.b->sub_size||mdl.b->layer_cnt>32)return 110;
 if(npu_platform_init()!=NPU_OK)return 111;
 npu_set_model(mdl_data,sizeof(mdl_data),2);
 if(npu_native_enable(0)!=NPU_OK)return 112;
 unsigned pos=0;
 for(unsigned mode=0;mode<4;++mode){
  unsigned count=1;
  for(unsigned rep=0;rep<count;++rep){
   if(mode==1||mode==2){if(npu_cache_invalidate(&edge_npu_runtime))return 113;}
   if(input_ready(&mdl,&in))return 114;
   net_pref_info.total_layers=0;
   uint32_t hits=edge_npu_runtime.hits,misses=edge_npu_runtime.misses,subs=edge_npu_runtime.submissions;
   vex_fence();uint64_t start=vex_cycles();
   rc=mode==0?tm_run_cpu(&mdl,&in,out):tm_run(&mdl,&in,out);
   uint64_t cycles=vex_cycles()-start;vex_fence();
   if(rc)return 200+rc;
   Row *r=&rows[pos++];r->mode=mode;r->rep=rep;r->cycles=cycles;
   r->hits=edge_npu_runtime.hits-hits;r->misses=edge_npu_runtime.misses-misses;r->submissions=edge_npu_runtime.submissions-subs;
   if(score_bits(out,r->scores))return 210;
   if(mode==0&&rep==0)memcpy(expected,r->scores,sizeof(expected));
   if(memcmp(expected,r->scores,sizeof(expected)))return 220+pos;
   if(mode==0&&(r->hits||r->misses||r->submissions))return 250;
   if(mode!=0&&r->submissions==0)return 251;
   if(mode==3&&(r->misses||r->hits!=r->submissions))return 252;
   if((mode==1||mode==2)&&(r->hits||r->misses!=r->submissions))return 253;
  }
 }
 /* Untimed, layer-by-layer validation. Hashing is disabled in every timing row. */
 for(unsigned backend=0;backend<2;++backend){
  if(npu_cache_invalidate(&edge_npu_runtime))return 260;
  if(input_ready(&mdl,&in))return 261;
  net_pref_info.total_layers=0;validate_layer=backend;
  rc=backend?tm_run(&mdl,&in,out):tm_run_cpu(&mdl,&in,out);
  validate_layer=-1;if(rc)return 270+rc;
 }
 if(layer_seen[0]!=mdl.b->layer_cnt||layer_seen[1]!=mdl.b->layer_cnt)return 280;
 if(memcmp(layer_hash[0],layer_hash[1],mdl.b->layer_cnt*sizeof(uint32_t)))return 281;
 return 0;
}
int main(void){
 uart[2]=53U;uart[3]=7U;
 put("BOOT VEX_TM_V1\r\nMODEL ");put(MODEL_SHA);put("\r\nINPUT ");put(INPUT_SHA);
 put("\r\nVEX_TM_V1 hz=02FAF080 rows=00000004 boundary=tm_run_only sw_im2col=1 weight_resident=0\r\n");
 int rc=run();
 for(unsigned p=0;p<4;++p){Row *r=&rows[p];
  put("R ");hex(r->mode);put(" N ");hex(r->rep);put(" C ");hex(r->cycles>>32);hex(r->cycles);
  put(" H ");hex(r->hits);put(" M ");hex(r->misses);put(" U ");hex(r->submissions);put(" S");
  for(unsigned j=0;j<3;++j){tx(' ');hex(r->scores[j]);}put("\r\n");
 }
 for(unsigned p=0;p<layer_seen[0]&&p<32;++p){put("L ");hex(p);put(" CPU ");hex(layer_hash[0][p]);put(" NPU ");hex(layer_hash[1][p]);put("\r\n");}
 put("END ");hex(rc);put("\r\n");return rc;
}
