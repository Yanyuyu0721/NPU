/*-----------------------------------------
file name  : control_axi_cdma.v
created    : 2026/01/08 16:04:44
modified   : 2026-02-09 17:58:27
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
module control_axi_cdma # (
    parameter ADDR_WIDTH = 32  , // const
    parameter ICMD_LEN   = 124 , // const
    parameter LEN_WIDTH  = 8   , // const
    parameter TAG_WIDTH  = 8     // const
)(
    input  wire                      clk                  , // (input )
    input  wire                      rst_n                , // (input )

    input  wire       [ICMD_LEN-1:0] cmd                  , // (input )
    input  wire                      cmd_vld              , // (input )
    output wire                      cmd_rdy              , 

    input  wire                      cdma_desc_status_en  , // (input )

    output wire     [ADDR_WIDTH-1:0] cdma_desc_read_addr  , // (output)
    output wire     [ADDR_WIDTH-1:0] cdma_desc_write_addr , // (output)
    output wire    [LEN_WIDTH+1-1:0] cdma_desc_len        , // (output)
    output wire      [TAG_WIDTH-1:0] cdma_desc_tag        , // (output)
    output wire                      cdma_desc_valid      , // (output)
    input  wire                      cdma_desc_ready      , // (input )

    output wire      [TAG_WIDTH-1:0] cdma_status_tag      , // (output)
    output wire                      cdma_status_en         // (output)
);

wire cmd_fifo_full ;
wire cmd_fifo_empty;

wire cmd_en = cmd_vld & cmd_rdy;

wire [ICMD_LEN-1:0] cmd_fifo_out;
wire                cmd_fifo_rd_en;

reg [TAG_WIDTH-1:0]   tag      ;
reg [LEN_WIDTH+1-1:0] len      ;
reg [31:0]          src_addr ;
reg [31:0]          dest_addr;
reg [4:0]           opcode   ;
wire                is_sync  ;
assign is_sync = &cmd_fifo_out[4:0];

reg  sync_resp_enable;
always@(posedge clk) begin 
    if( is_sync & cmd_fifo_rd_en ) 
        sync_resp_enable <= cmd[5];
end


always @ (posedge clk) begin 
    if( cmd_fifo_rd_en ) begin 
        tag <= cmd_fifo_out[ICMD_LEN-1 -: TAG_WIDTH];
        len <= cmd_fifo_out[80:69] + 1'b1;
        src_addr  <= cmd_fifo_out[68:37];
        dest_addr <= cmd_fifo_out[36:5] ;
        opcode    <= cmd_fifo_out[4:0]  ;
    end
end

syncfifo # (
    .DATA_WIDTH                   (ICMD_LEN                     ), 
    .ADDR_WIDTH                   (4                            ), 
    .RAM_STYLE                    ("BLOCK"                      ), 
    .FWFT_EN                      (1                            ) 
)u_cdma_cmd_fio(
    .din                          (cmd                          ), // (input )
    .wr_en                        (cmd_en                       ), // (input )
    .full                         (cmd_fifo_full                ), // (output)
    
    .dout                         (cmd_fifo_out                 ), // (output)
    .rd_en                        (cmd_fifo_rd_en               ), // (input )
    .empty                        (cmd_fifo_empty               ), // (output)
    
    .clk                          (clk                          ), // (input )
    .rst_n                        (rst_n                        )  // (input )
);

assign cdma_desc_read_addr = src_addr;
assign cdma_desc_write_addr= dest_addr;
assign cdma_desc_len       = len;
assign cdma_desc_tag       = tag;
assign cdma_status_tag     = tag;

// ++ cdma_status_en 
wire all_clear;
reg sync_status;
always @(posedge clk) begin
    if( ~rst_n ) 
        sync_status <= 1'b0;
    else if( cmd_fifo_rd_en & is_sync ) 
        sync_status <= 1'b1;
    else if( all_clear ) 
        sync_status <= 1'b0;
end

wire cmd_cnt_inc, cmd_cnt_dec;
assign cmd_cnt_inc = cmd_fifo_rd_en & ~is_sync;
assign cmd_cnt_dec = cdma_desc_status_en;
reg [3:0] cmd_cnt;
always @(posedge clk) begin
    if(~rst_n ) 
        cmd_cnt <= 'b0;
    else if(cmd_cnt_inc & ~cmd_cnt_dec)
        cmd_cnt <= cmd_cnt + 1'b1;
    else if(cmd_cnt_dec & ~cmd_cnt_inc)
        cmd_cnt <= cmd_cnt - 1'b1;
end

wire cmd_cnt_zero;
assign cmd_cnt_zero = ~(|cmd_cnt);
assign all_clear = sync_status & cmd_cnt_zero;
assign cdma_status_en = all_clear & sync_resp_enable ;
// -- cdma_status_en 

// ++ cdma_desc_valid
reg cdma_desc_valid_reg;
always @(posedge clk) begin
    if( ~rst_n ) 
        cdma_desc_valid_reg <= 1'b0;
    else if( cmd_fifo_rd_en & ~is_sync ) 
        cdma_desc_valid_reg <= 1'b1;
    else if( cdma_desc_ready ) 
        cdma_desc_valid_reg <= 1'b0;
end

reg rd_en_reg ;
always @(posedge clk) begin
    if( ~rst_n ) 
        rd_en_reg <= 1'b1;
    else if( cdma_status_en | ( cdma_desc_valid_reg & cdma_desc_ready ) ) 
        rd_en_reg <= 1'b1;
    else if( cmd_fifo_rd_en )
        rd_en_reg <= 1'b0;
end

assign cmd_fifo_rd_en = rd_en_reg & ~cmd_fifo_empty; 
assign cdma_desc_valid = cdma_desc_valid_reg;
// -- cdma_desc_valid


assign cmd_rdy = ~sync_status;

endmodule

`default_nettype wire 
