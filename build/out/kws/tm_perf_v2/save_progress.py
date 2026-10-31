from pathlib import Path
import datetime,hashlib,json,shutil,zipfile
from model_contract import verify_assets
H=Path(__file__).resolve().parent;ROOT=H.parents[3];B=H.parent/'tm_optimized';M=H.parents[1]/'mnist/tm_ppu_exact'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
verify_assets(compiled=True)
D=sorted((H/'demo_runs').iterdir())[-1]
records=[json.loads((D/'program/result.json').read_text())]+[json.loads(p.read_text())for p in sorted(D.glob('repeat_*/result.json'))]
assert len(records)==4 and all(r['passed'] and r['board_measurement']for r in records)
v=records[0]['validation'];ms=v['median_ms'];speed=v['speedup'];cycles=v['median_cycles']
assert all(r['validation']['median_cycles']==cycles for r in records),'repeat measurements differ'
assert json.loads((H/'unit_exact/result.json').read_text())['passed']
assert json.loads((H/'capture_validator_checks.json').read_text())['passed']
assert sha(H/'image_final/board_top.bit')==records[0]['bit_sha256']
assert sha(B/'image_demo1/board_top.bit')=='615ce60103ebe13914c6c6c0c9c51205b127a14c91a34c11203c0ca576320d3c'
custom=H.parent/'img_final/board_top.bit'
assert sha(custom)=='32a95adddef16e8c569c5bc55f9421ec683cb9697fd7c9f19ae7618732dc76cf'
# Make future firmware-only patching use this experiment's own verified DCP.
shutil.copy2(H/'firmware/firmware_itcm.mem',H/'image_final/firmware_itcm.mem')
p=H/'patch_itcm.py';s=p.read_text()
s=s.replace("H.parents[1]/'mnist/tm_ppu_exact/image_demo1/initial_firmware_itcm.mem'","H/'image_final/firmware_itcm.mem'")
s=s.replace("H.parents[1]/'mnist/tm_ppu_exact/image_demo1/routed_50mhz.dcp'","H/'image_final/routed_50mhz.dcp'")
s=s.replace("H.parents[1]/'mnist/tm_ppu_exact/image_demo1/result.json'","H/'image_final/result.json'")
p.write_text(s);shutil.copy2(H/'image_final/updated_init.txt',H/'itcm_dump.txt')
if not (H/'rtl_override').exists():shutil.copytree(M/'rtl_override',H/'rtl_override')
p=H/'test_kws_exact_ppu.py';s=p.read_text().replace("H.parents[1]/'mnist/tm_ppu_exact/rtl_override/src/rtl/post_processing_unit/ppu.v'","H/'rtl_override/src/rtl/post_processing_unit/ppu.v'");p.write_text(s)
now=datetime.datetime.now().astimezone();bit=sha(H/'image_final/board_top.bit');mem=sha(H/'firmware/firmware_itcm.mem')
summary=dict(passed=True,produced_at=now.isoformat(),protocol='VEX_TM_KWS3',model_sha256=sha(H/'model.bin'),input_sha256=sha(H/'input.bin'),cpu_reference_unchanged=True,word_documents_edited=False,verified_final_runs=4,verified_final_timing_samples=68,median_cycles=cycles,median_ms=ms,speedup=speed,bit_sha256=bit,firmware_mem_sha256=mem,baseline_bit_sha256=sha(B/'image_demo1/board_top.bit'),custom_bit_sha256=sha(custom),final_evidence=str(D),rtl_test=json.loads((H/'unit_exact/result.json').read_text()),capture_validator_cases=18)
(H/'checkpoint_summary.json').write_text(json.dumps(summary,indent=2))
report=f'''# TinyMaix KWS 优化实测与演示恢复

保存时间：{now.isoformat()}。

结论：当前同一 TinyMaix KWS 模型的热态整网加速比，从 6.68746 倍提升到 **{speed['3']:.5f} 倍**。NPU 热态时间从 41.25288 ms 降至 **{ms['3']:.5f} ms**，缩短 {100*(1-ms['3']/41.25288):.2f}%。Word 文档未修改。

## 最终板测

| 模式 | 周期中位数 | 耗时/ms | CPU/NPU |
|---|---:|---:|---:|
| TinyMaix CPU 稳态 | {cycles['0']} | {ms['0']:.5f} | 1 |
| NPU 首次调用 | {cycles['1']} | {ms['1']:.5f} | {speed['1']:.5f}× |
| NPU 指令缓存未命中 | {cycles['2']} | {ms['2']:.5f} | {speed['2']:.5f}× |
| NPU 指令缓存命中 | {cycles['3']} | {ms['3']:.5f} | {speed['3']:.5f}× |

平台为 XC7A100T，VexRiscv RV32IM，CPU/NPU 同为 50 MHz。计时包围完整 tm_run_cpu/tm_run；模型加载、输入预处理、显式清缓存、正确性检查和串口打印在计时外。CPU 剔除第一次调用后取五次中位数；首次 NPU 调用测一次，缓存未命中及命中各测五次。仍无持久权重驻留，首次调用包含量化计划建立，后续复用；指令缓存未命中不等于全部冷启动。

模型、权重、固定输入与 6.69 倍版本完全相同：9448 字节 MAIX、13 层、64×40×1 特征输入。CPU 原始算子函数及预处理后的 CPU 推理路径已与基准逐项核对。当前 CPU 为 {ms['0']:.5f} ms，基准为 275.87698 ms，微小周期差异来自固件重新链接及调用代码变化，没有更换或减速 CPU 参考算法。

## 本轮改动

1. 深度卷积按列生成窗口，将相邻窗口的重叠数据保存在 CPU 寄存器中，减少从 NPU 共享内存重复读回。
2. 复用已完成布局布线、50 MHz 时序通过的精确 Q8 PPU 硬件。8 层卷积的 120 个通道中，116 个通道执行硬件量化/ReLU；分母不在硬件支持范围内的 4 个通道继续执行原软件量化。每次推理仍有 11 次真实 NPU 提交和 4 次普通卷积硬件窗口调用。
3. 从冻结模型参数生成 GAP 与三个 FC 的精确量化函数表，保持原浮点表达式的 INT8 输出；CPU 参考路径保留。表大小 3364 字节，不缓存输入、激活、预测或整网输出。
4. 硬件输出按四个通道、四个位置使用 32 位读写和字节转置恢复 TinyMaix HWC 布局；保留软件量化通道的字节。

阶段板测热态倍数：6.68746× → 窗口优化 7.05718× → 数学函数优化 7.45329× → PPU 融合 8.729×左右 → 布局转换与最终整理 {speed['3']:.5f}×。各阶段原始记录保存在 board_baseline、board_profile、board_column、board_math、board_ppu、board_copy；最终结论以 demo_runs 下记录为准。

## 验证

- 最终版本重新烧录一次，连续发送 R 重测三次：四轮、68 个计时样本，各模式周期中位数一致。
- 每轮固定输入 13 层哈希与最终浮点位模式均与优化前冻结记录一致；额外六种输入也逐层、逐输出与原记录一致。固定输入最终概率为 {v['probabilities']}。
- 每轮计时外验证 256 个 GAP 值、3825 个 FC 阈值边界值和 3072 个随机 INT32 值，合计 7153 个数学用例。
- 每轮计时外执行 432 个布局转换用例，覆盖未对齐目标、尾部、混合软硬件通道、通道数和两种地址形式，并对照标量字节参考。
- 精确 PPU RTL 仿真通过 1290 组任务、56666 个数值样本，包括本模型全部 116 个硬件量化通道的系数、随机极值、边界长度和旧模式。
- 主机验证器接受真实最终日志，拒绝 18 种破坏日志，包括伪造倍数、缺失 PPU/自检、模型更换及 CPU/NPU 同时偏离原参考输出。

这是固定输入及压力输入的数值一致性与性能验证，不是完整 KWS 数据集准确率或实时录音端到端评估。

## 时序与工具

使用既有精确 PPU 布线检查点更新 ITCM，更新前后逐字核对 24576 个字。硬件原构建及本轮位流导出工具为 Vivado 2018.2；本轮实际烧录使用 Vivado 2026.1 和 127.0.0.1:3122。没有提高时钟。50 MHz setup 裕量 1.914 ns、hold 裕量 0.018 ns；不能宣称该版本可运行 100/150 MHz。固件 { (H/'firmware/firmware.bin').stat().st_size } 字节，BSS 38640 字节，链接器保留至少 8 KiB 栈。

## 拍摄与断电恢复

双击：`{H/'run_demo.cmd'}`。

脚本确认 XC7A100T、重新烧录 image_final/board_top.bit、采集真实串口、校验后显示 CPU/NPU 耗时和加速比。回车或 R 后回车重新测量，Q 退出。也可用串口助手 COM3、115200、8N1 发送 ASCII 字符 R。请关闭其他占用 COM3 的软件。

最终数值由本轮周期计算，没有写死 9.23 或 9.83。建议画面标注“TinyMaix KWS / 50 MHz / 完整推理 / NPU 指令缓存命中”；同时展示首次和缓存未命中数据。当前 FPGA 运行此版 TinyMaix KWS，等待 R；JTAG 配置位于 SRAM，未写启动 Flash，断电后运行上述入口恢复。

原 tm_optimized 约 6.69 倍版本、原版 edge_infer 的 img_final 位流以及 MNIST 固件均保留。

## 与文档的关系

当前热态 {speed['3']:.5f} 倍超过原文 9.23 倍这一加速比数值，但原文 CPU/NPU 时间为 163.99/17.77 ms，而本轮为 {ms['0']:.5f}/{ms['3']:.5f} ms，且缺少论文原始模型及缓存条件证据，不能称为同条件复现。正文可写“当前 XC7A100T 移植实现实测约 9.83 倍”，并列出模型、频率和缓存条件；不能照搬原文绝对耗时。MNIST 本轮未优化，其 TinyMaix 结果仍约 5.75 倍。

最终位流 SHA256：`{bit}`。

最终固件 MEM SHA256：`{mem}`。

模型 SHA256：`{sha(H/'model.bin')}`。

最终原始证据：`{D}`，含一次烧录记录、三次 UART 重跑、每轮原始 uart.txt 和 result.json。源码、函数表生成器、测试和构建记录均在本实验目录；固件更新应以本目录 image_final 的精确 PPU DCP 为基底，不能换回原无精确 PPU 的布线检查点。
'''
(H/'进度与恢复.md').write_text(report,encoding='utf-8')
report_path=Path(r'D:\技术文档\TinyMaix_KWS优化实测_20261030.md');report_path.write_text(report,encoding='utf-8')
files=set()
for d in ['source','firmware','image_final','demo_runs','rtl_override']:
    files.update(p for p in (H/d).rglob('*')if p.is_file()and '__pycache__'not in p.parts)
