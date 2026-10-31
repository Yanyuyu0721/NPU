from pathlib import Path
import json,subprocess
H=Path(__file__).resolve().parent;ROOT=H.parents[3];D=H/'unit_descriptor'
attempt=1
while D.exists():attempt+=1;D=H/f'unit_descriptor{attempt}'
D.mkdir()
s=(ROOT/'sim/evidence/ppu_transport_sources/tests/tb_ppu_descriptor.sv').read_text()
s=s.replace('[751:0]','[903:0]').replace('[93:0]','[112:0]')
s=s.replace('d*94+:94','d*113+:113').replace('d*94 +: 94','d*113 +: 113')
s=s.replace('wire [8:0] cfg_out_zp;','wire [15:0] cfg_exact_outscale;wire [8:0] cfg_out_zp;')
s=s.replace('x[103:86]=id;','x[103:86]=id;x[122:104]=id*17+7;')
s=s.replace('{inst[103:86],inst[85:54],inst[53:42],inst[36:5]}','{inst[122:104],inst[103:86],inst[85:54],inst[53:42],inst[36:5]}')
s=s.replace('reset_all();\n if(test_id==1)', 'reset_all();\n inst=0;inst[35:20]=16\'hB7A9;inst[19:11]=9\'h180;send(inst);\n if(cfg_exact_outscale!==16\'hB7A9||cfg_out_zp!==9\'h180)$fatal(1,"EXACT_CFG_DECODE");\n reset_all();\n if(test_id==1)')
(D/'tb_descriptor.sv').write_text(s);(D/'run.tcl').write_text('run all\nquit\n')
rtl=H/'shadow/platform/rtl/src/rtl/common_cells/fifo';root=Path(r'D:\Xlinx\Vivado\2018.2\bin')
commands=[['xvlog.bat','--sv',str(rtl/'gnrl_dfflr.v'),str(rtl/'syncfifo.v'),str(rtl.parent/'arbiter/round_robin_arbiter.v'),str(H/'rtl_override/src/rtl/post_processing_unit/ppu_control.v'),str(D/'tb_descriptor.sv')],['xelab.bat','tb_ppu_descriptor','-s','descriptor','--timescale','1ns/1ps'],['xsim.bat','descriptor','-tclbatch','run.tcl']]
record=dict(passed=False,commands=[])
for i,cmd in enumerate(commands):
 cmd[0]=str(root/cmd[0]);r=subprocess.run(cmd,cwd=D,capture_output=True,creationflags=subprocess.CREATE_NO_WINDOW)
 (D/f'step{i}.log').write_bytes(r.stdout+r.stderr);record['commands'].append(dict(command=cmd,exit=r.returncode))
 if r.returncode:print((r.stdout+r.stderr).decode(errors='replace'));break
else:record['passed']='PPU_DESCRIPTOR_UNIT_PASS'in(D/'step2.log').read_text(errors='replace')
(D/'result.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2));assert record['passed']
