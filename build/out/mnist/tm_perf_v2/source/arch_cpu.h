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
#include "stdlib.h"
#include "stdint.h"
#include "math.h"
#include "float.h"
#include "tinymaix.h"

#if (TM_MDL_TYPE != TM_MDL_FP8_143) && (TM_MDL_TYPE != TM_MDL_FP8_152)
//sum = SUM(Ai*Bi)
TM_INLINE void tm_dot_prod(mtype_t* sptr, mtype_t* kptr,uint32_t size, sumtype_t* result)
{
    sumtype_t sum=0;
    uint32_t i = 0;
    uint32_t cnt = (size>>3)<<3;  //8
    for(; i+8-1 <cnt; ){
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
        sum += sptr[i]*kptr[i];i++;
    }
    for(; i <size; i++){
        sum += sptr[i]*kptr[i]; 
    }
    *result = sum;
    return;
}

TM_INLINE  void tm_dot_prod_pack2(mtype_t* sptr, mtype_t* kptr, uint32_t size, sumtype_t* result)
{ 
    sumtype_t sum0 = 0;
    sumtype_t sum1 = 0;
    mtype_t* kptr0 = kptr;
    mtype_t* kptr1 = kptr+size;

    uint32_t i = 0;
    uint32_t cnt = (size>>3)<<3;  //8
    for(; i+8-1 <cnt; ){
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
        sum0 += sptr[i]*kptr0[i]; sum1 += sptr[i]*kptr1[i]; i++;
    }
    for(; i <size; i++){
        sum0 += sptr[i]*kptr0[i]; 
        sum1 += sptr[i]*kptr1[i]; 
    }

    result[0] = sum0;
    result[1] = sum1;
    return;
}

TM_INLINE void tm_dot_prod_gap_3x3x1(mtype_t* sptr, mtype_t* kptr, uint32_t* k_oft, sumtype_t* result)
{
    *result = sptr[k_oft[0]]*kptr[0] + sptr[k_oft[1]]*kptr[1] + sptr[k_oft[2]]*kptr[2] + \
        sptr[k_oft[3]]*kptr[3] + sptr[k_oft[4]]*kptr[4] + sptr[k_oft[5]]*kptr[5] + \
        sptr[k_oft[6]]*kptr[6] + sptr[k_oft[7]]*kptr[7] + sptr[k_oft[8]]*kptr[8] ;
    return;                  
}

TM_INLINE void tm_dot_prod_3x3x1(mtype_t* sptr, mtype_t* kptr, sumtype_t* result)
{
    *result = sptr[0]*kptr[0] + sptr[1]*kptr[1] + sptr[2]*kptr[2] + \
        sptr[3]*kptr[3] + sptr[4]*kptr[4] + sptr[5]*kptr[5] + \
        sptr[6]*kptr[6] + sptr[7]*kptr[7] + sptr[8]*kptr[8] ;
    return;
}



#else
/*************************** FP8 SIMULATION **********************************/
#define SUMSCALE 1.0

TM_INLINE void tm_dot_prod(mtype_t* sptr, mtype_t* kptr,uint32_t size, sumtype_t* result)
{
    sumtype_t sum=0;
    for(int i=0; i <size; i++){
        float _s = tm_fp8to32(sptr[i]);
        float _k = tm_fp8to32(kptr[i]);
        sum += _s*_k;
        //printf("%.3f*%.3f+",_s,_k);
    }
    //printf("\r\n");
    *result = sum;
    return;
}

TM_INLINE void tm_postprocess_sum(sumtype_t sum, btype_t b, int act, mtype_t* outp, \
    sctype_t scale, sctype_t out_s, zptype_t out_zp)
{   //printf("sum=%.6f,", sum);
    sum += tm_fp8to32(b); //printf("%.6f,", sum);
    switch(act){    //activation func
    case TM_ACT_RELU:
        sum = sum>0?sum:0;
        break;
    case TM_ACT_RELU6:
        sum = sum>0?sum:0;
        sum = sum>6?6:sum;
        break;
    default:
        break;
    }
    //printf("%.6f,", sum);
    *outp = tm_fp32to8(sum);
    //printf("  %02x,%.6f\r\n", *outp, tm_fp8to32(*outp));
    return;
}

#endif

#if (TM_MDL_TYPE==TM_MDL_FP32) || (TM_MDL_TYPE==TM_MDL_FP16) 

