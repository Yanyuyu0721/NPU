from pathlib import Path
import datetime,hashlib,json,shutil,subprocess,time
H=Path(__file__).resolve().parent;OUT=H/'image_demo1';OUT.mkdir(exist_ok=False)
from model_contract import verify_assets
verify_assets(check_firmware=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
shutil.copy2(H/'firmware/firmware_itcm.mem',H/'shadow/platform/firmware_itcm.mem')
shutil.copy2(H/'firmware/firmware_itcm.mem',OUT/'initial_firmware_itcm.mem')
p=H/'shadow/build_2018_2.tcl';s=p.read_text();needle='write_checkpoint -force [file join $out routed_50mhz.dcp]'
assert needle in s
dump='''
    set f [open [file join $out initial_itcm.txt] w]
    foreach c [get_cells -hier -filter {REF_NAME =~ RAMB*}] {
        if {[string match *itcm* $c]} {
            puts $f "CELL $c"
            foreach p [list_property $c] {if {[regexp {^INIT_[0-9A-F][0-9A-F]$} $p]} {puts $f "$p [get_property $p $c]"}}
        }
    }
    close $f
'''
s=s.replace(needle,needle+dump);(OUT/'build_ppu.tcl').write_text(s)
# The original build locates its platform beside the Tcl script.
shutil.copy2(OUT/'build_ppu.tcl',H/'shadow/build_ppu.tcl')
cmd=[r'D:\Xlinx\Vivado\2018.2\bin\vivado.bat','-mode','batch','-source',str(H/'shadow/build_ppu.tcl'),'-log',str(OUT/'build.log'),'-journal',str(OUT/'build.jou'),'-tclargs',str(OUT),'xc7a100tfgg484-2',str(H/'rtl_override')]
record=dict(passed=False,scope='EXACT_TINYMAIX_PPU_NEW_ROUTED_HARDWARE_NOT_BOARD_TESTED',started=datetime.datetime.now().astimezone().isoformat(),command=cmd,firmware_itcm_sha256=sha(H/'firmware/firmware_itcm.mem'),rtl_override_sha256={str(p.relative_to(H/'rtl_override')):sha(p)for p in(H/'rtl_override').rglob('*')if p.is_file()})
start=time.monotonic()
with(OUT/'stdout.log').open('wb')as f:
 process=subprocess.Popen(cmd,cwd=OUT,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
 record['pid']=process.pid;(OUT/'result.json').write_text(json.dumps(record,indent=2));code=process.wait(3600)
record.update(exit=code,seconds=time.monotonic()-start,finished=datetime.datetime.now().astimezone().isoformat())
try:
 assert code==0 and 'PORT_BIT_READY'in(OUT/'stdout.log').read_text(errors='replace'),'hardware build failed'
 rows=[line.split()for line in(OUT/'timing_metrics.tsv').read_text().splitlines()[1:]]
 sta={mhz:dict(setup_ns=float(setup),hold_ns=float(hold))for mhz,period,setup,hold in rows}
 record.update(sta=sta,timing_50mhz_met=sta['50']['setup_ns']>=0 and sta['50']['hold_ns']>=0)
 assert record['timing_50mhz_met'],'50 MHz timing failed'
 # Verify all initialized ITCM words read back from the routed design.
 import re
 planes={}
 for block in(OUT/'initial_itcm.txt').read_text().split('CELL ')[1:]:
  m=re.fullmatch(r'u_system/u_itcm/banked_storage/mem_reg_(\d+)_0_(\d+)',block.splitlines()[0]);assert m
  bit=int(m[1])*8+int(m[2]);assert bit not in planes
  props={int(k,16):int(v,16)for k,v in re.findall(r"^INIT_([0-9A-F]{2}) 256'h([0-9A-Fa-f]{64})$",block,re.M)};assert len(props)==128;planes[bit]=props
 assert set(planes)==set(range(32))
 words=[int(x,16)for x in(OUT/'initial_firmware_itcm.mem').read_text().split()]
 for a,w in enumerate(words):assert sum(((planes[b][a//256]>>(a%256))&1)<<b for b in range(32))==w,('init',a)
 record.update(passed=True,bit_sha256=sha(OUT/'board_top.bit'),new_words_verified=len(words),routed_checkpoint_sha256=sha(OUT/'routed_50mhz.dcp'))
except Exception as exc:record['error']=repr(exc)
(OUT/'result.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2));assert record['passed']
