/*-----------------------------------------
file name  : tiny_npu.h
created    : 2026/01/16 20:13:04
modified   : 2026-03-20 12:35:29
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
#ifndef TINY_NPU_H
#define TINY_NPU_H
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "npu_runtime.h"
#include "vex_platform.h"
/* Both the real A7 and its RTL simulation expose CPU BRAM at A0000000,
 * while the NPU data bus addresses that BRAM from zero. */
#define EDGE_DMA_ADDR(a) vex_dma_addr((uintptr_t)(uint32_t)(a))
#ifndef EDGE_HOST_TEST
#include "xil_io.h"
#endif

#define TM_ALIGN8(addr)        (((addr) + 63) & ~63)

// time record 
typedef struct {
    uint32_t layer_id;       
    uint64_t start_time;
    uint64_t end_time;

    uint64_t ext_start_time;
    uint64_t ext_end_time;
} LayerTimeRecord;

#define MAX_LAYERS 256
typedef struct {
    uint32_t total_layers;             
    LayerTimeRecord layers[MAX_LAYERS];
} NetworkProfileInfo;

extern NetworkProfileInfo net_pref_info;
extern uint64_t pref_time;

#define WEIGHT           (0)
#define ACTIVATION       (1)
#define WEIGHT_BATCH     (3)
#define ACTIVATION_BATCH (4)

#define TINY_NPU_PE_NCOL 8
#define TINY_NPU_PE_NROW 8

//--------- register 
#define TINY_NPU_REG_BASE_ADDR       EDGE_NPU_MMIO_BASE
#define TINY_NPU_REG_CMD             (TINY_NPU_REG_BASE_ADDR + 0x00)
#define TINY_NPU_REG_INTR_STATUS     (TINY_NPU_REG_BASE_ADDR + 0x08)
#define TINY_NPU_REG_INTR_RAW_STATUS (TINY_NPU_REG_BASE_ADDR + 0x10)
#define TINY_NPU_REG_INTR_MASK       (TINY_NPU_REG_BASE_ADDR + 0x18)
#define TINY_NPU_REG_INTR_CLEAR      (TINY_NPU_REG_BASE_ADDR + 0x20)
#define TINY_NPU_REG_INTR_FORCE      (TINY_NPU_REG_BASE_ADDR + 0x28)
#define TINY_NPU_REG_TINY_NPU_STATUS (TINY_NPU_REG_BASE_ADDR + 0x30)
#define TINY_NPU_REG_SYSTOLIC_STATUS (TINY_NPU_REG_BASE_ADDR + 0x38)
#define TINY_NPU_REG_CDMA_STATUS     (TINY_NPU_REG_BASE_ADDR + 0x40)

#ifndef EDGE_HOST_TEST
#define NPU_REG_READ(addr) Xil_In32(addr)
#define NPU_REG_WRITE(addr,val) Xil_Out32(addr,val)
#else
#define NPU_REG_READ(addr) (0U)
#define NPU_REG_WRITE(addr,val) ((void)(addr),(void)(val))
#endif

// =================================================================
// Systolic Unit Instruction 
// =================================================================
static inline void* gen_systolic_data_instr(void* inst_addr, const uint8_t op_type, int addr, int dest, int len) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[0] |= 1;
    instr_data[0] |= ((uint32_t)op_type & 0x1F) << 4;
    
    uint32_t u_addr = EDGE_DMA_ADDR(addr);
    instr_data[0] |= (u_addr << 9);   
    instr_data[1] |= (u_addr >> 23); 

    instr_data[1] |= ((uint32_t)dest & 0x1F) << 9;
    instr_data[1] |= ((uint32_t)len & 0xFFF) << 14;



    return (void*)(instr_data + 2);
}

static inline void* gen_systolic_calc_instr(void* inst_addr, int row_en, int col_en, int rd_buf_id, int last_en, int calc_len) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0; 
    instr_data[0] |= 1;
    instr_data[0] |= (2 << 4);
    instr_data[0] |= ((uint32_t)row_en & 0xF) << 9;
    instr_data[0] |= ((uint32_t)col_en & 0xF) << 13;
    instr_data[0] |= ((uint32_t)rd_buf_id & 0x1) << 17;
    instr_data[0] |= ((uint32_t)last_en & 0x1) << 18;
    instr_data[0] |= ((uint32_t)calc_len & 0xFFF) << 19;



    return (void*)(instr_data + 2);
}

static inline void* gen_systolic_batch_instr(void* inst_addr, const uint8_t op_type, int addr, int batch, int len) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[0] |= 1;
    instr_data[0] |= ((uint32_t)op_type & 0x1F) << 4;
    uint32_t u_addr = EDGE_DMA_ADDR(addr);
    instr_data[0] |= (u_addr << 9); 
    instr_data[1] |= (u_addr >> 23); 
    instr_data[1] |= ((uint32_t)batch & 0x1F) << 9;
    instr_data[1] |= ((uint32_t)len & 0xFFF) << 14;



    return (void*)(instr_data + 2);
}

static inline void* gen_systolic_sync_instr(void* inst_addr, int tag) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[0] |= 1;
    instr_data[0] |= (0x1F << 4);
    uint32_t u_tag = (uint32_t)tag & 0xFF; 
    instr_data[1] |= (u_tag << 24);



    return (void*)(instr_data + 2);
}

// =================================================================
// CDMA Instruction
// =================================================================
static inline void* gen_cdma_instr(void* inst_addr, int src_addr, int dest_addr, int len) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[2] = 0;
    instr_data[3] = 0;
    instr_data[0] |= 2;
    uint32_t u_dest = (uint32_t)dest_addr;
    instr_data[0] |= (u_dest & 0x7FFFFF) << 9;
    instr_data[1] |= (u_dest >> 23) & 0x1FF;
    uint32_t u_src = (uint32_t)src_addr;
    instr_data[1] |= (u_src & 0x7FFFFF) << 9;
    instr_data[2] |= (u_src >> 23) & 0x1FF;
    uint32_t u_len = (uint32_t)len;
    instr_data[2] |= (u_len & 0xFFF) << 9;



    return (void*)(instr_data + 4);
}