files.update(p for p in H.iterdir()if p.is_file())
for d in ['board_baseline','board_profile','board_column','board_math','board_ppu','board_copy']:
    files.update(p for p in (H/d).rglob('*')if p.is_file()and p.suffix not in ['.wdb','.jou'])
files.update(p for p in (H/'unit_exact').iterdir()if p.is_file()and p.suffix in ['.mem','.txt','.sv','.tcl','.json','.log'])
files.update(p for p in (B/'source').rglob('*')if p.is_file())
files.update([B/'board_demo1/result.json',ROOT/'board/program_2018_2.tcl'])
archive=ROOT/'checkpoints'/('kws_tinymaix_'+now.strftime('%Y%m%d_%H%M%S')+'.zip')
manifest={str(p.relative_to(ROOT)):sha(p)for p in sorted(files)}
with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=3)as z:
    for p in sorted(files):z.write(p,p.relative_to(ROOT).as_posix())
    z.writestr('checkpoint_manifest.json',json.dumps(manifest,indent=2))
    z.write(report_path,'reports/'+report_path.name)
with zipfile.ZipFile(archive)as z:
    assert z.testzip() is None,'archive CRC failed'
    for name,value in manifest.items():assert hashlib.sha256(z.read(name.replace('\\','/'))).hexdigest()==value,name
receipt=dict(passed=True,archive=str(archive),archive_bytes=archive.stat().st_size,sha256=sha(archive),files_verified=len(manifest))
(H/'checkpoint_archive.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(dict(summary=summary,archive=receipt,report=str(report_path)),indent=2))
