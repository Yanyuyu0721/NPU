// Fixed-capacity banks avoid rounding a non-power-of-two RAM up to one large array.
// Read-first, byte-write, one registered read cycle. Cross-port same-address
// read/write and write/write collisions retain the underlying BRAM's undefined contract.
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
 localparam BANKS=(RAM_WORDS+BANK_WORDS-1)/BANK_WORDS;
 localparam SEL_WIDTH=BANKS>1?$clog2(BANKS):1;
 reg [SEL_WIDTH-1:0] a_sel=0,b_sel=0;
 reg a_valid=1,b_valid=1;
 wire [DATA_WIDTH-1:0] a_data[0:BANKS-1],b_data[0:BANKS-1];
 initial begin
  if(DATA_WIDTH!=8*STRB_WIDTH||RAM_WORDS<1||BANK_WORDS<1||RAM_WORDS>2**ADDR_WIDTH)
   $error("Invalid bank geometry");
 end
 always @(posedge a_clk) if(a_rd) begin a_sel<=a_addr/BANK_WORDS;a_valid<=a_addr<RAM_WORDS;end
 always @(posedge b_clk) if(b_rd) begin b_sel<=b_addr/BANK_WORDS;b_valid<=b_addr<RAM_WORDS;end
 always @* begin
  a_rdata=0;b_rdata=0;
  for(integer s=0;s<BANKS;s=s+1) begin
   if(a_valid&&a_sel==s)a_rdata=a_data[s];
   if(b_valid&&b_sel==s)b_rdata=b_data[s];
  end
 end
 for(genvar g=0;g<BANKS;g=g+1)begin:banks
  localparam BASE=g*BANK_WORDS;
  localparam WORDS=RAM_WORDS-BASE<BANK_WORDS?RAM_WORDS-BASE:BANK_WORDS;
  (* ram_style="block" *) reg [DATA_WIDTH-1:0] mem[0:WORDS-1];
  reg [DATA_WIDTH-1:0] ar=0,br=0;
  assign a_data[g]=ar;assign b_data[g]=br;
  if(INIT_FILE!="")begin:init_file
   // A temporary initialization-only image has no runtime read/write ports.
   reg [DATA_WIDTH-1:0] initial_image[0:RAM_WORDS-1];
   initial begin
    $readmemh(INIT_FILE,initial_image);
    for(integer k=0;k<WORDS;k=k+1)mem[k]=initial_image[BASE+k];
   end
  end
  always @(posedge a_clk)begin
   if(a_addr>=BASE&&a_addr<BASE+WORDS)begin
    if(a_rd)ar<=mem[a_addr-BASE];
    if(a_wr)for(integer j=0;j<STRB_WIDTH;j=j+1)if(a_strb[j])mem[a_addr-BASE][8*j+:8]<=a_wdata[8*j+:8];
   end
  end
  always @(posedge b_clk)begin
   if(b_addr>=BASE&&b_addr<BASE+WORDS)begin
    if(b_rd)br<=mem[b_addr-BASE];
    if(b_wr)for(integer j=0;j<STRB_WIDTH;j=j+1)if(b_strb[j])mem[b_addr-BASE][8*j+:8]<=b_wdata[8*j+:8];
   end
  end
 end
endmodule
