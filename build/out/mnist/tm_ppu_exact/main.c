#include "tinymaix.h"
#include "tiny_npu.h"
#include "vex_platform.h"
#include "model_blob.h"
#include "fixture.h"
#include "identity.h"
extern tm_err_t tm_run_cpu(tm_mdl_t*,tm_mat_t*,tm_mat_t*);
extern uint32_t edge_hw_windows;
extern int mnist_math_selftest(void);
static uint8_t model_buffer[MDL_BUF_LEN] __attribute__((aligned(64)));
static volatile uint32_t *const uart=(void*)0xF0000000U;
static void tx(char c){while(((uart[1]>>16)&255U)==0){}uart[0]=(uint8_t)c;}
static void put(const char*s){while(*s)tx(*s++);}
static void hex(uint32_t v){for(int i=7;i>=0;--i)tx("0123456789ABCDEF"[(v>>(i*4))&15]);}
static void decimal(uint64_t v){char b[24];unsigned n=0;do{b[n++]='0'+v%10;v/=10;}while(v);while(n)tx(b[--n]);}
static void fixed3(uint64_t milli){decimal(milli/1000);tx('.');tx('0'+milli/100%10);tx('0'+milli/10%10);tx('0'+milli%10);}
void *bench_malloc(size_t n){(void)n;return 0;}
void bench_free(void*p){(void)p;}
typedef struct{uint64_t cycles;uint32_t mode,rep,hits,misses,submissions,windows,quantizations,scores[10];}Row;
static Row rows[17];
static uint64_t profile_cycles[2][6],profile_external[2][6];
static uint32_t expected[10],layer_hash[2][32],extra_hash[2][32];
static uint32_t layer_seen[2],extra_seen[2],probe_scores[6][2][10],probe_pass[6];
static int validate_layer=-1,extended=0,input_case=0;
static tm_err_t layer_cb(tm_mdl_t*mdl,tml_head_t*h){
 if(validate_layer<0)return TM_OK;if(mdl->layer_i>=32)return TM_ERR;
 unsigned n=h->out_dims[1]*h->out_dims[2]*h->out_dims[3];
 const uint8_t*p=mdl->buf+h->out_oft;uint32_t v=2166136261U;
 while(n--){v^=*p++;v*=16777619U;}
 (extended?extra_hash:layer_hash)[validate_layer][mdl->layer_i]=v;
 (extended?extra_seen:layer_seen)[validate_layer]++;return TM_OK;
}
static int input_ready(tm_mdl_t*mdl,tm_mat_t*in){
 memset(model_buffer,0,sizeof(model_buffer));tm_mat_t raw=*in;raw.data=(mtype_t*)fixture_input;
 if(input_case){uint32_t random=0x271028A7U;uint8_t *probe_input=(uint8_t*)in->data;
  for(unsigned i=0;i<sizeof(fixture_input);++i){
   random^=random<<13;random^=random>>17;random^=random<<5;
   switch(input_case){
    case 1:probe_input[i]=128;break;
    case 2:probe_input[i]=(i*17+i/28*7)&255;break;
    case 3:probe_input[i]=random&255;break;
    case 4:probe_input[i]=255-fixture_input[i];break;
    case 5:probe_input[i]=0;break;
    default:probe_input[i]=255;break;
   }
  }raw.data=(mtype_t*)probe_input;
 }
 return tm_preprocess(mdl,TMPP_UINT2INT,&raw,in);
}
static int score_bits(tm_mat_t*out,uint32_t result[10]){
 if(out->h*out->w*out->c!=10)return 1;
 for(unsigned j=0;j<10;++j){union{float f;uint32_t u;}v;v.f=out->dataf[j];result[j]=v.u;}return 0;
}
static int run(void){
 tm_mdl_t mdl={0};tm_mat_t in={0},out[1]={{0}};
 int rc=tm_load(&mdl,mdl_data,model_buffer,layer_cb,&in);if(rc)return 100+rc;
 if(mdl.b->buf_size>sizeof(model_buffer)||mdl.b->sub_size||mdl.b->layer_cnt!=6)return 110;
 /* Reopening the HAL does not reset PL. Continue tags across UART reruns. */
 uint8_t previous_tag=edge_npu_runtime.next_tag;
 if(npu_platform_init()!=NPU_OK)return 111;
 /* The board exposes 32-bit CSR status ports. Bind hardware by the host's
  * routed-bitstream/source receipt; require three genuine PPU calls and exact
  * per-layer outputs below before accepting any measurement. */
 edge_npu_runtime.next_tag=previous_tag;
 npu_set_model(mdl_data,sizeof(mdl_data),1);if(npu_native_enable(0)!=NPU_OK)return 112;
 unsigned pos=0;
 for(unsigned mode=0;mode<4;++mode){unsigned count=mode==0?6:mode==1?1:5;
  for(unsigned rep=0;rep<count;++rep){
   if((mode==1||mode==2)&&npu_cache_invalidate(&edge_npu_runtime))return 113;
   if(input_ready(&mdl,&in))return 114;
   net_pref_info.total_layers=0;
   uint32_t hits=edge_npu_runtime.hits,misses=edge_npu_runtime.misses,subs=edge_npu_runtime.submissions,windows=edge_hw_windows,quants=edge_ppu_layers;
   vex_fence();uint64_t start=vex_cycles();
   rc=mode==0?tm_run_cpu(&mdl,&in,out):tm_run(&mdl,&in,out);
   uint64_t cycles=vex_cycles()-start;vex_fence();if(rc)return 200+rc;
   if((mode==0&&rep==1)||(mode==3&&rep==4))for(unsigned i=0;i<6;++i){
    unsigned backend=mode!=0;LayerTimeRecord*p=&net_pref_info.layers[i];
    profile_cycles[backend][i]=p->end_time-p->start_time;
    profile_external[backend][i]=backend?p->ext_end_time-p->ext_start_time:0;
   }
   Row*r=&rows[pos++];r->mode=mode;r->rep=rep;r->cycles=cycles;
   r->hits=edge_npu_runtime.hits-hits;r->misses=edge_npu_runtime.misses-misses;
   r->submissions=edge_npu_runtime.submissions-subs;r->windows=edge_hw_windows-windows;r->quantizations=edge_ppu_layers-quants;
   if(score_bits(out,r->scores))return 210;
   if(mode==0&&rep==0)memcpy(expected,r->scores,sizeof(expected));
   if(memcmp(expected,r->scores,sizeof(expected)))return 220+pos;
   if(r->quantizations!=(mode?3U:0U))return 254;
   if(mode==0&&(r->hits||r->misses||r->submissions||r->windows))return 250;
   if(mode&&(r->submissions!=4||r->windows!=3))return 251;
   if(mode==3&&(r->misses||r->hits!=r->submissions))return 252;
   if((mode==1||mode==2)&&(r->hits||r->misses!=r->submissions))return 253;
  }
 }
 /* All validation below is untimed and occurs after timing/profile snapshots. */
 for(unsigned backend=0;backend<2;++backend){
  if(npu_cache_invalidate(&edge_npu_runtime)||input_ready(&mdl,&in))return 260;
  validate_layer=backend;rc=backend?tm_run(&mdl,&in,out):tm_run_cpu(&mdl,&in,out);validate_layer=-1;
  if(rc)return 270+rc;
 }
 if(layer_seen[0]!=6||layer_seen[1]!=6||memcmp(layer_hash[0],layer_hash[1],6*4))return 281;
 extended=1;
 for(unsigned sample=0;sample<6;++sample){input_case=sample+1;memset(extra_seen,0,sizeof(extra_seen));
  for(unsigned backend=0;backend<2;++backend){
   if(npu_cache_invalidate(&edge_npu_runtime)||input_ready(&mdl,&in))return 290;
   uint32_t subs=edge_npu_runtime.submissions,windows=edge_hw_windows,quants=edge_ppu_layers;
   validate_layer=backend;rc=backend?tm_run(&mdl,&in,out):tm_run_cpu(&mdl,&in,out);validate_layer=-1;
   if(rc||score_bits(out,probe_scores[sample][backend]))return 300+sample;
   if(edge_ppu_layers-quants!=(backend?3U:0U))return 330+sample;
   if(edge_npu_runtime.submissions-subs!=(backend?4U:0U)||edge_hw_windows-windows!=(backend?3U:0U))return 310+sample;
  }
  if(extra_seen[0]!=6||extra_seen[1]!=6||memcmp(extra_hash[0],extra_hash[1],6*4)||memcmp(probe_scores[sample][0],probe_scores[sample][1],40))return 320+sample;
  probe_pass[sample]=1;
 }
 input_case=0;extended=0;if(mnist_math_selftest())return 340;return 0;
}
static uint64_t median_cycles(unsigned first){
 uint64_t a[5];for(unsigned i=0;i<5;++i)a[i]=rows[first+i].cycles;
 for(unsigned i=1;i<5;++i){uint64_t v=a[i];unsigned j=i;while(j&&a[j-1]>v){a[j]=a[j-1];--j;}a[j]=v;}return a[2];
}
static void demo_summary(int rc){
 put("\r\n=== TinyMaix MNIST CNN / exact PPU on XC7A100T ===\r\n");
 put("DEMO CLOCK CPU=50MHz NPU=50MHz\r\nDEMO SCOPE tm_run full inference; same model and input\r\n");
 if(rc){put("DEMO VALIDATION FAIL - no accepted speedup\r\n");return;}
 uint64_t cpu=median_cycles(1),cold=median_cycles(7),hot=median_cycles(12);
 put("DEMO CPU_MEDIAN_MS ");fixed3((cpu+25)/50);put("\r\nDEMO NPU_FIRST_MS ");fixed3((rows[6].cycles+25)/50);
 put("\r\nDEMO NPU_COLD_MEDIAN_MS ");fixed3((cold+25)/50);put("\r\nDEMO NPU_HOT_MEDIAN_MS ");fixed3((hot+25)/50);
 put("\r\nDEMO SPEEDUP_COLD ");fixed3((cpu*1000+cold/2)/cold);put("x\r\nDEMO SPEEDUP_HOT ");fixed3((cpu*1000+hot/2)/hot);put("x\r\n");
 put("DEMO VALIDATION PASS 6 layers; fixed input plus 6 stress inputs\r\nDEMO REPEAT send R (115200 baud, 8N1)\r\n");
}
static void report(int rc){
 for(unsigned p=0;p<17;++p){Row*r=&rows[p];put("R ");hex(r->mode);put(" N ");hex(r->rep);put(" C ");hex(r->cycles>>32);hex(r->cycles);
  put(" H ");hex(r->hits);put(" M ");hex(r->misses);put(" U ");hex(r->submissions);put(" W ");hex(r->windows);put(" Q ");hex(r->quantizations);put(" S");
  for(unsigned j=0;j<10;++j){tx(' ');hex(r->scores[j]);}put("\r\n");}
 for(unsigned i=0;i<layer_seen[0]&&i<32;++i){put("L ");hex(i);put(" CPU ");hex(layer_hash[0][i]);put(" NPU ");hex(layer_hash[1][i]);put("\r\n");}
 for(unsigned b=0;b<2;++b)for(unsigned i=0;i<6;++i){put("P ");hex(b);put(" L ");hex(i);put(" C ");hex(profile_cycles[b][i]>>32);hex(profile_cycles[b][i]);put(" E ");hex(profile_external[b][i]>>32);hex(profile_external[b][i]);put("\r\n");}
 for(unsigned sample=0;sample<6;++sample){put("V ");hex(sample);put(" CPU");for(unsigned j=0;j<10;++j){tx(' ');hex(probe_scores[sample][0][j]);}put(" NPU");for(unsigned j=0;j<10;++j){tx(' ');hex(probe_scores[sample][1][j]);}put(" MATCH ");hex(probe_pass[sample]);put("\r\n");}
 if(!rc)put("T MATH EXP_PAIRS 00008080 GAP_VALUES 00000100 FC_BOUNDARIES 000004FB FC_RANDOM 00000400\r\n");
 demo_summary(rc);put("END ");hex(rc);put("\r\n");
}
int main(void){
 uart[2]=53;uart[3]=7;
 for(;;){
  memset(rows,0,sizeof(rows));memset(layer_seen,0,sizeof(layer_seen));memset(probe_pass,0,sizeof(probe_pass));
  validate_layer=-1;extended=0;input_case=0;edge_hw_windows=0;edge_ppu_layers=0;
  put("BOOT VEX_MNIST_PQ2\r\nMODEL ");put(MODEL_SHA);put("\r\nINPUT ");put(INPUT_SHA);
  put("\r\nVEX_MNIST_PQ2 hz=02FAF080 rows=00000011 boundary=tm_run_only conv_window=hardware weight_resident=0 quant_cache=1 ppu_exact=1 math_tables=1\r\n");
  int rc=run();report(rc);
  for(;;){if((uart[1]>>24)&255U){char c=(char)uart[0];if(c=='r'||c=='R')break;}}
 }
}
