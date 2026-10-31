/* Vertical depthwise convolution, unchanged TinyMaix INT32/quantization contract.
 * Pack four window bytes per aligned CPU store. Pad K to 8/16 with zero weights.
 * All channel inputs and outputs remain live until the single batch completes. */
static uint8_t dw_padding_row[512];
static tm_err_t tml_dw_vertical_batch(tm_mat_t *in,tm_mat_t *out,wtype_t *w,btype_t *b,
 int kh,int act,int pad_top,sctype_t *ws,sctype_t in_s,zptype_t in_zp,sctype_t out_s,zptype_t out_zp){
 if(!edge_npu_runtime.ready||edge_npu_runtime.faulted)return TM_ERR;
 unsigned channels=out->c,n=out->h*out->w,k=(kh+3U)&~3U;
 if(in->c!=channels||channels>TM_MAX_CSIZE||(kh!=7&&kh!=15)||in->w*in->c>sizeof(dw_padding_row)||out->w!=in->w)return TM_ERR_UNSUPPORT;
 uint32_t ws_stride=64,as_stride=TM_ALIGN8(n*k),os_stride=TM_ALIGN8(n*4);
 uint32_t wo=0,ao=TM_ALIGN8(channels*ws_stride),oo=TM_ALIGN8(ao+channels*as_stride);
 if(oo+channels*os_stride>EDGE_NPU_SCRATCH_BYTES)return TM_ERR_OOM;
 int8_t *weights=CPU_SHARED_MEM(wo);uint8_t *activation=CPU_SHARED_MEM(ao);
 int32_t outscale=npu_quant_prepare(channels,ws,in_s,out_s);
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_start_time=pref_time;
 memset(dw_padding_row,(uint8_t)in_zp,sizeof(dw_padding_row));
 for(unsigned c=0;c<channels;++c){
  memset(weights+c*ws_stride,0,k);memcpy(weights+c*ws_stride,w+c*kh,kh);
 }
 uint64_t pack_start;TM_GET_TICK(pack_start);
 const uint8_t *row[16];
 for(unsigned j=0;j<k;++j){int iy=(int)j-pad_top;row[j]=j<(unsigned)kh&&iy>=0&&iy<in->h?(const uint8_t*)in->data+iy*in->w*in->c:dw_padding_row;}
 for(unsigned c=0;c<channels;++c){
  for(unsigned j=0;j<k;j+=4){
   const uint8_t *p0=row[j]+c,*p1=row[j+1]+c,*p2=row[j+2]+c,*p3=row[j+3]+c;
   uint32_t *dst=(uint32_t*)(activation+c*as_stride+j);
   for(unsigned x=0;x<out->w;++x){
    *dst=(uint32_t)*p0|((uint32_t)*p1<<8)|((uint32_t)*p2<<16)|((uint32_t)*p3<<24);
    p0+=channels;p1+=channels;p2+=channels;p3+=channels;dst+=k/4;
   }
  }
  /* Adjacent vertical windows overlap kh-1 taps. Reuse packed INT32 words
   * and read only the new row's sample; no approximation or sample shortcut. */
  for(unsigned y=1;y<out->h;++y){
   int iy=(int)y-pad_top+kh-1;
   const uint8_t *last=(iy>=0&&iy<in->h)?(const uint8_t*)in->data+iy*in->w*channels:dw_padding_row;
   last+=c;
   const uint32_t *src=(const uint32_t*)(activation+c*as_stride+(y-1)*out->w*k);
   uint32_t *dst=(uint32_t*)(activation+c*as_stride+y*out->w*k);
   if(k==16){
    for(unsigned x=0;x<out->w;++x){
     uint32_t a=src[0],b=src[1],d=src[2],e=src[3];
     dst[0]=(a>>8)|(b<<24);dst[1]=(b>>8)|(d<<24);dst[2]=(d>>8)|(e<<24);
     dst[3]=((e>>8)&65535U)|((uint32_t)*last<<16)|((uint32_t)(uint8_t)in_zp<<24);
     src+=4;dst+=4;last+=channels;
    }
   }else{
    for(unsigned x=0;x<out->w;++x){
     uint32_t a=src[0],b=src[1];dst[0]=(a>>8)|(b<<24);
     dst[1]=((b>>8)&65535U)|((uint32_t)*last<<16)|((uint32_t)(uint8_t)in_zp<<24);
     src+=2;dst+=2;last+=channels;
    }
   }
  }
 }
 extern int npu_dw_batch_prepare(uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,const int32_t*);
 uint64_t pack_end;TM_GET_TICK(pack_end);
 int rc=npu_dw_batch_prepare(NPU_SHARED_MEM(ao),NPU_SHARED_MEM(wo),NPU_SHARED_MEM(oo),as_stride,ws_stride,os_stride,k,n,channels,b);
 if(rc!=NPU_OK)return TM_ERR;
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_end_time=pref_time;
 if(npu_submit_prepared(2000000ULL)!=NPU_OK)return TM_ERR;
 uint64_t post_start;TM_GET_TICK(post_start);
 for(unsigned c=0;c<channels;++c)
  tm_postprocess_sum_npu(c,channels,n,CPU_SHARED_MEM(oo+c*os_stride),b+c,act,out->data,sumscale+c,outscale,out_zp);
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_end_time+=pref_time-post_start;
 return TM_OK;
}
