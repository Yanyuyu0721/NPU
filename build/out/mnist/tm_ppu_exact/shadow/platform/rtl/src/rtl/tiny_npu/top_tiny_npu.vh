/*-----------------------------------------
file name  : top_tiny_npu.vh
created    : 2026/01/06 14:00:41
modified   : 2026-03-14 14:28:40
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`ifndef TOP_TINY_NPU__VH
`define TOP_TINY_NPU__VH

`define CMD_DATA_WIDTH     (32)
`define CMD_ADDR_WIDTH     (32)
`define DATA_WIDTH         (64)
`define ADDR_WIDTH         (32)

`ifdef EDGE_RISCV_SIM
 `define DEVICE_ADDR        (32'hc0000000) // VexRiscv simulation map
`else
 `define DEVICE_ADDR        (32'h43C00000) // Zynq map
`endif
`define REG_CMD             (`DEVICE_ADDR + 7'h00)
`define REG_INTR_STATUS     (`DEVICE_ADDR + 7'h08)
`define REG_INTR_RAW_STATUS (`DEVICE_ADDR + 7'h10)
`define REG_INTR_MASK       (`DEVICE_ADDR + 7'h18)
`define REG_INTR_CLEAR      (`DEVICE_ADDR + 7'h20)
`define REG_INTR_FORCE      (`DEVICE_ADDR + 7'h28)
`define REG_TINY_NPU_STATUS (`DEVICE_ADDR + 7'h30)
`define REG_SYSTOLIC_STATUS (`DEVICE_ADDR + 7'h38)
`define REG_CDMA_STATUS     (`DEVICE_ADDR + 7'h40)

`define INSTR_FIFO_AWIDTH  (12)

`define INSTR_WIDTH        (64) 

`define PE_NCOL            (8)
`define PE_NROW            (8)

`define CALC_DWIDTH        (8)
`define CALC_CHANNEL       (2)

`define PSUM_WIDTH         (32)

`define TAG_WIDTH          (8)
`define LEN_WIDTH          (12)
`define USER_WIDTH         (3)
`define SYSTOLIC_CMD_LEN   (`INSTR_WIDTH   - 4)
`define CDMA_CMD_LEN       (`INSTR_WIDTH*2 - 4)
`define PPU_CMD_LEN        (`INSTR_WIDTH*2 - 4)
`define INST_DMA_CMD_LEN   (`INSTR_WIDTH   - 4)

// for zynq
`ifdef EDGE_RISCV_SIM
 `define DATA_BUFFER_SIZE   (20) // shared RAM at NPU address 0x80000
`elsif EDGE_SIM_SMALL_DDR
 `define DATA_BUFFER_SIZE   (16) // bounded test RAM; address bus remains 32 bits
`else
 `define DATA_BUFFER_SIZE   (30)
`endif
 `define DATA_BUFFER_ADDR   (32'h00_00_00_00)
 
 `define GLOBAL_BUFFER_SIZE (12)
 `define GLOBAL_BUFFER_ADDR (32'h40_00_00_00)

// for riscv sim
//`define DATA_BUFFER_SIZE   (20)
//`define DATA_BUFFER_ADDR   (32'h00_00_00)

//`define GLOBAL_BUFFER_SIZE (12)
//`define GLOBAL_BUFFER_ADDR (32'h10_00_00)


// FPGA_SOURCE is a build flag, never a shared-header side effect.
// Vivado sources_1 sets FPGA_SOURCE; portable simulation omits it.
`define DATA_WIDTH_64BIT


`endif

