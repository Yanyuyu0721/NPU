/*-----------------------------------------
file name  : systolic_pe.v
created    : 2026/01/27 17:13:43
modified   : 2026-03-18 15:43:10
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
module systolic_pe # (
    parameter integer DWIDTH     = 8  ,     
    parameter integer CHANNEL    = 2  ,  // now ,just const for 2, TODO
    parameter integer PSUM_WIDTH = 32  
)(
    input  wire                      clk,
    input  wire                      rst_n,
   
    input  wire                      pe_en,
    input  wire                      pe_start_in,

    output reg                       pe_start_out,
    // activation 
    input  wire                      vld_a_in,
    input  wire                      last_in,
    input  wire [DWIDTH*CHANNEL-1:0] activation_in,
    output reg  [DWIDTH*CHANNEL-1:0] activation_out,
    output reg                       vld_a_out,
    output reg                       last_out,

    // weight 
    input  wire                      vld_w_in,
    input  wire [DWIDTH*CHANNEL-1:0] weight_in,
    output reg  [DWIDTH*CHANNEL-1:0] weight_out,
    output reg                       vld_w_out,

    // output 
    input  wire [PSUM_WIDTH-1:0]     sum_in,      
    input  wire                      sum_in_vld,  
    output wire [PSUM_WIDTH-1:0]     sum_out,     
    output wire                      sum_out_vld 
);

reg pe_en_reg;
always @(posedge clk) begin 
    if(~rst_n ) begin 
        pe_en_reg <= 1'b0;
    end else if( pe_start_in & pe_en) begin 
        pe_en_reg <= 1'b1;
    end else if(last_in) begin 
        pe_en_reg <= 1'b0;
    end
end

wire pe_enable = (pe_start_in & pe_en ) | pe_en_reg; 

always @(posedge clk) begin
    if (~rst_n) begin
        vld_a_out      <= 1'b0;
        vld_w_out      <= 1'b0;
        activation_out <= 'b0;
        weight_out     <= 'b0;
    end else if( pe_enable ) begin
        if (vld_a_in ) activation_out <= activation_in;
        if (vld_w_in) weight_out     <= weight_in;
        
        vld_a_out   <= vld_a_in; 
        vld_w_out   <= vld_w_in;
    end else begin 
        vld_a_out   <= 1'b0;
        vld_w_out   <= 1'b0;
    end
end

always @(posedge clk) begin 
    if (~rst_n) begin
        last_out       <= 1'b0;
    end else begin 
        last_out    <= last_in ;
    end
end

always @(posedge clk) begin 
    if( ~rst_n ) begin 
        pe_start_out <= 1'b0;
    end else if( pe_en & pe_start_in ) begin 
        pe_start_out <= 1'b1;        
    end else begin 
        pe_start_out <= 1'b0;
    end
end

wire compute_en = vld_a_in & vld_w_in;
    
wire signed [DWIDTH-1:0] w0_reg = weight_out[DWIDTH-1 : 0];
wire signed [DWIDTH-1:0] w1_reg = weight_out[2*DWIDTH-1 : DWIDTH];
wire signed [DWIDTH-1:0] a0_reg = activation_out[DWIDTH-1 : 0];
wire signed [DWIDTH-1:0] a1_reg = activation_out[2*DWIDTH-1 : DWIDTH];

// wire signed [2*DWIDTH:0] dot_prod_0 = $signed(w0) * $signed(a0);
// wire signed [2*DWIDTH:0] dot_prod_1 = $signed(w1) * $signed(a1);
// 
// wire signed [2*DWIDTH:0] dot_prod = $signed(dot_prod_0) + $signed(dot_prod_1);
(* use_dsp = "yes" *) reg signed [2*DWIDTH:0] dot_prod_0_reg;
(* use_dsp = "yes" *) reg signed [2*DWIDTH:0] dot_prod_1_reg;
reg                     stage2_valid;
reg                     stage2_last;

always @(posedge clk) begin
    if (~rst_n) begin
        dot_prod_0_reg <= 'b0;
        dot_prod_1_reg <= 'b0;
        stage2_valid  <= 1'b0;
        stage2_last   <= 1'b0;
    end else begin
        dot_prod_0_reg <= $signed(w0_reg) * $signed(a0_reg);
        dot_prod_1_reg <= $signed(w1_reg) * $signed(a1_reg);
        stage2_valid   <= vld_a_out & vld_w_out;
        stage2_last    <= last_out;
    end
end

(* use_dsp = "yes" *) reg signed [2*DWIDTH:0] dot_prod_reg;
reg                     stage3_valid;
reg                     stage3_last;

always @(posedge clk) begin
    if (~rst_n) begin
        dot_prod_reg <= 'b0;
        stage3_valid <= 1'b0;
        stage3_last  <= 1'b0;
    end else begin
        dot_prod_reg <= $signed(dot_prod_0_reg) + $signed(dot_prod_1_reg);
        stage3_valid <= stage2_valid;
        stage3_last  <= stage2_last;
    end
end

reg  [PSUM_WIDTH-1:0] partial_sum;
wire [PSUM_WIDTH-1:0] partial_sum_next = $signed(partial_sum) + $signed(dot_prod_reg);

always @(posedge clk) begin 
    if( ~rst_n ) begin 
        partial_sum <= 'b0;
    end else if( stage3_last ) begin 
        partial_sum <= 'b0;
    end else if( stage3_valid ) begin 
        partial_sum <= partial_sum_next;
    end
end



reg  [PSUM_WIDTH-1:0] drain_reg;
reg                   drain_vld;
reg  [PSUM_WIDTH-1:0] drain_reg_d;
reg                   drain_vld_d;

always @(posedge clk) begin
    if (~rst_n) begin
        drain_vld <= 1'b0;
        drain_reg <= 'b0;
    end else if( sum_in_vld ) begin 
        drain_reg <= sum_in; 
        drain_vld <= 1'b1;
    end else begin 
        drain_vld <= 1'b0;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        drain_vld_d <= 1'b0;
        drain_reg_d <= 'b0;
    end else if( drain_vld ) begin 
        drain_reg_d <= drain_reg; 
        drain_vld_d <= 1'b1;
    end else begin 
        drain_vld_d <= 1'b0;
    end
end

// assign sum_out     = ({PSUM_WIDTH{stage2_last}} & partial_sum_next) | ({PSUM_WIDTH{drain_vld_d}} & drain_reg_d);
// assign sum_out_vld = drain_vld_d | stage2_last;
reg [PSUM_WIDTH-1:0] sum_out_reg;
reg                  sum_out_vld_reg;

always @(posedge clk) begin
    if (~rst_n) begin
        sum_out_reg     <= 'b0;
        sum_out_vld_reg <= 1'b0;
    end else begin
        sum_out_reg     <= ({PSUM_WIDTH{stage3_last}} & partial_sum_next) | ({PSUM_WIDTH{drain_vld_d}} & drain_reg_d);
        sum_out_vld_reg <= drain_vld_d | stage3_last;
    end
end

assign sum_out     = sum_out_reg;
assign sum_out_vld = sum_out_vld_reg;

endmodule
`default_nettype wire
