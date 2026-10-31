from pathlib import Path
import hashlib,json,random,struct,subprocess,time
H=Path(__file__).resolve().parent;D=H/'unit_exact'
attempt=1
while D.exists():attempt+=1;D=H/f'unit_exact{attempt}'
D.mkdir()
c=json.loads((H/'model_contract.json').read_text(encoding='utf-8'));rng=random.Random(0x20261029)
i32=lambda x:(x+2**31)%2**32-2**31
def truncdiv(n,d):return (abs(n)//d)*(-1 if n<0 else 1)
tasks=[];inputs=[];expected=[]
for layer in c['layers']:
 if layer['type']!=0:continue
 for ws in layer['weight_scales']:
  d=int(1.0/ws/layer['input_scale']);scale=int(struct.unpack('<f',struct.pack('<f',256/layer['output_scale']))[0]);recip=(2**32+d-1)//d
  assert 2049<=d<=65535 and recip<2**21
  for act in(0,1):
   for length in(1,7,8,9,169):tasks.append((d,recip,scale,-128,rng.randrange(-2**31,2**31),act,length,1))
# Random denominators plus bypass and legacy rounded Q16 coverage.
for n in range(130):
 mode=0 if n<10 else 2 if n<20 else 1
 d=rng.randrange(2049,65536);recip=(2**32+d-1)//d
 tasks.append((d,recip,rng.randrange(1,65536),rng.randrange(-256,256),rng.randrange(-2**31,2**31),n&1,rng.randrange(1,182),mode))
for d,r,scale,zp,bias,act,n,mode in tasks:
 for i in range(n):
  x=[0,1,-1,0x7fffffff,-0x80000000,0x7fffff,-0x800000,d//256,d//256+1][i]if i<9 else rng.randrange(-2**31,2**31)
  inputs.append(x&0xffffffff);acc=i32(x+bias)
  if mode==1:
   q=truncdiv(i32(acc<<8),d);q=max(0,q)if act else q
   out=((i32(q*scale)>>16)+zp)&255
  elif mode==0:out=(max(0,x+bias)if act else x+bias)&0xffffffff
  else:
   # Existing datapath keeps signed 33-bit bias sum then ReLU, round Q16.
   v=x+bias;v=max(0,v)if act else v
   out=max(-128,min(127,((v*d+32768)>>16)+zp))&255
  expected.append(out)
(D/'input.mem').write_text(''.join(f'{x:08x}\n'for x in inputs));(D/'expected.mem').write_text(''.join(f'{x:08x}\n'for x in expected))
(D/'tasks.txt').write_text(''.join(f'{d:x} {r:x} {s:x} {z&511:x} {b&0xffffffff:x} {a:x} {n:x} {m:x}\n'for d,r,s,z,b,a,n,m in tasks))
tb=r'''`timescale 1ns/1ps
module tb_exact;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,bias_enable=1,rescale_enable=1,actfunc_enable=1;
reg[2:0]actfunc_type=7;reg[8:0]out_zp;reg[15:0]exact_outscale;
wire data_rdy,cmd_rdy,status;reg data_vld=0,cmd_vld=0;reg[31:0]data;
reg[112:0]cmd;wire bus_data_vld,cmd_en;wire[63:0]bus_data;wire[31:0]cmd_addr;wire[12:0]cmd_data_num;
ppu dut(.*);
reg[31:0]iv[0:TOTAL-1],ev[0:TOTAL-1];
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
 for(t=0;t<TASKS;t=t+1)begin
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
 $display("EXACT_PPU_PASS tasks=%0d samples=%0d",TASKS,TOTAL);$finish;
end
endmodule
'''.replace('TOTAL',str(len(inputs))).replace('TASKS',str(len(tasks)))
(D/'tb_exact.sv').write_text(tb);(D/'run.tcl').write_text('run all\nquit\n')
root=Path(r'D:\Xlinx\Vivado\2018.2\bin');commands=[['xvlog.bat','--sv',str(H/'rtl_override/src/rtl/post_processing_unit/ppu.v'),str(D/'tb_exact.sv')],['xelab.bat','tb_exact','-s','exact_sim','--timescale','1ns/1ps'],['xsim.bat','exact_sim','-tclbatch','run.tcl']]
record=dict(passed=False,tasks=len(tasks),samples=len(inputs),commands=[])
for i,cmd in enumerate(commands):
 cmd[0]=str(root/cmd[0]);result=subprocess.run(cmd,cwd=D,capture_output=True,creationflags=subprocess.CREATE_NO_WINDOW)
 (D/f'step{i}.log').write_bytes(result.stdout+result.stderr);record['commands'].append(dict(command=cmd,exit=result.returncode))
 if result.returncode:print((result.stdout+result.stderr).decode(errors='replace'));break
else:record['passed']='EXACT_PPU_PASS'in(D/'step2.log').read_text(errors='replace')
(D/'result.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2));assert record['passed']
