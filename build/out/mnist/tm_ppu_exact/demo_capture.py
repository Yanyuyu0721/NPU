"""Program the aligned TinyMaix image, capture raw UART, verify before reporting.

No number from the previous custom edge_infer test is accepted by this parser.
"""
from pathlib import Path
import argparse,datetime,hashlib,json,re,statistics,struct,subprocess,sys,time
from model_contract import verify_assets
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
ROW=re.compile(r'^R ([0-9A-F]{8}) N ([0-9A-F]{8}) C ([0-9A-F]{16}) H ([0-9A-F]{8}) M ([0-9A-F]{8}) U ([0-9A-F]{8}) W ([0-9A-F]{8}) Q ([0-9A-F]{8}) S((?: [0-9A-F]{8}){10})$',re.M)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def validate(text,simulation=False):
 contract=verify_assets(check_firmware=True)
 identity=json.loads((HERE/'provenance.json').read_text(encoding='utf-8'))
 text=text.replace('\r','')
 assert not re.search(r'^D ',text,re.M),'diagnostic UART invalidates timing'
 assert text.startswith('BOOT VEX_MNIST_PQ2\n'),'fresh TinyMaix boot missing'
 assert re.findall(r'^BOOT .+$',text,re.M)==['BOOT VEX_MNIST_PQ2'],'multiple or mixed-protocol boots'
 assert re.findall(r'^MODEL ([0-9a-f]{64})$',text,re.M)==[identity['model_binary_sha256']],'model identity'
 assert re.findall(r'^INPUT ([0-9a-f]{64})$',text,re.M)==[identity['input_sha256']],'input identity'
 expected=[(m,r)for m in range(4)for r in range(1 if simulation else 6 if m==0 else 1 if m==1 else 5)]
 count=len(expected)
 assert f'VEX_MNIST_PQ2 hz=02FAF080 rows={count:08X} boundary=tm_run_only conv_window=hardware weight_resident=0 quant_cache=1 ppu_exact=1 math_tables=1\n'in text,'clock/boundary'
 matches=ROW.findall(text);assert len(matches)==count,'row count'
 records=[]
 reference=None
 # One batch per convolution/FC layer; reject silent CPU fallback.
 submissions=sum(1 for x in identity["layers"] if x["type"] in (0,2,5))
 for (mode,rep,cycles,hits,misses,subs,windows,quants,scores),expected_pair in zip(matches,expected):
  mode,rep,cycles,hits,misses,subs,windows,quants=[int(x,16)for x in(mode,rep,cycles,hits,misses,subs,windows,quants)]
  assert(mode,rep)==expected_pair,'mode/repeat order';assert cycles>0,'zero cycles'
  bits=[int(x,16)for x in scores.split()]
  if reference is None:reference=bits
  assert bits==reference,'CPU/NPU final float bits differ'
  assert (hits,misses,subs)==((0,0,0)if mode==0 else (submissions,0,submissions)if mode==3 else (0,submissions,submissions)),'cache/submission counts'
  assert windows==(0 if mode==0 else 3),'hardware window call count'
  assert quants==(0 if mode==0 else 3),'exact PPU layer call count'
  records.append(dict(mode=mode,repeat=rep,cycles=cycles,ms=cycles/50000,hits=hits,misses=misses,submissions=subs,hardware_windows=windows,hardware_quantizations=quants,score_bits=bits))
 layers=re.findall(r'^L ([0-9A-F]{8}) CPU ([0-9A-F]{8}) NPU ([0-9A-F]{8})$',text,re.M)
 assert len(layers)==len(identity['layers']),'layer validation missing'
 for i,(number,cpu,npu)in enumerate(layers):assert int(number,16)==i and cpu==npu,'layer output hash mismatch'
 assert [cpu for _,cpu,_ in layers]==contract['golden_inputs'][0]['layer_hashes'],'original CPU reference layer hashes differ'
 assert reference==contract['golden_inputs'][0]['score_bits'],'original CPU reference scores differ'
 assert re.findall(r'^END ([0-9A-F]{8})$',text,re.M)==['00000000'],'firmware did not pass'
 profiles=re.findall(r'^P ([0-9A-F]{8}) L ([0-9A-F]{8}) C ([0-9A-F]{16}) E ([0-9A-F]{16})$',text,re.M)
 if not simulation:
  assert len(profiles)==12,'layer profiling missing'
  for row,(b,i)in zip(profiles,[(b,i)for b in range(2)for i in range(6)]):
   rb,ri,cycles,external=[int(x,16)for x in row]
   assert(rb,ri)==(b,i)and cycles>0 and 0<=external<=cycles,'invalid layer profile'
 probes=re.findall(r'^V ([0-9A-F]{8}) CPU((?: [0-9A-F]{8}){10}) NPU((?: [0-9A-F]{8}){10}) MATCH ([0-9A-F]{8})$',text,re.M)
 assert len(probes)==6,'stress input validation missing'
 for i,(number,cpu,npu,match)in enumerate(probes):assert int(number,16)==i and cpu==npu and match=='00000001','stress input mismatch'
 for i,(_,cpu,_,_)in enumerate(probes):assert [int(x,16)for x in cpu.split()]==contract['golden_inputs'][i+1]['score_bits'],'original CPU stress scores differ'
 medians={m:statistics.median(x['cycles']for x in records if x['mode']==m and(simulation or m!=0 or x['repeat']>0))for m in range(4)}
 for label,expected_value in [('CPU_MEDIAN_MS',medians[0]/50000),('NPU_FIRST_MS',medians[1]/50000),('NPU_COLD_MEDIAN_MS',medians[2]/50000),('NPU_HOT_MEDIAN_MS',medians[3]/50000),('SPEEDUP_COLD',medians[0]/medians[2]),('SPEEDUP_HOT',medians[0]/medians[3])]:
  values=re.findall(r'^DEMO '+label+r' ([0-9]+\.[0-9]{3})(?:x)?$',text,re.M)
  assert len(values)==1 and abs(float(values[0])-expected_value)<=0.000501,'printed demo value differs from measured cycles: '+label
 assert 'T MATH EXP_PAIRS 00008080 GAP_VALUES 00000100 FC_BOUNDARIES 000004FB FC_RANDOM 00000400\n'in text,'math domain validation missing'
 assert 'DEMO VALIDATION PASS 6 layers; fixed input plus 6 stress inputs\n'in text,'demo pass marker missing'
 probabilities=[struct.unpack('<f',struct.pack('<I',x))[0]for x in reference]
 assert max(range(len(probabilities)),key=probabilities.__getitem__)==identity['expected_label'],'fixture classification mismatch'
 return dict(passed=True,simulation=simulation,stress_inputs=probes,records=records,layer_count=len(layers),layer_hashes=layers,layer_profiles=[dict(backend=int(b,16),layer=int(i,16),cycles=int(c,16),external_cycles=int(e,16))for b,i,c,e in profiles],expected_submissions=submissions,score_bits=reference,probabilities=[struct.unpack('<f',struct.pack('<I',x))[0]for x in reference],median_cycles=medians,median_ms={m:v/50000 for m,v in medians.items()},speedup={m:medians[0]/medians[m]for m in(1,2,3)})

