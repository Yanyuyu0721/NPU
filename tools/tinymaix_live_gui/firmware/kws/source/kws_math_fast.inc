#include "kws_math_tables.h"
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
