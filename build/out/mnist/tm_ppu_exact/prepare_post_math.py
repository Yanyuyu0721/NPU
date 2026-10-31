"""Generate exact quantization/exp function tables; no prediction/input caching."""
from pathlib import Path
import hashlib,json,struct
H=Path(__file__).resolve().parent;OUT=H/'post_candidate';OUT.mkdir(exist_ok=False)
c=json.loads((H/'model_contract.json').read_text(encoding='utf-8'));t=json.loads((H/'post_table_analysis.json').read_text())
f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
bits=lambda x:struct.unpack('<I',struct.pack('<f',x))[0]
gap=c['layers'][3];fc=c['layers'][4];soft=c['layers'][5]
gap_lut=[(int(f(f(f(f(a-gap['input_zero_point'])*gap['input_scale'])/gap['output_scale'])+f(gap['output_zero_point'])))+128)%256-128 for a in range(-128,128)]
def fc_q(acc):
 value=f(f(f(f(acc)*fc['input_scale'])*fc['weight_scales'][0])/fc['output_scale']);value=f(value+f(fc['output_zero_point']))
 return int(max(-128,min(127,value)))
threshold=[]
for q in range(-127,128):
 lo=-2**31;hi=2**31-1
 while lo<hi:
  mid=(lo+hi)//2
  if fc_q(mid)>=q:hi=mid
  else:lo=mid+1
 assert fc_q(lo)>=q and fc_q(lo-1)<q
 threshold.append(lo)
packed=[]
for i in range(0,len(t['deltas']),2):
 a=t['deltas'][i]+2;b=t['deltas'][i+1]+2 if i+1<len(t['deltas'])else 0
 assert 0<=a<=4 and 0<=b<=4;packed.append(a|(b<<4))
lines=['#pragma once','/* Derived only from frozen model parameters; all INT8 exp argument pairs. */']
def arr(kind,name,data,formatter=str):
 lines.append(f'static const {kind} {name}[{len(data)}]={{')
 for i in range(0,len(data),16):lines.append(','.join(formatter(v)for v in data[i:i+16])+',')
 lines.append('};')
