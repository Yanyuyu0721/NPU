# Third-party notices

This inventory describes components present in this XC7A100T / VexRiscv / TinyMaix package. The root license covers original migration utilities, tests and documents only. Imported or derived components retain their original notices and terms.

| Component | Packaged location | Retained notice |
|---|---|---|
| TinyMaix | src/software/mnist/ and src/software/kws/, including tm_model.c, tm_layers.c and TinyMaix headers | Sipeed copyright and Apache-2.0 headers. The license text is in licenses/apache_2_0.txt. |
| AXI DMA, CDMA, crossbar and RAM infrastructure | src/hardware/src/rtl/axi_dma/, axi_cdma/, axi_crossbar/ and common_cells/ram/ | Alex Forencich copyright and MIT permission text remain in the relevant files. |
| Nuclei FIFO support cell | src/hardware/src/rtl/common_cells/fifo/gnrl_dfflr.v | Nuclei copyright and Apache-2.0 header remain in the source. |
| Generated VexRiscv RTL | src/hardware/src/extensions/riscv_rtl/riscv_cpu.v | The original SpinalHDL generator version and Git hashes remain in the file header. No separate upstream license file for this generated RTL is present in the imported source subset. |
| AMD IP and generated device artifacts | board/platform/global_buffer.tcl, XPM integration, checkpoint and bitstream files | AMD tools and IP remain subject to their supplied terms. Tool executables are installed independently and are not bundled. |
| Original NPU RTL and application adaptations | src/hardware/ and src/software/ | Standalone personal author-comment fields are anonymized; required copyright and license notices are retained. The root migration license does not assign a new license to imported code lacking an identified license notice. |
| Models and numeric fixtures | data/mnist/, data/kws/, data/audio/ and matching tools/tinymaix_live_gui/firmware/ assets | Model provenance and hashes are retained in baseline.json and firmware provenance.json. These are supplied deployment models and fixtures, not a newly trained model collection or a bundled evaluation dataset. |
| Python dependencies | requirements.txt | NumPy, Pillow, pyserial, sounddevice and soundfile are installed independently and retain their own licenses. Their tested versions are recorded in the root README.md. |

The active build uses the VexRiscv adapter vex_hal.c. Upstream compatibility files such as npu_zynq.c and npu_board_impl.c are retained with the frozen source subset but are not compiled by build/rebuild_live.py. They do not add a Cortex-A9 BSP or an ARM deployment to this package.

Only MNIST and the three-class KWS deployment are included in the active demo. No EMNIST, CIFAR-10, ImageNetV2, EuroSAT, traffic-sign training package, EES331 board manual or Cortex-A9 BSP is claimed as a submitted asset.
