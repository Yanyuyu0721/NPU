#include "tinymaix.h"
#include "tiny_npu.h"
#include "vex_platform.h"
#include "model_blob.h"
#include "fixture.h"
#include "identity.h"
#if LIVE_TASK == 1
#define INPUT_BYTES 784
#define CLASSES 10
#define LAYERS 6
#define SUBMISSIONS 4
#define WINDOWS 3
#define QUANTS 3
extern int mnist_math_selftest(void),mnist_dequant_selftest(void),mnist_softmax_quant_selftest(void),mnist_config_cache_selftest(void);
extern uint32_t edge_weight_loads,edge_weight_hits;
#else
#define INPUT_BYTES 2560
#define CLASSES 3
#define LAYERS 13
#define SUBMISSIONS 11
#define WINDOWS 4
#define QUANTS 8
extern int kws_math_selftest(void);
#endif
extern int kws_ppu_copy_selftest(void);
extern tm_err_t tm_run_cpu(tm_mdl_t*,tm_mat_t*,tm_mat_t*);
extern uint32_t edge_hw_windows;
static uint8_t model_buffer[MDL_BUF_LEN] __attribute__((aligned(64)));
static uint8_t input_buffer[INPUT_BYTES] __attribute__((aligned(4)));
static volatile uint32_t *const uart=(void*)0xF0000000U;
static void tx(char c){while(((uart[1]>>16)&255U)==0){}uart[0]=(uint8_t)c;}
static void put(const char*s){while(*s)tx(*s++);}
static void hex(uint32_t v){for(int i=7;i>=0;--i)tx("0123456789ABCDEF"[(v>>(i*4))&15]);}
void *bench_malloc(size_t n){(void)n;return 0;}
void bench_free(void*p){(void)p;}
static int rx(uint64_t timeout){uint64_t start=vex_cycles();for(;;){if((uart[1]>>24)&255U)return (uint8_t)uart[0];if(timeout&&vex_cycles()-start>=timeout)return -1;}}
static uint32_t crc_byte(uint32_t c,uint8_t b){c^=b;for(unsigned i=0;i<8;++i)c=(c>>1)^((0U-(c&1U))&0xEDB88320U);return c;}
static uint32_t input_crc(void){uint32_t c=UINT32_MAX;for(unsigned i=0;i<INPUT_BYTES;++i)c=crc_byte(c,input_buffer[i]);return c^UINT32_MAX;}
static void info(void){put("INFO TMLIVE1 TASK ");hex(LIVE_TASK);put(" HZ ");hex(50000000);put(" BYTES ");hex(INPUT_BYTES);put(" MODEL ");put(MODEL_SHA);put("\r\nREADY\r\n");}
typedef struct{uint64_t cycles;uint32_t mode,rep,hits,misses,subs,windows,quants,loads,weight_hits,scores[CLASSES];}Row;
static Row rows[17];
static uint32_t hashes[2][LAYERS],seen[2],reference[CLASSES];
static int validating=-1;
static tm_err_t layer_cb(tm_mdl_t *mdl,tml_head_t*h){
 if(validating<0)return TM_OK;if(mdl->layer_i>=LAYERS)return TM_ERR;
 unsigned n=h->out_dims[1]*h->out_dims[2]*h->out_dims[3];const uint8_t*p=mdl->buf+h->out_oft;uint32_t v=2166136261U;
 while(n--){v^=*p++;v*=16777619U;}hashes[validating][mdl->layer_i]=v;++seen[validating];return TM_OK;
}
static int prepare_input(tm_mdl_t*mdl,tm_mat_t*in){memset(model_buffer,0,sizeof(model_buffer));tm_mat_t raw=*in;raw.data=(mtype_t*)input_buffer;return tm_preprocess(mdl,TMPP_UINT2INT,&raw,in);}
static int copy_scores(tm_mat_t*out,uint32_t*s){if(out->h*out->w*out->c!=CLASSES)return 1;for(unsigned j=0;j<CLASSES;++j){union{float f;uint32_t u;}v;v.f=out->dataf[j];s[j]=v.u;}return 0;}
static int infer(void){
 tm_mdl_t mdl={0};tm_mat_t in={0},out[1]={{0}};
 int rc=tm_load(&mdl,mdl_data,model_buffer,layer_cb,&in);if(rc)return 100+rc;
 if(mdl.b->buf_size>sizeof(model_buffer)||mdl.b->sub_size||mdl.b->layer_cnt!=LAYERS)return 110;
 uint8_t previous=edge_npu_runtime.next_tag;if(npu_platform_init()!=NPU_OK)return 111;edge_npu_runtime.next_tag=previous;
 npu_set_model(mdl_data,sizeof(mdl_data),LIVE_TASK);if(npu_native_enable(0)!=NPU_OK)return 112;
 unsigned pos=0;validating=-1;memset(seen,0,sizeof(seen));
 for(unsigned mode=0;mode<4;++mode){unsigned count=mode==0?6:mode==1?1:5;
  for(unsigned rep=0;rep<count;++rep){
   if((mode==1||mode==2)&&npu_cache_invalidate(&edge_npu_runtime))return 113;
   if(prepare_input(&mdl,&in))return 114;
   uint32_t hits=edge_npu_runtime.hits,misses=edge_npu_runtime.misses,subs=edge_npu_runtime.submissions,windows=edge_hw_windows,quants=edge_ppu_layers;
#if LIVE_TASK == 1
   uint32_t loads=edge_weight_loads,wh=edge_weight_hits;
#endif
   vex_fence();uint64_t start=vex_cycles();
   rc=mode==0?tm_run_cpu(&mdl,&in,out):tm_run(&mdl,&in,out);
   uint64_t cycles=vex_cycles()-start;vex_fence();if(rc)return 200+rc;
   Row*r=&rows[pos++];r->mode=mode;r->rep=rep;r->cycles=cycles;
   r->hits=edge_npu_runtime.hits-hits;r->misses=edge_npu_runtime.misses-misses;r->subs=edge_npu_runtime.submissions-subs;
   r->windows=edge_hw_windows-windows;r->quants=edge_ppu_layers-quants;r->loads=0;r->weight_hits=0;
#if LIVE_TASK == 1
   r->loads=edge_weight_loads-loads;r->weight_hits=edge_weight_hits-wh;
   if(r->loads!=(mode==1?4U:0U)||r->weight_hits!=((mode==2||mode==3)?4U:0U))return 255;
#endif
   if(copy_scores(out,r->scores))return 210;
   if(mode==0&&rep==0)memcpy(reference,r->scores,sizeof(reference));
   if(memcmp(reference,r->scores,sizeof(reference)))return 220+pos;
   if(r->subs!=(mode?SUBMISSIONS:0)||r->windows!=(mode?WINDOWS:0)||r->quants!=(mode?QUANTS:0))return 250;
   if(mode==0&&(r->hits||r->misses))return 251;
   if(mode==3&&(r->hits!=SUBMISSIONS||r->misses))return 252;
   if((mode==1||mode==2)&&(r->hits||r->misses!=SUBMISSIONS))return 253;
  }
 }
 /* Input-dependent layer equality is checked after the timing samples. */
 for(unsigned b=0;b<2;++b){
  if(prepare_input(&mdl,&in)||npu_cache_invalidate(&edge_npu_runtime))return 260;
  validating=b;rc=b?tm_run(&mdl,&in,out):tm_run_cpu(&mdl,&in,out);validating=-1;
  uint32_t result[CLASSES];if(rc||copy_scores(out,result)||memcmp(result,reference,sizeof(result)))return 270;
 }
 if(seen[0]!=LAYERS||seen[1]!=LAYERS||memcmp(hashes[0],hashes[1],sizeof(hashes[0])))return 281;
 return 0;
}
static void report(uint32_t seq,uint32_t crc,int rc){
 put("BEGIN TMLIVE1 TASK ");hex(LIVE_TASK);put(" SEQ ");hex(seq);put(" LEN ");hex(INPUT_BYTES);put(" CRC ");hex(crc);put("\r\nMODEL ");put(MODEL_SHA);put("\r\n");
 if(!rc){
  for(unsigned p=0;p<17;++p){Row*r=&rows[p];put("R ");hex(r->mode);put(" N ");hex(r->rep);put(" C ");hex(r->cycles>>32);hex(r->cycles);
   put(" H ");hex(r->hits);put(" M ");hex(r->misses);put(" U ");hex(r->subs);put(" W ");hex(r->windows);put(" Q ");hex(r->quants);
   put(" B ");hex(r->loads);put(" K ");hex(r->weight_hits);put(" S");for(unsigned j=0;j<CLASSES;++j){tx(' ');hex(r->scores[j]);}put("\r\n");
  }
  for(unsigned i=0;i<LAYERS;++i){put("L ");hex(i);put(" CPU ");hex(hashes[0][i]);put(" NPU ");hex(hashes[1][i]);put("\r\n");}
 }
 put("END ");hex(seq);put(" RC ");hex(rc);put("\r\nREADY\r\n");
}
static int boot_checks(void){
 if(npu_platform_init()!=NPU_OK)return 1;npu_set_model(mdl_data,sizeof(mdl_data),LIVE_TASK);
 if(kws_ppu_copy_selftest())return 2;
#if LIVE_TASK == 1
 if(mnist_math_selftest())return 3;if(mnist_dequant_selftest())return 4;
 if(mnist_softmax_quant_selftest())return 5;if(mnist_config_cache_selftest())return 6;
#else
 if(kws_math_selftest())return 3;
#endif
 return 0;
}
int main(void){
 uart[2]=53;uart[3]=7;put("BOOT TMLIVE1\r\n");int checks=boot_checks();put("CHECK ");hex(checks);put("\r\n");
 if(checks){put("FAULT\r\n");for(;;){}}
 info();unsigned magic=0;const char pattern[4]={'T','M','G','1'};
 for(;;){
  int b=rx(0);
  if(magic==0&&b=='?'){info();continue;}
  if(magic==0&&b=='R'){memcpy(input_buffer,fixture_input,INPUT_BYTES);uint32_t c=input_crc();int rc=infer();if(input_crc()!=c)rc=290;report(0,c,rc);continue;}
  if(b!=pattern[magic]){magic=b=='T'?1:0;continue;}if(++magic<4)continue;magic=0;
  uint8_t header[10];int valid=1;for(unsigned i=0;i<10;++i){b=rx(100000000ULL);if(b<0){valid=0;break;}header[i]=(uint8_t)b;}
  if(!valid){put("ERROR HEADER_TIMEOUT\r\nREADY\r\n");continue;}
  unsigned task=header[0],flags=header[1],seq=header[2]|((unsigned)header[3]<<8),length=header[4]|((unsigned)header[5]<<8);
  uint32_t expected=(uint32_t)header[6]|((uint32_t)header[7]<<8)|((uint32_t)header[8]<<16)|((uint32_t)header[9]<<24);
  if(task!=LIVE_TASK||flags||length!=INPUT_BYTES){put("ERROR HEADER_MISMATCH\r\nREADY\r\n");continue;}
  tx(6);uint32_t crc=UINT32_MAX;
  for(unsigned i=0;i<length;++i){b=rx(100000000ULL);if(b<0){valid=0;break;}input_buffer[i]=(uint8_t)b;crc=crc_byte(crc,b);if((i&63U)==63U||i+1==length)tx(6);}
  if(!valid){put("ERROR PAYLOAD_TIMEOUT\r\nREADY\r\n");continue;}
  crc^=UINT32_MAX;if(crc!=expected){put("ERROR CRC_MISMATCH\r\nREADY\r\n");continue;}
  int rc=infer();if(input_crc()!=crc)rc=290;report(seq,crc,rc);
 }
}
