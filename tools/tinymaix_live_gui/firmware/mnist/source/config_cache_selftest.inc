/* Untimed prepare-only tests. Compare the cached path with a forced complete
 * preflight and encoder for each changed parameter, bounds/error and epoch. */
static uint64_t config_program_fingerprint(void){
 uint64_t h=npu_hash_bytes(0,prepared.cpu,(prepared.words-1U)*8U);
 const uint32_t *tail=(const uint32_t*)(prepared.cpu+(prepared.words-1U)*8U);
 uint32_t last[2]={tail[0],tail[1]&0x00FFFFFFU};return npu_hash_bytes(h,last,sizeof(last));
}
int mnist_config_cache_selftest(void){
 uint32_t bias[16],scale[16],output[16],header[12]={0};unsigned cases=0;
 const unsigned channels[3]={1,4,16};
 for(unsigned group=0;group<3;++group)for(unsigned variant=0;variant<24;++variant){
  unsigned c=channels[group];
  for(unsigned i=0;i<16;++i){bias[i]=i*31;scale[i]=20000+i;output[i]=EDGE_NPU_SCRATCH_BASE+0x2000+i*64;}
  edge_npu_runtime.inflight=0;edge_npu_runtime.faulted=0;edge_ppu_outscale=12000;
  npu_set_layer(0,header,sizeof(header));mac_config_reset();
  uint8_t tag;uint32_t words;
  int rc=npu_mac_engine(0,EDGE_NPU_SCRATCH_BASE,EDGE_NPU_SCRATCH_BASE+0x1000,bias,1,scale,1,7,-128,output,8,8,8,c,&tag,&words);
  if(rc)return 1;
  uint32_t a=EDGE_NPU_SCRATCH_BASE,w=a+0x1000,k=8,n=8,an=8,cn=c,rs=1,act=1,type=7;int zp=-128;
  switch(variant){
   case 1:a+=8;break;case 2:w+=8;break;case 3:bias[0]^=1;break;
   case 4:++scale[0];break;case 5:output[0]+=8;break;
   case 6:act=0;break;case 7:type=0;break;case 8:zp=-127;break;
   case 9:k=16;break;case 10:n=an=16;break;case 11:rs=0;break;
   case 12:edge_ppu_outscale=12001;break;
   case 13:a=EDGE_NPU_SCRATCH_BASE-8;break;
   case 14:w=EDGE_NPU_SCRATCH_BASE+EDGE_NPU_SCRATCH_BYTES;break;
   case 15:++output[0];break;case 16:output[0]=a;break;
   case 17:scale[0]=1U<<17;break;case 18:cn=0;break;
   case 19:type=8;break;case 20:an=7;break;
   case 21:edge_npu_runtime.inflight=1;break;
   case 22:edge_npu_runtime.faulted=1;break;
   case 23:if(npu_cache_invalidate(&edge_npu_runtime))return 2;break;
  }
  int cached=npu_mac_engine(0,a,w,bias,rs,scale,act,type,zp,output,k,n,an,cn,&tag,&words);
  uint64_t hash=cached==NPU_OK?config_program_fingerprint():0;uint32_t count=words;
  mac_config_reset();
  int complete=npu_mac_engine(0,a,w,bias,rs,scale,act,type,zp,output,k,n,an,cn,&tag,&words);
  if(cached!=complete||count!=words||(cached==NPU_OK&&hash!=config_program_fingerprint()))return 100+cases;
  if(variant>=13&&variant<=22&&cached==NPU_OK)return 200+cases;
  ++cases;
 }
 edge_npu_runtime.inflight=0;edge_npu_runtime.faulted=0;prepared_valid=0;
 if(npu_cache_invalidate(&edge_npu_runtime))return 3;
 return cases==72?0:4;
}
