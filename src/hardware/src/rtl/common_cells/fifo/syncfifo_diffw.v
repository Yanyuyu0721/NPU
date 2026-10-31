/**************************************
@ filename     : syncfifo_diffwidth.v
@ origin author: xu xiaokang
@ update by    : yyrwkk
@ create time  : 2025/03/28 21:51:18
@ version      : v1.0.0
**************************************/
`default_nettype none
module syncfifo_diffw # (
    parameter       DIN_WIDTH   = 8            , 
    parameter       DOUT_WIDTH  = 8            , 
    parameter       WADDR_WIDTH = 4            , 
    parameter       RAM_STYLE   = "distributed", 
    parameter [0:0] FWFT_EN     = 1            , 
    parameter [0:0] MSB_FIFO    = 1              
)(
  input  wire [DIN_WIDTH-1:0]  din         ,
  input  wire                  wr_en       ,
  output wire                  full        ,

  output wire [DOUT_WIDTH-1:0] dout        ,
  input  wire                  rd_en       ,
  output wire                  empty       ,

  input  wire                  clk         ,
  input  wire                  rst_n         
);

`ifndef FPGA_SOURCE 
wire [DIN_WIDTH-1:0]  wdata      ;
wire                  wdata_rd_en;
wire                  wdata_empty;

wire [DOUT_WIDTH-1:0] rdata      ;
wire                  rdata_wr_en;
wire                  rdata_full ;

