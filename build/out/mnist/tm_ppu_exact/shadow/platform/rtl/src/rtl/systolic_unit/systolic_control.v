/*-----------------------------------------
file name  : control_systolic_unit.v
created    : 2025/12/25 15:35:58
modified   : 2026-03-17 23:54:42
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module systolic_control #( 
    parameter PE_NCOL        = 8   , 
    parameter PE_NROW        = 8   ,
    parameter AXI_ADDR_WIDTH = 32  , // const
    parameter TAG_WIDTH      = 8   , // const
    parameter LEN_WIDTH      = 12  , // const
    parameter AXIS_USER_WIDTH= 3   , 
    parameter ICMD_LEN       = 60  , // const
    parameter OCMD_LEN       = AXI_ADDR_WIDTH + LEN_WIDTH+1 + AXIS_USER_WIDTH
)(
    input  wire                        clk                  , // (input )
    input  wire                        rst_n                , // (input )
    
    input  wire       [ICMD_LEN-1:0]   i_cmd                , // (input )
    input  wire                        i_cmd_vld            , // (input )
    output wire                        i_cmd_rdy            , // (input )
   
    output reg [11:0]                  calc_len             ,
    output reg                         last_en              ,
    
    output wire       [OCMD_LEN-1:0]   o_cmd                , // (output)
    output wire                        o_fifo_cmd_en        , // (output)
    output wire                        o_buf_cmd_en         , // (output)
    
    output reg                         rd_buf_id            , // (output)

    output reg         [PE_NCOL-1:0]   col_en               , // (output)
    output reg         [PE_NROW-1:0]   row_en               , // (output)
    output reg [PE_NCOL * ($clog2(PE_NROW-1)) - 1 : 0] raw_row_en ,
    
    output wire        [PE_NCOL-1:0]   col_start_en         , // (output)
    output wire        [PE_NROW-1:0]   row_start_en         , // (output)
    
    input  wire                        fifo_status_en       , // (input )
    input  wire                        buff_status_en       , // (input )
    input  wire                        calc_status_en       , // (input )
    
    output wire      [TAG_WIDTH-1:0]   systolic_status_tag  , // (output)
    output wire                        systolic_status_en     // (output)
);

localparam RAW_ROW_W = $clog2(PE_NROW-1);

wire i_cmd_en ;
wire is_fifo_cmd;
wire is_buf_cmd;
wire is_calc_cmd;
wire is_sync_cmd;
wire is_fifo_cmd_batch;
wire is_buf_cmd_batch;
assign i_cmd_en = i_cmd_rdy & i_cmd_vld;

assign is_buf_cmd    = ~(|i_cmd[4:0]);
assign is_fifo_cmd   = i_cmd[4:0] == 5'b00001;
assign is_calc_cmd   = i_cmd[4:0] == 5'b00010;
assign is_buf_cmd_batch    = i_cmd[4:0] == 5'b00011;
assign is_fifo_cmd_batch   = i_cmd[4:0] == 5'b00100;
assign is_sync_cmd   = &i_cmd[4:0];

wire [TAG_WIDTH-1  :0]       tag ;
wire [LEN_WIDTH+1-1:0]       len ;
wire [AXIS_USER_WIDTH-1:0]   user;
wire [AXI_ADDR_WIDTH-1:0]    addr;
assign tag = i_cmd[59:52];
assign len = i_cmd[53:42] + 1'b1;
assign user= i_cmd[39:37];
assign addr= i_cmd[36:5 ];

reg fifo_batch_reg, buf_batch_reg ;
wire batch_cmd_en  ;
assign batch_cmd_en = (is_fifo_cmd_batch | is_buf_cmd_batch ) & i_cmd_en;  
reg batch_status;
reg [2:0 ] batch_cnt;
reg [AXIS_USER_WIDTH-1:0] batch_reg; 
reg [LEN_WIDTH+1-1:0]     len_reg;
reg [TAG_WIDTH-1:0]       tag_reg;

wire batch_end;
assign batch_end = batch_cnt == batch_reg;
always @(posedge clk) begin 
    if( ~rst_n ) begin 
        batch_status <= 1'b0;
    end else if( batch_cmd_en ) begin 
        batch_status  <= 1'b1;
    end else if(batch_end) begin 
        batch_status  <= 1'b0;
    end
end

reg  sync_resp_enable;
always@(posedge clk) begin 
    if( is_sync_cmd & i_cmd_en ) 
        sync_resp_enable <= i_cmd[5];
end

always@(posedge clk ) begin 
    if( batch_cmd_en ) begin 
        batch_cnt <= {AXIS_USER_WIDTH{1'b0}};
    end else if(batch_status) begin 
        batch_cnt <= batch_cnt + 1'b1;
    end
end

always @(posedge clk) begin 
    if( batch_cmd_en ) begin 
        fifo_batch_reg <= is_fifo_cmd_batch;
        buf_batch_reg  <= is_buf_cmd_batch;
    end
end

always@(posedge clk) begin 
    if( i_cmd_en ) begin  
        batch_reg <= user;
        len_reg   <= len;
        tag_reg   <= tag;
    end
end

reg [31:0] batch_addr; 
always@(posedge clk) begin 
    if( batch_cmd_en ) begin 
        batch_addr <= addr;
    end else if( batch_status ) begin 
        batch_addr <= batch_addr + len_reg ;
    end
end

wire [OCMD_LEN-1:0] batch_cmd;
wire [OCMD_LEN-1:0] normal_cmd; 
assign batch_cmd = {batch_addr,len_reg, batch_cnt};
assign normal_cmd = {addr,len, user};
assign o_cmd = batch_status ? batch_cmd : normal_cmd; 
assign o_fifo_cmd_en   =  batch_status ? fifo_batch_reg  : (is_fifo_cmd & i_cmd_en);
assign o_buf_cmd_en    =  batch_status ? buf_batch_reg   : (is_buf_cmd  & i_cmd_en);

reg [PE_NCOL-1:0]   col_en_decoded_reg;
reg [PE_NROW-1:0]   row_en_decoded_reg;
reg [RAW_ROW_W-1:0] raw_row_en_decoded_reg;
reg                 calc_cmd_en_d1;
always@(posedge clk) begin 
    if( is_calc_cmd & i_cmd_en ) begin     
        rd_buf_id <= i_cmd[13:13];
        raw_row_en_decoded_reg <= i_cmd[8:5]  ;
        col_en_decoded_reg  <= (1 << (i_cmd[12:9] + 5'b1))  - 1'b1; 
        row_en_decoded_reg  <= (1 << (i_cmd[8:5]  + 5'b1 )) - 1'b1;
        last_en   <= i_cmd[14:14];
        calc_len  <= i_cmd[26:15];
    end
end

always @(posedge clk) begin 
    if( ~rst_n ) begin 
        calc_cmd_en_d1 <= 1'b0;
    end else begin 
        calc_cmd_en_d1 <= is_calc_cmd & i_cmd_en;
    end
end

reg  [PE_NCOL-1:0] col_en_pipe [0:PE_NCOL-1];
reg  [PE_NROW-1:0]   row_en_pipe [0:PE_NROW-1];
reg  [RAW_ROW_W-1:0] raw_row_en_pipe [0:PE_NCOL-1];
always @(posedge clk ) begin
    if (calc_cmd_en_d1) begin
        col_en_pipe[0] <= col_en_decoded_reg;
        row_en_pipe[0] <= row_en_decoded_reg;
        raw_row_en_pipe[0] <= raw_row_en_decoded_reg;
    end
end

genvar gc,gr;
generate
    for (gc = 1; gc < PE_NCOL; gc = gc + 1) begin : gen_col_pipe
        always @(posedge clk ) begin
            col_en_pipe[gc] <= col_en_pipe[gc-1];
            raw_row_en_pipe[gc] <= raw_row_en_pipe[gc-1];
        end
    end

    for (gc = 0; gc < PE_NCOL; gc = gc + 1) begin : gen_col_out
        always @(*) begin
            col_en[gc] = col_en_pipe[gc][gc];
            raw_row_en[gc * RAW_ROW_W +: RAW_ROW_W] = raw_row_en_pipe[gc];
        end
    end

    for (gr = 1; gr < PE_NROW; gr = gr + 1) begin : gen_row_pipe
        always @(posedge clk ) begin
            row_en_pipe[gr] <= row_en_pipe[gr-1];
        end
    end

    for (gr = 0; gr < PE_NROW; gr = gr + 1) begin : gen_row_out
        always @(*) begin
            row_en[gr] = row_en_pipe[gr][gr];
        end
    end
endgenerate

localparam NPE_MAX = PE_NCOL > PE_NROW  ? (PE_NCOL+1) : (PE_NROW + 1); 
reg [NPE_MAX-1:0] shift_ctrl;

genvar i,j,k;
generate
    for( i=0;i<NPE_MAX;i=i+1 ) begin: shift_ctrl_item
        if( i == 0 ) begin 
            always @(posedge clk) begin 
                if( ~rst_n ) begin 
                    shift_ctrl[i] <= 1'b0;
                end else if( is_calc_cmd & i_cmd_en ) begin 
                    shift_ctrl[i] <= 1'b1;
                end else begin 
                    shift_ctrl[i] <= 1'b0;
                end
            end
        end else begin 
            always @(posedge clk) begin 
                if( ~rst_n ) begin 
                    shift_ctrl[i] <= 1'b0;
                end else begin 
                    shift_ctrl[i] <= shift_ctrl[i-1];
                end
            end
        end
    end

    for( j=0;j<PE_NCOL;j=j+1 ) begin: col_start_en_item 
        assign col_start_en[j] = shift_ctrl[j+1] & col_en[j];
    end

    for( k=0;k<PE_NROW;k=k+1 ) begin: row_start_en_item 
        assign row_start_en[k] = shift_ctrl[k+1] & row_en[k];
    end
endgenerate 

// +++++ sync instruction 
wire [1:0] count1_lay0 , count1_lay1;
wire [2:0] count1, count1_dec1;
assign count1_lay0 = fifo_status_en + buff_status_en;
assign count1      = count1_lay0 + calc_status_en;
assign count1_dec1 = count1 - 1'b1;

wire cmd_cnt_inc_en;
wire cmd_cnt_dec_en;
assign cmd_cnt_inc_en = (is_calc_cmd & i_cmd_en) | o_fifo_cmd_en | o_buf_cmd_en ; 
assign cmd_cnt_dec_en = fifo_status_en | buff_status_en | calc_status_en;

reg [6:0] cmd_cnt_reg;
always @(posedge clk) begin
    if( ~rst_n ) 
        cmd_cnt_reg <= 'b0;
    else if( cmd_cnt_inc_en & cmd_cnt_dec_en) 
        cmd_cnt_reg <= cmd_cnt_reg - count1_dec1;
    else if( cmd_cnt_inc_en )
        cmd_cnt_reg <= cmd_cnt_reg + 1'b1;
    else if( cmd_cnt_dec_en ) 
        cmd_cnt_reg <= cmd_cnt_reg - count1;
end

wire cmd_cnt_reg_zero;
assign cmd_cnt_reg_zero = ~(|cmd_cnt_reg);

wire all_clear;
reg sync_status;
reg [TAG_WIDTH-1:0] sync_tag_reg;
always @(posedge clk) begin 
    if( ~rst_n ) 
        sync_status <= 1'b0;
    else if( i_cmd_en & is_sync_cmd ) 
        sync_status <= 1'b1;
    else if( all_clear ) 
        sync_status <= 1'b0;
end

assign all_clear = sync_status & cmd_cnt_reg_zero;
assign systolic_status_en  = all_clear & sync_resp_enable ;
assign systolic_status_tag = tag_reg;
// ----- sync instruction 

assign i_cmd_rdy = ~batch_status & ~sync_status;

endmodule

`default_nettype wire 