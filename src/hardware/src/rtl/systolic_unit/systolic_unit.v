/*-----------------------------------------
file name  : systolic_unit.v
created    : 2025/12/08 19:47:02
modified   : 2026-03-18 02:06:44
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module systolic_unit # (
    parameter PE_NROW        =  8  ,
    parameter PE_NCOL        =  8  ,  
    parameter CHANNEL        =  2  ,
    parameter DWIDTH         =  8  ,
    parameter AXI_DATA_WIDTH = 64  ,
    parameter AXI_ADDR_WIDTH = 32  ,
    parameter TAG_WIDTH      = 1   ,
    parameter LEN_WIDTH      = 12  ,
    parameter AXIS_USER_WIDTH= 3   ,
    parameter PSUM_WIDTH     = 32  , // TODO
    parameter CMD_LEN        = AXI_ADDR_WIDTH + LEN_WIDTH+1 + AXIS_USER_WIDTH 

)(
    input  wire                        clk                                     ,
    input  wire                        rst_n                                   ,

    // +++++++++++++++++++++++++++ pe_array controll 
    input  wire [PE_NCOL-1:0]          col_en                                  ,  
    input  wire [PE_NROW-1:0]          row_en                                  , 

    input  wire [PE_NCOL*$clog2(PE_NROW-1)-1:0]raw_row_en                      ,
    input  wire                        rd_buf_id                               ,

    input  wire [11:0]                 calc_len                                ,
    input  wire                        last_en                                 ,

    input  wire [PE_NCOL-1:0]          weight_start_en                         ,
    input  wire [PE_NROW-1:0]          activation_start_en                     ,
    output wire                        wr_buf_id                               ,
    // --------------------------- pe_array controll 
    // output channel
    output wire [PE_NCOL-1:0]           vld_out                                , 
    output wire [PE_NCOL*PSUM_WIDTH-1:0]res_out                                ,  
    // +++++++++++++++++++++++++++ axi dma 
    input  wire [CMD_LEN-1:0]          axi_dma_cmd                             ,
    // ++  weight axi dma cmd 
    input  wire                        weight_cmd_wr_en                        ,
    // ++  activation axi dma cmd 
    input  wire                        activation_cmd_wr_en                    ,

    // ++ weight axi dma status channel
    output wire  [TAG_WIDTH-1:0]       weight_m_axis_read_desc_status_tag      ,
    output wire  [3:0]                 weight_m_axis_read_desc_status_error    ,
    output wire                        weight_m_axis_read_desc_status_valid    ,

    // ++ activation axi dma status channel
    output wire  [TAG_WIDTH-1:0]       activation_m_axis_read_desc_status_tag  ,
    output wire  [3:0]                 activation_m_axis_read_desc_status_error,
    output wire                        activation_m_axis_read_desc_status_valid,

    // ++ calc status channel
    output wire                        calc_status_valid                       ,

    // ++ weight axi dma channel 
    output wire  [0:0]                 weight_m_axi_arid                       ,
    output wire  [AXI_ADDR_WIDTH-1:0]  weight_m_axi_araddr                     ,
    output wire  [7:0]                 weight_m_axi_arlen                      ,
    output wire  [2:0]                 weight_m_axi_arsize                     ,
    output wire  [1:0]                 weight_m_axi_arburst                    ,
    output wire                        weight_m_axi_arlock                     ,
    output wire  [3:0]                 weight_m_axi_arcache                    ,
    output wire  [2:0]                 weight_m_axi_arprot                     ,
    output wire                        weight_m_axi_arvalid                    ,
    input  wire                        weight_m_axi_arready                    ,

    input  wire [0:0]                  weight_m_axi_rid                        ,
    input  wire [AXI_DATA_WIDTH-1:0]   weight_m_axi_rdata                      ,
    input  wire [1:0]                  weight_m_axi_rresp                      ,
    input  wire                        weight_m_axi_rlast                      ,
    input  wire                        weight_m_axi_rvalid                     ,
    output wire                        weight_m_axi_rready                     ,

    // ++ activation axi dam channel 
    output wire  [0:0]                 activation_m_axi_arid                   ,
    output wire  [AXI_ADDR_WIDTH-1:0]  activation_m_axi_araddr                 ,
    output wire  [7:0]                 activation_m_axi_arlen                  ,
    output wire  [2:0]                 activation_m_axi_arsize                 ,
    output wire  [1:0]                 activation_m_axi_arburst                ,
    output wire                        activation_m_axi_arlock                 ,
    output wire  [3:0]                 activation_m_axi_arcache                ,
    output wire  [2:0]                 activation_m_axi_arprot                 ,
    output wire                        activation_m_axi_arvalid                ,
    input  wire                        activation_m_axi_arready                ,

    input  wire [0:0]                  activation_m_axi_rid                    ,
    input  wire [AXI_DATA_WIDTH-1:0]   activation_m_axi_rdata                  ,
    input  wire [1:0]                  activation_m_axi_rresp                  ,
    input  wire                        activation_m_axi_rlast                  ,
    input  wire                        activation_m_axi_rvalid                 ,
    output wire                        activation_m_axi_rready                 ,

    input  wire                        update_pingpong 

    // --------------------------- axi dma 
);

// ++ weight axis channel 
wire [PE_NCOL-1:0          ]        w_axis_vld    ;
wire [PE_NCOL-1:0          ]        w_axis_last   ;
wire [PE_NCOL*AXI_DATA_WIDTH-1:0  ] w_axis_data   ;
wire [PE_NCOL-1:0          ]        w_axis_rdy    ;

// ++ activation axis channel 
wire [PE_NROW-1:0          ]        a_axis_vld    ;
wire [PE_NROW-1:0          ]        a_axis_last   ;
wire [PE_NROW*AXI_DATA_WIDTH-1:0  ] a_axis_data   ;
wire [PE_NROW-1:0          ]        a_axis_rdy    ;

wire [PE_NROW-1:0          ]        vld_a_in      ;
wire [PE_NCOL-1:0          ]        last_in       ; 
wire [PE_NROW*DWIDTH*CHANNEL-1:0]  activation_in ;

wire [PE_NCOL-1:0          ]        vld_w_in      ; 
wire [PE_NCOL*DWIDTH*CHANNEL-1:0]  weight_in     ; 
wire [PE_NCOL-1:0          ]        pe_start      ;

// +++++++++++++++++++++++++
wire [PE_NCOL-1:0]                 axis_tready;
wire [PE_NCOL-1:0]                 axis_tvalid;
wire [PE_NCOL*AXI_DATA_WIDTH-1:0]  axis_tdata ;
// -------------------------
// Command retirement is per chunk; last_in remains final-output-only.
wire [PE_NCOL-1:0] chunk_done;
assign calc_status_valid = chunk_done[0];
genvar col, row;
generate 
    for( row = 0; row < PE_NROW ; row = row + 1 ) begin : row_fifo 
        systolic_fifo # ( 
            .DIWIDTH      ( AXI_DATA_WIDTH )  ,
            .DOWIDTH      ( DWIDTH        )  ,
            .CHANNEL      ( CHANNEL        )  ,
            // 128 x 64-bit beats = 1024 bytes per activation channel.
            // This board profile requires every encoded K chunk <= 1024.
            .AWIDTH       ( 7              ) 
        ) u_systolic_fifo (
            .clk        (clk                                  ),
            .rst_n      (rst_n                                ),
            
            .axis_vld   (a_axis_vld [row]                     ),
            .axis_last  (a_axis_last[row]                     ),
            .axis_data  (a_axis_data[row * AXI_DATA_WIDTH +: AXI_DATA_WIDTH]),
            .axis_rdy   (a_axis_rdy [row]                     ),
        
            .calc_len   (calc_len                             ),         
            .start_en   (activation_start_en[row]             ),

            .last_en    (last_en                              ),
        
            .out_vld    (vld_a_in     [row]                   ),
            .out_start  (                                     ),
            .out_data   (activation_in[row*CHANNEL*DWIDTH +: CHANNEL*DWIDTH]),
            .out_last   (                                     ) 
        ); 
    end
endgenerate 

generate 
    for( col = 0; col < PE_NCOL ; col = col + 1 ) begin : col_buffer
        wire local_wr_buf_id;
        systolic_buffer # ( 
            .DIWIDTH        ( AXI_DATA_WIDTH )  ,
            .DOWIDTH        ( DWIDTH        )  ,
            .CHANNEL        ( CHANNEL        )  ,
            // Each ping-pong bank holds one <=1024-byte weight packet.
            // Array dimensions and INT8/INT32 arithmetic are unchanged.
            .AWIDTH         ( 7              ) 
        ) u_systolic_buffer (
            .clk            (clk                              ),
            .rst_n          (rst_n                            ),
            
            .axis_vld       (w_axis_vld [col]                 ),
            .axis_last      (w_axis_last[col]                 ),
            .axis_data      (w_axis_data[col*AXI_DATA_WIDTH +: AXI_DATA_WIDTH]),
            .axis_rdy       (w_axis_rdy [col]                 ),

            .rd_buf_id      (rd_buf_id                        ), 
            .calc_len       (calc_len                         ),         
            .start_en       (weight_start_en[col]             ),
            .last_en        (last_en                          ),

            .wr_buf_id      (local_wr_buf_id                  ),
        
            .out_vld        (vld_w_in            [col]        ),
            .out_data       (weight_in[col*DWIDTH*CHANNEL +: DWIDTH*CHANNEL]),
            .out_start      (pe_start [col]                   ),
            .out_last       (last_in  [col]               ) ,
            .chunk_done     (chunk_done[col]                  ),

            .update_pingpong (update_pingpong  )
        ); 
            
        if( col == 0 ) assign wr_buf_id = local_wr_buf_id;
    end
endgenerate 

systolic_array # (
    .DIWIDTH   ( DWIDTH    ),
    .CHANNEL   ( CHANNEL    ),
    .NROW      ( PE_NROW    ),
    .NCOL      ( PE_NCOL    ),
    .PSUM_WIDTH( PSUM_WIDTH )
) u_systolic_array (
    .clk           (clk          ),
    .rst_n         (rst_n        ),
                                 
    .vld_a_in      (vld_a_in     ),
    .last_in       (last_in      ),
    .activation_in (activation_in),

    .col_start     (weight_start_en),
    .raw_row_en    (raw_row_en     ),

    .pe_rowen      (row_en       ), 
                                
    .vld_w_in      (vld_w_in     ),
    .weight_in     (weight_in    ), 
    .pe_start      (pe_start     ),

    .vld_out       (vld_out      ),
    .res_out       (res_out      ) 
);

// ++++++++++++++++++++++++++++++ weight axi_dma
wire                       weight_axi_dma_enable         ;
// ===== axis data
wire [AXI_DATA_WIDTH-1:0]  weight_m_axis_read_data_tdata ;
// wire [AXI_KEEP_WIDTH-1:0] m_axis_read_data_tkeep;
wire                       weight_m_axis_read_data_tvalid;
wire                       weight_m_axis_read_data_tready;
wire                       weight_m_axis_read_data_tlast ;
// wire [AXIS_ID_WIDTH-1:0]   m_axis_read_data_tid;
// wire [AXIS_DEST_WIDTH-1:0] m_axis_read_data_tdest;
wire [AXIS_USER_WIDTH-1:0] weight_m_axis_read_data_tuser ;

wire [AXI_ADDR_WIDTH-1:0]  weight_s_axis_read_desc_addr  ;
wire [LEN_WIDTH+1-1:0   ]  weight_s_axis_read_desc_len   ;
wire [TAG_WIDTH-1:0]       weight_s_axis_read_desc_tag   ;
wire [AXIS_USER_WIDTH-1:0] weight_s_axis_read_desc_user  ;
wire                       weight_s_axis_read_desc_valid ;
wire                       weight_s_axis_read_desc_ready ;

axi_dma_rd # (
    // Width of AXI data bus in bits
    .AXI_DATA_WIDTH    ( AXI_DATA_WIDTH ) ,
    // Width of AXI address bus in bits
    .AXI_ADDR_WIDTH    ( AXI_ADDR_WIDTH ) ,
    // Width of AXI ID signal
    .AXI_ID_WIDTH      ( 1  ) ,
    // Maximum AXI burst length to generate
    .AXI_MAX_BURST_LEN ( 64 ) ,
    // Use AXI stream tkeep signal
    //.AXIS_KEEP_ENABLE  ( 0  ) ,
    // Use AXI stream tlast signal
    .AXIS_LAST_ENABLE  ( 1  ) ,
    // Propagate AXI stream tid signal
    .AXIS_ID_ENABLE    ( 0  ) ,
    // Propagate AXI stream tdest signal
    .AXIS_DEST_ENABLE  ( 0  ) ,
    // Propagate AXI stream tuser signal
    .AXIS_USER_ENABLE  ( 1  ) ,
    // AXI stream tuser signal width
    .AXIS_USER_WIDTH   ( AXIS_USER_WIDTH  ) ,
    // Width of length field
    .LEN_WIDTH         ( LEN_WIDTH+1 ) ,
    // Width of tag field
    .TAG_WIDTH         ( 1  ) ,
    // Enable support for scatter/gather DMA
    // (multiple descriptors per AXI stream frame)
    .ENABLE_SG         ( 0  ) ,
    // Enable support for unaligned transfers
    .ENABLE_UNALIGNED  ( 1  ) 
)u_axi_dma_weight(
    .clk               ( clk    ),
    .rst               ( ~rst_n ),

    // AXI read descriptor input
    .s_axis_read_desc_addr (weight_s_axis_read_desc_addr ),
    .s_axis_read_desc_len  (weight_s_axis_read_desc_len  ),
    .s_axis_read_desc_tag  (weight_s_axis_read_desc_tag  ),
    // .s_axis_read_desc_id   (s_axis_read_desc_id   ),
    // .s_axis_read_desc_dest (s_axis_read_desc_dest ),
    .s_axis_read_desc_user (weight_s_axis_read_desc_user ),
    .s_axis_read_desc_valid(weight_s_axis_read_desc_valid),
    .s_axis_read_desc_ready(weight_s_axis_read_desc_ready),

    // AXI read descriptor status output
    .m_axis_read_desc_status_tag  (weight_m_axis_read_desc_status_tag  ),
    .m_axis_read_desc_status_error(weight_m_axis_read_desc_status_error),
    .m_axis_read_desc_status_valid(weight_m_axis_read_desc_status_valid),

    // AXI stream read data output
    .m_axis_read_data_tdata  (weight_m_axis_read_data_tdata ),
    // .m_axis_read_data_tkeep  (m_axis_read_data_tkeep ),
    .m_axis_read_data_tvalid (weight_m_axis_read_data_tvalid),
    .m_axis_read_data_tready (weight_m_axis_read_data_tready),
    .m_axis_read_data_tlast  (weight_m_axis_read_data_tlast ),
    // .m_axis_read_data_tid    (m_axis_read_data_tid   ),
    // .m_axis_read_data_tdest  (m_axis_read_data_tdest ),
    .m_axis_read_data_tuser  (weight_m_axis_read_data_tuser ),

    //  AXI master interface
    .m_axi_arid    (weight_m_axi_arid    ),
    .m_axi_araddr  (weight_m_axi_araddr  ),
    .m_axi_arlen   (weight_m_axi_arlen   ),
    .m_axi_arsize  (weight_m_axi_arsize  ),
    .m_axi_arburst (weight_m_axi_arburst ),
    .m_axi_arlock  (weight_m_axi_arlock  ),
    .m_axi_arcache (weight_m_axi_arcache ),
    .m_axi_arprot  (weight_m_axi_arprot  ),
    .m_axi_arvalid (weight_m_axi_arvalid ),
    .m_axi_arready (weight_m_axi_arready ),
    .m_axi_rid     (weight_m_axi_rid     ),
    .m_axi_rdata   (weight_m_axi_rdata   ),
    .m_axi_rresp   (weight_m_axi_rresp   ),
    .m_axi_rlast   (weight_m_axi_rlast   ),
    .m_axi_rvalid  (weight_m_axi_rvalid  ),
    .m_axi_rready  (weight_m_axi_rready  ),

    //  Configuration
    .enable        (weight_axi_dma_enable)
);

axis_1to8 # (
    .DWIDTH ( AXI_DATA_WIDTH ) 
) u_axis_1to8_weight(
    .clk            (clk ),
    .rst_n          (rst_n),
    .axis_valid_i   (weight_m_axis_read_data_tvalid),
    .axis_last_i    (weight_m_axis_read_data_tlast ),
    .axis_data_i    (weight_m_axis_read_data_tdata ),
    .axis_ready_i   (weight_m_axis_read_data_tready),
    .axis_user_i    (weight_m_axis_read_data_tuser[2:0]),

    .axis_valid_o   (w_axis_vld ),
    .axis_last_o    (w_axis_last),
    .axis_data_o    (w_axis_data),  
    .axis_ready_o   (w_axis_rdy )
);

// ------------------------------ weight axi_dma

// ++++++++++++++++++++++++++++++ activation axi_dma
wire                       activation_axi_dma_enable         ;
// ===== axis data
wire [AXI_DATA_WIDTH-1:0]  activation_m_axis_read_data_tdata ;
// wire [AXI_KEEP_WIDTH-1:0] m_axis_read_data_tkeep;
wire                       activation_m_axis_read_data_tvalid;
wire                       activation_m_axis_read_data_tready;
wire                       activation_m_axis_read_data_tlast ;
// wire [AXIS_ID_WIDTH-1:0]   m_axis_read_data_tid;
// wire [AXIS_DEST_WIDTH-1:0] m_axis_read_data_tdest;
wire [AXIS_USER_WIDTH-1:0] activation_m_axis_read_data_tuser ;

wire [AXI_ADDR_WIDTH-1:0]  activation_s_axis_read_desc_addr  ;
wire [LEN_WIDTH+1-1:0]     activation_s_axis_read_desc_len   ;
wire [TAG_WIDTH-1:0]       activation_s_axis_read_desc_tag   ;
wire [AXIS_USER_WIDTH-1:0] activation_s_axis_read_desc_user  ;
wire                       activation_s_axis_read_desc_valid ;
wire                       activation_s_axis_read_desc_ready ;

axi_dma_rd # (
    // Width of AXI data bus in bits
    .AXI_DATA_WIDTH    ( AXI_DATA_WIDTH ) ,
    // Width of AXI address bus in bits
    .AXI_ADDR_WIDTH    ( AXI_ADDR_WIDTH ) ,
    // Width of AXI ID signal
    .AXI_ID_WIDTH      ( 1  ) ,
    // Maximum AXI burst length to generate
    .AXI_MAX_BURST_LEN ( 64 ) ,
    // Use AXI stream tkeep signal
    // .AXIS_KEEP_ENABLE  ( 0  ) ,
    // Use AXI stream tlast signal
    .AXIS_LAST_ENABLE  ( 1  ) ,
    // Propagate AXI stream tid signal
    .AXIS_ID_ENABLE    ( 0  ) ,
    // Propagate AXI stream tdest signal
    .AXIS_DEST_ENABLE  ( 0  ) ,
    // Propagate AXI stream tuser signal
    .AXIS_USER_ENABLE  ( 1  ) ,
    // AXI stream tuser signal width
    .AXIS_USER_WIDTH   ( AXIS_USER_WIDTH  ) ,
    // Width of length field
    .LEN_WIDTH         ( LEN_WIDTH + 1 ) ,
    // Width of tag field
    .TAG_WIDTH         ( 1  ) ,
    // Enable support for scatter/gather DMA
    // (multiple descriptors per AXI stream frame)
    .ENABLE_SG         ( 0  ) ,
    // Enable support for unaligned transfers
    .ENABLE_UNALIGNED  ( 1  ) 
)u_axi_dma_activation(
    .clk               ( clk    ),
    .rst               ( ~rst_n ),

    //  AXI read descriptor input
    .s_axis_read_desc_addr (activation_s_axis_read_desc_addr ),
    .s_axis_read_desc_len  (activation_s_axis_read_desc_len  ),
    .s_axis_read_desc_tag  (activation_s_axis_read_desc_tag  ),
    // .s_axis_read_desc_id   (s_axis_read_desc_id   ),
    // .s_axis_read_desc_dest (s_axis_read_desc_dest ),
    .s_axis_read_desc_user (activation_s_axis_read_desc_user ),
    .s_axis_read_desc_valid(activation_s_axis_read_desc_valid),
    .s_axis_read_desc_ready(activation_s_axis_read_desc_ready),

    // AXI read descriptor status output
    .m_axis_read_desc_status_tag  (activation_m_axis_read_desc_status_tag  ),
    .m_axis_read_desc_status_error(activation_m_axis_read_desc_status_error),
    .m_axis_read_desc_status_valid(activation_m_axis_read_desc_status_valid),

    // AXI stream read data output
    .m_axis_read_data_tdata  (activation_m_axis_read_data_tdata ),
    // .m_axis_read_data_tkeep  (m_axis_read_data_tkeep ),
    .m_axis_read_data_tvalid (activation_m_axis_read_data_tvalid),
    .m_axis_read_data_tready (activation_m_axis_read_data_tready),
    .m_axis_read_data_tlast  (activation_m_axis_read_data_tlast ),
    // .m_axis_read_data_tid    (m_axis_read_data_tid   ),
    // .m_axis_read_data_tdest  (m_axis_read_data_tdest ),
    .m_axis_read_data_tuser  (activation_m_axis_read_data_tuser ),

    //  AXI master interface
    .m_axi_arid    (activation_m_axi_arid    ),
    .m_axi_araddr  (activation_m_axi_araddr  ),
    .m_axi_arlen   (activation_m_axi_arlen   ),
    .m_axi_arsize  (activation_m_axi_arsize  ),
    .m_axi_arburst (activation_m_axi_arburst ),
    .m_axi_arlock  (activation_m_axi_arlock  ),
    .m_axi_arcache (activation_m_axi_arcache ),
    .m_axi_arprot  (activation_m_axi_arprot  ),
    .m_axi_arvalid (activation_m_axi_arvalid ),
    .m_axi_arready (activation_m_axi_arready ),
    .m_axi_rid     (activation_m_axi_rid     ),
    .m_axi_rdata   (activation_m_axi_rdata   ),
    .m_axi_rresp   (activation_m_axi_rresp   ),
    .m_axi_rlast   (activation_m_axi_rlast   ),
    .m_axi_rvalid  (activation_m_axi_rvalid  ),
    .m_axi_rready  (activation_m_axi_rready  ),

    //  Configuration
    .enable        (activation_axi_dma_enable)
);

axis_1to8 # (
    .DWIDTH ( AXI_DATA_WIDTH ) 
) u_axis_1to8_activation (
    .clk            (clk ),
    .rst_n          (rst_n),
    .axis_valid_i   (activation_m_axis_read_data_tvalid),
    .axis_last_i    (activation_m_axis_read_data_tlast ),
    .axis_data_i    (activation_m_axis_read_data_tdata ),
    .axis_ready_i   (activation_m_axis_read_data_tready),
    .axis_user_i    (activation_m_axis_read_data_tuser[2:0]),

    .axis_valid_o   (a_axis_vld ),
    .axis_last_o    (a_axis_last),
    .axis_data_o    (a_axis_data),  
    .axis_ready_o   (a_axis_rdy )
);
// ------------------------------ weight axi_dma

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++ control 
// buffer cmd fifo: depth 16
wire buffer_cmd_full;
wire buffer_cmd_empty;
wire [CMD_LEN-1:0] buffer_cmd_o ;
wire               buffer_cmd_rd_en;

syncfifo # (
    .DATA_WIDTH  ( CMD_LEN       ), 
    .ADDR_WIDTH  ( 9             ), 
    .RAM_STYLE   ( "block" ), 
    .FWFT_EN     ( 1             )              
) u_buffer_cmd_fifo (
    .din    ( axi_dma_cmd     ) ,
    .wr_en  ( weight_cmd_wr_en) ,
    .full   ( buffer_cmd_full ) ,
    
    .dout   ( buffer_cmd_o    ) ,
    .rd_en  ( buffer_cmd_rd_en) ,
    .empty  ( buffer_cmd_empty) ,
    
    .clk    (clk  )         ,
    .rst_n  (rst_n)
);

assign { weight_s_axis_read_desc_addr ,
         weight_s_axis_read_desc_len  , 
         weight_s_axis_read_desc_user } = buffer_cmd_o; 

assign weight_s_axis_read_desc_valid = ~buffer_cmd_empty;
assign buffer_cmd_rd_en              = weight_s_axis_read_desc_ready;

// fifo cmd fifo: depth 16 
wire fifo_cmd_full;
wire fifo_cmd_empty;
wire [CMD_LEN-1:0] fifo_cmd_o ;
wire               fifo_cmd_rd_en;
syncfifo # (
    .DATA_WIDTH  ( CMD_LEN       ), 
    .ADDR_WIDTH  ( 9             ), 
    .RAM_STYLE   ( "block" ), 
    .FWFT_EN     ( 1             )              
) u_fifo_cmd_fifo (
    .din    ( axi_dma_cmd         ) ,
    .wr_en  ( activation_cmd_wr_en) ,
    .full   ( fifo_cmd_full       ) ,
    
    .dout   ( fifo_cmd_o    ) ,
    .rd_en  ( fifo_cmd_rd_en) ,
    .empty  ( fifo_cmd_empty) ,
    
    .clk    (clk  )           ,
    .rst_n  (rst_n)                
);
assign { activation_s_axis_read_desc_addr ,
         activation_s_axis_read_desc_len  , 
         activation_s_axis_read_desc_user } = fifo_cmd_o; 
assign activation_s_axis_read_desc_valid = ~fifo_cmd_empty;
assign fifo_cmd_rd_en                    = activation_s_axis_read_desc_ready;

assign weight_s_axis_read_desc_tag = {TAG_WIDTH{1'b0}};
assign activation_s_axis_read_desc_tag = {TAG_WIDTH{1'b0}};

assign weight_axi_dma_enable = 1'b1;
assign activation_axi_dma_enable = 1'b1;
// ------------------------------------------------------ control
endmodule

`default_nettype wire 
