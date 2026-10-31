/*-----------------------------------------
file name  : stack.v
created    : 2026/01/28 12:06:09
modified   : 2026-01-28 12:35:52
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/

`default_nettype none

module stack # (
    parameter integer DATA_WIDTH = 32,
    parameter integer DEPTH      = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  clear,    

    input  wire                  push,
    input  wire [DATA_WIDTH-1:0] din,

    input  wire                  pop,
    output wire [DATA_WIDTH-1:0] dout,
    
    output wire                  empty,
    output wire                  full
);
    localparam PTR_WIDTH = $clog2(DEPTH + 1);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_WIDTH-1:0]  sp;

    assign empty = (sp == {PTR_WIDTH{1'b0}});
    assign full  = (sp == DEPTH[PTR_WIDTH-1:0]);
    assign dout  = empty ? {DATA_WIDTH{1'b0}} : mem[sp - 1'b1];

    always @(posedge clk) begin
        if (!rst_n) begin
            sp <= {PTR_WIDTH{1'b0}};
        end else if (clear) begin
            sp <= {PTR_WIDTH{1'b0}};
        end else begin
            if (push && !full) begin
                mem[sp] <= din;
                sp      <= sp + 1'b1;
            end else if (pop && !empty) begin
                sp      <= sp - 1'b1;
            end
        end
    end
endmodule

`default_nettype wire
