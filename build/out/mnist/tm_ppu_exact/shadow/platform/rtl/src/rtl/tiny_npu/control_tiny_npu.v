/*-----------------------------------------
file name  : control_tiny_npu.v
created    : 2026/01/05 22:19:11
modified   : 2026-02-25 18:28:00
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
`default_nettype none
module control_tiny_npu # (
    parameter                 NINSTR = 64          ,
    parameter              TAG_WIDTH = 8
)(
    input  wire                          clk                  , // (input )
    input  wire                          rst_n                , // (input )

    input  wire                          instruction_valid    , // (input )
    input  wire             [NINSTR-1:0] instruction          , // (input )
    output wire                          instruction_ready    , // (output)

    input  wire                          systolic_status_en   , // (input )
    input  wire                          cdma_status_en       , // (input )
    input  wire                          ppu_status_en        , // TODO

    output wire                          systolic_unit_cmd_vld, // (output)
    input  wire                          systolic_unit_cmd_rdy,
    output wire           [NINSTR-4-1:0] systolic_unit_cmd    , // (output)

    output wire                          cdma_cmd_vld         , // (output)
    input  wire                          cdma_cmd_rdy         , // (output)
    output wire         [NINSTR*2-4-1:0] cdma_cmd             , // (output) 

    output wire                          ppu_cmd_vld          , // (output)
    input  wire                          ppu_cmd_rdy          , // (output)
    output wire         [NINSTR*2-4-1:0] ppu_cmd              ,

    output wire                          inst_dma_cmd_vld     ,
    output wire           [NINSTR-4-1:0] inst_dma_cmd         ,
    input  wire                          inst_dma_cmd_rdy     ,

    output wire                          sync_status_en       , // (output)
    output wire          [TAG_WIDTH-1:0] sync_status_tag        // (output)
);

localparam [2:0] s_idle = 3'b000;
localparam [2:0] s_cdma = 3'b001;
localparam [2:0] s_sync = 3'b010;
localparam [2:0] s_ppu  = 3'b011;
localparam [2:0] s_sync_wait = 3'b100;

wire                  cdma_cmd_en      ; 
wire [NINSTR*2-4-1:0] cdma_cmd_fifo    ;

wire                  systolic_unit_cmd_en;
wire  [NINSTR-4-1:0]  systolic_unit_cmd_fifo; 

wire                  ppu_cmd_en;
wire [NINSTR*2-4-1:0] ppu_cmd_fifo; 

wire                  inst_dma_cmd_en;
wire  [NINSTR-4-1:0]  inst_dma_cmd_fifo; 

// Every accepted instruction must have storage in its destination queue.
// Long instructions hold their first word in instr_reg; their second word
// waits for queue space. Global SYNC is broadcast only when all three queues
// can accept it on the same edge. No queue depth or opcode is changed.
wire systolic_queue_full, cdma_queue_full, ppu_queue_full, inst_dma_queue_full;
wire sync_dispatch;

wire instr_en;
assign instr_en = instruction_valid & instruction_ready;

wire [NINSTR-4-1:0] cmd     ;
wire [4:0]          opcode  ;
wire [3:0]          cmd_type;
assign cmd     = instruction[NINSTR-1:4];
assign cmd_type= instruction[3:0];
assign opcode  = instruction[8:4];

wire is_systolic_unit ;
wire is_cdma          ;
wire is_ppu           ;
wire is_special       ;
wire is_inst_dma      ;
assign is_systolic_unit = cmd_type == 4'b0001; 
assign is_cdma          = cmd_type == 4'b0010;
assign is_ppu           = cmd_type == 4'b0011; 
assign is_inst_dma      = cmd_type == 4'b0100;
assign is_special       = &cmd_type;

wire ppu_long_inst = is_ppu && opcode == 'b1; 
wire ppu_short_inst = is_ppu && opcode != 'b1;
wire is_sync;
assign is_sync = is_special & ~(|opcode) ;

wire all_sync;

reg [NINSTR-4-1:0] instr_reg;
always @ (posedge clk) begin 
    if( ( is_cdma || ppu_long_inst ) && instr_en )
        instr_reg <= cmd;
end

reg [2:0] curr_state, next_state;

always @(posedge clk) begin
    if( ~rst_n ) 
        curr_state <= s_idle;
    else 
        curr_state <= next_state;
end

always@(*) begin 
    case( curr_state )
    s_idle: begin 
        if( instr_en & is_cdma )     next_state = s_cdma;         
        else if( instr_en & ppu_long_inst) next_state = s_ppu;
        else if( instr_en & is_sync) next_state = s_sync;
        else                         next_state = s_idle;
    end
    s_cdma: begin 
        if( instr_en ) next_state = s_idle;
        else           next_state = s_cdma;
    end
    s_ppu: begin 
        if( instr_en ) next_state = s_idle;
        else           next_state = s_ppu;
    end
    s_sync: begin
        if (sync_dispatch) next_state = s_sync_wait;
        else               next_state = s_sync;
    end
    s_sync_wait: begin 
        if( all_sync ) next_state = s_idle;
        else           next_state = s_sync_wait;
    end
    default: begin 
        next_state = s_idle;
    end
    endcase
end

wire is_idle_state, is_cdma_state,is_ppu_state, is_sync_state,is_sync_wait_state;
assign is_idle_state = curr_state == s_idle;
assign is_cdma_state = curr_state == s_cdma;
assign is_ppu_state  = curr_state == s_ppu;
assign is_sync_state = curr_state == s_sync;
assign is_sync_wait_state = curr_state == s_sync_wait;

reg [TAG_WIDTH-1:0] tag_reg;
always @ (posedge clk) begin 
    if( is_idle_state & instr_en ) 
        tag_reg <= instruction[NINSTR-1 -: TAG_WIDTH];
end

wire idle_destination_ready;
assign idle_destination_ready = is_systolic_unit ? ~systolic_queue_full :
                                is_inst_dma      ? ~inst_dma_queue_full :
                                ppu_short_inst   ? ~ppu_queue_full : 1'b1;
assign instruction_ready = (is_idle_state && idle_destination_ready) ||
                           (is_cdma_state && !cdma_queue_full) ||
                           (is_ppu_state && !ppu_queue_full);
assign sync_dispatch = is_sync_state && !systolic_queue_full &&
                       !cdma_queue_full && !ppu_queue_full;
assign systolic_unit_cmd_en = (instr_en & is_idle_state & is_systolic_unit) | sync_dispatch ;
assign cdma_cmd_en          = instr_en & is_cdma_state | sync_dispatch                          ;
assign ppu_cmd_en           = instr_en & (( is_idle_state & ppu_short_inst) | is_ppu_state) | sync_dispatch; 
assign inst_dma_cmd_en      = (instr_en & is_idle_state & is_inst_dma);

assign systolic_unit_cmd_fifo = is_sync_state ? {tag_reg,46'b0 ,1'b1,5'b1_1111}: cmd;
assign cdma_cmd_fifo          = is_sync_state ? {tag_reg,110'b0,1'b1,5'b1_1111}:{instruction,instr_reg};
assign ppu_cmd_fifo           = is_sync_state ? {tag_reg,110'b0,1'b1,5'b1_1111}: 
                                is_ppu_state ? {instruction,instr_reg} : {64'b0,cmd};
assign inst_dma_cmd_fifo      = cmd;

reg [2:0] sync_status;
always@(posedge clk) begin 
    if( is_sync_state ) 
        sync_status[0] <= 1'b0;
    else if(systolic_status_en)
        sync_status[0] <= 1'b1;
end

always@(posedge clk) begin 
    if( is_sync_state ) 
        sync_status[1] <= 1'b0;
    else if( cdma_status_en )
        sync_status[1] <= 1'b1;
end

always@(posedge clk) begin 
    if( is_sync_state ) 
        sync_status[2] <= 1'b0;
    else if( ppu_status_en ) 
        sync_status[2] <= 1'b1;
end

assign all_sync = &sync_status;

assign sync_status_tag = tag_reg;
assign sync_status_en  = is_sync_wait_state & all_sync;

wire systolic_unit_cmd_rd_en;
assign systolic_unit_cmd_rd_en = systolic_unit_cmd_rdy & systolic_unit_cmd_vld;
wire systolic_queue_empty;
syncfifo # (
    .DATA_WIDTH    ( NINSTR-4 ) , 
    .ADDR_WIDTH    ( 11        ) , 
    .RAM_STYLE     ( "block"  ) , 
    .FWFT_EN       ( 1        )           
)u_systolic_queue(
    .din                          (systolic_unit_cmd_fifo       ), // (input )
    .wr_en                        (systolic_unit_cmd_en         ), // (input )
    .full                         (systolic_queue_full), // (output)
    
    .dout                         (systolic_unit_cmd            ), // (output)
    .rd_en                        (systolic_unit_cmd_rd_en      ), // (input )
    .empty                        (systolic_queue_empty         ), // (output)
    
    .clk                          (clk                          ), // (input )
    .rst_n                        (rst_n                        )  // (input )
);
assign systolic_unit_cmd_vld = ~systolic_queue_empty;       

wire cdma_cmd_rd_en;
assign cdma_cmd_rd_en = cdma_cmd_rdy & cdma_cmd_vld;
wire cdma_queue_empty;
syncfifo # (
    .DATA_WIDTH     ( NINSTR*2 -4), 
    .ADDR_WIDTH     ( 4          ), 
    .RAM_STYLE      ("block"     ), 
    .FWFT_EN        ( 1          )    
)u_cdma_queue(
    .din                          (cdma_cmd_fifo                ), // (input )
    .wr_en                        (cdma_cmd_en                  ), // (input )
    .full                         (cdma_queue_full), // (output)
    
    .dout                         (cdma_cmd                     ), // (output)
    .rd_en                        (cdma_cmd_rd_en               ), // (input )
    .empty                        (cdma_queue_empty             ), // (output)
    
    .clk                          (clk                          ), // (input )
    .rst_n                        (rst_n                        )  // (input )
);
assign cdma_cmd_vld = ~cdma_queue_empty;               

wire ppu_cmd_rd_en;
assign ppu_cmd_rd_en = ppu_cmd_rdy & ppu_cmd_vld;
wire ppu_queue_empty;

syncfifo # (
    .DATA_WIDTH     ( NINSTR*2-4   ), 
    .ADDR_WIDTH     ( 11            ), 
    .RAM_STYLE      ("block"       ), 
    .FWFT_EN        ( 1            )    
)u_ppu_queue(
    .din                          (ppu_cmd_fifo), // (input )
    .wr_en                        (ppu_cmd_en  ), // (input )
    .full                         (ppu_queue_full), // (output)
    
    .dout                         (ppu_cmd), // (output)
    .rd_en                        (ppu_cmd_rd_en), // (input )
    .empty                        (ppu_queue_empty), // (output)
    
    .clk                          (clk), // (input )
    .rst_n                        (rst_n)  // (input )
);
assign ppu_cmd_vld = ~ppu_queue_empty;

wire inst_dma_cmd_rd_en;
assign inst_dma_cmd_rd_en = inst_dma_cmd_rdy & inst_dma_cmd_vld;
wire inst_dma_queue_empty;
syncfifo # (
    .DATA_WIDTH     ( NINSTR-4     ), 
    .ADDR_WIDTH     ( 4            ), 
    .RAM_STYLE      ("distributed" ), 
    .FWFT_EN        ( 1            )    
)u_inst_dma_queue(
    .din      (inst_dma_cmd_fifo), // (input )
    .wr_en    (inst_dma_cmd_en  ), // (input )
    .full     (inst_dma_queue_full), // (output)
    
    .dout     (inst_dma_cmd        ), // (output)
    .rd_en    (inst_dma_cmd_rd_en  ), // (input )
    .empty    (inst_dma_queue_empty), // (output)
    
    .clk      (clk   ), // (input )
    .rst_n    (rst_n )  // (input )
);

assign inst_dma_cmd_vld = ~inst_dma_queue_empty;
endmodule
`default_nettype wire
