/*-----------------------------------------
file name  : round_robin_arbiter.v
created    : 2026/02/02 22:20:56
modified   : 2026-02-06 21:24:04
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none 
module round_robin_arbiter # (
    parameter N = 8 
)(
    input  wire         clk  ,
    input  wire         rst_n,
    input  wire [N-1:0] req  ,
    output wire [N-1:0] grant
);

reg  [N-1:0] rotate_ptr;
wire [N-1:0] mask_req;
wire [N-1:0] mask_grant;
wire [N-1:0] nomask_grant;
wire [N-1:0] grant_comb;
wire         no_mask_req;
wire         update_ptr;

assign mask_req = req & rotate_ptr;

assign mask_grant[0] = mask_req[0];
genvar i0;
generate
    for (i0 = 1; i0 < N; i0 = i0 + 1) begin : gen_mask_grant
        assign mask_grant[i0] = mask_req[i0] & (~|mask_req[i0-1:0]);
    end
endgenerate

assign nomask_grant[0] = req[0];

genvar i1;
generate
    for (i1 = 1; i1 < N; i1 = i1 + 1) begin : gen_nomask_grant
        assign nomask_grant[i1] = req[i1] & (~|req[i1-1:0]);
    end
endgenerate

assign no_mask_req = (mask_req == {N{1'b0}});
assign grant_comb  = no_mask_req ? nomask_grant : mask_grant;

assign update_ptr = |grant_comb;

wire [N-1:0] next_rotate_ptr; 
genvar j;
generate
    for (j = 0; j < N; j = j + 1) begin : gen_next_ptr
        if (j == 0) begin
            assign next_rotate_ptr[0] = grant_comb[N-1];
        end else begin
            assign next_rotate_ptr[j] = grant_comb[N-1] | (|grant_comb[j-1:0]);
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rotate_ptr <= {N{1'b1}};
    end else if (update_ptr) begin
        rotate_ptr <= next_rotate_ptr;
    end
end

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) 
//         grant <= {N{1'b0}};
//     else 
//         grant <= grant_comb;
// end
assign grant = grant_comb;

endmodule

`default_nettype wire
