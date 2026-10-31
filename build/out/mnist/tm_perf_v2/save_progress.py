from pathlib import Path
import datetime,hashlib,json,shutil,zipfile
from model_contract import verify_assets
from check_cpu_reference import verify as verify_cpu
H=Path(__file__).resolve().parent;ROOT=H.parents[3];B=H.parent/'tm_ppu_exact';K=H.parents[1]/'kws/tm_perf_v2'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
verify_assets(check_firmware=True);verify_cpu()
D=sorted((H/'demo_runs').iterdir())[-1]
records=[json.loads((D/'program/result.json').read_text())]+[json.loads(p.read_text())for p in sorted(D.glob('repeat_*/result.json'))]
assert len(records)==4 and all(r['passed']and r['board_measurement']for r in records)
v=records[0]['validation'];cycles=v['median_cycles'];ms=v['median_ms'];speed=v['speedup']
assert all(r['validation']['median_cycles']==cycles for r in records)
assert json.loads((H/'capture_validator_checks.json').read_text())['passed']
assert sha(H/'image_final/board_top.bit')==records[0]['bit_sha256']
assert sha(B/'image_demo3/board_top.bit')=='558cf07439ce2bb878fb6a0d68e7041c665e9e4a4c05ceb62323c7859c344ce8'
assert sha(K/'image_final/board_top.bit')=='58af111d85c35cf1bb2b2fbb84af407dceeb6d12db7ad10f77c9cae69f588175'
shutil.copy2(H/'firmware/firmware_itcm.mem',H/'image_final/firmware_itcm.mem')
p=H/'patch_itcm.py';s=p.read_text()
s=s.replace("H.parent/'tm_ppu_exact/image_demo1/initial_firmware_itcm.mem'","H/'image_final/firmware_itcm.mem'")
s=s.replace("H.parent/'tm_ppu_exact/image_demo1/routed_50mhz.dcp'","H/'image_final/routed_50mhz.dcp'")
s=s.replace("H.parent/'tm_ppu_exact/image_demo1/result.json'","H/'image_final/result.json'")
p.write_text(s);shutil.copy2(H/'image_final/updated_init.txt',H/'itcm_dump.txt')
if not(H/'rtl_override').exists():shutil.copytree(B/'rtl_override',H/'rtl_override')
now=datetime.datetime.now().astimezone();bit=sha(H/'image_final/board_top.bit');mem=sha(H/'firmware/firmware_itcm.mem')
summary=dict(passed=True,produced_at=now.isoformat(),protocol='VEX_MNIST_PQ6',model_sha256=sha(H/'model.bin'),input_sha256=sha(H/'input.bin'),cpu_reference_unchanged=True,word_documents_edited=False,verified_final_runs=4,verified_final_timing_samples=68,median_cycles=cycles,median_ms=ms,speedup=speed,bit_sha256=bit,firmware_mem_sha256=mem,baseline_bit_sha256=sha(B/'image_demo3/board_top.bit'),kws_optimized_bit_sha256=sha(K/'image_final/board_top.bit'),final_evidence=str(D),weight_resident=True,execution_configuration_cached=True,new_checks=dict(layout_cases=432,dequant_values=256,softmax_quant_values=33024,configuration_cache_cases=72),capture_validator_rejected_cases=22)
(H/'checkpoint_summary.json').write_text(json.dumps(summary,indent=2))
report=f'''# TinyMaix MNIST 优化实测与恢复

保存时间：{now.isoformat()}。

结论：同一 TinyMaix MNIST CNN 的热态整网加速比从 **5.74882 倍**提升到 **{speed['3']:.5f} 倍**。NPU 热态耗时从 3.99530 ms 降至 **{ms['3']:.5f} ms**，缩短 {100*(1-ms['3']/3.99530):.2f}%。Word 文档未修改。

## 最终板测

| 模式 | 周期中位数 | 耗时/ms | CPU/NPU |
|---|---:|---:|---:|
| 原 TinyMaix CPU 稳态 | {cycles['0']} | {ms['0']:.5f} | 1 |
| NPU 首次调用，含参数建立和权重加载 | {cycles['1']} | {ms['1']:.5f} | {speed['1']:.5f}× |
| 权重驻留，NPU 指令缓存未命中 | {cycles['2']} | {ms['2']:.5f} | {speed['2']:.5f}× |
| 权重驻留，NPU 指令缓存命中 | {cycles['3']} | {ms['3']:.5f} | {speed['3']:.5f}× |

平台为 XC7A100T、VexRiscv RV32IM，CPU/NPU 同为 50 MHz。计时包围完整 tm_run_cpu/tm_run，模型加载、输入预处理、显式清指令缓存、结果校验和 UART 不计时。CPU 剔除首轮后取五次中位数；NPU 首次一次，未命中/命中各五次中位数。后两档复用权重、量化计划和执行配置；指令缓存未命中不是全部冷启动。每轮 npu_set_model 重置权重驻留与执行参数缓存，首次实际拷贝和建立配置发生在首次推理计时内。

模型、权重、固定输入与 5.75 倍版本相同：2408 字节 MAIX、28×28×1 INT8 CNN，Conv4/8/16 → GAP → FC10 → Softmax，共 6 层、21220 MAC。CPU 原算子函数、支持文件及预处理后的 CPU 推理路径已核对一致；当前 CPU {ms['0']:.5f} ms 与原 22.96828 ms 的极小差异来自调用代码和链接布局变化，未改动参考算法或人为减速。

## 优化内容

1. PPU 输出以四通道、四位置为一组进行 32 位读取、字节转置和写回，保留非四倍数尾部及未对齐路径。原三层精确 Q8 PPU 硬件量化未改。
2. 缓存执行参数的预检结果和原始内容指纹。每次复用前仍逐项比较所有形状、地址、激活标志、偏置、量化系数及输出地址；代码缓存仍真实查找/生成，提交仍检查 epoch、范围、故障与在途状态。没有缓存输入、窗口、激活或整网结果。
3. 在独立 NPU scratch 高端区域驻留模型权重。首次四层权重各拷贝一次，后续四层各命中一次；窗口和输出使用不重叠的低端区域。切换模型重新初始化。
4. 最终 INT8 输出反量化采用完整 256 值精确函数表，替代重复软件浮点转换及乘法。
5. Softmax 量化对远离所有 INT8 取整边界的保守数值区间直接返回相同整数，其余数值保留原 FP32 除法、缩放和加法。保留此前完整 32896 个指数输入对的精确函数表，以及 GAP/FC 精确量化表。

每次 NPU 推理仍有 4 次真实 NPU 提交、3 次硬件窗口生成和 3 次精确 PPU 量化。实际加速比来自当轮周期计数，没有写死 11.3 或 11.775。

阶段热态板测：原 5.74882× → 批量布局转换约 6.44× → 执行参数缓存约 9.27× → 权重驻留及反量化约 10.50× → Softmax 快路径与最终整理 {speed['3']:.5f}×。阶段记录在 board_baseline、board_profile、board_config、board_resident；最终以 demo_runs 记录为准。

## 验证

- 最终版实际重新烧录一次，连续串口 R 重跑三次，四轮共 68 个计时样本；各模式周期中位数一致，包含完成 tag 跨界重跑。
- 每轮固定输入六层哈希及最终十分类浮点位模式与原 CPU 参考一致，识别为 7；额外六种输入也通过逐层和最终输出校验。最终固定样本及额外输入均对照此前冻结的独立原 CPU 记录。
- 每轮计时外完成原有 32896 个指数输入对、256 个 GAP 值、1275 个 FC 阈值边界值及 1024 个随机 INT32 校验。
- 每轮新增 432 个布局转换用例、256 个反量化值、33024 个 Softmax 量化边界/随机用例、72 个执行配置缓存与强制完整预检/编码对照用例。缓存测试覆盖参数变化、地址重叠/越界、错误状态及代码缓存 epoch 失效。
- 日志验证器接受本轮真实记录，拒绝 22 种破坏日志，包括伪造加速比、缺失权重加载或自检、错误模型、CPU/NPU 同时偏离原始参考等。

这是数值一致性与性能验证，不代表完整 MNIST 测试集准确率评估。

## 硬件、工具与容量

复用既有精确 PPU 布线 DCP，仅更新 ITCM 初值；更新前后逐字验证 24576 个字，未修改 RTL、重新布线或提高时钟。硬件构建及本轮位流导出使用 Vivado 2018.2，实际烧录使用 Vivado 2026.1、127.0.0.1:3122。50 MHz setup 裕量 1.914 ns、hold 裕量 0.018 ns；100/150 MHz 不满足该版时序。

固件 92744 字节，ITCM 容量 98304 字节；BSS 38468 字节，链接器仍保留至少 8 KiB 栈。此前 PPU 数值/指令控制 RTL 验证保留在原 tm_ppu_exact 工程，本轮未改动这些硬件。

## 演示与断电恢复

双击：`{H/'run_demo.cmd'}`。

脚本确认 XC7A100T、烧录 image_final/board_top.bit、采集 COM3 / 115200 原始串口并校验后显示结果。回车或 R 后回车重测，Q 退出。串口助手使用 115200、8N1，发送 ASCII R。拍摄时标注“TinyMaix MNIST CNN / 50 MHz / 完整推理 / 权重驻留 / NPU 指令缓存命中”，同时保留首次与缓存未命中数据。

当前 FPGA 运行这份新版 TinyMaix MNIST，等待 R。配置位于 FPGA SRAM，未写启动 Flash；断电后运行上述入口重新加载。原约 5.75 倍 MNIST 版本和最新约 9.83 倍 KWS 版本均未覆盖。

KWS 切换入口：`{K/'run_demo.cmd'}`。两套固件必须分别烧录；切换任务后不能将上一任务的旧显示作为新板测。

## 与文档的对应

当前热态 {speed['3']:.5f} 倍已超过原文 11.3 倍这一数值，但 CPU/NPU 绝对时间与原文 41.41/3.65 ms 不同；原文模型身份及缓存条件仍缺少原始证据，不能称同条件复现。建议写“当前 XC7A100T 移植实现，MNIST 热态实测约 11.77 倍”，列明模型、50 MHz、权重驻留和计时边界。当前 KWS 热态实测约 9.83 倍；两者均是 TinyMaix 路径，各自优化配置需要分别说明。

最终 bitstream SHA256：`{bit}`。

最终固件 MEM SHA256：`{mem}`。

模型 SHA256：`{sha(H/'model.bin')}`。

最终原始证据：`{D}`。后续固件初值更新应使用本目录 image_final 的精确 PPU DCP 及对应初值，不应换用原无精确 Q8 PPU 的硬件检查点。
'''
(H/'进度与恢复.md').write_text(report,encoding='utf-8')
report_path=Path(r'D:\技术文档\TinyMaix_MNIST优化实测_20261030.md');report_path.write_text(report,encoding='utf-8')
files=set()
for d in ['source','firmware','image_final','demo_runs','rtl_override']:
 files.update(p for p in(H/d).rglob('*')if p.is_file()and'__pycache__'not in p.parts)
