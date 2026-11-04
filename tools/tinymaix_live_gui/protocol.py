"""TMLIVE1 hardware protocol. Results are accepted only after identity and equality checks."""
import hashlib, json, math, re, statistics, struct, sys, time, zlib
from pathlib import Path
try:
    import serial
except ImportError:
    # Discover an optional per-user Conda dependency without embedding an account name.
    for dependency_root in (Path.home()/'AppData/Local/miniconda3/Lib/site-packages',Path.home()/'miniconda3/Lib/site-packages'):
        if (dependency_root/'serial/__init__.py').is_file():
            sys.path.append(str(dependency_root))
            break
    try:
        import serial
    except ImportError:
        raise RuntimeError('Install pyserial in the selected Python environment: python -m pip install pyserial') from None
from serial.tools import list_ports

HOME = Path(__file__).resolve().parent
TASKS = {
    'mnist': dict(id=1, size=784, classes=10, layers=6, submissions=4, windows=3, quants=3, labels=[str(i) for i in range(10)]),
    'kws': dict(id=2, size=2560, classes=3, layers=13, submissions=11, windows=4, quants=8, labels=['Hi xiaowen', 'Nihao wenwen', 'Background']),
}
for name, spec in TASKS.items():
    spec['model'] = json.loads((HOME/'firmware'/name/'baseline.json').read_text(encoding='utf-8'))['model_sha256']

def sha(data):
    return hashlib.sha256(data).hexdigest()

class ResponseError(RuntimeError):
    def __init__(self,message,raw):
        super().__init__(message)
        self.raw=raw

def read_until(port, marker=b'READY\r\n', timeout=30):
    deadline=time.monotonic()+timeout
    data=bytearray()
    while time.monotonic()<deadline:
        data.extend(port.read(max(1, port.in_waiting)))
        if marker in data:
            return bytes(data)
        if b'FAULT' in data:
            raise RuntimeError('板卡自检失败：'+data.decode('ascii',errors='replace'))
        if len(data)>200000:
            raise RuntimeError('串口响应超出长度限制')
    raise TimeoutError('等待板卡响应超时：'+data[-200:].decode('ascii',errors='replace'))

def validate_info(raw, task, boot=False):
    s=TASKS[task]
    text=raw.decode('ascii',errors='strict')
    pat=r'INFO TMLIVE1 TASK ([0-9A-F]{8}) HZ ([0-9A-F]{8}) BYTES ([0-9A-F]{8}) MODEL ([0-9a-f]{64})'
    m=re.search(pat,text)
    if not m or [int(m[1],16),int(m[2],16),int(m[3],16),m[4]] != [s['id'],50000000,s['size'],s['model']]:
        raise RuntimeError('板卡固件/模型不匹配，请加载所选模型的实时演示固件。'+text[-250:])
    if boot and 'CHECK 00000000\r\n' not in text:
        raise RuntimeError('缺少启动自检通过记录')
    return dict(task=task, hz=50000000, model=s['model'], protocol='TMLIVE1')