TM_INLINE void tm_postprocess_sum(int n, sumtype_t* sums, btype_t* bs, int act, mtype_t* outp, \
    sctype_t* scales, sctype_t out_s, zptype_t out_zp)
{
    for(int i = 0; i < n; i++) {
        sumtype_t sum = sums[i];
        sum += bs[i];
        switch(act){    //activation func
        case TM_ACT_RELU:
        case TM_ACT_RELU6: //treat relu6 as relu in float mode //speed up
            sum = sum>0?sum:0;
            break;
        //    sum = sum>0?sum:0;
        //    sum = sum>6?6:sum;
        //    break;
        default:
            break;
        }
        outp[i] = (mtype_t)sum;
    }
    return;
}

#elif (TM_MDL_TYPE==TM_MDL_INT8) || (TM_MDL_TYPE==TM_MDL_INT16) 

#if TM_NPU_CPU_COMPAT && TM_FASTSCALE
/* Match the existing GCC/RV32 Q8 bit pattern without signed-left-shift or
 * signed-multiply undefined behaviour. This intentionally retains modulo-32
 * arithmetic; using an unbounded INT64 requantizer would change the model.
 * Dot products and dot+bias for the frozen image models are independently
 * checked against INT64 before the NPU output is interpreted as INT32. */
TM_INLINE int32_t tm_compat_i32(uint32_t value)
{
    return value <= INT32_MAX ? (int32_t)value : -1 - (int32_t)(UINT32_MAX-value);
}
TM_INLINE int32_t tm_compat_q8(sumtype_t sum, int32_t denominator)
{
    return tm_compat_i32((uint32_t)sum << TM_FASTSCALE_SHIFT) / denominator;
}
TM_INLINE mtype_t tm_compat_output(int32_t sum, int32_t scale, zptype_t zp)
{
    uint32_t product = (uint32_t)sum * (uint32_t)scale;
    uint32_t shifted = product >> (2*TM_FASTSCALE_SHIFT);
    if (product & 0x80000000u)
        shifted |= UINT32_MAX << (32-2*TM_FASTSCALE_SHIFT);
    uint32_t quantized = shifted + (uint32_t)zp;
#if TM_MDL_TYPE == TM_MDL_INT8
    uint32_t bits = quantized & 255u;
    return (mtype_t)(bits <= 127u ? (int32_t)bits : (int32_t)bits-256);
#else
    uint32_t bits = quantized & 65535u;
    return (mtype_t)(bits <= 32767u ? (int32_t)bits : (int32_t)bits-65536);
#endif
}
/* Exact signed division for a fixed positive denominator. The magnitude is
 * <= 2^31, so the ceil-reciprocal estimate is at most one too large, and its
 * product with the divisor cannot overflow uint32_t. CPU reference is unchanged. */
TM_INLINE int32_t tm_npu_q8_recip(sumtype_t sum,uint32_t denominator,uint32_t reciprocal){
 int32_t s=tm_compat_i32((uint32_t)sum<<TM_FASTSCALE_SHIFT);
 uint32_t magnitude=s<0?0U-(uint32_t)s:(uint32_t)s;
 uint32_t q=(uint32_t)(((uint64_t)magnitude*reciprocal)>>32);
 if(q*denominator>magnitude)--q;
 return s<0?tm_compat_i32(0U-q):(int32_t)q;
}
#endif

#if !TM_FASTSCALE
TM_INLINE void tm_postprocess_sum(int n, sumtype_t* sums, btype_t* bs, int act, mtype_t* outp, sctype_t* scales, sctype_t out_s_inv, zptype_t out_zp)
#else
TM_INLINE void tm_postprocess_sum(int n, sumtype_t* sums, btype_t* bs, int act, mtype_t* outp, int32_t* scales, int32_t out_s, zptype_t out_zp)
#endif
{
    for(int i = 0; i < n; i++) {
        sumtype_t sum = sums[i];
        #if TM_NPU_CPU_COMPAT && TM_FASTSCALE
            sum = tm_compat_i32((uint32_t)sum + (uint32_t)bs[i]);
        #else
            sum += bs[i];
        #endif
        #if !TM_FASTSCALE
            float sumf = sum*scales[i];
        #else 
            #if TM_NPU_CPU_COMPAT
                sumtype_t sumf = tm_compat_q8(sum, scales[i]);
            #else
                sumtype_t sumf = (sum<<TM_FASTSCALE_SHIFT)/scales[i];
            #endif
        #endif
        switch(act){    //activation func
        case TM_ACT_RELU:
            sumf = sumf>0?sumf:0;
            break;
        case TM_ACT_RELU6:
            sumf = sumf>0?sumf:0;
        #if (!TM_FASTSCALE)
            sumf = sumf>6?6:sumf;
        #else
            sumf = sumf>(6<<TM_FASTSCALE_SHIFT)?(6<<TM_FASTSCALE_SHIFT):sumf;
        #endif
            break;
        default:
            break;
        }
        #if !TM_FASTSCALE
            outp[i] = (mtype_t)(sumf*out_s_inv + out_zp);  //(mtype_t)((int)(sumf/out_s) + out_zp) //(mtype_t)((int)(sumf/out_s +0.5) + out_zp)
        #else 
            #if TM_NPU_CPU_COMPAT
                outp[i] = tm_compat_output(sumf, out_s, out_zp);
            #else
                outp[i] = (mtype_t)(((sumf*out_s)>>(TM_FASTSCALE_SHIFT+TM_FASTSCALE_SHIFT))+out_zp);
            #endif
        #endif
    }
    return;
}