genvar idx;
generate
    if( DOUT_WIDTH > DIN_WIDTH ) begin 
        syncfifo # (
            .DATA_WIDTH (DIN_WIDTH ),
            .ADDR_WIDTH (1         ),
            .RAM_STYLE  (RAM_STYLE ),
            .FWFT_EN    (1         )
        ) syncfifo_inst_w (
            .din          (din              ),
            .wr_en        (wr_en            ),
            .full         (full             ),
            .dout         (wdata            ),
            .rd_en        (wdata_rd_en      ),
            .empty        (wdata_empty      ),
            .clk          (clk              ),
            .rst_n        (rst_n            )
        );

        localparam RADDR_WIDTH = $clog2((2**WADDR_WIDTH) * DIN_WIDTH / DOUT_WIDTH);
        syncfifo # (
            .DATA_WIDTH (DOUT_WIDTH ),
            .ADDR_WIDTH (RADDR_WIDTH),
            .RAM_STYLE  (RAM_STYLE  ),
            .FWFT_EN    (FWFT_EN    )
        ) syncfifo_inst_r (
            .din          (rdata         ),
            .wr_en        (rdata_wr_en   ),
            .full         (rdata_full    ),
            .dout         (dout          ),
            .rd_en        (rd_en         ),
            .empty        (empty         ),
            .clk          (clk           ),
            .rst_n        (rst_n         )
        );

        assign wdata_rd_en = (~rdata_full) && (~wdata_empty);

        wire [DOUT_WIDTH-1:0] rdata_r;
        wire [DOUT_WIDTH-1:0] rdata_r_nxt;
        wire rdata_ld ;
        
        assign rdata_ld = wdata_rd_en;
        if (MSB_FIFO == 1) begin
            // always @(posedge clk) begin
            //     if (~rst_n)
            //         rdata_r <= 'd0;
            //     else if (wdata_rd_en)
            //         rdata_r <= {rdata_r[DOUT_WIDTH-DIN_WIDTH-1:0], wdata}; 
            //     else
            //         rdata_r <= rdata_r;
            // end
            assign rdata_r_nxt = {rdata_r[DOUT_WIDTH-DIN_WIDTH-1:0], wdata};
            gnrl_dfflr#(DOUT_WIDTH) gnrl_dfflr_inst_msb(rdata_ld,rdata_r_nxt,rdata_r,clk,rst_n);

            assign rdata = {rdata_r[DOUT_WIDTH-DIN_WIDTH-1:0], wdata}; 
        end else begin 
            // always @(posedge clk) begin
            //     if (~rst_n)
            //         rdata_r <= 'd0;
            //     else if (wdata_rd_en)
            //         rdata_r <= {wdata, rdata_r[DOUT_WIDTH-1 : DIN_WIDTH]}; // ÏÈ½øµÄÎªµÍÎ»
            //     else
            //         rdata_r <= rdata_r;
            // end
            assign rdata_r_nxt = {wdata, rdata_r[DOUT_WIDTH-1 : DIN_WIDTH]};
            gnrl_dfflr#(DOUT_WIDTH) gnrl_dfflr_inst_lsb(rdata_ld,rdata_r_nxt,rdata_r,clk,rst_n);
            assign rdata = {wdata, rdata_r[DOUT_WIDTH-1 : DIN_WIDTH]}; 
        end

        localparam WDATA_RD_EN_CNT_MAX = DOUT_WIDTH / DIN_WIDTH - 1;
        wire [$clog2(WDATA_RD_EN_CNT_MAX+1)-1 : 0] wdata_rd_en_cnt    ;
        wire [$clog2(WDATA_RD_EN_CNT_MAX+1)-1 : 0] wdata_rd_en_cnt_nxt;
        wire                                       wdata_rd_en_cnt_ld ;
        // always @(posedge clk) begin
        //     if (~rst_n)
        //         wdata_rd_en_cnt <= 'd0;
        //     else if (wdata_rd_en)
        //         wdata_rd_en_cnt <= wdata_rd_en_cnt + 1'b1;
        //     else
        //         wdata_rd_en_cnt <= wdata_rd_en_cnt;
        // end
        assign wdata_rd_en_cnt_ld  = wdata_rd_en ;
        assign wdata_rd_en_cnt_nxt = wdata_rd_en_cnt + 1'b1;
        gnrl_dfflr#($clog2(WDATA_RD_EN_CNT_MAX+1)) gnrl_dfflr_inst_cnt(wdata_rd_en_cnt_ld,wdata_rd_en_cnt_nxt,wdata_rd_en_cnt,clk,rst_n);

        assign rdata_wr_en = wdata_rd_en && (wdata_rd_en_cnt == WDATA_RD_EN_CNT_MAX);
    end else if (DOUT_WIDTH == DIN_WIDTH) begin 
        syncfifo # (
            .DATA_WIDTH (DIN_WIDTH  ),
            .ADDR_WIDTH (WADDR_WIDTH),
            .RAM_STYLE  (RAM_STYLE  ),
            .FWFT_EN    (FWFT_EN    )
        ) syncfifo_inst (
            .din          (din         ),
            .wr_en        (wr_en       ),
            .full         (full        ),
            .dout         (dout        ),
            .rd_en        (rd_en       ),
            .empty        (empty       ),
            .clk          (clk         ),
            .rst_n        (rst_n       )
        );
    end else begin 
        syncfifo # (
            .DATA_WIDTH (DIN_WIDTH  ),
            .ADDR_WIDTH (WADDR_WIDTH),
            .RAM_STYLE  (RAM_STYLE  ),
            .FWFT_EN    (1          )
        ) sync_fifo_inst_w (
            .din          (din         ),
            .wr_en        (wr_en       ),
            .full         (full        ),
            .dout         (wdata       ),
            .rd_en        (wdata_rd_en ),
            .empty        (wdata_empty ),
            .clk          (clk         ),
            .rst_n        (rst_n       )
        );

        syncfifo # (
            .DATA_WIDTH (DOUT_WIDTH),
            .ADDR_WIDTH (1         ),
            .RAM_STYLE  (RAM_STYLE ),
            .FWFT_EN    (FWFT_EN   )
        ) syncfifo_inst_r (
            .din          (rdata             ),
            .wr_en        (rdata_wr_en       ),
            .full         (rdata_full        ),
            .dout         (dout              ),
            .rd_en        (rd_en             ),
            .empty        (empty             ),
            .clk          (clk               ),
            .rst_n        (rst_n             )
        );

        assign rdata_wr_en = (~rdata_full) && (~wdata_empty);

        localparam RDATA_WR_EN_CNT_MAX = DIN_WIDTH/ DOUT_WIDTH - 1;
        wire [$clog2(RDATA_WR_EN_CNT_MAX+1)-1 : 0] rdata_wr_en_cnt    ;
        wire [$clog2(RDATA_WR_EN_CNT_MAX+1)-1 : 0] rdata_wr_en_cnt_nxt;
        wire                                       rdata_wr_en_cnt_ld ;

        // always @(posedge clk) begin
        //     if (~rst_n)
        //         rdata_wr_en_cnt <= 'd0;
        //     else if (rdata_wr_en)
        //         rdata_wr_en_cnt <= rdata_wr_en_cnt + 1'b1;
        //     else
        //         rdata_wr_en_cnt <= rdata_wr_en_cnt;
        // end

        assign rdata_wr_en_cnt_ld  = rdata_wr_en ;
        assign rdata_wr_en_cnt_nxt = rdata_wr_en_cnt + 1'b1;
        gnrl_dfflr #($clog2(RDATA_WR_EN_CNT_MAX+1)) gnrl_dfflr_inst_cnt(rdata_wr_en_cnt_ld,rdata_wr_en_cnt_nxt,rdata_wr_en_cnt,clk,rst_n);

        // not good, even bad !!!
        // if (MSB_FIFO == 1) begin
        //     wire [DIN_WIDTH-1:0] wdata_r ;
        //     assign wdata_r = wdata << (rdata_wr_en_cnt * DOUT_WIDTH);
        //     assign rdata = wdata_r[DIN_WIDTH-1 : DIN_WIDTH-DOUT_WIDTH];
        // end else begin
        //     wire [DIN_WIDTH-1:0] wdata_r ;
        //     assign wdata_r = wdata >> (rdata_wr_en_cnt * DOUT_WIDTH);
        //     assign rdata = wdata_r[DOUT_WIDTH-1 : 0];
        // end
        wire  [DOUT_WIDTH-1:0] wdata_r [RDATA_WR_EN_CNT_MAX+1-1:0];
        for( idx = 0;idx<RDATA_WR_EN_CNT_MAX+1;idx = idx + 1) begin 
           assign wdata_r[idx] = wdata[idx*DOUT_WIDTH+:DOUT_WIDTH];
        end

        if (MSB_FIFO == 1) begin
            assign rdata = wdata_r[~rdata_wr_en_cnt];
        end else begin 
            assign rdata = wdata_r[rdata_wr_en_cnt];
        end

        assign wdata_rd_en = rdata_wr_en && (rdata_wr_en_cnt == RDATA_WR_EN_CNT_MAX);
    end
