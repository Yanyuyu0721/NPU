"""Exact unary functions from model parameters; no input/prediction caching."""
from pathlib import Path
import struct,json,shutil,hashlib
H=Path(__file__).resolve().parent
S=H/'snapshots/column';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
a=(H/'model.bin').read_bytes();o=64;layers=[]
f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
bits=lambda x:struct.unpack('<I',struct.pack('<f',x))[0]
for i in range(13):
    t,io,size,ino,outo=struct.unpack_from('<HHIII',a,o)
    ins,iz,outs,oz=struct.unpack_from('<fifi',a,o+32)
    row=dict(i=i,type=t,in_s=ins,in_zp=iz,out_s=outs,out_zp=oz)
    if t==2:
        ws=struct.unpack_from('<I',a,o+48)[0];row['ws']=struct.unpack_from('<f',a,o+ws)[0]
    layers.append(row);o+=size
gap=layers[8];fc=layers[9:12]
lut=[(int(f(f(f(f(v-gap['in_zp'])*gap['in_s'])/gap['out_s'])+gap['out_zp']))+128)%256-128 for v in range(-128,128)]
def quant(v,p):
    q=f(f(f(f(v)*p['in_s'])*p['ws'])/p['out_s']);q=f(q+p['out_zp'])
    return int(max(-128,min(127,q)))
tables=[]
for p in fc:
    thresholds=[]
    for q in range(-127,128):
        lo=-2**31;hi=2**31-1
        while lo<hi:
            mid=(lo+hi)//2
            if quant(mid,p)>=q:hi=mid
            else:lo=mid+1
        assert -2**31+2<lo<2**31-3 and quant(lo,p)>=q and quant(lo-1,p)<q
        thresholds.append(lo)
    tables.append(thresholds)
lines=['#pragma once','/* Model-parameter quantization functions, all inputs supported. */']
def arr(kind,name,values):
    lines.append(f'static const {kind} {name}[{len(values)}]={{')
    for i in range(0,len(values),16):lines.append(','.join(map(str,values[i:i+16]))+',')
    lines.append('};')
arr('int8_t','kws_gap_lut',lut)
for i,t in enumerate(tables):arr('int32_t',f'kws_fc_threshold_{i}',t)
lines.append('static const int32_t *const kws_fc_threshold[3]={kws_fc_threshold_0,kws_fc_threshold_1,kws_fc_threshold_2};')
lines.append('static const uint32_t kws_fc_identity[3][4]={'+','.join('{'+','.join(f'0x{x:08X}U' for x in [bits(p['in_s']),bits(p['ws']),bits(p['out_s']),p['out_zp']&0xffffffff])+'}' for p in fc)+'};')
for k in ['in_s','out_s']:lines.append(f'#define KWS_GAP_{k.upper()} 0x{bits(gap[k]):08X}U')
(H/'source/kws_math_tables.h').write_text('\n'.join(lines)+'\n')
code=r'''#include "kws_math_tables.h"
TM_INLINE uint32_t kws_bits(float f){union{float f;uint32_t u;}v={f};return v.u;}
TM_INLINE int8_t kws_fc_quant(int32_t sum,unsigned id){
 const int32_t *table=kws_fc_threshold[id];unsigned lo=0,hi=255;
 while(lo<hi){unsigned m=(lo+hi)>>1;if(sum>=table[m])lo=m+1;else hi=m;}
 return (int8_t)((int)lo-128);
}
static int kws_fc_identity_match(float is,float ws,float os,int oz){
 for(unsigned i=0;i<3;++i)if(kws_bits(is)==kws_fc_identity[i][0]&&kws_bits(ws)==kws_fc_identity[i][1]&&kws_bits(os)==kws_fc_identity[i][2]&&(uint32_t)oz==kws_fc_identity[i][3])return (int)i;
 return -1;
}
tm_err_t tml_gap_fast(tm_mat_t*in,tm_mat_t*out,sctype_t is,zptype_t iz,sctype_t os,zptype_t oz){
 if(in->h!=4||in->w!=3||in->c!=32||out->c!=32||iz!=-128||oz!=-128||kws_bits(is)!=KWS_GAP_IN_S||kws_bits(os)!=KWS_GAP_OUT_S)return tml_gap(in,out,is,iz,os,oz);
 for(unsigned c=0;c<32;++c){int sum=0;for(unsigned p=0;p<12;++p)sum+=in->data[p*32+c];out->data[c]=kws_gap_lut[sum/12+128];}
 return TM_OK;
}
int kws_math_selftest(void){
 union{uint32_t u;float f;}is={KWS_GAP_IN_S},os={KWS_GAP_OUT_S};
 for(int a=-128;a<128;++a)if((int8_t)((a+128)*is.f/os.f-128)!=kws_gap_lut[a+128])return 1;
 for(unsigned id=0;id<3;++id){
  union{uint32_t u;float f;}fi={kws_fc_identity[id][0]},fw={kws_fc_identity[id][1]},fo={kws_fc_identity[id][2]};int oz=(int32_t)kws_fc_identity[id][3];
  for(unsigned i=0;i<255;++i)for(int j=-2;j<=2;++j){
   int32_t a=kws_fc_threshold[id][i]+j;float q=a*fi.f*fw.f/fo.f+oz;
   if(q>127)q=127;if(q< -128)q=-128;if((int8_t)q!=kws_fc_quant(a,id))return 2+id;
  }
  uint32_t rng=0x20261030U+id;
  for(unsigned i=0;i<1024;++i){rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;
   int32_t a=(int32_t)rng;float q=a*fi.f*fw.f/fo.f+oz;
   if(q>127)q=127;if(q< -128)q=-128;if((int8_t)q!=kws_fc_quant(a,id))return 5+id;
  }
 }
 return 0;
}
'''
(H/'source/kws_math_fast.inc').write_text(code)
p=H/'source/tm_layers.c';s=p.read_text();old='/*************************** TML_FC **********************************/'
assert old in s;s=s.replace(old,'#include "kws_math_fast.inc"\n\n'+old)
idx=s.index('tm_err_t TM_WEAK tml_fc_npu(');left,right=s[:idx],s[idx:]
old='''float quantized = sum*in_s*ws[0]/out_s + out_zp;
        if (quantized > 127.0f) quantized = 127.0f;
        if (quantized < -128.0f) quantized = -128.0f;
        out->data[c] = (mtype_t)quantized;'''
