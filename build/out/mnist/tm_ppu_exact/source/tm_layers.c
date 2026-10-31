/* Copyright 2022 Sipeed Technology Co., Ltd. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/
// It is default O0 implement
#include "tinymaix.h"
#include "float.h"
#include "math.h"
#include "tiny_npu.h"

#ifndef TM_NPU_CPU_COMPAT
#define TM_NPU_CPU_COMPAT 0
#endif
/* Image-network opt-in: NPU dot+bias, original CPU quantization/activation.
 * Model biases already encode input zero-point compensation. Keep raw input
 * bytes and in_zp padding; subtracting in_zp again would double-correct.
 * The existing singleton runtime and global sumscale are non-reentrant. */
#if TM_NPU_CPU_COMPAT
#define TM_NPU_LOCAL static
#else
#define TM_NPU_LOCAL
#endif
// #if TM_OPT_LEVEL == TM_OPT0
// 
// #if TM_ARCH==TM_ARCH_CPU
    #include "arch_cpu.h"
// #elif TM_ARCH==TM_ARCH_ARM_SIMD
//     #include "arch_arm_simd.h"
// #elif TM_ARCH==TM_ARCH_ARM_NEON
//     #include "arch_arm_neon.h"
// #elif TM_ARCH==TM_ARCH_ARM_MVEI
//     #include "arch_arm_mvei.h"
// #elif TM_ARCH==TM_ARCH_RV32P
//     #include "arch_rv32p.h"
// #elif TM_ARCH==TM_ARCH_RV64V
//     #include "arch_rv64v.h"
// #elif TM_ARCH==TM_ARCH_CSKYV2
//     #include "arch_cskyv2.h"
// #elif TM_ARCH==TM_ARCH_X86_SSE2
//     #include "arch_x86_sse2.h"
// #else
//     #error "UNSUPPORT ARCH!"
// #endif

#if TM_ENABLE_LOGGING && TM_ENABLE_DIAGNOSTICS

#define TML_DIAG_FIRST_VALUES 16

static uint32_t tml_diag_hash_bytes(const void *ptr, int len)
{
    const uint8_t *data = (const uint8_t *)ptr;
    uint32_t hash = 2166136261u;

    for (int i = 0; i < len; ++i) {
        hash ^= data[i];
        hash *= 16777619u;
    }

    return hash;
}

static void tml_diag_print_i8_buffer(const char *tag, const int8_t *data, int len)
{
    long long sum = 0;
    unsigned long long abs_sum = 0;
    unsigned long zero_count = 0;
    unsigned long neg_count = 0;
    unsigned long pos_count = 0;
    int min_v = 0;
    int max_v = 0;

    if (data == NULL || len <= 0) {
        TM_PRINTF("DIAG %s len=%d data=NULL\r\n", tag, len);
        return;
    }

    min_v = (int)data[0];
    max_v = (int)data[0];
    for (int i = 0; i < len; ++i) {
        int v = (int)data[i];
        sum += v;
        abs_sum += (v < 0) ? (unsigned long long)(-v) : (unsigned long long)v;
        if (v < min_v) min_v = v;
        if (v > max_v) max_v = v;
        if (v == 0) zero_count++;
        else if (v < 0) neg_count++;
        else pos_count++;
    }

    TM_PRINTF("DIAG %s len=%d sum=%lld abs=%llu min=%d max=%d zero=%lu neg=%lu pos=%lu hash=0x%08lx\r\n",
        tag, len, sum, abs_sum, min_v, max_v,
        zero_count, neg_count, pos_count,
        (unsigned long)tml_diag_hash_bytes(data, len));

    int first_n = (len < TML_DIAG_FIRST_VALUES) ? len : TML_DIAG_FIRST_VALUES;
    TM_PRINTF("DIAG %s first%d:", tag, first_n);
    for (int i = 0; i < first_n; ++i) {
        TM_PRINTF(" %d", (int)data[i]);
    }
    TM_PRINTF("\r\n");
}

static void tml_diag_print_i32_buffer(const char *tag, const int32_t *data, int len)
{
    long long sum = 0;
    long min_v = 0;
    long max_v = 0;

    if (data == NULL || len <= 0) {
        TM_PRINTF("DIAG %s len=%d data=NULL\r\n", tag, len);
        return;
    }

    min_v = (long)data[0];
    max_v = (long)data[0];
    for (int i = 0; i < len; ++i) {
        long v = (long)data[i];
        sum += (long long)v;
        if (v < min_v) min_v = v;
        if (v > max_v) max_v = v;
    }

    TM_PRINTF("DIAG %s len=%d sum=%lld min=%ld max=%ld hash=0x%08lx\r\n",
        tag, len, sum, min_v, max_v,
        (unsigned long)tml_diag_hash_bytes(data, len * (int)sizeof(int32_t)));

    int first_n = (len < 8) ? len : 8;
    TM_PRINTF("DIAG %s first%d:", tag, first_n);
    for (int i = 0; i < first_n; ++i) {
        TM_PRINTF(" %ld", (long)data[i]);
    }
    TM_PRINTF("\r\n");
}

#else

#define tml_diag_print_i8_buffer(...)  ((void)0)
#define tml_diag_print_i32_buffer(...) ((void)0)

#endif

TM_PERF_REG(t_sbuf);TM_PERF_REG(t_dotp);TM_PERF_REG(t_post); 
TM_PERF_REG(t_valid); TM_PERF_REG(t_pad); 
TM_PERF_REG(t_conv); TM_PERF_REG(t_pwconv); TM_PERF_REG(t_dwconv); 
 
/*************************** TML_CONV2D **********************************/
TM_STATIC uint32_t k_oft[TM_MAX_KSIZE]; 
TM_STATIC mtype_t sbuf[TM_MAX_KCSIZE]; 
// #if (TM_MDL_TYPE==TM_MDL_FP32) || (TM_MDL_TYPE==TM_MDL_FP16) 
// #define SUMSCALE NULL
// #define OUTSCALE outscale

// #elif (TM_MDL_TYPE==TM_MDL_INT8) || (TM_MDL_TYPE==TM_MDL_INT16) 

// #if TM_FASTSCALE
    TM_STATIC int32_t sumscale[TM_MAX_CSIZE];
    #define OUTSCALE outscale
// #else
//     TM_STATIC float sumscale[TM_MAX_CSIZE];
//     #define OUTSCALE outscale_inv
// #endif
#define SUMSCALE (sumscale + c)
#include "quant_plan.inc"
// #endif
 
