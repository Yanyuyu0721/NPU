/*-----------------------------------------
file name  : systolic_array.v
created    : 2025/12/02 01:07:47
modified   : 2026-03-17 23:54:01
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module systolic_array # (
    parameter DIWIDTH = 8     ,
    parameter CHANNEL = 2     , 
    parameter NROW    = 8     ,
    parameter NCOL    = 8     ,
    parameter PSUM_WIDTH = 32 ,// TODO
    parameter DWIDTH  = DIWIDTH * CHANNEL 
)(
    input wire                              clk           ,
    input wire                              rst_n         ,

    input wire  [NROW-1:0             ]     vld_a_in      ,
    input wire  [NROW-1:0             ]     pe_rowen      ,
    input wire  [NROW*DWIDTH-1:0      ]     activation_in ,

    input wire  [NCOL*$clog2(NROW-1)-1:0   ]     raw_row_en    ,
    input wire  [NCOL-1:0             ]     col_start     ,

    input wire  [NCOL-1:0             ]     vld_w_in      ,
    input wire  [NCOL-1:0             ]     pe_start      ,
    input wire  [NROW*DWIDTH-1:0      ]     weight_in     , 
    input wire  [NCOL-1:0             ]     last_in       ,
    
    // output logic 
    output wire [NCOL-1:0             ]     vld_out       ,
    output wire [NCOL*PSUM_WIDTH-1:0  ]     res_out          // TODO
);

wire [DWIDTH-1:0]      activation_pipe [NROW-1:0][NCOL-1:0];
wire                   vld_a_pipe      [NROW-1:0][NCOL-1:0];
wire                   last_pipe       [NROW-1:0][NCOL-1:0];

wire [DWIDTH-1:0]      weight_pipe     [NROW-1:0][NCOL-1:0];
wire                   vld_w_pipe      [NROW-1:0][NCOL-1:0];

wire [PSUM_WIDTH-1:0]  sum_data_pipe   [NROW-1:0][NCOL-1:0];
wire                   sum_vld_pipe    [NROW-1:0][NCOL-1:0];

wire                   pe_start_pipe   [NROW-1:0][NCOL-1:0];

genvar col, row;
generate 
    for( row = 0; row < NROW; row = row + 1 ) begin : row_gen
        for( col = 0; col < NCOL; col = col + 1 ) begin : col_gen            
            wire [DWIDTH-1:0]  pe_act_in;
            wire               pe_vld_a_in;
            wire               pe_last_in;      

            // horizontal inputs
            if (col == 0) begin
                assign pe_act_in   = activation_in[row*DWIDTH +: DWIDTH];
                assign pe_vld_a_in = vld_a_in[row];
            end else begin
                assign pe_act_in   = activation_pipe[row][col-1];
                assign pe_vld_a_in = vld_a_pipe[row][col-1];
            end 

            // vertical inputs( weight )
            wire [DWIDTH-1:0]  pe_w_in;
            wire               pe_vld_w_in;

            if (row == 0) begin
                assign pe_w_in     = weight_in[col*DWIDTH +: DWIDTH];
                assign pe_vld_w_in = vld_w_in[col];
            end else begin
                assign pe_w_in     = weight_pipe[row-1][col];
                assign pe_vld_w_in = vld_w_pipe[row-1][col];
            end
            
            // vertical inputs
            wire [PSUM_WIDTH-1:0] pe_sum_in;
            wire                  pe_sum_in_vld;

            if (row == 0) begin
                assign pe_sum_in     = {PSUM_WIDTH{1'b0}};
                assign pe_sum_in_vld = 1'b0;
            end else begin
                assign pe_sum_in     = sum_data_pipe[row-1][col];
                assign pe_sum_in_vld = sum_vld_pipe [row-1][col];
            end

            wire pe_start_in_node;        
            if (row == 0) begin
                // Top Row: Take from module input port
                assign pe_start_in_node = pe_start[col];
                assign pe_last_in  = last_in[col];
            end else begin
                // Other Rows: Take from Upper Neighbor's Output
                assign pe_start_in_node = pe_start_pipe[row-1][col];
                assign pe_last_in       = last_pipe[row-1][col];
            end

            systolic_pe #(
                .DWIDTH    (DIWIDTH   ),
                .CHANNEL   (CHANNEL   ),
                .PSUM_WIDTH(PSUM_WIDTH)
            ) u_systolic_pe (
                .clk            (clk),
                .rst_n          (rst_n),
                
                // control
                .pe_en          (pe_rowen[row]),  
                .pe_start_in    (pe_start_in_node),    // [Connected]
                .pe_start_out   (pe_start_pipe[row][col]), // [Connected]

                // activation
                .vld_a_in       (pe_vld_a_in),
                .last_in        (pe_last_in),
                .activation_in  (pe_act_in),
                .activation_out (activation_pipe[row][col]),
                .vld_a_out      (vld_a_pipe[row][col]),
                .last_out       (last_pipe[row][col]),
    
                // weight
                .vld_w_in       (pe_vld_w_in),
                .weight_in      (pe_w_in),
                .weight_out     (weight_pipe[row][col]),
                .vld_w_out      (vld_w_pipe[row][col]),

                // sum chain
                .sum_in         (pe_sum_in),
                .sum_in_vld     (pe_sum_in_vld),
                .sum_out        (sum_data_pipe[row][col]),
                .sum_out_vld    (sum_vld_pipe[row][col])
            );
        end
    end
endgenerate  

genvar k;
generate
    for (k = 0; k < NCOL; k = k + 1) begin : out_map
        systolic_reorder # (
            .DATA_WIDTH (PSUM_WIDTH     ),
            .MAX_DEPTH  (NROW           ), 
            .ROWWIDTH   ($clog2(NROW-1) )  
        )u_systolic_reorder(
            .clk                          (clk                          ), // (input )
            .rst_n                        (rst_n                        ), // (input )

            // --- Configuration ---
            .start_en                     (col_start[k]                 ), // (input )
            .row_en                       (raw_row_en[k*$clog2(NROW-1) +: $clog2(NROW-1)]  ), // (input )

            // --- Write Interface (From Systolic Array, Reverse Order) ---
            .data_in_vld                  (sum_vld_pipe [NROW-1][k]     ), // (input )
            .data_in                      (sum_data_pipe[NROW-1][k]     ), // (input )

            // --- Read Interface (Variable Length = row_en) ---
            .data_out_vld                 (vld_out[k]                         ), // (output)
            .data_out                     (res_out[k*PSUM_WIDTH +: PSUM_WIDTH]) // (output)
        );
    end
endgenerate

endmodule 
`default_nettype wire