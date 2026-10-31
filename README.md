# VexRiscv TinyMaix FPGA inference

本包对应 AMD 2026 自主选题高级组，按选题指南 3.3.5 推荐结构整理。本次最终演示选用 XC7A100T，运行 MNIST CNN 与三分类 KWS CNN，采用 TinyMaix CPU/NPU 路径，均为 50 MHz。文档保留原有 Zynq-7020 测试、功耗、资源及设计内容，仅局部更新这两个模型的性能数据与对应条件。目录和文件名使用英文；中文只用于内容。

## 先运行演示

本机直接双击 `run.cmd`，弹出 Tkinter 独立窗口，不会打开浏览器。也可双击 `run_mnist.cmd` 或 `run_kws.cmd`，直接进入对应页签。FPGA 上电、连接 JTAG 与串口后，选择 COM3（CH340）、模型，点击“加载并连接”。切换模型需要重新加载对应固件；每次更换手写或音频输入无需重新烧录。配置位于 FPGA SRAM，断电后重新加载，不写 Flash。

MNIST 支持鼠标、触控、Windows Ink 手绘板笔压及图片导入；KWS 支持文件、麦克风选择、录音和回放。当前模型有 Hi xiaowen、Nihao wenwen、Background 三类。原生窗口的画板、WAV 导入、录音、播放及两模型上板链路已验证。原有浏览器入口保留为可选方式：运行 `python tools/tinymaix_live_gui/launch.py`。两种界面共享同一推理后端。

## 当前固定样例实测

| 任务 | CPU ms | NPU 首次 ms | 指令流未命中 ms | NPU 热缓存 ms | 热缓存加速比 |
|---|---:|---:|---:|---:|---:|
| MNIST CNN | 22.96778 | 5.19508 | 2.29884 | 1.95034 | 11.7763× |
| KWS CNN | 275.87612 | 38.64252 | 31.79060 | 28.06528 | 9.8298× |

这是从本目录重新烧录并上传固定输入得到的结果，原始数据见 `data/benchmark.json` 和其中指向的包内 `tools/tinymaix_live_gui/runs/`。CPU 为 FPGA 内的 VexRiscv，不是上位机 CPU。计时包围完整 tm_run_cpu/tm_run；CPU 舍弃首次后取 5 次中位数，NPU 首次 1 次、指令流未命中/命中各 5 次。模型加载、预处理、显式缓存失效、串口和校验不计入。主界面显示热缓存结果，同时显示另外两档。

MNIST 首次装载权重，后两档复用权重、配置与量化计划。KWS 没有持久权重复用。未命中不等于全部冷启动；每个新输入重置模型相关缓存。没有缓存输入、激活或预测。不同输入的耗时略有变化，界面不会固定显示上表倍数。

## 正式材料

- `report/design_report.docx`：更新后的设计报告（原文档迁移）。
- `report/technical_paper.docx`：原稿基础上局部更新的技术论文。
- `report/presentation.pptx`：6 页可编辑答辩稿，保留原图、资源分析及版式，更新 MNIST/KWS 实测数据。
- `report/collaboration_record.json`：真实可见交互记录节选。
- `report/collaboration_notes.md`：优化、自我纠错及技能提炼说明。

原文件未覆盖。所有原工程、文档、历史失败、缓存与中间版本已在旁置 `D:/vexriscv_tinymaix_archive_20261030/original_snapshot.zip` 全量归档，9189 个文件；它不属于精简提交包。历史证据中的绝对路径是当时来源标签，当前入口只从包内读取项目资产。

## 从新电脑复现

安装 Python 3.10 或以上（包含 Tkinter）及 requirements.txt 中的 NumPy、Pillow、pyserial、sounddevice、soundfile；安装 RISC-V RV32IM/ILP32 GCC、Vivado。例：

```bat
python -m venv .venv
.venv\Scripts\python -m pip install -r requirements.txt
set TINYMAIX_PYTHON=%CD%\.venv\Scripts\python.exe
set TINYMAIX_GCC=C:\tools\riscv\bin\riscv-none-elf-gcc.exe
set TINYMAIX_VIVADO=C:\amd\2026.1\Vivado\bin\vivado.bat
set TINYMAIX_PATCH_VIVADO=C:\amd\2018.2\Vivado\bin\vivado.bat
run.cmd
```