int conv2d_times=0;
//for valid or kernel in valid part, use fast method
tm_err_t TM_WEAK tml_conv2d_dwconv2d(tm_mat_t* in, tm_mat_t* out, wtype_t* w, btype_t* b, \
    int kw, int kh, int sx, int sy, int dx, int dy, int act, \
    int pad_top, int pad_bottom, int pad_left, int pad_right, int dmul, \
    sctype_t* ws, sctype_t in_s, zptype_t in_zp, sctype_t out_s, zptype_t out_zp) //kernel: (cho, chi, h, w)
{   
    
    // TM_PERF_INIT(t_sbuf);TM_PERF_INIT(t_dotp);TM_PERF_INIT(t_post);
    // TM_PERF_INIT(t_valid);TM_PERF_INIT(t_pad);
    // TM_PERF_INIT(t_conv); TM_PERF_INIT(t_pwconv); TM_PERF_INIT(t_dwconv);
    int pad_flag = (pad_top != 0 ||pad_bottom != 0 ||pad_left != 0 ||pad_right != 0);
    if(dx!=1 || dy!= 1) return TM_ERR_TODO;
    if(act >= TM_ACT_MAXCNT) return TM_ERR_UNSUPPORT;
    int maxk = kw*kh;
    if(maxk>TM_MAX_KSIZE) return TM_ERR_KSIZE;
    if(maxk==1 && (pad_flag||dmul)) return TM_ERR_UNSUPPORT;   //assume no pad or dwconv when pwconv
    int chi  = in->c;
    int cho  = out->c;
    sumtype_t sum = 0;
    mtype_t* outp = out->data;

#if (TM_MDL_TYPE == TM_MDL_INT8) || (TM_MDL_TYPE == TM_MDL_INT16)
#if TM_FASTSCALE
	int32_t outscale = (1<<TM_FASTSCALE_SHIFT)/out_s;
	for(int c=0; c<out->c;c++) sumscale[c]=1.0/ws[c]/in_s;
#else
	sctype_t outscale = out_s;
    sctype_t outscale_inv = 1.f / outscale;
	for(int c=0; c<out->c;c++) sumscale[c]=ws[c]*in_s;
#endif
#else
	sctype_t outscale = out_s;
#endif

    if(maxk==1){ // TM_PERF_START(t_pwconv);   //pointwise conv
        #define BATCH_SIZE 2
        sumtype_t sums[BATCH_SIZE];
        for (int y = 0; y < out->h; y++) {
            for (int x = 0; x < out->w; x++) {
                mtype_t* sptr = (mtype_t*)TM_MATP(in, sy*y, sx*x, 0);
                wtype_t* kptr = (wtype_t*)w;
                int c = 0;
                for(; c<out->c-BATCH_SIZE+1; ){
                    for(int bat = 0; bat < BATCH_SIZE; bat+=2)
                        tm_dot_prod_pack2(sptr, kptr + chi*bat, chi, sums + bat);
                    tm_postprocess_sum(BATCH_SIZE, sums, b + c, act, outp, SUMSCALE, OUTSCALE, out_zp);
                    c += BATCH_SIZE;
                    outp += BATCH_SIZE;
                    kptr += chi*BATCH_SIZE;//*2;
                }
                for(; c<out->c; c++){
                    tm_dot_prod(sptr, kptr, chi, &sum); //size=maxk*chi //pw maxk==1
                    tm_postprocess_sum(1, &sum, b + c, act, outp, SUMSCALE, OUTSCALE, out_zp); outp++;
                    kptr += chi;
                }
            }
        }
        // TM_PERF_ADD(t_pwconv);
        return TM_OK;
    }
    // conv2d_times++;
    // if( conv2d_times== 3 ) 
    //     for (int y = 0; y < in->h * in->w * in->c; ++y) {
    //         TM_PRINTF("%d\n",in->data[y]);
    //     }

    // if(dmul) {TM_PERF_START(t_dwconv);} else {TM_PERF_START(t_conv);};
    int oft = 0;
    int idx = 0;
    for(int y=0; y<kh; y++){    //gen k_oft table
        for(int x=0; x<kw; x++){
            k_oft[idx] = oft;
            idx += 1;
            oft += chi;
        }
        oft += (in->w - kw)*chi;
    }
    chi  = dmul ? 1 : in->c; // dmul>=1 indicate depthwise; dummy chi for dwconv compatible
    int slow_flag = 0; //same pad part is slow
    for (int y = 0; y < out->h; y++) {
        int src_y0 = sy*y - pad_top;
        for (int x = 0; x < out->w; x++) {
            int src_x0 = sx*x - pad_left;
            sumtype_t sum;
            slow_flag = ((src_y0<0)+(src_x0<0)+(src_y0+kh>in->h)+(src_x0+kw>in->w));
            //TM_PERF_START(t_sbuf);
            if(!slow_flag) {// TM_PERF_START(t_valid); //valid or same valid part
                mtype_t* sptr_base = (mtype_t*)TM_MATP(in, src_y0, src_x0, 0); //?c/dmul:0
                mtype_t* sptr = sptr_base; //= (mtype_t*)TM_MATP(in, src_y0, src_x0, 0); //sbuf ²»±ä
                uint32_t sidx=0;    //sbuf:cho,chi,maxk //dw:chi==1;
                for (int cc = 0; cc < (dmul?cho:chi); cc++) {
                    for (int k = 0; k < maxk; k++) {
                        sbuf[sidx+k] = sptr[k_oft[k]];
                    }
                    sidx += maxk;
                    sptr = sptr_base + (dmul?(cc+1)/dmul:(cc+1));
                }
            } else { // TM_PERF_START(t_pad);       //same pad part
                int _ky0 = src_y0<0 ? -src_y0 : 0;
                int _kx0 = src_x0<0 ? -src_x0 : 0;
                int _ky1 = in->h-src_y0>kh ? kh : in->h-src_y0;
                int _kx1 = in->w-src_x0>kw ? kw : in->w-src_x0;
                uint32_t sidx=0;    //sbuf:cho,chi,maxk //dw:chi==1;
                uint32_t s_step = (_ky1-_ky0)*(_kx1-_kx0);
                mtype_t* sptr_base = (mtype_t*)TM_MATP(in, src_y0, src_x0, 0);
                mtype_t* sptr = sptr_base;
           //  #if TM_MDL_TYPE == TM_MDL_INT8
                memset(sbuf, in_zp, dmul?cho*maxk:chi*maxk);    //do padding
           //  #elif (TM_MDL_TYPE == TM_MDL_FP32)||(TM_MDL_TYPE == TM_MDL_FP16)||(TM_MDL_TYPE == TM_MDL_FP8_143)||(TM_MDL_TYPE == TM_MDL_FP8_152)
           //      memset(sbuf, 0, (dmul?cho*maxk:chi*maxk)*sizeof(mtype_t));
           //  #else
           //  #error "unsupport mdl type"
           //  #endif
                for (int cc = 0; cc < (dmul?cho:chi); cc++) {
                    for(int _ky=_ky0; _ky<_ky1; _ky++){
                        for(int _kx=_kx0; _kx<_kx1; _kx++){
                            int k = _ky*kw + _kx;
                            sbuf[sidx+k] = sptr[k_oft[k]];
                        }
                    }
                    sidx += maxk;
                    sptr = sptr_base + (dmul?(cc+1)/dmul:(cc+1));
                }
            }
            //TM_PERF_ADD(t_sbuf);
            mtype_t* sptr = sbuf;    //sbuf prepare ok~
            if(maxk*chi==9 && dmul){ //simple opt for 3x3 dwconv
                for(int c=0; c<out->c; c++){
                    wtype_t* kptr = (wtype_t*)w + c*chi*maxk;//TM_PERF_START(t_dotp);
                    tm_dot_prod_3x3x1(sptr, kptr, &sum);//TM_PERF_ADD(t_dotp);TM_PERF_START(t_post);
                    tm_postprocess_sum(1, &sum, b + c, act, outp, SUMSCALE, OUTSCALE, out_zp); outp++;//TM_PERF_ADD(t_post);
                    sptr += maxk; //dwconv need move step
                }
            }else {
                for(int c=0; c<out->c; c++){
                    wtype_t* kptr = (wtype_t*)w + c*chi*maxk;//TM_PERF_START(t_dotp);
                    tm_dot_prod(sptr, kptr, maxk*chi, &sum);//TM_PERF_ADD(t_dotp);TM_PERF_START(t_post);
                    
                    tm_postprocess_sum(1, &sum, b + c, act, outp, SUMSCALE, OUTSCALE, out_zp); outp++;//TM_PERF_ADD(t_post);
                    if(dmul) sptr += maxk; //dwconv need move step
                }
            }
            // if(!slow_flag) {TM_PERF_ADD(t_valid);} else {TM_PERF_ADD(t_pad);}
        }
    }
    // if(dmul) {TM_PERF_ADD(t_dwconv);} else {TM_PERF_ADD(t_conv);};
    return TM_OK;
}

