/*-----------------------------------------
file name  : top_ppu.v
created    : 2026/02/06 21:54:15
modified   : 2026-02-08 00:01:07
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
module top_ppu # (
    parameter PSUM_WIDTH     = 32 ,
    parameter AXI_DATA_WIDTH = 64 ,
    parameter AXI_ADDR_WIDTH = 32 ,
    parameter PPU_CMD_LEN    = 124,
    parameter LEN_WIDTH      = 12 ,
    parameter TAG_WIDTH      = 8  , 
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8 
)(
    input  wire                     clk                  ,
    input  wire                     rst_n                ,

    input  wire                     ppu_cmd_vld          ,
    input  wire [PPU_CMD_LEN-1:0]   ppu_cmd              , 
    output wire                     ppu_cmd_rdy          ,

    output wire                     ppu_status_en        ,
    output wire [TAG_WIDTH-1:0]     ppu_status_tag       , 

    output wire [7:0]               ppu_data_rdy         ,
    input  wire [7:0]               ppu_data_vld         ,
    input  wire [8*PSUM_WIDTH-1:0]  ppu_data             ,

    // ppu master group0
    output wire [0:0]               ppu_gp0_m_axi_awid   ,
    output wire [AXI_ADDR_WIDTH-1:0]ppu_gp0_m_axi_awaddr ,
    output wire [7:0]               ppu_gp0_m_axi_awlen  ,
    output wire [2:0]               ppu_gp0_m_axi_awsize ,
    output wire [1:0]               ppu_gp0_m_axi_awburst,
    output wire                     ppu_gp0_m_axi_awvalid,
    input  wire                     ppu_gp0_m_axi_awready,
    output wire [AXI_DATA_WIDTH-1:0]ppu_gp0_m_axi_wdata  ,
    output wire [AXI_STRB_WIDTH-1:0]ppu_gp0_m_axi_wstrb  ,
    output wire                     ppu_gp0_m_axi_wlast  ,
    output wire                     ppu_gp0_m_axi_wvalid ,
    input  wire                     ppu_gp0_m_axi_wready ,
    input  wire [0:0]               ppu_gp0_m_axi_bid    ,
    input  wire [1:0]               ppu_gp0_m_axi_bresp  ,
    input  wire                     ppu_gp0_m_axi_bvalid ,
    output wire                     ppu_gp0_m_axi_bready ,

    // ppu master group1
    output wire [0:0]               ppu_gp1_m_axi_awid   ,
    output wire [AXI_ADDR_WIDTH-1:0]ppu_gp1_m_axi_awaddr ,
    output wire [7:0]               ppu_gp1_m_axi_awlen  ,
    output wire [2:0]               ppu_gp1_m_axi_awsize ,
    output wire [1:0]               ppu_gp1_m_axi_awburst,
    output wire                     ppu_gp1_m_axi_awvalid,
    input  wire                     ppu_gp1_m_axi_awready,
    output wire [AXI_DATA_WIDTH-1:0]ppu_gp1_m_axi_wdata  ,
    output wire [AXI_STRB_WIDTH-1:0]ppu_gp1_m_axi_wstrb  ,
    output wire                     ppu_gp1_m_axi_wlast  ,
    output wire                     ppu_gp1_m_axi_wvalid ,
    input  wire                     ppu_gp1_m_axi_wready ,
    input  wire [0:0]               ppu_gp1_m_axi_bid    ,
    input  wire [1:0]               ppu_gp1_m_axi_bresp  ,
    input  wire                     ppu_gp1_m_axi_bvalid ,
    output wire                     ppu_gp1_m_axi_bready   
);


localparam PPU_MOD_CMD_LEN = 18 + 32 + 12 + 32;
localparam DMA_CMD_LEN     = AXI_ADDR_WIDTH + LEN_WIDTH+1 + 2; 

wire gp0_write_desc_status_en;
wire gp1_write_desc_status_en;

wire [8:0]             cfg_out_zp        ;
wire [2:0]             cfg_actfunc_type  ;
wire                   cfg_actfunc_enable;
wire                   cfg_rescale_enable;
wire                   cfg_bias_enable   ;

wire [7:0]                   ppu_mod_cmd_rdy  ;
wire [7:0]                   ppu_mod_cmd_vld  ;
wire [8*PPU_MOD_CMD_LEN-1:0] ppu_mod_cmd      ; 

wire [7:0]             ppu_mod_cmd_en ;
wire [8*32-1:0]        ppu_mod_cmd_addr; 
wire [8*13-1:0]        ppu_mod_cmd_data_num ;  

wire [DMA_CMD_LEN-1:0] dma_cmd_gp0       ; 
wire                   dma_cmd_en_gp0    ; 

wire [DMA_CMD_LEN-1:0] dma_cmd_gp1       ; 
wire                   dma_cmd_en_gp1    ; 
wire [7:0]             ppu_status        ;
ppu_control # (
    .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH                ), // const
    .TAG_WIDTH       (TAG_WIDTH                     ), // const
    .LEN_WIDTH       (LEN_WIDTH                     ), // const
    .AXIS_USER_WIDTH (2                             ), 
    .INSTR_WIDTH     (PPU_CMD_LEN                   ),
    .OCMD_LEN        (DMA_CMD_LEN                   )
) u_ppu_control (
    .clk        (clk                               ), // (input )
    .rst_n      (rst_n                             ), // (input )

    .inst_vld   (ppu_cmd_vld                       ), // (input )
    .inst       (ppu_cmd                           ), // (input )
    .inst_rdy   (ppu_cmd_rdy                       ), // (output)

    .cmd_en_gp0      (ppu_mod_cmd_en[3:0]                 ) ,
    .cmd_addr_gp0    (ppu_mod_cmd_addr[4*32-1:0]          ) ,
    .cmd_data_num_gp0(ppu_mod_cmd_data_num[4*13-1:0]      ) , 

    .cmd_en_gp1      (ppu_mod_cmd_en[7:4]                 ) ,
    .cmd_addr_gp1    (ppu_mod_cmd_addr[8*32-1 : 4*32]     ) ,
    .cmd_data_num_gp1(ppu_mod_cmd_data_num[8*13-1 : 4*13] ) ,

    .o_cmd_gp0       (dma_cmd_gp0       ), // (output)
    .o_cmd_en_gp0    (dma_cmd_en_gp0    ), // (output)
    .gp0_status_en   (gp0_write_desc_status_en), // (input )

    .o_cmd_gp1       (dma_cmd_gp1       ), // (output)
    .o_cmd_en_gp1    (dma_cmd_en_gp1    ), // (output)
    .gp1_status_en   (gp1_write_desc_status_en), // (input )

    .cfg_out_zp        (cfg_out_zp            ), // (output)
    .cfg_actfunc_type  (cfg_actfunc_type      ), // (output)
    .cfg_actfunc_enable(cfg_actfunc_enable    ), // (output)
    .cfg_rescale_enable(cfg_rescale_enable    ), // (output)
    .cfg_bias_enable   (cfg_bias_enable       ), // (output)

    .ppu_inst_rdy      (ppu_mod_cmd_rdy       ), // (input )
    .ppu_status        (ppu_status            ),
    .ppu_inst_vld      (ppu_mod_cmd_vld       ), // (output)
    .ppu_inst          (ppu_mod_cmd           ), // (output)

    .ppu_status_en     (ppu_status_en         ), // (output)
    .ppu_status_tag    (ppu_status_tag        )  // (output)
);

wire [7:0]                  bus_fifo_empty; 
wire [7:0]                  bus_fifo_rd_en; 
wire [8*AXI_DATA_WIDTH-1:0] bus_fifo_dout ;

genvar i;
generate 
    for( i = 0; i < 8; i = i + 1 ) begin : ppu_item
        wire [PSUM_WIDTH-1:0] fifo_data_in;
        wire                  fifo_wr_en;
        wire                  fifo_full;
        
        wire [PSUM_WIDTH-1:0] fifo_data_out;
        wire                  fifo_rd_en;
        wire                  fifo_empty;
        
        wire data_rdy_from_ppu;

        syncfifo # (
            .DATA_WIDTH   (PSUM_WIDTH        ), 
            .ADDR_WIDTH   (5                 ), 
            .RAM_STYLE    ("distributed"     ), 
            .FWFT_EN      (1                 ) 
        ) u_syncfifo_raw (
            .din    (fifo_data_in        ), // (input )
            .wr_en  (fifo_wr_en          ), // (input )
            .full   (fifo_full           ), // (output)
                    
            .dout   (fifo_data_out       ), // (output)
            .rd_en  (fifo_rd_en          ), // (input )
            .empty  (fifo_empty          ), // (output)
                    
            .clk    (clk                 ), // (input )
            .rst_n  (rst_n               )  // (input )
        );

        assign fifo_wr_en = ppu_data_vld[i];
        assign fifo_data_in = ppu_data[i*PSUM_WIDTH +: PSUM_WIDTH];
        assign ppu_data_rdy[i] = ~fifo_full;
        assign fifo_rd_en = data_rdy_from_ppu;

        wire                      bus_data_vld ; 
        wire [AXI_DATA_WIDTH-1:0] bus_data     ;  

        ppu # (
            .DWIDTH         (PSUM_WIDTH     ) ,
            .AXI_DATA_WIDTH (AXI_DATA_WIDTH ) , 
            .BUS_FIFO_DEPTH (512            ) 
        ) u_ppu (
            .clk              (clk                     ), // (input )
            .rst_n            (rst_n                   ), // (input )
        
            .bias_enable      (cfg_bias_enable         ), // (input )
            .rescale_enable   (cfg_rescale_enable      ), // (input )
            .actfunc_enable   (cfg_actfunc_enable      ), // (input )
            .actfunc_type     (cfg_actfunc_type        ), // (input ) 0: relu
            .out_zp           (cfg_out_zp              ), // (input )
        
            .data_rdy         (data_rdy_from_ppu       ), // (output)
            .data_vld         ( ~fifo_empty            ) ,
            .data             ( fifo_data_out          ) ,
        
            .cmd_vld          (ppu_mod_cmd_vld[i]                               ), 
            .cmd              (ppu_mod_cmd[i*PPU_MOD_CMD_LEN +: PPU_MOD_CMD_LEN]), 
            .cmd_rdy          (ppu_mod_cmd_rdy[i]                               ), 
        
            .bus_data_vld     (bus_data_vld            ), // (output)
            .bus_data         (bus_data                ), // (output)
        
            .cmd_en           (ppu_mod_cmd_en[i]                 ), 
            .cmd_addr         (ppu_mod_cmd_addr[i*32 +: 32]      ), 
            .cmd_data_num     (ppu_mod_cmd_data_num[i*13 +: 13]  ),

            .status           (ppu_status[i]                     )
        );

        syncfifo # (
            .DATA_WIDTH   (AXI_DATA_WIDTH        ), 
            .ADDR_WIDTH   (9                     ), 
            .RAM_STYLE    ("block"               ), 
            .FWFT_EN      (1                     ) 
        ) u_syncfifo_bus (
            .din    (bus_data            ), // (input ) Local signal
            .wr_en  (bus_data_vld        ), // (input ) Local signal
            .full   (                    ), // (output)
                    
            .dout   (bus_fifo_dout [i*AXI_DATA_WIDTH +: AXI_DATA_WIDTH]), 
            .rd_en  (bus_fifo_rd_en[i]   ), 
            .empty  (bus_fifo_empty[i]   ), 
                    
            .clk    (clk                 ), // (input )
            .rst_n  (rst_n               )  // (input )
        );
    end
endgenerate

// AXI_ADDR_WIDTH + LEN_WIDTH+1 + 2
wire [DMA_CMD_LEN-1:0] dma_cmd_gp0_out;
wire                   dma_cmd_gp0_rd_en;
wire                   dma_cmd_gp0_empty; 

wire [DMA_CMD_LEN-1:0] dma_cmd_gp1_out;
wire                   dma_cmd_gp1_rd_en;
wire                   dma_cmd_gp1_empty; 
syncfifo # (
    .DATA_WIDTH   (DMA_CMD_LEN     ), 
    .ADDR_WIDTH   (8               ), 
    .RAM_STYLE    ("block"   ), 
    .FWFT_EN      (1               ) 
) u_dma_gp0_cmd (
    .din    (dma_cmd_gp0        ), // (input )
    .wr_en  (dma_cmd_en_gp0     ), // (input )
    .full   (                   ), // (output)
            
    .dout   (dma_cmd_gp0_out    ), // (output)
    .rd_en  (dma_cmd_gp0_rd_en  ), // (input )
    .empty  (dma_cmd_gp0_empty  ), // (output)
            
    .clk    (clk                ), // (input )
    .rst_n  (rst_n              )  // (input )
);

syncfifo # (
    .DATA_WIDTH   (DMA_CMD_LEN     ), 
    .ADDR_WIDTH   (8               ), 
    .RAM_STYLE    ("block"   ), 
    .FWFT_EN      (1               ) 
) u_dma_gp1_cmd (
    .din    (dma_cmd_gp1        ), // (input )
    .wr_en  (dma_cmd_en_gp1     ), // (input )
    .full   (                   ), // (output)
            
    .dout   (dma_cmd_gp1_out    ), // (output)
    .rd_en  (dma_cmd_gp1_rd_en  ), // (input )
    .empty  (dma_cmd_gp1_empty  ), // (output)
            
    .clk    (clk                ), // (input )
    .rst_n  (rst_n              )  // (input )
);

wire [AXI_ADDR_WIDTH-1:0]  gp0_axis_write_desc_addr ;
wire [LEN_WIDTH+1-1:0]     gp0_axis_write_desc_len  ;
wire                       gp0_axis_write_desc_valid;
wire                       gp0_axis_write_desc_ready;
wire [1:0]                 gp0_axis_write_desc_user ; 

wire [AXI_ADDR_WIDTH-1:0]  gp1_axis_write_desc_addr ;
wire [LEN_WIDTH+1-1:0]     gp1_axis_write_desc_len  ;
wire                       gp1_axis_write_desc_valid;
wire                       gp1_axis_write_desc_ready;
wire [1:0]                 gp1_axis_write_desc_user ; 

assign {gp0_axis_write_desc_addr,gp0_axis_write_desc_len,gp0_axis_write_desc_user} 
        = dma_cmd_gp0_out;
assign gp0_axis_write_desc_valid  = ~dma_cmd_gp0_empty;
assign dma_cmd_gp0_rd_en = gp0_axis_write_desc_ready & ~dma_cmd_gp0_empty; 

assign {gp1_axis_write_desc_addr,gp1_axis_write_desc_len,gp1_axis_write_desc_user} 
        = dma_cmd_gp1_out;
assign gp1_axis_write_desc_valid  = ~dma_cmd_gp1_empty;
assign dma_cmd_gp1_rd_en = gp1_axis_write_desc_ready & ~dma_cmd_gp1_empty; 

wire [AXI_DATA_WIDTH-1:0] gp0_write_data_tdata;
wire                      gp0_write_data_tvalid;
wire                      gp0_write_data_tready;
wire [1:0]                gp0_write_data_tsel;

wire [AXI_DATA_WIDTH-1:0] gp1_write_data_tdata;
wire                      gp1_write_data_tvalid;
wire                      gp1_write_data_tready;
wire [1:0]                gp1_write_data_tsel;

axi_dma_wr # (
    // Width of AXI data bus in bits
    .AXI_DATA_WIDTH               (AXI_DATA_WIDTH               ), 
    // Width of AXI address bus in bits
    .AXI_ADDR_WIDTH               (AXI_ADDR_WIDTH               ), 
    // Width of AXI ID signal
    .AXI_ID_WIDTH                 (1                            ), 
    // Maximum AXI burst length to generate
    .AXI_MAX_BURST_LEN            (64                           ), 
    // Use AXI stream tlast signal
    .AXIS_LAST_ENABLE             (0                            ), 
    // Propagate AXI stream tid signal
    .AXIS_ID_ENABLE               (0), 
    // AXI stream tid signal width
    .AXIS_ID_WIDTH                (1),
    // Propagate AXI stream tdest signal
    .AXIS_DEST_ENABLE             (0), 
    // AXI stream tdest signal width
    .AXIS_DEST_WIDTH              (1), 
    // Propagate AXI stream tuser signal
    .AXIS_USER_ENABLE             (0), 
    // AXI stream tuser signal width
    .AXIS_USER_WIDTH              (2), 
    // Width of length field
    .LEN_WIDTH                    (LEN_WIDTH + 1                ), 
    // Width of tag field
    .TAG_WIDTH                    (1), 
    // Enable support for scatter/gather DMA
    // (multiple descriptors per AXI stream frame)
    .ENABLE_SG                    (0), 
    // Enable support for unaligned transfers
    .ENABLE_UNALIGNED             (1) 
)u_axi_dma_wr_gp0(
    .clk                          (clk          ), // (input )
    .rst                          (~rst_n       ), // (input )

    // AXI write descriptor input
    .s_axis_write_desc_addr       (gp0_axis_write_desc_addr ), // (input )
    .s_axis_write_desc_len        (gp0_axis_write_desc_len  ), // (input )
    .s_axis_write_desc_tag        (1'b0),
    .s_axis_write_desc_valid      (gp0_axis_write_desc_valid), // (input )
    .s_axis_write_desc_ready      (gp0_axis_write_desc_ready), // (output)
    .s_axis_write_desc_user       (gp0_axis_write_desc_user ), // (input ) custom signal

    // AXI write descriptor status output
    .m_axis_write_desc_status_len  (), // (output) nc
    .m_axis_write_desc_status_tag  (), // (output) nc
    .m_axis_write_desc_status_id   (), // (output) nc
    .m_axis_write_desc_status_dest (), // (output) nc
    .m_axis_write_desc_status_user (), // (output) nc
    .m_axis_write_desc_status_error(), // (output) nc
    .m_axis_write_desc_status_valid(gp0_write_desc_status_en), // (output)

    // AXI stream write data input
    .s_axis_write_data_tdata      (gp0_write_data_tdata), // (input )
    .s_axis_write_data_tkeep      ({AXI_STRB_WIDTH{1'b1}}),
    .s_axis_write_data_tvalid     (gp0_write_data_tvalid), // (input )
    .s_axis_write_data_tready     (gp0_write_data_tready), // (output)
    .s_axis_write_data_tlast      (1'b0),
    .s_axis_write_data_tid        (1'b0),
    .s_axis_write_data_tdest      (1'b0),
    .s_axis_write_data_tuser      (2'b0),
    .s_axis_write_data_tsel       (gp0_write_data_tsel), // (output) cusntom signal 

    // AXI master interface
    .m_axi_awid                   (ppu_gp0_m_axi_awid      ), // (output)
    .m_axi_awaddr                 (ppu_gp0_m_axi_awaddr    ), // (output)
    .m_axi_awlen                  (ppu_gp0_m_axi_awlen     ), // (output)
    .m_axi_awsize                 (ppu_gp0_m_axi_awsize    ), // (output)
    .m_axi_awburst                (ppu_gp0_m_axi_awburst   ), // (output)
    .m_axi_awlock                 (), // (output)
    .m_axi_awcache                (), // (output)
    .m_axi_awprot                 (), // (output)
    .m_axi_awvalid                (ppu_gp0_m_axi_awvalid   ), // (output)
    .m_axi_awready                (ppu_gp0_m_axi_awready   ), // (input )
    .m_axi_wdata                  (ppu_gp0_m_axi_wdata     ), // (output)
    .m_axi_wstrb                  (ppu_gp0_m_axi_wstrb     ), // (output)
    .m_axi_wlast                  (ppu_gp0_m_axi_wlast     ), // (output)
    .m_axi_wvalid                 (ppu_gp0_m_axi_wvalid    ), // (output)
    .m_axi_wready                 (ppu_gp0_m_axi_wready    ), // (input )
    .m_axi_bid                    (ppu_gp0_m_axi_bid       ), // (input )
    .m_axi_bresp                  (ppu_gp0_m_axi_bresp     ), // (input )
    .m_axi_bvalid                 (ppu_gp0_m_axi_bvalid    ), // (input )
    .m_axi_bready                 (ppu_gp0_m_axi_bready    ), // (output)

    // Configuration
    .enable                       (1'b1) // (input )
);

axi_dma_wr # (
   // Width of AXI data bus in bits
    .AXI_DATA_WIDTH               (AXI_DATA_WIDTH               ), 
    // Width of AXI address bus in bits
    .AXI_ADDR_WIDTH               (AXI_ADDR_WIDTH               ), 
    // Width of AXI ID signal
    .AXI_ID_WIDTH                 (1                            ), 
    // Maximum AXI burst length to generate
    .AXI_MAX_BURST_LEN            (64                           ), 
    // Use AXI stream tlast signal
    .AXIS_LAST_ENABLE             (0                            ), 
    // Propagate AXI stream tid signal
    .AXIS_ID_ENABLE               (0), 
    // AXI stream tid signal width
    .AXIS_ID_WIDTH                (1),
    // Propagate AXI stream tdest signal
    .AXIS_DEST_ENABLE             (0), 
    // AXI stream tdest signal width
    .AXIS_DEST_WIDTH              (1), 
    // Propagate AXI stream tuser signal
    .AXIS_USER_ENABLE             (0), 
    // AXI stream tuser signal width
    .AXIS_USER_WIDTH              (2), 
    // Width of length field
    .LEN_WIDTH                    (LEN_WIDTH + 1                ), 
    // Width of tag field
    .TAG_WIDTH                    (1), 
    // Enable support for scatter/gather DMA
    // (multiple descriptors per AXI stream frame)
    .ENABLE_SG                    (0), 
    // Enable support for unaligned transfers
    .ENABLE_UNALIGNED             (1) 
) u_axi_dma_wr_gp1 (
    .clk                          (clk                      ), // (input )
    .rst                          (~rst_n                   ), // (input )

    // AXI write descriptor input
    .s_axis_write_desc_addr       (gp1_axis_write_desc_addr ), // (input )
    .s_axis_write_desc_len        (gp1_axis_write_desc_len  ), // (input )
    .s_axis_write_desc_tag        (1'b0),
    .s_axis_write_desc_valid      (gp1_axis_write_desc_valid), // (input )
    .s_axis_write_desc_ready      (gp1_axis_write_desc_ready), // (output)
    .s_axis_write_desc_user       (gp1_axis_write_desc_user ), // (input ) custom signal

    // AXI write descriptor status output
    .m_axis_write_desc_status_len  (), // (output) nc
    .m_axis_write_desc_status_tag  (), // (output) nc
    .m_axis_write_desc_status_id   (), // (output) nc
    .m_axis_write_desc_status_dest (), // (output) nc
    .m_axis_write_desc_status_user (), // (output) nc
    .m_axis_write_desc_status_error(), // (output) nc
    .m_axis_write_desc_status_valid(gp1_write_desc_status_en), // (output)

    // AXI stream write data input
    .s_axis_write_data_tdata      (gp1_write_data_tdata ), // (input )
    .s_axis_write_data_tkeep      ({AXI_STRB_WIDTH{1'b1}}),
    .s_axis_write_data_tvalid     (gp1_write_data_tvalid), // (input )
    .s_axis_write_data_tready     (gp1_write_data_tready), // (output)
    .s_axis_write_data_tlast      (1'b0),
    .s_axis_write_data_tid        (1'b0),
    .s_axis_write_data_tdest      (1'b0),
    .s_axis_write_data_tuser      (2'b0),
    .s_axis_write_data_tsel       (gp1_write_data_tsel ), // (output) cusntom signal 

    // AXI master interface
    .m_axi_awid                   (ppu_gp1_m_axi_awid    ), // (output)
    .m_axi_awaddr                 (ppu_gp1_m_axi_awaddr  ), // (output)
    .m_axi_awlen                  (ppu_gp1_m_axi_awlen   ), // (output)
    .m_axi_awsize                 (ppu_gp1_m_axi_awsize  ), // (output)
    .m_axi_awburst                (ppu_gp1_m_axi_awburst ), // (output)
    .m_axi_awlock                 (), // (output)
    .m_axi_awcache                (), // (output)
    .m_axi_awprot                 (), // (output)
    .m_axi_awvalid                (ppu_gp1_m_axi_awvalid ), // (output)
    .m_axi_awready                (ppu_gp1_m_axi_awready ), // (input )
    .m_axi_wdata                  (ppu_gp1_m_axi_wdata   ), // (output)
    .m_axi_wstrb                  (ppu_gp1_m_axi_wstrb   ), // (output)
    .m_axi_wlast                  (ppu_gp1_m_axi_wlast   ), // (output)
    .m_axi_wvalid                 (ppu_gp1_m_axi_wvalid  ), // (output)
    .m_axi_wready                 (ppu_gp1_m_axi_wready  ), // (input )
    .m_axi_bid                    (ppu_gp1_m_axi_bid     ), // (input )
    .m_axi_bresp                  (ppu_gp1_m_axi_bresp   ), // (input )
    .m_axi_bvalid                 (ppu_gp1_m_axi_bvalid  ), // (input )
    .m_axi_bready                 (ppu_gp1_m_axi_bready  ), // (output)

    // Configuration
    .enable                       (1'b1) // (input )
);

wire [7:0] axis_4to1_rdy;
axis_4to1 # (
    .DWIDTH (AXI_DATA_WIDTH ) 
)u_axis_4to1_gp0(
    .axis_valid_i ( ~bus_fifo_empty[3:0]               ),
    .axis_data_i  ( bus_fifo_dout[4*AXI_DATA_WIDTH-1:0]),
    .axis_ready_i ( axis_4to1_rdy[3:0]                 ),

    .axis_user    ( gp0_write_data_tsel                ),
    .axis_valid_o ( gp0_write_data_tvalid              ), // (output)
    .axis_data_o  ( gp0_write_data_tdata               ), // (output)
    .axis_ready_o ( gp0_write_data_tready              )  // (input )
);

axis_4to1 # (
    .DWIDTH (AXI_DATA_WIDTH ) 
)u_axis_4to1_gp1(
    .axis_valid_i ( ~bus_fifo_empty[7:4]                               ),
    .axis_data_i  ( bus_fifo_dout[8*AXI_DATA_WIDTH-1: 4*AXI_DATA_WIDTH]),
    .axis_ready_i ( axis_4to1_rdy[7:4]                                 ),

    .axis_user    ( gp1_write_data_tsel   ),
    .axis_valid_o ( gp1_write_data_tvalid ), // (output)
    .axis_data_o  ( gp1_write_data_tdata  ), // (output)
    .axis_ready_o ( gp1_write_data_tready )  // (input )
);

assign bus_fifo_rd_en = axis_4to1_rdy & ~bus_fifo_empty; 

endmodule

`default_nettype wire
