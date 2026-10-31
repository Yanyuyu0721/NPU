/* Untimed comparison against a scalar byte oracle, including fallback lanes,
 * tails, unaligned destinations and both plane-address forms. */
int kws_ppu_copy_selftest(void){
 static const unsigned sizes[6]={1,3,4,8,12,16},channels[6]={1,3,4,8,16,32};
 uint8_t output[516] __attribute__((aligned(4))),expected[516];
 int32_t denominator[32];uint32_t offsets[32];unsigned cases=0;
 for(unsigned a=0;a<6;++a)for(unsigned b=0;b<6;++b)for(unsigned pattern=0;pattern<3;++pattern)for(unsigned address=0;address<2;++address)for(unsigned unaligned=0;unaligned<2;++unaligned){
  unsigned n=sizes[a],c=channels[b];
  for(unsigned i=0;i<sizeof(output);++i)output[i]=expected[i]=(uint8_t)(i*29+pattern*37+a);
  for(unsigned j=0;j<c;++j){
   denominator[j]=pattern==0?3000:pattern==1?1000:(j%3?3000:1000);offsets[j]=j*64;
   uint8_t *source=CPU_SHARED_MEM(offsets[j]);
   for(unsigned i=0;i<64;++i)source[i]=(uint8_t)(i*53+j*71+a*17+b*31+pattern);
   if(denominator[j]>=2049)for(unsigned i=0;i<n;++i)expected[unaligned+i*c+j]=source[i];
  }
  kws_ppu_copy_planes((mtype_t*)(output+unaligned),n,c,address?offsets:0,0,64,denominator);
  if(memcmp(output,expected,sizeof(output)))return 1+cases;
  ++cases;
 }
 return cases==432?0:1000;
}