// =================================================================
// PPU Instruction
// =================================================================
static inline void* gen_ppu_cfg_instr(void* inst_addr, int bias_en, int rescale_en, int act_en, int act_type, int out_zp) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[0] |= 3;
    instr_data[0] |= ((uint32_t)bias_en & 0x1) << 9;
    instr_data[0] |= ((uint32_t)rescale_en & 0x1) << 10;
    instr_data[0] |= ((uint32_t)act_en & 0x1) << 11;
    instr_data[0] |= ((uint32_t)act_type & 0x7) << 12;
    instr_data[0] |= ((uint32_t)out_zp & 0x1FF) << 15;


    return (void*)(instr_data + 2);
}

static inline void* gen_ppu_data_instr(void* inst_addr, int addr, int dest, int len, int bias, int rescale) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[2] = 0;
    instr_data[3] = 0;
    instr_data[0] |= 3;
    instr_data[0] |= (1 << 4);
    uint32_t u_addr = EDGE_DMA_ADDR(addr);
    instr_data[0] |= (u_addr & 0x7FFFFF) << 9;
    instr_data[1] |= (u_addr >> 23) & 0x1FF;
    uint32_t u_dest = (uint32_t)dest;
    instr_data[1] |= (u_dest & 0x1F) << 9;
    uint32_t u_len = (uint32_t)len;
    instr_data[1] |= (u_len & 0xFFF) << 14;
    uint32_t u_bias = (uint32_t)bias;
    instr_data[1] |= (u_bias & 0x3F) << 26; 
    instr_data[2] |= (u_bias >> 6) & 0x3FFFFFF;
    uint32_t u_rescale = (uint32_t)rescale;
    instr_data[2] |= (u_rescale & 0x3F) << 26; 
    instr_data[3] |= (u_rescale >> 6) & 0xFFF;


    return (void*)(instr_data + 4);
}

// Exact Q8 extension; host verifies the routed hardware image receipt.
extern uint32_t edge_ppu_outscale,edge_ppu_layers;
static inline void* gen_ppu_exact_cfg(void* p,int bias,int relu,int zp,uint32_t scale){
 uint32_t *q=p;gen_ppu_cfg_instr(p,bias,1,relu,7,zp);
 q[0]|=(scale&255U)<<24;q[1]|=(scale>>8)&255U;return q+2;
}
static inline void* gen_ppu_exact_data(void* p,int addr,int dest,int len,int bias,uint32_t d){
 uint32_t reciprocal=UINT32_MAX/d+1U;
 uint64_t packed=((uint64_t)reciprocal<<16)|d;
 uint32_t *q=p;gen_ppu_data_instr(p,addr,dest,len,bias,(uint32_t)packed);
 q[3]=(uint32_t)(packed>>6);return q+4;
}

// =================================================================
// SYNC Instruction
// =================================================================
static inline void* gen_global_sync_instr(void* inst_addr, int tag) {
    uint32_t* instr_data = (uint32_t*)inst_addr;
    instr_data[0] = 0;
    instr_data[1] = 0;
    instr_data[0] |= 0xF;
    uint32_t u_tag = (uint32_t)tag;
    instr_data[1] |= (u_tag & 0xFF) << 24;


    return (void*)(instr_data + 2);
}



extern volatile uint8_t sync_flag;
extern volatile uint8_t sync_tag;

//#define CPU_SHARED_MEM(x) (0xa0080000 + (x) )
//#define NPU_SHARED_MEM(x) (0x80000    + (x) )

#define SHARED_MEM EDGE_NPU_SCRATCH_BASE
#ifdef EDGE_HOST_TEST
void *edge_host_shared(uint32_t off);
#define CPU_SHARED_MEM(off) edge_host_shared((uint32_t)(off))
#else
#define CPU_SHARED_MEM(off)   ((void *)(uintptr_t)(SHARED_MEM + (off)))
#endif
#define NPU_SHARED_MEM(off)   ((uint32_t)(SHARED_MEM + (off)))

int npu_matrix_axb(void* inst_addr, int matrix_a_addr, int matrix_b_addr, int matrix_c_addr, int a_col,int a_row, int b_col, int b_row,uint8_t*exp_tag,uint32_t* inst_len);
int npu_mac_engine(void* inst_addr, uint32_t a_addr, uint32_t w_addr, uint32_t bias[],uint8_t rescale_enable, uint32_t rescale[], uint32_t act_enable, uint32_t act_type,int32_t out_zp, uint32_t out_addr[],uint32_t insize,uint32_t outsize, uint32_t a_num, uint32_t w_num,uint8_t*exp_tag,uint32_t* inst_len);

void sw_im2col_hwc(int8_t* in_data, int8_t* a_arr, int kw, int kh, int sx, int sy, 
                    int pad_top, int pad_bottom, int pad_left, int pad_right, int in_w, int in_h, int chi,
                    int out_h, int out_w, int in_zp) ;
void sw_im2col_1x1_hwc(int8_t* in_data, int8_t* a_arr, int kw, int kh, int sx, int sy,
                    int pad_top, int pad_bottom, int pad_left, int pad_right,
                    int in_w, int in_h, int chi, int out_h, int out_w, int in_zp);
void sw_pack_weight(int8_t* w_src, int8_t* w_dst, int out_c, int in_c, int maxk); 

#endif // TINY_NPU_H