endgenerate
`else 
localparam UNIT_WIDTH = (DIN_WIDTH < DOUT_WIDTH) ? DIN_WIDTH : DOUT_WIDTH;

// Input Swizzling
wire [DIN_WIDTH-1:0] din_xpm;
generate
    if (MSB_FIFO == 1 && DIN_WIDTH > UNIT_WIDTH) begin : gen_din_swap
        genvar i;
        for (i = 0; i < (DIN_WIDTH / UNIT_WIDTH); i = i + 1) begin : loop_din
            assign din_xpm[(i * UNIT_WIDTH) +: UNIT_WIDTH] = 
                din[((DIN_WIDTH/UNIT_WIDTH - 1 - i) * UNIT_WIDTH) +: UNIT_WIDTH];
        end 
     end else begin : gen_din_pass
        assign din_xpm = din;
    end
endgenerate

localparam FIFO_WRITE_DEPTH = 1 << WADDR_WIDTH;

wire [DOUT_WIDTH-1:0] dout_xpm;
wire rst_inv = ~rst_n;
    
// XPM distributed memory requires symmetric port widths. Width conversion
// therefore uses block RAM on all supported vendor versions.
localparam XPM_MEM_TYPE = (DIN_WIDTH != DOUT_WIDTH) ? "block" :
                          (RAM_STYLE == "distributed") ? "distributed" : 
                          (RAM_STYLE == "block")       ? "block"   : "auto";
localparam XPM_READ_MODE = (FWFT_EN == 1) ? "fwft" : "std";

xpm_fifo_sync #(
    .FIFO_MEMORY_TYPE(XPM_MEM_TYPE),
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH),
    .WRITE_DATA_WIDTH(DIN_WIDTH),
    .READ_DATA_WIDTH(DOUT_WIDTH),
    .READ_MODE(XPM_READ_MODE),
    .FIFO_READ_LATENCY(FWFT_EN ? 0 : 1),
    .USE_ADV_FEATURES("0000"),
    .RD_DATA_COUNT_WIDTH($clog2(FIFO_WRITE_DEPTH * DIN_WIDTH / DOUT_WIDTH) + 1),
    .WR_DATA_COUNT_WIDTH(WADDR_WIDTH + 1),
    .DOUT_RESET_VALUE("0"),
    .ECC_MODE("no_ecc"),
`ifndef EDGE_XPM_LEGACY
    .SIM_ASSERT_CHK(0),
    .CASCADE_HEIGHT(0),
`endif
    .WAKEUP_TIME(0)
)xpm_fifo_inst (
    .wr_clk(clk),
    .rst(rst_inv),
    .wr_en(wr_en),
    .din(din_xpm),  
    .full(full),
        
    .rd_en(rd_en),
    .dout(dout_xpm),
    .empty(empty),

    .data_valid(), .sleep(1'b0), .injectdbiterr(1'b0), .injectsbiterr(1'b0),
    .overflow(), .underflow(), .prog_empty(), .prog_full(),
    .rd_data_count(), .wr_data_count(), .sbiterr(), .dbiterr(),
    .wr_rst_busy(), .rd_rst_busy()
);

// Output Swizzling
generate
    if (MSB_FIFO == 1 && DOUT_WIDTH > UNIT_WIDTH) begin : gen_dout_swap
        genvar j;
        for (j = 0; j < (DOUT_WIDTH / UNIT_WIDTH); j = j + 1) begin : loop_dout
            assign dout[(j * UNIT_WIDTH) +: UNIT_WIDTH] = 
                   dout_xpm[((DOUT_WIDTH/UNIT_WIDTH - 1 - j) * UNIT_WIDTH) +: UNIT_WIDTH];
            end
        end 
    else begin : gen_dout_pass
        assign dout = dout_xpm;
    end
endgenerate

`endif

endmodule

`default_nettype wire 