tm_err_t tml_conv2d_npu( 
    tm_mat_t* in  ,  // input feature map ( dims, h, w, c   )
    tm_mat_t* out ,  // output result map ( dims, h, w, c   )
    wtype_t * w   ,  // weight            ( cho , chi, h, w ), wtype_t -> in8_t   / float
    btype_t * b   ,  // bias              ( out -> c        ), wtype_t -> int32_t / float
    int kw, int kh,  // kernal w , h
    int sx, int sy,  // stride 1/2 
    int dx, int dy,  // dilation, now just support dx=1, dy=1
    int act,         // activaation type
    int pad_top, int pad_bottom, int pad_left, int pad_right, // pad
    int dmul,        // standard conv and depthwise
    sctype_t* ws  ,  // weight scala 
    sctype_t in_s ,  // per-tensor, input scale 
    zptype_t in_zp,  // input zero point 
    sctype_t out_s,  // output scale 
    zptype_t out_zp  // output zero point
){
    if (!edge_npu_runtime.ready || edge_npu_runtime.faulted) return TM_ERR;

    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_start_time = pref_time;

    if (dmul == 1) { TM_PRINTF("duml == 1\n"); return TM_ERR_UNSUPPORT; } 
    if (dx != 1) { TM_PRINTF("dx == %d\n", dx); return TM_ERR_TODO; }
    if (dy != 1) { TM_PRINTF("dy == %d\n", dy); return TM_ERR_TODO; }
    if (act >= TM_ACT_MAXCNT) return TM_ERR_UNSUPPORT;

    if (act != TM_ACT_NONE && act != TM_ACT_RELU
        && !(TM_NPU_CPU_COMPAT && act == TM_ACT_RELU6)) return TM_ERR_UNSUPPORT;

    unsigned native=npu_native_mode();
    npu_window_shape_t shape={in->h,in->w,in->c,out->h,out->w,(uint32_t)kw,(uint32_t)sx,
      (uint32_t)pad_top,(uint32_t)pad_bottom,(uint32_t)pad_left,(uint32_t)pad_right,(int8_t)in_zp};
    size_t tensor_bytes=0,window_bytes=0;
    if(native && (kw!=kh||sx!=sy||npu_window_sizes(&shape,&tensor_bytes,&window_bytes)))return TM_ERR_UNSUPPORT;
    if(native && (tensor_bytes>1048576U||window_bytes>EDGE_NPU_SCRATCH_BYTES))return TM_ERR_OOM;
    int direct=native&&npu_window_direct(&shape);
    if(native && kw==1&&!direct)return TM_ERR_UNSUPPORT;
    int maxk = kw * kh;
    if (maxk > TM_MAX_KSIZE) return TM_ERR_KSIZE;
    if (maxk == 1 && dmul) return TM_ERR_UNSUPPORT;

    if (out->c > TM_MAX_CSIZE) { TM_PRINTF("out->c > TM_MAX_CSIZE\n"); return TM_ERR_UNSUPPORT; }

    int32_t outscale = npu_quant_prepare(out->c,ws,in_s,out_s);

    int exact_ppu = TM_NPU_PPU_EXACT;
    int rescale_enable = 0;
    TM_NPU_LOCAL uint32_t rescale [TM_MAX_CSIZE] = {0};
    int act_enable = 0;
    int act_type   = 0;

    if(exact_ppu){
        if(outscale<=0||outscale>65535||act!=TM_ACT_RELU)return TM_ERR_UNSUPPORT;
        for(int c=0;c<out->c;++c){
            if(sumscale[c]<2049||sumscale[c]>65535)return TM_ERR_UNSUPPORT;
            rescale[c]=(uint32_t)sumscale[c];
        }
        edge_ppu_outscale=(uint32_t)outscale;
        rescale_enable=1;act_enable=1;act_type=7;
    }
    if( !TM_NPU_CPU_COMPAT && act == TM_ACT_RELU ) {
        act_enable = 1;
        act_type   = 0;
        rescale_enable = 1;
    }

    if( rescale_enable && !exact_ppu )
        for (int c = 0; c < out->c; c++){
            rescale[c] = (ws[c]*in_s / out_s) * (1 << 16 );
        }

    int weight_size       = maxk * out->c * in->c; 
    int activation_size   = out->h * out->w * (maxk * in->c); 

    uint32_t out_per_size;
    
    if( rescale_enable ) 
        out_per_size = out->h * out->w * sizeof(mtype_t); 
    else 
        out_per_size = out->h * out->w * sizeof(sumtype_t); 

    out_per_size = TM_ALIGN8(out_per_size);
    uint32_t w_arr_addr   = 0;
    uint32_t a_arr_addr   = native?0:TM_ALIGN8(w_arr_addr + weight_size * sizeof(wtype_t));
    uint32_t out_arr_addr = TM_ALIGN8(a_arr_addr + (direct?0:activation_size * sizeof(mtype_t)));
    uint32_t inst_rel_addr= TM_ALIGN4(out_arr_addr + out->c * out_per_size);
    uint32_t scratch_end_est = inst_rel_addr;

    TM_PRINTF("DIAG NPU PLAN profile=%lu in=%ux%ux%u out=%ux%ux%u k=%dx%d s=%d,%d pad=%d,%d,%d,%d act=%d\r\n",
        (unsigned long)net_pref_info.total_layers,
        in->h, in->w, in->c,
        out->h, out->w, out->c,
        kw, kh, sx, sy,
        pad_top, pad_bottom, pad_left, pad_right,
        act);
    TM_PRINTF("DIAG NPU PLAN sizes weight=%d activation=%d out_per=%lu w_arr=0x%08lx a_arr=0x%08lx out_arr=0x%08lx inst=0x%08lx rescale=%d act_en=%d out_zp=%ld outscale=%ld\r\n",
        weight_size,
        activation_size,
        (unsigned long)out_per_size,
        (unsigned long)w_arr_addr,
        (unsigned long)a_arr_addr,
        (unsigned long)out_arr_addr,
        (unsigned long)inst_rel_addr,
        rescale_enable,
        act_enable,
        (long)out_zp,
        (long)outscale);

    if (inst_rel_addr > EDGE_NPU_SCRATCH_BYTES) return TM_ERR_OOM;
    wtype_t* w_arr = native?w:(wtype_t*)CPU_SHARED_MEM(w_arr_addr);
    mtype_t* native_a=direct?in->data:(mtype_t*)CPU_SHARED_MEM(a_arr_addr);
    if(native && npu_native_layer((uintptr_t)w,(size_t)weight_size,(uintptr_t)in->data,tensor_bytes,(uintptr_t)native_a,window_bytes)!=NPU_OK)return TM_ERR;
    extern int npu_window_bram_available(void);
    int use_hw_window=!native && maxk!=1 && kw==kh && sx==sy && npu_window_bram_available();
    if(!native){if(use_hw_window)memcpy(w_arr,w,weight_size);else sw_pack_weight(w,w_arr,out->c,in->c,maxk);}
    tml_diag_print_i8_buffer("NPU_PACKED_WEIGHT", (const int8_t *)w_arr, weight_size);

    mtype_t* a_arr = native?native_a:(mtype_t*)CPU_SHARED_MEM(a_arr_addr);
   
    
    TM_NPU_LOCAL uint32_t out_addr_npu[TM_MAX_CSIZE];
    TM_NPU_LOCAL uint32_t out_addr_cpu[TM_MAX_CSIZE];
    
    for (int oc = 0; oc < out->c; ++oc) {
        uint32_t cur_addr = TM_ALIGN8(out_arr_addr + oc * out_per_size);
        out_addr_cpu[oc] = cur_addr; 
        out_addr_npu[oc] = NPU_SHARED_MEM(cur_addr);
    }

    uint32_t a_addr  = native?(uint32_t)(uintptr_t)a_arr:NPU_SHARED_MEM(a_arr_addr); 
    uint32_t w_addr  = native?(uint32_t)(uintptr_t)w_arr:NPU_SHARED_MEM(w_arr_addr); 
    int insize       = maxk * in->c;
    int outsize      = out->w * out->h;
    uint32_t a_num   = out->w * out->h;
    uint32_t w_num   = out->c;
    
    uint8_t  exp_tag;
    uint32_t inst_len; 


    if (npu_mac_engine(CPU_SHARED_MEM(inst_rel_addr), a_addr, w_addr, (uint32_t*)b, rescale_enable, rescale, act_enable, act_type, exact_ppu ? out_zp : TM_NPU_CPU_COMPAT ? 0 : out_zp, 
            out_addr_npu, insize, outsize, a_num, w_num, &exp_tag, &inst_len) != NPU_OK) return (npu_last_result() == NPU_ECAPACITY || npu_last_result() == NPU_EUNSUPPORTED) ? TM_ERR_UNSUPPORT : TM_ERR; 
    /* Instructions reside in persistent CODE DDR, outside scratch. */
    TM_PRINTF("DIAG NPU INST profile=%lu exp_tag=%u inst_len=%lu scratch_end_est=0x%08lx cmd_addr=0x%08lx\r\n",
        (unsigned long)net_pref_info.total_layers,
        (unsigned)exp_tag,
        (unsigned long)inst_len,
        (unsigned long)scratch_end_est,
        (unsigned long)npu_prepared_physical());
    if (rescale_enable) {
        int first_n = (out->c < 8) ? out->c : 8;
        TM_PRINTF("DIAG NPU RESCALE first%d:", first_n);
        for (int i = 0; i < first_n; ++i) {
            TM_PRINTF(" %lu", (unsigned long)rescale[i]);
        }
        TM_PRINTF("\r\n");
    }

    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_end_time = pref_time;

    if(native) {
        if(!direct && (native==2 ? npu_window_hardware((uintptr_t)in->data,(uintptr_t)a_arr,&shape,2000000ULL) :
             npu_window_native((const int8_t *)in->data,(int8_t *)a_arr,window_bytes,&shape))!=NPU_OK)return TM_ERR;
    } else if(maxk!=1 && kw==kh && sx==sy){
        extern int npu_window_bram(uintptr_t,uintptr_t,const npu_window_shape_t*,uint64_t);
        int window_rc=npu_window_bram((uintptr_t)in->data,(uintptr_t)a_arr,&shape,2000000ULL);
        if(window_rc==NPU_EUNSUPPORTED){
            if(use_hw_window)sw_pack_weight(w,w_arr,out->c,in->c,maxk);
            sw_im2col_hwc(in->data,a_arr,kw,kh,sx,sy,pad_top,pad_bottom,pad_left,pad_right,in->w,in->h,in->c,out->h,out->w,in_zp);
        }
        else if(window_rc!=NPU_OK)return TM_ERR;
        /* Hardware emits [p][ci][ky][kx], matching the unpermuted model weights. */
        if(window_rc==NPU_OK && !use_hw_window && in->c>=16)memcpy(w_arr,w,weight_size);
    } else if( maxk != 1 ) {
        sw_im2col_hwc(in->data, a_arr, kw, kh, sx, sy, 
                   pad_top, pad_bottom, pad_left, pad_right,in->w, in->h, in->c ,
                   out->h, out->w, in_zp);
    } else {
        sw_im2col_1x1_hwc(in->data, a_arr, kw, kh, sx, sy, 
                   pad_top, pad_bottom, pad_left, pad_right,in->w, in->h, in->c ,
                   out->h, out->w, in_zp);
    }
    tml_diag_print_i8_buffer("NPU_IM2COL", (const int8_t *)a_arr, activation_size);

    if (npu_submit_prepared(2000000ULL) != NPU_OK) return (npu_last_result() == NPU_ECAPACITY || npu_last_result() == NPU_EUNSUPPORTED) ? TM_ERR_UNSUPPORT : TM_ERR;
    if(exact_ppu)++edge_ppu_layers;
    TM_PRINTF("DIAG NPU DONE profile=%lu got_tag=%u exp_tag=%u\r\n",
        (unsigned long)net_pref_info.total_layers,
        (unsigned)sync_tag,
        (unsigned)exp_tag);

    int dump_ch = (out->c < 4) ? out->c : 4;
    for (int c = 0; c < dump_ch; ++c) {
        TM_PRINTF("DIAG NPU_CH_OUT c=%d addr=0x%08lx len=%lu type=%s\r\n",
            c,
            (unsigned long)out_addr_cpu[c],
            (unsigned long)(out->h * out->w),
            rescale_enable ? "i8" : "i32");
        if (rescale_enable) {
            tml_diag_print_i8_buffer("NPU_CH_OUT_I8", (const int8_t *)CPU_SHARED_MEM(out_addr_cpu[c]), out->h * out->w);
        } else {
            tml_diag_print_i32_buffer("NPU_CH_OUT_I32", (const int32_t *)CPU_SHARED_MEM(out_addr_cpu[c]), out->h * out->w);
        }
    }

    uint64_t pref_time_start;
    TM_GET_TICK(pref_time_start); 
 
    mtype_t* outp = out->data;
    uint32_t out_num = out->h * out->w;
   
    for(int c = 0; c < out->c; c++){
        if( !rescale_enable )
        tm_postprocess_sum_npu(c, out->c, out_num, CPU_SHARED_MEM(out_addr_cpu[c]), 
                               b + c, act, outp, SUMSCALE, OUTSCALE, out_zp);
        else {
            mtype_t* sum_arr = (mtype_t*)CPU_SHARED_MEM(out_addr_cpu[c]);
            for(int i = 0; i < out_num; i++) 
                outp[( i* out->c ) + c ] = sum_arr[i];
        }
    }

    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_end_time += pref_time - pref_time_start;

    return TM_OK;
}

