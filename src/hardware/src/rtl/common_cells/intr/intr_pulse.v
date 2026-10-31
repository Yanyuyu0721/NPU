/*-----------------------------------------
file name  : intr_pulse.v
created    : 2026/01/10 21:01:29
modified   : 2026-01-11 15:46:05
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none 
module intr_pulse # (
    parameter NUM = 1 
)(
    input  wire                      clk                  , // (input )
    input  wire                      rst_n                , // (input )
    
    input  wire            [NUM-1:0] force_i              , // (input )
    input  wire            [NUM-1:0] pulse_i              , // (input )
    input  wire            [NUM-1:0] mask_i               , // (input )
    input  wire            [NUM-1:0] clear_i              , // (input )
    
    output reg             [NUM-1:0] status_o             , // (output)
    output reg             [NUM-1:0] raw_status_o          // (output)
);

wire [NUM-1:0] event_s;
wire [NUM-1:0] event_m;
assign event_s = force_i | pulse_i;
assign event_m = event_s & ~mask_i;

genvar i;
generate
    for( i = 0 ; i< NUM ; i=i+1 ) begin : intr_item
        always @(posedge clk) begin: status
            if( ~rst_n ) 
                status_o[i] <= 1'b0;
            else if( event_m[i] ) 
                status_o[i] <= 1'b1;
            else if( clear_i[i] ) 
                status_o[i] <= 1'b0;
        end

        always @(posedge clk) begin: raw_status
            if( ~rst_n ) 
                raw_status_o[i] <= 1'b0;
            else if( event_s[i] ) 
                raw_status_o[i] <= 1'b1;
            else if( clear_i[i] ) 
                raw_status_o[i] <= 1'b0;
        end
    end
endgenerate

endmodule
`default_nettype wire 


