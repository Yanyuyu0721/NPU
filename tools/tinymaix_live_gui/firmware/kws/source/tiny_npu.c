#include "tiny_npu.h"

uint32_t edge_ppu_outscale,edge_ppu_layers,edge_ppu_channels;
volatile uint8_t sync_flag;
volatile uint8_t sync_tag;


NetworkProfileInfo net_pref_info = {0} ;

uint64_t pref_time;

// APPLICATION : matrix axb 
int npu_matrix_axb(void* inst_addr, int matrix_a_addr, int matrix_b_addr, int matrix_c_addr, int a_col,int a_row, int b_col, int b_row,uint8_t*exp_tag,uint32_t* inst_len) {
    uintptr_t origin_inst_addr = (uintptr_t)inst_addr;
    uint8_t rd_buf_id;
    uint32_t row_loop = (a_row + TINY_NPU_PE_NCOL- 1) / TINY_NPU_PE_NCOL; // outter loop
    uint32_t col_loop = (b_col + TINY_NPU_PE_NROW- 1) / TINY_NPU_PE_NROW; // inner  loop

    uint32_t matrix_a_addr_now = matrix_a_addr;
    uint32_t matrix_b_addr_now; 
    uint32_t matrix_c_addr_now = matrix_c_addr;

    rd_buf_id = NPU_REG_READ(TINY_NPU_REG_SYSTOLIC_STATUS) & 0x1;

    inst_addr =  gen_ppu_cfg_instr(inst_addr, 0, 0, 0, 0, 0);
    for(uint32_t row_loop_u = 0; row_loop_u < row_loop; ++row_loop_u) {
        uint32_t col_en = TINY_NPU_PE_NCOL-1;
        if(row_loop_u == row_loop-1) { // last row
            uint32_t rem = a_row % TINY_NPU_PE_NCOL;
            if(rem != 0) {
                col_en = rem - 1;
            }
        }
        
        // load weights rows(A rows)
        for(uint32_t tile_row = 0;tile_row < col_en + 1; ++tile_row) {
            inst_addr = gen_ppu_data_instr(inst_addr, matrix_c_addr_now, tile_row, b_col-1, 0,0);
            // inst_addr = gen_systolic_data_instr(inst_addr, WEIGHT, matrix_a_addr_now, tile_row, (a_col-1));

            matrix_c_addr_now = matrix_c_addr_now + b_col * 4; // PSUM_WIDTH is 32
            // matrix_a_addr_now = matrix_a_addr_now + a_col;
        }
        inst_addr = gen_systolic_batch_instr(inst_addr, WEIGHT_BATCH , matrix_a_addr_now, col_en ,(a_col-1)); 
        matrix_a_addr_now = matrix_a_addr_now +  (col_en + 1) * a_col;

        matrix_b_addr_now = matrix_b_addr;
        for(uint32_t col_loop_u = 0; col_loop_u < col_loop; ++col_loop_u) {
            uint32_t row_en = TINY_NPU_PE_NROW - 1; // 7

            if(col_loop_u == col_loop - 1) { // last column
                uint32_t rem = b_col % TINY_NPU_PE_NROW;
                if(rem != 0){
                    row_en = rem - 1;
                }
            }

            // load activation columns(B)
            // for(uint32_t tile_col = 0;tile_col < row_en + 1; ++tile_col) {
            //     inst_addr = gen_systolic_data_instr(inst_addr, ACTIVATION, matrix_b_addr_now, tile_col, (b_row-1));
            //     matrix_b_addr_now = matrix_b_addr_now + b_row;
            // }
            inst_addr = gen_systolic_batch_instr(inst_addr, ACTIVATION_BATCH , matrix_b_addr_now, row_en ,(b_row-1)); 
            matrix_b_addr_now = matrix_b_addr_now +  (row_en + 1) * b_row;

            inst_addr = gen_systolic_sync_instr(inst_addr,1);
            inst_addr = gen_systolic_calc_instr(inst_addr, row_en, col_en, rd_buf_id, 1, a_col-1);
        }
        rd_buf_id = (rd_buf_id & 0x1 ) ? 0 : 1;
    }

    inst_addr = gen_global_sync_instr(inst_addr, 2);
    __asm__ volatile("": : :"memory");

    *exp_tag  = 2;
    *inst_len = ((uintptr_t)inst_addr - origin_inst_addr)>>3; 

    return 0;
}

