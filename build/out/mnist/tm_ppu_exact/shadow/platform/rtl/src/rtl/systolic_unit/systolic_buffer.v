/*-----------------------------------------
file name  : systolic_buffer.v
created    : 2025/12/03 22:16:18
modified   : 2026-03-18
description: Fixed Multiple Driver issue on processed_cnt
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module systolic_buffer # ( 
    parameter integer DIWIDTH       = 32  , 
    parameter integer DOWIDTH       = 8   , 
    parameter integer CHANNEL       = 2   , // now const for 2, TODO 
    parameter integer AWIDTH        = 10   
)(
    input  wire                       clk           ,
    input  wire                       rst_n         ,
    
    // Axis Input
    input  wire                       axis_vld      ,
    input  wire                       axis_last     ,
    input  wire [DIWIDTH-1:0]         axis_data     ,
    output wire                       axis_rdy      ,

    // Control
    input  wire                       rd_buf_id     , 
    input  wire [11:0]                calc_len      , 
    input  wire                       start_en      ,
    input  wire                       last_en       , 

    // Status & Output
    output wire                       wr_buf_id     , 
    output wire                       out_start     ,
    output wire                       out_vld       ,
    output wire [DOWIDTH*CHANNEL-1:0] out_data      , 
    output wire                       out_last      ,
    output reg                        chunk_done    , // every K chunk, independent of last_en

    input  wire                       update_pingpong
);

// ============================================================
// 1. parameter 
// ============================================================
localparam integer READ_RAM_WIDTH = DOWIDTH * CHANNEL;
localparam integer RATIO = DIWIDTH / READ_RAM_WIDTH;
localparam integer EXTRA_ADDR_BITS = $clog2(RATIO);
localparam integer READ_ADDR_WIDTH = AWIDTH + EXTRA_ADDR_BITS;
localparam integer WRITE_DEPTH = 1 << AWIDTH;

assign axis_rdy = 1'b1;

// ============================================================
// 2. write logic (Ping-Pong)
// ============================================================
reg  cur_wr_buf_id;     
reg  [AWIDTH-1:0] wr_addr;

always @(posedge clk) begin 
    if (~rst_n) begin
        cur_wr_buf_id <= 1'b0; 
        wr_addr       <= 'b0;
    end else if(update_pingpong) begin 
        cur_wr_buf_id <= 1'b0; 
        wr_addr       <= 'b0;
    end else if (axis_vld) begin
        if (axis_last) begin 
            cur_wr_buf_id <= ~cur_wr_buf_id; 
            wr_addr       <= 'b0; 
        end else begin 
            wr_addr       <= wr_addr + 1'b1;
        end
    end
end
assign wr_buf_id = cur_wr_buf_id;

// ============================================================
// 3. RAM 
// ============================================================
wire [READ_RAM_WIDTH-1:0]  ram0_rdata, ram1_rdata;
reg  [READ_ADDR_WIDTH-1:0] ram_rd_addr; 
wire                       ram_rd_en;

simple_dp_ram #(
    .WRITE_WIDTH(DIWIDTH),      // 32 
    .READ_WIDTH(READ_RAM_WIDTH),// 16
    .WRITE_DEPTH(WRITE_DEPTH)   // 1024
) u_ram0 (
    .clk(clk),
    .wr_en(axis_vld && (cur_wr_buf_id == 1'b0)),
    .wr_addr(wr_addr),
    .din(axis_data),
    .rd_en(ram_rd_en),
    .rd_addr(ram_rd_addr),
    .dout(ram0_rdata)
);

simple_dp_ram #(
    .WRITE_WIDTH(DIWIDTH),
    .READ_WIDTH(READ_RAM_WIDTH),
    .WRITE_DEPTH(WRITE_DEPTH)
) u_ram1 (
    .clk(clk),
    .wr_en(axis_vld && (cur_wr_buf_id == 1'b1)),
    .wr_addr(wr_addr),
    .din(axis_data),
    .rd_en(ram_rd_en),
    .rd_addr(ram_rd_addr),
    .dout(ram1_rdata)
);

// ============================================================
// 4. read logic (Status & Counters)
// ============================================================
reg [12:0] target_len;    
reg        is_running;
reg        active_rd_buf_id;
reg        latched_last_en; 

// 独立抽出 processed_cnt 解决多驱动问题
reg [12:0] processed_cnt; 

always @(posedge clk) begin
    if (~rst_n) begin
        processed_cnt <= 13'b0;
    end else if (start_en) begin
        processed_cnt <= 13'b0;  
    end else if (is_running && (processed_cnt < target_len)) begin
        processed_cnt <= processed_cnt + 2; 
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        is_running       <= 1'b0;
        target_len       <= 'b0;
        active_rd_buf_id <= 1'b0;
        latched_last_en  <= 1'b0;
    end else if (start_en) begin
        is_running       <= 1'b1;
        target_len       <= {1'b0, calc_len} + 1'b1; 
        active_rd_buf_id <= rd_buf_id;
        latched_last_en  <= last_en; 
    end else if (processed_cnt >= target_len) begin
        is_running       <= 1'b0;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        ram_rd_addr <= 'b0;
    end else if (start_en) begin
        // ? 关键修复点：start_en 脉冲时，当前在读地址 0
        // 为保证下一拍能读出地址 1 的数据，这里必须赋值为 1！
        ram_rd_addr <= 'd1; 
    end else if (is_running && (processed_cnt < target_len)) begin
        ram_rd_addr <= ram_rd_addr + 1'b1;
    end else begin 
        ram_rd_addr <= 'b0; // 闲置时复位为 0，使得下一个 start_en 周期能命中地址 0
    end
end

assign ram_rd_en = is_running || start_en;

// ============================================================
// 5. output logic (CHANNEL=2) 
// ============================================================

wire [READ_RAM_WIDTH-1:0] current_ram_word;
assign current_ram_word = (active_rd_buf_id == 1'b1) ? ram1_rdata : ram0_rdata;

wire [DOWIDTH-1:0] raw_low_word  = current_ram_word[DOWIDTH-1 : 0];
wire [DOWIDTH-1:0] raw_high_word = current_ram_word[2*DOWIDTH-1 : DOWIDTH];

reg [READ_RAM_WIDTH-1:0] out_data_reg;
reg                      out_vld_reg;
reg                      out_last_reg;
reg                      out_start_reg;

always @(posedge clk) begin
    if (~rst_n) begin
        out_vld_reg   <= 1'b0;
        out_data_reg  <= 'b0;
        out_last_reg  <= 1'b0;
        out_start_reg <= 1'b0;
    end else begin
        if (start_en) begin
            out_vld_reg   <= 1'b0;
            out_data_reg  <= 'b0;
            out_last_reg  <= 1'b0;
            out_start_reg <= 1'b0;
        end else if (is_running) begin
            if (processed_cnt < target_len) begin
                out_vld_reg <= 1'b1;

                // channel 0 (Low)
                out_data_reg[DOWIDTH-1 : 0] <= raw_low_word;
                
                if( processed_cnt == 0 ) begin 
                    out_start_reg <= 1'b1;
                end else begin 
                    out_start_reg <= 1'b0;
                end
                
                // channel 1 (High)
                if ((processed_cnt + 1) < target_len) begin
                    out_data_reg[2*DOWIDTH-1 : DOWIDTH] <= raw_high_word;
                end else begin
                    out_data_reg[2*DOWIDTH-1 : DOWIDTH] <= {DOWIDTH{1'b0}}; // Zero Padding
                end

                // last 
                if ((processed_cnt + 2) >= target_len) begin
                    out_last_reg <= latched_last_en; 
                end else begin
                    out_last_reg <= 1'b0;
                end

            end else begin
                // idle 
                out_vld_reg   <= 1'b0;
                out_data_reg  <= 'b0;
                out_last_reg  <= 1'b0;
                out_start_reg <= 1'b0;
            end
        end else begin
            // not running
            out_vld_reg   <= 1'b0;
            out_data_reg  <= 'b0;
            out_last_reg  <= 1'b0;
            out_start_reg <= 1'b0;
        end
    end
end

// Retire the command on the same final-data edge as out_last. Nonfinal
// K chunks retain their psums (out_last stays low) but must release SYNC.
// start_en has the same priority as the existing output pipeline.
always @(posedge clk) begin
    if (~rst_n)
        chunk_done <= 1'b0;
    else
        chunk_done <= !start_en && is_running &&
                      (processed_cnt < target_len) &&
                      ((processed_cnt + 2) >= target_len);
end

assign out_vld  = out_vld_reg ;
assign out_data = out_data_reg;
assign out_last = out_last_reg;
assign out_start= out_start_reg;

endmodule

`default_nettype wire