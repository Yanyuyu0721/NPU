"""Pin the model, fixture, original CPU functions and independent baseline outputs."""
from pathlib import Path
import hashlib,json,re,subprocess
H=Path(__file__).resolve().parent;B=H.parent/'tm_optimized'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
MODEL='ccc3138779cc0475c5bccee25c9f5e0f1ddc2878d22ec675a0ccb14fd5ef7b37'
INPUT='63faecf9da6db4a2175ada6462a0f54dfd7da5b1995134b394cee18f0359ea2e'
def function(text,name):
    match=re.search(r'\b'+re.escape(name)+r'\s*\([^;{}]*\)\s*\{',text)
    assert match,('missing function',name)
    start=match.start();brace=text.index('{',match.start());depth=1;i=brace+1
    while depth:
        depth+=(text[i]=='{')-(text[i]=='}');i+=1
    return re.sub(r'\s+','',text[start:i])
def verify_assets(compiled=False):
    assert sha(H/'model.bin')==MODEL and sha(H/'input.bin')==INPUT,'model/input changed'
    for n in ['model_blob.h','fixture.h','identity.h','arch_cpu.h','libc.c','tm_port.h','start.s','linker.ld']:
        assert sha(H/'source'/n)==sha(B/'source'/n),('frozen source changed',n)
    for name in ['tml_conv2d_dwconv2d','tml_gap','tml_fc','tml_softmax']:
        assert function((H/'source/tm_layers.c').read_text(),name)==function((B/'source/tm_layers.c').read_text(),name),('CPU function changed',name)
    gcc=Path(r'D:\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gcc.exe')
    pp=[]
    for p in [B/'source',H/'source']:
        args=[str(gcc),'-E','-P','-march=rv32im','-mabi=ilp32','-DTM_NPU_CPU_COMPAT=1','-DNPU_PLATFORM=0','-I',str(p),str(p/'tm_model.c')]
        result=subprocess.run(args,capture_output=True);assert result.returncode==0,result.stderr
        pp.append(function(result.stdout.decode(),'tm_run'))
    assert pp[0]==pp[1],'preprocessed CPU inference path changed'
    original=json.loads((B/'board_demo1/result.json').read_text())['validation']
    oracle=json.loads((H/'baseline_oracle.json').read_text())
    for k in ['score_bits','layer_hashes','stress_inputs']:assert oracle[k]==original[k],('oracle changed',k)
    if compiled:
        build=json.loads((H/'firmware/build.json').read_text())
        for name,value in build['source_hashes'].items():assert sha(H/'source'/name)==value,('compiled source changed',name)
        binary=(H/'firmware/firmware.bin').read_bytes()
        assert binary.count((H/'model.bin').read_bytes())==1,'model binary missing'
        words=(H/'firmware/firmware_itcm.mem').read_text().split()
        data=b''.join(int(w,16).to_bytes(4,'little')for w in words)
        assert len(data)==98304 and data==binary+bytes(98304-len(binary)),'ITCM mismatch'
    return dict(passed=True,model_sha256=MODEL,input_sha256=INPUT,cpu_reference_unchanged=True)
if __name__=='__main__':print(json.dumps(verify_assets(compiled=True),indent=2))
