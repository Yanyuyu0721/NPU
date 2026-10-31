/*-----------------------------------------
file name  : ppu_control.v
created    : 2026/02/02 21:56:16
modified   : 2026-02-10 21:07:57
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module ppu_control # (
    parameter AXI_ADDR_WIDTH = 32  , // const
    parameter TAG_WIDTH      = 8   , // const
    parameter LEN_WIDTH      = 12  , // const
    parameter AXIS_USER_WIDTH= 2   , 
    parameter INSTR_WIDTH    = 124 ,
    parameter OINST_LEN      = 18 + 32 + 12 + 32,
    parameter OCMD_LEN       = AXI_ADDR_WIDTH + LEN_WIDTH+1 + AXIS_USER_WIDTH
)(
    input  wire                   clk               ,
    input  wire                   rst_n             ,

    input  wire                   inst_vld          ,
    input  wire [INSTR_WIDTH-1:0] inst              ,
    output wire                   inst_rdy          ,

    input  wire [3:0]             cmd_en_gp0        ,
    input  wire [32*4-1:0]        cmd_addr_gp0      ,
    input  wire [13*4-1:0]        cmd_data_num_gp0  ,

    input  wire [3:0]             cmd_en_gp1        ,
    input  wire [32*4-1:0]        cmd_addr_gp1      ,
    input  wire [13*4-1:0]        cmd_data_num_gp1  ,

    output reg  [OCMD_LEN-1:0]    o_cmd_gp0         , // (output)
    output reg                    o_cmd_en_gp0      , // (output)
    input  wire                   gp0_status_en     ,

    output reg  [OCMD_LEN-1:0]    o_cmd_gp1         , // (output)
    output reg                    o_cmd_en_gp1      , // (output)
    input  wire                   gp1_status_en     ,

    output reg  [8:0]             cfg_out_zp        ,
    output reg  [2:0]             cfg_actfunc_type  ,
    output reg                    cfg_actfunc_enable,
    output reg                    cfg_rescale_enable,
    output reg                    cfg_bias_enable   ,

    input  wire [7:0]             ppu_inst_rdy      ,
    input  wire [7:0]             ppu_status        ,
    output wire [7:0]             ppu_inst_vld      ,
    output wire [8*OINST_LEN-1:0] ppu_inst          ,

    output reg                    ppu_status_en     ,
    output reg  [TAG_WIDTH-1:0]   ppu_status_tag   
);
wire [7:0] dma_fifo_empty;
//----------- parse inst, then generate inst for ppu 
wire [4:0]  w_opcode  = inst[4:0];    
// opcode == 1
wire [17:0] w_rescale = inst[103:86]; 
wire [31:0] w_bias    = inst[85:54];  
wire [11:0] w_len     = inst[53:42];  
wire [2:0]  w_dest_id = inst[39:37];   
wire [31:0] w_addr    = inst[36:5];   
// opcode == 0
wire [8:0]  w_cfg_zp      = inst[19:11]; 
wire [2:0]  w_cfg_act_type= inst[10:8];  
wire        w_cfg_act_en  = inst[7];     
wire        w_cfg_res_en  = inst[6];     
wire        w_cfg_bias_en = inst[5];     
// opcode == 5'b11111
wire [TAG_WIDTH-1:0] w_sync_tag = inst[123:116];

// One command event controls every command-induced state/write update.
wire inst_fire = inst_vld && inst_rdy;
wire [7:0] inst_fifo_full;
reg [TAG_WIDTH-1:0] w_sync_tag_reg;
always@(posedge clk) begin 
    if( (w_opcode == 5'h1F) && inst_fire ) begin 
        w_sync_tag_reg <= w_sync_tag;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        cfg_out_zp         <= 9'd0;
        cfg_actfunc_type   <= 3'd0;
        cfg_actfunc_enable <= 1'b0;
        cfg_rescale_enable <= 1'b0;
        cfg_bias_enable    <= 1'b0;
    end else if (inst_fire && (w_opcode == 5'd0)) begin 
        cfg_out_zp         <= w_cfg_zp;
        cfg_actfunc_type   <= w_cfg_act_type;
        cfg_actfunc_enable <= w_cfg_act_en;
        cfg_rescale_enable <= w_cfg_res_en;
        cfg_bias_enable    <= w_cfg_bias_en;
    end
end

reg  sync_resp_enable;
always@(posedge clk) begin 
    if( (w_opcode == 5'h1F) && inst_fire ) 
        sync_resp_enable <= inst[5];
end
// sync inst
reg  [6:0] cmd_cnt_gp0;
always @(posedge clk) begin
    if (~rst_n) cmd_cnt_gp0 <= 7'd0;
    else if (o_cmd_en_gp0 & ~gp0_status_en) 
        cmd_cnt_gp0 <= cmd_cnt_gp0 + 1'b1;
    else if (~o_cmd_en_gp0 & gp0_status_en)
        cmd_cnt_gp0 <= cmd_cnt_gp0 - 1'b1;
end
wire cnt_gp0_zero = (cmd_cnt_gp0 == 7'd0);

reg [6:0] cmd_cnt_gp1;
always @(posedge clk) begin
    if (~rst_n) 
        cmd_cnt_gp1 <= 7'd0;
    else if (o_cmd_en_gp1 && ~gp1_status_en)
        cmd_cnt_gp1 <= cmd_cnt_gp1 + 1'b1;
    else if (~o_cmd_en_gp1 && gp1_status_en)
        cmd_cnt_gp1 <= cmd_cnt_gp1 - 1'b1;
end
wire cnt_gp1_zero = (cmd_cnt_gp1 == 7'd0);

wire [7:0] inst_fifo_empty;
reg  sync_status;

// A queued descriptor is outstanding work even while its worker is idle.
// A FIFO pop makes the real worker busy/enqueues its task on the same edge;
// worker status and the existing command/DMA checks then cover that work.
// FIFO/worker progress is independent of SYNC, so this introduces no drain cycle.
wire all_clear = (&inst_fifo_empty) && cnt_gp0_zero && cnt_gp1_zero && (&ppu_status) && ~|cmd_en_gp1 && ~|cmd_en_gp0
                 && (&dma_fifo_empty) && ~o_cmd_en_gp0 && ~o_cmd_en_gp1; 


always @(posedge clk) begin
    if (~rst_n)
        sync_status <= 1'b0;
    else if (inst_fire && (w_opcode == 5'h1F) )
        sync_status <= 1'b1;
    else if (sync_status && all_clear)
        sync_status <= 1'b0;
end

// Conservative full handling: even a simultaneous read cannot accept a write
// while full. Other destinations and CFG preserve their original readiness.
assign inst_rdy = (w_opcode == 5'h1F) ? all_clear :
                  (~sync_status && ((w_opcode != 5'd1) || !inst_fifo_full[w_dest_id]));

always @(posedge clk) begin
    if (!rst_n) begin
        ppu_status_en  <= 1'b0;
        ppu_status_tag <= {TAG_WIDTH{1'b0}};
    end else if (sync_status && all_clear && sync_resp_enable) begin
        ppu_status_en  <= 1'b1;
        ppu_status_tag <= w_sync_tag_reg; 
    end else begin
        ppu_status_en  <= 1'b0;
    end
end

// ppu inst
// Held VALID cannot duplicate a descriptor while READY is low. Reset empties
// FIFOs and clears sync_status; stale payload/invalid cycles cause no writes.
wire inst_is_ppu = inst_fire && (w_opcode == 5'd1);
wire [7:0] v_wr_en = inst_is_ppu ? (8'b1 << w_dest_id) : 8'b0;
wire [OINST_LEN-1:0] v_fifo_din = {w_rescale, w_bias, w_len, w_addr};

generate
    genvar j;
    for (j = 0; j < 8; j = j + 1) begin : inst_fifos
        wire ppu_inst_fifo_rd_en;
        assign ppu_inst_fifo_rd_en = ppu_inst_rdy[j] & ~inst_fifo_empty[j];
        syncfifo #(
            .DATA_WIDTH(OINST_LEN),
            .ADDR_WIDTH(5),
            .FWFT_EN(1'b1) 
        ) u_syncfifo (
            .clk   (clk),
            .rst_n (rst_n),
            .din   (v_fifo_din),
            .wr_en (v_wr_en[j]),
            .full  (inst_fifo_full[j]),
            .dout  (ppu_inst[j*OINST_LEN +: OINST_LEN]), 
            .rd_en (ppu_inst_fifo_rd_en), 
            .empty (inst_fifo_empty[j])
        );
    end
endgenerate
assign ppu_inst_vld = ~inst_fifo_empty;

//------------ parse input cmd from ppu, then generate cmd for output cdma
localparam FIFO_DATA_W = 32 + 13; // addr + num
wire [7:0] fifo_full;
wire [7:0] fifo_rd_en;
wire [FIFO_DATA_W-1:0] dout_gp0 [0:3];
wire [FIFO_DATA_W-1:0] dout_gp1 [0:3];

generate
    genvar i;
    // GP0: index 0-3
    for (i = 0; i < 4; i = i + 1) begin : gp0_fifos
        syncfifo #(
            .DATA_WIDTH(FIFO_DATA_W),
            .ADDR_WIDTH(4),
            .FWFT_EN(1) 
        ) u_fifo_gp0 (
            .clk  (clk  ), 
            .rst_n(rst_n),
            .din  ({cmd_addr_gp0[i*32 +: 32], cmd_data_num_gp0[i*13 +: 13]}),
            .wr_en(cmd_en_gp0[i] ),
            .full (fifo_full[i]  ),
            .dout (dout_gp0[i]  ),
            .rd_en(fifo_rd_en[i] ),
            .empty(dma_fifo_empty[i] )
        );
    end
    // GP1: index 4-7
    for (i = 0; i < 4; i = i + 1) begin : gp1_fifos
        syncfifo #(
            .DATA_WIDTH(FIFO_DATA_W),
            .ADDR_WIDTH(4),
            .FWFT_EN(1)
        ) u_fifo_gp1 (
            .clk  (clk  ), 
            .rst_n(rst_n),
            .din  ({cmd_addr_gp1[i*32 +: 32], cmd_data_num_gp1[i*13 +: 13]}),
            .wr_en(cmd_en_gp1[i]  ),
            .full (fifo_full[i+4] ),
            .dout (dout_gp1[i] ),
            .rd_en(fifo_rd_en[i+4]),
            .empty(dma_fifo_empty[i+4])
        );
    end
endgenerate

wire [3:0] grant_gp0;
wire [3:0] grant_gp1;
wire [1:0] id_gp0, id_gp1;

round_robin_arbiter #(.N(4)) u_arb_gp0 (
    .clk   (clk),
    .rst_n (rst_n),
    .req   (~dma_fifo_empty[3:0]), 
    .grant (grant_gp0)
);

round_robin_arbiter #(.N(4)) u_arb_gp1 (
    .clk   (clk),
    .rst_n (rst_n),
    .req   (~dma_fifo_empty[7:4]),
    .grant (grant_gp1)
);

assign id_gp0 = grant_gp0[1] ? 2'd1 : (grant_gp0[2] ? 2'd2 : (grant_gp0[3] ? 2'd3 : 2'd0));
assign id_gp1 = grant_gp1[1] ? 2'd1 : (grant_gp1[2] ? 2'd2 : (grant_gp1[3] ? 2'd3 : 2'd0));
assign fifo_rd_en[3:0] = grant_gp0;
assign fifo_rd_en[7:4] = grant_gp1;
// gp0 output
always @(posedge clk) begin
    if (!rst_n) begin
        o_cmd_gp0    <= {OCMD_LEN{1'b0}};
        o_cmd_en_gp0 <= 1'b0;
    end else begin
        o_cmd_en_gp0 <=  |grant_gp0;
        if (|grant_gp0) begin
            // addr(32) + len(13) + id(2)
            o_cmd_gp0 <= {
                dout_gp0[id_gp0][44:13], 
                dout_gp0[id_gp0][12:0],  
                id_gp0                    
            };
        end 
    end
end

// gp1 output
always @(posedge clk) begin
    if (!rst_n) begin
        o_cmd_gp1 <= {OCMD_LEN{1'b0}};
        o_cmd_en_gp1 <= 1'b0;
    end else begin
        o_cmd_en_gp1 <= |grant_gp1;
        if (|grant_gp1) begin
            o_cmd_gp1 <= {
                dout_gp1[id_gp1][44:13], 
                dout_gp1[id_gp1][12:0], 
                id_gp1
            };
        end
    end
end

endmodule
`default_nettype wire
