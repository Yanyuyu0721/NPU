from pathlib import Path
import re,json,hashlib,subprocess,sys
H=Path(__file__).resolve().parent
oldmem=H/'image_demo1/initial_firmware_itcm.mem'
dump=(H/'itcm_dump.txt').read_text()
planes={}
for block in dump.split('CELL ')[1:]:
 name=block.splitlines()[0]
 m=re.fullmatch(r'u_system/u_itcm/banked_storage/mem_reg_(\d+)_0_(\d+)',name)
 assert m,name
 bit=int(m[1])*8+int(m[2]);assert bit not in planes
 props={int(k,16):int(v,16)for k,v in re.findall(r"^INIT_([0-9A-F]{2}) 256'h([0-9A-Fa-f]{64})$",block,re.M)}
 assert len(props)==128,(name,len(props))
 planes[bit]=(name,props)
assert set(planes)==set(range(32))
oldwords=[int(w,16)for w in oldmem.read_text().split()]
for address,expected in enumerate(oldwords):
 actual=sum(((planes[b][1][address//256]>>(address%256))&1)<<b for b in range(32))
 assert actual==expected,(address,hex(actual),hex(expected))
print('VERIFIED_ALL_24576_OLD_WORDS_MATCH_ROUTED_BRAM_INIT',flush=True)
newmem=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve();out.mkdir(exist_ok=False)
newwords=[int(w,16)for w in newmem.read_text().split()];assert len(newwords)==len(oldwords)
lines=['open_checkpoint {'+(H/'image_demo1/routed_50mhz.dcp').as_posix()+'}',
       'set changed 0']
count=0
for b,(name,props)in sorted(planes.items()):
 for index,old in props.items():
  new=old
  for k in range(256):
   addr=index*256+k
   if addr<len(newwords):new=(new&~(1<<k))|(((newwords[addr]>>b)&1)<<k)
  if new==old:continue
  key=f'INIT_{index:02X}';expected=f"256'h{old:064X}";value=f"256'h{new:064X}"
  lines+=['set c [get_cells {'+name+'}]',
          'if {[get_property '+key+' $c] ne "'+expected+'"} {error {BASE_INIT_CHANGED}}',
          'set_property '+key+' '+value+' $c',
          'if {[get_property '+key+' $c] ne "'+value+'"} {error {NEW_INIT_MISMATCH}}',
          'incr changed']
  count+=1
lines+=['if {$changed != '+str(count)+'} {error {COUNT_MISMATCH}}',
        'set f [open {'+(out/'updated_init.txt').as_posix()+'} w]',
        'foreach c [get_cells -hier -filter {REF_NAME =~ RAMB*}] {',
        ' if {[string match *itcm* $c]} {',
        '  puts $f "CELL $c"',
        '  foreach p [list_property $c] {if {[regexp {^INIT_[0-9A-F][0-9A-F]$} $p]} {puts $f "$p [get_property $p $c]"}}',
        ' }',
        '}',
        'close $f',
        'write_checkpoint -force {'+(out/'routed_50mhz.dcp').as_posix()+'}',
        'write_bitstream -force {'+(out/'board_top.bit').as_posix()+'}',
        'puts ITCM_PATCH_VERIFIED_BIT_READY']
(out/'patch.tcl').write_text('\n'.join(lines)+'\n')
record=dict(scope='SAME_ROUTED_HARDWARE_ITCM_INIT_UPDATE',source_checkpoint=str(H/'image_demo1/routed_50mhz.dcp'),source_checkpoint_sha256=hashlib.sha256((H/'image_demo1/routed_50mhz.dcp').read_bytes()).hexdigest(),old_words_verified=len(oldwords),changed_init_properties=count,firmware_itcm_sha256=hashlib.sha256(newmem.read_bytes()).hexdigest(),timing_50mhz_met=True,sta=json.loads((H/'image_demo1/result.json').read_text())['sta'])
cmd=[r'D:\Xlinx\Vivado\2018.2\bin\vivado.bat','-mode','batch','-source',str(out/'patch.tcl'),'-log',str(out/'build.log'),'-journal',str(out/'build.jou')]
with(out/'stdout.log').open('wb')as f:
 p=subprocess.Popen(cmd,cwd=out,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
 record['pid']=p.pid;(out/'result.json').write_text(json.dumps(record,indent=2))
 code=p.wait(600)
assert code==0 and 'ITCM_PATCH_VERIFIED_BIT_READY'in(out/'build.log').read_text(),out/'build.log'
verified={}
for block in (out/'updated_init.txt').read_text().split('CELL ')[1:]:
 m=re.fullmatch(r'u_system/u_itcm/banked_storage/mem_reg_(\d+)_0_(\d+)',block.splitlines()[0]);assert m
 b=int(m[1])*8+int(m[2]);assert b not in verified
 verified[b]={int(k,16):int(v,16)for k,v in re.findall(r"^INIT_([0-9A-F]{2}) 256'h([0-9A-Fa-f]{64})$",block,re.M)}
 assert len(verified[b])==128
assert set(verified)==set(range(32))
for addr,expected in enumerate(newwords):
 actual=sum(((verified[b][addr//256]>>(addr%256))&1)<<b for b in range(32))
 assert actual==expected,('NEW_INIT_WORD',addr,hex(actual),hex(expected))
record['new_words_verified']=len(newwords)
record.update(verdict='ITCM_UPDATED_NOT_BOARD_TESTED',bit_sha256=hashlib.sha256((out/'board_top.bit').read_bytes()).hexdigest(),bit_file=str(out/'board_top.bit'))
(out/'result.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2))