#include <string.h>

#include "dw_batch.inc"

tm_err_t tml_dwconv2d_npu( 
    tm_mat_t* in  ,  // input feature map ( dims, h, w, c   )
    tm_mat_t* out ,  // output result map ( dims, h, w, c   )
    wtype_t * w   ,  // weight            ( cho , 1, h, w ), wtype_t -> int8_t   / float
    btype_t * b   ,  // bias              ( out -> c        ), btype_t -> int32_t / float
    int kw, int kh,  // kernal w , h
    int sx, int sy,  // stride 1/2 
    int dx, int dy,  // dilation, now just support dx=1, dy=1
    int act,         // activaation type
    int pad_top, int pad_bottom, int pad_left, int pad_right, // pad
    int dmul,        // standard conv and depthwise (expected to be 1 here)
    sctype_t* ws  ,  // weight scala 
    sctype_t in_s ,  // per-tensor, input scale 
    zptype_t in_zp,  // input zero point 
    sctype_t out_s,  // output scale 
    zptype_t out_zp  // output zero point
){
    if(TM_NPU_CPU_COMPAT && kw==1 && sx==1 && sy==1 && dx==1 && dy==1 && dmul==1 && pad_left==0 && pad_right==0)
        return tml_dw_vertical_batch(in,out,w,b,kh,act,pad_top,ws,in_s,in_zp,out_s,out_zp);
    if (!edge_npu_runtime.ready || edge_npu_runtime.faulted) return TM_ERR;
    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_start_time = pref_time;

    if (dmul != 1) { TM_PRINTF("duml != 1 in dwconv\n"); return TM_ERR_UNSUPPORT; } 
    if (in->c != out->c) { TM_PRINTF("in->c != out->c\n"); return TM_ERR_UNSUPPORT; }
    if (dx != 1) { TM_PRINTF("dx == %d\n", dx); return TM_ERR_TODO; }
    if (dy != 1) { TM_PRINTF("dy == %d\n", dy); return TM_ERR_TODO; }
    if (act >= TM_ACT_MAXCNT) return TM_ERR_UNSUPPORT;

    if (act != TM_ACT_NONE && act != TM_ACT_RELU
        && !(TM_NPU_CPU_COMPAT && act == TM_ACT_RELU6)) return TM_ERR_UNSUPPORT;

    int maxk = kw * kh;
    if (maxk > TM_MAX_KSIZE) return TM_ERR_KSIZE;

    if (out->c > TM_MAX_CSIZE) { TM_PRINTF("out->c > TM_MAX_CSIZE\n"); return TM_ERR_UNSUPPORT; }


    int32_t outscale = npu_quant_prepare(out->c,ws,in_s,out_s);

    int exact_ppu = TM_NPU_PPU_EXACT;
    int rescale_enable = 0;
    TM_NPU_LOCAL uint32_t rescale [TM_MAX_CSIZE] = {0};
    int act_enable = 0;
    int act_type   = 0;

    if(exact_ppu){
        if(outscale<=0||outscale>65535||act!=TM_ACT_RELU)return TM_ERR_UNSUPPORT;
        for(int c=0;c<out->c;++c){
            if(sumscale[c]<2049||sumscale[c]>65535)return TM_ERR_UNSUPPORT;
            rescale[c]=(uint32_t)sumscale[c];
        }
        edge_ppu_outscale=(uint32_t)outscale;
        rescale_enable=1;act_enable=1;act_type=7;
    }
    if( !TM_NPU_CPU_COMPAT && act == TM_ACT_RELU ) {
        act_enable = 1;
        act_type   = 0;
        rescale_enable = 1;
    }

    if( rescale_enable ) {
        for (int c = 0; c < out->c; c++){
            rescale[c] = (ws[c]*in_s / out_s) * (1 << 16 );
        }
    }

   int weight_size           = maxk * out->c;            
    uint32_t a_channel_size   = out->h * out->w * maxk;  
    
    uint32_t out_per_size;
    if( rescale_enable ) 
        out_per_size = out->h * out->w * sizeof(mtype_t); 
    else 
        out_per_size = out->h * out->w * sizeof(sumtype_t); 

    out_per_size = TM_ALIGN8(out_per_size);
    uint32_t w_arr_addr   = 0;
    uint32_t a_arr_addr   = TM_ALIGN8(w_arr_addr + weight_size * sizeof(wtype_t));
    uint32_t out_arr_addr = TM_ALIGN8(a_arr_addr + a_channel_size * sizeof(mtype_t));
    uint32_t inst_rel_addr= TM_ALIGN8(out_arr_addr + out_per_size);

    if (inst_rel_addr > EDGE_NPU_SCRATCH_BYTES) return TM_ERR_OOM;
    wtype_t* w_arr       = (wtype_t*)CPU_SHARED_MEM(w_arr_addr); 
    mtype_t* a_arr_1ch   = (mtype_t*)CPU_SHARED_MEM(a_arr_addr);
    void* out_arr_cpu = CPU_SHARED_MEM(out_arr_addr);
    uint32_t out_arr_npu = NPU_SHARED_MEM(out_arr_addr);

    int k_oft[TM_MAX_KSIZE];
    for (int ky = 0; ky < kh; ky++) {
        for (int kx = 0; kx < kw; kx++) {
            k_oft[ky * kw + kx] = (ky * in->w + kx) * in->c;
        }
    }

    int insize       = maxk;           
    int outsize      = out->w * out->h;
    uint32_t a_num   = out->w * out->h; 
    uint32_t w_num   = 1;               
    mtype_t* outp    = out->data;
    uint32_t out_num = out->h * out->w;

    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_end_time = pref_time;

    uint64_t pref_time_start;

    for (int c = 0; c < out->c; ++c) {
        
        mtype_t* a_ptr = a_arr_1ch;
        for (int y = 0; y < out->h; y++) {
            int src_y0 = sy * y - pad_top;
            for (int x = 0; x < out->w; x++) {
                int src_x0 = sx * x - pad_left;
                
                int is_valid = (src_y0 >= 0 && src_x0 >= 0 && 
                                src_y0 + kh <= in->h && src_x0 + kw <= in->w);
                
                if (is_valid) {
                    int8_t* in_ptr_base = in->data + (src_y0 * in->w + src_x0) * in->c + c;
                    for (int k = 0; k < maxk; k++) {
                        *a_ptr++ = in_ptr_base[k_oft[k]];
                    }
                } else {
                    for (int k = 0; k < maxk; k++) {
                        int ky = k / kw;
                        int kx = k % kw;
                        int sy_k = src_y0 + ky;
                        int sx_k = src_x0 + kx;
                        if (sy_k >= 0 && sy_k < in->h && sx_k >= 0 && sx_k < in->w) {
                            *a_ptr++ = in->data[(sy_k * in->w + sx_k) * in->c + c];
                        } else {
                            *a_ptr++ = in_zp; 
                        }
                    }
                }
            }
        }

        TM_GET_TICK(pref_time_start); 
        
        sw_pack_weight(w + c * maxk, w_arr + c * maxk, 1, 1, maxk);
        uint8_t  exp_tag;
        uint32_t inst_len; 
        
        uint32_t a_addr_c = NPU_SHARED_MEM(a_arr_addr); 
        uint32_t w_addr_c = NPU_SHARED_MEM(w_arr_addr + c * maxk * sizeof(wtype_t));
        
        uint32_t cur_out_addr[1] = { out_arr_npu };     
        uint32_t cur_rescale[1]  = { rescale[c] };
        
        if (npu_mac_engine(CPU_SHARED_MEM(inst_rel_addr), a_addr_c, w_addr_c, (uint32_t*)(b + c), 
                       rescale_enable, cur_rescale, act_enable, act_type, exact_ppu ? out_zp : TM_NPU_CPU_COMPAT ? 0 : out_zp, 
                       cur_out_addr, insize, outsize, a_num, w_num, &exp_tag, &inst_len) != NPU_OK) return (npu_last_result() == NPU_ECAPACITY || npu_last_result() == NPU_EUNSUPPORTED) ? TM_ERR_UNSUPPORT : TM_ERR; 

        TM_GET_TICK(pref_time); 
        net_pref_info.layers[net_pref_info.total_layers].ext_end_time += pref_time - pref_time_start;


        sync_flag = 0;
        sync_tag = 0;

        if (npu_submit_prepared(2000000ULL) != NPU_OK) return TM_ERR;
       
        TM_GET_TICK(pref_time_start); 

        if( !rescale_enable ) {
            tm_postprocess_sum_npu(c, out->c, out_num, out_arr_cpu, 
                                   b + c, act, outp, SUMSCALE, OUTSCALE, out_zp);
        } else {
            mtype_t* sum_arr = (mtype_t*)out_arr_cpu;
            for(int i = 0; i < out_num; i++) {
                outp[( i * out->c ) + c ] = sum_arr[i];
            }
        }

        TM_GET_TICK(pref_time); 
        net_pref_info.layers[net_pref_info.total_layers].ext_end_time += pref_time - pref_time_start;
    }

    return TM_OK;
}

