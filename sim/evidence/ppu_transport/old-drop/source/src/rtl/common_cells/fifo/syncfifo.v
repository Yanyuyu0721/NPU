/**************************************
@ filename     : syncfifo.v
@ origin author: anonymous contributor
@ update by    : anonymous contributor
@ create time  : 2025/03/28 14:38:08
@ version      : v1.0.0
**************************************/
`default_nettype none
module syncfifo # (
    parameter       DATA_WIDTH    = 8            , 
    parameter       ADDR_WIDTH    = 4            , 
    parameter       RAM_STYLE     = "distributed", 
    parameter [0:0] FWFT_EN       = 1              
)(
    input  wire [DATA_WIDTH-1:0]  din          ,
    input  wire                   wr_en        ,
    output wire                   full         ,
    
    output wire [DATA_WIDTH-1:0]  dout         ,
    input  wire                   rd_en        ,
    output wire                   empty        ,
    
    input  wire                   clk          ,
    input  wire                   rst_n
);

`ifndef FPGA_SOURCE
wire [ADDR_WIDTH-1+1 : 0] rptr     ;
wire [ADDR_WIDTH-1+1 : 0] rptr_nxt ;
wire                      rptr_ld  ;
assign rptr_nxt = rptr + 1'b1      ;
assign rptr_ld  = rd_en & (~empty) ;
gnrl_dfflr #(ADDR_WIDTH + 1) gnrl_dfflr_rptr(rptr_ld,rptr_nxt,rptr,clk,rst_n);

wire [ADDR_WIDTH-1+1 : 0] wptr     ;
wire [ADDR_WIDTH-1+1 : 0] wptr_nxt ;
wire                      wptr_ld  ;
assign wptr_nxt = wptr + 1'b1      ;
assign wptr_ld  = wr_en & (~full)  ;
gnrl_dfflr #(ADDR_WIDTH + 1) gnrl_dfflr_wptr(wptr_ld,wptr_nxt,wptr,clk,rst_n);

wire [ADDR_WIDTH-1:0] raddr ;
wire [ADDR_WIDTH-1:0] waddr ;
assign raddr = rptr[ADDR_WIDTH-1:0];
assign waddr = wptr[ADDR_WIDTH-1:0];


assign empty = (rptr == wptr) ? 1'b1 : 1'b0 ; // when in reset state, both rptr and wptr are zero


assign full = ( (wptr[ADDR_WIDTH] != rptr[ADDR_WIDTH]) 
                && 
                (wptr[ADDR_WIDTH-1:0] == rptr[ADDR_WIDTH-1:0])
              ) ? 1'b1 : 1'b0;

localparam DEPTH = 1 << ADDR_WIDTH; 
(* ram_style = RAM_STYLE *) reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge clk) begin
    if (wr_en && ~full) begin 
        mem[waddr] <= din;
    end
end

generate
    if( FWFT_EN == 1 ) begin
        //=========================== first-word fall-through mode begin ====================== 
        wire [DATA_WIDTH-1:0] dout_old       ;
        wire                  dout_old_ld    ;
        assign dout_old_ld = rd_en & (~empty);
        gnrl_dfflr #(DATA_WIDTH) gnrl_dfflr_old(dout_old_ld,mem[raddr],dout_old,clk,rst_n);

        assign dout = (~empty) ? mem[raddr] : dout_old ;
        //=========================== first-word fall-through mode  end  ====================== 
    end else begin
        //=========================== normal mode begin ====================== 
        reg [DATA_WIDTH-1:0] dout_r;
        always @(posedge clk) begin
            if (rd_en && ~empty) begin 
                dout_r <= mem[raddr];
            end
        end

        assign dout = dout_r;
        //=========================== normal mode  end  ====================== 
    end
endgenerate
`else 

localparam FIFO_DEPTH = 1 << ADDR_WIDTH;
localparam XPM_MEM_TYPE = (RAM_STYLE == "distributed") ? "distributed" : 
                          (RAM_STYLE == "block")       ? "block"   : "auto";

localparam XPM_READ_MODE = (FWFT_EN == 1) ? "fwft" : "std";

wire rst;
assign rst = ~rst_n;

xpm_fifo_sync #(
`ifndef EDGE_XPM_LEGACY
    .CASCADE_HEIGHT(0),        
`endif
    .DOUT_RESET_VALUE("0"),    
    .ECC_MODE("no_ecc"),       
    .FIFO_MEMORY_TYPE(XPM_MEM_TYPE), 
    .FIFO_READ_LATENCY(FWFT_EN ? 0 : 1),
    .FIFO_WRITE_DEPTH(FIFO_DEPTH), 
    .FULL_RESET_VALUE(0),     
    .PROG_EMPTY_THRESH(10),  
    .PROG_FULL_THRESH(10),   
    .RD_DATA_COUNT_WIDTH($clog2(FIFO_DEPTH)+1),
    .READ_DATA_WIDTH(DATA_WIDTH), 
    .READ_MODE(XPM_READ_MODE),   
`ifndef EDGE_XPM_LEGACY
    .SIM_ASSERT_CHK(0),
`endif
    .USE_ADV_FEATURES("0000"),
    .WAKEUP_TIME(0),
    .WRITE_DATA_WIDTH(DATA_WIDTH),  
    .WR_DATA_COUNT_WIDTH($clog2(FIFO_DEPTH)+1)
) xpm_fifo_sync_inst (
    .wr_clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .din(din),
    .full(full),
        
    .rd_en(rd_en),
    .dout(dout),
    .empty(empty),

    .data_valid(),         
    .sleep(1'b0),
    .injectdbiterr(1'b0),
    .injectsbiterr(1'b0),
    .overflow(),
    .underflow(),
    .prog_empty(),
    .prog_full(),
    .rd_data_count(),
    .wr_data_count(),
    .sbiterr(),
    .dbiterr(),
    .wr_rst_busy(),
    .rd_rst_busy()
);

`endif

endmodule
`default_nettype wire 
