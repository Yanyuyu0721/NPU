from pathlib import Path
import hashlib,json,shutil,subprocess,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
SOURCE=HERE/'source'
from model_contract import verify_assets
verify_assets()
OUT=HERE/'firmware'
OUT.mkdir(exist_ok=True)
shutil.copy2(HERE/'main.c',SOURCE/'main.c')
GCC=Path(r'D:\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gcc.exe')
flags=['-march=rv32im','-mabi=ilp32','-O2','-g','-ffreestanding','-fno-builtin','-fno-common','-ffunction-sections','-fdata-sections','-fstack-usage','-msmall-data-limit=0','-fno-stack-protector','-I',str(SOURCE),'-DTM_NPU_PPU_EXACT=1','-DTM_NPU_CPU_COMPAT=1','-DBENCH_MODEL_ID=2']
record={'commands':[],'scope':'REAL_TINYMAIX_FIRMWARE_BUILD_NOT_BOARD_TEST'}
def run(name,cmd):
 result=subprocess.run(list(map(str,cmd)),cwd=OUT,capture_output=True)
 (OUT/(name+'.log')).write_bytes(result.stdout+result.stderr)
 record['commands'].append(dict(name=name,command=list(map(str,cmd)),exit=result.returncode))
 (OUT/'build.json').write_text(json.dumps(record,indent=2))
 if result.returncode:print((result.stdout+result.stderr).decode(errors='replace'));raise SystemExit(name+' failed')
units=['start.s','main.c','vex_hal.c','libc.c','tm_layers.c','tm_model.c','tiny_npu.c','npu_runtime.c','npu_views.c']
objects=[]
for unit in units:
 obj=OUT/(unit+'.o');run('compile_'+unit,[GCC,*flags,'-DNPU_PLATFORM=1','-c',SOURCE/unit,'-o',obj]);objects.append(obj)
obj=OUT/'tm_model_cpu.o';run('compile_cpu',[GCC,*flags,'-DNPU_PLATFORM=0','-Dtm_run=tm_run_cpu','-Dtm_load=tm_load_cpu','-Dtm_unload=tm_unload_cpu','-Dtm_preprocess=tm_preprocess_cpu','-c',SOURCE/'tm_model.c','-o',obj]);objects.append(obj)
run('link',[GCC,*flags,'-nostdlib','-nostartfiles','-Wl,--gc-sections,--no-relax,--build-id=none',f'-Wl,-Map={OUT/"firmware.map"}','-T',SOURCE/'linker.ld',*objects,'-lgcc','-o',OUT/'firmware.elf'])
run('objcopy',[GCC.with_name('riscv-none-elf-objcopy.exe'),'-O','binary',OUT/'firmware.elf',OUT/'firmware.bin'])
run('size',[GCC.with_name('riscv-none-elf-size.exe'),'-A',OUT/'firmware.elf'])
data=(OUT/'firmware.bin').read_bytes();assert len(data)<=98304
data+=bytes(98304-len(data));mem=OUT/'firmware_itcm.mem'
mem.write_bytes(''.join(f'{int.from_bytes(data[i:i+4],"little"):08X}\r\n'for i in range(0,len(data),4)).encode())
record.update(firmware_bin_bytes=(OUT/'firmware.bin').stat().st_size,firmware_itcm_sha256=hashlib.sha256(mem.read_bytes()).hexdigest(),source_hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in SOURCE.iterdir()if p.is_file()})
(OUT/'build.json').write_text(json.dumps(record,indent=2))
print((OUT/'size.log').read_text());print('FIRMWARE_OK',record['firmware_bin_bytes'],record['firmware_itcm_sha256'])
