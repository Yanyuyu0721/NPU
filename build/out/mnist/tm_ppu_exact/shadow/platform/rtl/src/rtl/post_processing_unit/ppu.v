/*-----------------------------------------
file name  : ppu.v
created    : 2026/02/02 08:06:06
modified   : 2026-03-18 15:03:25
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module ppu # (
    parameter DWIDTH         = 32   , // PSUM_WIDTH
    parameter AXI_DATA_WIDTH = 64   , // Bus Data Width 
    parameter BUS_FIFO_DEPTH = 512  ,
    parameter RESCALE_WIDTH  = 18   ,
    parameter PPU_CMD_WIDTH  = 18 + 32 + 12 + 32 // rescale + bias + len + addr
)(
    input  wire                      clk              , 
    input  wire                      rst_n            ,

    input  wire                      bias_enable      ,
    input  wire                      rescale_enable   , 
    input  wire                      actfunc_enable   ,
    input  wire [2:0]                actfunc_type     , // 0: relu
    input  wire [8:0]                out_zp           ,

    output wire                      data_rdy         ,
    input  wire                      data_vld         ,
    input  wire [DWIDTH-1:0]         data             ,

    input  wire                      cmd_vld          ,
    input  wire [PPU_CMD_WIDTH-1:0]  cmd              , // rescale_coe: 18bit, bias: 32bit, len: 12bit,  addr: 32bit 
    output wire                      cmd_rdy          ,

    output reg                       bus_data_vld     ,
    output reg  [AXI_DATA_WIDTH-1:0] bus_data         ,

    output reg                       cmd_en           ,
    output reg  [31:0]               cmd_addr         ,
    output reg  [12:0]               cmd_data_num     ,

    output wire                      status           
);

localparam FIFO_WIDTH = 12 + 32;
reg [FIFO_WIDTH-1:0] task_fifo[3:0];
reg [1:0] wr_ptr, rd_ptr;
reg [2:0] fifo_count;

wire task_fifo_full = (fifo_count == 3'd4);
wire task_fifo_empty= (fifo_count == 3'd0);

wire [11:0] task_out_len;
wire [31:0] task_out_base_addr;
assign {task_out_base_addr, task_out_len} = task_fifo[rd_ptr];
reg task_pop;

wire [17:0] w_cmd_rescale_coe;
wire [31:0] w_cmd_bias ;
wire [11:0] w_cmd_len  ;
wire [31:0] w_cmd_addr ;

assign {w_cmd_rescale_coe, w_cmd_bias, w_cmd_len,w_cmd_addr} = cmd;

localparam s_idle = 1'b0;
localparam s_busy = 1'b1;

reg curr_state, next_state;
reg [11:0] proc_cnt_in ;

// level 0: register in pipeline 
reg [17:0] r_rescale_coe;
reg [31:0] r_bias       ;
reg [11:0] r_input_len  ;
// level 1: register in pipeline 
reg [17:0] r_rescale_coe_s1;
reg [17:0] r_rescale_coe_s2;

assign cmd_rdy  = (curr_state == s_idle) && (~task_fifo_full);
assign data_rdy = (curr_state == s_busy);

always @(posedge clk) begin 
    if(~rst_n) curr_state <= s_idle;
    else curr_state <= next_state;
end

always@(*) begin 
    case(curr_state) 
    s_idle: begin 
        if( cmd_vld & ~task_fifo_full) next_state = s_busy;
        else next_state = s_idle;
    end
    s_busy: begin 
        if( data_vld & (proc_cnt_in == r_input_len )) 
            next_state = s_idle;
        else 
            next_state = s_busy;
    end
    endcase
end

always @(posedge clk) begin 
    if(~rst_n) begin 
        proc_cnt_in   <= 'b0; 
        r_bias        <= 'b0;
        r_rescale_coe <= 'b0;
        r_input_len   <= 'b0;
        wr_ptr        <= 'b0;
        rd_ptr        <= 'b0;
        fifo_count    <= 'b0;

    end else begin 
        if( curr_state == s_idle && cmd_vld && ~task_fifo_full) begin 
            r_bias        <= w_cmd_bias;
            r_rescale_coe <= w_cmd_rescale_coe;
            r_input_len   <= w_cmd_len;
            proc_cnt_in   <= 12'b0; 
            task_fifo[wr_ptr] <= {w_cmd_addr , w_cmd_len};
            wr_ptr            <= wr_ptr + 1'b1;
            fifo_count        <= fifo_count + 1'b1;
        end else if( curr_state == s_busy && data_vld ) begin 
            if( proc_cnt_in == r_input_len ) proc_cnt_in <= 12'b0;
            else proc_cnt_in <= proc_cnt_in + 1'b1;
        end

        // pop logic
        if(( curr_state == s_idle ) && cmd_vld && ~task_fifo_full && task_pop ) begin 
            fifo_count <= fifo_count;
        end else if( task_pop ) begin 
            fifo_count <= fifo_count - 1'b1;
        end

        if( task_pop ) begin 
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

always@(posedge clk ) begin 
    if( data_vld & data_rdy ) begin 
        r_rescale_coe_s1 <= r_rescale_coe;
    end
end

reg            data_add_bias_vld;

always @(posedge clk) begin
    if (data_add_bias_vld) begin
        r_rescale_coe_s2 <= r_rescale_coe_s1; 
    end
end


// ------------- bias -------------- 
reg [DWIDTH:0] data_add_bias;
always@(posedge clk) begin 
    if( data_vld & data_rdy& bias_enable ) 
        data_add_bias <= $signed(data) + $signed(r_bias);
    else if( data_vld ) 
        data_add_bias <= $signed(data);
end
always @(posedge clk) begin 
    if( ~rst_n ) 
        data_add_bias_vld <= 1'b0;
    else  
        data_add_bias_vld <= data_vld & data_rdy;
end
// ------------- bias -------------- 

// ------------- relu ------------- 
reg  [DWIDTH:0] data_relu;
reg             data_relu_vld;
wire            is_relu_op = (actfunc_type == 3'b000); 

always @(posedge clk) begin 
    if (data_add_bias_vld) begin
        if (actfunc_enable & is_relu_op) begin 
            data_relu <= data_add_bias[DWIDTH] ? 'b0 : data_add_bias;
        end else begin 
            data_relu <= data_add_bias;
        end
    end
end

always @(posedge clk) begin 
    if (~rst_n) begin 
        data_relu_vld <= 1'b0;
    end else begin 
        data_relu_vld <= data_add_bias_vld;
    end
end

// assign data_relu_vld = data_add_bias_vld;
// always@(*) begin 
//     if( data_add_bias_vld & actfunc_enable & is_relu_op ) begin 
//         data_relu <= data_add_bias[DWIDTH] ? 'b0 :  data_add_bias;
//     end else if( data_add_bias_vld ) begin 
//         data_relu <= data_add_bias;
//     end
// end


// ------------- relu ------------- 

// ------------- rescale ----------- 
wire [RESCALE_WIDTH-1:0]   rescale_coe;
(* use_dsp = "yes" *) reg  [DWIDTH+RESCALE_WIDTH:0] rescale_data_tmp;
reg                        rescale_data_tmp_vld;

always@(posedge clk) begin 
    if( data_relu_vld & rescale_enable)
        rescale_data_tmp <= $signed(data_relu) * $signed(r_rescale_coe_s2);
    else if( data_relu_vld ) 
        rescale_data_tmp <= $signed(data_relu) << 16;
end

always @(posedge clk) begin 
    if( ~rst_n ) begin 
        rescale_data_tmp_vld <= 1'b0;
    end else begin 
        rescale_data_tmp_vld <= data_relu_vld ;
    end
end

wire signed [DWIDTH+RESCALE_WIDTH:0] rescale_data_rounded;
assign rescale_data_rounded = rescale_data_tmp + $signed('b1 << 15);

// A signed (DWIDTH+1) x RESCALE_WIDTH product, shifted by Q16, needs
// DWIDTH+RESCALE_WIDTH-15 bits. Keep them all until INT8 saturation.
localparam SCALED_WIDTH = DWIDTH + RESCALE_WIDTH - 15;
reg signed [SCALED_WIDTH-1:0] rescale_data_reg;
reg                   rescale_data_reg_vld;

always @(posedge clk) begin
    if (rescale_data_tmp_vld) begin
        rescale_data_reg <= rescale_data_rounded[DWIDTH+RESCALE_WIDTH:16];
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        rescale_data_reg_vld <= 1'b0;
    end else begin
        rescale_data_reg_vld <= rescale_data_tmp_vld;
    end
end

// reg signed [DWIDTH:0] rescale_data_reg;
// reg                   rescale_data_reg_vld;
// 
// always @(*) begin
//     rescale_data_reg = rescale_data_rounded[DWIDTH+RESCALE_WIDTH:16];
// end
// 
// always @(*) begin
//     rescale_data_reg_vld = rescale_data_tmp_vld;
// end

// ------------- rescale ----------- 

// ------------- zp & saturation -> int8 ----------- 
// wire signed [DWIDTH:0]   val_with_zp; 
// reg  signed [DWIDTH-1:0] scaled_data;
// reg                      scaled_data_vld;
// always @(posedge clk) begin 
//     if( ~rst_n ) begin 
//         scaled_data_vld <= 1'b0;
//     end else begin 
//         scaled_data_vld <= rescale_data_reg_vld;
//     end
// end
// assign val_with_zp = $signed(rescale_data_reg) + $signed(out_zp);
// 
// always@(posedge clk) begin 
//     if(rescale_data_reg_vld & rescale_enable) begin 
//         if( val_with_zp > 127 ) scaled_data <= {24'b0,8'd127}; 
//         else if( val_with_zp < -128 ) scaled_data <= {24'b0,-8'd128};
//         else scaled_data <= {24'b0,val_with_zp[7:0]};
//     end else if( rescale_data_reg_vld )begin 
//         scaled_data <= rescale_data_reg[31:0];
//     end
// end

reg signed [SCALED_WIDTH:0] r_val_with_zp;
reg signed [DWIDTH:0]   r_rescale_data_bypass;
reg                     r_val_with_zp_vld;

always @(posedge clk) begin 
    if(rescale_data_reg_vld) begin 
        if (rescale_enable) begin
            r_val_with_zp <= $signed(rescale_data_reg) + $signed(out_zp);
        end else begin
            r_rescale_data_bypass <= rescale_data_reg;
        end
    end
end

always @(posedge clk) begin 
    if (~rst_n) r_val_with_zp_vld <= 1'b0;
    else        r_val_with_zp_vld <= rescale_data_reg_vld;
end

reg  signed [DWIDTH-1:0] scaled_data;
reg                      scaled_data_vld;

always@(posedge clk) begin 
    if(r_val_with_zp_vld) begin 
        if (rescale_enable) begin
            if( r_val_with_zp > 127 ) 
                scaled_data <= {24'b0, 8'd127}; 
            else if( r_val_with_zp < -128 ) 
                scaled_data <= {24'b0, -8'd128};
            else 
                scaled_data <= {24'b0, r_val_with_zp[7:0]};
        end else begin 
            scaled_data <= r_rescale_data_bypass[31:0];
        end
    end
end

always @(posedge clk) begin 
    if( ~rst_n ) scaled_data_vld <= 1'b0;
    else         scaled_data_vld <= r_val_with_zp_vld;
end
// ------------- zp & saturation -> int8 ----------- 

// output logic   
localparam HALF_DEPTH_WITH_D    = (BUS_FIFO_DEPTH >> 1) * (AXI_DATA_WIDTH / DWIDTH);
localparam HALF_DEPTH_WITH_8BIT = (BUS_FIFO_DEPTH >> 1) * (AXI_DATA_WIDTH / 8);

wire [11:0] target_half_depth;
assign target_half_depth = rescale_enable ? HALF_DEPTH_WITH_8BIT : HALF_DEPTH_WITH_D;

localparam RATIO_D    = AXI_DATA_WIDTH / DWIDTH; 
localparam RATIO_8BIT = AXI_DATA_WIDTH / 8;      
localparam CNT_PACK_WIDTH = $clog2(RATIO_8BIT); 

wire [CNT_PACK_WIDTH:0] target_pack_num;
assign target_pack_num = rescale_enable ? RATIO_8BIT : RATIO_D;

reg [11:0]               cnt_out_processed; 
reg [11:0]               cnt_block;         
reg [CNT_PACK_WIDTH-1:0] cnt_pack;          
    
wire is_last_output = ~task_fifo_empty &&(cnt_out_processed == task_out_len);
wire is_block_full  = (cnt_block == target_half_depth - 1'b1);
wire is_pack_full   = (cnt_pack == target_pack_num - 1'b1);

always @(posedge clk) begin
    if (!rst_n) cnt_out_processed <= 12'd0;
    else if (scaled_data_vld) begin
        if (is_last_output) cnt_out_processed <= 12'd0;
        else                cnt_out_processed <= cnt_out_processed + 1'b1;
    end
end

always @(posedge clk) begin
    if (!rst_n) cnt_block <= 12'd0;
    else if (scaled_data_vld) begin
        if (is_block_full || is_last_output) cnt_block <= 12'd0;
        else                                 cnt_block <= cnt_block + 1'b1;
    end
end

always @(posedge clk) begin
    if (!rst_n) cnt_pack <= {CNT_PACK_WIDTH{1'b0}};
    else if (scaled_data_vld) begin
        if (is_pack_full || is_last_output) cnt_pack <= {CNT_PACK_WIDTH{1'b0}};
        else                                cnt_pack <= cnt_pack + 1'b1;
    end
end

// data pack
always @(posedge clk) begin
    if (!rst_n) begin
        bus_data     <= {AXI_DATA_WIDTH{1'b0}};
        bus_data_vld <= 1'b0;
    end else begin
        bus_data_vld <= 1'b0;
        if (scaled_data_vld) begin
            if (cnt_pack == 0) bus_data <= {AXI_DATA_WIDTH{1'b0}};
            
            if (rescale_enable) bus_data[cnt_pack*8 +: 8]           <= scaled_data[7:0];
            else                bus_data[cnt_pack*DWIDTH +: DWIDTH] <= scaled_data[DWIDTH-1:0];

            if (is_pack_full || is_last_output) begin
                bus_data_vld <= 1'b1;
            end
        end
    end
end

reg [31:0] r_addr_offset; 

always @(*) begin
    task_pop = 1'b0;
    if (scaled_data_vld && is_last_output) begin
        task_pop = 1'b1;
    end
end

wire [31:0] next_cmd_addr      = task_out_base_addr + r_addr_offset;
wire [31:0] inc_offset_rescale = r_addr_offset + {20'd0, (cnt_block + 1'b1)};
wire [31:0] inc_offset_normal  = r_addr_offset + ({20'd0, (cnt_block + 1'b1)} << 2);

// always @(posedge clk) begin
//     if (!rst_n) begin
//         r_addr_offset  <= 32'd0;
//         cmd_en         <= 1'b0 ;
//         cmd_addr       <= 32'd0;
//         cmd_data_num   <= 13'd0;
//     end else begin
//         cmd_en <= 1'b0;
// 
//         if (scaled_data_vld) begin
//             if (is_block_full || is_last_output) begin
//                 cmd_en   <= 1'b1;
//                 
//                 cmd_addr <= task_out_base_addr + r_addr_offset;
//                 
// 
//                 if (rescale_enable)
//                     cmd_data_num  <= cnt_block + 1'b1;
//                 else 
//                     cmd_data_num  <= (cnt_block + 1'b1) << 2;
// 
//                 if (is_last_output) begin
//                     r_addr_offset <= 32'd0;
//                 end else begin
//                     if (rescale_enable)
//                         r_addr_offset <= r_addr_offset + (cnt_block + 1'b1); 
//                     else
//                         r_addr_offset <= r_addr_offset + ((cnt_block + 1'b1) << 2);
//                 end
//             end
//         end
//     end
// end

always @(posedge clk) begin
    if (!rst_n) begin
        r_addr_offset  <= 32'd0;
        cmd_en         <= 1'b0 ;
        cmd_addr       <= 32'd0;
        cmd_data_num   <= 13'd0;
    end else begin
        cmd_en <= 1'b0;

        if (scaled_data_vld) begin
            if (is_block_full || is_last_output) begin
                cmd_en   <= 1'b1;
                
                cmd_addr <= next_cmd_addr;

                if (rescale_enable)
                    cmd_data_num  <= {1'b0, cnt_block} + 13'd1;
                else 
                    cmd_data_num  <= ({1'b0, cnt_block} + 13'd1) << 2;

                if (is_last_output) begin
                    r_addr_offset <= 32'd0;
                end else begin
                    r_addr_offset <= rescale_enable ? inc_offset_rescale : inc_offset_normal;
                end
            end
        end
    end
end

assign status = (curr_state == s_idle) && task_fifo_empty;

endmodule
`default_nettype wire
