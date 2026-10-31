/*-----------------------------------------
file name  : top_axi_cdma.v
created    : 2026/01/08 16:07:12
modified   : 2026-03-18 14:07:04
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none 
module top_axi_cdma # (
    parameter                 DATA_WIDTH = 32      , 
    parameter                 ADDR_WIDTH = 32      , // const
    parameter                 LEN_WIDTH  = 8       , // const
    parameter                 ICMD_LEN   = 124     , // const
    parameter                 TAG_WIDTH  = 8         // const
)(
   
    input  wire                      clk                  , // (input )
    input  wire                      rst_n                , // (input )

    input  wire       [ICMD_LEN-1:0] cmd                  , // (input )
    input  wire                      cmd_vld              , // (input )
    output wire                      cmd_rdy              , 

    output wire      [TAG_WIDTH-1:0] cdma_status_tag      , 
    output wire                      cdma_status_en       ,

    output wire                [0:0] cdma_m_axi_awid      , // (output)
    output wire     [ADDR_WIDTH-1:0] cdma_m_axi_awaddr    , // (output)
    output wire                [7:0] cdma_m_axi_awlen     , // (output)
    output wire                [2:0] cdma_m_axi_awsize    , // (output)
    output wire                [1:0] cdma_m_axi_awburst   , // (output)
    output wire                      cdma_m_axi_awlock    , // (output)
    output wire                [3:0] cdma_m_axi_awcache   , // (output)
    output wire                [2:0] cdma_m_axi_awprot    , // (output)
    output wire                      cdma_m_axi_awvalid   , // (output)
    input  wire                      cdma_m_axi_awready   , // (input )
    
    output wire     [DATA_WIDTH-1:0] cdma_m_axi_wdata     , // (output)
    output wire   [DATA_WIDTH/8-1:0] cdma_m_axi_wstrb     , // (output)
    output wire                      cdma_m_axi_wlast     , // (output)
    output wire                      cdma_m_axi_wvalid    , // (output)
    input  wire                      cdma_m_axi_wready    , // (input )
    
    input  wire                [0:0] cdma_m_axi_bid       , // (input )
    input  wire                [1:0] cdma_m_axi_bresp     , // (input )
    input  wire                      cdma_m_axi_bvalid    , // (input )
    output wire                      cdma_m_axi_bready    , // (output)
    
    output wire                [0:0] cdma_m_axi_arid      , // (output)
    output wire     [ADDR_WIDTH-1:0] cdma_m_axi_araddr    , // (output)
    output wire                [7:0] cdma_m_axi_arlen     , // (output)
    output wire                [2:0] cdma_m_axi_arsize    , // (output)
    output wire                [1:0] cdma_m_axi_arburst   , // (output)
    output wire                      cdma_m_axi_arlock    , // (output)
    output wire                [3:0] cdma_m_axi_arcache   , // (output)
    output wire                [2:0] cdma_m_axi_arprot    , // (output)
    output wire                      cdma_m_axi_arvalid   , // (output)
    input  wire                      cdma_m_axi_arready   , // (input )
    
    input  wire                [0:0] cdma_m_axi_rid       , // (input )
    input  wire     [DATA_WIDTH-1:0] cdma_m_axi_rdata     , // (input )
    input  wire                [1:0] cdma_m_axi_rresp     , // (input )
    input  wire                      cdma_m_axi_rlast     , // (input )
    input  wire                      cdma_m_axi_rvalid    , // (input )
    output wire                      cdma_m_axi_rready      // (output)
);

wire                      cdma_desc_status_en  ; 
wire     [ADDR_WIDTH-1:0] cdma_desc_read_addr  ; 
wire     [ADDR_WIDTH-1:0] cdma_desc_write_addr ; 
wire    [LEN_WIDTH+1-1:0] cdma_desc_len        ; 
wire      [0:0]           cdma_desc_tag        ; 
wire                      cdma_desc_valid      ; 
wire                      cdma_desc_ready      ; 

//----------------------- timing opt 
wire                [0:0] int_m_axi_awid      ;
wire     [ADDR_WIDTH-1:0] int_m_axi_awaddr    ;
wire                [7:0] int_m_axi_awlen     ;
wire                [2:0] int_m_axi_awsize    ;
wire                [1:0] int_m_axi_awburst   ;
wire                      int_m_axi_awlock    ;
wire                [3:0] int_m_axi_awcache   ;
wire                [2:0] int_m_axi_awprot    ;
wire                      int_m_axi_awvalid   ;
wire                      int_m_axi_awready   ;

wire     [DATA_WIDTH-1:0] int_m_axi_wdata     ;
wire   [DATA_WIDTH/8-1:0] int_m_axi_wstrb     ;
wire                      int_m_axi_wlast     ;
wire                      int_m_axi_wvalid    ;
wire                      int_m_axi_wready    ;

wire                [0:0] int_m_axi_bid       ;
wire                [1:0] int_m_axi_bresp     ;
wire                      int_m_axi_bvalid    ;
wire                      int_m_axi_bready    ;

wire                [0:0] int_m_axi_arid      ;
wire     [ADDR_WIDTH-1:0] int_m_axi_araddr    ;
wire                [7:0] int_m_axi_arlen     ;
wire                [2:0] int_m_axi_arsize    ;
wire                [1:0] int_m_axi_arburst   ;
wire                      int_m_axi_arlock    ;
wire                [3:0] int_m_axi_arcache   ;
wire                [2:0] int_m_axi_arprot    ;
wire                      int_m_axi_arvalid   ;
wire                      int_m_axi_arready   ;

wire                [0:0] int_m_axi_rid       ;
wire     [DATA_WIDTH-1:0] int_m_axi_rdata     ;
wire                [1:0] int_m_axi_rresp     ;
wire                      int_m_axi_rlast     ;
wire                      int_m_axi_rvalid    ;
wire                      int_m_axi_rready    ;

control_axi_cdma # (
    .ADDR_WIDTH                   (ADDR_WIDTH                   ), // const
    .ICMD_LEN                     (ICMD_LEN                     ), // const
    .LEN_WIDTH                    (LEN_WIDTH                    ), // const
    .TAG_WIDTH                    (TAG_WIDTH                    )  // const
)u_control_axi_cdma(
    .clk                          (clk                          ), // (input ) 
    .rst_n                        (rst_n                        ), // (input )

    .cmd                          (cmd[ICMD_LEN-1:0]            ), // (input )
    .cmd_vld                      (cmd_vld                      ), // (input )
    .cmd_rdy                      (cmd_rdy                      ), 

    .cdma_desc_status_en          (cdma_desc_status_en          ), // (input ) 

    .cdma_desc_read_addr          (cdma_desc_read_addr          ), // (output)
    .cdma_desc_write_addr         (cdma_desc_write_addr         ), // (output)
    .cdma_desc_len                (cdma_desc_len                ), // (output)
    .cdma_desc_tag                (cdma_desc_tag                ), // (output)
    .cdma_desc_valid              (cdma_desc_valid              ), // (output)
    .cdma_desc_ready              (cdma_desc_ready              ), // (input )

    .cdma_status_tag              (cdma_status_tag              ), // (output)
    .cdma_status_en               (cdma_status_en               )  // (output)
);

wire [TAG_WIDTH-1:0]       cdma_m_axis_desc_status_tag  ;
wire [3:0]                 cdma_m_axis_desc_status_error;
wire                       cdma_m_axis_desc_status_valid;

assign cdma_desc_status_en = cdma_m_axis_desc_status_valid;          

axi_cdma # (
    // Width of data bus in bits
    .AXI_DATA_WIDTH    (DATA_WIDTH ),
    // Width of address bus in bits
    .AXI_ADDR_WIDTH    (ADDR_WIDTH ),
    // Width of AXI ID signal
    .AXI_ID_WIDTH      (1          ),
    // Maximum AXI burst length to generate
    .AXI_MAX_BURST_LEN (64         ),
    // Width of length field
    .LEN_WIDTH         (LEN_WIDTH+1),
    // Width of tag field
    .TAG_WIDTH         (1          ),
    // Enable support for unaligned transfers
    .ENABLE_UNALIGNED  (1          )
)u_axi_cdma(
    .clk                          (clk                          ), // (input )
    .rst                          (~rst_n                       ), // (input )

    // AXI descriptor input
    .s_axis_desc_read_addr        (cdma_desc_read_addr          ), // (input )
    .s_axis_desc_write_addr       (cdma_desc_write_addr         ), // (input )
    .s_axis_desc_len              (cdma_desc_len                ), // (input )
    .s_axis_desc_tag              (cdma_desc_tag                ), // (input )
    .s_axis_desc_valid            (cdma_desc_valid              ), // (input )
    .s_axis_desc_ready            (cdma_desc_ready              ), // (output)
    
    // AXI descriptor status outputcdma_
    .m_axis_desc_status_tag       (cdma_m_axis_desc_status_tag  ), // (output)
    .m_axis_desc_status_error     (cdma_m_axis_desc_status_error), // (output)
    .m_axis_desc_status_valid     (cdma_m_axis_desc_status_valid), // (output)

    // AXI write master interface
    .m_axi_awid                   (int_m_axi_awid[0:0]          ), // (output)
    .m_axi_awaddr                 (int_m_axi_awaddr             ), // (output)
    .m_axi_awlen                  (int_m_axi_awlen[7:0]         ), // (output)
    .m_axi_awsize                 (int_m_axi_awsize[2:0]        ), // (output)
    .m_axi_awburst                (int_m_axi_awburst[1:0]       ), // (output)
    .m_axi_awlock                 (int_m_axi_awlock             ), // (output)
    .m_axi_awcache                (int_m_axi_awcache[3:0]       ), // (output)
    .m_axi_awprot                 (int_m_axi_awprot[2:0]        ), // (output)
    .m_axi_awvalid                (int_m_axi_awvalid            ), // (output)
    .m_axi_awready                (int_m_axi_awready            ), // (input )
    .m_axi_wdata                  (int_m_axi_wdata              ), // (output)
    .m_axi_wstrb                  (int_m_axi_wstrb              ), // (output)
    .m_axi_wlast                  (int_m_axi_wlast              ), // (output)
    .m_axi_wvalid                 (int_m_axi_wvalid             ), // (output)
    .m_axi_wready                 (int_m_axi_wready             ), // (input )
    .m_axi_bid                    (int_m_axi_bid                ), // (input )
    .m_axi_bresp                  (int_m_axi_bresp[1:0]         ), // (input )
    .m_axi_bvalid                 (int_m_axi_bvalid             ), // (input )
    .m_axi_bready                 (int_m_axi_bready             ), // (output)

    // AXI read master interface 
    .m_axi_arid                   (int_m_axi_arid               ), // (output)
    .m_axi_araddr                 (int_m_axi_araddr             ), // (output)
    .m_axi_arlen                  (int_m_axi_arlen[7:0]         ), // (output)
    .m_axi_arsize                 (int_m_axi_arsize[2:0]        ), // (output)
    .m_axi_arburst                (int_m_axi_arburst[1:0]       ), // (output)
    .m_axi_arlock                 (int_m_axi_arlock             ), // (output)
    .m_axi_arcache                (int_m_axi_arcache[3:0]       ), // (output)
    .m_axi_arprot                 (int_m_axi_arprot[2:0]        ), // (output)
    .m_axi_arvalid                (int_m_axi_arvalid            ), // (output)
    .m_axi_arready                (int_m_axi_arready            ), // (input )
    .m_axi_rid                    (int_m_axi_rid                ), // (input )
    .m_axi_rdata                  (int_m_axi_rdata              ), // (input )
    .m_axi_rresp                  (int_m_axi_rresp[1:0]         ), // (input )
    .m_axi_rlast                  (int_m_axi_rlast              ), // (input )
    .m_axi_rvalid                 (int_m_axi_rvalid             ), // (input )
    .m_axi_rready                 (int_m_axi_rready             ), // (output)
    // Configuration
    .enable                       (1'b1                         )  // (input )
);

//----------------------- timing opt 
// --- 1. AW Channel (Master -> Slave) ---
bwdfwdpipe #( .DWIDTH(22 + ADDR_WIDTH) ) u_slice_aw (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (int_m_axi_awvalid),
    .s_data  ({int_m_axi_awid, int_m_axi_awaddr, int_m_axi_awlen, int_m_axi_awsize, int_m_axi_awburst, int_m_axi_awlock, int_m_axi_awcache, int_m_axi_awprot}),
    .s_ready (int_m_axi_awready), 
    
    .m_valid (cdma_m_axi_awvalid),
    .m_data  ({cdma_m_axi_awid, cdma_m_axi_awaddr, cdma_m_axi_awlen, cdma_m_axi_awsize, cdma_m_axi_awburst, cdma_m_axi_awlock, cdma_m_axi_awcache, cdma_m_axi_awprot}),
    .m_ready (cdma_m_axi_awready) 
);

// --- 2. W Channel (Master -> Slave) ---
bwdfwdpipe #( .DWIDTH(DATA_WIDTH + DATA_WIDTH/8 + 1) ) u_slice_w (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (int_m_axi_wvalid),
    .s_data  ({int_m_axi_wdata, int_m_axi_wstrb, int_m_axi_wlast}),
    .s_ready (int_m_axi_wready), 
    
    .m_valid (cdma_m_axi_wvalid),
    .m_data  ({cdma_m_axi_wdata, cdma_m_axi_wstrb, cdma_m_axi_wlast}),
    .m_ready (cdma_m_axi_wready) 
);

// --- 3. B Channel (Slave -> Master ) ---
bwdfwdpipe #( .DWIDTH(3) ) u_slice_b (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (cdma_m_axi_bvalid), 
    .s_data  ({cdma_m_axi_bid, cdma_m_axi_bresp}),
    .s_ready (cdma_m_axi_bready),
    
    .m_valid (int_m_axi_bvalid),  
    .m_data  ({int_m_axi_bid, int_m_axi_bresp}),
    .m_ready (int_m_axi_bready)   
);

// --- 4. AR Channel (Master -> Slave) ---
bwdfwdpipe #( .DWIDTH(22 + ADDR_WIDTH) ) u_slice_ar (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (int_m_axi_arvalid),
    .s_data  ({int_m_axi_arid, int_m_axi_araddr, int_m_axi_arlen, int_m_axi_arsize, int_m_axi_arburst, int_m_axi_arlock, int_m_axi_arcache, int_m_axi_arprot}),
    .s_ready (int_m_axi_arready), 
    
    .m_valid (cdma_m_axi_arvalid),
    .m_data  ({cdma_m_axi_arid, cdma_m_axi_araddr, cdma_m_axi_arlen, cdma_m_axi_arsize, cdma_m_axi_arburst, cdma_m_axi_arlock, cdma_m_axi_arcache, cdma_m_axi_arprot}),
    .m_ready (cdma_m_axi_arready) 
);

// --- 5. R Channel (Slave -> Master) ---
bwdfwdpipe #( .DWIDTH(DATA_WIDTH + 4) ) u_slice_r (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (cdma_m_axi_rvalid), 
    .s_data  ({cdma_m_axi_rid, cdma_m_axi_rdata, cdma_m_axi_rresp, cdma_m_axi_rlast}),
    .s_ready (cdma_m_axi_rready), 
    
    .m_valid (int_m_axi_rvalid),  
    .m_data  ({int_m_axi_rid, int_m_axi_rdata, int_m_axi_rresp, int_m_axi_rlast}),
    .m_ready (int_m_axi_rready)   
);

endmodule

`default_nettype wire 