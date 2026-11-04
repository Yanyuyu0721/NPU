# XC7A100T VexRiscv TinyMaix inference

本包为AMD 2026自主选题高级组工程，按选题指南3.3.5整理。平台统一为正点原子达芬奇Pro A7-100T，器件xc7a100tfgg484-2。片内VexRiscv RV32IM软核与NPU同为50 MHz，采用TinyMaix推理路径，运行MNIST与三分类KWS。2026年11月2日使用Vivado 2026.1重新综合、布局布线、生成演示位流并完成上板复测。

## 运行演示

双击run.cmd弹出原生Tkinter窗口；run_mnist.cmd和run_kws.cmd分别进入两项任务。FPGA上电并连接JTAG和串口，选择COM3（CH340），点击“加载并连接”。切换模型时重新加载对应固件；更换输入无需烧录。配置加载到SRAM，断电后重新加载。

MNIST支持鼠标、触控、Windows Ink手绘板及图片导入。KWS支持音频文件、录音、回放，类别为Hi xiaowen、Nihao wenwen、Background。界面显示实际CPU/NPU耗时、加速比、首次与缓存状态，输入变化可能使耗时略有变化。可选网页入口为python tools/tinymaix_live_gui/launch.py，与原生窗口共享后端。

## 同一模型与输入的板测

| 任务 | CPU ms | 首次NPU ms | 指令流未命中 ms | NPU热缓存 ms | 热缓存加速比 |
|---|---:|---:|---:|---:|---:|
| MNIST | 22.96778 | 5.19508 | 2.29884 | 1.95034 | 11.7763× |
| KWS | 275.87612 | 38.64252 | 31.79060 | 28.06528 | 9.8298× |

数据来自data/benchmark.json。每项任务重新加载本包位流后重复两轮，原始UART和输入保存在tools/tinymaix_live_gui/runs/，收据见build/reports/board_retest_20261102.json。CPU为片内VexRiscv，计时覆盖完整tm_run_cpu/tm_run。CPU运行6次、舍弃首次后取5次中位数；NPU首次1次、指令流未命中及热缓存各5次。模型加载、预处理、串口传输、显式缓存失效和校验不计入。各轮最终分数和全部中间层输出一致。

MNIST后两档复用权重、配置和量化计划；KWS无持久权重复用。未命中不代表全部冷启动。新输入会重置模型相关缓存，不缓存输入、激活或预测结果。

## XC7A100T实现结果

整套系统布线后资源：LUT 41174/63400（64.94%），FF 38150/126800（30.09%），BRAM 134.5/135（99.63%），DSP 212/240（88.33%）。统计包含VexRiscv、NPU、片上存储和互连。50 MHz时WNS为2.96 ns，WHS为0.036 ns。

Vivado布线后估算片上总功耗0.429 W，动态0.325 W，器件静态0.104 W。采用默认开关活动与25°C默认散热模型，无SAIF文件；此项是FPGA片上估算，未计开发板外设和电源损耗。原始报告和文件身份见build/reports/implementation_20261102.json。

为在Vivado 2026.1下保持A7器件资源可容纳，阵列行FIFO、命令FIFO与PPU通道0至6显式使用分布式RAM，队列容量保持不变。全局缓存IP的时钟参数已统一为50 MHz。历史构建证据位于build/out/mnist与build/out/kws；当前有效布局只使用build/out/xc7a100t_20261102。

## 正式材料

- report/design_report.docx与report/design_report.pdf：XC7A100T设计报告，两种格式内容一致。
- report/technical_paper.docx：XC7A100T技术论文。
- report/presentation.pptx：6页答辩稿。
- report/collaboration_record.json与collaboration_notes.md：协作记录及说明。

文档、PPT中的平台、资源、时序、功耗和模型性能采用本版数据。

## 新电脑环境

在项目根目录打开终端。安装Python 3.12（包含Tkinter）及requirements.txt中的依赖、RISC-V RV32IM/ILP32 GCC、Vivado 2026.1。原生启动器及板卡加载按Windows环境验证。例：

```bat
python -m venv .venv
.venv\Scripts\python -m pip install -r requirements.txt
set TINYMAIX_PYTHON=%CD%\.venv\Scripts\python.exe
set TINYMAIX_GCC=C:\tools\riscv\bin\riscv-none-elf-gcc.exe
set TINYMAIX_VIVADO=C:\amd\2026.1\Vivado\bin\vivado.bat
set TINYMAIX_PATCH_VIVADO=C:\amd\2026.1\Vivado\bin\vivado.bat
run.cmd
```

本次实测环境为Python 3.12.14、NumPy 2.3.5、Pillow 12.3.0、pyserial 3.5、sounddevice 0.5.6、soundfile 0.14.0，编译器为xPack RISC-V GCC 15.2.0。安装依赖后运行verify_host.py核对音频特征哈希与预处理行为。

本机启动器可使用已有Python与串口包回退路径。其他电脑正常安装依赖，关闭其他占用串口的程序。

## 重建

```bat
C:\amd\2026.1\Vivado\bin\vivado.bat -mode batch -source board/rebuild_hardware.tcl -tclargs build/out/hardware_rebuild xc7a100tfgg484-2
python build/rebuild_live.py --task mnist --out build/out/rebuild_mnist
python build/rebuild_live.py --task kws --out build/out/rebuild_kws
```

输出目录必须全新。硬件源码为src/hardware，平台和引脚约束位于board/。重建脚本只接受xc7a100tfgg484-2并以50 MHz实现，输出综合、实现、时序、功耗和DRC报告。固件重建从src/software和共享main_live.c生成ELF/BIN/ITCM，通过build/patch_itcm.py将程序写入本包当前有效DCP，并逐字校验24576字旧、新ITCM内容后导出位流。

若采用重新布局后的DCP更新固件，需要同时更新build/out/xc7a100t_20261102中的routed_50mhz.dcp、firmware_itcm.mem、itcm_dump.txt和result.json，再执行固件重建。现成两模型演示位流位于tools/tinymaix_live_gui/firmware/<task>/image/board_top.bit。板级program.tcl检查实际器件身份，固件加载前检查位流和模型身份。

## 校验

```bat
python build/check_package.py
python sim/validate_saved_runs.py
python skill/scripts/selfcheck.py
python tools/tinymaix_live_gui/verify_host.py
```

保存记录验证重新解析真实UART；Skill自检验证校验工具行为，不代表重新执行RTL仿真。DSP流水线相关DRC警告在原始报告中保留。

## 目录

| 目录 | 内容 |
|---|---|
| src/ | 有效RTL与两模型TinyMaix固件算子 |
| sim/ | 保存记录验证入口与功能验证证据 |
| build/ | 重建入口、当前DCP、综合实现及板测报告 |
| board/ | 器件身份、50 MHz约束、平台与JTAG加载 |
| data/ | 冻结模型、输入、WAV与板测结果 |
| skill/ | 可复用的身份绑定、超时及逐字比较工具 |
| report/ | 两份Word、答辩稿、双语海报及两份协作材料 |
| tools/ | 原生上位机、实时位流与原始UART记录 |

优化前后推理性能和Vivado 2026.1存储映射资源对比见report/collaboration_notes.md，原始数据见data/optimization_baseline/及build/reports/。

README.md只保留根目录与skill/目录两份。提交包不含guideline.pdf。原始工程及早期版本旁置归档，许可与第三方说明保留。
