/*-----------------------------------------
file name  : top_tiny_npu_wrapper.v
created    : 2026/01/11 16:10:46
modified   : 2026-01-13 22:17:35
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
`include "top_tiny_npu.vh"
module top_tiny_npu_wrapper (
    // -------------------------------------------------------------------------
    // Clock & Reset Channel
    // -------------------------------------------------------------------------
    input  wire                          tiny_npu_clk             ,
    input  wire                          tiny_npu_rst_n           ,

    // -------------------------------------------------------------------------
    // Interrupt Channel
    // -------------------------------------------------------------------------
    output wire                          tiny_npu_sync_intr       ,

    // -------------------------------------------------------------------------
    // Instruction / Status AXI-Lite Slave Interface (Input from Host)
    // -------------------------------------------------------------------------
    // CDC Clock/Reset
    input  wire                          tiny_npu_i_m_clk         ,
    input  wire                          tiny_npu_i_m_rst_n       ,
    
    // Write Address Channel
    input  wire [`CMD_ADDR_WIDTH-1:0]    tiny_npu_i_s_axil_awaddr , // (input )
    input  wire [2:0]                    tiny_npu_i_s_axil_awprot , // (input )
    input  wire                          tiny_npu_i_s_axil_awvalid, // (input )
    output wire                          tiny_npu_i_s_axil_awready, // (output)
    
    // Write Data Channel
    input  wire [`CMD_DATA_WIDTH-1:0]    tiny_npu_i_s_axil_wdata  , // (input )
    input  wire [`CMD_DATA_WIDTH/8-1:0]  tiny_npu_i_s_axil_wstrb  , // (input )
    input  wire                          tiny_npu_i_s_axil_wvalid , // (input )
    output wire                          tiny_npu_i_s_axil_wready , // (output)
    
    // Write Response Channel
    output wire [1:0]                    tiny_npu_i_s_axil_bresp  , // (output)
    output wire                          tiny_npu_i_s_axil_bvalid , // (output)
    input  wire                          tiny_npu_i_s_axil_bready , // (input )
    
    // Read Address Channel
    input  wire [`CMD_ADDR_WIDTH-1:0]    tiny_npu_i_s_axil_araddr , // (input )
    input  wire [2:0]                    tiny_npu_i_s_axil_arprot , // (input )
    input  wire                          tiny_npu_i_s_axil_arvalid, // (input )
    output wire                          tiny_npu_i_s_axil_arready, // (output)
    
    // Read Data Channel
    output wire [`CMD_DATA_WIDTH-1:0]    tiny_npu_i_s_axil_rdata  , // (output)
    output wire [1:0]                    tiny_npu_i_s_axil_rresp  , // (output)
    output wire                          tiny_npu_i_s_axil_rvalid , // (output)
    input  wire                          tiny_npu_i_s_axil_rready , // (input )

    // -------------------------------------------------------------------------
    // Data AXI Master Interface (Output to Memory/System)
    // -------------------------------------------------------------------------
    // CDC Clock/Reset
    input  wire                          tiny_npu_d_s_clk         ,
    input  wire                          tiny_npu_d_s_rst_n       ,

    // Write Address Channel
    output wire [3:0]                    tiny_npu_d_m_axi_awid    , // (output)
    output wire [`ADDR_WIDTH-1:0]        tiny_npu_d_m_axi_awaddr  , // (output)
    output wire [7:0]                    tiny_npu_d_m_axi_awlen   , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_awsize  , // (output)
    output wire [1:0]                    tiny_npu_d_m_axi_awburst , // (output)
    output wire                          tiny_npu_d_m_axi_awlock  , // (output)
    output wire [3:0]                    tiny_npu_d_m_axi_awcache , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_awprot  , // (output)
    output wire                          tiny_npu_d_m_axi_awvalid , // (output)
    input  wire                          tiny_npu_d_m_axi_awready , // (input )
    
    // Write Data Channel
    output wire [`DATA_WIDTH-1:0]        tiny_npu_d_m_axi_wdata   , // (output)
    output wire [`DATA_WIDTH/8-1:0]      tiny_npu_d_m_axi_wstrb   , // (output)
    output wire                          tiny_npu_d_m_axi_wlast   , // (output)
    output wire                          tiny_npu_d_m_axi_wvalid  , // (output)
    input  wire                          tiny_npu_d_m_axi_wready  , // (input )
    
    // Write Response Channel
    input  wire [3:0]                    tiny_npu_d_m_axi_bid     , // (input )
    input  wire [1:0]                    tiny_npu_d_m_axi_bresp   , // (input )
    input  wire                          tiny_npu_d_m_axi_bvalid  , // (input )
    output wire                          tiny_npu_d_m_axi_bready  , // (output)
    
    // Read Address Channel
    output wire [3:0]                    tiny_npu_d_m_axi_arid    , // (output)
    output wire [`ADDR_WIDTH-1:0]        tiny_npu_d_m_axi_araddr  , // (output)
    output wire [7:0]                    tiny_npu_d_m_axi_arlen   , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_arsize  , // (output)
    output wire [1:0]                    tiny_npu_d_m_axi_arburst , // (output)
    output wire                          tiny_npu_d_m_axi_arlock  , // (output)
    output wire [3:0]                    tiny_npu_d_m_axi_arcache , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_arprot  , // (output)
    output wire                          tiny_npu_d_m_axi_arvalid , // (output)
    input  wire                          tiny_npu_d_m_axi_arready , // (input )
    
    // Read Data Channel
    input  wire [3:0]                    tiny_npu_d_m_axi_rid     , // (input )
    input  wire [`DATA_WIDTH-1:0]        tiny_npu_d_m_axi_rdata   , // (input )
    input  wire [1:0]                    tiny_npu_d_m_axi_rresp   , // (input )
    input  wire                          tiny_npu_d_m_axi_rlast   , // (input )
    input  wire                          tiny_npu_d_m_axi_rvalid  , // (input )
    output wire                          tiny_npu_d_m_axi_rready    // (output)
);

// =========================================================================
// Internal Signals
// =========================================================================

// Data AXI Master Signals (NPU -> CDC)
wire [3:0]                   data_m_axi_awid     ; 
wire [`ADDR_WIDTH-1:0]       data_m_axi_awaddr   ; 
wire [7:0]                   data_m_axi_awlen    ; 
wire [2:0]                   data_m_axi_awsize   ; 
wire [1:0]                   data_m_axi_awburst  ; 
wire                         data_m_axi_awlock   ; 
wire [3:0]                   data_m_axi_awcache  ; 
wire [2:0]                   data_m_axi_awprot   ; 
wire                         data_m_axi_awvalid  ; 
wire                         data_m_axi_awready  ; 
wire [`DATA_WIDTH-1:0]       data_m_axi_wdata    ; 
wire [`DATA_WIDTH/8-1:0]     data_m_axi_wstrb    ; 
wire                         data_m_axi_wlast    ; 
wire                         data_m_axi_wvalid   ; 
wire                         data_m_axi_wready   ; 
wire [3:0]                   data_m_axi_bid      ; 
wire [1:0]                   data_m_axi_bresp    ; 
wire                         data_m_axi_bvalid   ; 
wire                         data_m_axi_bready   ; 
wire [3:0]                   data_m_axi_arid     ; 
wire [`ADDR_WIDTH-1:0]       data_m_axi_araddr   ; 
wire [7:0]                   data_m_axi_arlen    ; 
wire [2:0]                   data_m_axi_arsize   ; 
wire [1:0]                   data_m_axi_arburst  ; 
wire                         data_m_axi_arlock   ; 
wire [3:0]                   data_m_axi_arcache  ; 
wire [2:0]                   data_m_axi_arprot   ; 
wire                         data_m_axi_arvalid  ; 
wire                         data_m_axi_arready  ; 
wire [3:0]                   data_m_axi_rid      ; 
wire [`DATA_WIDTH-1:0]       data_m_axi_rdata    ; 
wire [1:0]                   data_m_axi_rresp    ; 
wire                         data_m_axi_rlast    ; 
wire                         data_m_axi_rvalid   ; 
wire                         data_m_axi_rready   ; 

// Instruction AXI-Lite Slave Signals (CDC -> NPU)
wire [`CMD_ADDR_WIDTH-1:0]   instr_s_axil_awaddr ; 
wire [2:0]                   instr_s_axil_awprot ; 
wire                         instr_s_axil_awvalid; 
wire                         instr_s_axil_awready; 
wire [`CMD_DATA_WIDTH-1:0]   instr_s_axil_wdata  ; 
wire [`CMD_DATA_WIDTH/8-1:0] instr_s_axil_wstrb  ; 
wire                         instr_s_axil_wvalid ; 
wire                         instr_s_axil_wready ; 
wire [1:0]                   instr_s_axil_bresp  ; 
wire                         instr_s_axil_bvalid ; 
wire                         instr_s_axil_bready ; 

// Status AXI-Lite Slave Signals (CDC -> NPU)
wire                         status_s_axil_arvalid; 
wire                         status_s_axil_arready; 
wire [`CMD_ADDR_WIDTH-1:0]   status_s_axil_araddr ; 
wire [2:0]                   status_s_axil_arprot ; 
wire                         status_s_axil_rvalid ; 
wire                         status_s_axil_rready ; 
wire [`CMD_DATA_WIDTH-1:0]   status_s_axil_rdata  ; 
wire [1:0]                   status_s_axil_rresp  ; 

// =========================================================================
// Module Instantiations
// =========================================================================

// -------------------------------------------------------------------------
// Top Tiny NPU Core
// -------------------------------------------------------------------------
top_tiny_npu u_top_tiny_npu (
    .clk                   ( tiny_npu_clk             ), // (input ) 
    .rst_n                 ( tiny_npu_rst_n           ), // (input ) 

    // +++++ instruction in channel 
    .instr_s_axil_awaddr   ( instr_s_axil_awaddr      ), // (input ) 
    .instr_s_axil_awprot   ( instr_s_axil_awprot[2:0] ), // (input ) 
    .instr_s_axil_awvalid  ( instr_s_axil_awvalid     ), // (input ) 
    .instr_s_axil_awready  ( instr_s_axil_awready     ), // (output) 
    .instr_s_axil_wdata    ( instr_s_axil_wdata       ), // (input ) 
    .instr_s_axil_wstrb    ( instr_s_axil_wstrb       ), // (input ) 
    .instr_s_axil_wvalid   ( instr_s_axil_wvalid      ), // (input ) 
    .instr_s_axil_wready   ( instr_s_axil_wready      ), // (output) 
    .instr_s_axil_bresp    ( instr_s_axil_bresp[1:0]  ), // (output) 
    .instr_s_axil_bvalid   ( instr_s_axil_bvalid      ), // (output) 
    .instr_s_axil_bready   ( instr_s_axil_bready      ), // (input ) 
    // ----- instruction in channel 

    // +++++ status out channel 
    .status_s_axil_arvalid ( status_s_axil_arvalid    ), // (input ) 
    .status_s_axil_arready ( status_s_axil_arready    ), // (output) 
    .status_s_axil_araddr  ( status_s_axil_araddr     ), // (input ) 
    .status_s_axil_arprot  ( status_s_axil_arprot[2:0]), // (input ) 
    .status_s_axil_rvalid  ( status_s_axil_rvalid     ), // (output) 
    .status_s_axil_rready  ( status_s_axil_rready     ), // (input ) 
    .status_s_axil_rdata   ( status_s_axil_rdata      ), // (output) 
    .status_s_axil_rresp   ( status_s_axil_rresp[1:0] ), // (output) 
    // ----- status out channel

    // +++++ intr
    .sync_intr_event       ( tiny_npu_sync_intr       ), // (output)
    // ----- intr

    // +++++ data channel (Master)
    .data_m_axi_awid       ( data_m_axi_awid          ), 
    .data_m_axi_awaddr     ( data_m_axi_awaddr        ), 
    .data_m_axi_awlen      ( data_m_axi_awlen         ), 
    .data_m_axi_awsize     ( data_m_axi_awsize        ), 
    .data_m_axi_awburst    ( data_m_axi_awburst       ), 
    .data_m_axi_awlock     ( data_m_axi_awlock        ), 
    .data_m_axi_awcache    ( data_m_axi_awcache       ), 
    .data_m_axi_awprot     ( data_m_axi_awprot        ), 
    .data_m_axi_awvalid    ( data_m_axi_awvalid       ), 
    .data_m_axi_awready    ( data_m_axi_awready       ), 
    .data_m_axi_wdata      ( data_m_axi_wdata         ), 
    .data_m_axi_wstrb      ( data_m_axi_wstrb         ), 
    .data_m_axi_wlast      ( data_m_axi_wlast         ), 
    .data_m_axi_wvalid     ( data_m_axi_wvalid        ), 
    .data_m_axi_wready     ( data_m_axi_wready        ), 
    .data_m_axi_bid        ( data_m_axi_bid           ), 
    .data_m_axi_bresp      ( data_m_axi_bresp         ), 
    .data_m_axi_bvalid     ( data_m_axi_bvalid        ), 
    .data_m_axi_bready     ( data_m_axi_bready        ), 
    .data_m_axi_arid       ( data_m_axi_arid          ), 
    .data_m_axi_araddr     ( data_m_axi_araddr        ), 
    .data_m_axi_arlen      ( data_m_axi_arlen         ), 
    .data_m_axi_arsize     ( data_m_axi_arsize        ), 
    .data_m_axi_arburst    ( data_m_axi_arburst       ), 
    .data_m_axi_arlock     ( data_m_axi_arlock        ), 
    .data_m_axi_arcache    ( data_m_axi_arcache       ), 
    .data_m_axi_arprot     ( data_m_axi_arprot        ), 
    .data_m_axi_arvalid    ( data_m_axi_arvalid       ), 
    .data_m_axi_arready    ( data_m_axi_arready       ), 
    .data_m_axi_rid        ( data_m_axi_rid           ), 
    .data_m_axi_rdata      ( data_m_axi_rdata         ), 
    .data_m_axi_rresp      ( data_m_axi_rresp         ), 
    .data_m_axi_rlast      ( data_m_axi_rlast         ), 
    .data_m_axi_rvalid     ( data_m_axi_rvalid        ), 
    .data_m_axi_rready     ( data_m_axi_rready        ) 
    // ----- data channel
);

// -------------------------------------------------------------------------
// AXI Data CDC (Clock Domain Crossing)
// -------------------------------------------------------------------------
axi_cdc u_axi_cdc (
    .s_axi_clk             ( tiny_npu_clk             ), // (input )
    .s_axi_rst_n           ( tiny_npu_rst_n           ), // (input )

    // Slave Interface (from NPU)
    .s_axi_aw_valid        ( data_m_axi_awvalid       ),
    .s_axi_aw_ready        ( data_m_axi_awready       ),
    .s_axi_aw_payload_addr ( data_m_axi_awaddr        ),
    .s_axi_aw_payload_id   ( data_m_axi_awid          ),
    .s_axi_aw_payload_region (                        ), // Unconnected
    .s_axi_aw_payload_len  ( data_m_axi_awlen         ),
    .s_axi_aw_payload_size ( data_m_axi_awsize        ),
    .s_axi_aw_payload_burst( data_m_axi_awburst       ),
    .s_axi_aw_payload_lock ( data_m_axi_awlock        ),
    .s_axi_aw_payload_cache( data_m_axi_awcache       ),
    .s_axi_aw_payload_qos  (                          ), // Unconnected
    .s_axi_aw_payload_prot ( data_m_axi_awprot        ),
    .s_axi_w_valid         ( data_m_axi_wvalid        ),
    .s_axi_w_ready         ( data_m_axi_wready        ),
    .s_axi_w_payload_data  ( data_m_axi_wdata         ),
    .s_axi_w_payload_strb  ( data_m_axi_wstrb         ),
    .s_axi_w_payload_last  ( data_m_axi_wlast         ),
    .s_axi_b_valid         ( data_m_axi_bvalid        ),
    .s_axi_b_ready         ( data_m_axi_bready        ),
    .s_axi_b_payload_id    ( data_m_axi_bid           ),
    .s_axi_b_payload_resp  ( data_m_axi_bresp         ),
    .s_axi_ar_valid        ( data_m_axi_arvalid       ),
    .s_axi_ar_ready        ( data_m_axi_arready       ),
    .s_axi_ar_payload_addr ( data_m_axi_araddr        ),
    .s_axi_ar_payload_id   ( data_m_axi_arid          ),
    .s_axi_ar_payload_region (                        ), // Unconnected
    .s_axi_ar_payload_len  ( data_m_axi_arlen         ),
    .s_axi_ar_payload_size ( data_m_axi_arsize        ),
    .s_axi_ar_payload_burst( data_m_axi_arburst       ),
    .s_axi_ar_payload_lock ( data_m_axi_arlock        ),
    .s_axi_ar_payload_cache( data_m_axi_arcache       ),
    .s_axi_ar_payload_qos  (                          ), // Unconnected
    .s_axi_ar_payload_prot ( data_m_axi_arprot        ),
    .s_axi_r_valid         ( data_m_axi_rvalid        ),
    .s_axi_r_ready         ( data_m_axi_rready        ),
    .s_axi_r_payload_data  ( data_m_axi_rdata         ),
    .s_axi_r_payload_id    ( data_m_axi_rid           ),
    .s_axi_r_payload_resp  ( data_m_axi_rresp         ),
    .s_axi_r_payload_last  ( data_m_axi_rlast         ),

    // Master Interface (to Wrapper Ports)
    .m_axi_clk             ( tiny_npu_d_s_clk         ), // (input )
    .m_axi_rst_n           ( tiny_npu_d_s_rst_n       ), // (input )
    .m_axi_aw_valid        ( tiny_npu_d_m_axi_awvalid ), // (output)
    .m_axi_aw_ready        ( tiny_npu_d_m_axi_awready ), // (input )
    .m_axi_aw_payload_addr ( tiny_npu_d_m_axi_awaddr  ), // (output)
    .m_axi_aw_payload_id   ( tiny_npu_d_m_axi_awid    ), // (output)
    .m_axi_aw_payload_region (                        ), // (output) Unconnected
    .m_axi_aw_payload_len  ( tiny_npu_d_m_axi_awlen   ), // (output)
    .m_axi_aw_payload_size ( tiny_npu_d_m_axi_awsize  ), // (output)
    .m_axi_aw_payload_burst( tiny_npu_d_m_axi_awburst ), // (output)
    .m_axi_aw_payload_lock ( tiny_npu_d_m_axi_awlock  ), // (output)
    .m_axi_aw_payload_cache( tiny_npu_d_m_axi_awcache ), // (output)
    .m_axi_aw_payload_qos  (                          ), // (output) Unconnected
    .m_axi_aw_payload_prot ( tiny_npu_d_m_axi_awprot  ), // (output)
    .m_axi_w_valid         ( tiny_npu_d_m_axi_wvalid  ), // (output)
    .m_axi_w_ready         ( tiny_npu_d_m_axi_wready  ), // (input )
    .m_axi_w_payload_data  ( tiny_npu_d_m_axi_wdata   ), // (output)
    .m_axi_w_payload_strb  ( tiny_npu_d_m_axi_wstrb   ), // (output)
    .m_axi_w_payload_last  ( tiny_npu_d_m_axi_wlast   ), // (output)
    .m_axi_b_valid         ( tiny_npu_d_m_axi_bvalid  ), // (input )
    .m_axi_b_ready         ( tiny_npu_d_m_axi_bready  ), // (output)
    .m_axi_b_payload_id    ( tiny_npu_d_m_axi_bid     ), // (input )
    .m_axi_b_payload_resp  ( tiny_npu_d_m_axi_bresp   ), // (input )
    .m_axi_ar_valid        ( tiny_npu_d_m_axi_arvalid ), // (output)
    .m_axi_ar_ready        ( tiny_npu_d_m_axi_arready ), // (input )
    .m_axi_ar_payload_addr ( tiny_npu_d_m_axi_araddr  ), // (output)
    .m_axi_ar_payload_id   ( tiny_npu_d_m_axi_arid    ), // (output)
    .m_axi_ar_payload_region (                        ), // (output) Unconnected
    .m_axi_ar_payload_len  ( tiny_npu_d_m_axi_arlen   ), // (output)
    .m_axi_ar_payload_size ( tiny_npu_d_m_axi_arsize  ), // (output)
    .m_axi_ar_payload_burst( tiny_npu_d_m_axi_arburst ), // (output)
    .m_axi_ar_payload_lock ( tiny_npu_d_m_axi_arlock  ), // (output)
    .m_axi_ar_payload_cache( tiny_npu_d_m_axi_arcache ), // (output)
    .m_axi_ar_payload_qos  (                          ), // (output) Unconnected
    .m_axi_ar_payload_prot ( tiny_npu_d_m_axi_arprot  ), // (output)
    .m_axi_r_valid         ( tiny_npu_d_m_axi_rvalid  ), // (input )
    .m_axi_r_ready         ( tiny_npu_d_m_axi_rready  ), // (output)
    .m_axi_r_payload_data  ( tiny_npu_d_m_axi_rdata   ), // (input )
    .m_axi_r_payload_id    ( tiny_npu_d_m_axi_rid     ), // (input )
    .m_axi_r_payload_resp  ( tiny_npu_d_m_axi_rresp   ), // (input )
    .m_axi_r_payload_last  ( tiny_npu_d_m_axi_rlast   )  // (input )
);

// -------------------------------------------------------------------------
// AXI-Lite Control CDC (Clock Domain Crossing)
// -------------------------------------------------------------------------
axil_cdc u_axil_cdc (
    .s_axil_clk            ( tiny_npu_i_m_clk         ), // (input )
    .s_axil_rst_n          ( tiny_npu_i_m_rst_n       ), // (input )

    // Slave Interface (from Wrapper Ports)
    .s_axil_aw_valid       ( tiny_npu_i_s_axil_awvalid), // (input )
    .s_axil_aw_ready       ( tiny_npu_i_s_axil_awready), // (output)
    .s_axil_aw_payload_addr( tiny_npu_i_s_axil_awaddr ), // (input )
    .s_axil_aw_payload_prot( tiny_npu_i_s_axil_awprot ), // (input )
    .s_axil_w_valid        ( tiny_npu_i_s_axil_wvalid ), // (input )
    .s_axil_w_ready        ( tiny_npu_i_s_axil_wready ), // (output)
    .s_axil_w_payload_data ( tiny_npu_i_s_axil_wdata  ), // (input )
    .s_axil_w_payload_strb ( tiny_npu_i_s_axil_wstrb  ), // (input )
    .s_axil_b_valid        ( tiny_npu_i_s_axil_bvalid ), // (output)
    .s_axil_b_ready        ( tiny_npu_i_s_axil_bready ), // (input )
    .s_axil_b_payload_resp ( tiny_npu_i_s_axil_bresp  ), // (output)

    .s_axil_ar_valid       ( tiny_npu_i_s_axil_arvalid), // (input )
    .s_axil_ar_ready       ( tiny_npu_i_s_axil_arready), // (output)
    .s_axil_ar_payload_addr( tiny_npu_i_s_axil_araddr ), // (input )
    .s_axil_ar_payload_prot( tiny_npu_i_s_axil_arprot ), // (input )

    .s_axil_r_valid        ( tiny_npu_i_s_axil_rvalid ), // (output)
    .s_axil_r_ready        ( tiny_npu_i_s_axil_rready ), // (input )
    .s_axil_r_payload_data ( tiny_npu_i_s_axil_rdata  ), // (output)
    .s_axil_r_payload_resp ( tiny_npu_i_s_axil_rresp  ), // (output)

    // Master Interface (to NPU)
    .m_axil_clk            ( tiny_npu_clk             ), // (input )
    .m_axil_rst_n          ( tiny_npu_rst_n           ), // (input )

    .m_axil_aw_valid       ( instr_s_axil_awvalid     ), // (output)
    .m_axil_aw_ready       ( instr_s_axil_awready     ), // (input )
    .m_axil_aw_payload_addr( instr_s_axil_awaddr      ), // (output)
    .m_axil_aw_payload_prot( instr_s_axil_awprot      ), // (output)
    .m_axil_w_valid        ( instr_s_axil_wvalid      ), // (output)
    .m_axil_w_ready        ( instr_s_axil_wready      ), // (input )
    .m_axil_w_payload_data ( instr_s_axil_wdata       ), // (output)
    .m_axil_w_payload_strb ( instr_s_axil_wstrb       ), // (output)

    .m_axil_b_valid        ( instr_s_axil_bvalid      ), // (input )
    .m_axil_b_ready        ( instr_s_axil_bready      ), // (output)
    .m_axil_b_payload_resp ( instr_s_axil_bresp       ), // (input )

    .m_axil_ar_valid       ( status_s_axil_arvalid    ), // (output)
    .m_axil_ar_ready       ( status_s_axil_arready    ), // (input )
    .m_axil_ar_payload_addr( status_s_axil_araddr     ), // (output)
    .m_axil_ar_payload_prot( status_s_axil_arprot     ), // (output)
    .m_axil_r_valid        ( status_s_axil_rvalid     ), // (input )
    .m_axil_r_ready        ( status_s_axil_rready     ), // (output)
    .m_axil_r_payload_data ( status_s_axil_rdata      ), // (input )
    .m_axil_r_payload_resp ( status_s_axil_rresp      )  // (input )
);

endmodule
`default_nettype wire 
