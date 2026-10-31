/*-----------------------------------------
file name  : axil_fifo.v
created    : 2026/01/05 21:02:06
modified   : 2026-03-18 22:59:30
description: AXI-Lite to FIFO interface
notes      : Replaced combinatorial handshake with standard AXI state machine
author     : yyrwkk
-----------------------------------------*/
`timescale 1ns / 1ps
`default_nettype none

module axil_fifo # (
    // Width of data bus in bits
    parameter                 CMD_DATA_WIDTH = 32       , 
    parameter                 DATA_WIDTH     = 32       , 
    // Width of address bus in bits
    parameter                 ADDR_WIDTH     = 16       , 
    // Device 's address, must be aligned
    parameter                 FIFO_ADDR      = 16'hfff0 , 
    // Fifo addr width
    parameter                 FIFO_AWIDTH    = 5        ,
    parameter                 INSTR_WIDTH    = 64       ,
    // Width of wstrb (width of data bus in words)
    parameter                 STRB_WIDTH     = $clog2(DATA_WIDTH/8) 
)(
    input  wire                 clk                  , // (input )
    input  wire                 rst_n                , // (input )

    // aw channel
    input  wire [ADDR_WIDTH-1:0] s_axil_awaddr       , // (input )
    input  wire            [2:0] s_axil_awprot       , // (input )
    input  wire                  s_axil_awvalid      , // (input )
    output wire                  s_axil_awready      , // (output)
    
    // w channel
    input  wire [CMD_DATA_WIDTH-1:0] s_axil_wdata    , // (input )
    input  wire [CMD_DATA_WIDTH/8-1:0] s_axil_wstrb  , // (input )
    input  wire                  s_axil_wvalid       , // (input )
    output wire                  s_axil_wready       , // (output)

    // b channel
    output wire            [1:0] s_axil_bresp        , // (output)
    output wire                  s_axil_bvalid       , // (output)
    input  wire                  s_axil_bready       , // (input )

    input  wire [DATA_WIDTH-1:0] inst_data           ,
    input  wire                  inst_data_vld       ,
    output wire                  inst_data_rdy       ,

    // fifo output 
    output wire [INSTR_WIDTH-1:0] inst_fifo_data     ,
    output wire                  inst_fifo_vld       , 
    input  wire                  inst_fifo_rdy       ,

    output wire [CMD_DATA_WIDTH-1:0] axil_wdata      , 
    output wire [ADDR_WIDTH-1:0] axil_waddr          , 
    output wire                  axil_wen                            
);

localparam VALID_ADDR_WIDTH = ADDR_WIDTH-STRB_WIDTH;

reg axil_wr_en;

reg s_axil_awready_reg;
reg s_axil_wready_reg ;
reg s_axil_bvalid_reg ;
reg aw_en; 

wire [VALID_ADDR_WIDTH-1:0] s_axil_valid_awaddr;
assign s_axil_valid_awaddr = s_axil_awaddr[ADDR_WIDTH-1:STRB_WIDTH];

assign s_axil_awready = s_axil_awready_reg ;
assign s_axil_wready  = s_axil_wready_reg  ;
assign s_axil_bresp   = 2'b00              ; // ”¿‘∂∑µªÿ OKAY
assign s_axil_bvalid  = s_axil_bvalid_reg  ;

wire inst_cmd_full;

// --- fifo signals 
wire available   ;
wire addr_eq     ;
assign addr_eq = (s_axil_valid_awaddr == FIFO_ADDR[ADDR_WIDTH-1:STRB_WIDTH]); 
assign available = ~(addr_eq & inst_cmd_full);

always @(posedge clk) begin
    if( ~rst_n ) begin 
        s_axil_awready_reg <= 1'b0;
        s_axil_wready_reg  <= 1'b0;
        s_axil_bvalid_reg  <= 1'b0;
        aw_en              <= 1'b1;
    end else begin 
        if (~s_axil_awready_reg && s_axil_awvalid && s_axil_wvalid && aw_en && available) begin
            s_axil_awready_reg <= 1'b1;
            s_axil_wready_reg  <= 1'b1;
            aw_en              <= 1'b0; 
        end 
        else if (s_axil_bready && s_axil_bvalid_reg) begin
            s_axil_awready_reg <= 1'b0;
            s_axil_wready_reg  <= 1'b0;
            aw_en              <= 1'b1;
        end 
        else begin
            s_axil_awready_reg <= 1'b0;
            s_axil_wready_reg  <= 1'b0;
        end

        if (s_axil_awvalid && s_axil_awready_reg && s_axil_wvalid && s_axil_wready_reg) begin
            s_axil_bvalid_reg <= 1'b1; 
        end 
        else if (s_axil_bready && s_axil_bvalid_reg) begin
            s_axil_bvalid_reg <= 1'b0;
        end
    end