// APPLICATION : mac_engine 
static int npu_mac_generate(void* inst_addr, uint32_t a_addr, uint32_t w_addr, uint32_t bias[],uint8_t rescale_enable, uint32_t rescale[], uint32_t act_enable, uint32_t act_type,int32_t out_zp, uint32_t out_addr[],uint32_t insize,uint32_t outsize, uint32_t a_num, uint32_t w_num,uint8_t*exp_tag,uint32_t* inst_len) {
    uint8_t row_en;
    uint8_t col_en;
    uint32_t out_loop_times;
    uint32_t inn_loop_times;
    uint8_t  rd_buf_id = 0;
    uintptr_t origin_inst_addr = (uintptr_t)inst_addr;

    out_loop_times = (w_num + TINY_NPU_PE_NCOL- 1) / TINY_NPU_PE_NCOL; // outter loop
    inn_loop_times = (a_num + TINY_NPU_PE_NROW- 1) / TINY_NPU_PE_NROW; // inner  loop

    int col_en_last;
    int w_rem = w_num % TINY_NPU_PE_NCOL;
    col_en_last = (w_rem == 0) ? TINY_NPU_PE_NCOL-1 : w_rem-1; 

    int row_en_last;
    int a_rem = a_num % TINY_NPU_PE_NROW;
    row_en_last = (a_rem == 0) ? TINY_NPU_PE_NROW-1 : a_rem -1;

    int w_addr_cnt = w_addr; 
    int a_addr_cnt ; 

    const uint32_t MAX_INSIZE = 1024;

    inst_addr = act_type==7 ? gen_ppu_exact_cfg(inst_addr,1,act_enable,out_zp,edge_ppu_outscale) : gen_ppu_cfg_instr(inst_addr, 1, rescale_enable, act_enable, act_type, out_zp);
    uint8_t data_width = rescale_enable ? 1 : 4;
    for(uint32_t o_loop=0; o_loop < out_loop_times; ++o_loop){
        col_en = ( o_loop == out_loop_times-1 ) ? col_en_last:TINY_NPU_PE_NCOL- 1;
        for( int i = 0;i<col_en + 1;i++ ) {
            for (uint32_t out_offset = 0; out_offset < outsize; out_offset += MAX_INSIZE) {
                uint32_t chunk_outsize = outsize - out_offset;
                if (chunk_outsize > MAX_INSIZE) {
                    chunk_outsize = MAX_INSIZE;
                }

                uint32_t cur_out_addr = out_addr[o_loop * TINY_NPU_PE_NCOL + i] + out_offset* data_width;
                if(act_type==7) inst_addr=gen_ppu_exact_data(inst_addr,cur_out_addr,i,chunk_outsize-1,bias[o_loop*TINY_NPU_PE_NCOL+i],rescale[o_loop*TINY_NPU_PE_NCOL+i]);
                else if( rescale_enable )
                    inst_addr = gen_ppu_data_instr(inst_addr, cur_out_addr, i, (chunk_outsize - 1), bias[o_loop * TINY_NPU_PE_NCOL + i], rescale[o_loop * TINY_NPU_PE_NCOL + i]);
                else 
                    inst_addr = gen_ppu_data_instr(inst_addr, cur_out_addr, i, (chunk_outsize - 1), bias[o_loop * TINY_NPU_PE_NCOL + i], 0);
            }
        }

        if( insize <= MAX_INSIZE ) {
            inst_addr = gen_systolic_batch_instr(inst_addr, WEIGHT_BATCH, w_addr_cnt, col_en, (insize - 1)); 
            w_addr_cnt += (col_en + 1) * insize;

            a_addr_cnt = a_addr; 
            for( uint32_t i_loop=0; i_loop < inn_loop_times; ++i_loop) {
                row_en = ( i_loop == inn_loop_times-1) ? row_en_last:TINY_NPU_PE_NROW- 1;

                inst_addr = gen_systolic_batch_instr(inst_addr, ACTIVATION_BATCH , a_addr_cnt , row_en ,(insize-1)); 
                a_addr_cnt += (row_en + 1) * insize;

                inst_addr = gen_systolic_sync_instr(inst_addr,1);
                inst_addr = gen_systolic_calc_instr(inst_addr, row_en, col_en, rd_buf_id, 1, (insize-1));
            }
        } else {
            int w_addr_base = w_addr_cnt;
            a_addr_cnt = a_addr;
            for(uint32_t i_loop = 0; i_loop < inn_loop_times; ++i_loop) {
                row_en = (i_loop == inn_loop_times - 1) ? row_en_last : TINY_NPU_PE_NROW - 1;
                int a_addr_base = a_addr_cnt;

                for (uint32_t offset = 0; offset < insize; offset += MAX_INSIZE) {
                    uint32_t chunk_size = insize - offset;
                    if (chunk_size > MAX_INSIZE) {
                        chunk_size = MAX_INSIZE;
                    }

                    for (int i = 0; i < col_en + 1; i++) {
                        inst_addr = gen_systolic_data_instr(inst_addr, WEIGHT, w_addr_base + i * insize + offset, i, (chunk_size - 1));
                    }

                    for (int j = 0; j < row_en + 1; j++) {
                        inst_addr = gen_systolic_data_instr(inst_addr, ACTIVATION, a_addr_base + j * insize + offset, j, (chunk_size - 1));
                    }

                    inst_addr = gen_systolic_sync_instr(inst_addr, 1);

                    uint8_t calc_flag = (offset + MAX_INSIZE >= insize) ? 1 : 0; 
                    inst_addr = gen_systolic_calc_instr(inst_addr, row_en, col_en, rd_buf_id, calc_flag, (chunk_size - 1));  
                    /* Each weight DMA packet flips its column's write bank.
                     * Advance per K chunk so future loads use the other bank. */
                    rd_buf_id ^= 1U;
                }
                a_addr_cnt += (row_en + 1) * insize;
            }
            w_addr_cnt += (col_en + 1) * insize;

        }

        /* The small-K path loads weights once per output-channel tile. */
        if (insize <= MAX_INSIZE)
            rd_buf_id = (rd_buf_id & 0x1 ) ? 0 : 1;
    } 

    inst_addr = gen_global_sync_instr(inst_addr, 3);
    __asm__ volatile("": : :"memory");

    *exp_tag  = 3;
    *inst_len = ((uintptr_t)inst_addr - origin_inst_addr)>>3; 

    return 0;
}

