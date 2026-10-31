# Third-party notices

This is a local migration package. No repository or competition submission was published by this workflow.

| Component | Location and evidence | License / disposition |
|---|---|---|
| TinyMaix | Sipeed copyright headers in common TinyMaix implementation and app port headers | Apache-2.0. Keep headers and `licenses/apache_2_0.txt`. Modifications retain this license. |
| AXI DMA/CDMA/crossbar/RAM | Alex Forencich copyright and full permission text embedded in RTL | MIT. Preserve per-file notices, including on modified files. |
| Nuclei FIFO cell | `src/rtl/common_cells/fifo/gnrl_dfflr.v` | Apache-2.0, original copyright retained. |
| SpinalHDL/VexRiscv extension | `src/extensions/vexriscv/LICENSE`, Scala and generated RTL | Repository-provided MIT text retained. Generated/vendor components must retain their own headers. Extension remains outside main ARM acceptance. |
| AMD/Xilinx application support | `platform.c/.h`, time headers, CMake support | Preserve the exact per-file terms. Older platform files restrict use to applications running on or interacting with Xilinx devices; the root MIT notice does not replace them. |
| AMD IP and tool-generated outputs | Vivado/XPM/PS/IP dependencies supplied by installed tools | Not redistributed as tool binaries. The installed AMD tool/IP terms apply. Tcl parameters and source-controlled integration are included. |
| Original NPU/custom code | Pinned remote revision and imported local application files in `report/source_manifest.json` | No repository-wide license was found. User authorized local use and modification; public redistribution rights remain to be confirmed with the rights holders. Do not apply root MIT to these files. |
| Model weights and fixtures | Registry active model headers and `data/test_inputs/manifest.json` | Deployment/numeric fixtures only. Training lineage and redistribution rights are not established by this migration. Review before public release. |
| Python/EDA/compiler dependencies | `src/host/requirements.txt` and recorded tool versions | Install independently; toolchains and environment packages are excluded from the clean archive. |

Existing notices are evidence, not a claim that all upstream rights have been audited. The MIT scope above covers new original migration work only. The clean archive remains a review package while original/custom-code and dataset rights are unresolved.

## Public labeled evaluation data

Benchmark media are downloaded for local validation and are excluded from the clean submission ZIP. The package retains source/selection/label manifests, upstream revisions and checksums, preparation code, and measured results. Predictions never supply ground truth. Preparation does not replace each source's applicable terms.

| Dataset | Source and use | Applicable notice |
|---|---|---|
| MNIST | [CVDF mirror](https://github.com/cvdfoundation/mnist), complete 10,000-image published test split | Preserve original MNIST attribution; the mirror identifies the original dataset authors. |
| EMNIST Balanced | [NIST](https://www.nist.gov/itl/products-and-services/emnist-dataset), complete 18,800-image test split and official 47-label mapping | NIST/public dataset terms; cite Cohen et al., EMNIST, 2017. IDX axes are transposed to upright glyphs before frontend processing. |
| CIFAR-10 | [Author's dataset page](https://www.cs.toronto.edu/~kriz/cifar.html), complete 10,000-image test split | Cite Krizhevsky, Learning Multiple Layers of Features from Tiny Images, 2009. Author-published archive MD5 is checked. |
| ImageNetV2 | [Author repository](https://github.com/modestyachts/ImageNetV2) and its linked [author mirror](https://huggingface.co/datasets/vaishaal/ImageNetV2), complete MatchedFrequency test set | Repository MIT covers code, not image data; individual Flickr image rights remain applicable. Media are not bundled. Cite Recht et al., Do ImageNet Classifiers Generalize to ImageNet?, 2019. |
| EuroSAT RGB | [Author Zenodo record v2](https://zenodo.org/records/7711810), all four model target categories | Author repository states MIT; Copernicus Sentinel terms also apply. Published archive MD5 is checked. No independent holdout is inferred. Cite Helber et al., EuroSAT, 2019. |
| MobvoiHotwords | [OpenSLR 87](https://www.openslr.org/87/), 50 officially annotated test utterances per keyword/negative category | Apache-2.0; preserve attribution to Mobvoi and the OpenSLR dataset authors. |
| Speech Commands v0.02 | [Google dataset](https://huggingface.co/datasets/google/speech_commands), published test archive linked by its dataset loader, ten model target English categories | CC-BY-4.0; cite Pete Warden, Speech Commands: A Dataset for Limited-Vocabulary Speech Recognition, 2018. |
| TT100K crops | [Derivative author repository](https://github.com/fengwm64/TT100K_Cropped), pinned test crops in the 19 target categories; [original dataset](https://cg.cs.tsinghua.edu.cn/traffic-sign/) | Original TT100K images are CC-BY-NC; derivative code MIT does not replace image terms. Media are not bundled. Cite Zhu et al., Traffic-Sign Detection and Classification in the Wild, 2016. |

## Newly trained RTL models

`data/models/retrained/` contains newly trained weights for MNIST, Mobvoi
Hotwords and the pinned 19-class TT100K crop mapping. This lineage is distinct
from the historical deployment headers above. Training uses only the declared
train/validation partitions; each exported contract binds its checkpoint and
manifest hashes. Test counts are MNIST 10000, Mobvoi balanced 3000, traffic
2319. Raw training/test corpora and tool binaries remain outside the ZIP;
manifests, download/selection code and original attribution remain included.
The TT100K noncommercial/attribution terms also constrain use of derived
artifacts. Mobvoi attribution and Apache-2.0 text are retained. PyTorch 2.7.1
is installed independently from the official wheel and is not redistributed
as part of the submission. Verilator, MinGW GCC and NVIDIA runtimes are also
external dependencies; recorded versions and commands accompany the tests.

## Local EES331 deployment handoff

This private handoff additionally bundles the user-provided EES331 manual, generated
bit/XSA/PS initialization, the SDK2018.3 Cortex-A9 BSP project, and unmodified
Python wheels (NumPy BSD, Pillow HPND, pySerial BSD, license files inside each wheel).
The current deploy ELF and bundled Unified platform/BSP/application are genuine
Vitis Embedded2026.1 builds; the older SDK2018.3 artifacts remain as a compatibility
archive. Installed AMD tools and toolchain executables are excluded. Generated AMD artifacts
and BSP sources retain AMD terms and are intended for the documented AMD device.
The board manual remains vendor material; copying into this private workspace does
not confer public redistribution rights. No public package has been published.