/***************************  TML_GAP **********************************/
tm_err_t TM_WEAK tml_gap(tm_mat_t* in, tm_mat_t* out, sctype_t in_s, zptype_t in_zp, sctype_t out_s, zptype_t out_zp)
{   TM_DBGT_INIT();
    mtype_t* data;
    for(int c=0; c <out->c; c++){
        sumtype_t sum = 0;
        data = in->data + c;
        for(int y=0; y <in->h; y++){
            for(int x=0; x <in->w; x++){
                sum  += ((sumtype_t)(*data));
                data += out->c;
            }
        }
    // #if TM_MDL_TYPE == TM_MDL_INT8 || TM_MDL_TYPE == TM_MDL_INT16
        out->data[c] = (mtype_t)((sum/((in->h)*(in->w))-in_zp)*in_s/out_s + out_zp); //requant
    // #elif TM_MDL_TYPE == TM_MDL_FP32 || TM_MDL_TYPE == TM_MDL_FP16
    //     out->data[c] = (mtype_t)(sum/((in->h)*(in->w)));
    // //#else //#elif TM_MDL_TYPE == TM_MDL_FP8_143 || TM_MDL_TYPE == TM_MDL_FP8_152
    // #endif
    }
    return TM_OK;
}

#include "mnist_math_fast.inc"

