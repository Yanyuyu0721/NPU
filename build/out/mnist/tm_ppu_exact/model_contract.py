"""Pin the MNIST model and fixture independently of demo labels and timing."""
from pathlib import Path
import hashlib,json,re
H=Path(__file__).resolve().parent
MODEL='1cf43cece8f0f400cb94ff4716d11db88a98696fdbe683d00b23b90037cab6f0'
HEADER='d673c632399e863722148c3283a8e1490ad5299229fcae97fd1a70346e0067aa'
INPUT='8f6a418c9a639f9e14e96feca47a97df2a35a0a68ae2875431c5c80e05536941'
sha=lambda data:hashlib.sha256(data).hexdigest()
def verify_assets(check_firmware=False):
 c=json.loads((H/'model_contract.json').read_text(encoding='utf-8'))
 assert(c['model_binary_sha256'],c['model_header_sha256'],c['input']['fixture_sha256'])==(MODEL,HEADER,INPUT),'frozen model identity'
 assert(c['model_id'],c['model_bytes'],c['input_shape'],len(c['layers']))==(1,2408,[28,28,1],6),'frozen model structure'
 header=(H/'source/model_blob.h').read_bytes();assert sha(header)==HEADER,'model header changed'
 raw=bytes(int(x,16)for x in re.findall(r'0x([0-9a-fA-F]{2})\b',header.decode()))
 assert len(raw)==2408 and sha(raw)==MODEL and raw==(H/'model.bin').read_bytes(),'model weights changed'
 fixture=(H/'input.bin').read_bytes();assert len(fixture)==784 and sha(fixture)==INPUT,'fixture changed'
 embedded=bytes(map(int,re.search(r'fixture_input\[\]\s*=\s*\{([^}]+)\}',(H/'source/fixture.h').read_text())[1].split(',')))
 assert embedded==fixture,'compiled input differs from pinned input'
 identity=(H/'source/identity.h').read_text()
 assert f'#define MODEL_SHA "{MODEL}"'in identity and f'#define INPUT_SHA "{INPUT}"'in identity,'UART identity changed'
 registry=(H/'source/model_registry.h').read_text()
 row=re.search(r'\{1, 10, \{([^}]+)\}\}, /\* mnist \*/',registry)
 assert row and bytes(int(v,16)for v in re.findall(r'0x([0-9a-f]{2})',row[1])).hex()==HEADER,'original registry identity differs'
 prov=json.loads((H/'provenance.json').read_text())
 assert(prov['model_binary_sha256'],prov['model_header_sha256'],prov['input_sha256'])==(MODEL,HEADER,INPUT),'provenance differs'
 assert prov['layers']==[{k:l[k]for k in p}for l,p in zip(c['layers'],prov['layers'])],'layer contract differs'
 if check_firmware:
  build=json.loads((H/'firmware/build.json').read_text())
  for name,value in build['source_hashes'].items():assert sha((H/'source'/name).read_bytes())==value,'compiled source changed: '+name
  assert(H/'main.c').read_bytes()==(H/'source/main.c').read_bytes(),'main differs from compiled source'
  binary=(H/'firmware/firmware.bin').read_bytes()
  assert binary.count(raw)==1 and binary.count(fixture)==1,'model/input missing from compiled image'
  words=(H/'firmware/firmware_itcm.mem').read_text().split()
  data=b''.join(int(w,16).to_bytes(4,'little')for w in words)
  assert len(data)==98304 and data==binary+bytes(98304-len(binary)),'firmware BIN/MEM differ'
  assert sha((H/'firmware/firmware_itcm.mem').read_bytes())==build['firmware_itcm_sha256'],'compiled firmware hash differs'
 return c
if __name__=='__main__':
 c=verify_assets(check_firmware=True)
 print('MODEL_CONTRACT_PASS',c['name'],MODEL)