#if !TM_FASTSCALE
TM_INLINE void tm_postprocess_sum_npu(int idx, int chan, int n, sumtype_t* sums, btype_t* bs, int act, mtype_t* outp, sctype_t* scales, sctype_t out_s_inv, zptype_t out_zp)
#else
TM_INLINE void tm_postprocess_sum_npu(int idx,int chan, int n, sumtype_t* sums, btype_t* bs, int act, mtype_t* outp, int32_t* scales, int32_t out_s, zptype_t out_zp)
#endif
{
#if TM_NPU_CPU_COMPAT && TM_FASTSCALE
    uint32_t d=(uint32_t)scales[0];
    extern const uint32_t *edge_active_reciprocal;
    uint32_t reciprocal=edge_active_reciprocal?edge_active_reciprocal[idx]:d>1&&d<=INT32_MAX&&n>=32?(uint32_t)((UINT64_C(0x100000000)+d-1)/d):0;
    if(act==TM_ACT_RELU && d>0 && d<=INT32_MAX){
        for(int i=0;i<n;++i){
            int32_t s=tm_compat_i32((uint32_t)sums[i]<<TM_FASTSCALE_SHIFT);
            if(s<(int32_t)d){outp[i*chan+idx]=(mtype_t)out_zp;continue;}
            uint32_t q;
            if(reciprocal){q=(uint32_t)(((uint64_t)(uint32_t)s*reciprocal)>>32);if(q*d>(uint32_t)s)--q;}
            else q=(uint32_t)s/d;
            outp[i*chan+idx]=tm_compat_output((int32_t)q,out_s,out_zp);
        }
        return;
    }
#endif
    for(int i = 0; i < n; i++) {
        sumtype_t sum = sums[i];
        /* Raw NPU INT32 already includes the model's fused bias once. */
        (void)bs;
        #if !TM_FASTSCALE
            float sumf = sum* scales[0];
        #else 
            #if TM_NPU_CPU_COMPAT
                sumtype_t sumf = reciprocal?tm_npu_q8_recip(sum,d,reciprocal):tm_compat_q8(sum,scales[0]);
            #else
                sumtype_t sumf = (sum<<TM_FASTSCALE_SHIFT)/scales[0];
            #endif
        #endif
        switch(act){    //activation func
        case TM_ACT_RELU:
            sumf = sumf>0?sumf:0;
            break;
        case TM_ACT_RELU6:
            sumf = sumf>0?sumf:0;
        #if (!TM_FASTSCALE)
            sumf = sumf>6?6:sumf;
        #else
            sumf = sumf>(6<<TM_FASTSCALE_SHIFT)?(6<<TM_FASTSCALE_SHIFT):sumf;
        #endif
            break;
        default:
            break;
        }
        #if !TM_FASTSCALE
            outp[( i * chan ) + idx] = (mtype_t)(sumf*out_s_inv + out_zp);  //(mtype_t)((int)(sumf/out_s) + out_zp) //(mtype_t)((int)(sumf/out_s +0.5) + out_zp)
        #else 
            #if TM_NPU_CPU_COMPAT
                outp[(i*chan)+idx] = tm_compat_output(sumf, out_s, out_zp);
            #else
                outp[(i*chan)+idx] = (mtype_t)(((sumf*out_s)>>(TM_FASTSCALE_SHIFT+TM_FASTSCALE_SHIFT))+out_zp);
            #endif
        #endif
    }
    return;
}




#endif
