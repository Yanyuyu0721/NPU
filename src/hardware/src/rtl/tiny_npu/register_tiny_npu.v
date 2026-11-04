/*-----------------------------------------
file name  : regsiter_tiny_npu.v
created    : 2026/01/10 21:12:27
modified   : 2026-02-08 13:54:43
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
`include "top_tiny_npu.vh"
module register_tiny_npu # (
    parameter DATA_WIDTH = 64 ,
    parameter ADDR_WIDTH = 32 ,
    parameter TAG_WIDTH  = 8
)(
    input  wire                      clk                  , // (input )
    input  wire                      rst_n                , // (input )
        
    input  wire    [DATA_WIDTH -1:0] reg_data             , // (input )
    input  wire    [ADDR_WIDTH -1:0] reg_addr             , // (input )
    input  wire                      reg_wr_en            , // (input )
    
    input  wire                      sync_status_en       ,
    input  wire [TAG_WIDTH-1:0]      sync_status_tag      ,

    input  wire                      wr_buf_id            ,

    output reg      [DATA_WIDTH-1:0] intr_status          , // (output)
    output reg      [DATA_WIDTH-1:0] intr_raw_status      , // (output)
    output reg      [DATA_WIDTH-1:0] intr_mask            , // (output)
    output reg      [DATA_WIDTH-1:0] tiny_npu_status      , // (output)
    output reg      [DATA_WIDTH-1:0] systolic_status      , // (output)
    output reg      [DATA_WIDTH-1:0] cdma_status            // (output)
);

reg      [DATA_WIDTH-1:0] intr_clear  ;  
reg      [DATA_WIDTH-1:0] intr_force  ; 

wire sync_intr_force     ;
wire sync_intr_pulse     ;
wire sync_intr_mask      ;
wire sync_intr_clear     ;
wire sync_intr_status    ;
wire sync_intr_raw_status;

assign sync_intr_force = intr_force[0];
assign sync_intr_pulse = sync_status_en;
assign sync_intr_mask  = intr_mask[0];
assign sync_intr_clear = intr_clear[0];

intr_pulse # (
    .NUM ( 1  )
)u_intr_pulse(
    .clk                          (clk                         ), // (input )
    .rst_n                        (rst_n                       ), // (input )
    
    .force_i                      (sync_intr_force             ), // (input )
    .pulse_i                      (sync_intr_pulse             ), // (input )
    .mask_i                       (sync_intr_mask              ), // (input )
    .clear_i                      (sync_intr_clear             ), // (input )
    
    .status_o                     (sync_intr_status            ), // (output)
    .raw_status_o                 (sync_intr_raw_status        )  // (output)
);

`ifndef DATA_WIDTH_64BIT
localparam STRB_WIDTH  = 2 ;
`else
localparam STRB_WIDTH  = 3 ;
`endif

localparam [ADDR_WIDTH-1:0] intr_mask_addr  = `REG_INTR_MASK; 
localparam [ADDR_WIDTH-1:0] intr_clear_addr = `REG_INTR_CLEAR;
localparam [ADDR_WIDTH-1:0] intr_force_addr = `REG_INTR_FORCE;
wire is_intr_mask ;
wire is_intr_clear;
wire is_intr_force;

assign is_intr_mask  = reg_addr == intr_mask_addr[ADDR_WIDTH-1:STRB_WIDTH] ;
assign is_intr_clear = reg_addr == intr_clear_addr[ADDR_WIDTH-1:STRB_WIDTH] ;
assign is_intr_force = reg_addr == intr_force_addr[ADDR_WIDTH-1:STRB_WIDTH] ;

// intr status
always @(posedge clk) begin 
    if( ~rst_n ) 
        intr_status <= 'b0;
    else 
        intr_status[0] <= sync_intr_status;
end

// intr raw_status
always @(posedge clk) begin 
    if( ~rst_n ) 
        intr_raw_status <= 'b0;
    else 
        intr_raw_status[0] <= sync_intr_raw_status;
end

// intr mask
always @(posedge clk) begin 
    if( ~rst_n ) 
        intr_mask <= 'b0;
    else if( is_intr_mask & reg_wr_en ) 
        intr_mask <= reg_data;
end

// intr clear
always @(posedge clk) begin 
    if( ~rst_n ) begin 
        intr_clear <= 'b0;
    end else if( is_intr_clear & reg_wr_en & reg_data[0] ) 
        intr_clear[0] <= 1'b1;
    else if( intr_clear[0] ) 
        intr_clear[0] <= 1'b0;
end

// intr force
always @(posedge clk) begin 
    if( ~rst_n ) begin 
        intr_force <= 'b0;
    end else if( is_intr_force & reg_wr_en & reg_data[0] ) 
        intr_force[0] <= 1'b1;
    else if( intr_force[0] ) 
        intr_force[0] <= 1'b0;
end

// cdma status
always@(posedge clk) begin 
    cdma_status <= 64'h5051383100000000; // upper word: exact-PQ8 capability
end

// systolic_unit status
always@(posedge clk) begin 
    systolic_status[0:0] <= wr_buf_id;
end

// tiny_npu status
always@(posedge clk) begin 
    if( sync_status_en ) 
        tiny_npu_status[7:0] <= sync_status_tag;
end

endmodule
`default_nettype wire