files.update(p for p in H.iterdir()if p.is_file())
for d in ['board_baseline','board_profile','board_config','board_resident']:
 files.update(p for p in(H/d).rglob('*')if p.is_file()and p.suffix not in['.wdb','.jou'])
files.update(p for p in(B/'source').rglob('*')if p.is_file())
files.update([ROOT/'board/program_2018_2.tcl',B/'board_math1/result.json'])
manifest={str(p.relative_to(ROOT)):sha(p)for p in sorted(files)}
archive=ROOT/'checkpoints'/('mnist_tinymaix_'+now.strftime('%Y%m%d_%H%M%S')+'.zip')
with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=3)as z:
 for p in sorted(files):z.write(p,p.relative_to(ROOT).as_posix())
 z.writestr('checkpoint_manifest.json',json.dumps(manifest,indent=2));z.write(report_path,'reports/'+report_path.name)
with zipfile.ZipFile(archive)as z:
 assert z.testzip()is None
 for name,value in manifest.items():assert hashlib.sha256(z.read(name.replace('\\','/'))).hexdigest()==value,name
receipt=dict(passed=True,archive=str(archive),archive_bytes=archive.stat().st_size,sha256=sha(archive),files_verified=len(manifest))
(H/'checkpoint_archive.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(dict(summary=summary,archive=receipt,report=str(report_path)),indent=2))
