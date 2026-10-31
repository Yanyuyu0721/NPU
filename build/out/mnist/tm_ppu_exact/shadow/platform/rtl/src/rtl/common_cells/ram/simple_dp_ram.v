/*-----------------------------------------
file name  : simple_dp_ram.v
created    : 2026/01/27 11:48:49
modified   : 2026-01-27 15:21:01
description: 
notes      : 
author     : yyrwkk
-----------------------------------------*/
module simple_dp_ram #(
    parameter WRITE_WIDTH =   32,  
    parameter READ_WIDTH  =   8 ,   
    parameter WRITE_DEPTH = 1024 
)(
    input wire clk,            
    
    input wire                                                       wr_en  ,
    input wire  [$clog2(WRITE_DEPTH)-1:0]                            wr_addr,
    input wire  [WRITE_WIDTH-1:0]                                    din    ,
    
    input wire                                                       rd_en  ,
    input wire  [$clog2(WRITE_DEPTH * (WRITE_WIDTH/READ_WIDTH))-1:0] rd_addr,
    output wire [READ_WIDTH-1:0]                                     dout       
);
`ifndef FPGA_SOURCE
    localparam RATIO = WRITE_WIDTH / READ_WIDTH; 
    localparam SUB_ADDR_BITS = $clog2(RATIO)   ; 
    
    (* ram_style = "block" *)
    reg [WRITE_WIDTH-1:0] mem [0:WRITE_DEPTH-1];
    
    always @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= din;
        end
    end
    
    reg [SUB_ADDR_BITS-1:0] sub_addr;
    always@(posedge clk) begin 
        if( rd_en ) 
            sub_addr <= rd_addr[SUB_ADDR_BITS-1:0];
    end

    wire [$clog2(WRITE_DEPTH)-1:0] row_addr = rd_addr >> SUB_ADDR_BITS;
    
    reg [WRITE_WIDTH-1:0] full_word_out;

    always @(posedge clk) begin
        if (rd_en) begin
            full_word_out <= mem[row_addr];
        end
    end
    
    assign dout = full_word_out[sub_addr * READ_WIDTH +: READ_WIDTH];
`else 
xpm_memory_sdpram #(
        .ADDR_WIDTH_A($clog2(WRITE_DEPTH)),
        .ADDR_WIDTH_B($clog2(WRITE_DEPTH * (WRITE_WIDTH/READ_WIDTH))),
        .AUTO_SLEEP_TIME(0),
        .BYTE_WRITE_WIDTH_A(WRITE_WIDTH),
        .CLOCKING_MODE("common_clock"), // read and write use same clk domain 
        .ECC_MODE("no_ecc"),
        .MEMORY_INIT_FILE("none"),
        .MEMORY_OPTIMIZATION("true"),
        .MEMORY_PRIMITIVE("block"),
        .MEMORY_SIZE(WRITE_WIDTH * WRITE_DEPTH),
        .MESSAGE_CONTROL(0),
        .READ_DATA_WIDTH_B(READ_WIDTH),     // read_width 
        .READ_LATENCY_B(1),
        .READ_RESET_VALUE_B("0"),
        .USE_EMBEDDED_CONSTRAINT(0),
        .USE_MEM_INIT(0),
        .WAKEUP_TIME("disable_sleep"),
        .WRITE_DATA_WIDTH_A(WRITE_WIDTH),   // write_width 
        .WRITE_MODE_B("read_first")
    )
    xpm_memory_sdpram_inst (
        .clka(clk),
        .ena(1'b1),
        .wea(wr_en),
        .addra(wr_addr),
        .dina(din),
        .clkb(clk),
        .enb(rd_en),
        .addrb(rd_addr),
        .doutb(dout),

        .injectdbiterra(1'b0),
        .injectsbiterra(1'b0),
        .regceb(1'b1),
        .rstb(1'b0),
        .sleep(1'b0),
        .dbiterrb(),
        .sbiterrb()
    );
`endif
endmodule 
