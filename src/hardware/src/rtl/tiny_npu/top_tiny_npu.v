/*-----------------------------------------
file name  : top_tiny_npu.v
created    : 2025/12/16 23:09:01
modified   : 2026-02-10 17:43:09
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`include "top_tiny_npu.vh"
`default_nettype none
module top_tiny_npu (
    input  wire                       clk                          , // (input )
    input  wire                       rst_n                        , // (input )

    // +++++ instruction in channel 
    input  wire[`CMD_ADDR_WIDTH-1:0]  instr_s_axil_awaddr          , // (input )
    input  wire                [2:0]  instr_s_axil_awprot          , // (input )
    input  wire                       instr_s_axil_awvalid         , // (input )
    output wire                       instr_s_axil_awready         , // (output)
    input  wire[`CMD_DATA_WIDTH-1:0]  instr_s_axil_wdata           , // (input )
    input  wire[`CMD_DATA_WIDTH/8-1:0]instr_s_axil_wstrb           , // (input )
    input  wire                       instr_s_axil_wvalid          , // (input )
    output wire                       instr_s_axil_wready          , // (output)
    output wire                [1:0]  instr_s_axil_bresp           , // (output)
    output wire                       instr_s_axil_bvalid          , // (output)
    input  wire                       instr_s_axil_bready          , // (input )
    // ----- instruction in channel 

    // +++++ status out channel 
    input  wire                       status_s_axil_arvalid        , // (input )
    output wire                       status_s_axil_arready        , // (output)
    input  wire[`CMD_ADDR_WIDTH-1:0]  status_s_axil_araddr         , // (input )
    input  wire                [2:0]  status_s_axil_arprot         , // (input )
    output wire                       status_s_axil_rvalid         , // (output)
    input  wire                       status_s_axil_rready         , // (input )
    output wire[`CMD_DATA_WIDTH-1:0]  status_s_axil_rdata          , // (output)
    output wire                [1:0]  status_s_axil_rresp          , // (output)
    // ----- status out channel

    // +++++ intr
    output wire                       sync_intr_event              ,
    // ----- intr

    // +++++ data channel
    output wire                [3:0]  data_m_axi_awid              , 
    output wire    [`ADDR_WIDTH-1:0]  data_m_axi_awaddr            , 
    output wire                [7:0]  data_m_axi_awlen             , 
    output wire                [2:0]  data_m_axi_awsize            , 
    output wire                [1:0]  data_m_axi_awburst           , 
    output wire                       data_m_axi_awlock            , 
    output wire                [3:0]  data_m_axi_awcache           , 
    output wire                [2:0]  data_m_axi_awprot            , 
    output wire                       data_m_axi_awvalid           , 
    input  wire                       data_m_axi_awready           , 
    output wire    [`DATA_WIDTH-1:0]  data_m_axi_wdata             , 
    output wire  [`DATA_WIDTH/8-1:0]  data_m_axi_wstrb             , 
    output wire                       data_m_axi_wlast             , 
    output wire                       data_m_axi_wvalid            , 
    input  wire                       data_m_axi_wready            , 
    input  wire                [3:0]  data_m_axi_bid               , 
    input  wire                [1:0]  data_m_axi_bresp             , 
    input  wire                       data_m_axi_bvalid            , 
    output wire                       data_m_axi_bready            , 
    output wire                [3:0]  data_m_axi_arid              , 
    output wire    [`ADDR_WIDTH-1:0]  data_m_axi_araddr            , 
    output wire                [7:0]  data_m_axi_arlen             , 
    output wire                [2:0]  data_m_axi_arsize            , 
    output wire                [1:0]  data_m_axi_arburst           , 
    output wire                       data_m_axi_arlock            , 
    output wire                [3:0]  data_m_axi_arcache           , 
    output wire                [2:0]  data_m_axi_arprot            , 
    output wire                       data_m_axi_arvalid           , 
    input  wire                       data_m_axi_arready           , 
    input  wire                [3:0]  data_m_axi_rid               , 
    input  wire    [`DATA_WIDTH-1:0]  data_m_axi_rdata             , 
    input  wire                [1:0]  data_m_axi_rresp             , 
    input  wire                       data_m_axi_rlast             , 
    input  wire                       data_m_axi_rvalid            , 
    output wire                       data_m_axi_rready             
    // ----- data channel
);

wire          [`TAG_WIDTH-1:0] sync_status_tag  ; 
wire                           sync_status_en   ; 
wire                           wr_buf_id        ;

wire[`INSTR_WIDTH-1:0]    instr_rd_out          ; 
wire                      instr_rd_valid        ; 
wire                      instr_rd_ready        ; 

// One slave ID bit plus two crossbar route bits produce a three-bit ID.
// The fixed CDC interface is four bits; drive its extra bit explicitly.
assign data_m_axi_awid[3] = 1'b0;
assign data_m_axi_arid[3] = 1'b0;

wire [`CMD_DATA_WIDTH-1:0] axil_wdata           ; 
wire [`CMD_ADDR_WIDTH-1:0] axil_waddr           ; 
wire                       axil_wr_en           ;

wire [`DATA_WIDTH-1:0] inst_read_data_tdata ;
wire                   inst_read_data_tvalid;
wire                   inst_read_data_tready;

axil_fifo # (
    .CMD_DATA_WIDTH               (`CMD_DATA_WIDTH          ),
    // Width of data bus in bits
    .DATA_WIDTH                   (`DATA_WIDTH              ), 
    // Width of address bus in bits
    .ADDR_WIDTH                   (`CMD_ADDR_WIDTH          ), 
    // Device 's address, must be aligned
    .FIFO_ADDR                    (`REG_CMD                 ), 
    // Fifo addr width
    .INSTR_WIDTH                  (`INSTR_WIDTH             ),
    .FIFO_AWIDTH                  (`INSTR_FIFO_AWIDTH       ) 
) u_instr_fifo (
    .clk                          (clk                          ), // (input )
    .rst_n                        (rst_n                        ), // (input )

    // aw channel
    .s_axil_awaddr                (instr_s_axil_awaddr          ), // (input )
    .s_axil_awprot                (instr_s_axil_awprot[2:0]     ), // (input )
    .s_axil_awvalid               (instr_s_axil_awvalid         ), // (input )
    .s_axil_awready               (instr_s_axil_awready         ), // (output)
    
    // w channel
    .s_axil_wdata                 (instr_s_axil_wdata           ), // (input )
    .s_axil_wstrb                 (instr_s_axil_wstrb           ), // (input )
    .s_axil_wvalid                (instr_s_axil_wvalid          ), // (input )
    .s_axil_wready                (instr_s_axil_wready          ), // (output)

    // b channel
    .s_axil_bresp                 (instr_s_axil_bresp[1:0]      ), // (output)
    .s_axil_bvalid                (instr_s_axil_bvalid          ), // (output)
    .s_axil_bready                (instr_s_axil_bready          ), // (input )

    .inst_data                    (inst_read_data_tdata         ), // input
    .inst_data_vld                (inst_read_data_tvalid        ), // input
    .inst_data_rdy                (inst_read_data_tready        ), // output

    // fifo output 
    .inst_fifo_data               (instr_rd_out                 ), // (output)
    .inst_fifo_vld                (instr_rd_valid               ), // (output)
    .inst_fifo_rdy                (instr_rd_ready               ), // (input )

    .axil_wdata                   ( axil_wdata                  ), 
    .axil_waddr                   ( axil_waddr                  ), 
    .axil_wen                     ( axil_wr_en                  ) 
);

wire [0:0]                 inst_m_axi_arid   ;
wire [`ADDR_WIDTH-1:0]     inst_m_axi_araddr ;
wire [7:0]                 inst_m_axi_arlen  ;
wire [2:0]                 inst_m_axi_arsize ;
wire [1:0]                 inst_m_axi_arburst;
wire                       inst_m_axi_arlock ;
wire [3:0]                 inst_m_axi_arcache;
wire [2:0]                 inst_m_axi_arprot ;
wire                       inst_m_axi_arvalid;
wire                       inst_m_axi_arready;
wire [0:0]                 inst_m_axi_rid    ;
wire [`DATA_WIDTH-1:0]     inst_m_axi_rdata  ;
wire [1:0]                 inst_m_axi_rresp  ;
wire                       inst_m_axi_rlast  ;
wire                       inst_m_axi_rvalid ;
wire                       inst_m_axi_rready ;

wire                         inst_dma_cmd_vld   ; 
wire                         inst_dma_cmd_rdy   ; 
wire [`INST_DMA_CMD_LEN-1:0] inst_dma_cmd       ; 

wire [`ADDR_WIDTH-1:0]   inst_dma_read_desc_addr ;
wire [`LEN_WIDTH+4-1:0]  inst_dma_read_desc_len  ;
wire                     inst_dma_read_desc_valid;
wire                     inst_dma_read_desc_ready;

assign inst_dma_read_desc_valid = inst_dma_cmd_vld;
assign inst_dma_cmd_rdy         = inst_dma_read_desc_ready;
assign inst_dma_read_desc_addr  = inst_dma_cmd[36:5]; 
assign inst_dma_read_desc_len   = (inst_dma_cmd[48:37] + {{(`LEN_WIDTH+3){1'b0}},1'b1}) << 3; 

axi_dma_rd # (
    // Width of AXI data bus in bits
    .AXI_DATA_WIDTH    (`DATA_WIDTH   ), 
    // Width of AXI address bus in bits
    .AXI_ADDR_WIDTH    (`ADDR_WIDTH   ), 
    // Width of AXI ID signal
    .AXI_ID_WIDTH      (1             ), 
    // Maximum AXI burst length to generate
    .AXI_MAX_BURST_LEN (64            ), 
    // Use AXI stream tlast signal
    .AXIS_LAST_ENABLE  (0             ), 
    // Propagate AXI stream tid signal
    .AXIS_ID_ENABLE    (0             ), 
    // AXI stream tid signal width
    .AXIS_ID_WIDTH     (1             ), 
    // Propagate AXI stream tdest signal
    .AXIS_DEST_ENABLE  (0             ), 
    // AXI stream tdest signal width
    .AXIS_DEST_WIDTH   (1             ), 
    // Propagate AXI stream tuser signal
    .AXIS_USER_ENABLE  (0             ), 
    // AXI stream tuser signal width
    .AXIS_USER_WIDTH   (1             ), 
    // Width of length field
    .LEN_WIDTH         (`LEN_WIDTH+1+3), 
    // Width of tag field
    .TAG_WIDTH         (1             ), 
    // Enable support for scatter/gather DMA
    // (multiple descriptors per AXI stream frame)
    .ENABLE_SG         (0             ), 
    // Enable support for unaligned transfers
    .ENABLE_UNALIGNED  (1             ) 
)u_axi_dma_rd_cmd(
    .clk                          (clk          ), // (input )
    .rst                          (~rst_n       ), // (input )

    // AXI read descriptor input
    .s_axis_read_desc_addr        (inst_dma_read_desc_addr ), // (input )
    .s_axis_read_desc_len         (inst_dma_read_desc_len  ), // (input )
    .s_axis_read_desc_tag         (), // (input ) nc
    .s_axis_read_desc_id          (), // (input ) nc
    .s_axis_read_desc_dest        (), // (input ) nc
    .s_axis_read_desc_user        (), // (input ) nc
    .s_axis_read_desc_valid       (inst_dma_read_desc_valid), // (input )
    .s_axis_read_desc_ready       (inst_dma_read_desc_ready), // (output)

    // AXI read descriptor status output
    .m_axis_read_desc_status_tag  (), // (output) nc
    .m_axis_read_desc_status_error(), // (output) nc
    .m_axis_read_desc_status_valid(), // (output) nc

    // AXI stream read data output
    .m_axis_read_data_tdata       (inst_read_data_tdata  ), // (output)
    .m_axis_read_data_tkeep       (), // (output)
    .m_axis_read_data_tvalid      (inst_read_data_tvalid ), // (output)
    .m_axis_read_data_tready      (inst_read_data_tready ), // (input )
    .m_axis_read_data_tlast       (), // (output) nc
    .m_axis_read_data_tid         (), // (output) nc
    .m_axis_read_data_tdest       (), // (output) nc
    .m_axis_read_data_tuser       (), // (output) nc

    // AXI master interface
    .m_axi_arid                   (inst_m_axi_arid    ), // (output)
    .m_axi_araddr                 (inst_m_axi_araddr  ), // (output)
    .m_axi_arlen                  (inst_m_axi_arlen   ), // (output)
    .m_axi_arsize                 (inst_m_axi_arsize  ), // (output)
    .m_axi_arburst                (inst_m_axi_arburst ), // (output)
    .m_axi_arlock                 (inst_m_axi_arlock  ), // (output)
    .m_axi_arcache                (inst_m_axi_arcache ), // (output)
    .m_axi_arprot                 (inst_m_axi_arprot  ), // (output)
    .m_axi_arvalid                (inst_m_axi_arvalid ), // (output)
    .m_axi_arready                (inst_m_axi_arready ), // (input )
    .m_axi_rid                    (inst_m_axi_rid     ), // (input )
    .m_axi_rdata                  (inst_m_axi_rdata   ), // (input )
    .m_axi_rresp                  (inst_m_axi_rresp   ), // (input )
    .m_axi_rlast                  (inst_m_axi_rlast   ), // (input )
    .m_axi_rvalid                 (inst_m_axi_rvalid  ), // (input )
    .m_axi_rready                 (inst_m_axi_rready  ), // (output)

    // Configuration
    .enable                       (1'b1               ) // (input )
);

wire [`CMD_DATA_WIDTH-1:0]   intr_mask      ;
wire [`CMD_DATA_WIDTH-1:0]   intr_status    ;
wire [`CMD_DATA_WIDTH-1:0]   intr_raw_status;
wire [`CMD_DATA_WIDTH-1:0]   tiny_npu_status;
wire [`CMD_DATA_WIDTH-1:0]   systolic_status;
wire [`CMD_DATA_WIDTH-1:0]   cdma_status    ;

assign sync_intr_event = intr_status[0];

axil_register u_axil_register (
    .s_axil_ar_valid              (status_s_axil_arvalid  ), // (input )
    .s_axil_ar_ready              (status_s_axil_arready  ), // (output)
    .s_axil_ar_payload_addr       (status_s_axil_araddr   ), // (input )
    .s_axil_ar_payload_prot       (status_s_axil_arprot   ), // (input )
    .s_axil_r_valid               (status_s_axil_rvalid   ), // (output)
    .s_axil_r_ready               (status_s_axil_rready   ), // (input )
    .s_axil_r_payload_data        (status_s_axil_rdata    ), // (output)
    .s_axil_r_payload_resp        (status_s_axil_rresp    ), // (output)

    .intr_mask                    (intr_mask              ), // (input )
    .intr_status                  (intr_status            ), // (input )
    .intr_raw_status              (intr_raw_status        ), // (input )
    .tiny_npu_status              (tiny_npu_status        ), // (input )
    .systolic_status              (systolic_status        ), // (input )
    .cdma_status                  (cdma_status            ), // (input )
    .clk                          (clk                    ), // (input )
    .resetn                       (rst_n                  )  // (input )
);

register_tiny_npu # (
    .DATA_WIDTH                   (`CMD_DATA_WIDTH     ), 
    .ADDR_WIDTH                   (`CMD_ADDR_WIDTH     ), 
    .TAG_WIDTH                    (`TAG_WIDTH          )
) u_register_tiny_npu (
    .clk                          (clk                ), // (input )
    .rst_n                        (rst_n              ), // (input )
        
    .reg_data                     (axil_wdata         ), // (input )
    .reg_addr                     (axil_waddr         ), // (input )
    .reg_wr_en                    (axil_wr_en         ), // (input )
    
    .sync_status_en               (sync_status_en     ), // (input )
    .sync_status_tag              (sync_status_tag    ), // (input )

    .wr_buf_id                    (wr_buf_id          ), // (input )

    .intr_status                  (intr_status        ), 
    .intr_raw_status              (intr_raw_status    ), 
    .intr_mask                    (intr_mask          ), 
    .tiny_npu_status              (tiny_npu_status    ), 
    .systolic_status              (systolic_status    ), 
    .cdma_status                  (cdma_status        )  
);

wire                           systolic_unit_cmd_vld; 
wire                           systolic_unit_cmd_rdy; 
wire   [`SYSTOLIC_CMD_LEN-1:0] systolic_unit_cmd    ; 

wire                           cdma_cmd_vld         ; 
wire                           cdma_cmd_rdy         ; 
wire       [`CDMA_CMD_LEN-1:0] cdma_cmd             ; 

wire                           ppu_cmd_vld          ; 
wire                           ppu_cmd_rdy          ; 
wire       [`PPU_CMD_LEN-1:0]  ppu_cmd              ; 

wire          [`TAG_WIDTH-1:0] systolic_status_tag  ;  
wire                           systolic_status_en   ;  

wire          [`TAG_WIDTH-1:0] cdma_status_tag      ;  
wire                           cdma_status_en       ;  

wire          [`TAG_WIDTH-1:0] ppu_status_tag       ;  
wire                           ppu_status_en        ;  

control_tiny_npu # (
    .NINSTR ( `INSTR_WIDTH )          
) u_control_tiny_npu (
    .clk                          (clk                          ), // (input ) 
    .rst_n                        (rst_n                        ), // (input ) 

    .instruction_valid            (instr_rd_valid               ), // (input )
    .instruction                  (instr_rd_out                 ), // (input )
    .instruction_ready            (instr_rd_ready               ), // (output)

    .systolic_status_en           (systolic_status_en           ), // (input ) 
    .cdma_status_en               (cdma_status_en               ), // (input )
    .ppu_status_en                (ppu_status_en                ),

    .systolic_unit_cmd_vld        (systolic_unit_cmd_vld        ), // (output)
    .systolic_unit_cmd_rdy        (systolic_unit_cmd_rdy        ),
    .systolic_unit_cmd            (systolic_unit_cmd            ), // (output)
    .cdma_cmd_vld                 (cdma_cmd_vld                 ), // (output) 
    .cdma_cmd_rdy                 (cdma_cmd_rdy                 ),  
    .cdma_cmd                     (cdma_cmd                     ), // (output) 

    .ppu_cmd_vld                  (ppu_cmd_vld                  ),
    .ppu_cmd_rdy                  (ppu_cmd_rdy                  ),
    .ppu_cmd                      (ppu_cmd                      ),

    .inst_dma_cmd_vld             (inst_dma_cmd_vld             ),
    .inst_dma_cmd                 (inst_dma_cmd                 ),
    .inst_dma_cmd_rdy             (inst_dma_cmd_rdy             ),

    .sync_status_en               (sync_status_en               ), 
    .sync_status_tag              (sync_status_tag              ) 
);

// ++ weight axi dma channel 
wire                [0:0] weight_m_axi_arid    ; 
wire    [`ADDR_WIDTH-1:0] weight_m_axi_araddr  ; 
wire                [7:0] weight_m_axi_arlen   ; 
wire                [2:0] weight_m_axi_arsize  ; 
wire                [1:0] weight_m_axi_arburst ; 
wire                      weight_m_axi_arlock  ; 
wire                [3:0] weight_m_axi_arcache ; 
wire                [2:0] weight_m_axi_arprot  ; 
wire                      weight_m_axi_arvalid ; 
wire                      weight_m_axi_arready ; 

wire                [0:0] weight_m_axi_rid     ; 
wire    [`DATA_WIDTH-1:0] weight_m_axi_rdata   ; 
wire                [1:0] weight_m_axi_rresp   ; 
wire                      weight_m_axi_rlast   ; 
wire                      weight_m_axi_rvalid  ; 
wire                      weight_m_axi_rready  ; 

// ++ activation axi dam channel 
wire                [0:0] activation_m_axi_arid   ; 
wire    [`ADDR_WIDTH-1:0] activation_m_axi_araddr ; 
wire                [7:0] activation_m_axi_arlen  ; 
wire                [2:0] activation_m_axi_arsize ; 
wire                [1:0] activation_m_axi_arburst; 
wire                      activation_m_axi_arlock ; 
wire                [3:0] activation_m_axi_arcache; 
wire                [2:0] activation_m_axi_arprot ; 
wire                      activation_m_axi_arvalid; 
wire                      activation_m_axi_arready; 

wire                [0:0] activation_m_axi_rid    ; 
wire    [`DATA_WIDTH-1:0] activation_m_axi_rdata  ; 
wire                [1:0] activation_m_axi_rresp  ; 
wire                      activation_m_axi_rlast  ; 
wire                      activation_m_axi_rvalid ; 
wire                      activation_m_axi_rready ; 

wire [`PE_NCOL-1:0]            systolic_unit_vld_out ;
wire [`PE_NCOL*`PSUM_WIDTH-1:0]systolic_unit_res_out ;

top_systolic_unit # (
    .PE_NCOL                      (`PE_NCOL                     ), 
    .PE_NROW                      (`PE_NROW                     ), 
    .AXI_DATA_WIDTH               (`DATA_WIDTH                  ), 
    .DOWIDTH                      (`CALC_DWIDTH                 ), 
    .CHANNEL                      (`CALC_CHANNEL                ),
    .AXI_ADDR_WIDTH               (`ADDR_WIDTH                  ), // const
    .TAG_WIDTH                    (`TAG_WIDTH                   ), // const
    .LEN_WIDTH                    (`LEN_WIDTH                   ), // const
    .AXIS_USER_WIDTH              (`USER_WIDTH                  ), // const
    .ICMD_LEN                     (`SYSTOLIC_CMD_LEN            )  // const
) u_top_systolic_unit (
    .clk                          (clk                          ), // (input )
    .rst_n                        (rst_n                        ), // (input )

    // ++ config channel
    .cmd                          (systolic_unit_cmd            ), // (input )
    .cmd_vld                      (systolic_unit_cmd_vld        ), // (input )
    .cmd_rdy                      (systolic_unit_cmd_rdy        ),

    .systolic_status_tag          (systolic_status_tag          ), // (output)
    .systolic_status_en           (systolic_status_en           ), // (output)
    .wr_buf_id                    (wr_buf_id                    ),

    .vld_out                      (systolic_unit_vld_out        ),
    .res_out                      (systolic_unit_res_out        ),

    // ++ weight axi dma channel 
    .weight_m_axi_arid            (weight_m_axi_arid[0:0]       ), // (output)
    .weight_m_axi_araddr          (weight_m_axi_araddr          ), // (output)
    .weight_m_axi_arlen           (weight_m_axi_arlen[7:0]      ), // (output)
    .weight_m_axi_arsize          (weight_m_axi_arsize[2:0]     ), // (output)
    .weight_m_axi_arburst         (weight_m_axi_arburst[1:0]    ), // (output)
    .weight_m_axi_arlock          (weight_m_axi_arlock          ), // (output)
    .weight_m_axi_arcache         (weight_m_axi_arcache[3:0]    ), // (output)
    .weight_m_axi_arprot          (weight_m_axi_arprot[2:0]     ), // (output)
    .weight_m_axi_arvalid         (weight_m_axi_arvalid         ), // (output)
    .weight_m_axi_arready         (weight_m_axi_arready         ), // (input )

    .weight_m_axi_rid             (weight_m_axi_rid[0:0]        ), // (input )
    .weight_m_axi_rdata           (weight_m_axi_rdata           ), // (input )
    .weight_m_axi_rresp           (weight_m_axi_rresp[1:0]      ), // (input )
    .weight_m_axi_rlast           (weight_m_axi_rlast           ), // (input )
    .weight_m_axi_rvalid          (weight_m_axi_rvalid          ), // (input )
    .weight_m_axi_rready          (weight_m_axi_rready          ), // (output)

    // ++ activation axi dam channel 
    .activation_m_axi_arid        (activation_m_axi_arid[0:0]   ), // (output)
    .activation_m_axi_araddr      (activation_m_axi_araddr      ), // (output)
    .activation_m_axi_arlen       (activation_m_axi_arlen[7:0]  ), // (output)
    .activation_m_axi_arsize      (activation_m_axi_arsize[2:0] ), // (output)
    .activation_m_axi_arburst     (activation_m_axi_arburst[1:0]), // (output)
    .activation_m_axi_arlock      (activation_m_axi_arlock      ), // (output)
    .activation_m_axi_arcache     (activation_m_axi_arcache[3:0]), // (output)
    .activation_m_axi_arprot      (activation_m_axi_arprot[2:0] ), // (output)
    .activation_m_axi_arvalid     (activation_m_axi_arvalid     ), // (output)
    .activation_m_axi_arready     (activation_m_axi_arready     ), // (input )

    .activation_m_axi_rid         (activation_m_axi_rid[0:0]    ), // (input )
    .activation_m_axi_rdata       (activation_m_axi_rdata       ), // (input )
    .activation_m_axi_rresp       (activation_m_axi_rresp[1:0]  ), // (input )
    .activation_m_axi_rlast       (activation_m_axi_rlast       ), // (input )
    .activation_m_axi_rvalid      (activation_m_axi_rvalid      ), // (input )
    .activation_m_axi_rready      (activation_m_axi_rready      )  // (output)

    // --------------------------- axi dma 
);

wire [0:0]               ppu_gp0_m_axi_awid   ;
wire [`ADDR_WIDTH-1:0]   ppu_gp0_m_axi_awaddr ;
wire [7:0]               ppu_gp0_m_axi_awlen  ;
wire [2:0]               ppu_gp0_m_axi_awsize ;
wire [1:0]               ppu_gp0_m_axi_awburst;
wire                     ppu_gp0_m_axi_awvalid;
wire                     ppu_gp0_m_axi_awready;
wire [`DATA_WIDTH-1:0]   ppu_gp0_m_axi_wdata  ;
wire [`DATA_WIDTH/8-1:0] ppu_gp0_m_axi_wstrb  ;
wire                     ppu_gp0_m_axi_wlast  ;
wire                     ppu_gp0_m_axi_wvalid ;
wire                     ppu_gp0_m_axi_wready ;
wire [0:0]               ppu_gp0_m_axi_bid    ;
wire [1:0]               ppu_gp0_m_axi_bresp  ;
wire                     ppu_gp0_m_axi_bvalid ;
wire                     ppu_gp0_m_axi_bready ;

wire [0:0]               ppu_gp1_m_axi_awid   ;
wire [`ADDR_WIDTH-1:0]   ppu_gp1_m_axi_awaddr ;
wire [7:0]               ppu_gp1_m_axi_awlen  ;
wire [2:0]               ppu_gp1_m_axi_awsize ;
wire [1:0]               ppu_gp1_m_axi_awburst;
wire                     ppu_gp1_m_axi_awvalid;
wire                     ppu_gp1_m_axi_awready;
wire [`DATA_WIDTH-1:0]   ppu_gp1_m_axi_wdata  ;
wire [`DATA_WIDTH/8-1:0] ppu_gp1_m_axi_wstrb  ;
wire                     ppu_gp1_m_axi_wlast  ;
wire                     ppu_gp1_m_axi_wvalid ;
wire                     ppu_gp1_m_axi_wready ;
wire [0:0]               ppu_gp1_m_axi_bid    ;
wire [1:0]               ppu_gp1_m_axi_bresp  ;
wire                     ppu_gp1_m_axi_bvalid ;
wire                     ppu_gp1_m_axi_bready ;

top_ppu # (
    .PSUM_WIDTH                   (`PSUM_WIDTH       ), 
    .AXI_DATA_WIDTH               (`DATA_WIDTH       ), 
    .AXI_ADDR_WIDTH               (`ADDR_WIDTH       ), 
    .PPU_CMD_LEN                  (`PPU_CMD_LEN      ), 
    .LEN_WIDTH                    (`LEN_WIDTH        ), 
    .TAG_WIDTH                    (`TAG_WIDTH        ) 
) u_top_ppu (
    .clk                          (clk                     ), // (input )
    .rst_n                        (rst_n                   ), // (input )

    .ppu_cmd_vld                  (ppu_cmd_vld             ), // (input )
    .ppu_cmd                      (ppu_cmd                 ), // (input )
    .ppu_cmd_rdy                  (ppu_cmd_rdy             ), // (output)

    .ppu_status_en                (ppu_status_en           ), // (output)
    .ppu_status_tag               (ppu_status_tag          ), // (output)

    .ppu_data_rdy                 (                        ), // (output) nc
    .ppu_data_vld                 (systolic_unit_vld_out   ), // (input )
    .ppu_data                     (systolic_unit_res_out   ), // (input )

    // ppu master group0
    .ppu_gp0_m_axi_awid           (ppu_gp0_m_axi_awid      ), // (output)
    .ppu_gp0_m_axi_awaddr         (ppu_gp0_m_axi_awaddr    ), // (output)
    .ppu_gp0_m_axi_awlen          (ppu_gp0_m_axi_awlen     ), // (output)
    .ppu_gp0_m_axi_awsize         (ppu_gp0_m_axi_awsize    ), // (output)
    .ppu_gp0_m_axi_awburst        (ppu_gp0_m_axi_awburst   ), // (output)
    .ppu_gp0_m_axi_awvalid        (ppu_gp0_m_axi_awvalid   ), // (output)
    .ppu_gp0_m_axi_awready        (ppu_gp0_m_axi_awready   ), // (input )
    .ppu_gp0_m_axi_wdata          (ppu_gp0_m_axi_wdata     ), // (output)
    .ppu_gp0_m_axi_wstrb          (ppu_gp0_m_axi_wstrb     ), // (output)
    .ppu_gp0_m_axi_wlast          (ppu_gp0_m_axi_wlast     ), // (output)
    .ppu_gp0_m_axi_wvalid         (ppu_gp0_m_axi_wvalid    ), // (output)
    .ppu_gp0_m_axi_wready         (ppu_gp0_m_axi_wready    ), // (input )
    .ppu_gp0_m_axi_bid            (ppu_gp0_m_axi_bid       ), // (input )
    .ppu_gp0_m_axi_bresp          (ppu_gp0_m_axi_bresp     ), // (input )
    .ppu_gp0_m_axi_bvalid         (ppu_gp0_m_axi_bvalid    ), // (input )
    .ppu_gp0_m_axi_bready         (ppu_gp0_m_axi_bready    ), // (output)

    // ppu master group1
    .ppu_gp1_m_axi_awid           (ppu_gp1_m_axi_awid      ), // (output)
    .ppu_gp1_m_axi_awaddr         (ppu_gp1_m_axi_awaddr    ), // (output)
    .ppu_gp1_m_axi_awlen          (ppu_gp1_m_axi_awlen     ), // (output)
    .ppu_gp1_m_axi_awsize         (ppu_gp1_m_axi_awsize    ), // (output)
    .ppu_gp1_m_axi_awburst        (ppu_gp1_m_axi_awburst   ), // (output)
    .ppu_gp1_m_axi_awvalid        (ppu_gp1_m_axi_awvalid   ), // (output)
    .ppu_gp1_m_axi_awready        (ppu_gp1_m_axi_awready   ), // (input )
    .ppu_gp1_m_axi_wdata          (ppu_gp1_m_axi_wdata     ), // (output)
    .ppu_gp1_m_axi_wstrb          (ppu_gp1_m_axi_wstrb     ), // (output)
    .ppu_gp1_m_axi_wlast          (ppu_gp1_m_axi_wlast     ), // (output)
    .ppu_gp1_m_axi_wvalid         (ppu_gp1_m_axi_wvalid    ), // (output)
    .ppu_gp1_m_axi_wready         (ppu_gp1_m_axi_wready    ), // (input )
    .ppu_gp1_m_axi_bid            (ppu_gp1_m_axi_bid       ), // (input )
    .ppu_gp1_m_axi_bresp          (ppu_gp1_m_axi_bresp     ), // (input )
    .ppu_gp1_m_axi_bvalid         (ppu_gp1_m_axi_bvalid    ), // (input )
    .ppu_gp1_m_axi_bready         (ppu_gp1_m_axi_bready    )  // (output)
);

wire                [2:0] gb_s_axi_awid           ; 
wire [`GLOBAL_BUFFER_SIZE-1:0] gb_s_axi_awaddr    ; 
wire                [7:0] gb_s_axi_awlen          ; 
wire                [2:0] gb_s_axi_awsize         ; 
wire                [1:0] gb_s_axi_awburst        ; 
wire                      gb_s_axi_awlock         ; 
wire                [3:0] gb_s_axi_awcache        ; 
wire                [2:0] gb_s_axi_awprot         ; 
wire                      gb_s_axi_awvalid        ; 
wire                      gb_s_axi_awready        ; 
wire    [`DATA_WIDTH-1:0] gb_s_axi_wdata          ; 
wire  [`DATA_WIDTH/8-1:0] gb_s_axi_wstrb          ; 
wire                      gb_s_axi_wlast          ; 
wire                      gb_s_axi_wvalid         ; 
wire                      gb_s_axi_wready         ; 
wire                [2:0] gb_s_axi_bid            ; 
wire                [1:0] gb_s_axi_bresp          ; 
wire                      gb_s_axi_bvalid         ; 
wire                      gb_s_axi_bready         ; 
wire                [2:0] gb_s_axi_arid           ; 
wire [`GLOBAL_BUFFER_SIZE-1:0] gb_s_axi_araddr    ; 
wire                [7:0] gb_s_axi_arlen          ; 
wire                [2:0] gb_s_axi_arsize         ; 
wire                [1:0] gb_s_axi_arburst        ; 
wire                      gb_s_axi_arlock         ; 
wire                [3:0] gb_s_axi_arcache        ; 
wire                [2:0] gb_s_axi_arprot         ; 
wire                      gb_s_axi_arvalid        ; 
wire                      gb_s_axi_arready        ; 
wire                [2:0] gb_s_axi_rid            ; 
wire    [`DATA_WIDTH-1:0] gb_s_axi_rdata          ; 
wire                [1:0] gb_s_axi_rresp          ; 
wire                      gb_s_axi_rlast          ; 
wire                      gb_s_axi_rvalid         ; 
wire                      gb_s_axi_rready         ; 

`ifndef FPGA_SOURCE 
axi_ram # (
    // Width of data bus in bits
    .DATA_WIDTH                   (`DATA_WIDTH                   ),
    // Width of address bus in bits
    .ADDR_WIDTH                   (`GLOBAL_BUFFER_SIZE           ), 
    // Width of ID signal
    .ID_WIDTH                     (3                             ), 
    // Extra pipeline register on output
    .PIPELINE_OUTPUT              (1                             ) 
)u_global_buffer(
    .clk                          (clk                           ), // (input )
    .rst                          (~rst_n                        ), // (input )

    .s_axi_awid                   (gb_s_axi_awid                 ), // (input )
    .s_axi_awaddr                 (gb_s_axi_awaddr               ), // (input )
    .s_axi_awlen                  (gb_s_axi_awlen[7:0]           ), // (input )
    .s_axi_awsize                 (gb_s_axi_awsize[2:0]          ), // (input )
    .s_axi_awburst                (gb_s_axi_awburst[1:0]         ), // (input )
    .s_axi_awlock                 (gb_s_axi_awlock               ), // (input )
    .s_axi_awcache                (gb_s_axi_awcache[3:0]         ), // (input )
    .s_axi_awprot                 (gb_s_axi_awprot[2:0]          ), // (input )
    .s_axi_awvalid                (gb_s_axi_awvalid              ), // (input )
    .s_axi_awready                (gb_s_axi_awready              ), // (output)
    .s_axi_wdata                  (gb_s_axi_wdata                ), // (input )
    .s_axi_wstrb                  (gb_s_axi_wstrb                ), // (input )
    .s_axi_wlast                  (gb_s_axi_wlast                ), // (input )
    .s_axi_wvalid                 (gb_s_axi_wvalid               ), // (input )
    .s_axi_wready                 (gb_s_axi_wready               ), // (output)
    .s_axi_bid                    (gb_s_axi_bid                  ), // (output)
    .s_axi_bresp                  (gb_s_axi_bresp[1:0]           ), // (output)
    .s_axi_bvalid                 (gb_s_axi_bvalid               ), // (output)
    .s_axi_bready                 (gb_s_axi_bready               ), // (input )
    .s_axi_arid                   (gb_s_axi_arid                 ), // (input )
    .s_axi_araddr                 (gb_s_axi_araddr               ), // (input )
    .s_axi_arlen                  (gb_s_axi_arlen[7:0]           ), // (input )
    .s_axi_arsize                 (gb_s_axi_arsize[2:0]          ), // (input )
    .s_axi_arburst                (gb_s_axi_arburst[1:0]         ), // (input )
    .s_axi_arlock                 (gb_s_axi_arlock               ), // (input )
    .s_axi_arcache                (gb_s_axi_arcache[3:0]         ), // (input )
    .s_axi_arprot                 (gb_s_axi_arprot[2:0]          ), // (input )
    .s_axi_arvalid                (gb_s_axi_arvalid              ), // (input )
    .s_axi_arready                (gb_s_axi_arready              ), // (output)
    .s_axi_rid                    (gb_s_axi_rid                  ), // (output)
    .s_axi_rdata                  (gb_s_axi_rdata                ), // (output)
    .s_axi_rresp                  (gb_s_axi_rresp[1:0]           ), // (output)
    .s_axi_rlast                  (gb_s_axi_rlast                ), // (output)
    .s_axi_rvalid                 (gb_s_axi_rvalid               ), // (output)
    .s_axi_rready                 (gb_s_axi_rready               )  // (input )
);
`else 
global_buffer_top_tiny_npu u_global_buffer (
  .s_aclk(clk),                // input wire s_aclk
  .s_aresetn(rst_n),          // input wire s_aresetn
  .s_axi_awid(gb_s_axi_awid),        // input wire [2 : 0] s_axi_awid
  .s_axi_awaddr(gb_s_axi_awaddr),    // input wire [31 : 0] s_axi_awaddr
  .s_axi_awlen(gb_s_axi_awlen[7:0] ),      // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize(gb_s_axi_awsize[2:0] ),    // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst(gb_s_axi_awburst[1:0]   ),  // input wire [1 : 0] s_axi_awburst
  .s_axi_awvalid(gb_s_axi_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(gb_s_axi_awready),  // output wire s_axi_awready
  .s_axi_wdata(gb_s_axi_wdata),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb(gb_s_axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wlast(gb_s_axi_wlast),      // input wire s_axi_wlast
  .s_axi_wvalid(gb_s_axi_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(gb_s_axi_wready),    // output wire s_axi_wready
  .s_axi_bid(gb_s_axi_bid),          // output wire [2 : 0] s_axi_bid
  .s_axi_bresp(gb_s_axi_bresp[1:0] ),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(gb_s_axi_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(gb_s_axi_bready),    // input wire s_axi_bready
  .s_axi_arid(gb_s_axi_arid),        // input wire [2 : 0] s_axi_arid
  .s_axi_araddr(gb_s_axi_araddr),    // input wire [31 : 0] s_axi_araddr
  .s_axi_arlen(gb_s_axi_arlen[7:0] ),      // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize(gb_s_axi_arsize[2:0] ),    // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst(gb_s_axi_arburst[1:0]  ),  // input wire [1 : 0] s_axi_arburst
  .s_axi_arvalid(gb_s_axi_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(gb_s_axi_arready),  // output wire s_axi_arready
  .s_axi_rid(gb_s_axi_rid),          // output wire [2 : 0] s_axi_rid
  .s_axi_rdata(gb_s_axi_rdata),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp(gb_s_axi_rresp[1:0] ),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rlast(gb_s_axi_rlast),      // output wire s_axi_rlast
  .s_axi_rvalid(gb_s_axi_rvalid),    // output wire s_axi_rvalid
  .s_axi_rready(gb_s_axi_rready)    // input wire s_axi_rready
);
`endif 

wire                [0:0] cdma_m_axi_awid           ; 
wire    [`ADDR_WIDTH-1:0] cdma_m_axi_awaddr         ; 
wire                [7:0] cdma_m_axi_awlen          ; 
wire                [2:0] cdma_m_axi_awsize         ; 
wire                [1:0] cdma_m_axi_awburst        ; 
wire                      cdma_m_axi_awlock         ; 
wire                [3:0] cdma_m_axi_awcache        ; 
wire                [2:0] cdma_m_axi_awprot         ; 
wire                      cdma_m_axi_awvalid        ; 
wire                      cdma_m_axi_awready        ; 
wire    [`DATA_WIDTH-1:0] cdma_m_axi_wdata          ; 
wire  [`DATA_WIDTH/8-1:0] cdma_m_axi_wstrb          ; 
wire                      cdma_m_axi_wlast          ; 
wire                      cdma_m_axi_wvalid         ; 
wire                      cdma_m_axi_wready         ; 
wire                [0:0] cdma_m_axi_bid            ; 
wire                [1:0] cdma_m_axi_bresp          ; 
wire                      cdma_m_axi_bvalid         ; 
wire                      cdma_m_axi_bready         ; 
wire                [0:0] cdma_m_axi_arid           ; 
wire    [`ADDR_WIDTH-1:0] cdma_m_axi_araddr         ; 
wire                [7:0] cdma_m_axi_arlen          ; 
wire                [2:0] cdma_m_axi_arsize         ; 
wire                [1:0] cdma_m_axi_arburst        ; 
wire                      cdma_m_axi_arlock         ; 
wire                [3:0] cdma_m_axi_arcache        ; 
wire                [2:0] cdma_m_axi_arprot         ; 
wire                      cdma_m_axi_arvalid        ; 
wire                      cdma_m_axi_arready        ; 
wire                [0:0] cdma_m_axi_rid            ; 
wire    [`DATA_WIDTH-1:0] cdma_m_axi_rdata          ; 
wire                [1:0] cdma_m_axi_rresp          ; 
wire                      cdma_m_axi_rlast          ; 
wire                      cdma_m_axi_rvalid         ; 
wire                      cdma_m_axi_rready         ; 

top_axi_cdma # (
    .DATA_WIDTH                   (`DATA_WIDTH                  ), 
    .ADDR_WIDTH                   (`ADDR_WIDTH                  ), // const
    .LEN_WIDTH                    (`LEN_WIDTH                   ), // const
    .ICMD_LEN                     (`CDMA_CMD_LEN                ), // const
    .TAG_WIDTH                    (`TAG_WIDTH                   )  // const
)u_top_axi_cdma(
    .clk                          (clk                          ), // (input )
    .rst_n                        (rst_n                        ), // (input )

    .cmd                          (cdma_cmd                     ), // (input ) 
    .cmd_vld                      (cdma_cmd_vld                 ), // (input )
    .cmd_rdy                      (cdma_cmd_rdy                 ),

    .cdma_status_tag              (cdma_status_tag              ), // (output)
    .cdma_status_en               (cdma_status_en               ), // (output)

    .cdma_m_axi_awid              (cdma_m_axi_awid[0:0]         ), // (output) 
    .cdma_m_axi_awaddr            (cdma_m_axi_awaddr            ), // (output) 
    .cdma_m_axi_awlen             (cdma_m_axi_awlen[7:0]        ), // (output) 
    .cdma_m_axi_awsize            (cdma_m_axi_awsize[2:0]       ), // (output) 
    .cdma_m_axi_awburst           (cdma_m_axi_awburst[1:0]      ), // (output) 
    .cdma_m_axi_awlock            (cdma_m_axi_awlock            ), // (output) 
    .cdma_m_axi_awcache           (cdma_m_axi_awcache[3:0]      ), // (output) 
    .cdma_m_axi_awprot            (cdma_m_axi_awprot[2:0]       ), // (output) 
    .cdma_m_axi_awvalid           (cdma_m_axi_awvalid           ), // (output) 
    .cdma_m_axi_awready           (cdma_m_axi_awready           ), // (input ) 
    
    .cdma_m_axi_wdata             (cdma_m_axi_wdata             ), // (output) 
    .cdma_m_axi_wstrb             (cdma_m_axi_wstrb             ), // (output) 
    .cdma_m_axi_wlast             (cdma_m_axi_wlast             ), // (output) 
    .cdma_m_axi_wvalid            (cdma_m_axi_wvalid            ), // (output) 
    .cdma_m_axi_wready            (cdma_m_axi_wready            ), // (input ) 
    
    .cdma_m_axi_bid               (cdma_m_axi_bid[0:0]          ), // (input ) 
    .cdma_m_axi_bresp             (cdma_m_axi_bresp[1:0]        ), // (input ) 
    .cdma_m_axi_bvalid            (cdma_m_axi_bvalid            ), // (input ) 
    .cdma_m_axi_bready            (cdma_m_axi_bready            ), // (output) 
    
    .cdma_m_axi_arid              (cdma_m_axi_arid[0:0]         ), // (output) 
    .cdma_m_axi_araddr            (cdma_m_axi_araddr            ), // (output) 
    .cdma_m_axi_arlen             (cdma_m_axi_arlen[7:0]        ), // (output) 
    .cdma_m_axi_arsize            (cdma_m_axi_arsize[2:0]       ), // (output) 
    .cdma_m_axi_arburst           (cdma_m_axi_arburst[1:0]      ), // (output) 
    .cdma_m_axi_arlock            (cdma_m_axi_arlock            ), // (output) 
    .cdma_m_axi_arcache           (cdma_m_axi_arcache[3:0]      ), // (output) 
    .cdma_m_axi_arprot            (cdma_m_axi_arprot[2:0]       ), // (output) 
    .cdma_m_axi_arvalid           (cdma_m_axi_arvalid           ), // (output) 
    .cdma_m_axi_arready           (cdma_m_axi_arready           ), // (input ) 
    
    .cdma_m_axi_rid               (cdma_m_axi_rid[0:0]          ), // (input ) 
    .cdma_m_axi_rdata             (cdma_m_axi_rdata             ), // (input ) 
    .cdma_m_axi_rresp             (cdma_m_axi_rresp[1:0]        ), // (input ) 
    .cdma_m_axi_rlast             (cdma_m_axi_rlast             ), // (input ) 
    .cdma_m_axi_rvalid            (cdma_m_axi_rvalid            ), // (input ) 
    .cdma_m_axi_rready            (cdma_m_axi_rready            )  // (output) 
);

axi_crossbar_wrap_4x2 # (
    // Width of data bus in bits
    .DATA_WIDTH                   (`DATA_WIDTH                  ), 
    // Width of address bus in bits
    .ADDR_WIDTH                   (`ADDR_WIDTH                  ), 
    // Input ID field width (from AXI masters)
    .S_ID_WIDTH                   (1                            ), 
    .S_COUNT                      (4                            ),
    .M_COUNT                      (2                            ),
    .M_REGIONS                    (1                            ), 
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    .M00_BASE_ADDR                (`GLOBAL_BUFFER_ADDR          ), 
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    .M00_ADDR_WIDTH               (`GLOBAL_BUFFER_SIZE          ), 
    // Read connections between interfaces
    .M01_BASE_ADDR                (`DATA_BUFFER_ADDR            ), 
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    .M01_ADDR_WIDTH               (`DATA_BUFFER_SIZE            ) 
)u_axi_crossbar_wrap_4x2(
    .clk                          (clk                          ), // (input )
    .rst                          (~rst_n                       ), // (input )

    // +++++ AXI slave interface
    // ++ S00
    .s00_axi_awid                 (ppu_gp0_m_axi_awid           ), // (input )
    .s00_axi_awaddr               (ppu_gp0_m_axi_awaddr         ), // (input )
    .s00_axi_awlen                (ppu_gp0_m_axi_awlen          ), // (input )
    .s00_axi_awsize               (ppu_gp0_m_axi_awsize         ), // (input )
    .s00_axi_awburst              (ppu_gp0_m_axi_awburst        ), // (input )
    .s00_axi_awlock               (1'b0                         ), // (input ) 
    .s00_axi_awcache              (4'b0                         ), // (input ) Default cache
    .s00_axi_awprot               (3'b0                         ), // (input ) Default prot
    .s00_axi_awqos                (4'b0                         ), // (input )
    .s00_axi_awuser               (1'b0), // (input )
    .s00_axi_awvalid              (ppu_gp0_m_axi_awvalid        ), // (input )
    .s00_axi_awready              (ppu_gp0_m_axi_awready        ), // (output)
    .s00_axi_wdata                (ppu_gp0_m_axi_wdata          ), // (input )
    .s00_axi_wstrb                (ppu_gp0_m_axi_wstrb          ), // (input )
    .s00_axi_wlast                (ppu_gp0_m_axi_wlast          ), // (input )
    .s00_axi_wuser                (1'b0), // (input )
    .s00_axi_wvalid               (ppu_gp0_m_axi_wvalid         ), // (input )
    .s00_axi_wready               (ppu_gp0_m_axi_wready         ), // (output)
    .s00_axi_bid                  (ppu_gp0_m_axi_bid            ), // (output)
    .s00_axi_bresp                (ppu_gp0_m_axi_bresp          ), // (output)
    .s00_axi_buser                (                             ), // (output)
    .s00_axi_bvalid               (ppu_gp0_m_axi_bvalid         ), // (output)
    .s00_axi_bready               (ppu_gp0_m_axi_bready         ), // (input )

    .s00_axi_arid                 (weight_m_axi_arid            ), // (input )
    .s00_axi_araddr               (weight_m_axi_araddr          ), // (input )
    .s00_axi_arlen                (weight_m_axi_arlen           ), // (input )
    .s00_axi_arsize               (weight_m_axi_arsize          ), // (input )
    .s00_axi_arburst              (weight_m_axi_arburst         ), // (input )
    .s00_axi_arlock               (weight_m_axi_arlock          ), // (input )
    .s00_axi_arcache              (weight_m_axi_arcache         ), // (input )
    .s00_axi_arprot               (weight_m_axi_arprot          ), // (input )
    .s00_axi_arqos                (1'b0), // (input )
    .s00_axi_aruser               (1'b0), // (input )
    .s00_axi_arvalid              (weight_m_axi_arvalid         ), // (input )
    .s00_axi_arready              (weight_m_axi_arready         ), // (output)
    .s00_axi_rid                  (weight_m_axi_rid             ), // (output)
    .s00_axi_rdata                (weight_m_axi_rdata           ), // (output)
    .s00_axi_rresp                (weight_m_axi_rresp           ), // (output)
    .s00_axi_rlast                (weight_m_axi_rlast           ), // (output)
    .s00_axi_ruser                (                             ), // (output)
    .s00_axi_rvalid               (weight_m_axi_rvalid          ), // (output)
    .s00_axi_rready               (weight_m_axi_rready          ), // (input )
    // -- S00

    // ++ S01
    .s01_axi_awid                 (ppu_gp1_m_axi_awid           ), // (input )
    .s01_axi_awaddr               (ppu_gp1_m_axi_awaddr         ), // (input )
    .s01_axi_awlen                (ppu_gp1_m_axi_awlen          ), // (input )
    .s01_axi_awsize               (ppu_gp1_m_axi_awsize         ), // (input )
    .s01_axi_awburst              (ppu_gp1_m_axi_awburst        ), // (input )
    .s01_axi_awlock               (1'b0                         ), // (input )
    .s01_axi_awcache              (4'b0                         ), // (input )
    .s01_axi_awprot               (3'b0                         ), // (input )
    .s01_axi_awqos                (4'b0                         ), // (input )
    .s01_axi_awuser               (1'b0), // (input )
    .s01_axi_awvalid              (ppu_gp1_m_axi_awvalid        ), // (input )
    .s01_axi_awready              (ppu_gp1_m_axi_awready        ), // (output)
    .s01_axi_wdata                (ppu_gp1_m_axi_wdata          ), // (input )
    .s01_axi_wstrb                (ppu_gp1_m_axi_wstrb          ), // (input )
    .s01_axi_wlast                (ppu_gp1_m_axi_wlast          ), // (input )
    .s01_axi_wuser                (1'b0), // (input )
    .s01_axi_wvalid               (ppu_gp1_m_axi_wvalid         ), // (input )
    .s01_axi_wready               (ppu_gp1_m_axi_wready         ), // (output)
    .s01_axi_bid                  (ppu_gp1_m_axi_bid            ), // (output)
    .s01_axi_bresp                (ppu_gp1_m_axi_bresp          ), // (output)
    .s01_axi_buser                (                             ), // (output)
    .s01_axi_bvalid               (ppu_gp1_m_axi_bvalid         ), // (output)
    .s01_axi_bready               (ppu_gp1_m_axi_bready         ), // (input )

    .s01_axi_arid                 (activation_m_axi_arid        ), // (input )
    .s01_axi_araddr               (activation_m_axi_araddr      ), // (input )
    .s01_axi_arlen                (activation_m_axi_arlen[7:0]  ), // (input )
    .s01_axi_arsize               (activation_m_axi_arsize[2:0] ), // (input )
    .s01_axi_arburst              (activation_m_axi_arburst[1:0]), // (input )
    .s01_axi_arlock               (activation_m_axi_arlock      ), // (input )
    .s01_axi_arcache              (activation_m_axi_arcache[3:0]), // (input )
    .s01_axi_arprot               (activation_m_axi_arprot[2:0] ), // (input )
    .s01_axi_arqos                (1'b0), // (input )
    .s01_axi_aruser               (1'b0), // (input )
    .s01_axi_arvalid              (activation_m_axi_arvalid     ), // (input )
    .s01_axi_arready              (activation_m_axi_arready     ), // (output)
    .s01_axi_rid                  (activation_m_axi_rid         ), // (output)
    .s01_axi_rdata                (activation_m_axi_rdata       ), // (output)
    .s01_axi_rresp                (activation_m_axi_rresp[1:0]  ), // (output)
    .s01_axi_rlast                (activation_m_axi_rlast       ), // (output)
    .s01_axi_ruser                (                             ), // (output)
    .s01_axi_rvalid               (activation_m_axi_rvalid      ), // (output)
    .s01_axi_rready               (activation_m_axi_rready      ), // (input )
    // -- S01

    // ++ S02
    .s02_axi_awid                 (cdma_m_axi_awid              ), // (input )
    .s02_axi_awaddr               (cdma_m_axi_awaddr            ), // (input )
    .s02_axi_awlen                (cdma_m_axi_awlen             ), // (input )
    .s02_axi_awsize               (cdma_m_axi_awsize            ), // (input )
    .s02_axi_awburst              (cdma_m_axi_awburst           ), // (input )
    .s02_axi_awlock               (cdma_m_axi_awlock            ), // (input )
    .s02_axi_awcache              (cdma_m_axi_awcache           ), // (input )
    .s02_axi_awprot               (cdma_m_axi_awprot            ), // (input )
    .s02_axi_awqos                (1'b0), // (input )
    .s02_axi_awuser               (1'b0), // (input )
    .s02_axi_awvalid              (cdma_m_axi_awvalid           ), // (input )
    .s02_axi_awready              (cdma_m_axi_awready           ), // (output)
    .s02_axi_wdata                (cdma_m_axi_wdata             ), // (input )
    .s02_axi_wstrb                (cdma_m_axi_wstrb             ), // (input )
    .s02_axi_wlast                (cdma_m_axi_wlast             ), // (input )
    .s02_axi_wuser                (1'b0), // (input )
    .s02_axi_wvalid               (cdma_m_axi_wvalid            ), // (input )
    .s02_axi_wready               (cdma_m_axi_wready            ), // (output)
    .s02_axi_bid                  (cdma_m_axi_bid               ), // (output)
    .s02_axi_bresp                (cdma_m_axi_bresp             ), // (output)
    .s02_axi_buser                (                             ), // (output)
    .s02_axi_bvalid               (cdma_m_axi_bvalid            ), // (output)
    .s02_axi_bready               (cdma_m_axi_bready            ), // (input )
    .s02_axi_arid                 (cdma_m_axi_arid              ), // (input )
    .s02_axi_araddr               (cdma_m_axi_araddr            ), // (input )
    .s02_axi_arlen                (cdma_m_axi_arlen             ), // (input )
    .s02_axi_arsize               (cdma_m_axi_arsize            ), // (input )
    .s02_axi_arburst              (cdma_m_axi_arburst           ), // (input )
    .s02_axi_arlock               (cdma_m_axi_arlock            ), // (input )
    .s02_axi_arcache              (cdma_m_axi_arcache           ), // (input )
    .s02_axi_arprot               (cdma_m_axi_arprot            ), // (input )
    .s02_axi_arqos                (1'b0), // (input )
    .s02_axi_aruser               (1'b0), // (input )
    .s02_axi_arvalid              (cdma_m_axi_arvalid           ), // (input )
    .s02_axi_arready              (cdma_m_axi_arready           ), // (output)
    .s02_axi_rid                  (cdma_m_axi_rid               ), // (output)
    .s02_axi_rdata                (cdma_m_axi_rdata             ), // (output)
    .s02_axi_rresp                (cdma_m_axi_rresp             ), // (output)
    .s02_axi_rlast                (cdma_m_axi_rlast             ), // (output)
    .s02_axi_ruser                (                             ), // (output)
    .s02_axi_rvalid               (cdma_m_axi_rvalid            ), // (output)
    .s02_axi_rready               (cdma_m_axi_rready            ), // (input )
    // -- S02

    // ++ S03
    .s03_axi_awid                 (1'b0), // (input )
    .s03_axi_awaddr               (1'b0), // (input )
    .s03_axi_awlen                (1'b0), // (input )
    .s03_axi_awsize               (1'b0), // (input )
    .s03_axi_awburst              (1'b0), // (input )
    .s03_axi_awlock               (1'b0), // (input )
    .s03_axi_awcache              (1'b0), // (input )
    .s03_axi_awprot               (1'b0), // (input )
    .s03_axi_awqos                (1'b0), // (input )
    .s03_axi_awuser               (1'b0), // (input )
    .s03_axi_awvalid              (1'b0), // (input )
    .s03_axi_awready              (), // (output)
    .s03_axi_wdata                (1'b0), // (input )
    .s03_axi_wstrb                (1'b0), // (input )
    .s03_axi_wlast                (1'b0), // (input )
    .s03_axi_wuser                (1'b0), // (input )
    .s03_axi_wvalid               (1'b0), // (input )
    .s03_axi_wready               (), // (output)
    .s03_axi_bid                  (), // (output)
    .s03_axi_bresp                (), // (output)
    .s03_axi_buser                (), // (output)
    .s03_axi_bvalid               (), // (output)
    .s03_axi_bready               (1'b0), // (input )

    .s03_axi_arid                 (inst_m_axi_arid    ), // (input )
    .s03_axi_araddr               (inst_m_axi_araddr  ), // (input )
    .s03_axi_arlen                (inst_m_axi_arlen   ), // (input )
    .s03_axi_arsize               (inst_m_axi_arsize  ), // (input )
    .s03_axi_arburst              (inst_m_axi_arburst ), // (input )
    .s03_axi_arlock               (inst_m_axi_arlock  ), // (input )
    .s03_axi_arcache              (inst_m_axi_arcache ), // (input )
    .s03_axi_arprot               (inst_m_axi_arprot  ), // (input )
    .s03_axi_arqos                (1'b0), // (input ) nc
    .s03_axi_aruser               (1'b0), // (input ) nc
    .s03_axi_arvalid              (inst_m_axi_arvalid ), // (input )
    .s03_axi_arready              (inst_m_axi_arready ), // (output)
    .s03_axi_rid                  (inst_m_axi_rid     ), // (output)
    .s03_axi_rdata                (inst_m_axi_rdata   ), // (output)
    .s03_axi_rresp                (inst_m_axi_rresp   ), // (output)
    .s03_axi_rlast                (inst_m_axi_rlast   ), // (output)
    .s03_axi_ruser                (), // (output) nc
    .s03_axi_rvalid               (inst_m_axi_rvalid  ), // (output)
    .s03_axi_rready               (inst_m_axi_rready  ), // (input )
    // -- S03
 
    // AXI master interface
    // ++ M00
    .m00_axi_awid                 (gb_s_axi_awid                ), // (output)
    .m00_axi_awaddr               (gb_s_axi_awaddr              ), // (output)
    .m00_axi_awlen                (gb_s_axi_awlen[7:0]          ), // (output)
    .m00_axi_awsize               (gb_s_axi_awsize[2:0]         ), // (output)
    .m00_axi_awburst              (gb_s_axi_awburst[1:0]        ), // (output)
    .m00_axi_awlock               (gb_s_axi_awlock              ), // (output)
    .m00_axi_awcache              (gb_s_axi_awcache[3:0]        ), // (output)
    .m00_axi_awprot               (gb_s_axi_awprot[2:0]         ), // (output)
    .m00_axi_awqos                (                             ), // (output)
    .m00_axi_awregion             (                             ), // (output)
    .m00_axi_awuser               (                             ), // (output)
    .m00_axi_awvalid              (gb_s_axi_awvalid             ), // (output)
    .m00_axi_awready              (gb_s_axi_awready             ), // (input )
    .m00_axi_wdata                (gb_s_axi_wdata               ), // (output)
    .m00_axi_wstrb                (gb_s_axi_wstrb               ), // (output)
    .m00_axi_wlast                (gb_s_axi_wlast               ), // (output)
    .m00_axi_wuser                (                             ), // (output)
    .m00_axi_wvalid               (gb_s_axi_wvalid              ), // (output)
    .m00_axi_wready               (gb_s_axi_wready              ), // (input )
    .m00_axi_bid                  (gb_s_axi_bid                 ), // (input )
    .m00_axi_bresp                (gb_s_axi_bresp[1:0]          ), // (input )
    .m00_axi_buser                (                             ), // (input )
    .m00_axi_bvalid               (gb_s_axi_bvalid              ), // (input )
    .m00_axi_bready               (gb_s_axi_bready              ), // (output)
    .m00_axi_arid                 (gb_s_axi_arid                ), // (output)
    .m00_axi_araddr               (gb_s_axi_araddr              ), // (output)
    .m00_axi_arlen                (gb_s_axi_arlen[7:0]          ), // (output)
    .m00_axi_arsize               (gb_s_axi_arsize[2:0]         ), // (output)
    .m00_axi_arburst              (gb_s_axi_arburst[1:0]        ), // (output)
    .m00_axi_arlock               (gb_s_axi_arlock              ), // (output)
    .m00_axi_arcache              (gb_s_axi_arcache[3:0]        ), // (output)
    .m00_axi_arprot               (gb_s_axi_arprot[2:0]         ), // (output)
    .m00_axi_arqos                (                             ), // (output)
    .m00_axi_arregion             (                             ), // (output)
    .m00_axi_aruser               (                             ), // (output)
    .m00_axi_arvalid              (gb_s_axi_arvalid             ), // (output)
    .m00_axi_arready              (gb_s_axi_arready             ), // (input )
    .m00_axi_rid                  (gb_s_axi_rid                 ), // (input )
    .m00_axi_rdata                (gb_s_axi_rdata               ), // (input )
    .m00_axi_rresp                (gb_s_axi_rresp[1:0]          ), // (input )
    .m00_axi_rlast                (gb_s_axi_rlast               ), // (input )
    .m00_axi_ruser                (                             ), // (input )
    .m00_axi_rvalid               (gb_s_axi_rvalid              ), // (input )
    .m00_axi_rready               (gb_s_axi_rready              ), // (output)
    // -- M00

    // ++ M01
    .m01_axi_awid                 (data_m_axi_awid[2:0]         ), // (output)
    .m01_axi_awaddr               (data_m_axi_awaddr            ), // (output)
    .m01_axi_awlen                (data_m_axi_awlen             ), // (output)
    .m01_axi_awsize               (data_m_axi_awsize            ), // (output)
    .m01_axi_awburst              (data_m_axi_awburst           ), // (output)
    .m01_axi_awlock               (data_m_axi_awlock            ), // (output)
    .m01_axi_awcache              (data_m_axi_awcache           ), // (output)
    .m01_axi_awprot               (data_m_axi_awprot            ), // (output)
    .m01_axi_awqos                (                             ), // (output)
    .m01_axi_awregion             (                             ), // (output)
    .m01_axi_awuser               (                             ), // (output)
    .m01_axi_awvalid              (data_m_axi_awvalid           ), // (output)
    .m01_axi_awready              (data_m_axi_awready           ), // (input )
    .m01_axi_wdata                (data_m_axi_wdata             ), // (output)
    .m01_axi_wstrb                (data_m_axi_wstrb             ), // (output)
    .m01_axi_wlast                (data_m_axi_wlast             ), // (output)
    .m01_axi_wuser                (                             ), // (output)
    .m01_axi_wvalid               (data_m_axi_wvalid            ), // (output)
    .m01_axi_wready               (data_m_axi_wready            ), // (input )
    .m01_axi_bid                  (data_m_axi_bid[2:0]          ), // (input )
    .m01_axi_bresp                (data_m_axi_bresp             ), // (input )
    .m01_axi_buser                (                             ), // (input )
    .m01_axi_bvalid               (data_m_axi_bvalid            ), // (input )
    .m01_axi_bready               (data_m_axi_bready            ), // (output)
    .m01_axi_arid                 (data_m_axi_arid[2:0]         ), // (output)
    .m01_axi_araddr               (data_m_axi_araddr            ), // (output)
    .m01_axi_arlen                (data_m_axi_arlen             ), // (output)
    .m01_axi_arsize               (data_m_axi_arsize            ), // (output)
    .m01_axi_arburst              (data_m_axi_arburst           ), // (output)
    .m01_axi_arlock               (data_m_axi_arlock            ), // (output)
    .m01_axi_arcache              (data_m_axi_arcache           ), // (output)
    .m01_axi_arprot               (data_m_axi_arprot            ), // (output)
    .m01_axi_arqos                (                             ), // (output)
    .m01_axi_arregion             (                             ), // (output)
    .m01_axi_aruser               (                             ), // (output)
    .m01_axi_arvalid              (data_m_axi_arvalid           ), // (output)
    .m01_axi_arready              (data_m_axi_arready           ), // (input )
    .m01_axi_rid                  (data_m_axi_rid[2:0]          ), // (input )
    .m01_axi_rdata                (data_m_axi_rdata             ), // (input )
    .m01_axi_rresp                (data_m_axi_rresp             ), // (input )
    .m01_axi_rlast                (data_m_axi_rlast             ), // (input )
    .m01_axi_ruser                (                             ), // (input )
    .m01_axi_rvalid               (data_m_axi_rvalid            ), // (input )
    .m01_axi_rready               (data_m_axi_rready            )  // (output)
    // -- M01
);

endmodule

`default_nettype wire 
