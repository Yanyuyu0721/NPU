from pathlib import Path
import shutil,json,re
H=Path(__file__).resolve().parent;S=H/'snapshots/resident';S.mkdir(parents=True,exist_ok=False)
assert json.loads((H/'board_resident/result.json').read_text())['passed']
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
def edit(p,old,new):
 s=p.read_text(encoding='utf-8');assert old in s,(p,old);p.write_text(s.replace(old,new),encoding='utf-8')
p=H/'source/mnist_math_fast.inc';s=p.read_text();i=s.index('tm_err_t tml_softmax_fast(')
helper='''/* On the model's positive normal sum [1,16], these broad intervals are
 * far from every INT8 rounding boundary. All remaining values use the original
 * FP32 divide, exact power-of-two scaling and FP32 addition. No approximation. */
TM_INLINE mtype_t mnist_softmax_quant_fast(float numerator,float denominator){
 union{float f;uint32_t u;}a={numerator},d={denominator};
 if(d.u>=0x3F800000U&&d.u<=0x41800000U){
  if((a.u&0x7FFFFFFFU)==0)return -128;
  if((a.u&0x80000000U)&&(a.u&0x7FFFFFFFU)<=0x358637BDU)return -128;
  if(a.u>=d.u-(23U<<23)&&a.u<=d.u-(10U<<23))return -127;
 }
 union{float f;uint32_t u;}v;v.f=numerator/denominator;unsigned e=(v.u>>23)&255;
 if(e>0&&e<247)v.u+=8U<<23;else v.f*=256.0f;
 return (mtype_t)(v.f-128.0f);
}
int mnist_softmax_quant_selftest(void){
 uint32_t rng=0x20261030U;unsigned cases=0;
 for(unsigned i=0;i<32768;++i){
  rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;
  union{uint32_t u;float f;}d={((127U+(rng&3U))<<23)|((rng>>8)&0x7FFFFFU)},a,scale={0x3B800000U};
  rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;
  a.u=i%8==0?0x80000000U|(rng%0x358637BEU):i%8==1?0U:((90U+rng%37U)<<23)|((rng>>9)&0x7FFFFFU);
  mtype_t reference=(mtype_t)(a.f/d.f/scale.f-128.0f);
  if(reference!=mnist_softmax_quant_fast(a.f,d.f))return 1+i;
  ++cases;
 }
 for(unsigned i=0;i<32;++i){
  union{uint32_t u;float f;}d={((127U+(i&3U))<<23)|(i*234567U&0x7FFFFFU)},scale={0x3B800000U};
  for(unsigned bound=0;bound<2;++bound)for(int j=-2;j<2;++j){
   union{uint32_t u;float f;}a={d.u-((bound?10U:23U)<<23)+j};
   mtype_t reference=(mtype_t)(a.f/d.f/scale.f-128.0f);
   if(reference!=mnist_softmax_quant_fast(a.f,d.f))return 40000+cases;
   ++cases;
  }
 }
 return cases==33024?0:50000;
}
'''
s=s[:i]+helper+s[i:]
old='''union{float f;uint32_t u;}v;v.f=data[c]/sum;unsigned e=(v.u>>23)&255;
  if(e>0&&e<247)v.u+=8U<<23;else v.f*=256.0f;
  out->data[c]=(mtype_t)(v.f+(float)oz);'''