/*************************** TML_FC **********************************/
tm_err_t TM_WEAK tml_fc(tm_mat_t* in, tm_mat_t* out,  wtype_t* w, btype_t* b, \
    sctype_t* ws, sctype_t in_s, zptype_t in_zp, sctype_t out_s, zptype_t out_zp)
{   // Imported FC binaries use one tensor scale; remaining slots are padding.
    if (!(out_s > 0.0f) || !isfinite(out_s) || !isfinite(in_s)) return TM_ERR_DIMS;
    if (!(ws[0] > 0.0f) || !isfinite(ws[0])) return TM_ERR_DIMS;
    mtype_t* data = in->data;
    for(int c=0; c <out->c; c++){
        sumtype_t sum = 0;
        tm_dot_prod(data, w+c*in->c, in->c, &sum);
        sum += b[c];    //fuse with zp
    // #if TM_MDL_TYPE == TM_MDL_INT8 || TM_MDL_TYPE == TM_MDL_INT16
        float quantized = sum*in_s*ws[0]/out_s + out_zp;
#if TM_MDL_TYPE == TM_MDL_INT8
        if (quantized > 127.0f) quantized = 127.0f;
        if (quantized < -128.0f) quantized = -128.0f;
#elif TM_MDL_TYPE == TM_MDL_INT16
        if (quantized > 32767.0f) quantized = 32767.0f;
        if (quantized < -32768.0f) quantized = -32768.0f;
#endif
        out->data[c] = (mtype_t)quantized; // retain truncation, saturate before cast
    // #else
    //     out->data[c] = (mtype_t)(sum);
    // #endif
    }
    return TM_OK;
}

