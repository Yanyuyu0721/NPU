/*-----------------------------------------
file name  : systolic_reorder.v
created    : 2026/01/28 12:06:48
modified   : 2026-03-18 13:20:23
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module systolic_reorder # (
    parameter DATA_WIDTH = 32,
    parameter MAX_DEPTH  = 8 ,  
    parameter ROWWIDTH   = 3
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // --- Configuration ---
    input  wire                  start_en, 
    input  wire [ROWWIDTH-1:0]   row_en,   

    // --- Write Interface (From Systolic Array, Reverse Order) ---
    input  wire                  data_in_vld,
    input  wire [DATA_WIDTH-1:0] data_in,

    // --- Read Interface (Variable Length = row_en) ---
    output reg                   data_out_vld,
    output reg  [DATA_WIDTH-1:0] data_out
);

reg       wr_bank_sel; // 0: Bank0, 1: Bank1
reg       rd_bank_sel; // 0: Bank0, 1: Bank1


reg                  data_in_vld_reg;
reg [DATA_WIDTH-1:0] data_in_reg;

always @(posedge clk) begin 
    if( ~rst_n ) begin 
        data_in_vld_reg <= 1'b0;
    end else begin 
        data_in_vld_reg <= data_in_vld;
    end
end

always @(posedge clk) begin 
    data_in_reg <= data_in;
end



// Bank status, 1: full, ready to read 
reg [1:0] bank_ready;  
reg [ROWWIDTH:0] len_latch [0:1]; 
    
reg [ROWWIDTH:0] rd_cnt;

wire                  s0_push, s0_pop, s0_empty, s0_full;
wire                  s1_push, s1_pop, s1_empty, s1_full;
wire [DATA_WIDTH-1:0] s0_dout, s1_dout;
reg                   s0_clear, s1_clear;

wire current_bank_full = (wr_bank_sel == 1'b0) ? s0_full : s1_full;
wire effective_wr_sel  = (current_bank_full) ? ~wr_bank_sel : wr_bank_sel;
assign s0_push = data_in_vld_reg && (effective_wr_sel == 1'b0);
assign s1_push = data_in_vld_reg && (effective_wr_sel == 1'b1);

reg len_latch_sel;

always @(posedge clk) begin
    if (!rst_n) begin
        wr_bank_sel <= 1'b0;
        bank_ready  <= 2'b00;
        len_latch[0]<= 'd0;
        len_latch[1]<= 'd0;
        len_latch_sel <= 1'b0;
    end else begin
        if (start_en) begin
            len_latch[len_latch_sel] <= row_en + 1'b1;
            len_latch_sel <= ~len_latch_sel;
        end

        if (current_bank_full) begin
            bank_ready[wr_bank_sel] <= 1'b1; 
            wr_bank_sel             <= ~wr_bank_sel; 
        end

        if (s0_clear) bank_ready[0] <= 1'b0;
        if (s1_clear) bank_ready[1] <= 1'b0;
    end
end

wire current_rd_ready = bank_ready[rd_bank_sel];
    
always @(posedge clk) begin
    if (!rst_n) begin
        rd_bank_sel  <= 1'b0;
        rd_cnt       <= 'd0;
        data_out_vld <= 1'b0;
        data_out     <= {DATA_WIDTH{1'b0}};
        s0_clear     <= 1'b0;
        s1_clear     <= 1'b0;
    end else begin
        data_out_vld <= 1'b0;
        s0_clear     <= 1'b0;
        s1_clear     <= 1'b0;

        if (current_rd_ready) begin
            if (rd_cnt < len_latch[rd_bank_sel]) begin
                data_out_vld <= 1'b1;
                data_out     <= (rd_bank_sel == 1'b0) ? s0_dout : s1_dout;
                
                rd_cnt       <= rd_cnt + 1'b1;
            end else begin
                if (rd_bank_sel == 1'b0) s0_clear <= 1'b1;
                else                     s1_clear <= 1'b1;
                
                rd_bank_sel <= ~rd_bank_sel;
                rd_cnt      <= 'd0;
            end
        end
    end
end

wire reading_active = current_rd_ready && (rd_cnt < len_latch[rd_bank_sel]);
    
assign s0_pop = reading_active && (rd_bank_sel == 1'b0);
assign s1_pop = reading_active && (rd_bank_sel == 1'b1);

stack #(
    .DATA_WIDTH(DATA_WIDTH), 
    .DEPTH(MAX_DEPTH)
) u_stack0 (
    .clk(clk), 
    .rst_n(rst_n), 
    .clear(s0_clear),
    .push(s0_push), 
    .din(data_in_reg),
    .pop(s0_pop),   
    .dout(s0_dout),
    .empty(s0_empty), 
    .full(s0_full)
);

stack #(
    .DATA_WIDTH(DATA_WIDTH), 
    .DEPTH(MAX_DEPTH)
) u_stack1 (
    .clk(clk), 
    .rst_n(rst_n), 
    .clear(s1_clear),
    .push(s1_push), 
    .din(data_in_reg),
    .pop(s1_pop),   
    .dout(s1_dout),
    .empty(s1_empty), 
    .full(s1_full)
);

endmodule

`default_nettype wire