def render(record):
 lines=['# TinyMaix MNIST CNN A7 同口径测试结果','',f'状态：{"通过"if record.get("passed")else "未通过"}。',f'时间：{record.get("finished","")}。','']
 if record.get('error'):lines+=['错误：'+record['error'],'']
 if not record.get('validation'):return '\n'.join(lines)
 v=record['validation'];names={0:'TinyMaix CPU 稳态',1:'TinyMaix NPU 首次调用',2:'TinyMaix NPU 指令缓存未命中',3:'TinyMaix NPU 指令缓存命中'}
 lines+=['平台：XC7A100T，CPU/NPU 同为50 MHz。计时仅包围 tm_run_cpu/tm_run；模型加载、输入预处理、清缓存和UART不在时间内。每次NPU调用仍准备权重；普通卷积使用硬件窗口与精确Q8 PPU量化/激活，本模型没有深度卷积。没有持久权重驻留。','',
 '| 模式 | 周期中位数 | 时间 ms | 相对CPU |','|---|---:|---:|---:|']
 for m in range(4):lines.append(f'|{names[m]}|{v["median_cycles"][m]:.0f}|{v["median_ms"][m]:.5f}|{v["speedup"].get(m,1):.5f}倍|')
 lines+=['','CPU稳态剔除第一次调用，CPU／未命中／命中各取后续5次的中位数；NPU首次调用只测1次。','',f'{v["layer_count"]}层CPU/NPU输出哈希全部一致；所有计时调用的最终十分类浮点位模式一致。每次NPU推理有{v["expected_submissions"]}次真实提交。',f'输出概率：{v["probabilities"]}。','',
 '数值口径：TM_NPU_CPU_COMPAT=1，NPU执行INT32乘加及偏置，3层卷积的量化与ReLU在PPU执行，采用精确倒数乘法与校正保留TinyMaix Q8的逐位结果；FC量化仍为软件。量化系数随不可变模型缓存：首次构建计时，后续复用。普通卷积已启用硬件PPU；FC、GAP和Softmax仍在CPU执行；量化与指数函数使用从模型参数生成的精确函数表，不缓存输入预测结果。','',
 '模型：既有TinyMaix MNIST CNN，2408字节、6层（3个卷积、GAP、全连接、Softmax），28×28×1、10类。与旧EdgeModel MLP不同；使用同一原始MNIST样本，不转置。尚不能证明此模型就是论文11.3倍实验所用的精确版本。','',
 f'bitstream SHA256：`{record.get("bit_sha256","")}`',f'UART SHA256：`{record.get("transcript_sha256","")}`','',
 '固定输入及6种额外输入均完成CPU/NPU逐层与最终输出校验；额外输入校验在计时外。当前固件支持串口发送R重新运行。','',
 'Word文档未修改。TinyMaix KWS 演示保留在 build/out/kws/tm_optimized/run_demo.cmd；旧 MNIST MLP 镜像保留在 build/out/a7_2018_fix/board_top.bit。','']
 return '\n'.join(lines)

