/*-----------------------------------------
file name  : axis_4to1.v
created    : 2025/12/24 21:39:11
modified   : 2026-02-06 21:49:19
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
module axis_4to1 # (
    parameter DWIDTH = 32 
)(
    input  wire [3:0]           axis_valid_i   ,
    input  wire [4*DWIDTH-1:0]  axis_data_i    ,
    output reg  [3:0]           axis_ready_i   ,
    input  wire [1:0]           axis_user      ,


    output wire                 axis_valid_o   ,
    output wire [DWIDTH-1:0]    axis_data_o    ,  
    input  wire                 axis_ready_o   
);

assign axis_data_o  = axis_data_i[axis_user * DWIDTH +: DWIDTH];
assign axis_valid_o = axis_valid_i[axis_user];

always @(*) begin
    axis_ready_i = 4'b0000;
    axis_ready_i[axis_user] = axis_ready_o;
end

endmodule
`default_nettype wire
