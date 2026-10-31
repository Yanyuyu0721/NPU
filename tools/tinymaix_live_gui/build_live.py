from pathlib import Path
import argparse,datetime,hashlib,json,os,shutil,subprocess,sys
H=Path(__file__).resolve().parent;R=H.parents[1]
GCC=Path(os.environ.get('TINYMAIX_GCC',r'D:\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gcc.exe'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def build(task,out=None):
 d=Path(out).resolve() if out else R/'build/out'/('live_'+task+'_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
 assert not d.exists(),'fresh output directory required'
 d.mkdir(parents=True)
 shutil.copytree(R/'src/software'/task,d/'source')
 for name in ('model.bin','input.bin','baseline.json'):shutil.copy2(H/'firmware'/task/name,d/name)
 s=d/'source';o=d/'build';o.mkdir()
 base=json.loads((d/'baseline.json').read_text());original=R/'build/out'/task/'tm_perf_v2'
 assert sha(d/'model.bin')==base['model_sha256']
 for p in s.iterdir():
  if p.is_file()and p.name!='main.c':assert sha(p)==base['source_hashes'][p.name],p
 shutil.copy2(H/'main_live.c',s/'main.c');tid=1 if task=='mnist'else 2
 flags=['-march=rv32im','-mabi=ilp32','-O2','-g','-ffreestanding','-fno-builtin','-fno-common','-ffunction-sections','-fdata-sections','-fstack-usage','-msmall-data-limit=0','-fno-stack-protector','-I',str(s),'-DTM_NPU_CPU_COMPAT=1','-DTM_NPU_PPU_EXACT=1',f'-DBENCH_MODEL_ID={tid}',f'-DLIVE_TASK={tid}']
 record=dict(scope='REAL_TINYMAIX_LIVE_INPUT_FIRMWARE_BUILD',task=task,model_sha256=base['model_sha256'],commands=[])
 def run(name,cmd):
  q=subprocess.run(list(map(str,cmd)),cwd=o,capture_output=True);(o/(name+'.log')).write_bytes(q.stdout+q.stderr)
  record['commands'].append(dict(command=list(map(str,cmd)),exit=q.returncode));assert q.returncode==0,(name,(q.stdout+q.stderr).decode(errors='replace'))
 objs=[]
 for n in ['start.s','main.c','vex_hal.c','libc.c','tm_layers.c','tm_model.c','tiny_npu.c','npu_runtime.c','npu_views.c']:
  obj=o/(n+'.o');run(n,[GCC,*flags,'-DNPU_PLATFORM=1','-c',s/n,'-o',obj]);objs.append(obj)
 obj=o/'tm_model_cpu.o';run('cpu',[GCC,*flags,'-DNPU_PLATFORM=0','-Dtm_run=tm_run_cpu','-Dtm_load=tm_load_cpu','-Dtm_unload=tm_unload_cpu','-Dtm_preprocess=tm_preprocess_cpu','-c',s/'tm_model.c','-o',obj]);objs.append(obj)
 run('link',[GCC,*flags,'-nostdlib','-nostartfiles','-Wl,--gc-sections,--no-relax,--build-id=none',f'-Wl,-Map={o/"firmware.map"}','-T',s/'linker.ld',*objs,'-lgcc','-o',o/'firmware.elf'])
 run('objcopy',[GCC.with_name('riscv-none-elf-objcopy.exe'),'-O','binary',o/'firmware.elf',o/'firmware.bin'])
 run('size',[GCC.with_name('riscv-none-elf-size.exe'),'-A',o/'firmware.elf'])
 data=(o/'firmware.bin').read_bytes();assert len(data)<=98304;data+=bytes(98304-len(data))
 mem=o/'firmware_itcm.mem';mem.write_bytes(''.join(f'{int.from_bytes(data[i:i+4],"little"):08X}\r\n'for i in range(0,len(data),4)).encode())
 record.update(firmware_bytes=(o/'firmware.bin').stat().st_size,firmware_mem_sha256=sha(mem),source_hashes={p.name:sha(p)for p in s.iterdir()if p.is_file()})
 (o/'result.json').write_text(json.dumps(record,indent=2));print(task,(o/'size.log').read_text(errors='replace'),flush=True)
 image=d/'image';assert not image.exists(),'fresh image output required'
 q=subprocess.run([sys.executable,str(original/'patch_itcm.py'),str(mem),str(image)],capture_output=True)
 (d/'patch.log').write_bytes(q.stdout+q.stderr);assert q.returncode==0,(d/'patch.log').read_text(errors='replace')
 print('LIVE_IMAGE_READY',task,sha(image/'board_top.bit'),flush=True)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('task',choices=['mnist','kws']);p.add_argument('--out',type=Path);a=p.parse_args();build(a.task,a.out)
