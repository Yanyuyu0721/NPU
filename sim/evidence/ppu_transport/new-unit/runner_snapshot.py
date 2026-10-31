"""Root-owned XSim runner. --preflight-only never launches EDA."""
from pathlib import Path
import argparse,datetime,json,os,re,shutil,subprocess,time
from binding import P,ASSETS,sha,inspect,need

def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def hashes(p):return {f.relative_to(p).as_posix():sha(f)for f in p.rglob('*')if f.is_file()}
def execute(cmd,out,label,timeout,rec):
 cmd=list(map(str,cmd));start=time.monotonic()
 with(out/(label+'.log')).open('w')as stream:
  proc=subprocess.Popen(cmd,cwd=out,stdout=stream,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
  save(out/'running.json',dict(pid=proc.pid,command=cmd,stage=label))
  try:rc=proc.wait(timeout)
  except subprocess.TimeoutExpired:subprocess.run(['taskkill','/PID',str(proc.pid),'/T','/F'],capture_output=True);proc.wait();rc=124
 rec['commands'].append(dict(command=cmd,exit=rc,seconds=time.monotonic()-start));save(out/'result.json',rec)
 return rc,(out/(label+'.log')).read_text(errors='replace')
def run(a):
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);src=out/'source';src.mkdir();rec=dict(case=a.case,verdict='INCOMPLETE',scope='SIMULATION_ONLY',commands=[])
 try:
  pin=json.loads((P/'inputs_pin.json').read_text())
  for n,h in pin.items():need(sha(P/n)==h,'pinned source '+n)
  old=a.case.startswith('old-');unit=a.case in ('old-drop','old-sync','new-unit')
  if unit:
   sources=['src/rtl/common_cells/fifo/gnrl_dfflr.v','src/rtl/common_cells/fifo/syncfifo.v','src/rtl/common_cells/arbiter/round_robin_arbiter.v','src/rtl/post_processing_unit/ppu_control.v','tb_ppu_descriptor.sv'];inc=[];defines=[];top='tb_ppu_descriptor';plus=['--testplusarg test='+str({'old-drop':1,'old-sync':2,'new-unit':0}[a.case])];cap=20000
  else:
   rec['build_binding']=inspect(a.firmware);cfg=json.loads((P/'rtl/vcs_config.json').read_text());sources=cfg['sources'];inc=cfg['includes']+['.'];defines=cfg['defines'];top='tb_system';cap=a.max_cycles
   need(0<cap<=100000000 and 0<a.wall_timeout<=7200,'native root cap')
   fw=a.firmware.resolve()
   for n in ASSETS:shutil.copy2(fw/n,out/n)
   shutil.copy2(fw/'firmware.elf',out/'firmware.elf');shutil.copy2(fw/'result.json',out/'firmware_build.json');shutil.copytree(fw/'source',out/'firmware_source')
   shutil.copy2(P/'tests/transport_monitor.vh',src/'transport_monitor.vh')
   f=json.loads((P/'tests/fixture/fixture.json').read_text());plus=['--testplusarg fixture_p=1','--testplusarg fixture_co=1000','--testplusarg fixture_input=256','--testplusarg fixture_k=256','--testplusarg fixture_model='+str(f['model_bytes'])]
  for n in sources:
   origin=P/'rtl'/n
   if n.endswith('ppu_control.v')and old:origin=P/'tests/ppu_control_old.v'
   if n.endswith('tb_vex_network.sv'):origin=P/'tests/tb_classifier.sv'
   if n=='tb_ppu_descriptor.sv':origin=P/'tests'/n
   target=src/n;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(origin,target)
  for n in inc:
   for f in(P/'rtl'/n).glob('*.vh'):
    target=src/n/f.name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,target)
  for n in ('inputs_pin.json','expected_build.json'):shutil.copy2(P/n,out/n)
  shutil.copy2(Path(__file__),out/'runner_snapshot.py');shutil.copy2(P/'tools/binding.py',out/'binding_snapshot.py')
  rec['source_hashes']=hashes(src)
  rec['asset_hashes']={f.relative_to(out).as_posix():sha(f)for f in out.rglob('*')if f.is_file()and not f.is_relative_to(src)}
  args=['--sv','--work work','--log xvlog.log']+['--define '+x for x in defines]+['--include "'+(src/n).as_posix()+'"'for n in inc]+['"'+(src/n).as_posix()+'"'for n in sources]
  (out/'xvlog.args').write_text('\n'.join(args)+'\n');(out/'run.tcl').write_text(f'run {cap*10+1000} ns\nquit\n')
  (out/'xsim.args').write_text('\n'.join(['--tclbatch "'+(out/'run.tcl').as_posix()+'"','--onerror quit','--onfinish quit',*plus,'--testplusarg max_cycles='+str(cap),'--log xsim.log'])+'\n')
  if a.preflight_only:rec['verdict']='PREFLIGHT_ONLY';save(out/'result.json',rec);print('PREFLIGHT_ONLY no EDA launched');return 0
  tool=lambda n:a.vivado/'bin'/(n+'.bat')
  for n in ('xvlog','xelab','xsim'):
   need(tool(n).is_file(),'tool path '+str(tool(n)));rc,text=execute([tool(n),'--version'],out,n+'_version',30,rec);need(rc==0 and '2026.1'in text,'tool version')
  rc,text=execute([tool('xvlog'),'--file',out/'xvlog.args'],out,'compile',180,rec);need(rc==0,'compile')
  rc,text=execute([tool('xelab'),'work.'+top,'--snapshot','ppu_transport','--timescale','1ns/1ps','--debug','off','--mt','2'],out,'elaborate',180,rec);need(rc==0,'elaborate')
  need(hashes(src)==rec['source_hashes'],'snapshot pre-run drift')
  for n,h in rec['asset_hashes'].items():need(sha(out/n)==h,'asset pre-run drift '+n)
  rc,text=execute([tool('xsim'),'ppu_transport','--file',out/'xsim.args'],out,'simulate',180 if unit else a.wall_timeout,rec)
  need(hashes(src)==rec['source_hashes'],'snapshot post-run drift')
  for n,h in rec['asset_hashes'].items():need(sha(out/n)==h,'asset post-run drift '+n)
  negatives={'old-drop':'EXPECTED_OLD_DESCRIPTOR_DROP lane=7 accepted=33 stored=32 read=0','old-sync':'EXPECTED_OLD_PREMATURE_SYNC pending=1 reads=0 responses=1','old-native':'EXPECTED_OLD_NATIVE_DESCRIPTOR_DROP'}
  if a.case in negatives:
   marker=negatives[a.case];need(marker in text and 'PPU_DESCRIPTOR_UNIT_PASS'not in text and 'CLASSIFIER_TRANSPORT_PASS'not in text and 'TIMEOUT'not in text and rc!=124,'exact expected negative cause absent')
   if a.case=='old-native':
    rows=re.findall(r'TRANSPORT_DESCRIPTOR_LOSS call=(\d+) lane=(\d+) accepted=(\d+) stored=(\d+) read=(\d+) high=(\d+)',text);need(len(rows)==1,'specific drop evidence absent');r=list(map(int,rows[0]));need(r[2]==r[3]+1 and r[3]-r[4]==32 and r[5]==32,'actual full/drop count relation');rec['descriptor_loss']=r
   rec['verdict']='EXPECTED_NEGATIVE_CONFIRMED'
  else:
   marker='PPU_DESCRIPTOR_UNIT_PASS'if unit else'CLASSIFIER_TRANSPORT_PASS';need(rc==0 and text.count(marker)==1 and not re.search(r'Fatal:|FATAL:|ERROR:|TIMEOUT',text),'clean terminal success absent')
   if not unit:
    rows=re.findall(r'CLASSIFIER_RESULT co=(\d+) mode=(\d+) hot=(\d+) cycles=(\d+) reads=(\d+) windows=(\d+) irqs=(\d+)',text)
    need(len(rows)==6 and [(int(r[0]),int(r[1]),int(r[2]))for r in rows]==[(co,2,h)for co in (256,264,1000)for h in (0,1)],'six exact real calls')
    need(text.count('TRANSPORT_IRQ_RAW_PASS')==6 and text.count('TRANSPORT_LANE')==48,'IRQ numerical/counter proof');rec['results']=rows
   rec['verdict']='PASS'
 except Exception as e:rec['verdict']='FAIL_OR_REJECTED';rec['error']=repr(e)
 rec['finished_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();save(out/'result.json',rec);print(json.dumps({k:v for k,v in rec.items()if k not in ('commands','source_hashes','asset_hashes','build_binding')},indent=2));return 0 if rec['verdict']in ('PASS','EXPECTED_NEGATIVE_CONFIRMED')else 1
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--case',choices=('old-drop','old-sync','new-unit','old-native','new-native'),required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--firmware',type=Path,default=P/'evidence/build_v2');ap.add_argument('--preflight-only',action='store_true');ap.add_argument('--vivado',type=Path,default=Path('E:/vivado2026/2026.1/Vivado'));ap.add_argument('--max-cycles',type=int,default=100000000);ap.add_argument('--wall-timeout',type=int,default=7200);raise SystemExit(run(ap.parse_args()))
