/* Transpose four packed INT8 channel planes using aligned 32-bit transfers.
 * Unsupported exact-PPU channels are already quantized into the destination;
 * preserve their byte lanes rather than interpreting their INT32 scratch data. */
static void kws_ppu_copy_planes(mtype_t *out,unsigned n,unsigned channels,
 const uint32_t *offset,unsigned base,unsigned stride,const int32_t *denominator){
 if((channels&3U)||((uintptr_t)out&3U)){
  for(unsigned c=0;c<channels;++c){
   if(denominator&&(denominator[c]<2049||denominator[c]>65535))continue;
   const int8_t *s=CPU_SHARED_MEM(offset?offset[c]:base+c*stride);
   for(unsigned i=0;i<n;++i)out[i*channels+c]=s[i];
  }return;
 }
 for(unsigned c=0;c<channels;c+=4){
  uint32_t mask=0;
  for(unsigned j=0;j<4;++j)if(!denominator||(denominator[c+j]>=2049&&denominator[c+j]<=65535))mask|=255U<<(j*8);
  if(!mask)continue;
  const uint32_t *a=CPU_SHARED_MEM(offset?offset[c]:base+c*stride);
  const uint32_t *b=CPU_SHARED_MEM(offset?offset[c+1]:base+(c+1)*stride);
  const uint32_t *d=CPU_SHARED_MEM(offset?offset[c+2]:base+(c+2)*stride);
  const uint32_t *e=CPU_SHARED_MEM(offset?offset[c+3]:base+(c+3)*stride);
  uint32_t *dst=(uint32_t*)(out+c);unsigned step=channels/4;
  for(unsigned i=0;i<n/4;++i){
   uint32_t av=a[i],bv=b[i],dv=d[i],ev=e[i];
   uint32_t t0=(av&0x00FF00FFU)|((bv&0x00FF00FFU)<<8);
   uint32_t t1=((av>>8)&0x00FF00FFU)|(bv&0xFF00FF00U);
   uint32_t t2=(dv&0x00FF00FFU)|((ev&0x00FF00FFU)<<8);
   uint32_t t3=((dv>>8)&0x00FF00FFU)|(ev&0xFF00FF00U);
   uint32_t v0=(t0&65535U)|(t2<<16),v1=(t1&65535U)|(t3<<16);
   uint32_t v2=(t0>>16)|(t2&0xFFFF0000U),v3=(t1>>16)|(t3&0xFFFF0000U);
   if(mask==UINT32_MAX){dst[0]=v0;dst[step]=v1;dst[step*2]=v2;dst[step*3]=v3;}
   else{
    dst[0]=(dst[0]&~mask)|(v0&mask);dst[step]=(dst[step]&~mask)|(v1&mask);
    dst[step*2]=(dst[step*2]&~mask)|(v2&mask);dst[step*3]=(dst[step*3]&~mask)|(v3&mask);
   }
   dst+=step*4;
  }
  for(unsigned i=n&~3U;i<n;++i)for(unsigned j=0;j<4;++j)if(mask&(255U<<(j*8))){
   const int8_t *src=CPU_SHARED_MEM(offset?offset[c+j]:base+(c+j)*stride);
   out[i*channels+c+j]=src[i];
  }
 }
}