// software: hwc im2col 
void sw_im2col_hwc(int8_t* in_data, int8_t* a_arr, int kw, int kh, int sx, int sy, 
                    int pad_top, int pad_bottom, int pad_left, int pad_right, int in_w, int in_h, int chi,
                    int out_h, int out_w, int in_zp) {

#if 0
    // raw
    uint32_t sidx = 0;

    for (int y = 0; y < out_h; ++y) {
        int src_y0 = y * sy - pad_top;
        
        for (int x = 0; x < out_w; ++x) {
            int src_x0 = x * sx - pad_left;
            
            for (int cc = 0; cc < chi; cc++) {
                for (int ky = 0; ky < kh; ky++) {
                    int src_y = src_y0 + ky;
                    for (int kx = 0; kx < kw; kx++) {
                        int src_x = src_x0 + kx;
                        
                        if (src_y >= 0 && src_y < in_h && src_x >= 0 && src_x < in_w) {
                            int in_idx = (src_y * in_w + src_x) * chi + cc;
                            a_arr[sidx++] = in_data[in_idx];
                        } else {
                            a_arr[sidx++] = (int8_t)in_zp; 
                        }
                    }
                }
            }
        }
    }
#else 
    (void)pad_bottom; (void)pad_right;
    // opt
    int32_t sidx = 0;

    if( chi < 16 ){
        for (int y = 0; y < out_h; ++y) {
            int src_y0 = y * sy - pad_top;
            
            for (int x = 0; x < out_w; ++x) {
                int src_x0 = x * sx - pad_left;
                
                if (src_y0 >= 0 && src_y0 + kh <= in_h && src_x0 >= 0 && src_x0 + kw <= in_w) {
                    for (int cc = 0; cc < chi; cc++) {
                        for (int ky = 0; ky < kh; ky++) {
                            int src_y = src_y0 + ky;
                            int row_offset = src_y * in_w; 
                            
                            for (int kx = 0; kx < kw; kx++) {
                                int src_x = src_x0 + kx;
                                int in_idx = (row_offset + src_x) * chi + cc;
                                a_arr[sidx++] = in_data[in_idx];
                            }
                        }
                    }
                } else {
                    for (int cc = 0; cc < chi; cc++) {
                        for (int ky = 0; ky < kh; ky++) {
                            int src_y = src_y0 + ky;
                            int y_valid = (src_y >= 0 && src_y < in_h); 
                            int row_offset = src_y * in_w;
                            
                            for (int kx = 0; kx < kw; kx++) {
                                int src_x = src_x0 + kx;
                                if (y_valid && src_x >= 0 && src_x < in_w) {
                                    int in_idx = (row_offset + src_x) * chi + cc;
                                    a_arr[sidx++] = in_data[in_idx];
                                } else {
                                    a_arr[sidx++] = (int8_t)in_zp; 
                                }
                            }
                        }
                    }
                }
            }
        }
    } else {
        for (int y = 0; y < out_h; ++y) {
            int src_y0 = y * sy - pad_top;
            
            for (int x = 0; x < out_w; ++x) {
                int src_x0 = x * sx - pad_left;
                
                if (src_y0 >= 0 && src_y0 + kh <= in_h && src_x0 >= 0 && src_x0 + kw <= in_w) {
                    for (int ky = 0; ky < kh; ky++) {
                        int src_y = src_y0 + ky;
                        int row_offset = src_y * in_w; 
                        
                        for (int kx = 0; kx < kw; kx++) {
                            int src_x = src_x0 + kx;
                            int in_idx = (row_offset + src_x) * chi;
                            memcpy(&a_arr[sidx], &in_data[in_idx], chi * sizeof(int8_t));
                            sidx += chi;
                        }
                    }
                } else {
                    for (int ky = 0; ky < kh; ky++) {
                        int src_y = src_y0 + ky;
                        int y_valid = (src_y >= 0 && src_y < in_h); 
                        int row_offset = src_y * in_w;
                        
                        for (int kx = 0; kx < kw; kx++) {
                            int src_x = src_x0 + kx;
                            if (y_valid && src_x >= 0 && src_x < in_w) {
                                int in_idx = (row_offset + src_x) * chi;
                                memcpy(&a_arr[sidx], &in_data[in_idx], chi * sizeof(int8_t));
                            } else {
                                memset(&a_arr[sidx], in_zp, chi * sizeof(int8_t)); 
                            }
                            sidx += chi;
                        }
                    }
                }
            }
        }

    }
#endif
}

