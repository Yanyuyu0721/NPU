`timescale 1ns/1ps
module tb_exact;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,bias_enable=1,rescale_enable=1,actfunc_enable=1;
reg[2:0]actfunc_type=7;reg[8:0]out_zp;reg[15:0]exact_outscale;
wire data_rdy,cmd_rdy,status;reg data_vld=0,cmd_vld=0;reg[31:0]data;
reg[112:0]cmd;wire bus_data_vld,cmd_en;wire[63:0]bus_data;wire[31:0]cmd_addr;wire[12:0]cmd_data_num;
ppu dut(.*);
reg[31:0]iv[0:56666-1],ev[0:56666-1];
integer f,scan,t,d,r,s,z,b,a,n,m,i,offset=0,received=0,bytes=0,word_index=0,commands=0,cycle=0;
reg[63:0]expected_bus;integer got,valid_samples;
always@(posedge clk)begin cycle=cycle+1;if(cycle>1000000)$fatal(1,"TIMEOUT");end
always@(negedge clk)begin
 if(rst_n&&bus_data_vld)begin
  valid_samples=n-received;if(valid_samples>(m==0?2:8))valid_samples=m==0?2:8;
  expected_bus=0;
  for(integer j=0;j<valid_samples;j=j+1)begin
   if(m==0)expected_bus[j*32+:32]=ev[offset+received+j];else expected_bus[j*8+:8]=ev[offset+received+j][7:0];
  end
  if(bus_data!==expected_bus)$fatal(1,"EXACT_MISMATCH task=%0d mode=%0d sample=%0d got=%h expected=%h",t,m,received,bus_data,expected_bus);
  received=received+valid_samples;
 end
 if(rst_n&&cmd_en)begin
  if(cmd_addr!==32'h1000||cmd_data_num!==n*(m==0?4:1))$fatal(1,"DMA_DESCRIPTOR_MISMATCH");
  commands=commands+1;
 end
end
initial begin
 $readmemh("input.mem",iv);$readmemh("expected.mem",ev);f=$fopen("tasks.txt","r");
 repeat(4)@(negedge clk);rst_n=1;
 for(t=0;t<1290;t=t+1)begin
  scan=$fscanf(f,"%h %h %h %h %h %h %h %h\n",d,r,s,z,b,a,n,m);if(scan!=8)$fatal(1,"TASK_READ");
  received=0;commands=0;rescale_enable=(m!=0);actfunc_enable=a;actfunc_type=m==1?7:0;out_zp=z;exact_outscale=s;
  while(!cmd_rdy)@(negedge clk);
  cmd={m==1?{r[20:0],d[15:0]}:{19'd0,d[17:0]},b[31:0],12'(n-1),32'h1000};cmd_vld=1;
  @(negedge clk);cmd_vld=0;
  for(i=0;i<n;i=i+1)begin
   while(!data_rdy)@(negedge clk);
   data=iv[offset+i];data_vld=1;@(negedge clk);data_vld=0;
   if(i%11==3)repeat(2)@(negedge clk);
  end
  while(received<n||!status)@(negedge clk);
  repeat(2)@(negedge clk);if(commands!=1)$fatal(1,"COMMAND_COUNT");offset=offset+n;
 end
 $display("EXACT_PPU_PASS tasks=%0d samples=%0d",1290,56666);$finish;
end
endmodule
