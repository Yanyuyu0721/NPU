# Reusable FPGA verification workflow

适用于具有固定源码、模型/系数、初始化存储器和独立参考的 FPGA 数据通路，可迁移到 DSP、定点计算和包处理。Python 3.10+ 与标准库即可运行工具；仿真器、数值参考和板卡驱动由使用者提供。

## 用法

1. 运行前冻结源码、参考和完整初始化存储器，用 scripts/file_manifest.py 创建清单，在运行前后验证哈希。示例：

```text
python skill/scripts/file_manifest.py create --root . --manifest ../inputs.json --files src/hardware/src/rtl/post_processing_unit/ppu.v data/mnist/input.bin
python skill/scripts/file_manifest.py verify --root . --manifest ../inputs.json
```

2. 用 scripts/capture_run.py 执行有限时长的自检。只有正常退出、唯一精确完成标志、没有错误标志、输入源码未改变时才接受。输出目录必须全新；参数见 --help。
3. 用 scripts/compare_words.py 比较完整数值、保护区域和零填充。长度不符、X/Z、稀疏寻址或数据越界均拒绝。浮点输出可按原始 32 位字比较，不能用四舍五入掩盖差异。
4. 为自己的工程补充输入长度、请求号、实际提交/完成计数、在途任务和缓存状态检查。包装器通过只证明明确检查的内容，不代表算术、RTL 时序或板级功能都通过。

## 来源和已验证效果

先前 PPU 描述符接收/完成边界故障说明必须同时检查接收数、存储数和 pending；旧固件或错误模型可能给出看似合理的倍数，因此输入、模型、镜像、计时边界和参考输出必须绑定。超时或缺失阶段不能生成整网成功记录，CPU/NPU 同时偏离冻结参考也不能通过。WAV 经浏览器重采样会改变特征，说明预处理同样属于数值契约。

`python skill/scripts/selfcheck.py` 已实际执行 18 项正反例，覆盖源码变化、路径逃逸、零区改变、输出缩短、空文件、部分/重复 PASS、错误后 PASS、非零退出和有限超时。收据见 ../build/reports/validation_summary.json。这是工具行为验证，不是 RTL 或板卡收据。

主机板测解析器位于 ../tools/tinymaix_live_gui/protocol.py，依赖 TMLIVE1；迁移到其他工程必须自行适配协议，不把该实现当作通用驱动。本技能不加载位流、不安装 EDA，不宣称 PYNQ 专用加分项。

## 失效条件

源码、模型、精度、布局改变，参考不独立，浮点路径不确定，清单遗漏依赖，或协议缺少完整完成语义时，原结论失效。须审查新契约并重新验证，不能用失败 DUT 的输出更新黄金参考。完整清单之外新增文件不会被局部哈希工具自动保护，需结合根目录包自检。