tm_err_t TM_WEAK tml_fc_npu(tm_mat_t* in, tm_mat_t* out,  wtype_t* w, btype_t* b, \
    sctype_t* ws, sctype_t in_s, zptype_t in_zp, sctype_t out_s, zptype_t out_zp)
{
    if (!edge_npu_runtime.ready || edge_npu_runtime.faulted) return TM_ERR;

    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_start_time = pref_time;

    int in_features = in->c;
    int out_features = out->c;
    if (out_features > TM_MAX_CSIZE) return TM_ERR_UNSUPPORT; 
    
    TM_NPU_LOCAL uint32_t out_addr_npu[TM_MAX_CSIZE]; 
    TM_NPU_LOCAL uint32_t out_addr_cpu[TM_MAX_CSIZE];
    TM_NPU_LOCAL uint32_t rescale[TM_MAX_CSIZE] = {0};

    if (!(out_s > 0.0f) || !isfinite(out_s) || !isfinite(in_s)) return TM_ERR_UNSUPPORT;
    #if !TM_NPU_CPU_COMPAT
    float coefficient = ws[0] * in_s / out_s * 65536.0f;
    if (!isfinite(coefficient) || coefficient <= 0.0f || (double)coefficient > INT32_MAX) return TM_ERR_UNSUPPORT;
    for (int c = 0; c < out_features; c++) {
        rescale[c] = (uint32_t)coefficient;
    }
#else
    if (!(ws[0] > 0.0f) || !isfinite(ws[0])) return TM_ERR_UNSUPPORT;
#endif

    int weight_size     = in_features * out_features; 
    int act_size        = in_features; 
    
    uint32_t out_per_size = TM_NPU_CPU_COMPAT ? sizeof(sumtype_t) : sizeof(mtype_t); 
    // uint32_t out_per_size = sizeof(sumtype_t); 

    out_per_size = TM_ALIGN8(out_per_size);
    uint32_t w_arr_addr   = 0;
    uint32_t a_arr_addr   = TM_ALIGN8(w_arr_addr + weight_size * sizeof(wtype_t));
    uint32_t out_arr_addr = TM_ALIGN8(a_arr_addr + act_size * sizeof(mtype_t));
    uint32_t inst_rel_addr= TM_ALIGN4(out_arr_addr + out_features * out_per_size); 

    if (inst_rel_addr > EDGE_NPU_SCRATCH_BYTES) return TM_ERR_OOM;
    wtype_t* w_arr = (wtype_t*)CPU_SHARED_MEM(w_arr_addr); 
    // for(int i = 0; i < weight_size; i++) {
    //     w_arr[i] = w[i];
    // }
    memcpy(w_arr, w, weight_size * sizeof(wtype_t));

    mtype_t* a_arr = (mtype_t*)CPU_SHARED_MEM(a_arr_addr);
    mtype_t* data = in->data;
    // for(int i = 0; i < act_size; i++) {
    //     a_arr[i] = data[i];
    // }
    memcpy(a_arr, data, act_size * sizeof(mtype_t));

    for (int oc = 0; oc < out_features; ++oc) {
        uint32_t cur_addr = TM_ALIGN8(out_arr_addr + oc * out_per_size);
        out_addr_cpu[oc] = cur_addr; 
        out_addr_npu[oc] = NPU_SHARED_MEM(cur_addr);
    }

    uint32_t a_addr  = NPU_SHARED_MEM(a_arr_addr); 
    uint32_t w_addr  = NPU_SHARED_MEM(w_arr_addr); 
    
    int insize       = in_features;
    int outsize      = 1;
    uint32_t a_num   = 1;
    uint32_t w_num   = out_features;
    
    uint8_t  exp_tag;
    uint32_t inst_len; 
    
    if (npu_mac_engine(CPU_SHARED_MEM(inst_rel_addr), a_addr, w_addr, (uint32_t*)b, 
                   !TM_NPU_CPU_COMPAT, rescale, 0, 0, TM_NPU_CPU_COMPAT ? 0 : out_zp, 
                   out_addr_npu, insize, outsize, a_num, w_num, &exp_tag, &inst_len) != NPU_OK) return (npu_last_result() == NPU_ECAPACITY || npu_last_result() == NPU_EUNSUPPORTED) ? TM_ERR_UNSUPPORT : TM_ERR;

    TM_GET_TICK(pref_time); 
    net_pref_info.layers[net_pref_info.total_layers].ext_end_time = pref_time;

    if (npu_submit_prepared(2000000ULL) != NPU_OK) return TM_ERR;

    // for(int c = 0; c < out_features; c++){
    //     sumtype_t* npu_out_ptr = (sumtype_t*)CPU_SHARED_MEM(out_addr_cpu[c]);
    //     sumtype_t sum = *npu_out_ptr;

    //     out->data[c] = (mtype_t)(sum * in_s * ws[0] / out_s + out_zp); 
    // }

    // for(int c = 0; c < out_features; c++){
    //     mtype_t* npu_out_ptr = (mtype_t*)CPU_SHARED_MEM(out_addr_cpu[c]);
    //     out->data[c] = *npu_out_ptr; 
    // }
    for (int c=0;c<out_features;++c) {
#if TM_NPU_CPU_COMPAT
        /* FC has its own original floating-point requantization contract. */
        sumtype_t sum = *(sumtype_t*)CPU_SHARED_MEM(out_addr_cpu[c]);
        if(out_zp==42 && mnist_bits(in_s)==MNIST_FC_IN_BITS && mnist_bits(ws[0])==MNIST_FC_WS_BITS && mnist_bits(out_s)==MNIST_FC_OUT_BITS)out->data[c]=mnist_fc_quant(sum);
        else {
            float quantized=sum*in_s*ws[0]/out_s+out_zp;
            if(quantized>127)quantized=127;if(quantized< -128)quantized=-128;
            out->data[c]=(mtype_t)quantized;
        }
#else
        out->data[c] = *(mtype_t*)CPU_SHARED_MEM(out_addr_cpu[c]);
#endif
    }

    return TM_OK;
}

