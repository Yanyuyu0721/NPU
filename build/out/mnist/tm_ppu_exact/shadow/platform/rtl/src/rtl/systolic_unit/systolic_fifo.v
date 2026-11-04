/*-----------------------------------------
file name  : systolic_fifo.v
created    : 2025/12/09 22:43:42
modified   : 2026-01-27 21:15:31
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none

module systolic_fifo # (
    parameter integer DIWIDTH       = 32  , 
    parameter integer DOWIDTH       = 8   ,
    parameter integer CHANNEL       = 2   , // const for 2, TODO
    parameter integer AWIDTH        = 6    
)(
    input  wire                       clk           ,
    input  wire                       rst_n         ,
    
    // axis write interface
    input  wire                       axis_vld      ,
    input  wire                       axis_last     , 
    input  wire [DIWIDTH-1:0]         axis_data     ,
    output wire                       axis_rdy      ,

    // read control interface
    input  wire [11:0]                calc_len      , // 12-bit, N+1
    input  wire                       start_en      , 
    input  wire                       last_en       , 

    // output interface
    output wire                       out_vld       ,
    output wire                       out_start     ,
    output wire [DOWIDTH*CHANNEL-1:0] out_data      ,
    output wire                       out_last      
);

// ============================================================
// 1. parameter 
// ============================================================
localparam integer OUTPUT_BLOCK_WIDTH = DOWIDTH * CHANNEL; 
localparam integer RATIO = DIWIDTH / OUTPUT_BLOCK_WIDTH;
localparam integer SUB_CNT_WIDTH = $clog2(RATIO);

// ============================================================
// 2. fifo 
// ============================================================
wire [DIWIDTH-1:0] fifo_dout;
wire               fifo_full;
wire               fifo_empty;
reg                fifo_rd_en; 

syncfifo # (
    .DATA_WIDTH (DIWIDTH),
    .ADDR_WIDTH (AWIDTH ),
    .RAM_STYLE  ("block"), 
    .FWFT_EN    (1)           
) u_fifo_core (
    .clk     (clk),
    .rst_n   (rst_n),
    .din     (axis_data),
    .wr_en   (axis_vld & ~fifo_full), 
    .full    (fifo_full),
    .dout    (fifo_dout),
    .rd_en   (fifo_rd_en),
    .empty   (fifo_empty)
);

assign axis_rdy = ~fifo_full;

// ============================================================
// 3. control
// ============================================================
    
reg        is_running;      
reg [12:0] processed_cnt;   
reg [12:0] target_len;      
reg        latched_last_en; 
    
reg [SUB_CNT_WIDTH-1:0] sub_word_cnt;

wire handshake = is_running && (~fifo_empty);

wire is_last_beat = handshake && ((processed_cnt + CHANNEL) >= target_len);

wire is_word_end  = (sub_word_cnt == RATIO - 1);

always @(posedge clk) begin
    if (~rst_n) begin
        is_running      <= 1'b0;
        processed_cnt   <= 'b0;
        target_len      <= 'b0;
        latched_last_en <= 1'b0;
        sub_word_cnt    <= 'b0;
    end else begin
        if (start_en) begin
            is_running      <= 1'b1;
            processed_cnt   <= 'b0;
            target_len      <= {1'b0, calc_len} + 1'b1;
            latched_last_en <= last_en;
            sub_word_cnt    <= 'b0; 
        end else if (handshake) begin
            processed_cnt <= processed_cnt + CHANNEL;

            if (is_last_beat) begin
                is_running   <= 1'b0;
                sub_word_cnt <= 'b0; 
            end else if (is_word_end) begin
                sub_word_cnt <= 'b0;
            end else begin
                sub_word_cnt <= sub_word_cnt + 1'b1;
            end
        end
    end
end

// ============================================================
// 4. read control 
// ============================================================
    
always @(*) begin
    fifo_rd_en = 1'b0;
    if (handshake) begin
        if (is_word_end || is_last_beat) begin
            fifo_rd_en = 1'b1;
        end
    end
end

// ============================================================
// 5. output 
// ============================================================
wire [OUTPUT_BLOCK_WIDTH-1:0] current_slice;
assign current_slice = fifo_dout[sub_word_cnt * OUTPUT_BLOCK_WIDTH +: OUTPUT_BLOCK_WIDTH];

wire [DOWIDTH-1:0] raw_low  = current_slice[DOWIDTH-1 : 0];
wire [DOWIDTH-1:0] raw_high = current_slice[2*DOWIDTH-1 : DOWIDTH];

reg  [OUTPUT_BLOCK_WIDTH-1:0] data_mux_comb;

always @(*) begin
    // Low Channel
    data_mux_comb[DOWIDTH-1 : 0] = raw_low;

    // High Channel (Padding Logic)
    if ((processed_cnt + 1) < target_len) begin
        data_mux_comb[2*DOWIDTH-1 : DOWIDTH] = raw_high;
    end else begin
        data_mux_comb[2*DOWIDTH-1 : DOWIDTH] = {DOWIDTH{1'b0}};
    end
end

reg                          out_vld_reg;
reg [OUTPUT_BLOCK_WIDTH-1:0] out_data_reg;
reg                          out_last_reg;
reg                          out_start_reg;

always @(posedge clk) begin
    if (~rst_n) begin
        out_vld_reg  <= 1'b0;
        out_data_reg <= 'b0;
        out_last_reg <= 1'b0;
        out_start_reg <= 1'b0;
    end else begin
        out_vld_reg  <= 1'b0;
        out_last_reg <= 1'b0;
        out_data_reg <= 'b0; 
        out_start_reg <= 1'b0;

        if (handshake) begin
            out_vld_reg  <= 1'b1;
            out_data_reg <= data_mux_comb;


            if( processed_cnt == 0 ) begin 
                out_start_reg <= 1'b1;
            end

            if (is_last_beat && latched_last_en) begin
                out_last_reg <= 1'b1;
            end
        end
    end
end

assign out_vld  = out_vld_reg ;
assign out_data = out_data_reg;
assign out_last = out_last_reg;
assign out_start= out_start_reg;

endmodule

`default_nettype wire
