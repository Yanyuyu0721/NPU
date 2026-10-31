"""Validate final physical evidence, document the result, and save a recovery ZIP."""
from pathlib import Path
import datetime,hashlib,importlib.util,json,re,zipfile
from demo_capture import validate
from model_contract import verify_assets
H=Path(__file__).resolve().parent;ROOT=H.parents[3];BASE=H.parent/'tm_tinymaix';KWS=ROOT/'build/out/kws/tm_optimized'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
c=verify_assets(check_firmware=True);image=json.loads((H/'image_demo3/result.json').read_text());hw=json.loads((H/'image_demo1/result.json').read_text())
assert sha(H/'image_demo3/board_top.bit')==image['bit_sha256']
assert sha(H/'firmware/firmware_itcm.mem')==image['firmware_itcm_sha256']
assert image['new_words_verified']==24576 and hw['passed']and image['timing_50mhz_met']
assert sha(H/'image_demo1/routed_50mhz.dcp')==image['source_checkpoint_sha256']==hw['routed_checkpoint_sha256']
for name,value in hw['rtl_override_sha256'].items():assert sha(H/'rtl_override'/name)==value,name
guard=json.loads((H/'word_readonly_guard.json').read_text(encoding='utf-8'));word_checks={name:sha(Path(name))==value for name,value in guard.items()};assert all(word_checks.values())
def clean(source):return re.sub(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"','',source,flags=re.S)
def body(path,name):
 s=clean(path.read_text());start=re.search(r'\btm_err_t\s+TM_WEAK\s+'+name+r'\(',s).start();pos=s.index('{',start);depth=1;end=pos+1
 while depth:
  if s[end]=='{':depth+=1
  elif s[end]=='}':depth-=1
  end+=1
 return s[start:end]
cpu_checks={}
for name in ['tml_conv2d_dwconv2d','tml_gap','tml_fc','tml_softmax']:
 a=body(BASE/'source/tm_layers.c',name);b=body(H/'source/tm_layers.c',name);assert a==b,name
 cpu_checks[name]=hashlib.sha256(b.encode()).hexdigest()
for name in ['arch_cpu.h','tm_port.h','libc.c','vex_platform.h']:assert sha(H/'source'/name)==sha(BASE/'source'/name),('CPU support changed',name)
records=[];paths=[H/'board_math1/result.json']+sorted(H.glob('demo_runs/*/program/result.json'))+sorted(H.glob('demo_runs/*/repeat_*/result.json'))
for path in paths:
 r=json.loads(path.read_text());assert r['passed'],path
 v=validate((path.parent/'uart.txt').read_text(encoding='ascii'));assert json.loads(json.dumps(v))==r['validation'],path
 records.append(dict(result=str(path.relative_to(ROOT)),uart_sha256=sha(path.parent/'uart.txt'),validation=r['validation']))
assert len(records)>=5
old=json.loads((BASE/'board_demo1/result.json').read_text());ppu=json.loads((H/'board_ppu1/result.json').read_text());assert old['passed']and ppu['passed']
# Validate the earlier protocol with its retained parser, while keeping snapshot
# source/firmware identity verification separate from the current build.
spec=importlib.util.spec_from_file_location('ppu_only_capture',H/'snapshots/ppu_only/demo_capture.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);module.HERE=H
assert json.loads(json.dumps(module.validate((H/'board_ppu1/uart.txt').read_text(encoding='ascii'))))==ppu['validation']
snap=H/'snapshots/ppu_only';build=json.loads((snap/'firmware/build.json').read_text())
for name,value in build['source_hashes'].items():assert sha(snap/'source'/name)==value,name
assert sha(snap/'firmware/firmware_itcm.mem')==json.loads((H/'image_demo2/result.json').read_text())['firmware_itcm_sha256']
for folder in ['unit_exact2','unit_descriptor2']:assert json.loads((H/folder/'result.json').read_text())['passed']
assert sha(KWS/'image_demo1/board_top.bit')=='615ce60103ebe13914c6c6c0c9c51205b127a14c91a34c11203c0ca576320d3c'
kbuild=json.loads((KWS/'firmware/build.json').read_text())
for name,value in kbuild['source_hashes'].items():assert sha(KWS/'source'/name)==value,('KWS changed',name)
checks=json.loads((H/'capture_validator_checks.json').read_text());assert checks['passed']and checks['rejected_captures']==26
v=records[0]['validation'];ms=v['median_ms'];speed=v['speedup'];now=datetime.datetime.now().astimezone()
summary=dict(passed=True,saved=now.isoformat(),current_board='VEX_MNIST_PQ2 exact PPU + exact parameter function tables; UART R ready',bit_sha256=image['bit_sha256'],firmware_itcm_sha256=image['firmware_itcm_sha256'],model_sha256=c['model_binary_sha256'],word_documents_unchanged=word_checks,kws_sources_unchanged=True,cpu_reference_function_hashes=cpu_checks,final_verified_runs=len(records),final_timed_samples=17*len(records),ppu_only_verified_runs=1,records=records,baseline=old['validation'],ppu_only=ppu['validation'],hardware=hw,math_domain_checks_per_run=dict(exp_pairs=32896,gap_values=256,fc_boundary_values=1275,fc_random_int32=1024))
(H/'checkpoint_summary.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
archive=ROOT/'checkpoints'/f'mnist_exact_ppu_{now:%Y%m%d_%H%M%S}.zip'
note=f'''# MNIST 精确PPU优化与实板结果

保存时间：{now:%Y-%m-%d %H:%M:%S %z}。

当前板上为 `VEX_MNIST_PQ2`：原工程登记的同一MNIST TinyMaix INT8 CNN，3层卷积在PPU完成精确量化和ReLU，CPU/NPU仍为50 MHz。CPU参考算法、模型权重和固定输入均保持不变。已通过实板逐层校验和连续重跑；Word文档未改动。

|版本|CPU ms|NPU 热态 ms|整网加速比|
|---|---:|---:|---:|
|优化前，软件卷积后处理|{old['validation']['median_ms']['0']:.5f}|{old['validation']['median_ms']['3']:.5f}|{old['validation']['speedup']['3']:.5f}倍|
|只迁移卷积后处理到精确PPU|{ppu['validation']['median_ms']['0']:.5f}|{ppu['validation']['median_ms']['3']:.5f}|{ppu['validation']['speedup']['3']:.5f}倍|
|精确PPU加软件数学优化|{ms['0']:.5f}|{ms['3']:.5f}|{speed['3']:.5f}倍|
|文档历史数据|41.41|3.65|11.3倍|

NPU热态耗时比优化前缩短{(1-ms['3']/old['validation']['median_ms']['3'])*100:.2f}%。当前CPU基线仍约22.968 ms，而文档为41.41 ms；即使NPU数值接近文档3.65 ms，也不能把加速比写成11.3。当前热态数值比3.65 ms高{(ms['3']/3.65-1)*100:.2f}%，平台、完整CPU配置和论文模型身份尚未完全对应，不能认定同条件复现。

|最终版本模式|周期中位数|时间 ms|CPU/该模式|
|---|---:|---:|---:|
|CPU稳态|{v['median_cycles']['0']}|{ms['0']:.5f}|1|
|NPU首次调用|{v['median_cycles']['1']}|{ms['1']:.5f}|{speed['1']:.5f}倍|
|NPU指令缓存未命中|{v['median_cycles']['2']}|{ms['2']:.5f}|{speed['2']:.5f}倍|
|NPU指令缓存命中|{v['median_cycles']['3']}|{ms['3']:.5f}|{speed['3']:.5f}倍|

计时只包围完整 `tm_run_cpu/tm_run`，包括NPU路径中的调度、指令准备、权重准备、窗口生成、搬运/等待和剩余软件计算；加载、输入预处理、清指令缓存、验证和串口在计时外。CPU剔除第一轮、其后5次取中位数；NPU首次1次，其余两档各5次中位数。无持久权重驻留；首次量化参数构建计时，后续复用。数学函数表在固件内固定，来自模型参数，编译/生成成本不在推理时间内。指令缓存未命中不能简称为全部冷启动。

## 本次实现

原有PPU的Q16四舍五入、饱和规则与本模型TinyMaix FASTSCALE Q8规则不同。增加独立精确Q8模式，保留原Q16和INT32直通模式：偏置后按32位规则左移8位，以21位倒数乘法加余数校正实现精确有符号除法，再执行ReLU、32位乘法、算术移位、零点及INT8转换。保留原CPU的截断和模运算结果；这与文档通常描述的饱和量化存在具体数值实现差别，不能为了形式一致改变冻结模型的输出。扩展PPU参数描述与全局输出尺度，CPU程序传入各通道系数。每次推理仍为4次NPU提交、3次硬件窗口、3次真正的卷积PPU量化；FC乘加仍由NPU执行。

剩余软件开销通过固定参数的函数表优化：GAP对全部256种整数均值做量化映射；FC用255个精确阈值完成INT32到INT8转换；Softmax用全部32896种有效INT8输入值/最大值组合的指数函数结果，压缩为基表与4位修正表，保持原浮点位模式。表合计18748字节，不缓存图片、激活张量、预测类别或整网输出。CPU参考路径继续调用原来的GAP、FC和Softmax，源码函数体和CPU支持文件已与原版本核对一致。

最终固件83112字节，BSS35812字节，链接器保留至少8KiB栈；ITCM容量96KiB。具体表生成代码及完整取值域验证在 `prepare_post_math.py`、`post_candidate/` 和 `source/mnist_math_fast.inc`。

## 验证证据

- RTL精确PPU：410组任务、21573个数值样本，含全部本模型卷积量化系数、正负数、溢出、非8倍数长度、原Q16和直通模式。
- PPU指令控制：八通道、700个随机描述符、32深度满队列、扩展参数高位、配置、同步和复位验证通过。
- 最终版本实板{len(records)}轮、{17*len(records)}个计时样本，包含串口连续R重跑3次与完整一键入口重烧录；此前只启用PPU另测1轮17个样本。
- 每轮固定样本6层CPU/NPU哈希及最终十分类浮点位模式相同，识别为7；6种额外输入逐层与最终输出校验相同，固定及额外输入同时对照原CPU公式独立复算结果。
- 每轮在板上计时外逐项验证32896个指数输入对、256个GAP值、1275个FC阈值边界值和1024个随机INT32值。
- 串口验证器拒绝26种破坏日志，包括错误模型、伪造11.3倍、错误提交次数、未启用PPU、缺失数学取值域验证和CPU/NPU一起偏离参考输出。

这是数值一致性和计时验证，不是完整MNIST测试集准确率评估。

## 硬件与时序

新PPU经过实际综合、布局布线并加载到XC7A100T，使用Vivado2018.2，器件xc7a100tfgg484-2。50 MHz setup裕量1.914 ns、hold裕量0.018 ns，时序通过。100/150 MHz不满足此版时序，没有提高板上时钟。

布线资源：40968 LUT、33727 FF、134 RAMB36加1 RAMB18、212 DSP。DRC无Error或Critical Warning，保留既有DSP流水配置Warning。每次更新固件初值均逐字校验24576个ITCM字，软件镜像和真实硬件bitstream按SHA256绑定。

## 演示与恢复

双击本目录 `run_demo.cmd`。脚本会确认XC7A100T、加载 `image_demo3/board_top.bit`、采集真实串口并校验后显示时间和倍数。回车或R后回车重新测量，Q退出。串口助手设置COM3、115200、8N1，发送字符R。成功报告含 `T MATH ...`、`DEMO VALIDATION PASS ...` 和 `END 00000000`。每轮还会执行计时外的完整数学取值域校验，因此整轮等待时间不等于显示的单次推理时间。

当前测试程序已退出，板上等待R。此次使用JTAG配置SRAM，未写启动Flash；断电后重新运行此入口即可恢复。

当前应使用镜像：`image_demo3/board_top.bit`。`image_demo2`是只启用PPU的阶段对照；`image_demo1`用于保存新硬件布线与初始ITCM基底，初始固件含未通过32位CSR端口暴露的版本检查，不作为演示入口。版本绑定使用host的bitstream与RTL来源哈希，并以实际逐层输出作为正确性门槛。不要读取C0000044作为当前板的能力寄存器。

需要回到优化前版本时，运行 `{BASE/'run_demo.cmd'}`，其3.47倍镜像和源码完整保留。KWS入口 `{KWS/'run_demo.cmd'}` 未改动；切换它会加载原KWS硬件和固件。

源码与证据包括 `source/`、`rtl_override/`、`shadow/`、`firmware/`、`model_contract.json`、`board_ppu1/`、`board_math1/`、`demo_runs/`、`snapshots/ppu_only/`。`patch_itcm.py`后续必须以本目录 `image_demo1` 中的精确PPU布线为基底，不能换回原来的无精确PPU硬件DCP。原始模型哈希仍为 `{c['model_binary_sha256']}`，尚不能确认与论文11.3倍那次测试的模型完全同一。

恢复包：`{archive}`。备份不包含Vivado、RISC-V GCC和Python工具链。两个Word文件与KWS源码/镜像哈希均已核对未变。

最终bitstream SHA256：`{image['bit_sha256']}`。
最终固件MEM SHA256：`{image['firmware_itcm_sha256']}`。
'''
(H/'进度与恢复.md').write_text(note,encoding='utf-8')
Path(r'D:\技术文档\MNIST_PPU优化实测_20261029.md').write_text(note,encoding='utf-8')
files=set()
for p in H.iterdir():
 if p.is_file()and p.suffix in('.py','.c','.cmd','.json','.md','.txt'):files.add(p)
for folder in ['source','firmware','rtl_override','shadow','model_alignment_evidence','post_candidate','board_ppu1','board_math1','demo_runs','snapshots/ppu_only']:
 for p in(H/folder).rglob('*'):
  if p.is_file()and not any(x.startswith('.')or x in('__pycache__','xsim.dir')for x in p.relative_to(H/folder).parts):files.add(p)
for folder in ['unit_exact2','unit_descriptor2']:
 for p in(H/folder).iterdir():
  if p.is_file()and p.suffix in('.py','.sv','.tcl','.mem','.txt','.log','.json'):files.add(p)
for folder in ['image_demo1','image_demo2','image_demo3']:
 for p in(H/folder).iterdir():
  if p.is_file()and p.suffix in('.bit','.dcp','.json','.tcl','.mem','.txt','.tsv','.rpt','.log','.jou'):
   if folder=='image_demo1'and p.suffix=='.bit':continue
   files.add(p)
files.add(ROOT/'board/program_2018_2.tcl')
for path in [BASE/'image_demo1/board_top.bit',BASE/'image_demo1/result.json',BASE/'run_demo.cmd',KWS/'image_demo1/board_top.bit',KWS/'image_demo1/result.json']:files.add(path)
# Include complete rollback launchers and their local dependencies.
for base in [BASE,KWS]:
 for name in ['demo_capture.py','demo_console.py','provenance.json','firmware/firmware_itcm.mem']:
  files.add(base/name)
for name in ['model_contract.py','model_contract.json','model.bin','input.bin']:
 files.add(BASE/name)
for p in(BASE/'source').iterdir():
 if p.is_file():files.add(p)
files.add(BASE/'firmware/build.json');files.add(BASE/'firmware/firmware.bin');files.add(KWS/'run_demo.cmd')
with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=3)as z:
 for p in sorted(files):z.write(p,p.relative_to(ROOT).as_posix())
with zipfile.ZipFile(archive)as z:
 assert z.testzip()is None
 for p in [H/'image_demo3/board_top.bit',H/'firmware/firmware_itcm.mem',H/'image_demo1/routed_50mhz.dcp',BASE/'image_demo1/board_top.bit',KWS/'image_demo1/board_top.bit']:
  assert hashlib.sha256(z.read(p.relative_to(ROOT).as_posix())).hexdigest()==sha(p)
receipt=dict(passed=True,archive=str(archive),archive_sha256=sha(archive),archive_bytes=archive.stat().st_size,archived_files=len(files),final_runs=len(records),final_speedup=speed,final_ms=ms,word_documents_unchanged=word_checks)
(H/'checkpoint_archive.json').write_text(json.dumps(receipt,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(receipt,indent=2,ensure_ascii=False))
