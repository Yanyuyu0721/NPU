/*-----------------------------------------
file name  : top_systolic_unit.v
created    : 2025/12/25 22:50:43
modified   : 2026-03-17 23:52:15
description: 
notes      : 
author     : anonymous contributor
-----------------------------------------*/
`default_nettype none
module top_systolic_unit # (
    parameter PE_NCOL        = 8   , 
    parameter PE_NROW        = 8   ,
    parameter AXI_DATA_WIDTH = 64  ,
    parameter DOWIDTH        = 8   ,
    parameter CHANNEL        = 2   ,
    parameter AXI_ADDR_WIDTH = 32  , // const
    parameter TAG_WIDTH      = 8   , // const
    parameter LEN_WIDTH      = 12  , // const
    parameter AXIS_USER_WIDTH= 3   , // const
    parameter ICMD_LEN       = 60  , // const
    parameter PSUM_WIDTH     = 32  
)(
    input  wire                      clk                  , // (input )
    input  wire                      rst_n                , // (input )
    
    // ++ config channel
    input  wire       [ICMD_LEN-1:0] cmd                  , // (input )
    input  wire                      cmd_vld              , // (input )
    output wire                      cmd_rdy              ,
    
    output wire      [TAG_WIDTH-1:0] systolic_status_tag  ,  
    output wire                      systolic_status_en   ,  
    
    output wire                      wr_buf_id            , // (output)


    output wire [PE_NCOL-1:0]           vld_out           , 
    output wire [PE_NCOL*PSUM_WIDTH-1:0]res_out           ,  

    // ++ weight axi dma channel 
    output wire                [0:0] weight_m_axi_arid    , // (output)
    output wire [AXI_ADDR_WIDTH-1:0] weight_m_axi_araddr  , // (output)
    output wire                [7:0] weight_m_axi_arlen   , // (output)
    output wire                [2:0] weight_m_axi_arsize  , // (output)
    output wire                [1:0] weight_m_axi_arburst , // (output)
    output wire                      weight_m_axi_arlock  , // (output)
    output wire                [3:0] weight_m_axi_arcache , // (output)
    output wire                [2:0] weight_m_axi_arprot  , // (output)
    output wire                      weight_m_axi_arvalid , // (output)
    input  wire                      weight_m_axi_arready , // (input )

    input  wire                [0:0] weight_m_axi_rid     , // (input )
    input  wire [AXI_DATA_WIDTH-1:0] weight_m_axi_rdata   , // (input )
    input  wire                [1:0] weight_m_axi_rresp   , // (input )
    input  wire                      weight_m_axi_rlast   , // (input )
    input  wire                      weight_m_axi_rvalid  , // (input )
    output wire                      weight_m_axi_rready  , // (output)

    // ++ activation axi dam channel 
    output wire                [0:0] activation_m_axi_arid   , // (output)
    output wire [AXI_ADDR_WIDTH-1:0] activation_m_axi_araddr , // (output)
    output wire                [7:0] activation_m_axi_arlen  , // (output)
    output wire                [2:0] activation_m_axi_arsize , // (output)
    output wire                [1:0] activation_m_axi_arburst, // (output)
    output wire                      activation_m_axi_arlock , // (output)
    output wire                [3:0] activation_m_axi_arcache, // (output)
    output wire                [2:0] activation_m_axi_arprot , // (output)
    output wire                      activation_m_axi_arvalid, // (output)
    input  wire                      activation_m_axi_arready, // (input )

    input  wire                [0:0] activation_m_axi_rid    ,  // (input )
    input  wire [AXI_DATA_WIDTH-1:0] activation_m_axi_rdata  ,  // (input )
    input  wire                [1:0] activation_m_axi_rresp  ,  // (input )
    input  wire                      activation_m_axi_rlast  ,  // (input )
    input  wire                      activation_m_axi_rvalid ,  // (input )
    output wire                      activation_m_axi_rready    // (output)
    // --------------------------- axi dma 
);

localparam OCMD_LEN = AXI_ADDR_WIDTH + LEN_WIDTH + 1 + AXIS_USER_WIDTH;

wire [OCMD_LEN-1:0] axi_dma_cmd            ;
wire                weight_cmd_wr_en       ;
wire                activation_cmd_wr_en   ;

wire [PE_NCOL-1:0]  col_en                 ;  
wire [PE_NROW-1:0]  row_en                 ; 
wire                rd_buf_id              ;
wire [11:0]         calc_len               ;
wire                last_en                ;
wire [PE_NCOL-1:0]  weight_start_en        ;
wire [PE_NROW-1:0]  activation_start_en    ;

// ++++ status 
// ++ weight axi dma status channel
wire [0:0]           weight_m_axis_read_desc_status_tag      ;
wire [3:0]           weight_m_axis_read_desc_status_error    ;
wire                 weight_m_axis_read_desc_status_valid    ;
// ++ activation axi dma status channel
wire [0:0]           activation_m_axis_read_desc_status_tag  ;
wire [3:0]           activation_m_axis_read_desc_status_error;
wire                 activation_m_axis_read_desc_status_valid;

wire                 calc_status_valid  ;      

wire [PE_NCOL*$clog2(PE_NROW-1)-1:0] raw_row_en;
// ---- status 

systolic_control #( 
    .PE_NCOL        (PE_NCOL        ) , 
    .PE_NROW        (PE_NROW        ) , 
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH ) , // const 32
    .TAG_WIDTH      (TAG_WIDTH      ) , // const 8
    .LEN_WIDTH      (LEN_WIDTH      ) , // const 12 
    .AXIS_USER_WIDTH(AXIS_USER_WIDTH) , // const 3
    .ICMD_LEN       (ICMD_LEN       )   // const 60
)u_systolic_control(
    .clk                          (clk                          ), 
    .rst_n                        (rst_n                        ), 
    
    .i_cmd                        (cmd                          ), 
    .i_cmd_vld                    (cmd_vld                      ), 
    .i_cmd_rdy                    (cmd_rdy                      ),
   
    .calc_len                     (calc_len                     ),
    .last_en                      (last_en                      ),

    .o_cmd                        (axi_dma_cmd                  ), 
    .o_fifo_cmd_en                (activation_cmd_wr_en         ), 
    .o_buf_cmd_en                 (weight_cmd_wr_en             ), 
    
    .rd_buf_id                    (rd_buf_id                    ), 
    .col_en                       (col_en                       ), 
    .row_en                       (row_en                       ), 
    .raw_row_en                   (raw_row_en                   ),
    
    .col_start_en                 (weight_start_en              ), 
    .row_start_en                 (activation_start_en          ), 
    
    .fifo_status_en               (activation_m_axis_read_desc_status_valid ), // (input ) 
    .buff_status_en               (weight_m_axis_read_desc_status_valid     ), // (input )
    .calc_status_en               (calc_status_valid                        ), // (input )
    
    .systolic_status_tag          (systolic_status_tag          ), // (output) 
    .systolic_status_en           (systolic_status_en           )  // (output) 
);

systolic_unit # (
    .PE_NROW        (PE_NROW        ),
    .PE_NCOL        (PE_NCOL        ),  
    .DWIDTH         (DOWIDTH        ),
    .CHANNEL        (CHANNEL        ),
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH ),
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH ),
    .TAG_WIDTH      (1              ),
    .LEN_WIDTH      (LEN_WIDTH      ),
    .PSUM_WIDTH     (PSUM_WIDTH     ),
    .AXIS_USER_WIDTH(AXIS_USER_WIDTH) 
)u_systolic_unit(
    .clk                  (clk                 ) ,
    .rst_n                (rst_n               ) ,

    // +++++++++++++++++++++++++++ pe_array controll 
    .col_en               (col_en              ) ,  
    .row_en               (row_en              ) , 
    .raw_row_en           (raw_row_en          ) ,
    .rd_buf_id            (rd_buf_id           ) ,

    .calc_len             (calc_len            ) ,
    .last_en              (last_en             ) ,
                                               
    .weight_start_en      (weight_start_en     ) ,
    .activation_start_en  (activation_start_en ) ,
    .wr_buf_id            (wr_buf_id           ) ,
    // --------------------------- pe_array controll 
    .vld_out              (vld_out             ), // (output)
    .res_out              (res_out             ), // (output)

    // +++++++++++++++++++++++++++ axi dma 
    .axi_dma_cmd          (axi_dma_cmd         ) ,
    .weight_cmd_wr_en     (weight_cmd_wr_en    ) ,
    .activation_cmd_wr_en (activation_cmd_wr_en) ,

    // ++ weight axi dma status channel
    .weight_m_axis_read_desc_status_tag      (weight_m_axis_read_desc_status_tag      ),
    .weight_m_axis_read_desc_status_error    (weight_m_axis_read_desc_status_error    ),
    .weight_m_axis_read_desc_status_valid    (weight_m_axis_read_desc_status_valid    ),

    // ++ activation axi dma status channel
    .activation_m_axis_read_desc_status_tag  (activation_m_axis_read_desc_status_tag  ),
    .activation_m_axis_read_desc_status_error(activation_m_axis_read_desc_status_error),
    .activation_m_axis_read_desc_status_valid(activation_m_axis_read_desc_status_valid),

    .calc_status_valid        (calc_status_valid        ) ,

    // ++ weight axi dma channel 
    .weight_m_axi_arid        (weight_m_axi_arid        ) ,
    .weight_m_axi_araddr      (weight_m_axi_araddr      ) ,
    .weight_m_axi_arlen       (weight_m_axi_arlen       ) ,
    .weight_m_axi_arsize      (weight_m_axi_arsize      ) ,
    .weight_m_axi_arburst     (weight_m_axi_arburst     ) ,
    .weight_m_axi_arlock      (weight_m_axi_arlock      ) ,
    .weight_m_axi_arcache     (weight_m_axi_arcache     ) ,
    .weight_m_axi_arprot      (weight_m_axi_arprot      ) ,
    .weight_m_axi_arvalid     (weight_m_axi_arvalid     ) ,
    .weight_m_axi_arready     (weight_m_axi_arready     ) ,
                                                        
    .weight_m_axi_rid         (weight_m_axi_rid         ) ,
    .weight_m_axi_rdata       (weight_m_axi_rdata       ) ,
    .weight_m_axi_rresp       (weight_m_axi_rresp       ) ,
    .weight_m_axi_rlast       (weight_m_axi_rlast       ) ,
    .weight_m_axi_rvalid      (weight_m_axi_rvalid      ) ,
    .weight_m_axi_rready      (weight_m_axi_rready      ) ,

    // ++ activation axi dam channel 
    .activation_m_axi_arid    (activation_m_axi_arid    ) ,
    .activation_m_axi_araddr  (activation_m_axi_araddr  ) ,
    .activation_m_axi_arlen   (activation_m_axi_arlen   ) ,
    .activation_m_axi_arsize  (activation_m_axi_arsize  ) ,
    .activation_m_axi_arburst (activation_m_axi_arburst ) ,
    .activation_m_axi_arlock  (activation_m_axi_arlock  ) ,
    .activation_m_axi_arcache (activation_m_axi_arcache ) ,
    .activation_m_axi_arprot  (activation_m_axi_arprot  ) ,
    .activation_m_axi_arvalid (activation_m_axi_arvalid ) ,
    .activation_m_axi_arready (activation_m_axi_arready ) ,
                                                        
    .activation_m_axi_rid     (activation_m_axi_rid     ) ,
    .activation_m_axi_rdata   (activation_m_axi_rdata   ) ,
    .activation_m_axi_rresp   (activation_m_axi_rresp   ) ,
    .activation_m_axi_rlast   (activation_m_axi_rlast   ) ,
    .activation_m_axi_rvalid  (activation_m_axi_rvalid  ) ,
    .activation_m_axi_rready  (activation_m_axi_rready  ) ,
    // --------------------------- axi dma 

    .update_pingpong          (systolic_status_en       ) 
);

endmodule

`default_nettype wire 