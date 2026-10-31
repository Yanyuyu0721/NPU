from pathlib import Path
import shutil
H=Path(__file__).resolve().parent;S=H/'snapshots/config';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
def edit(p,old,new):
 s=p.read_text(encoding='utf-8');assert old in s,(p,old);p.write_text(s.replace(old,new),encoding='utf-8')
edit(H/'source/tm_layers.c','#include "quant_plan.inc"','#include "quant_plan.inc"\n#include "resident_weights.inc"')
edit(H/'source/npu_mac_adapter.inc','extern void npu_quant_reset(void);npu_quant_reset();','extern void npu_quant_reset(void);npu_quant_reset();\n    extern void mnist_weight_reset(const void*,size_t);mnist_weight_reset(model,bytes);')
p=H/'source/tm_layers.c';s=p.read_text();a=s.index('tm_err_t tml_conv2d_npu(');b=s.index('#include <string.h>',a)
left,m,right=s[:a],s[a:b],s[b:]
m=m.replace('if (inst_rel_addr > EDGE_NPU_SCRATCH_BYTES)', 'if (inst_rel_addr > MNIST_RESIDENT_BASE)')
old='if(!native){if(use_hw_window)memcpy(w_arr,w,weight_size);else sw_pack_weight(w,w_arr,out->c,in->c,maxk);}'
new='''uint32_t resident_address=0;
    if(!native){
     if(use_hw_window){if(mnist_weight_get(w,weight_size,net_pref_info.total_layers,&resident_address))return TM_ERR;}
     else sw_pack_weight(w,w_arr,out->c,in->c,maxk);
    }'''
assert old in m;m=m.replace(old,new)
m=m.replace('uint32_t w_addr  = native?(uint32_t)(uintptr_t)w_arr:NPU_SHARED_MEM(w_arr_addr);','uint32_t w_addr  = resident_address?resident_address:native?(uint32_t)(uintptr_t)w_arr:NPU_SHARED_MEM(w_arr_addr);')
s=left+m+right
a=s.index('tm_err_t TM_WEAK tml_fc_npu(');b=s.index('/*************************** TML_SOFTMAX',a)
left,m,right=s[:a],s[a:b],s[b:]
m=m.replace('if (inst_rel_addr > EDGE_NPU_SCRATCH_BYTES)', 'if (inst_rel_addr > MNIST_RESIDENT_BASE)')
old='memcpy(w_arr, w, weight_size * sizeof(wtype_t));';assert old in m
m=m.replace(old,'uint32_t resident_address=0;\n    if(mnist_weight_get(w,weight_size,net_pref_info.total_layers,&resident_address))return TM_ERR;')
m=m.replace('uint32_t w_addr  = NPU_SHARED_MEM(w_arr_addr);','uint32_t w_addr  = resident_address;')
p.write_text(left+m+right)
# A full-domain exact function table for final INT8 -> FP32 dequantization.
lines=['#pragma once','static const float mnist_dequant_lut[256]={']
for i in range(0,256,8):lines.append(','.join(float(v/256).hex()+'f'for v in range(i,i+8))+',')
lines.append('};');(H/'source/mnist_dequant_table.h').write_text('\n'.join(lines)+'\n')
p=H/'source/mnist_math_fast.inc';s=p.read_text();s=s.replace('#include "mnist_math_tables.h"','#include "mnist_math_tables.h"\n#include "mnist_dequant_table.h"')
start=s.index('int mnist_math_selftest(void)')
new='''int mnist_dequant_model(const tml_head_t*h,const mtype_t*input,float*output,unsigned count){
 if(h->out_zp!=-128||mnist_bits(h->out_s)!=0x3B800000U)return 0;
 for(unsigned i=0;i<count;++i)output[i]=mnist_dequant_lut[(int)input[i]+128];
 return 1;
}
int mnist_dequant_selftest(void){
 union{uint32_t u;float f;}scale={0x3B800000U};
 for(unsigned i=0;i<256;++i)if(mnist_bits((float)i*scale.f)!=mnist_bits(mnist_dequant_lut[i]))return 1;
 return 0;
}
'''
s=s[:start]+new+s[start:];p.write_text(s)
p=H/'source/tm_model.c';edit(p,'#include "tiny_npu.h"','#include "tiny_npu.h"\nextern int mnist_dequant_model(const tml_head_t*,const mtype_t*,float*,unsigned);')
old='''for(int i=0; i<out_size; i++) //do dequant
                    outf[i] = TML_DEQUANT(h, (TML_GET_OUTPUT(mdl, h))[i]);'''
new='''#if NPU_PLATFORM == 0
                for(int i=0; i<out_size; i++) //do dequant
                    outf[i] = TML_DEQUANT(h, (TML_GET_OUTPUT(mdl, h))[i]);
#else
                if(!mnist_dequant_model(h,TML_GET_OUTPUT(mdl,h),outf,out_size))
                 for(int i=0;i<out_size;++i)outf[i]=TML_DEQUANT(h,(TML_GET_OUTPUT(mdl,h))[i]);
#endif'''
edit(p,old,new)
p=H/'main.c'
edit(p,'extern int mnist_math_selftest(void);','extern int mnist_math_selftest(void);\nextern int mnist_dequant_selftest(void);\nextern uint32_t edge_weight_loads,edge_weight_hits;\nstatic uint32_t weight_counts[17][2];')
edit(p,'uint32_t hits=edge_npu_runtime.hits,','uint32_t wl=edge_weight_loads,wh=edge_weight_hits;\n   uint32_t hits=edge_npu_runtime.hits,')
edit(p,'Row*r=&rows[pos++];','''weight_counts[pos][0]=edge_weight_loads-wl;weight_counts[pos][1]=edge_weight_hits-wh;
   if(weight_counts[pos][0]!=(mode==1?4U:0U)||weight_counts[pos][1]!=((mode==2||mode==3)?4U:0U))return 255;
   Row*r=&rows[pos++];''')
edit(p,'if(kws_ppu_copy_selftest())return 341;return 0;','if(kws_ppu_copy_selftest())return 341;if(mnist_dequant_selftest())return 342;return 0;')
edit(p,'demo_summary(rc);put("END ");','''for(unsigned p=0;p<17;++p){put("B P ");hex(p);put(" L ");hex(weight_counts[p][0]);put(" H ");hex(weight_counts[p][1]);put("\\r\\n");}
 if(!rc)put("T DEQUANT VALUES 00000100\\r\\n");
 demo_summary(rc);put("END ");''')
for n in ['main.c','demo_capture.py']:
 p=H/n;s=p.read_text(encoding='utf-8').replace('VEX_MNIST_PQ4','VEX_MNIST_PQ5').replace('weight_resident=0','weight_resident=1');p.write_text(s,encoding='utf-8')
p=H/'demo_capture.py'
edit(p,"medians={m:statistics.median",'''weight_rows=re.findall(r'^B P ([0-9A-F]{8}) L ([0-9A-F]{8}) H ([0-9A-F]{8})$',text,re.M)
 assert len(weight_rows)==count,'weight preparation counts missing'
 for i,((p,l,h),r)in enumerate(zip(weight_rows,records)):
  assert int(p,16)==i and int(l,16)==(4 if r['mode']==1 else 0) and int(h,16)==(4 if r['mode'] in(2,3)else 0),'weight preparation counts'
 medians={m:statistics.median''')
edit(p,"assert 'T COPY CASES", "assert 'T DEQUANT VALUES 00000100\\n'in text,'dequant selftest missing'\n assert 'T COPY CASES")
print('RESIDENT_WEIGHTS_AND_EXACT_DEQUANT_READY')