new='''int id=kws_fc_identity_match(in_s,ws[0],out_s,out_zp);
        if(id>=0)out->data[c]=kws_fc_quant(sum,(unsigned)id);
        else {
         float quantized=sum*in_s*ws[0]/out_s+out_zp;
         if(quantized>127)quantized=127;if(quantized< -128)quantized=-128;
         out->data[c]=(mtype_t)quantized;
        }'''
assert old in right;p.write_text(left+right.replace(old,new))
p=H/'source/tm_model.c';s=p.read_text();s=s.replace('#include "tiny_npu.h"','#include "tiny_npu.h"\nextern tm_err_t tml_gap_fast(tm_mat_t*,tm_mat_t*,sctype_t,zptype_t,sctype_t,zptype_t);')
old='res = tml_gap(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);'
assert old in s;s=s.replace(old,'#if NPU_PLATFORM == 0\n            '+old+'\n#else\n            res = tml_gap_fast(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);\n#endif');p.write_text(s)
p=H/'main.c';s=p.read_text();s=s.replace('extern uint32_t edge_hw_windows;','extern uint32_t edge_hw_windows;\nextern int kws_math_selftest(void);');s=s.replace('input_case=0;extended=0;return 0;','input_case=0;extended=0;if(kws_math_selftest())return 340;return 0;')
s=s.replace('demo_summary(rc);put("END ");','if(!rc)put("T MATH GAP_VALUES 00000100 FC_BOUNDARIES 00000EF1 FC_RANDOM 00000C00\\r\\n");\n demo_summary(rc);put("END ");');p.write_text(s)
p=H/'demo_capture.py';s=p.read_text(encoding='utf-8');s=s.replace("assert 'DEMO VALIDATION PASS", "assert 'T MATH GAP_VALUES 00000100 FC_BOUNDARIES 00000EF1 FC_RANDOM 00000C00\\n'in text,'math validation missing'\n assert 'DEMO VALIDATION PASS");p.write_text(s,encoding='utf-8')
receipt=dict(model_sha256=hashlib.sha256(a).hexdigest(),table_bytes=256+3*255*4+3*4*4,gap_values=256,fc_boundary_cases=3*255*5,fc_random_cases=3072,scope='MODEL_PARAMETER_FUNCTIONS_NO_INPUT_PREDICTION_CACHE')
(H/'math_tables.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt,indent=2))
