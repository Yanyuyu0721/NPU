tm_err_t tml_softmax(tm_mat_t*,tm_mat_t*,sctype_t,zptype_t,sctype_t,zptype_t);
#include "mnist_math_tables.h"
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
