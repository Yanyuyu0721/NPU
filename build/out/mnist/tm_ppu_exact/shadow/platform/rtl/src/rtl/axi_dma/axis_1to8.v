/*-----------------------------------------
file name  : axis_1to16.v
created    : 2025/12/16 15:10:25
modified   : 2026-03-18 02:05:40
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module axis_1to8 # (
    parameter DWIDTH = 32 
)(
    input  wire                 clk            ,
    input  wire                 rst_n          ,
    input  wire                 axis_valid_i   ,
    input  wire                 axis_last_i    ,
    input  wire [DWIDTH-1:0]    axis_data_i    ,
    output wire                 axis_ready_i   ,
    input  wire [2:0]           axis_user_i    ,

    output wire [7:0]           axis_valid_o   ,
    output wire [7:0]           axis_last_o    ,
    output wire [8*DWIDTH-1:0]  axis_data_o    ,  
    input  wire [7:0]           axis_ready_o    
);

// assign axis_ready_i = axis_ready_o[axis_user_i];
// // assign axis_data_o  = axis_data_i ;  // connect to 8 port 
// genvar i;
// generate 
//     for( i = 0 ;i< 8 ;i = i+1 ) begin : item
//         wire is_self = (axis_user_i == i);
//         
//         assign axis_valid_o[i] = axis_valid_i & is_self;
//         assign axis_last_o[i]  = axis_last_i  & is_self;
//         
//         assign axis_data_o[i*DWIDTH +: DWIDTH] = axis_data_i; 
//     end
// endgenerate

// skid buffer timming opt
wire [7:0] pipe_ready_in;

assign axis_ready_i = pipe_ready_in[axis_user_i];
genvar i;
generate 
    for( i = 0 ; i < 8 ; i = i+1 ) begin : gen_router_pipes
        wire is_sel      = (axis_user_i == i);
        wire ch_valid_in = axis_valid_i & is_sel;
        
        wire [DWIDTH:0] payload_in = {axis_last_i, axis_data_i};
        wire [DWIDTH:0] payload_out;

        bwdfwdpipe #(
            .DWIDTH(DWIDTH + 1)
        ) u_bwdfwdpipe (
            .clk     (clk),
            .rst_n   (rst_n),
            
            .s_valid (ch_valid_in),
            .s_data  (payload_in),
            .s_ready (pipe_ready_in[i]),
            
            .m_valid (axis_valid_o[i]),
            .m_data  (payload_out),
            .m_ready (axis_ready_o[i])
        );
        
        assign axis_last_o[i] = payload_out[DWIDTH]; 
        assign axis_data_o[i*DWIDTH +: DWIDTH] = payload_out[DWIDTH-1:0]; 
    end
endgenerate

endmodule

`default_nettype wire 