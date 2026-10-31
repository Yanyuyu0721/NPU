`timescale 1ns/1ps
// Actual ppu_control + actual syncfifo. Only the worker/DMA ports are modeled.
module tb_ppu_descriptor;
reg clk=0; always #5 clk=~clk;
reg rst_n=0,inst_vld=0; reg [123:0] inst=0; wire inst_rdy;
reg [7:0] ppu_inst_rdy=0,ppu_status=255; wire [7:0] ppu_inst_vld;wire [751:0] ppu_inst;
reg [3:0] cmd_en_gp0=0,cmd_en_gp1=0;reg [127:0] cmd_addr_gp0=0,cmd_addr_gp1=0;
reg [51:0] cmd_data_num_gp0=0,cmd_data_num_gp1=0;
wire [46:0] o_cmd_gp0,o_cmd_gp1;wire o_cmd_en_gp0,o_cmd_en_gp1;
reg gp0_status_en=0,gp1_status_en=0;
wire [8:0] cfg_out_zp;wire [2:0] cfg_actfunc_type;
wire cfg_actfunc_enable,cfg_rescale_enable,cfg_bias_enable,ppu_status_en;wire[7:0]ppu_status_tag;
ppu_control dut(.*);
integer test_id=0,cycle=0,lane,i,n,sync_count=0,accepts[0:7],stores[0:7],reads[0:7],highwater[0:7];
reg [93:0] expected[0:7][0:2047];reg [31:0] rng=32'h13579bdf;
reg random_drain=0;
function automatic[123:0] descriptor(input integer d,input integer id);
 reg[123:0] x;begin x=0;x[4:0]=1;x[39:37]=d;x[36:5]=32'ha0000+id*64;x[53:42]=id%4096;x[85:54]=32'hb1a50000+id;x[103:86]=id;descriptor=x;end
endfunction
always @(negedge clk)if(random_drain)begin
 rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};ppu_inst_rdy=rng[7:0];
end
always @(posedge clk)begin
 cycle=cycle+1;if(cycle>20000)$fatal(1,"UNIT_TIMEOUT");
 if(rst_n)begin
  if(inst_vld&&inst_rdy&&inst[4:0]==1)begin
   lane=inst[39:37];expected[lane][accepts[lane]]={inst[103:86],inst[85:54],inst[53:42],inst[36:5]};accepts[lane]=accepts[lane]+1;
  end
  for(integer d=0;d<8;d=d+1)begin
   if(dut.v_wr_en[d]&&dut.inst_fifo_full[d])begin
    if(test_id==1&&accepts[d]==33&&stores[d]==32&&reads[d]==0)$fatal(1,"EXPECTED_OLD_DESCRIPTOR_DROP lane=%0d accepted=33 stored=32 read=0",d);
    $fatal(1,"UNIT_WRITE_WHILE_FULL lane=%0d",d);
   end
   if(dut.v_wr_en[d])begin
    if(!(inst_vld&&inst_rdy&&inst[4:0]==1&&inst[39:37]==d))$fatal(1,"UNIT_UNQUALIFIED_WRITE");
    stores[d]=stores[d]+1;
   end
   if(ppu_inst_vld[d]&&ppu_inst_rdy[d])begin
    if(reads[d]>=accepts[d]||ppu_inst[d*94+:94]!==expected[d][reads[d]])$fatal(1,"UNIT_ORDER_PAYLOAD lane=%0d index=%0d",d,reads[d]);
    reads[d]=reads[d]+1;
   end
   if(stores[d]-reads[d]>highwater[d])highwater[d]=stores[d]-reads[d];
  end
  if(inst_vld&&inst_rdy&&inst[4:0]==31&&test_id!=2)begin
   for(integer d=0;d<8;d=d+1)if(reads[d]!=accepts[d])$fatal(1,"UNIT_PREMATURE_SYNC_ACCEPT");
   if(ppu_status!=255||dut.cmd_cnt_gp0!=0||dut.cmd_cnt_gp1!=0||cmd_en_gp0||cmd_en_gp1||dut.dma_fifo_empty!=255||o_cmd_en_gp0||o_cmd_en_gp1)$fatal(1,"UNIT_SYNC_ACTIVE_WORK");
  end
  if(ppu_status_en)begin sync_count=sync_count+1;if(ppu_status_tag!=8'ha7)$fatal(1,"UNIT_SYNC_TAG");end
 end
end
task automatic reset_all;
 begin @(negedge clk);rst_n=0;inst_vld=0;inst=0;random_drain=0;ppu_inst_rdy=0;ppu_status=255;cmd_en_gp0=0;cmd_en_gp1=0;gp0_status_en=0;gp1_status_en=0;
 repeat(3)@(negedge clk);for(integer d=0;d<8;d=d+1)begin accepts[d]=0;stores[d]=0;reads[d]=0;highwater[d]=0;end sync_count=0;rst_n=1;@(negedge clk);
 if(ppu_inst_vld||ppu_status_en||cfg_out_zp||cfg_bias_enable)$fatal(1,"UNIT_RESET_GHOST");end
endtask
task automatic send(input[123:0] x);
 integer waitn;begin @(negedge clk);inst=x;inst_vld=1;waitn=0;@(posedge clk);
 while(!inst_rdy)begin waitn=waitn+1;if(waitn>1000)$fatal(1,"UNIT_SEND_TIMEOUT");@(posedge clk);end
 @(negedge clk);inst_vld=0;end
endtask
task automatic drain;
 begin random_drain=0;@(negedge clk);ppu_inst_rdy=255;repeat(40)@(negedge clk);ppu_inst_rdy=0;
 for(integer d=0;d<8;d=d+1)if(accepts[d]!=stores[d]||stores[d]!=reads[d])$fatal(1,"UNIT_COUNT_MISMATCH");end
endtask
task automatic sync_once;
 reg[123:0] s;begin s=0;s[4:0]=31;s[5]=1;s[123:116]=8'ha7;send(s);repeat(5)@(negedge clk);if(sync_count!=1)$fatal(1,"UNIT_SYNC_RESPONSE_COUNT count=%0d",sync_count);end
endtask
initial begin
 if(!$value$plusargs("test=%d",test_id))test_id=0;
 reset_all();
 if(test_id==1)begin for(i=0;i<33;i=i+1)send(descriptor(7,i));$fatal(1,"OLD_DROP_NOT_REPRODUCED");end
 if(test_id==2)begin
  send(descriptor(0,17));inst=0;inst[4:0]=31;inst[5]=1;inst[123:116]=8'ha7;inst_vld=1;
  @(posedge clk);if(!inst_rdy||dut.inst_fifo_empty==255)$fatal(1,"OLD_SYNC_NOT_REPRODUCED");
  @(negedge clk);inst_vld=0;repeat(4)@(negedge clk);
  if(sync_count==1&&reads[0]==0&&stores[0]==1&&dut.inst_fifo_empty!=255)$fatal(1,"EXPECTED_OLD_PREMATURE_SYNC pending=1 reads=0 responses=1");
  $fatal(1,"OLD_SYNC_WRONG_FAILURE");
 end
 // Fill 31, then32, then held33 at each lane; unrelated lane and CFG remain available.
 for(n=0;n<8;n=n+1)begin
  reset_all();for(i=0;i<31;i=i+1)send(descriptor(n,100*n+i));
  if(highwater[n]!=31)$fatal(1,"UNIT_DEPTH31");send(descriptor(n,100*n+31));
  if(highwater[n]!=32||!dut.inst_fifo_full[n])$fatal(1,"UNIT_DEPTH32");
  send(descriptor((n+1)%8,1000+n));send(124'h00000000000000000000000000007e0);
  if(cfg_out_zp!=0||!cfg_bias_enable)$fatal(1,"UNIT_CFG");
  @(negedge clk);inst=descriptor(n,100*n+32);inst_vld=1;
  repeat(4)begin @(posedge clk);if(inst_rdy)$fatal(1,"UNIT_FULL_DID_NOT_STALL");@(negedge clk);end
  ppu_inst_rdy=1<<n;@(posedge clk);if(inst_rdy)$fatal(1,"UNIT_FULL_READ_CONSERVATIVE");
  @(negedge clk);ppu_inst_rdy=0;@(posedge clk);if(!inst_rdy)$fatal(1,"UNIT_NO_SPACE_READY");
  @(negedge clk);inst_vld=0;repeat(3)@(negedge clk);drain();sync_once();
 end
 reset_all();random_drain=1;
 for(i=0;i<700;i=i+1)send(descriptor((i*5)%8,i+2000));
 drain();sync_once();
 // SYNC held through pending descriptor, worker activity, generated command and DMA response.
 reset_all();send(descriptor(3,42));@(negedge clk);inst=0;inst[4:0]=31;inst[5]=1;inst[123:116]=8'ha7;inst_vld=1;
 repeat(3)begin @(posedge clk);if(inst_rdy)$fatal(1,"UNIT_SYNC_PENDING");@(negedge clk);end
 ppu_status[3]=0;ppu_inst_rdy[3]=1;@(negedge clk);ppu_inst_rdy=0;
 repeat(3)begin @(posedge clk);if(inst_rdy)$fatal(1,"UNIT_SYNC_WORKER");@(negedge clk);end
 cmd_en_gp0=8;cmd_addr_gp0[96+:32]=32'ha0400;cmd_data_num_gp0[39+:13]=4;
 @(negedge clk);cmd_en_gp0=0;
 while(!o_cmd_en_gp0)@(negedge clk);
 @(negedge clk);ppu_status=255;
 repeat(4)begin @(posedge clk);if(inst_rdy)$fatal(1,"UNIT_SYNC_DMA");@(negedge clk);end
 gp0_status_en=1;@(negedge clk);gp0_status_en=0;
 @(posedge clk);if(!inst_rdy)$fatal(1,"UNIT_SYNC_DRAIN_READY");@(negedge clk);inst_vld=0;
 repeat(5)@(negedge clk);if(sync_count!=1)$fatal(1,"UNIT_SYNC_DRAIN_RESPONSE");
 // Reset pending/full and reset after accepted SYNC; fresh descriptor proves restart.
 reset_all();for(i=0;i<32;i=i+1)send(descriptor(0,i));reset_all();
 send(descriptor(7,321));reset_all();
 inst=0;inst[4:0]=31;inst[5]=1;inst[123:116]=8'ha7;inst_vld=1;@(posedge clk);@(negedge clk);rst_n=0;inst_vld=0;reset_all();
 send(descriptor(2,999));drain();sync_once();
 // Invalid valid-low displayed descriptor, then unknown opcode valid-high: no descriptor write.
 @(negedge clk);inst=descriptor(1,900);inst_vld=0;repeat(3)@(negedge clk);send(124'd9);
 repeat(4)@(negedge clk);if(accepts[1]!=0||stores[1]!=0)$fatal(1,"UNIT_INVALID_WRITE");
 $display("PPU_DESCRIPTOR_UNIT_PASS all_lanes=8 randomized=700 full=32 sync_reset=1");$finish;
end
endmodule
