/* Vertical depthwise convolution, unchanged TinyMaix INT32/quantization contract.
 * Pack four window bytes per aligned CPU store. Pad K to 8/16 with zero weights.
 * All channel inputs and outputs remain live until the single batch completes. */
static uint8_t dw_padding_row[512];
static tm_err_t tml_dw_vertical_batch(tm_mat_t *in,tm_mat_t *out,wtype_t *w,btype_t *b,
 int kh,int act,int pad_top,sctype_t *ws,sctype_t in_s,zptype_t in_zp,sctype_t out_s,zptype_t out_zp){
 if(!edge_npu_runtime.ready||edge_npu_runtime.faulted)return TM_ERR;
 unsigned channels=out->c,n=out->h*out->w,k=(kh+3U)&~3U;
 if(act!=TM_ACT_RELU)return TM_ERR_UNSUPPORT;
 if(in->c!=channels||channels>TM_MAX_CSIZE||(kh!=7&&kh!=15)||in->w*in->c>sizeof(dw_padding_row)||out->w!=in->w)return TM_ERR_UNSUPPORT;
 uint32_t ws_stride=64,as_stride=TM_ALIGN8(n*k),os_stride=TM_ALIGN8(n*4);
 uint32_t wo=0,ao=TM_ALIGN8(channels*ws_stride),oo=TM_ALIGN8(ao+channels*as_stride);
 if(oo+channels*os_stride>EDGE_NPU_SCRATCH_BYTES)return TM_ERR_OOM;
 int8_t *weights=CPU_SHARED_MEM(wo);uint8_t *activation=CPU_SHARED_MEM(ao);
 int32_t outscale=npu_quant_prepare(channels,ws,in_s,out_s);
 if(outscale<=0||outscale>65535)return TM_ERR_UNSUPPORT;
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_start_time=pref_time;
 memset(dw_padding_row,(uint8_t)in_zp,sizeof(dw_padding_row));
 for(unsigned c=0;c<channels;++c){
  memset(weights+c*ws_stride,0,k);memcpy(weights+c*ws_stride,w+c*kh,kh);
 }

 /* Keep overlapping taps in CPU registers, instead of loading each prior
  * window back from uncached NPU scratch. All input bytes remain live data. */
 const uint8_t *row[16],*incoming[64];
 if(out->h>64)return TM_ERR_UNSUPPORT;
 for(unsigned j=0;j<k;++j){int iy=(int)j-pad_top;row[j]=j<(unsigned)kh&&iy>=0&&iy<in->h?(const uint8_t*)in->data+iy*in->w*channels:dw_padding_row;}
 for(unsigned y=0;y<out->h;++y){int iy=(int)y-pad_top+kh;incoming[y]=iy>=0&&iy<in->h?(const uint8_t*)in->data+iy*in->w*channels:dw_padding_row;}
 for(unsigned c=0;c<channels;++c)for(unsigned x=0;x<out->w;++x){
  unsigned ix=x*channels+c;
  uint32_t a=(uint32_t)row[0][ix]|((uint32_t)row[1][ix]<<8)|((uint32_t)row[2][ix]<<16)|((uint32_t)row[3][ix]<<24);
  uint32_t b=(uint32_t)row[4][ix]|((uint32_t)row[5][ix]<<8)|((uint32_t)row[6][ix]<<16)|((uint32_t)row[7][ix]<<24);
  uint32_t *dst=(uint32_t*)(activation+c*as_stride+x*k);
  unsigned stride=out->w*k/4;
  if(k==16){
   uint32_t d=(uint32_t)row[8][ix]|((uint32_t)row[9][ix]<<8)|((uint32_t)row[10][ix]<<16)|((uint32_t)row[11][ix]<<24);
   uint32_t e=(uint32_t)row[12][ix]|((uint32_t)row[13][ix]<<8)|((uint32_t)row[14][ix]<<16)|((uint32_t)row[15][ix]<<24);
   for(unsigned y=0;y<out->h;++y){
    dst[0]=a;dst[1]=b;dst[2]=d;dst[3]=e;dst+=stride;
    uint32_t next=incoming[y][ix];
    a=(a>>8)|(b<<24);b=(b>>8)|(d<<24);d=(d>>8)|(e<<24);
    e=((e>>8)&65535U)|(next<<16)|((uint32_t)(uint8_t)in_zp<<24);
   }
  }else{
   for(unsigned y=0;y<out->h;++y){
    dst[0]=a;dst[1]=b;dst+=stride;
    uint32_t next=incoming[y][ix];a=(a>>8)|(b<<24);
    b=((b>>8)&65535U)|(next<<16)|((uint32_t)(uint8_t)in_zp<<24);
   }
  }
 }
 extern int npu_dw_batch_prepare(uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,const int32_t*,const uint32_t*,uint32_t,int32_t);

 int rc=npu_dw_batch_prepare(NPU_SHARED_MEM(ao),NPU_SHARED_MEM(wo),NPU_SHARED_MEM(oo),as_stride,ws_stride,os_stride,k,n,channels,b,(const uint32_t*)sumscale,(uint32_t)outscale,out_zp);
 if(rc!=NPU_OK)return TM_ERR;
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_end_time=pref_time;
 
 if(npu_submit_prepared(2000000ULL)!=NPU_OK)return TM_ERR;
 uint64_t post_start;TM_GET_TICK(post_start);
 for(unsigned c=0;c<channels;++c){
  uint32_t d=(uint32_t)sumscale[c];
  if(d>=2049&&d<=65535){
   ++edge_ppu_channels;
  }else tm_postprocess_sum_npu(c,channels,n,CPU_SHARED_MEM(oo+c*os_stride),b+c,act,out->data,sumscale+c,outscale,out_zp);
 }
 kws_ppu_copy_planes(out->data,n,channels,0,oo,os_stride,sumscale);
 ++edge_ppu_layers;
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_end_time+=pref_time-post_start;

 return TM_OK;
}
