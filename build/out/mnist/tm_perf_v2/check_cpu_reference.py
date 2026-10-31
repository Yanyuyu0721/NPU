from pathlib import Path
import hashlib,json,re,subprocess
H=Path(__file__).resolve().parent;B=H.parent/'tm_ppu_exact'
def function(text,name):
    m=re.search(r'\b'+re.escape(name)+r'\s*\([^;{}]*\)\s*\{',text);assert m,name
    b=text.index('{',m.start());depth=1;i=b+1
    while depth:depth+=(text[i]=='{')-(text[i]=='}');i+=1
    return re.sub(r'\s+','',text[m.start():i])
def verify():
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    for n in ['arch_cpu.h','libc.c','tm_port.h','fixture.h','model_blob.h','start.s','linker.ld']:
        assert sha(H/'source'/n)==sha(B/'source'/n),n
    for n in ['tml_conv2d_dwconv2d','tml_gap','tml_fc','tml_softmax']:
        assert function((H/'source/tm_layers.c').read_text(),n)==function((B/'source/tm_layers.c').read_text(),n),n
    gcc=Path(r'D:\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gcc.exe');texts=[]
    for p in [B/'source',H/'source']:
        r=subprocess.run([str(gcc),'-E','-P','-march=rv32im','-mabi=ilp32','-DTM_NPU_CPU_COMPAT=1','-DNPU_PLATFORM=0','-I',str(p),str(p/'tm_model.c')],capture_output=True)
        assert r.returncode==0,r.stderr;texts.append(function(r.stdout.decode(),'tm_run'))
    assert texts[0]==texts[1],'CPU inference path changed'
    result=dict(passed=True,original_cpu_reference_unchanged=True)
    (H/'cpu_reference_check.json').write_text(json.dumps(result,indent=2));return result
if __name__=='__main__':print(verify())
