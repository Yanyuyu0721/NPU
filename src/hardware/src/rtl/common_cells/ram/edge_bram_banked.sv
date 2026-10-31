// 2018.2 bring-up replacement for src/rtl/common_cells/ram/edge_bram_banked.sv
//
// Why: the packaged module preloads each bank through a temporary array
//      (reg initial_image[0:RAM_WORDS-1]; $readmemh(INIT_FILE, initial_image);
//       initial for(...) mem[k]=initial_image[BASE+k];)
//      Vivado 2026.1 folds that procedural copy into BRAM INIT, but Vivado 2018.2
//      silently keeps INIT_00..INIT_FF = 0 (verified on routed_50mhz.dcp: 0 of 129
//      RAMB cells carried data).  With an empty ITCM the CPU fetches 0x00000000,
//      traps to 0x0, the in-range AXI guard never returns ready and the core hangs:
//      uart_tx stays idle high and no character is ever sent.
//
// This drop-in keeps the port list, parameter list and read/write semantics
// (read-first, byte enables, registered read, out-of-range read returns 0) while
// performing a single direct $readmemh into the inferred memory, which every
// Vivado release accepts as BRAM preload data.
module edge_bram_banked #(
 parameter DATA_WIDTH=64, STRB_WIDTH=DATA_WIDTH/8, ADDR_WIDTH=16,
 parameter RAM_WORDS=22528, BANK_WORDS=1024, INIT_FILE=""
)(
 input wire a_clk, input wire a_rd, input wire a_wr,
 input wire [ADDR_WIDTH-1:0] a_addr,
 input wire [DATA_WIDTH-1:0] a_wdata,
 input wire [STRB_WIDTH-1:0] a_strb,
 output reg [DATA_WIDTH-1:0] a_rdata,
 input wire b_clk, input wire b_rd, input wire b_wr,
 input wire [ADDR_WIDTH-1:0] b_addr,
 input wire [DATA_WIDTH-1:0] b_wdata,
 input wire [STRB_WIDTH-1:0] b_strb,
 output reg [DATA_WIDTH-1:0] b_rdata
);
 // BANK_WORDS is accepted for source compatibility only: a single array gives
 // Vivado the direct preload it understands and still packs into the same BRAMs.
 (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:RAM_WORDS-1];

 reg a_valid = 1'b0;
 reg b_valid = 1'b0;
 reg [DATA_WIDTH-1:0] ar = {DATA_WIDTH{1'b0}};
 reg [DATA_WIDTH-1:0] br = {DATA_WIDTH{1'b0}};

 initial begin
  if (DATA_WIDTH != 8*STRB_WIDTH || RAM_WORDS < 1 || BANK_WORDS < 1 || RAM_WORDS > 2**ADDR_WIDTH)
   $error("Invalid bank geometry");
  if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
 end

 always @(posedge a_clk) begin
  if (a_rd) begin
   a_valid <= a_addr < RAM_WORDS;
   ar <= (a_addr < RAM_WORDS) ? mem[a_addr] : {DATA_WIDTH{1'b0}};
  end
 end

 always @(posedge b_clk) begin
  if (b_rd) begin
   b_valid <= b_addr < RAM_WORDS;
   br <= (b_addr < RAM_WORDS) ? mem[b_addr] : {DATA_WIDTH{1'b0}};
  end
 end

 always @(posedge a_clk) begin
  if (a_wr && a_addr < RAM_WORDS)
   for (integer j = 0; j < STRB_WIDTH; j = j + 1)
    if (a_strb[j]) mem[a_addr][8*j+:8] <= a_wdata[8*j+:8];
 end

 always @(posedge b_clk) begin
  if (b_wr && b_addr < RAM_WORDS)
   for (integer j = 0; j < STRB_WIDTH; j = j + 1)
    if (b_strb[j]) mem[b_addr][8*j+:8] <= b_wdata[8*j+:8];
 end

 always @* begin
  a_rdata = a_valid ? ar : {DATA_WIDTH{1'b0}};
  b_rdata = b_valid ? br : {DATA_WIDTH{1'b0}};
 end
endmodule
