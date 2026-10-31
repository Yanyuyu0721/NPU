"""Strict current source, compiler, ELF and complete RAM binding; host only."""
from pathlib import Path
import hashlib,json,struct
P=Path(__file__).resolve().parents[1]
ASSETS=('firmware.verilog','shared.mem','fixture.json','input.mem','raw.mem','output.mem','model.mem')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def need(ok,message):
 if not ok:raise ValueError('BIND_REJECTED: '+message)
def sections_and_symbols(elf):
 need(elf[:6]==b'\x7fELF\x01\x01','ELF32 LE')
 off=struct.unpack_from('<I',elf,32)[0];entry,count,strings=struct.unpack_from('<HHH',elf,46)
 need(entry==40 and off+entry*count<=len(elf),'ELF table bounds');hs=[struct.unpack_from('<10I',elf,off+i*entry)for i in range(count)]
 h=hs[strings];names=elf[h[4]:h[4]+h[5]]
 def name(data,at):return data[at:data.index(b'\0',at)].decode()
 ss={name(names,h[0]):dict(type=h[1],address=h[3],data=elf[h[4]:h[4]+h[5]],size=h[5])for h in hs};sy={}
 for h in hs:
  if h[1]!=2:continue
  t=hs[h[6]];st=elf[t[4]:t[4]+t[5]];need(h[9]==16,'symbol entry')
  for at in range(h[4],h[4]+h[5],16):
   n,v,size,info,other,index=struct.unpack_from('<IIIBBH',elf,at)
   if n:sy[name(st,n)]=(v,size)
 return ss,sy

def generated(text):return text.replace('\r\n','\n').replace('\n','\r\n').encode()
def expected_sources():
 expected={}
 for sub in ('common','vex_port'):
  for f in(P/'candidate'/sub).rglob('*'):
   if f.is_file():expected[sub+'/'+f.relative_to(P/'candidate'/sub).as_posix()]=f.read_bytes()
 expected['vex_port/main.c']=(P/'tests/probe_main.c').read_bytes()
 model=P/'candidate/models/mobilenetv1.h';expected['original_model.h']=model.read_bytes()
 expected['vex_port/model_blob.h']=generated(model.read_text().replace('const uint8_t mdl_data[','const uint8_t __attribute__((section(".model"),aligned(64))) mdl_data['))
 vals=dict(LAYER_OFFSET=231808,LAYER_ID=29,MODEL_ID=7,H=1,W=1,OH=1,OW=1)
 expected['vex_port/probe_config.h']=generated('\n'.join(f'#define PROBE_{k} {v}U'for k,v in vals.items())+'\n')
 return expected

def inspect(fw, frozen=True):
 fw=Path(fw).resolve();receipt=json.loads((fw/'result.json').read_text());expected=expected_sources()
 actual={f.relative_to(fw/'source').as_posix():f for f in(fw/'source').rglob('*')if f.is_file()}
 need(set(actual)==set(expected),'current source set')
 for n,b in expected.items():need(actual[n].read_bytes()==b and receipt['source_hashes'].get(n)==hashlib.sha256(b).hexdigest(),'current source '+n)
 need(set(receipt['source_hashes'])==set(expected),'receipt source set')
 need(receipt.get('task')=='classifier_transport'and receipt.get('firmware_build_passed') is True,'build identity')
 need(sha(fw/'firmware.elf')==receipt['firmware_sha256'],'ELF receipt')
 need(set(receipt['runtime_asset_hashes'])==set(ASSETS),'asset set')
 for n in ASSETS:
  need(sha(fw/n)==receipt['runtime_asset_hashes'][n],'asset receipt '+n)
  if n not in ('firmware.verilog','shared.mem'):need((fw/n).read_bytes()==(P/'tests/fixture'/n).read_bytes(),'current fixture '+n)
 ss,sy=sections_and_symbols((fw/'firmware.elf').read_bytes());ram=bytearray(1048576)
 end=max(s['address']+s['size']-0x80000000 for n,s in ss.items()if n in ('.text','.rodata'));need(0<end<=98304,'ITCM capacity');itcm=bytearray(end)
 for n,s in ss.items():
  if s['type']==8 or not s['size']:continue
  if n in ('.text','.rodata'):
   start=s['address']-0x80000000;need(start>=0 and start+s['size']<=end,'ITCM bounds');itcm[start:start+s['size']]=s['data']
  elif n in ('.model','.data'):
   start=s['address']-0xa0000000;need(start>=0 and start+s['size']<=0xa0000,'RAM load bounds');ram[start:start+s['size']]=s['data']
 actual_ram=b''.join(int(x,16).to_bytes(8,'little')for x in(fw/'shared.mem').read_text().split())
 actual_itcm=bytes(int(x,16)for x in(fw/'firmware.verilog').read_text().split())
 need(actual_ram==ram,'FULL_RAM_FROM_ELF_ZERO_SLACK');need(actual_itcm==itcm,'FULL_ITCM_FROM_ELF_ZERO_GAPS')
 model=bytes(int(x,16)for x in(P/'tests/fixture/model.mem').read_text().split());need(ss['.model']['address']==0xa0000000 and ss['.model']['data']==model,'original model ELF section')
 graph,size=sy['graph'];need(size==32768 and graph>=0xa0080000 and graph+size<0xa00a0000-64,'graph profile');need(sy['_bss_end'][0]<=0xa009ffc0 and sy['_stack_top'][0]==0xa00ffff0,'BSS stack profile')
 need(receipt['itcm_image_bytes']==end,'ITCM receipt')
 commands=[];tools={}
 for row in receipt['commands']:
  need(row['exit']==0,'build command failure');cmd=row['command'];exe=Path(cmd[0]);need(exe.is_file(),'compiler/tool missing');tools[str(exe)]=sha(exe)
  if row['name'].startswith('compile_') or row['name']=='link':
   need('-march=rv32im'in cmd and '-mabi=ilp32'in cmd and '-DEDGE_VEX_IMAGE_SIM=1'in cmd and '-DEDGE_VEX_EURO_PROFILE=1'not in cmd,'compile profile')
  if row['name']=='link':
   for arg in cmd:
    if arg.endswith('.a') and Path(arg).is_file():tools[arg]=sha(Path(arg))
  commands.append(dict(name=row['name'],exit=0,command=[x.replace(str(fw),'${BUILD}')for x in cmd]))
 proof=dict(source_hashes=receipt['source_hashes'],elf_sha256=sha(fw/'firmware.elf'),assets={n:sha(fw/n)for n in ASSETS},commands=commands,tool_hashes=tools,toolchain_config_sha256=sha(P.parents[1]/'image_networks_20261026/build/toolchain_config.json'),itcm_bytes=end,ram_bytes=len(ram),model_bytes=len(model),graph_address=hex(graph),bss_end=hex(sy['_bss_end'][0]),full_ram_reconstructed=True)
 if frozen:need(proof==json.loads((P/'expected_build.json').read_text()),'frozen compiler/source/ELF/RAM build differs')
 return proof
if __name__=='__main__':
 import argparse
 ap=argparse.ArgumentParser();ap.add_argument('firmware',type=Path);ap.add_argument('--freeze',action='store_true');a=ap.parse_args();proof=inspect(a.firmware,not a.freeze)
 if a.freeze:(P/'expected_build.json').write_text(json.dumps(proof,indent=2))
 print(json.dumps({k:v for k,v in proof.items()if k not in ('source_hashes','assets','commands','tool_hashes')},indent=2))
