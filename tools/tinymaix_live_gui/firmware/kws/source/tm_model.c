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
#include "tinymaix.h"
#include "tiny_npu.h"
extern tm_err_t tml_gap_fast(tm_mat_t*,tm_mat_t*,sctype_t,zptype_t,sctype_t,zptype_t);

#if TM_ENABLE_LOGGING && TM_ENABLE_DIAGNOSTICS

#define TM_DIAG_FIRST_VALUES 16

static uint32_t tm_diag_hash_bytes(const void *ptr, int len)
{
    const uint8_t *data = (const uint8_t *)ptr;
    uint32_t hash = 2166136261u;

    for (int i = 0; i < len; ++i) {
        hash ^= data[i];
        hash *= 16777619u;
    }

    return hash;
}

static void tm_diag_print_i8_buffer(const char *tag, int layer, const mtype_t *data, int len)
{
    long long sum = 0;
    unsigned long long abs_sum = 0;
    unsigned long zero_count = 0;
    unsigned long neg_count = 0;
    unsigned long pos_count = 0;
    int min_v = 0;
    int max_v = 0;

    if (data == NULL || len <= 0) {
        TM_PRINTF("DIAG %s L%d len=%d data=NULL\r\n", tag, layer, len);
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

    TM_PRINTF("DIAG %s L%d len=%d sum=%lld abs=%llu min=%d max=%d zero=%lu neg=%lu pos=%lu hash=0x%08lx\r\n",
        tag, layer, len, sum, abs_sum, min_v, max_v,
        zero_count, neg_count, pos_count,
        (unsigned long)tm_diag_hash_bytes(data, len));

    int first_n = (len < TM_DIAG_FIRST_VALUES) ? len : TM_DIAG_FIRST_VALUES;
    TM_PRINTF("DIAG %s L%d first%d:", tag, layer, first_n);
    for (int i = 0; i < first_n; ++i) {
        TM_PRINTF(" %d", (int)data[i]);
    }
    TM_PRINTF("\r\n");

    TM_PRINTF("DIAG %s L%d samples:", tag, layer);
    int sample_idx[8] = {0, 1, 2, 3, len / 4, len / 2, (len * 3) / 4, len - 1};
    for (int i = 0; i < 8; ++i) {
        int idx = sample_idx[i];
        if (idx >= 0 && idx < len) {
            TM_PRINTF(" [%d]=%d", idx, (int)data[idx]);
        }
    }
    TM_PRINTF("\r\n");
}

static void tm_diag_print_u8_buffer(const char *tag, int layer, const uint8_t *data, int len)
{
    unsigned long long sum = 0;
    int min_v = 0;
    int max_v = 0;

    if (data == NULL || len <= 0) {
        TM_PRINTF("DIAG %s L%d len=%d data=NULL\r\n", tag, layer, len);
        return;
    }

    min_v = (int)data[0];
    max_v = (int)data[0];
    for (int i = 0; i < len; ++i) {
        int v = (int)data[i];
        sum += (unsigned long long)v;
        if (v < min_v) min_v = v;
        if (v > max_v) max_v = v;
    }

    TM_PRINTF("DIAG %s L%d len=%d sum=%llu min=%d max=%d hash=0x%08lx\r\n",
        tag, layer, len, sum, min_v, max_v,
        (unsigned long)tm_diag_hash_bytes(data, len));

    int first_n = (len < TM_DIAG_FIRST_VALUES) ? len : TM_DIAG_FIRST_VALUES;
    TM_PRINTF("DIAG %s L%d first%d:", tag, layer, first_n);
    for (int i = 0; i < first_n; ++i) {
        TM_PRINTF(" %u", (unsigned)data[i]);
    }
    TM_PRINTF("\r\n");
}

static void tm_diag_print_i32_buffer(const char *tag, int layer, const btype_t *data, int len)
{
    long long sum = 0;
    long min_v = 0;
    long max_v = 0;

    if (data == NULL || len <= 0) {
        TM_PRINTF("DIAG %s L%d len=%d data=NULL\r\n", tag, layer, len);
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

    TM_PRINTF("DIAG %s L%d len=%d sum=%lld min=%ld max=%ld hash=0x%08lx\r\n",
        tag, layer, len, sum, min_v, max_v,
        (unsigned long)tm_diag_hash_bytes(data, len * (int)sizeof(btype_t)));

    int first_n = (len < 8) ? len : 8;
    TM_PRINTF("DIAG %s L%d first%d:", tag, layer, first_n);
    for (int i = 0; i < first_n; ++i) {
        TM_PRINTF(" %ld", (long)data[i]);
    }
    TM_PRINTF("\r\n");
}

static void tm_diag_print_scale_buffer(const char *tag, int layer, const sctype_t *data, int len)
{
    if (data == NULL || len <= 0) {
        TM_PRINTF("DIAG %s L%d len=%d data=NULL\r\n", tag, layer, len);
        return;
    }

    int first_n = (len < 8) ? len : 8;
    TM_PRINTF("DIAG %s L%d len=%d first%d:", tag, layer, len, first_n);
    for (int i = 0; i < first_n; ++i) {
        TM_PRINTF(" %.9g", (double)data[i]);
    }
    TM_PRINTF("\r\n");
}

static void tm_diag_print_mat(const char *tag, int layer, const tm_mat_t *mat)
{
    int len = mat->h * mat->w * mat->c;
    TM_PRINTF("DIAG %s L%d dims=%ux%ux%u ptr=0x%08lx\r\n",
        tag, layer, mat->h, mat->w, mat->c, (unsigned long)(uintptr_t)mat->data);
    tm_diag_print_i8_buffer(tag, layer, mat->data, len);
}

#else

#define tm_diag_print_i8_buffer(...)    ((void)0)
#define tm_diag_print_u8_buffer(...)    ((void)0)
#define tm_diag_print_i32_buffer(...)   ((void)0)
#define tm_diag_print_scale_buffer(...) ((void)0)
#define tm_diag_print_mat(...)          ((void)0)

#endif

//load model
//mdl: model handle; bin: model bin buf; buf: main buf for middle output; cb: layer callback; 
//in: return input mat, include buf addr; //you can ignore it if use static buf
tm_err_t TM_WEAK tm_load  (tm_mdl_t* mdl, const uint8_t* bin, uint8_t*buf, tm_cb_t cb, tm_mat_t* in)
{
    tm_mdlbin_t* mdl_bin = (tm_mdlbin_t*)bin;
    if(mdl_bin->magic != TM_MDL_MAGIC)   return TM_ERR_MAGIC;   //FIXME: big-endian not compatible
    if(mdl_bin->mdl_type != TM_MDL_TYPE) return TM_ERR_MDLTYPE;
    mdl->b          = mdl_bin;
    mdl->cb         = (void*)cb;
    if(buf == NULL) {
        mdl->buf        = (uint8_t*)tm_malloc(mdl->b->buf_size);
        if(mdl->buf == NULL) return TM_ERR_OOM;
        mdl->main_alloc = 1;
	} else {
        mdl->buf = buf;
        mdl->main_alloc = 0;
    }
    if(mdl->b->sub_size > 0) {
        mdl->subbuf = (uint8_t*)tm_malloc(mdl->b->sub_size);
        if(mdl->subbuf == NULL) return TM_ERR_OOM;
    } else mdl->subbuf = NULL;
    mdl->layer_i    = 0;
    mdl->layer_body = mdl->b->layers_body;
    memcpy((void*)in, (void*)mdl->b->in_dims, sizeof(tm_mat_t));
    in->data = (mtype_t*)mdl->buf; //input at 0 oft
    TM_PRINTF("DIAG MODEL magic=0x%08lx type=%u out_deq=%u input_cnt=%u output_cnt=%u layer_cnt=%u buf_size=%lu sub_size=%lu\r\n",
        (unsigned long)mdl->b->magic,
        (unsigned)mdl->b->mdl_type,
        (unsigned)mdl->b->out_deq,
        (unsigned)mdl->b->input_cnt,
        (unsigned)mdl->b->output_cnt,
        (unsigned)mdl->b->layer_cnt,
        (unsigned long)mdl->b->buf_size,
        (unsigned long)mdl->b->sub_size);
    TM_PRINTF("DIAG MODEL in_dims=%ux%ux%u out_dims=%ux%ux%u mdl_buf=0x%08lx main_alloc=%u\r\n",
        mdl->b->in_dims[1], mdl->b->in_dims[2], mdl->b->in_dims[3],
        mdl->b->out_dims[1], mdl->b->out_dims[2], mdl->b->out_dims[3],
        (unsigned long)(uintptr_t)mdl->buf,
        (unsigned)mdl->main_alloc);
    return TM_OK;
}
 
//remove model
void TM_WEAK tm_unload(tm_mdl_t* mdl)
{
    if(mdl->main_alloc) tm_free(mdl->buf);
    if(mdl->subbuf) tm_free(mdl->subbuf);
    return;
}
 
//preprocess data input
tm_err_t TM_WEAK tm_preprocess(tm_mdl_t* mdl, tm_pp_t pp_type, tm_mat_t* in, tm_mat_t* out)
{
    tml_head_t* l0h = (tml_head_t*)mdl->b->layers_body;
    sctype_t in_s = l0h->in_s;
    zptype_t in_zp= l0h->in_zp;
    int in_size = in->h*in->w*in->c;
    if (pp_type == TMPP_UINT2INT) {
        tm_diag_print_u8_buffer("PREPROCESS_RAW_U8", -1, (const uint8_t *)in->data, in_size);
    }
    switch(pp_type){
#if (TM_MDL_TYPE == TM_MDL_INT8)||(TM_MDL_TYPE == TM_MDL_INT16)
    case TMPP_FP2INT:
        for(int i=0; i<in_size; i++)
            out->data[i] = (mtype_t)(in->dataf[i]/in_s + in_zp);
        break;
    case TMPP_UINT2INT:
        for(int i=0; i<in_size; i++)
            out->data[i] = ((mtype_t)(((uint8_t*)(in->data))[i]-128))<<UINT2INT_SHIFT;
        break;
#else
//     case TMPP_UINT2FP01:
//         for(int i=0; i<in_size; i++)
//             out->data[i] = (((uint8_t*)(in->data))[i])/255.0f;
//         break;
//     case TMPP_UINT2FPN11:
//         for(int i=0; i<in_size; i++)
//             out->data[i] = ((((uint8_t*)(in->data))[i])-128)/128.0f;
//         break;
#endif
    default:    //don't do anything
        out->data = in->data;
        break;
    }
    TM_PRINTF("DIAG PREPROCESS pp_type=%d in_s=%.9g in_zp=%ld out_ptr=0x%08lx\r\n",
        pp_type, (double)in_s, (long)in_zp, (unsigned long)(uintptr_t)out->data);
    tm_diag_print_i8_buffer("PREPROCESS_OUT_I8", -1, out->data, in_size);
    return TM_OK;
}

//run model
//mdl: model handle; in: input mat; out: output mat
tm_err_t TM_WEAK tm_run(tm_mdl_t* mdl, tm_mat_t* in, tm_mat_t* out)
{
    if (mdl->b->layer_cnt > MAX_LAYERS) return TM_ERR_UNSUPPORT;
    net_pref_info.total_layers = 0;
    tm_mat_t _in, _in1, _out;
    tm_err_t res = TM_OK;
    int out_idx = 0;
    memcpy((void*)&_in, (void*)in, sizeof(tm_mat_t));       
    mdl->layer_body = mdl->b->layers_body;
    tm_diag_print_mat("RUN_INPUT", -1, &_in);
    for(mdl->layer_i = 0; mdl->layer_i < mdl->b->layer_cnt; mdl->layer_i++){

        TM_PRINTF("layer: %d\n",mdl->layer_i);

        net_pref_info.layers[net_pref_info.total_layers].layer_id = net_pref_info.total_layers ;
        TM_GET_TICK(pref_time); 
        net_pref_info.layers[net_pref_info.total_layers].start_time = pref_time;

        tml_head_t* h = (tml_head_t*)(mdl->layer_body);
        if (mdl->layer_i >= MAX_LAYERS) return TM_ERR_UNSUPPORT;
#if NPU_PLATFORM != 0
        npu_set_layer(mdl->layer_i, h, sizeof(*h));
#endif

        if(mdl->layer_i>0) {
            _in.data  = (mtype_t *)(mdl->buf + h->in_oft);
            memcpy((void*)&_in, (void*)(h->in_dims), sizeof(uint16_t)*4);
        }
        _out.data = (mtype_t *)(mdl->buf + h->out_oft);
        memcpy((void*)&_out, (void*)(h->out_dims), sizeof(uint16_t)*4);
        TM_PRINTF("DIAG L%d HEAD type=%u is_out=%u size=%lu in_oft=%lu out_oft=%lu in_s=%.9g in_zp=%ld out_s=%.9g out_zp=%ld\r\n",
            mdl->layer_i,
            (unsigned)h->type,
            (unsigned)h->is_out,
            (unsigned long)h->size,
            (unsigned long)h->in_oft,
            (unsigned long)h->out_oft,
            (double)h->in_s,
            (long)h->in_zp,
            (double)h->out_s,
            (long)h->out_zp);
        tm_diag_print_mat("LAYER_IN", mdl->layer_i, &_in);
        switch(h->type){
        case TML_DWCONV2D:{ 
            tml_conv2d_dw_t* l = (tml_conv2d_dw_t*)(mdl->layer_body);
            #if NPU_PLATFORM == 0
            res = tml_conv2d_dwconv2d(&_in, &_out, (wtype_t*)(mdl->layer_body + l->w_oft), (btype_t*)(mdl->layer_body + l->b_oft), \
                l->kernel_w, l->kernel_h, l->stride_w, l->stride_h, l->dilation_w, l->dilation_h, \
                l->act, l->pad[0], l->pad[1], l->pad[2], l->pad[3], l->depth_mul, \
                (sctype_t*)(mdl->layer_body + l->ws_oft), h->in_s, h->in_zp, h->out_s, h->out_zp); 
            #else
            res = tml_dwconv2d_npu(&_in, &_out, (wtype_t*)(mdl->layer_body + l->w_oft), (btype_t*)(mdl->layer_body + l->b_oft), \
                l->kernel_w, l->kernel_h, l->stride_w, l->stride_h, l->dilation_w, l->dilation_h, \
                l->act, l->pad[0], l->pad[1], l->pad[2], l->pad[3], l->depth_mul, \
                (sctype_t*)(mdl->layer_body + l->ws_oft), h->in_s, h->in_zp, h->out_s, h->out_zp); 

            #endif
            break;
         }
         case TML_CONV2D: {
            tml_conv2d_dw_t* l = (tml_conv2d_dw_t*)(mdl->layer_body);
            
            // 棰勮绠楁寚閽堜互鎻愰珮鍙鎬�
            wtype_t* weights = (wtype_t*)(mdl->layer_body + l->w_oft);
            btype_t* bias    = (btype_t*)(mdl->layer_body + l->b_oft);
            sctype_t* scale  = (sctype_t*)(mdl->layer_body + l->ws_oft);
            int npu_insize = l->kernel_w * l->kernel_h * _in.c;
            int weight_len = l->kernel_w * l->kernel_h * _in.c * _out.c;

            TM_PRINTF("L%d Conv2D: in=%ux%ux%u out=%ux%ux%u k=%ux%u s=%u act=%u insize=%d\n",
                mdl->layer_i,
                _in.h, _in.w, _in.c,
                _out.h, _out.w, _out.c,
                l->kernel_w, l->kernel_h, l->stride_w, l->act, npu_insize);
            TM_PRINTF("DIAG L%d CONV pad=%u,%u,%u,%u dil=%u,%u depth_mul=%lu ws_oft=%lu w_oft=%lu b_oft=%lu weight_len=%d path=%s\r\n",
                mdl->layer_i,
                l->pad[0], l->pad[1], l->pad[2], l->pad[3],
                l->dilation_w, l->dilation_h,
                (unsigned long)l->depth_mul,
                (unsigned long)l->ws_oft,
                (unsigned long)l->w_oft,
                (unsigned long)l->b_oft,
                weight_len,
                (NPU_PLATFORM == 0) ? "CPU" : ((npu_insize > 1024) ? "CPU_FALLBACK" : "NPU"));
            tm_diag_print_scale_buffer("WEIGHT_SCALE", mdl->layer_i, scale, _out.c);
            tm_diag_print_i8_buffer("WEIGHT_I8", mdl->layer_i, weights, weight_len);
            tm_diag_print_i32_buffer("BIAS_I32", mdl->layer_i, bias, _out.c);

            #if NPU_PLATFORM == 0
                // 鎯呭喌 1: 缂栬瘧鏃舵湭寮�鍚� NPU锛屽己鍒朵娇鐢� CPU
                res = tml_conv2d_dwconv2d(&_in, &_out, weights, bias,
                    l->kernel_w, l->kernel_h, l->stride_w, l->stride_h,
                    l->dilation_w, l->dilation_h, l->act,
                    l->pad[0], l->pad[1], l->pad[2], l->pad[3],
                    l->depth_mul, scale,
                    h->in_s, h->in_zp, h->out_s, h->out_zp);
            #else
                // 鎯呭喌 2: 缂栬瘧鏃跺紑鍚簡 NPU
                if (npu_insize > 1024) {
                    TM_PRINTF("L%d CPU fallback: NPU insize %d > 1024\n", mdl->layer_i, npu_insize);
                    res = tml_conv2d_dwconv2d(&_in, &_out, weights, bias,
                        l->kernel_w, l->kernel_h, l->stride_w, l->stride_h,
                        l->dilation_w, l->dilation_h, l->act,
                        l->pad[0], l->pad[1], l->pad[2], l->pad[3],
                        l->depth_mul, scale,
                        h->in_s, h->in_zp, h->out_s, h->out_zp);
                } else {
                    res = tml_conv2d_npu(&_in, &_out, weights, bias,
                        l->kernel_w, l->kernel_h, l->stride_w, l->stride_h,
                        l->dilation_w, l->dilation_h, l->act,
                        l->pad[0], l->pad[1], l->pad[2], l->pad[3],
                        l->depth_mul, scale,
                        h->in_s, h->in_zp, h->out_s, h->out_zp);
                }
                
            #endif
            break;
        }
        case TML_GAP: {
            // TM_PRINTF("enter tml_gap\n");
            tml_gap_t* l = (tml_gap_t*)(mdl->layer_body);
            #if NPU_PLATFORM == 0
            res = tml_gap(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);
#else
            res = tml_gap_fast(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);
#endif
            break;}
        case TML_FC: {
            // TM_PRINTF("enter tml_fc\n");
            tml_fc_t* l = (tml_fc_t*)(mdl->layer_body);
            #if NPU_PLATFORM == 0
            res = tml_fc(&_in, &_out, (wtype_t*)(mdl->layer_body + l->w_oft), (btype_t*)(mdl->layer_body + l->b_oft), \
                (sctype_t*)(mdl->layer_body + l->ws_oft), h->in_s, h->in_zp, h->out_s, h->out_zp);
            #else
            res = tml_fc_npu(&_in, &_out, (wtype_t*)(mdl->layer_body + l->w_oft), (btype_t*)(mdl->layer_body + l->b_oft), \
                (sctype_t*)(mdl->layer_body + l->ws_oft), h->in_s, h->in_zp, h->out_s, h->out_zp);
            #endif
            break;}
        case TML_SOFTMAX: {
            // TM_PRINTF("enter tml_softmax\n");
            tml_softmax_t* l = (tml_softmax_t*)(mdl->layer_body);
            res = tml_softmax(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);
            break; }
        case TML_RESHAPE: {
            tml_reshape_t* l = (tml_reshape_t*)(mdl->layer_body);
            res = tml_reshape(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);
            break; }
        case TML_ADD: {
            // TM_PRINTF("enter tml_add\n");
            tml_add_t* l = (tml_add_t*)(mdl->layer_body);
            memcpy((void*)&_in1, (void*)(h->in_dims), sizeof(uint16_t)*4);
            _in1.data = (mtype_t *)(mdl->buf + l->in_oft1);
            res = tml_add(&_in, &_in1, &_out, h->in_s, h->in_zp, l->in_s1, l->in_zp1, h->out_s, h->out_zp);
            break; }
        default:
            res = TM_ERR_LAYERTYPE;
            break;
        }
#if NPU_PLATFORM != 0
        /* Preflight unsupported operations have not launched this request.
         * Hardware errors/timeouts are never hidden by CPU retries. */
        if (res == TM_ERR_UNSUPPORT) {
            if (h->type == TML_CONV2D || h->type == TML_DWCONV2D) {
                tml_conv2d_dw_t *l=(tml_conv2d_dw_t*)mdl->layer_body;
                res=tml_conv2d_dwconv2d(&_in,&_out,(wtype_t*)(mdl->layer_body+l->w_oft),
                    (btype_t*)(mdl->layer_body+l->b_oft),l->kernel_w,l->kernel_h,l->stride_w,l->stride_h,
                    l->dilation_w,l->dilation_h,l->act,l->pad[0],l->pad[1],l->pad[2],l->pad[3],
                    l->depth_mul,(sctype_t*)(mdl->layer_body+l->ws_oft),h->in_s,h->in_zp,h->out_s,h->out_zp);
            } else if(h->type == TML_FC) {
                tml_fc_t *l=(tml_fc_t*)mdl->layer_body;
                res=tml_fc(&_in,&_out,(wtype_t*)(mdl->layer_body+l->w_oft),(btype_t*)(mdl->layer_body+l->b_oft),
                    (sctype_t*)(mdl->layer_body+l->ws_oft),h->in_s,h->in_zp,h->out_s,h->out_zp);
            }
        }
#endif
        if(res != TM_OK) {
            TM_PRINTF("layer %d failed: type=%u res=%d\n", mdl->layer_i, h->type, res);
            return res;
        }
        tm_diag_print_mat("LAYER_OUT", mdl->layer_i, &_out);
        if(mdl->cb) { tm_err_t cb_rc=((tm_cb_t)mdl->cb)(mdl,h); if(cb_rc!=TM_OK)return cb_rc; }
        if(h->is_out) {
            memcpy((void*)(&out[out_idx]), (void*)(&(h->out_dims)), sizeof(uint16_t)*4);
            if(mdl->b->out_deq == 0 || TM_MDL_TYPE == TM_MDL_FP32) //fp32 do not need deq
                out[out_idx].data = (mtype_t*)(TML_GET_OUTPUT(mdl, h));
            else {
                int out_size = h->out_dims[1]*h->out_dims[2]*h->out_dims[3];
                float* outf = (float*)(TM_ALIGN(TML_GET_OUTPUT(mdl, h) + out_size));
                for(int i=0; i<out_size; i++) //do dequant
                    outf[i] = TML_DEQUANT(h, (TML_GET_OUTPUT(mdl, h))[i]);
                out[out_idx].dataf = outf;
            }
            out_idx += 1;
        }
        mdl->layer_body += (h->size);

        TM_GET_TICK(pref_time); 
        net_pref_info.layers[net_pref_info.total_layers].end_time = pref_time;
        net_pref_info.total_layers  ++ ; 
    }
    return TM_OK;
}