void sw_im2col_1x1_hwc(int8_t* in_data, int8_t* a_arr, int kw, int kh, int sx, int sy, 
                           int pad_top, int pad_bottom, int pad_left, int pad_right, 
                           int in_w, int in_h, int chi, int out_h, int out_w, int in_zp) {
    
    (void)kw; (void)kh;
    int pad_flag = (pad_top != 0 || pad_bottom != 0 || pad_left != 0 || pad_right != 0);
    int32_t sidx = 0;

    if (pad_flag) { 
        for (int y = 0; y < out_h; ++y) {
            int src_y = y * sy - pad_top;
            
            int y_valid = (src_y >= 0 && src_y < in_h);
            int row_offset = src_y * in_w;

            for (int x = 0; x < out_w; ++x) {
                int src_x = x * sx - pad_left;
                
                if (y_valid && src_x >= 0 && src_x < in_w) {
                    int in_idx = (row_offset + src_x) * chi;
                    memcpy(&a_arr[sidx], &in_data[in_idx], chi * sizeof(int8_t));
                } else {
                    memset(&a_arr[sidx], in_zp, chi * sizeof(int8_t));
                }
                sidx += chi;
            }
        }
    } else {
        for (int y = 0; y < out_h; ++y) {
            int src_y = y * sy;
            int row_offset = src_y * in_w;
        
            for (int x = 0; x < out_w; ++x) {
                int src_x = x * sx;
                int in_idx = (row_offset + src_x) * chi;
            
                memcpy(&a_arr[sidx], &in_data[in_idx], chi * sizeof(int8_t));
                sidx += chi;
            }
        }
    }
}

// software: weight pack
void sw_pack_weight(int8_t* w_src, int8_t* w_dst, int out_c, int in_c, int maxk) {

#if 0
    // raw
    int weight_len = maxk * in_c;
    for (int i = 0; i < out_c; i++) {     
        for (int j = 0; j < weight_len; j++) {
            *(w_dst++) = *(w_src + i * weight_len + j);
        }
    }
#else
    if (in_c < 16) {
        uint32_t total_bytes = out_c * in_c * maxk;
        memcpy(w_dst, w_src, total_bytes * sizeof(int8_t));
    }  else {
        int didx = 0;
        for (int i = 0; i < out_c; i++) {
            int base = i * maxk * in_c;
            for (int k = 0; k < maxk; k++)
                for (int c = 0; c < in_c; c++)
                    w_dst[didx++] = w_src[base + c * maxk + k];
        }  
    }
#endif
}

#include "npu_mac_adapter.inc"