end

always @(*) begin
    axil_wr_en = s_axil_awvalid && s_axil_awready_reg && s_axil_wvalid && s_axil_wready_reg;
end

//------------------------------ syncfifo & Data Route

wire inst_cmd_en = axil_wr_en & addr_eq;

assign axil_wdata = s_axil_wdata;
assign axil_waddr = { {STRB_WIDTH{1'b0}}, s_axil_valid_awaddr };
assign axil_wen   = axil_wr_en & ~addr_eq;

wire [INSTR_WIDTH-1:0]  fifo_data_dout;
wire                    fifo_data_empty;
wire                    fifo_data_rd_en;

wire [INSTR_WIDTH-1:0]  fifo_cmd_dout;
wire                    fifo_cmd_empty;
wire                    fifo_cmd_rd_en;

wire [INSTR_WIDTH-1:0]  arb_dout;
wire                    arb_valid;
wire                    arb_ready;

syncfifo_diffw # (
    .DIN_WIDTH       (CMD_DATA_WIDTH), 
    .DOUT_WIDTH      (INSTR_WIDTH   ), 
    .WADDR_WIDTH     (5             ), 
    .RAM_STYLE       ("distributed" ), 
    .FWFT_EN         (1             ), 
    .MSB_FIFO        (0             )  
) u_syncfifo_diffw_cmd (
    .din          (s_axil_wdata   ), // (input )
    .wr_en        (inst_cmd_en    ), // (input )
    .full         (inst_cmd_full  ), // (output)

    .dout         (fifo_cmd_dout  ), // (output)
    .rd_en        (fifo_cmd_rd_en ), // (input )
    .empty        (fifo_cmd_empty ), // (output)

    .clk          (clk            ), // (input )
    .rst_n        (rst_n          )  // (input )
);

wire inst_data_en = inst_data_vld & inst_data_rdy;
wire inst_data_full;
syncfifo_diffw # (
    .DIN_WIDTH       (DATA_WIDTH    ), 
    .DOUT_WIDTH      (INSTR_WIDTH   ), 
    .WADDR_WIDTH     (5             ), 
    .RAM_STYLE       ("distributed" ), 
    .FWFT_EN         (1             ), 
    .MSB_FIFO        (0             )  
) u_syncfifo_diffw_data (
    .din          (inst_data      ), // (input )
    .wr_en        (inst_data_en   ), // (input )
    .full         (inst_data_full ), // (output) nc

    .dout         (fifo_data_dout ), // (output)
    .rd_en        (fifo_data_rd_en), // (input )
    .empty        (fifo_data_empty), // (output)

    .clk          (clk            ), // (input )
    .rst_n        (rst_n          )  // (input )
);
assign inst_data_rdy = ~inst_data_full; 

wire   [INSTR_WIDTH-1:0] inst_fifo_data_tmp  ;
wire                     inst_fifo_vld_tmp   ;   
wire                     inst_fifo_rdy_tmp   ;  

assign inst_fifo_data_tmp  = ~fifo_data_empty ? fifo_data_dout : fifo_cmd_dout; 
assign inst_fifo_vld_tmp   = ~fifo_data_empty | ~fifo_cmd_empty;
assign fifo_data_rd_en = ~fifo_data_empty & inst_fifo_rdy_tmp;
assign fifo_cmd_rd_en  = ~fifo_cmd_empty & fifo_data_empty & inst_fifo_rdy_tmp;

wire inst_syncfifo_wr_en;
wire inst_syncfifo_full ;
wire inst_syncfifo_rd_en;
wire inst_syncfifo_empty;

assign inst_syncfifo_wr_en = inst_fifo_vld_tmp & ~inst_syncfifo_full;
assign inst_fifo_rdy_tmp  =  ~inst_syncfifo_full;
syncfifo # (
    .DATA_WIDTH   (INSTR_WIDTH    ), 
    .ADDR_WIDTH   (FIFO_AWIDTH    ), 
    .RAM_STYLE    ("block"        ), 
    .FWFT_EN      (1              )  
)u_syncfifo_inst(
    .din           (inst_fifo_data_tmp    ), // (input )
    .wr_en         (inst_syncfifo_wr_en   ), // (input )
    .full          (inst_syncfifo_full    ), // (output)
    
    .dout          (inst_fifo_data        ), // (output)
    .rd_en         (inst_syncfifo_rd_en   ), // (input )
    .empty         (inst_syncfifo_empty   ), // (output)
    
    .clk           (clk                   ), // (input )
    .rst_n         (rst_n                 ) // (input )
);

assign inst_fifo_vld = ~inst_syncfifo_empty;
assign inst_syncfifo_rd_en = inst_fifo_rdy & ~inst_syncfifo_empty;

//------------------------------ syncfifo
endmodule
`default_nettype wire