arr('int8_t','mnist_gap_lut',gap_lut);arr('int32_t','mnist_fc_threshold',threshold)
arr('uint32_t','mnist_exp_base',t['base_bits'],lambda v:f'0x{v:08X}U');arr('uint8_t','mnist_exp_delta',packed,lambda v:f'0x{v:02X}')
for name,value in [('GAP_IN',gap['input_scale']),('GAP_OUT',gap['output_scale']),('FC_IN',fc['input_scale']),('FC_WS',fc['weight_scales'][0]),('FC_OUT',fc['output_scale']),('SM_IN',soft['input_scale']),('SM_OUT',soft['output_scale'])]:lines.append(f'#define MNIST_{name}_BITS 0x{bits(value):08X}U')
(OUT/'mnist_math_tables.h').write_text('\n'.join(lines)+'\n')
code=r'''#include "mnist_math_tables.h"
TM_INLINE uint32_t mnist_bits(float x){union{float f;uint32_t u;}v={x};return v.u;}
TM_INLINE int8_t mnist_fc_quant(int32_t sum){
 unsigned lo=0,hi=255;while(lo<hi){unsigned mid=(lo+hi)>>1;if(sum>=mnist_fc_threshold[mid])lo=mid+1;else hi=mid;}
 return (int8_t)((int)lo-128);
}
TM_INLINE float mnist_exp_exact(unsigned value,unsigned maximum){
 unsigned i=(maximum*(maximum+1U)>>1)+value;
 int correction=((mnist_exp_delta[i>>1]>>((i&1U)*4))&15)-2;
 union{uint32_t u;float f;}v;v.u=mnist_exp_base[maximum-value]+correction*64;return v.f;
}
tm_err_t tml_gap_fast(tm_mat_t*in,tm_mat_t*out,sctype_t is,zptype_t iz,sctype_t os,zptype_t oz){
 if(in->h!=2||in->w!=2||in->c!=16||out->c!=16||iz!=-128||oz!=-128||mnist_bits(is)!=MNIST_GAP_IN_BITS||mnist_bits(os)!=MNIST_GAP_OUT_BITS)return tml_gap(in,out,is,iz,os,oz);
 for(unsigned c=0;c<16;++c){int sum=in->data[c]+in->data[16+c]+in->data[32+c]+in->data[48+c];out->data[c]=mnist_gap_lut[sum/4+128];}
 return TM_OK;
}
tm_err_t tml_softmax_fast(tm_mat_t*in,tm_mat_t*out,sctype_t is,zptype_t iz,sctype_t os,zptype_t oz){
 if(in->c!=10||iz!=42||oz!=-128||mnist_bits(is)!=MNIST_SM_IN_BITS||mnist_bits(os)!=MNIST_SM_OUT_BITS)return tml_softmax(in,out,is,iz,os,oz);
 unsigned maximum=0;for(unsigned c=0;c<10;++c){unsigned v=(int)in->data[c]+128;if(v>maximum)maximum=v;}
 float*data=(float*)out->data;float sum=0;
 for(unsigned c=0;c<10;++c){float v=mnist_exp_exact((int)in->data[c]+128,maximum);sum+=v;data[c]=v-0.000001f;}
 for(unsigned c=0;c<10;++c){
  union{float f;uint32_t u;}v;v.f=data[c]/sum;unsigned e=(v.u>>23)&255;
  if(e>0&&e<247)v.u+=8U<<23;else v.f*=256.0f;
  out->data[c]=(mtype_t)(v.f+(float)oz);
 }
 return TM_OK;
}
int mnist_math_selftest(void){
 union{uint32_t u;float f;}is={MNIST_SM_IN_BITS};
 for(int m=0;m<256;++m)for(int v=0;v<=m;++v){
  float a=(float)(v-128-42)*is.f,b=(float)(m-128-42)*is.f;
  if(mnist_bits(tm_exp(a-b))!=mnist_bits(mnist_exp_exact(v,m)))return 1;
 }
 union{uint32_t u;float f;}gi={MNIST_GAP_IN_BITS},go={MNIST_GAP_OUT_BITS};
 for(int a=-128;a<128;++a)if((int8_t)((a+128)*gi.f/go.f-128)!=mnist_gap_lut[a+128])return 2;
 union{uint32_t u;float f;}fi={MNIST_FC_IN_BITS},fw={MNIST_FC_WS_BITS},fo={MNIST_FC_OUT_BITS};
 for(unsigned i=0;i<255;++i)for(int j=-2;j<=2;++j){
  int32_t a=mnist_fc_threshold[i]+j;float q=a*fi.f*fw.f/fo.f+42;
  if(q>127)q=127;if(q< -128)q=-128;if((int8_t)q!=mnist_fc_quant(a))return 3;
 }
 uint32_t rng=0x20261029;
 for(unsigned i=0;i<1024;++i){rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;
  int32_t a=(int32_t)rng;float q=a*fi.f*fw.f/fo.f+42;
  if(q>127)q=127;if(q< -128)q=-128;if((int8_t)q!=mnist_fc_quant(a))return 4;
 }
 return 0;
}
'''
# Forward declarations keep original CPU implementations intact below.
forward='tm_err_t tml_softmax(tm_mat_t*,tm_mat_t*,sctype_t,zptype_t,sctype_t,zptype_t);\n'
(OUT/'mnist_math_fast.inc').write_text(forward+code)
receipt=dict(scope='MODEL_PARAMETER_FUNCTION_TABLES_NOT_INPUT_OUTPUT_MEMOIZATION',model_sha256=c['model_binary_sha256'],gap_entries=256,fc_thresholds=255,softmax_pairs=len(t['deltas']),packed_delta_bytes=len(packed),delta_range=[min(t['deltas']),max(t['deltas'])],table_bytes=256+255*4+256*4+len(packed),header_sha256=hashlib.sha256((OUT/'mnist_math_tables.h').read_bytes()).hexdigest())
(OUT/'result.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt,indent=2))
