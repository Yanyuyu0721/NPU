from pathlib import Path
import contextlib,hashlib,importlib.util,io,json,struct,types
H=Path(__file__).resolve().parent
path=H/'model_alignment_evidence/reference_mnist.py';ns={'__file__':str(path)}
exec(path.read_text().split("text=(H/'board_demo1/uart.txt')")[0],ns)
ref=types.SimpleNamespace(**ns)
c=json.loads((H/'model_contract.json').read_text(encoding='utf-8'));l=c['layers'][5];f=ref.f
deq=[f(f(i-128-l['input_zero_point'])*l['input_scale'])for i in range(256)]
bits=lambda x:struct.unpack('<I',struct.pack('<f',x))[0]
base=[bits(ref.exp_local(f(deq[255-d]-deq[255])))for d in range(256)]
deltas=[]
for maximum in range(256):
 for value in range(maximum+1):
  e=bits(ref.exp_local(f(deq[value]-deq[maximum])));delta=e-base[maximum-value]
  assert delta%64==0
  deltas.append(delta//64)
print('SOFTMAX_TABLE_ENTRIES',len(deltas),'DELTA_RANGE',min(deltas),max(deltas),'BASE_BYTES',len(base)*4)
summary=dict(entries=len(deltas),delta_min=min(deltas),delta_max=max(deltas),base_bits=base,deltas=deltas)
(H/'post_table_analysis.json').write_text(json.dumps(summary))