def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path);p.add_argument('--validate',type=Path);p.add_argument('--simulation',action='store_true');p.add_argument('--bit',type=Path,default=HERE/'image_demo3/board_top.bit');p.add_argument('--port',default='COM3');a=p.parse_args()
 if a.validate:
  print(json.dumps(validate(a.validate.read_text(encoding='ascii'),a.simulation),indent=2));return 0
 assert a.out and not a.out.exists(),'fresh capture output required'
 image=json.loads((a.bit.parent/'result.json').read_text(encoding='utf-8'))
 verify_assets(check_firmware=True)
 assert image.get('timing_50mhz_met')and image.get('bit_sha256')==sha(a.bit),'physical image gate'
 assert image['firmware_itcm_sha256']==sha(HERE/'firmware/firmware_itcm.mem'),'firmware/image mismatch'
 # Use the installed pure-Python serial package with the bundled interpreter.
 try:import serial
 except ImportError:
  raise RuntimeError('Install pyserial in the selected Python environment: python -m pip install pyserial') from None
 out=a.out.resolve();out.mkdir(parents=True);arm=out/'capture_arm.txt';ack=out/'capture_ack.txt'
 cmd=[r'D:\Xlinx\Vivado\2018.2\bin\vivado.bat','-mode','batch','-source',str(ROOT/'board/program_2018_2.tcl'),'-log',str(out/'program.log'),'-journal',str(out/'program.jou'),'-tclargs',str(a.bit.resolve()),'127.0.0.1:3121','',str(arm),str(ack)]
 record=dict(passed=False,board_measurement=False,bit_sha256=sha(a.bit),port=a.port,started=datetime.datetime.now().astimezone().isoformat(),command=cmd)
 process=None
 try:
  raw=bytearray();armed=False;deadline=time.monotonic()+240
  with serial.Serial(a.port,115200,timeout=.05)as uart,(out/'stdout.log').open('wb')as log,(out/'uart.txt').open('wb')as transcript:
   uart.reset_input_buffer();process=subprocess.Popen(cmd,cwd=out,stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
   while time.monotonic()<deadline:
    if not armed:
     uart.reset_input_buffer()
     if arm.exists():uart.reset_input_buffer();ack.write_text('capture_ready\n');armed=True
     if process.poll()is not None:raise RuntimeError('programmer exited before capture armed')
     time.sleep(.01);continue
    chunk=uart.read(4096)
    if chunk:raw.extend(chunk);transcript.write(chunk);transcript.flush()
    if re.search(rb'\nEND [0-9A-F]{8}\r?\n',raw):break
    if process.poll()not in(None,0):raise RuntimeError('programmer failed')
   else:raise TimeoutError('no complete firmware report within 240 seconds')
   assert process.wait(max(1,deadline-time.monotonic()))==0,'programmer return code'
  programming=(out/'stdout.log').read_text(errors='replace')
  assert 'ACTUAL_HW_PART=xc7a100t'in programming and 'MATCHING_A7_IMAGE_PROGRAMMED'in programming,'device/program marker'
  assert not re.search(r'ERROR:|FATAL:',programming),'programming error'
  record['validation']=validate(raw.decode('ascii'));record.update(passed=True,board_measurement=True,transcript_sha256=sha(out/'uart.txt'))
 except Exception as exc:record['error']=repr(exc)
 finally:
  if process is not None and process.poll()is None:subprocess.run(['taskkill','/PID',str(process.pid),'/T','/F'],capture_output=True)
  record['finished']=datetime.datetime.now().astimezone().isoformat();(out/'result.json').write_text(json.dumps(record,indent=2),encoding='utf-8');(out/'report.md').write_text(render(record),encoding='utf-8')
 print(json.dumps(record,indent=2));return 0 if record['passed']else 1
if __name__=='__main__':raise SystemExit(main())