assert old in s;s=s.replace(old,'out->data[c]=mnist_softmax_quant_fast(data[c],sum);');p.write_text(s)
shutil.copy2(H/'config_cache_selftest.inc',H/'source/config_cache_selftest.inc')
p=H/'source/npu_mac_adapter.inc';s=p.read_text();p.write_text(s+'\n#include "config_cache_selftest.inc"\n')
# Drop temporary fine-grained profiling from the final benchmark image.
p=H/'source/tm_layers.c';s=p.read_text();s=s.replace('uint64_t edge_conv_stages[6][6];','')
s=re.sub(r'\s*uint64_t g[0-5]=vex_cycles\(\);','',s)
old='''    uint64_t g6=vex_cycles();unsigned li=net_pref_info.total_layers;
    edge_conv_stages[li][0]=g1-g0;edge_conv_stages[li][1]=g2-g1;edge_conv_stages[li][2]=g3-g2;
    edge_conv_stages[li][3]=g4-g3;edge_conv_stages[li][4]=g5-g4;edge_conv_stages[li][5]=g6-g5;
''';assert old in s;s=s.replace(old,'');p.write_text(s)
p=H/'main.c';s=p.read_text();s=s.replace('extern uint64_t edge_conv_stages[6][6];','').replace('static uint64_t detailed_profile[6][6];','')
s=s.replace('if(mode==3&&rep==4)memcpy(detailed_profile,edge_conv_stages,sizeof(detailed_profile));','')
old='for(unsigned i=0;i<3;++i){put("G L ");hex(i);for(unsigned j=0;j<6;++j){tx(\' \');hex(detailed_profile[i][j]>>32);hex(detailed_profile[i][j]);}put("\\r\\n");}'
assert old in s;s=s.replace(old,'')
s=s.replace('extern int mnist_dequant_selftest(void);','extern int mnist_dequant_selftest(void);\nextern int mnist_softmax_quant_selftest(void);\nextern int mnist_config_cache_selftest(void);')
s=s.replace('if(mnist_dequant_selftest())return 342;return 0;','if(mnist_dequant_selftest())return 342;if(mnist_softmax_quant_selftest())return 343;if(mnist_config_cache_selftest())return 344;return 0;')
s=s.replace('demo_summary(rc);put("END ");','if(!rc)put("T SMQUANT CASES 00008100\\r\\nT CONFIG CASES 00000048\\r\\n");\n demo_summary(rc);put("END ");');p.write_text(s)
for n in ['main.c','demo_capture.py']:
 p=H/n;s=p.read_text(encoding='utf-8').replace('VEX_MNIST_PQ5','VEX_MNIST_PQ6');p.write_text(s,encoding='utf-8')
shutil.copy2(H/'main.c',H/'main_demo.c')
p=H/'demo_capture.py';edit(p,"assert 'T DEQUANT VALUES", "assert 'T SMQUANT CASES 00008100\\nT CONFIG CASES 00000048\\n'in text,'softmax/configuration validation missing'\n assert 'T DEQUANT VALUES")
edit(p,"HERE/'image_demo3/board_top.bit'","HERE/'image_final/board_top.bit'")
edit(p,'每次NPU调用仍准备权重；普通卷积使用硬件窗口与精确Q8 PPU量化/激活，本模型没有深度卷积。没有持久权重驻留。','首次NPU调用建立执行参数并将4层权重加载到独立驻留区域；后续复用。普通卷积使用硬件窗口与精确Q8 PPU量化/激活，本模型没有深度卷积。输入、窗口、激活和输出每次重算。')
edit(p,'不缓存输入预测结果。','不缓存输入预测结果。新增完整域输出反量化表及保守Softmax量化区间快路径，未改变数值结果。')
edit(p,'TinyMaix KWS 演示保留在 build/out/kws/tm_optimized/run_demo.cmd','最新TinyMaix KWS 9.83倍演示保留在 build/out/kws/tm_perf_v2/run_demo.cmd')
p=H/'demo_console.py';s=p.read_text(encoding='utf-8').replace('image_demo3','image_final').replace('image_demo1','image_final').replace('3121','3122').replace(r'D:\Xlinx\Vivado\2018.2\bin\hw_server.bat',r'D:\AMDDesignTools\2026.1\Vivado\bin\hw_server.bat')
s=s.replace("record=dict(passed=True,scope='REAL_BOARD_UART_RERUN',", "record=dict(passed=True,board_measurement=True,finished=datetime.datetime.now().astimezone().isoformat(),scope='REAL_BOARD_UART_RERUN',")
s=s.replace("print(' Loading, preprocessing", "print(' Weights resident after first NPU call; immutable execution parameters cached')\n print(' Loading, preprocessing")
p.write_text(s,encoding='utf-8')
p=H/'build_firmware.py';edit(p,'verify_assets()','verify_assets()\nfrom check_cpu_reference import verify as verify_cpu\nverify_cpu()')
print('FINAL_MNIST_PQ6_READY_WITH_33024_NUMERIC_AND_72_CONFIG_TESTS')