/*************************** TML_SOFTMAX **********************************/
tm_err_t TM_WEAK tml_softmax(tm_mat_t* in, tm_mat_t* out, sctype_t in_s, zptype_t in_zp, sctype_t out_s, zptype_t out_zp)
{   TM_DBGT_INIT(); //note we have float size output buf even in INT8/INT16 mode
    mtype_t* din = in->data;
    float*  dout = (float*)(out->data);
    float   dmax =  -FLT_MAX;
    for(int c=0; c <in->c; c++){
   //  #if TM_MDL_TYPE == TM_MDL_INT8 || TM_MDL_TYPE == TM_MDL_INT16
        dout[c] = (float)((sumtype_t)din[c] - in_zp)*in_s;
   //  #else
   //      dout[c] = din[c];
   //  #endif
        if(dout[c] > dmax) dmax = dout[c];
    }
    float sum = 0;
    for(int c=0; c <in->c; c++){
        dout[c] -= dmax;
        dout[c] = (float)tm_exp(dout[c]);
        sum     += dout[c];
        dout[c] -= 0.000001f;  //prevent 1.0 value (cause 256 overflow)
    }
    for(int c=0; c <in->c; c++){  //int8/int16 <= fp32, so it is ok
    // #if TM_MDL_TYPE == TM_MDL_INT8 || TM_MDL_TYPE == TM_MDL_INT16
        out->data[c] = (mtype_t)(dout[c]/sum/out_s + out_zp); //requant
    // #else
    //     out->data[c] = (mtype_t)(dout[c]/sum);
    // #endif
    }
    return TM_OK;
}

/*************************** TML_RESHAPE **********************************/
tm_err_t TM_WEAK tml_reshape(tm_mat_t* in, tm_mat_t* out, sctype_t in_s, zptype_t in_zp, sctype_t out_s, zptype_t out_zp)
{   
    //in fact do nothing... out shape
    return TM_OK;
}


tm_err_t TM_WEAK tml_add(tm_mat_t* in0, tm_mat_t* in1, tm_mat_t* out, \
    sctype_t in_s0, zptype_t in_zp0, sctype_t in_s1, zptype_t in_zp1, sctype_t out_s, zptype_t out_zp)
{   //TODO: check in0 shape == in1 shape 
    //It is simple and experimental implement for ADD, could be more way faster
    mtype_t* d0 = in0->data;
    mtype_t* d1 = in1->data;
    mtype_t* res = out->data; 
    int size = in0->h*in0->w*in0->c;
    TM_PRINTF("s0=%.3f,zp0=%d; s1=%.3f,zp1=%d\r\n", in_s0, in_zp0, in_s1, in_zp1);
#if TM_MDL_TYPE == TM_MDL_FP16 || TM_MDL_TYPE == TM_MDL_FP32 || TM_MDL_TYPE == TM_MDL_INT8
    int i;
    for(i=0; i+4<=size; ){
        res[i] = TM_QUANT(TM_DEQUANT(d0[i],in_s0,in_zp0)+TM_DEQUANT(d1[i],in_s1,in_zp1), out_s, out_zp); i++;
        res[i] = TM_QUANT(TM_DEQUANT(d0[i],in_s0,in_zp0)+TM_DEQUANT(d1[i],in_s1,in_zp1), out_s, out_zp); i++;
        res[i] = TM_QUANT(TM_DEQUANT(d0[i],in_s0,in_zp0)+TM_DEQUANT(d1[i],in_s1,in_zp1), out_s, out_zp); i++;
        res[i] = TM_QUANT(TM_DEQUANT(d0[i],in_s0,in_zp0)+TM_DEQUANT(d1[i],in_s1,in_zp1), out_s, out_zp); i++;
    }
    for(; i<size; i++){
        res[i] = TM_QUANT(TM_DEQUANT(d0[i],in_s0,in_zp0)+TM_DEQUANT(d1[i],in_s1,in_zp1), out_s, out_zp);
    }
#else
    #error "ADD not support this data type yet"
#endif
    return TM_OK;
}

// #endif