本机启动器优先使用已有 bundled Python；其他电脑使用 TINYMAIX_PYTHON 或 PATH 中的 Python。串口缺少 pyserial 时，本机保留原 Miniconda 回退目录；新机器正常安装 pyserial 即可。关闭其他占用串口的程序。

### 固件与位流重建

```bat
python build/rebuild_live.py --task mnist --out build/out/rebuild_mnist
python build/rebuild_live.py --task kws --out build/out/rebuild_kws
```

输出目录必须全新。重建从 src/software 复制冻结算子，使用共享实时入口 `tools/tinymaix_live_gui/main_live.c`；生成 ELF、BIN、24576 字 ITCM、位流及收据。更新前后逐字核对 ITCM。现成演示位流位于 `tools/tinymaix_live_gui/firmware/<task>/image/board_top.bit`，模型和镜像身份校验通过后才允许加载。

本次有效硬件布局布线及 ITCM 位流导出使用 **Vivado 2018.2**，板卡加载使用 **Vivado 2026.1**。指南允许说明并保证复现的其他版本，本包据此声明版本差异；未声称用 2026.1 从 RTL 重建了当前布局布线。若改工具版本，必须重新检查数值、资源和时序。

从 RTL 重建现有精确 PPU 硬件，使用全新输出目录：

```bat
C:\amd\2018.2\Vivado\bin\vivado.bat -mode batch -source board/rebuild_hardware.tcl -tclargs build/out/hardware_rebuild xc7a100tfgg484-2
```

活动 RTL 在 src/hardware，平台与约束在 board/platform 与 board/board_pins.xdc。当前仓内 DCP 已重新导出资源、50 MHz 时序及 DRC 报告，见 build/reports；旧实现过程及输入绑定见 build/out/mnist/tm_ppu_exact/image_demo1。DSP 流水线 DRC 警告按原始报告保留，不能写成所有规则零告警。

### 校验

```bat
python build/check_package.py
python sim/validate_saved_runs.py
python skill/scripts/selfcheck.py
python tools/tinymaix_live_gui/verify_host.py
```

包自检核对文件清单、模型、镜像、源代码身份和路径命名；保存记录校验会重新解析 CPU/NPU 分数、全层哈希和缓存状态。Skill 的 18 项正反例只证明校验工具行为，不能冒充 RTL 验证。真实重新测量请运行 GUI；每次输入的原始 UART、输入字节和 JSON 都保存至 runs/。

## 目录对照

| 推荐目录 | 本包内容 |
|---|---|
| src/ | 现有有效 RTL、两模型 TinyMaix 固件算子 |
| sim/ | 保存记录验证入口、现有验证证据索引 |
| build/ | 重建入口、原始 DCP、综合实现/时序/DRC 报告 |
| board/ | 器件身份、引脚、平台、JTAG 加载与硬件重建入口 |
| data/ | 冻结模型、输入、WAV、原始 CPU/NPU 实测和优化基线 |
| skill/ | 可复用的身份绑定、负例、有限超时与逐字比较工具 |
| report/ | 两份正式 Word、答辩稿、协作记录与说明 |
| tools/ | 实时上位机、实时位流与逐轮板测记录 |

## 本次演示实现

随包 XC7A100T 检查点的整套系统资源为 LUT 40968/63400，FF 33727/126800，BRAM 134.5/135，DSP 212/240。50 MHz setup +1.914 ns、hold +0.018 ns。原文中的 Zynq-7020、150 MHz、资源和功耗数据按原稿保留；本次演示采用上述 XC7A100T 配置。

每轮 CPU/NPU 输出一致性检查和原始 UART 记录继续保留。许可和第三方说明原样保留。

## 提交包说明

目录依据选题指南第3.3.5节整理，README.md仅保留根目录（项目简介与复现步骤）和skill/目录（技能使用说明）两份。report/保留两份正式Word、答辩PPT和协作记录、协作说明，共5个文件；指南PDF、整理日志和额外核对清单移出提交包。

板级入口为board/program.tcl，检查实际XC7A100T器件并通过Vivado 2026.1加载SRAM；RTL及其2018.2兼容BRAM初始化实现已冻结在src/hardware。保存记录验证入口sim/validate_saved_runs.py会核对原始UART结果；精确PPU的源码和验证证据位于build/out/mnist/tm_ppu_exact及sim/evidence。各子目录的运行说明统一见本文件，技能使用方法见skill/README.md。