def parse_result(raw, task, seq, payload):
    s=TASKS[task]; text=raw.decode('ascii',errors='strict')
    crc=zlib.crc32(payload)
    begin=f"BEGIN TMLIVE1 TASK {s['id']:08X} SEQ {seq:08X} LEN {len(payload):08X} CRC {crc:08X}"
    if begin not in text.splitlines() or f'END {seq:08X} RC 00000000' not in text.splitlines():
        raise RuntimeError('板卡未完成本次输入验证：'+text[-300:])
    if f"MODEL {s['model']}" not in text.splitlines():
        raise RuntimeError('返回的模型身份不符')
    rows=[]; layers=[]
    pat=r'R ([0-9A-F]{8}) N ([0-9A-F]{8}) C ([0-9A-F]{16}) H ([0-9A-F]{8}) M ([0-9A-F]{8}) U ([0-9A-F]{8}) W ([0-9A-F]{8}) Q ([0-9A-F]{8}) B ([0-9A-F]{8}) K ([0-9A-F]{8}) S((?: [0-9A-F]{8})+)'
    for line in text.splitlines():
        if line.startswith('R '):
            m=re.fullmatch(pat,line)
            if not m: raise RuntimeError('测量行格式错误')
            values=[int(m[i],16) for i in range(1,11)]
            row=dict(zip(['mode','rep','cycles','hits','misses','submissions','windows','quants','weight_loads','weight_hits'],values))
            row['score_bits']=[int(v,16) for v in m[11].split()]
            rows.append(row)
        elif line.startswith('L '):
            m=re.fullmatch(r'L ([0-9A-F]{8}) CPU ([0-9A-F]{8}) NPU ([0-9A-F]{8})',line)
            if not m: raise RuntimeError('层验证行格式错误')
            layers.append([int(v,16) for v in m.groups()])
    order=[(0,i) for i in range(6)]+[(1,0)]+[(m,i) for m in (2,3) for i in range(5)]
    if [(r['mode'],r['rep']) for r in rows]!=order: raise RuntimeError('测量样本数量或顺序不符')
    reference=rows[0]['score_bits']
    if len(reference)!=s['classes']: raise RuntimeError('输出类别数量不符')
    for r in rows:
        mode=r['mode']; active=bool(mode)
        expected=[s['submissions'] if active else 0,s['windows'] if active else 0,s['quants'] if active else 0]
        if [r[k] for k in ('submissions','windows','quants')]!=expected: raise RuntimeError('硬件调用计数不符')
        if (r['hits'],r['misses'])!=((s['submissions'],0) if mode==3 else (0,s['submissions']) if active else (0,0)):
            raise RuntimeError('指令缓存状态不符')
        weights=(4 if mode==1 else 0,4 if mode in (2,3) else 0) if task=='mnist' else (0,0)
        if (r['weight_loads'],r['weight_hits'])!=weights: raise RuntimeError('权重状态不符')
        if r['score_bits']!=reference or not 0<r['cycles']<50000000*30: raise RuntimeError('CPU/NPU 输出不一致或计数无效')
    if len(layers)!=s['layers'] or [l[0] for l in layers]!=list(range(s['layers'])) or any(l[1]!=l[2] for l in layers):
        raise RuntimeError('CPU/NPU 中间层输出不一致')
    scores=list(struct.unpack('<'+'f'*s['classes'],struct.pack('<'+'I'*s['classes'],*reference)))
    if not all(math.isfinite(v) and 0<=v<=1 for v in scores) or not .9<sum(scores)<1.1: raise RuntimeError('概率输出无效')
    med=lambda mode: statistics.median(r['cycles'] for r in rows if r['mode']==mode and (mode!=0 or r['rep']>0))
    cpu=med(0); modes={label:dict(cycles=med(mode),ms=med(mode)/50000,speedup=cpu/med(mode)) for label,mode in [('first',1),('cold',2),('hot',3)]}
    top=max(range(len(scores)),key=scores.__getitem__)
    return dict(task=task,seq=seq,input_sha256=sha(payload),input_crc32=f'{crc:08x}',model_sha256=s['model'],clock_hz=50000000,
                cpu_ms=cpu/50000,cpu_cycles=cpu,modes=modes,scores=scores,labels=s['labels'],prediction=s['labels'][top],confidence=scores[top],
                rows=rows,layers=layers,verified=True,measurement='mcycle: tm_run_cpu / tm_run; CPU first discarded, median of 5; NPU first + cold 5 + hot 5')

def infer(port, task, seq, payload):
    s=TASKS[task]
    if len(payload)!=s['size']: raise ValueError('输入字节数不符')
    port.reset_input_buffer()
    port.write(struct.pack('<4sBBHHI',b'TMG1',s['id'],0,seq,len(payload),zlib.crc32(payload)));port.flush()
    if port.read(1)!=b'\x06': raise RuntimeError('板卡未接受输入头，请重新连接实时固件')
    for i in range(0,len(payload),64):
        port.write(payload[i:i+64]);port.flush()
        if port.read(1)!=b'\x06': raise RuntimeError(f'输入传输失败（偏移 {i}）')
    raw=read_until(port,timeout=40)
    try: return parse_result(raw,task,seq,payload),raw
    except (RuntimeError,ValueError) as e: raise ResponseError(str(e),raw) from e
