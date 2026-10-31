// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : riscv_cpu
// Git hash  : 3d057743f1f6d76f9573642909319f6825887364

`timescale 1ns/1ps

module riscv_cpu (
  input  wire          io_asyncReset,
  input  wire          io_axiClk,
  output wire          io_uart_txd,
  input  wire          io_uart_rxd,
  input  wire          io_coreInterrupt,
  output wire          io_ramAxi_aw_valid,
  input  wire          io_ramAxi_aw_ready,
  output wire [31:0]   io_ramAxi_aw_payload_addr,
  output wire [3:0]    io_ramAxi_aw_payload_id,
  output wire [3:0]    io_ramAxi_aw_payload_region,
  output wire [7:0]    io_ramAxi_aw_payload_len,
  output wire [2:0]    io_ramAxi_aw_payload_size,
  output wire [1:0]    io_ramAxi_aw_payload_burst,
  output wire [0:0]    io_ramAxi_aw_payload_lock,
  output wire [3:0]    io_ramAxi_aw_payload_cache,
  output wire [3:0]    io_ramAxi_aw_payload_qos,
  output wire [2:0]    io_ramAxi_aw_payload_prot,
  output wire          io_ramAxi_w_valid,
  input  wire          io_ramAxi_w_ready,
  output wire [31:0]   io_ramAxi_w_payload_data,
  output wire [3:0]    io_ramAxi_w_payload_strb,
  output wire          io_ramAxi_w_payload_last,
  input  wire          io_ramAxi_b_valid,
  output wire          io_ramAxi_b_ready,
  input  wire [3:0]    io_ramAxi_b_payload_id,
  input  wire [1:0]    io_ramAxi_b_payload_resp,
  output wire          io_ramAxi_ar_valid,
  input  wire          io_ramAxi_ar_ready,
  output wire [31:0]   io_ramAxi_ar_payload_addr,
  output wire [3:0]    io_ramAxi_ar_payload_id,
  output wire [3:0]    io_ramAxi_ar_payload_region,
  output wire [7:0]    io_ramAxi_ar_payload_len,
  output wire [2:0]    io_ramAxi_ar_payload_size,
  output wire [1:0]    io_ramAxi_ar_payload_burst,
  output wire [0:0]    io_ramAxi_ar_payload_lock,
  output wire [3:0]    io_ramAxi_ar_payload_cache,
  output wire [3:0]    io_ramAxi_ar_payload_qos,
  output wire [2:0]    io_ramAxi_ar_payload_prot,
  input  wire          io_ramAxi_r_valid,
  output wire          io_ramAxi_r_ready,
  input  wire [31:0]   io_ramAxi_r_payload_data,
  input  wire [3:0]    io_ramAxi_r_payload_id,
  input  wire [1:0]    io_ramAxi_r_payload_resp,
  input  wire          io_ramAxi_r_payload_last,
  output wire          io_externalAxi_aw_valid,
  input  wire          io_externalAxi_aw_ready,
  output wire [31:0]   io_externalAxi_aw_payload_addr,
  output wire [3:0]    io_externalAxi_aw_payload_id,
  output wire [3:0]    io_externalAxi_aw_payload_region,
  output wire [7:0]    io_externalAxi_aw_payload_len,
  output wire [2:0]    io_externalAxi_aw_payload_size,
  output wire [1:0]    io_externalAxi_aw_payload_burst,
  output wire [0:0]    io_externalAxi_aw_payload_lock,
  output wire [3:0]    io_externalAxi_aw_payload_cache,
  output wire [3:0]    io_externalAxi_aw_payload_qos,
  output wire [2:0]    io_externalAxi_aw_payload_prot,
  output wire          io_externalAxi_w_valid,
  input  wire          io_externalAxi_w_ready,
  output wire [31:0]   io_externalAxi_w_payload_data,
  output wire [3:0]    io_externalAxi_w_payload_strb,
  output wire          io_externalAxi_w_payload_last,
  input  wire          io_externalAxi_b_valid,
  output wire          io_externalAxi_b_ready,
  input  wire [3:0]    io_externalAxi_b_payload_id,
  input  wire [1:0]    io_externalAxi_b_payload_resp,
  output wire          io_externalAxi_ar_valid,
  input  wire          io_externalAxi_ar_ready,
  output wire [31:0]   io_externalAxi_ar_payload_addr,
  output wire [3:0]    io_externalAxi_ar_payload_id,
  output wire [3:0]    io_externalAxi_ar_payload_region,
  output wire [7:0]    io_externalAxi_ar_payload_len,
  output wire [2:0]    io_externalAxi_ar_payload_size,
  output wire [1:0]    io_externalAxi_ar_payload_burst,
  output wire [0:0]    io_externalAxi_ar_payload_lock,
  output wire [3:0]    io_externalAxi_ar_payload_cache,
  output wire [3:0]    io_externalAxi_ar_payload_qos,
  output wire [2:0]    io_externalAxi_ar_payload_prot,
  input  wire          io_externalAxi_r_valid,
  output wire          io_externalAxi_r_ready,
  input  wire [31:0]   io_externalAxi_r_payload_data,
  input  wire [3:0]    io_externalAxi_r_payload_id,
  input  wire [1:0]    io_externalAxi_r_payload_resp,
  input  wire          io_externalAxi_r_payload_last,
  output wire          io_axiLite_aw_valid,
  input  wire          io_axiLite_aw_ready,
  output wire [31:0]   io_axiLite_aw_payload_addr,
  output wire [2:0]    io_axiLite_aw_payload_prot,
  output wire          io_axiLite_w_valid,
  input  wire          io_axiLite_w_ready,
  output wire [31:0]   io_axiLite_w_payload_data,
  output wire [3:0]    io_axiLite_w_payload_strb,
  input  wire          io_axiLite_b_valid,
  output wire          io_axiLite_b_ready,
  input  wire [1:0]    io_axiLite_b_payload_resp,
  output wire          io_axiLite_ar_valid,
  input  wire          io_axiLite_ar_ready,
  output wire [31:0]   io_axiLite_ar_payload_addr,
  output wire [2:0]    io_axiLite_ar_payload_prot,
  input  wire          io_axiLite_r_valid,
  output wire          io_axiLite_r_ready,
  input  wire [31:0]   io_axiLite_r_payload_data,
  input  wire [1:0]    io_axiLite_r_payload_resp
);

  wire       [4:0]    axi_uartCtrl_io_apb_PADDR;
  wire                axi_core_cpu_iBus_rsp_payload_error;
  wire                axi_core_cpu_dBus_cmd_ready;
  wire                axi_core_cpu_dBus_rsp_error;
  wire       [31:0]   axi4ReadOnlyDecoder_io_input_ar_payload_addr;
  wire       [2:0]    axi4SharedDecoder_io_input_arw_payload_size;
  wire       [3:0]    axi4SharedDecoder_io_input_w_payload_strb;
  reg                 axi4SharedDecoder_io_input_r_ready;
  wire       [19:0]   axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr;
  wire                axi_apbBridge_io_axi_arbiter_io_output_arw_ready;
  wire                axi_apbBridge_io_axi_arbiter_io_output_w_ready;
  wire                axi_ramBridge_io_shared_arbiter_io_output_arw_ready;
  wire                axi_extBridge_io_shared_arbiter_io_output_arw_ready;
  wire                axi_liteBridge_io_shared_arbiter_io_output_arw_ready;
  wire                io_asyncReset_buffercc_io_dataOut;
  wire                axi_apbBridge_io_axi_arw_ready;
  wire                axi_apbBridge_io_axi_w_ready;
  wire                axi_apbBridge_io_axi_b_valid;
  wire       [3:0]    axi_apbBridge_io_axi_b_payload_id;
  wire       [1:0]    axi_apbBridge_io_axi_b_payload_resp;
  wire                axi_apbBridge_io_axi_r_valid;
  wire       [31:0]   axi_apbBridge_io_axi_r_payload_data;
  wire       [3:0]    axi_apbBridge_io_axi_r_payload_id;
  wire       [1:0]    axi_apbBridge_io_axi_r_payload_resp;
  wire                axi_apbBridge_io_axi_r_payload_last;
  wire       [19:0]   axi_apbBridge_io_apb_PADDR;
  wire       [0:0]    axi_apbBridge_io_apb_PSEL;
  wire                axi_apbBridge_io_apb_PENABLE;
  wire                axi_apbBridge_io_apb_PWRITE;
  wire       [31:0]   axi_apbBridge_io_apb_PWDATA;
  wire                axi_uartCtrl_io_apb_PREADY;
  wire       [31:0]   axi_uartCtrl_io_apb_PRDATA;
  wire                axi_uartCtrl_io_uart_txd;
  wire                axi_uartCtrl_io_interrupt;
  wire                axi_ramBridge_io_shared_arw_ready;
  wire                axi_ramBridge_io_shared_w_ready;
  wire                axi_ramBridge_io_shared_b_valid;
  wire       [3:0]    axi_ramBridge_io_shared_b_payload_id;
  wire       [1:0]    axi_ramBridge_io_shared_b_payload_resp;
  wire                axi_ramBridge_io_shared_r_valid;
  wire       [31:0]   axi_ramBridge_io_shared_r_payload_data;
  wire       [3:0]    axi_ramBridge_io_shared_r_payload_id;
  wire       [1:0]    axi_ramBridge_io_shared_r_payload_resp;
  wire                axi_ramBridge_io_shared_r_payload_last;
  wire                axi_ramBridge_io_axi_ar_valid;
  wire       [31:0]   axi_ramBridge_io_axi_ar_payload_addr;
  wire       [3:0]    axi_ramBridge_io_axi_ar_payload_id;
  wire       [3:0]    axi_ramBridge_io_axi_ar_payload_region;
  wire       [7:0]    axi_ramBridge_io_axi_ar_payload_len;
  wire       [2:0]    axi_ramBridge_io_axi_ar_payload_size;
  wire       [1:0]    axi_ramBridge_io_axi_ar_payload_burst;
  wire       [0:0]    axi_ramBridge_io_axi_ar_payload_lock;
  wire       [3:0]    axi_ramBridge_io_axi_ar_payload_cache;
  wire       [3:0]    axi_ramBridge_io_axi_ar_payload_qos;
  wire       [2:0]    axi_ramBridge_io_axi_ar_payload_prot;
  wire                axi_ramBridge_io_axi_aw_valid;
  wire       [31:0]   axi_ramBridge_io_axi_aw_payload_addr;
  wire       [3:0]    axi_ramBridge_io_axi_aw_payload_id;
  wire       [3:0]    axi_ramBridge_io_axi_aw_payload_region;
  wire       [7:0]    axi_ramBridge_io_axi_aw_payload_len;
  wire       [2:0]    axi_ramBridge_io_axi_aw_payload_size;
  wire       [1:0]    axi_ramBridge_io_axi_aw_payload_burst;
  wire       [0:0]    axi_ramBridge_io_axi_aw_payload_lock;
  wire       [3:0]    axi_ramBridge_io_axi_aw_payload_cache;
  wire       [3:0]    axi_ramBridge_io_axi_aw_payload_qos;
  wire       [2:0]    axi_ramBridge_io_axi_aw_payload_prot;
  wire                axi_ramBridge_io_axi_w_valid;
  wire       [31:0]   axi_ramBridge_io_axi_w_payload_data;
  wire       [3:0]    axi_ramBridge_io_axi_w_payload_strb;
  wire                axi_ramBridge_io_axi_w_payload_last;
  wire                axi_ramBridge_io_axi_r_ready;
  wire                axi_ramBridge_io_axi_b_ready;
  wire                axi_extBridge_io_shared_arw_ready;
  wire                axi_extBridge_io_shared_w_ready;
  wire                axi_extBridge_io_shared_b_valid;
  wire       [3:0]    axi_extBridge_io_shared_b_payload_id;
  wire       [1:0]    axi_extBridge_io_shared_b_payload_resp;
  wire                axi_extBridge_io_shared_r_valid;
  wire       [31:0]   axi_extBridge_io_shared_r_payload_data;
  wire       [3:0]    axi_extBridge_io_shared_r_payload_id;
  wire       [1:0]    axi_extBridge_io_shared_r_payload_resp;
  wire                axi_extBridge_io_shared_r_payload_last;
  wire                axi_extBridge_io_axi_ar_valid;
  wire       [31:0]   axi_extBridge_io_axi_ar_payload_addr;
  wire       [3:0]    axi_extBridge_io_axi_ar_payload_id;
  wire       [3:0]    axi_extBridge_io_axi_ar_payload_region;
  wire       [7:0]    axi_extBridge_io_axi_ar_payload_len;
  wire       [2:0]    axi_extBridge_io_axi_ar_payload_size;
  wire       [1:0]    axi_extBridge_io_axi_ar_payload_burst;
  wire       [0:0]    axi_extBridge_io_axi_ar_payload_lock;
  wire       [3:0]    axi_extBridge_io_axi_ar_payload_cache;
  wire       [3:0]    axi_extBridge_io_axi_ar_payload_qos;
  wire       [2:0]    axi_extBridge_io_axi_ar_payload_prot;
  wire                axi_extBridge_io_axi_aw_valid;
  wire       [31:0]   axi_extBridge_io_axi_aw_payload_addr;
  wire       [3:0]    axi_extBridge_io_axi_aw_payload_id;
  wire       [3:0]    axi_extBridge_io_axi_aw_payload_region;
  wire       [7:0]    axi_extBridge_io_axi_aw_payload_len;
  wire       [2:0]    axi_extBridge_io_axi_aw_payload_size;
  wire       [1:0]    axi_extBridge_io_axi_aw_payload_burst;
  wire       [0:0]    axi_extBridge_io_axi_aw_payload_lock;
  wire       [3:0]    axi_extBridge_io_axi_aw_payload_cache;
  wire       [3:0]    axi_extBridge_io_axi_aw_payload_qos;
  wire       [2:0]    axi_extBridge_io_axi_aw_payload_prot;
  wire                axi_extBridge_io_axi_w_valid;
  wire       [31:0]   axi_extBridge_io_axi_w_payload_data;
  wire       [3:0]    axi_extBridge_io_axi_w_payload_strb;
  wire                axi_extBridge_io_axi_w_payload_last;
  wire                axi_extBridge_io_axi_r_ready;
  wire                axi_extBridge_io_axi_b_ready;
  wire                axi_liteBridge_io_shared_arw_ready;
  wire                axi_liteBridge_io_shared_w_ready;
  wire                axi_liteBridge_io_shared_b_valid;
  wire       [3:0]    axi_liteBridge_io_shared_b_payload_id;
  wire       [1:0]    axi_liteBridge_io_shared_b_payload_resp;
  wire                axi_liteBridge_io_shared_r_valid;
  wire       [31:0]   axi_liteBridge_io_shared_r_payload_data;
  wire       [3:0]    axi_liteBridge_io_shared_r_payload_id;
  wire       [1:0]    axi_liteBridge_io_shared_r_payload_resp;
  wire                axi_liteBridge_io_shared_r_payload_last;
  wire                axi_liteBridge_io_axi_ar_valid;
  wire       [31:0]   axi_liteBridge_io_axi_ar_payload_addr;
  wire       [3:0]    axi_liteBridge_io_axi_ar_payload_id;
  wire       [3:0]    axi_liteBridge_io_axi_ar_payload_region;
  wire       [7:0]    axi_liteBridge_io_axi_ar_payload_len;
  wire       [2:0]    axi_liteBridge_io_axi_ar_payload_size;
  wire       [1:0]    axi_liteBridge_io_axi_ar_payload_burst;
  wire       [0:0]    axi_liteBridge_io_axi_ar_payload_lock;
  wire       [3:0]    axi_liteBridge_io_axi_ar_payload_cache;
  wire       [3:0]    axi_liteBridge_io_axi_ar_payload_qos;
  wire       [2:0]    axi_liteBridge_io_axi_ar_payload_prot;
  wire                axi_liteBridge_io_axi_aw_valid;
  wire       [31:0]   axi_liteBridge_io_axi_aw_payload_addr;
  wire       [3:0]    axi_liteBridge_io_axi_aw_payload_id;
  wire       [3:0]    axi_liteBridge_io_axi_aw_payload_region;
  wire       [7:0]    axi_liteBridge_io_axi_aw_payload_len;
  wire       [2:0]    axi_liteBridge_io_axi_aw_payload_size;
  wire       [1:0]    axi_liteBridge_io_axi_aw_payload_burst;
  wire       [0:0]    axi_liteBridge_io_axi_aw_payload_lock;
  wire       [3:0]    axi_liteBridge_io_axi_aw_payload_cache;
  wire       [3:0]    axi_liteBridge_io_axi_aw_payload_qos;
  wire       [2:0]    axi_liteBridge_io_axi_aw_payload_prot;
  wire                axi_liteBridge_io_axi_w_valid;
  wire       [31:0]   axi_liteBridge_io_axi_w_payload_data;
  wire       [3:0]    axi_liteBridge_io_axi_w_payload_strb;
  wire                axi_liteBridge_io_axi_w_payload_last;
  wire                axi_liteBridge_io_axi_r_ready;
  wire                axi_liteBridge_io_axi_b_ready;
  wire                axi_axiToLite_io_input_ar_ready;
  wire                axi_axiToLite_io_input_aw_ready;
  wire                axi_axiToLite_io_input_w_ready;
  wire                axi_axiToLite_io_input_r_valid;
  wire       [31:0]   axi_axiToLite_io_input_r_payload_data;
  wire       [3:0]    axi_axiToLite_io_input_r_payload_id;
  wire       [1:0]    axi_axiToLite_io_input_r_payload_resp;
  wire                axi_axiToLite_io_input_r_payload_last;
  wire                axi_axiToLite_io_input_b_valid;
  wire       [3:0]    axi_axiToLite_io_input_b_payload_id;
  wire       [1:0]    axi_axiToLite_io_input_b_payload_resp;
  wire                axi_axiToLite_io_output_aw_valid;
  wire       [31:0]   axi_axiToLite_io_output_aw_payload_addr;
  wire       [2:0]    axi_axiToLite_io_output_aw_payload_prot;
  wire                axi_axiToLite_io_output_w_valid;
  wire       [31:0]   axi_axiToLite_io_output_w_payload_data;
  wire       [3:0]    axi_axiToLite_io_output_w_payload_strb;
  wire                axi_axiToLite_io_output_b_ready;
  wire                axi_axiToLite_io_output_ar_valid;
  wire       [31:0]   axi_axiToLite_io_output_ar_payload_addr;
  wire       [2:0]    axi_axiToLite_io_output_ar_payload_prot;
  wire                axi_axiToLite_io_output_r_ready;
  wire                axi_core_cpu_iBus_cmd_valid;
  wire       [31:0]   axi_core_cpu_iBus_cmd_payload_pc;
  wire                axi_core_cpu_dBus_cmd_valid;
  wire                axi_core_cpu_dBus_cmd_payload_wr;
  wire       [3:0]    axi_core_cpu_dBus_cmd_payload_mask;
  wire       [31:0]   axi_core_cpu_dBus_cmd_payload_address;
  wire       [31:0]   axi_core_cpu_dBus_cmd_payload_data;
  wire       [1:0]    axi_core_cpu_dBus_cmd_payload_size;
  wire                io_coreInterrupt_buffercc_io_dataOut;
  wire                axi4ReadOnlyDecoder_io_input_ar_ready;
  wire                axi4ReadOnlyDecoder_io_input_r_valid;
  wire       [31:0]   axi4ReadOnlyDecoder_io_input_r_payload_data;
  wire       [1:0]    axi4ReadOnlyDecoder_io_input_r_payload_resp;
  wire                axi4ReadOnlyDecoder_io_input_r_payload_last;
  wire                axi4ReadOnlyDecoder_io_outputs_0_ar_valid;
  wire       [31:0]   axi4ReadOnlyDecoder_io_outputs_0_ar_payload_addr;
  wire       [3:0]    axi4ReadOnlyDecoder_io_outputs_0_ar_payload_cache;
  wire       [2:0]    axi4ReadOnlyDecoder_io_outputs_0_ar_payload_prot;
  wire                axi4ReadOnlyDecoder_io_outputs_0_r_ready;
  wire                axi4SharedDecoder_io_input_arw_ready;
  wire                axi4SharedDecoder_io_input_w_ready;
  wire                axi4SharedDecoder_io_input_b_valid;
  wire       [1:0]    axi4SharedDecoder_io_input_b_payload_resp;
  wire                axi4SharedDecoder_io_input_r_valid;
  wire       [31:0]   axi4SharedDecoder_io_input_r_payload_data;
  wire       [1:0]    axi4SharedDecoder_io_input_r_payload_resp;
  wire                axi4SharedDecoder_io_input_r_payload_last;
  wire                axi4SharedDecoder_io_sharedOutputs_0_arw_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_0_arw_payload_addr;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_0_arw_payload_size;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_0_arw_payload_cache;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_0_arw_payload_prot;
  wire                axi4SharedDecoder_io_sharedOutputs_0_arw_payload_write;
  wire                axi4SharedDecoder_io_sharedOutputs_0_w_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_0_w_payload_data;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_0_w_payload_strb;
  wire                axi4SharedDecoder_io_sharedOutputs_0_w_payload_last;
  wire                axi4SharedDecoder_io_sharedOutputs_0_b_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_0_r_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_1_arw_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_1_arw_payload_addr;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_1_arw_payload_size;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_1_arw_payload_cache;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_1_arw_payload_prot;
  wire                axi4SharedDecoder_io_sharedOutputs_1_arw_payload_write;
  wire                axi4SharedDecoder_io_sharedOutputs_1_w_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_1_w_payload_data;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_1_w_payload_strb;
  wire                axi4SharedDecoder_io_sharedOutputs_1_w_payload_last;
  wire                axi4SharedDecoder_io_sharedOutputs_1_b_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_1_r_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_2_arw_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_2_arw_payload_addr;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_2_arw_payload_size;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_2_arw_payload_cache;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_2_arw_payload_prot;
  wire                axi4SharedDecoder_io_sharedOutputs_2_arw_payload_write;
  wire                axi4SharedDecoder_io_sharedOutputs_2_w_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_2_w_payload_data;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_2_w_payload_strb;
  wire                axi4SharedDecoder_io_sharedOutputs_2_w_payload_last;
  wire                axi4SharedDecoder_io_sharedOutputs_2_b_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_2_r_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_3_arw_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_3_arw_payload_addr;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_3_arw_payload_size;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_3_arw_payload_cache;
  wire       [2:0]    axi4SharedDecoder_io_sharedOutputs_3_arw_payload_prot;
  wire                axi4SharedDecoder_io_sharedOutputs_3_arw_payload_write;
  wire                axi4SharedDecoder_io_sharedOutputs_3_w_valid;
  wire       [31:0]   axi4SharedDecoder_io_sharedOutputs_3_w_payload_data;
  wire       [3:0]    axi4SharedDecoder_io_sharedOutputs_3_w_payload_strb;
  wire                axi4SharedDecoder_io_sharedOutputs_3_w_payload_last;
  wire                axi4SharedDecoder_io_sharedOutputs_3_b_ready;
  wire                axi4SharedDecoder_io_sharedOutputs_3_r_ready;
  wire                axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_ready;
  wire                axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_w_ready;
  wire                axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_valid;
  wire       [3:0]    axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_id;
  wire       [1:0]    axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_resp;
  wire                axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_valid;
  wire       [31:0]   axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_data;
  wire       [3:0]    axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_id;
  wire       [1:0]    axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_resp;
  wire                axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_last;
  wire                axi_apbBridge_io_axi_arbiter_io_output_arw_valid;
  wire       [19:0]   axi_apbBridge_io_axi_arbiter_io_output_arw_payload_addr;
  wire       [3:0]    axi_apbBridge_io_axi_arbiter_io_output_arw_payload_id;
  wire       [7:0]    axi_apbBridge_io_axi_arbiter_io_output_arw_payload_len;
  wire       [2:0]    axi_apbBridge_io_axi_arbiter_io_output_arw_payload_size;
  wire       [1:0]    axi_apbBridge_io_axi_arbiter_io_output_arw_payload_burst;
  wire                axi_apbBridge_io_axi_arbiter_io_output_arw_payload_write;
  wire                axi_apbBridge_io_axi_arbiter_io_output_w_valid;
  wire       [31:0]   axi_apbBridge_io_axi_arbiter_io_output_w_payload_data;
  wire       [3:0]    axi_apbBridge_io_axi_arbiter_io_output_w_payload_strb;
  wire                axi_apbBridge_io_axi_arbiter_io_output_w_payload_last;
  wire                axi_apbBridge_io_axi_arbiter_io_output_b_ready;
  wire                axi_apbBridge_io_axi_arbiter_io_output_r_ready;
  wire                axi_ramBridge_io_shared_arbiter_io_readInputs_0_ar_ready;
  wire                axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_valid;
  wire       [31:0]   axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_data;
  wire       [2:0]    axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_id;
  wire       [1:0]    axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_resp;
  wire                axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_last;
  wire                axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready;
  wire                axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_w_ready;
  wire                axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_valid;
  wire       [2:0]    axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_id;
  wire       [1:0]    axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp;
  wire                axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_valid;
  wire       [31:0]   axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data;
  wire       [2:0]    axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_id;
  wire       [1:0]    axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp;
  wire                axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last;
  wire                axi_ramBridge_io_shared_arbiter_io_output_arw_valid;
  wire       [31:0]   axi_ramBridge_io_shared_arbiter_io_output_arw_payload_addr;
  wire       [3:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_id;
  wire       [3:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_region;
  wire       [7:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_len;
  wire       [2:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_size;
  wire       [1:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_burst;
  wire       [0:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_lock;
  wire       [3:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_cache;
  wire       [3:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_qos;
  wire       [2:0]    axi_ramBridge_io_shared_arbiter_io_output_arw_payload_prot;
  wire                axi_ramBridge_io_shared_arbiter_io_output_arw_payload_write;
  wire                axi_ramBridge_io_shared_arbiter_io_output_w_valid;
  wire       [31:0]   axi_ramBridge_io_shared_arbiter_io_output_w_payload_data;
  wire       [3:0]    axi_ramBridge_io_shared_arbiter_io_output_w_payload_strb;
  wire                axi_ramBridge_io_shared_arbiter_io_output_w_payload_last;
  wire                axi_ramBridge_io_shared_arbiter_io_output_b_ready;
  wire                axi_ramBridge_io_shared_arbiter_io_output_r_ready;
  wire                axi_extBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready;
  wire                axi_extBridge_io_shared_arbiter_io_sharedInputs_0_w_ready;
  wire                axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_valid;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_id;
  wire       [1:0]    axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp;
  wire                axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_valid;
  wire       [31:0]   axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_id;
  wire       [1:0]    axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp;
  wire                axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last;
  wire                axi_extBridge_io_shared_arbiter_io_output_arw_valid;
  wire       [31:0]   axi_extBridge_io_shared_arbiter_io_output_arw_payload_addr;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_id;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_region;
  wire       [7:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_len;
  wire       [2:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_size;
  wire       [1:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_burst;
  wire       [0:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_lock;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_cache;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_qos;
  wire       [2:0]    axi_extBridge_io_shared_arbiter_io_output_arw_payload_prot;
  wire                axi_extBridge_io_shared_arbiter_io_output_arw_payload_write;
  wire                axi_extBridge_io_shared_arbiter_io_output_w_valid;
  wire       [31:0]   axi_extBridge_io_shared_arbiter_io_output_w_payload_data;
  wire       [3:0]    axi_extBridge_io_shared_arbiter_io_output_w_payload_strb;
  wire                axi_extBridge_io_shared_arbiter_io_output_w_payload_last;
  wire                axi_extBridge_io_shared_arbiter_io_output_b_ready;
  wire                axi_extBridge_io_shared_arbiter_io_output_r_ready;
  wire                axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready;
  wire                axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_w_ready;
  wire                axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_valid;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_id;
  wire       [1:0]    axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp;
  wire                axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_valid;
  wire       [31:0]   axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_id;
  wire       [1:0]    axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp;
  wire                axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last;
  wire                axi_liteBridge_io_shared_arbiter_io_output_arw_valid;
  wire       [31:0]   axi_liteBridge_io_shared_arbiter_io_output_arw_payload_addr;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_id;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_region;
  wire       [7:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_len;
  wire       [2:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_size;
  wire       [1:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_burst;
  wire       [0:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_lock;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_cache;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_qos;
  wire       [2:0]    axi_liteBridge_io_shared_arbiter_io_output_arw_payload_prot;
  wire                axi_liteBridge_io_shared_arbiter_io_output_arw_payload_write;
  wire                axi_liteBridge_io_shared_arbiter_io_output_w_valid;
  wire       [31:0]   axi_liteBridge_io_shared_arbiter_io_output_w_payload_data;
  wire       [3:0]    axi_liteBridge_io_shared_arbiter_io_output_w_payload_strb;
  wire                axi_liteBridge_io_shared_arbiter_io_output_w_payload_last;
  wire                axi_liteBridge_io_shared_arbiter_io_output_b_ready;
  wire                axi_liteBridge_io_shared_arbiter_io_output_r_ready;
  wire                io_apb_decoder_io_input_PREADY;
  wire       [31:0]   io_apb_decoder_io_input_PRDATA;
  wire                io_apb_decoder_io_input_PSLVERROR;
  wire       [19:0]   io_apb_decoder_io_output_PADDR;
  wire       [0:0]    io_apb_decoder_io_output_PSEL;
  wire                io_apb_decoder_io_output_PENABLE;
  wire                io_apb_decoder_io_output_PWRITE;
  wire       [31:0]   io_apb_decoder_io_output_PWDATA;
  wire                apb3Router_io_input_PREADY;
  wire       [31:0]   apb3Router_io_input_PRDATA;
  wire                apb3Router_io_input_PSLVERROR;
  wire       [19:0]   apb3Router_io_outputs_0_PADDR;
  wire       [0:0]    apb3Router_io_outputs_0_PSEL;
  wire                apb3Router_io_outputs_0_PENABLE;
  wire                apb3Router_io_outputs_0_PWRITE;
  wire       [31:0]   apb3Router_io_outputs_0_PWDATA;
  reg                 resetCtrl_systemResetUnbuffered;
  reg        [5:0]    resetCtrl_systemResetCounter;
  wire       [5:0]    _zz_when_RiscvCpu_l172;
  wire                when_RiscvCpu_l172;
  wire                when_RiscvCpu_l176;
  reg                 resetCtrl_systemReset;
  reg                 resetCtrl_axiReset;
  wire                dBus_cmd_fire;
  wire                when_Utils_l732;
  reg                 _zz_when_Utils_l767;
  reg                 _zz_when_Utils_l767_1;
  reg        [2:0]    _zz_dBus_cmd_haltWhen_valid;
  reg        [2:0]    _zz_dBus_cmd_haltWhen_valid_1;
  wire                when_Utils_l767;
  wire                when_Utils_l769;
  wire                _zz_dBus_cmd_haltWhen_valid_2;
  wire                dBus_cmd_haltWhen_valid;
  reg                 dBus_cmd_haltWhen_ready;
  wire                dBus_cmd_haltWhen_payload_wr;
  wire       [3:0]    dBus_cmd_haltWhen_payload_mask;
  wire       [31:0]   dBus_cmd_haltWhen_payload_address;
  wire       [31:0]   dBus_cmd_haltWhen_payload_data;
  wire       [1:0]    dBus_cmd_haltWhen_payload_size;
  wire                dBus_cmd_haltWhen_fork2_outputs_0_valid;
  wire                dBus_cmd_haltWhen_fork2_outputs_0_ready;
  wire                dBus_cmd_haltWhen_fork2_outputs_0_payload_wr;
  wire       [3:0]    dBus_cmd_haltWhen_fork2_outputs_0_payload_mask;
  wire       [31:0]   dBus_cmd_haltWhen_fork2_outputs_0_payload_address;
  wire       [31:0]   dBus_cmd_haltWhen_fork2_outputs_0_payload_data;
  wire       [1:0]    dBus_cmd_haltWhen_fork2_outputs_0_payload_size;
  wire                dBus_cmd_haltWhen_fork2_outputs_1_valid;
  reg                 dBus_cmd_haltWhen_fork2_outputs_1_ready;
  wire                dBus_cmd_haltWhen_fork2_outputs_1_payload_wr;
  wire       [3:0]    dBus_cmd_haltWhen_fork2_outputs_1_payload_mask;
  wire       [31:0]   dBus_cmd_haltWhen_fork2_outputs_1_payload_address;
  wire       [31:0]   dBus_cmd_haltWhen_fork2_outputs_1_payload_data;
  wire       [1:0]    dBus_cmd_haltWhen_fork2_outputs_1_payload_size;
  reg                 dBus_cmd_haltWhen_fork2_logic_linkEnable_0;
  reg                 dBus_cmd_haltWhen_fork2_logic_linkEnable_1;
  wire                when_Stream_l1253;
  wire                when_Stream_l1253_1;
  wire                dBus_cmd_haltWhen_fork2_outputs_0_fire;
  wire                dBus_cmd_haltWhen_fork2_outputs_1_fire;
  wire                when_Stream_l581;
  reg                 dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_valid;
  wire                dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_ready;
  wire                dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_wr;
  wire       [3:0]    dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_mask;
  wire       [31:0]   dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_address;
  wire       [31:0]   dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_data;
  wire       [1:0]    dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_size;
  reg        [3:0]    _zz_io_input_w_payload_strb;
  wire                io_outputs_0_ar_validPipe_valid;
  wire                io_outputs_0_ar_validPipe_ready;
  wire       [31:0]   io_outputs_0_ar_validPipe_payload_addr;
  wire       [3:0]    io_outputs_0_ar_validPipe_payload_cache;
  wire       [2:0]    io_outputs_0_ar_validPipe_payload_prot;
  reg                 io_outputs_0_ar_rValid;
  wire                io_outputs_0_ar_validPipe_fire;
  wire                io_sharedOutputs_0_arw_validPipe_valid;
  wire                io_sharedOutputs_0_arw_validPipe_ready;
  wire       [31:0]   io_sharedOutputs_0_arw_validPipe_payload_addr;
  wire       [2:0]    io_sharedOutputs_0_arw_validPipe_payload_size;
  wire       [3:0]    io_sharedOutputs_0_arw_validPipe_payload_cache;
  wire       [2:0]    io_sharedOutputs_0_arw_validPipe_payload_prot;
  wire                io_sharedOutputs_0_arw_validPipe_payload_write;
  reg                 io_sharedOutputs_0_arw_rValid;
  wire                io_sharedOutputs_0_arw_validPipe_fire;
  wire                io_sharedOutputs_1_arw_validPipe_valid;
  wire                io_sharedOutputs_1_arw_validPipe_ready;
  wire       [31:0]   io_sharedOutputs_1_arw_validPipe_payload_addr;
  wire       [2:0]    io_sharedOutputs_1_arw_validPipe_payload_size;
  wire       [3:0]    io_sharedOutputs_1_arw_validPipe_payload_cache;
  wire       [2:0]    io_sharedOutputs_1_arw_validPipe_payload_prot;
  wire                io_sharedOutputs_1_arw_validPipe_payload_write;
  reg                 io_sharedOutputs_1_arw_rValid;
  wire                io_sharedOutputs_1_arw_validPipe_fire;
  wire                io_sharedOutputs_2_arw_validPipe_valid;
  wire                io_sharedOutputs_2_arw_validPipe_ready;
  wire       [31:0]   io_sharedOutputs_2_arw_validPipe_payload_addr;
  wire       [2:0]    io_sharedOutputs_2_arw_validPipe_payload_size;
  wire       [3:0]    io_sharedOutputs_2_arw_validPipe_payload_cache;
  wire       [2:0]    io_sharedOutputs_2_arw_validPipe_payload_prot;
  wire                io_sharedOutputs_2_arw_validPipe_payload_write;
  reg                 io_sharedOutputs_2_arw_rValid;
  wire                io_sharedOutputs_2_arw_validPipe_fire;
  wire                io_sharedOutputs_3_arw_validPipe_valid;
  wire                io_sharedOutputs_3_arw_validPipe_ready;
  wire       [31:0]   io_sharedOutputs_3_arw_validPipe_payload_addr;
  wire       [2:0]    io_sharedOutputs_3_arw_validPipe_payload_size;
  wire       [3:0]    io_sharedOutputs_3_arw_validPipe_payload_cache;
  wire       [2:0]    io_sharedOutputs_3_arw_validPipe_payload_prot;
  wire                io_sharedOutputs_3_arw_validPipe_payload_write;
  reg                 io_sharedOutputs_3_arw_rValid;
  wire                io_sharedOutputs_3_arw_validPipe_fire;
  wire                io_input_r_stage_valid;
  wire                io_input_r_stage_ready;
  wire       [31:0]   io_input_r_stage_payload_data;
  wire       [1:0]    io_input_r_stage_payload_resp;
  wire                io_input_r_stage_payload_last;
  reg                 io_input_r_rValid;
  reg        [31:0]   io_input_r_rData_data;
  reg        [1:0]    io_input_r_rData_resp;
  reg                 io_input_r_rData_last;
  wire                when_Stream_l477;
  wire       [3:0]    _zz_io_sharedInputs_0_arw_payload_id;
  wire       [7:0]    _zz_io_sharedInputs_0_arw_payload_len;
  wire                io_output_arw_halfPipe_valid;
  wire                io_output_arw_halfPipe_ready;
  wire       [19:0]   io_output_arw_halfPipe_payload_addr;
  wire       [3:0]    io_output_arw_halfPipe_payload_id;
  wire       [7:0]    io_output_arw_halfPipe_payload_len;
  wire       [2:0]    io_output_arw_halfPipe_payload_size;
  wire       [1:0]    io_output_arw_halfPipe_payload_burst;
  wire                io_output_arw_halfPipe_payload_write;
  reg                 io_output_arw_rValid;
  wire                io_output_arw_halfPipe_fire;
  reg        [19:0]   io_output_arw_rData_addr;
  reg        [3:0]    io_output_arw_rData_id;
  reg        [7:0]    io_output_arw_rData_len;
  reg        [2:0]    io_output_arw_rData_size;
  reg        [1:0]    io_output_arw_rData_burst;
  reg                 io_output_arw_rData_write;
  wire                io_output_w_halfPipe_valid;
  wire                io_output_w_halfPipe_ready;
  wire       [31:0]   io_output_w_halfPipe_payload_data;
  wire       [3:0]    io_output_w_halfPipe_payload_strb;
  wire                io_output_w_halfPipe_payload_last;
  reg                 io_output_w_rValid;
  wire                io_output_w_halfPipe_fire;
  reg        [31:0]   io_output_w_rData_data;
  reg        [3:0]    io_output_w_rData_strb;
  reg                 io_output_w_rData_last;
  wire       [2:0]    _zz_io_readInputs_0_ar_payload_id;
  wire       [3:0]    _zz_io_readInputs_0_ar_payload_region;
  wire       [7:0]    _zz_io_readInputs_0_ar_payload_len;
  wire       [2:0]    _zz_io_sharedInputs_0_arw_payload_id_1;
  wire       [3:0]    _zz_io_sharedInputs_0_arw_payload_region;
  wire       [7:0]    _zz_io_sharedInputs_0_arw_payload_len_1;
  wire                io_output_arw_halfPipe_valid_1;
  wire                io_output_arw_halfPipe_ready_1;
  wire       [31:0]   io_output_arw_halfPipe_payload_addr_1;
  wire       [3:0]    io_output_arw_halfPipe_payload_id_1;
  wire       [3:0]    io_output_arw_halfPipe_payload_region;
  wire       [7:0]    io_output_arw_halfPipe_payload_len_1;
  wire       [2:0]    io_output_arw_halfPipe_payload_size_1;
  wire       [1:0]    io_output_arw_halfPipe_payload_burst_1;
  wire       [0:0]    io_output_arw_halfPipe_payload_lock;
  wire       [3:0]    io_output_arw_halfPipe_payload_cache;
  wire       [3:0]    io_output_arw_halfPipe_payload_qos;
  wire       [2:0]    io_output_arw_halfPipe_payload_prot;
  wire                io_output_arw_halfPipe_payload_write_1;
  reg                 io_output_arw_rValid_1;
  wire                io_output_arw_halfPipe_fire_1;
  reg        [31:0]   io_output_arw_rData_addr_1;
  reg        [3:0]    io_output_arw_rData_id_1;
  reg        [3:0]    io_output_arw_rData_region;
  reg        [7:0]    io_output_arw_rData_len_1;
  reg        [2:0]    io_output_arw_rData_size_1;
  reg        [1:0]    io_output_arw_rData_burst_1;
  reg        [0:0]    io_output_arw_rData_lock;
  reg        [3:0]    io_output_arw_rData_cache;
  reg        [3:0]    io_output_arw_rData_qos;
  reg        [2:0]    io_output_arw_rData_prot;
  reg                 io_output_arw_rData_write_1;
  wire                io_output_w_s2mPipe_valid;
  reg                 io_output_w_s2mPipe_ready;
  wire       [31:0]   io_output_w_s2mPipe_payload_data;
  wire       [3:0]    io_output_w_s2mPipe_payload_strb;
  wire                io_output_w_s2mPipe_payload_last;
  reg                 io_output_w_rValidN;
  reg        [31:0]   io_output_w_rData_data_1;
  reg        [3:0]    io_output_w_rData_strb_1;
  reg                 io_output_w_rData_last_1;
  wire                io_output_w_s2mPipe_m2sPipe_valid;
  wire                io_output_w_s2mPipe_m2sPipe_ready;
  wire       [31:0]   io_output_w_s2mPipe_m2sPipe_payload_data;
  wire       [3:0]    io_output_w_s2mPipe_m2sPipe_payload_strb;
  wire                io_output_w_s2mPipe_m2sPipe_payload_last;
  reg                 io_output_w_s2mPipe_rValid;
  reg        [31:0]   io_output_w_s2mPipe_rData_data;
  reg        [3:0]    io_output_w_s2mPipe_rData_strb;
  reg                 io_output_w_s2mPipe_rData_last;
  wire                when_Stream_l477_1;
  wire       [3:0]    _zz_io_sharedInputs_0_arw_payload_id_2;
  wire       [3:0]    _zz_io_sharedInputs_0_arw_payload_region_1;
  wire       [7:0]    _zz_io_sharedInputs_0_arw_payload_len_2;
  wire                io_output_arw_halfPipe_valid_2;
  wire                io_output_arw_halfPipe_ready_2;
  wire       [31:0]   io_output_arw_halfPipe_payload_addr_2;
  wire       [3:0]    io_output_arw_halfPipe_payload_id_2;
  wire       [3:0]    io_output_arw_halfPipe_payload_region_1;
  wire       [7:0]    io_output_arw_halfPipe_payload_len_2;
  wire       [2:0]    io_output_arw_halfPipe_payload_size_2;
  wire       [1:0]    io_output_arw_halfPipe_payload_burst_2;
  wire       [0:0]    io_output_arw_halfPipe_payload_lock_1;
  wire       [3:0]    io_output_arw_halfPipe_payload_cache_1;
  wire       [3:0]    io_output_arw_halfPipe_payload_qos_1;
  wire       [2:0]    io_output_arw_halfPipe_payload_prot_1;
  wire                io_output_arw_halfPipe_payload_write_2;
  reg                 io_output_arw_rValid_2;
  wire                io_output_arw_halfPipe_fire_2;
  reg        [31:0]   io_output_arw_rData_addr_2;
  reg        [3:0]    io_output_arw_rData_id_2;
  reg        [3:0]    io_output_arw_rData_region_1;
  reg        [7:0]    io_output_arw_rData_len_2;
  reg        [2:0]    io_output_arw_rData_size_2;
  reg        [1:0]    io_output_arw_rData_burst_2;
  reg        [0:0]    io_output_arw_rData_lock_1;
  reg        [3:0]    io_output_arw_rData_cache_1;
  reg        [3:0]    io_output_arw_rData_qos_1;
  reg        [2:0]    io_output_arw_rData_prot_1;
  reg                 io_output_arw_rData_write_2;
  wire                io_output_w_s2mPipe_valid_1;
  reg                 io_output_w_s2mPipe_ready_1;
  wire       [31:0]   io_output_w_s2mPipe_payload_data_1;
  wire       [3:0]    io_output_w_s2mPipe_payload_strb_1;
  wire                io_output_w_s2mPipe_payload_last_1;
  reg                 io_output_w_rValidN_1;
  reg        [31:0]   io_output_w_rData_data_2;
  reg        [3:0]    io_output_w_rData_strb_2;
  reg                 io_output_w_rData_last_2;
  wire                io_output_w_s2mPipe_m2sPipe_valid_1;
  wire                io_output_w_s2mPipe_m2sPipe_ready_1;
  wire       [31:0]   io_output_w_s2mPipe_m2sPipe_payload_data_1;
  wire       [3:0]    io_output_w_s2mPipe_m2sPipe_payload_strb_1;
  wire                io_output_w_s2mPipe_m2sPipe_payload_last_1;
  reg                 io_output_w_s2mPipe_rValid_1;
  reg        [31:0]   io_output_w_s2mPipe_rData_data_1;
  reg        [3:0]    io_output_w_s2mPipe_rData_strb_1;
  reg                 io_output_w_s2mPipe_rData_last_1;
  wire                when_Stream_l477_2;
  wire       [3:0]    _zz_io_sharedInputs_0_arw_payload_id_3;
  wire       [3:0]    _zz_io_sharedInputs_0_arw_payload_region_2;
  wire       [7:0]    _zz_io_sharedInputs_0_arw_payload_len_3;
  wire                io_output_arw_halfPipe_valid_3;
  wire                io_output_arw_halfPipe_ready_3;
  wire       [31:0]   io_output_arw_halfPipe_payload_addr_3;
  wire       [3:0]    io_output_arw_halfPipe_payload_id_3;
  wire       [3:0]    io_output_arw_halfPipe_payload_region_2;
  wire       [7:0]    io_output_arw_halfPipe_payload_len_3;
  wire       [2:0]    io_output_arw_halfPipe_payload_size_3;
  wire       [1:0]    io_output_arw_halfPipe_payload_burst_3;
  wire       [0:0]    io_output_arw_halfPipe_payload_lock_2;
  wire       [3:0]    io_output_arw_halfPipe_payload_cache_2;
  wire       [3:0]    io_output_arw_halfPipe_payload_qos_2;
  wire       [2:0]    io_output_arw_halfPipe_payload_prot_2;
  wire                io_output_arw_halfPipe_payload_write_3;
  reg                 io_output_arw_rValid_3;
  wire                io_output_arw_halfPipe_fire_3;
  reg        [31:0]   io_output_arw_rData_addr_3;
  reg        [3:0]    io_output_arw_rData_id_3;
  reg        [3:0]    io_output_arw_rData_region_2;
  reg        [7:0]    io_output_arw_rData_len_3;
  reg        [2:0]    io_output_arw_rData_size_3;
  reg        [1:0]    io_output_arw_rData_burst_3;
  reg        [0:0]    io_output_arw_rData_lock_2;
  reg        [3:0]    io_output_arw_rData_cache_2;
  reg        [3:0]    io_output_arw_rData_qos_2;
  reg        [2:0]    io_output_arw_rData_prot_2;
  reg                 io_output_arw_rData_write_3;
  wire                io_output_w_s2mPipe_valid_2;
  reg                 io_output_w_s2mPipe_ready_2;
  wire       [31:0]   io_output_w_s2mPipe_payload_data_2;
  wire       [3:0]    io_output_w_s2mPipe_payload_strb_2;
  wire                io_output_w_s2mPipe_payload_last_2;
  reg                 io_output_w_rValidN_2;
  reg        [31:0]   io_output_w_rData_data_3;
  reg        [3:0]    io_output_w_rData_strb_3;
  reg                 io_output_w_rData_last_3;
  wire                io_output_w_s2mPipe_m2sPipe_valid_2;
  wire                io_output_w_s2mPipe_m2sPipe_ready_2;
  wire       [31:0]   io_output_w_s2mPipe_m2sPipe_payload_data_2;
  wire       [3:0]    io_output_w_s2mPipe_m2sPipe_payload_strb_2;
  wire                io_output_w_s2mPipe_m2sPipe_payload_last_2;
  reg                 io_output_w_s2mPipe_rValid_2;
  reg        [31:0]   io_output_w_s2mPipe_rData_data_2;
  reg        [3:0]    io_output_w_s2mPipe_rData_strb_2;
  reg                 io_output_w_s2mPipe_rData_last_2;
  wire                when_Stream_l477_3;

  (* keep_hierarchy = "TRUE" *) vexBufferCC_1 io_asyncReset_buffercc (
    .io_dataIn  (io_asyncReset                    ), //i
    .io_dataOut (io_asyncReset_buffercc_io_dataOut), //o
    .io_axiClk  (io_axiClk                        )  //i
  );
  vexAxi4SharedToApb3Bridge axi_apbBridge (
    .io_axi_arw_valid         (io_output_arw_halfPipe_valid                  ), //i
    .io_axi_arw_ready         (axi_apbBridge_io_axi_arw_ready                ), //o
    .io_axi_arw_payload_addr  (io_output_arw_halfPipe_payload_addr[19:0]     ), //i
    .io_axi_arw_payload_id    (io_output_arw_halfPipe_payload_id[3:0]        ), //i
    .io_axi_arw_payload_len   (io_output_arw_halfPipe_payload_len[7:0]       ), //i
    .io_axi_arw_payload_size  (io_output_arw_halfPipe_payload_size[2:0]      ), //i
    .io_axi_arw_payload_burst (io_output_arw_halfPipe_payload_burst[1:0]     ), //i
    .io_axi_arw_payload_write (io_output_arw_halfPipe_payload_write          ), //i
    .io_axi_w_valid           (io_output_w_halfPipe_valid                    ), //i
    .io_axi_w_ready           (axi_apbBridge_io_axi_w_ready                  ), //o
    .io_axi_w_payload_data    (io_output_w_halfPipe_payload_data[31:0]       ), //i
    .io_axi_w_payload_strb    (io_output_w_halfPipe_payload_strb[3:0]        ), //i
    .io_axi_w_payload_last    (io_output_w_halfPipe_payload_last             ), //i
    .io_axi_b_valid           (axi_apbBridge_io_axi_b_valid                  ), //o
    .io_axi_b_ready           (axi_apbBridge_io_axi_arbiter_io_output_b_ready), //i
    .io_axi_b_payload_id      (axi_apbBridge_io_axi_b_payload_id[3:0]        ), //o
    .io_axi_b_payload_resp    (axi_apbBridge_io_axi_b_payload_resp[1:0]      ), //o
    .io_axi_r_valid           (axi_apbBridge_io_axi_r_valid                  ), //o
    .io_axi_r_ready           (axi_apbBridge_io_axi_arbiter_io_output_r_ready), //i
    .io_axi_r_payload_data    (axi_apbBridge_io_axi_r_payload_data[31:0]     ), //o
    .io_axi_r_payload_id      (axi_apbBridge_io_axi_r_payload_id[3:0]        ), //o
    .io_axi_r_payload_resp    (axi_apbBridge_io_axi_r_payload_resp[1:0]      ), //o
    .io_axi_r_payload_last    (axi_apbBridge_io_axi_r_payload_last           ), //o
    .io_apb_PADDR             (axi_apbBridge_io_apb_PADDR[19:0]              ), //o
    .io_apb_PSEL              (axi_apbBridge_io_apb_PSEL                     ), //o
    .io_apb_PENABLE           (axi_apbBridge_io_apb_PENABLE                  ), //o
    .io_apb_PREADY            (io_apb_decoder_io_input_PREADY                ), //i
    .io_apb_PWRITE            (axi_apbBridge_io_apb_PWRITE                   ), //o
    .io_apb_PWDATA            (axi_apbBridge_io_apb_PWDATA[31:0]             ), //o
    .io_apb_PRDATA            (io_apb_decoder_io_input_PRDATA[31:0]          ), //i
    .io_apb_PSLVERROR         (io_apb_decoder_io_input_PSLVERROR             ), //i
    .io_axiClk                (io_axiClk                                     ), //i
    .resetCtrl_axiReset       (resetCtrl_axiReset                            )  //i
  );
  vexApb3UartCtrl axi_uartCtrl (
    .io_apb_PADDR       (axi_uartCtrl_io_apb_PADDR[4:0]      ), //i
    .io_apb_PSEL        (apb3Router_io_outputs_0_PSEL        ), //i
    .io_apb_PENABLE     (apb3Router_io_outputs_0_PENABLE     ), //i
    .io_apb_PREADY      (axi_uartCtrl_io_apb_PREADY          ), //o
    .io_apb_PWRITE      (apb3Router_io_outputs_0_PWRITE      ), //i
    .io_apb_PWDATA      (apb3Router_io_outputs_0_PWDATA[31:0]), //i
    .io_apb_PRDATA      (axi_uartCtrl_io_apb_PRDATA[31:0]    ), //o
    .io_uart_txd        (axi_uartCtrl_io_uart_txd            ), //o
    .io_uart_rxd        (io_uart_rxd                         ), //i
    .io_interrupt       (axi_uartCtrl_io_interrupt           ), //o
    .io_axiClk          (io_axiClk                           ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                  )  //i
  );
  vexAxi4SharedToAxi4 axi_ramBridge (
    .io_shared_arw_valid          (io_output_arw_halfPipe_valid_1                   ), //i
    .io_shared_arw_ready          (axi_ramBridge_io_shared_arw_ready                ), //o
    .io_shared_arw_payload_addr   (io_output_arw_halfPipe_payload_addr_1[31:0]      ), //i
    .io_shared_arw_payload_id     (io_output_arw_halfPipe_payload_id_1[3:0]         ), //i
    .io_shared_arw_payload_region (io_output_arw_halfPipe_payload_region[3:0]       ), //i
    .io_shared_arw_payload_len    (io_output_arw_halfPipe_payload_len_1[7:0]        ), //i
    .io_shared_arw_payload_size   (io_output_arw_halfPipe_payload_size_1[2:0]       ), //i
    .io_shared_arw_payload_burst  (io_output_arw_halfPipe_payload_burst_1[1:0]      ), //i
    .io_shared_arw_payload_lock   (io_output_arw_halfPipe_payload_lock              ), //i
    .io_shared_arw_payload_cache  (io_output_arw_halfPipe_payload_cache[3:0]        ), //i
    .io_shared_arw_payload_qos    (io_output_arw_halfPipe_payload_qos[3:0]          ), //i
    .io_shared_arw_payload_prot   (io_output_arw_halfPipe_payload_prot[2:0]         ), //i
    .io_shared_arw_payload_write  (io_output_arw_halfPipe_payload_write_1           ), //i
    .io_shared_w_valid            (io_output_w_s2mPipe_m2sPipe_valid                ), //i
    .io_shared_w_ready            (axi_ramBridge_io_shared_w_ready                  ), //o
    .io_shared_w_payload_data     (io_output_w_s2mPipe_m2sPipe_payload_data[31:0]   ), //i
    .io_shared_w_payload_strb     (io_output_w_s2mPipe_m2sPipe_payload_strb[3:0]    ), //i
    .io_shared_w_payload_last     (io_output_w_s2mPipe_m2sPipe_payload_last         ), //i
    .io_shared_b_valid            (axi_ramBridge_io_shared_b_valid                  ), //o
    .io_shared_b_ready            (axi_ramBridge_io_shared_arbiter_io_output_b_ready), //i
    .io_shared_b_payload_id       (axi_ramBridge_io_shared_b_payload_id[3:0]        ), //o
    .io_shared_b_payload_resp     (axi_ramBridge_io_shared_b_payload_resp[1:0]      ), //o
    .io_shared_r_valid            (axi_ramBridge_io_shared_r_valid                  ), //o
    .io_shared_r_ready            (axi_ramBridge_io_shared_arbiter_io_output_r_ready), //i
    .io_shared_r_payload_data     (axi_ramBridge_io_shared_r_payload_data[31:0]     ), //o
    .io_shared_r_payload_id       (axi_ramBridge_io_shared_r_payload_id[3:0]        ), //o
    .io_shared_r_payload_resp     (axi_ramBridge_io_shared_r_payload_resp[1:0]      ), //o
    .io_shared_r_payload_last     (axi_ramBridge_io_shared_r_payload_last           ), //o
    .io_axi_aw_valid              (axi_ramBridge_io_axi_aw_valid                    ), //o
    .io_axi_aw_ready              (io_ramAxi_aw_ready                               ), //i
    .io_axi_aw_payload_addr       (axi_ramBridge_io_axi_aw_payload_addr[31:0]       ), //o
    .io_axi_aw_payload_id         (axi_ramBridge_io_axi_aw_payload_id[3:0]          ), //o
    .io_axi_aw_payload_region     (axi_ramBridge_io_axi_aw_payload_region[3:0]      ), //o
    .io_axi_aw_payload_len        (axi_ramBridge_io_axi_aw_payload_len[7:0]         ), //o
    .io_axi_aw_payload_size       (axi_ramBridge_io_axi_aw_payload_size[2:0]        ), //o
    .io_axi_aw_payload_burst      (axi_ramBridge_io_axi_aw_payload_burst[1:0]       ), //o
    .io_axi_aw_payload_lock       (axi_ramBridge_io_axi_aw_payload_lock             ), //o
    .io_axi_aw_payload_cache      (axi_ramBridge_io_axi_aw_payload_cache[3:0]       ), //o
    .io_axi_aw_payload_qos        (axi_ramBridge_io_axi_aw_payload_qos[3:0]         ), //o
    .io_axi_aw_payload_prot       (axi_ramBridge_io_axi_aw_payload_prot[2:0]        ), //o
    .io_axi_w_valid               (axi_ramBridge_io_axi_w_valid                     ), //o
    .io_axi_w_ready               (io_ramAxi_w_ready                                ), //i
    .io_axi_w_payload_data        (axi_ramBridge_io_axi_w_payload_data[31:0]        ), //o
    .io_axi_w_payload_strb        (axi_ramBridge_io_axi_w_payload_strb[3:0]         ), //o
    .io_axi_w_payload_last        (axi_ramBridge_io_axi_w_payload_last              ), //o
    .io_axi_b_valid               (io_ramAxi_b_valid                                ), //i
    .io_axi_b_ready               (axi_ramBridge_io_axi_b_ready                     ), //o
    .io_axi_b_payload_id          (io_ramAxi_b_payload_id[3:0]                      ), //i
    .io_axi_b_payload_resp        (io_ramAxi_b_payload_resp[1:0]                    ), //i
    .io_axi_ar_valid              (axi_ramBridge_io_axi_ar_valid                    ), //o
    .io_axi_ar_ready              (io_ramAxi_ar_ready                               ), //i
    .io_axi_ar_payload_addr       (axi_ramBridge_io_axi_ar_payload_addr[31:0]       ), //o
    .io_axi_ar_payload_id         (axi_ramBridge_io_axi_ar_payload_id[3:0]          ), //o
    .io_axi_ar_payload_region     (axi_ramBridge_io_axi_ar_payload_region[3:0]      ), //o
    .io_axi_ar_payload_len        (axi_ramBridge_io_axi_ar_payload_len[7:0]         ), //o
    .io_axi_ar_payload_size       (axi_ramBridge_io_axi_ar_payload_size[2:0]        ), //o
    .io_axi_ar_payload_burst      (axi_ramBridge_io_axi_ar_payload_burst[1:0]       ), //o
    .io_axi_ar_payload_lock       (axi_ramBridge_io_axi_ar_payload_lock             ), //o
    .io_axi_ar_payload_cache      (axi_ramBridge_io_axi_ar_payload_cache[3:0]       ), //o
    .io_axi_ar_payload_qos        (axi_ramBridge_io_axi_ar_payload_qos[3:0]         ), //o
    .io_axi_ar_payload_prot       (axi_ramBridge_io_axi_ar_payload_prot[2:0]        ), //o
    .io_axi_r_valid               (io_ramAxi_r_valid                                ), //i
    .io_axi_r_ready               (axi_ramBridge_io_axi_r_ready                     ), //o
    .io_axi_r_payload_data        (io_ramAxi_r_payload_data[31:0]                   ), //i
    .io_axi_r_payload_id          (io_ramAxi_r_payload_id[3:0]                      ), //i
    .io_axi_r_payload_resp        (io_ramAxi_r_payload_resp[1:0]                    ), //i
    .io_axi_r_payload_last        (io_ramAxi_r_payload_last                         ), //i
    .io_axiClk                    (io_axiClk                                        ), //i
    .resetCtrl_axiReset           (resetCtrl_axiReset                               )  //i
  );
  vexAxi4SharedToAxi4 axi_extBridge (
    .io_shared_arw_valid          (io_output_arw_halfPipe_valid_2                   ), //i
    .io_shared_arw_ready          (axi_extBridge_io_shared_arw_ready                ), //o
    .io_shared_arw_payload_addr   (io_output_arw_halfPipe_payload_addr_2[31:0]      ), //i
    .io_shared_arw_payload_id     (io_output_arw_halfPipe_payload_id_2[3:0]         ), //i
    .io_shared_arw_payload_region (io_output_arw_halfPipe_payload_region_1[3:0]     ), //i
    .io_shared_arw_payload_len    (io_output_arw_halfPipe_payload_len_2[7:0]        ), //i
    .io_shared_arw_payload_size   (io_output_arw_halfPipe_payload_size_2[2:0]       ), //i
    .io_shared_arw_payload_burst  (io_output_arw_halfPipe_payload_burst_2[1:0]      ), //i
    .io_shared_arw_payload_lock   (io_output_arw_halfPipe_payload_lock_1            ), //i
    .io_shared_arw_payload_cache  (io_output_arw_halfPipe_payload_cache_1[3:0]      ), //i
    .io_shared_arw_payload_qos    (io_output_arw_halfPipe_payload_qos_1[3:0]        ), //i
    .io_shared_arw_payload_prot   (io_output_arw_halfPipe_payload_prot_1[2:0]       ), //i
    .io_shared_arw_payload_write  (io_output_arw_halfPipe_payload_write_2           ), //i
    .io_shared_w_valid            (io_output_w_s2mPipe_m2sPipe_valid_1              ), //i
    .io_shared_w_ready            (axi_extBridge_io_shared_w_ready                  ), //o
    .io_shared_w_payload_data     (io_output_w_s2mPipe_m2sPipe_payload_data_1[31:0] ), //i
    .io_shared_w_payload_strb     (io_output_w_s2mPipe_m2sPipe_payload_strb_1[3:0]  ), //i
    .io_shared_w_payload_last     (io_output_w_s2mPipe_m2sPipe_payload_last_1       ), //i
    .io_shared_b_valid            (axi_extBridge_io_shared_b_valid                  ), //o
    .io_shared_b_ready            (axi_extBridge_io_shared_arbiter_io_output_b_ready), //i
    .io_shared_b_payload_id       (axi_extBridge_io_shared_b_payload_id[3:0]        ), //o
    .io_shared_b_payload_resp     (axi_extBridge_io_shared_b_payload_resp[1:0]      ), //o
    .io_shared_r_valid            (axi_extBridge_io_shared_r_valid                  ), //o
    .io_shared_r_ready            (axi_extBridge_io_shared_arbiter_io_output_r_ready), //i
    .io_shared_r_payload_data     (axi_extBridge_io_shared_r_payload_data[31:0]     ), //o
    .io_shared_r_payload_id       (axi_extBridge_io_shared_r_payload_id[3:0]        ), //o
    .io_shared_r_payload_resp     (axi_extBridge_io_shared_r_payload_resp[1:0]      ), //o
    .io_shared_r_payload_last     (axi_extBridge_io_shared_r_payload_last           ), //o
    .io_axi_aw_valid              (axi_extBridge_io_axi_aw_valid                    ), //o
    .io_axi_aw_ready              (io_externalAxi_aw_ready                          ), //i
    .io_axi_aw_payload_addr       (axi_extBridge_io_axi_aw_payload_addr[31:0]       ), //o
    .io_axi_aw_payload_id         (axi_extBridge_io_axi_aw_payload_id[3:0]          ), //o
    .io_axi_aw_payload_region     (axi_extBridge_io_axi_aw_payload_region[3:0]      ), //o
    .io_axi_aw_payload_len        (axi_extBridge_io_axi_aw_payload_len[7:0]         ), //o
    .io_axi_aw_payload_size       (axi_extBridge_io_axi_aw_payload_size[2:0]        ), //o
    .io_axi_aw_payload_burst      (axi_extBridge_io_axi_aw_payload_burst[1:0]       ), //o
    .io_axi_aw_payload_lock       (axi_extBridge_io_axi_aw_payload_lock             ), //o
    .io_axi_aw_payload_cache      (axi_extBridge_io_axi_aw_payload_cache[3:0]       ), //o
    .io_axi_aw_payload_qos        (axi_extBridge_io_axi_aw_payload_qos[3:0]         ), //o
    .io_axi_aw_payload_prot       (axi_extBridge_io_axi_aw_payload_prot[2:0]        ), //o
    .io_axi_w_valid               (axi_extBridge_io_axi_w_valid                     ), //o
    .io_axi_w_ready               (io_externalAxi_w_ready                           ), //i
    .io_axi_w_payload_data        (axi_extBridge_io_axi_w_payload_data[31:0]        ), //o
    .io_axi_w_payload_strb        (axi_extBridge_io_axi_w_payload_strb[3:0]         ), //o
    .io_axi_w_payload_last        (axi_extBridge_io_axi_w_payload_last              ), //o
    .io_axi_b_valid               (io_externalAxi_b_valid                           ), //i
    .io_axi_b_ready               (axi_extBridge_io_axi_b_ready                     ), //o
    .io_axi_b_payload_id          (io_externalAxi_b_payload_id[3:0]                 ), //i
    .io_axi_b_payload_resp        (io_externalAxi_b_payload_resp[1:0]               ), //i
    .io_axi_ar_valid              (axi_extBridge_io_axi_ar_valid                    ), //o
    .io_axi_ar_ready              (io_externalAxi_ar_ready                          ), //i
    .io_axi_ar_payload_addr       (axi_extBridge_io_axi_ar_payload_addr[31:0]       ), //o
    .io_axi_ar_payload_id         (axi_extBridge_io_axi_ar_payload_id[3:0]          ), //o
    .io_axi_ar_payload_region     (axi_extBridge_io_axi_ar_payload_region[3:0]      ), //o
    .io_axi_ar_payload_len        (axi_extBridge_io_axi_ar_payload_len[7:0]         ), //o
    .io_axi_ar_payload_size       (axi_extBridge_io_axi_ar_payload_size[2:0]        ), //o
    .io_axi_ar_payload_burst      (axi_extBridge_io_axi_ar_payload_burst[1:0]       ), //o
    .io_axi_ar_payload_lock       (axi_extBridge_io_axi_ar_payload_lock             ), //o
    .io_axi_ar_payload_cache      (axi_extBridge_io_axi_ar_payload_cache[3:0]       ), //o
    .io_axi_ar_payload_qos        (axi_extBridge_io_axi_ar_payload_qos[3:0]         ), //o
    .io_axi_ar_payload_prot       (axi_extBridge_io_axi_ar_payload_prot[2:0]        ), //o
    .io_axi_r_valid               (io_externalAxi_r_valid                           ), //i
    .io_axi_r_ready               (axi_extBridge_io_axi_r_ready                     ), //o
    .io_axi_r_payload_data        (io_externalAxi_r_payload_data[31:0]              ), //i
    .io_axi_r_payload_id          (io_externalAxi_r_payload_id[3:0]                 ), //i
    .io_axi_r_payload_resp        (io_externalAxi_r_payload_resp[1:0]               ), //i
    .io_axi_r_payload_last        (io_externalAxi_r_payload_last                    ), //i
    .io_axiClk                    (io_axiClk                                        ), //i
    .resetCtrl_axiReset           (resetCtrl_axiReset                               )  //i
  );
  vexAxi4SharedToAxi4 axi_liteBridge (
    .io_shared_arw_valid          (io_output_arw_halfPipe_valid_3                    ), //i
    .io_shared_arw_ready          (axi_liteBridge_io_shared_arw_ready                ), //o
    .io_shared_arw_payload_addr   (io_output_arw_halfPipe_payload_addr_3[31:0]       ), //i
    .io_shared_arw_payload_id     (io_output_arw_halfPipe_payload_id_3[3:0]          ), //i
    .io_shared_arw_payload_region (io_output_arw_halfPipe_payload_region_2[3:0]      ), //i
    .io_shared_arw_payload_len    (io_output_arw_halfPipe_payload_len_3[7:0]         ), //i
    .io_shared_arw_payload_size   (io_output_arw_halfPipe_payload_size_3[2:0]        ), //i
    .io_shared_arw_payload_burst  (io_output_arw_halfPipe_payload_burst_3[1:0]       ), //i
    .io_shared_arw_payload_lock   (io_output_arw_halfPipe_payload_lock_2             ), //i
    .io_shared_arw_payload_cache  (io_output_arw_halfPipe_payload_cache_2[3:0]       ), //i
    .io_shared_arw_payload_qos    (io_output_arw_halfPipe_payload_qos_2[3:0]         ), //i
    .io_shared_arw_payload_prot   (io_output_arw_halfPipe_payload_prot_2[2:0]        ), //i
    .io_shared_arw_payload_write  (io_output_arw_halfPipe_payload_write_3            ), //i
    .io_shared_w_valid            (io_output_w_s2mPipe_m2sPipe_valid_2               ), //i
    .io_shared_w_ready            (axi_liteBridge_io_shared_w_ready                  ), //o
    .io_shared_w_payload_data     (io_output_w_s2mPipe_m2sPipe_payload_data_2[31:0]  ), //i
    .io_shared_w_payload_strb     (io_output_w_s2mPipe_m2sPipe_payload_strb_2[3:0]   ), //i
    .io_shared_w_payload_last     (io_output_w_s2mPipe_m2sPipe_payload_last_2        ), //i
    .io_shared_b_valid            (axi_liteBridge_io_shared_b_valid                  ), //o
    .io_shared_b_ready            (axi_liteBridge_io_shared_arbiter_io_output_b_ready), //i
    .io_shared_b_payload_id       (axi_liteBridge_io_shared_b_payload_id[3:0]        ), //o
    .io_shared_b_payload_resp     (axi_liteBridge_io_shared_b_payload_resp[1:0]      ), //o
    .io_shared_r_valid            (axi_liteBridge_io_shared_r_valid                  ), //o
    .io_shared_r_ready            (axi_liteBridge_io_shared_arbiter_io_output_r_ready), //i
    .io_shared_r_payload_data     (axi_liteBridge_io_shared_r_payload_data[31:0]     ), //o
    .io_shared_r_payload_id       (axi_liteBridge_io_shared_r_payload_id[3:0]        ), //o
    .io_shared_r_payload_resp     (axi_liteBridge_io_shared_r_payload_resp[1:0]      ), //o
    .io_shared_r_payload_last     (axi_liteBridge_io_shared_r_payload_last           ), //o
    .io_axi_aw_valid              (axi_liteBridge_io_axi_aw_valid                    ), //o
    .io_axi_aw_ready              (axi_axiToLite_io_input_aw_ready                   ), //i
    .io_axi_aw_payload_addr       (axi_liteBridge_io_axi_aw_payload_addr[31:0]       ), //o
    .io_axi_aw_payload_id         (axi_liteBridge_io_axi_aw_payload_id[3:0]          ), //o
    .io_axi_aw_payload_region     (axi_liteBridge_io_axi_aw_payload_region[3:0]      ), //o
    .io_axi_aw_payload_len        (axi_liteBridge_io_axi_aw_payload_len[7:0]         ), //o
    .io_axi_aw_payload_size       (axi_liteBridge_io_axi_aw_payload_size[2:0]        ), //o
    .io_axi_aw_payload_burst      (axi_liteBridge_io_axi_aw_payload_burst[1:0]       ), //o
    .io_axi_aw_payload_lock       (axi_liteBridge_io_axi_aw_payload_lock             ), //o
    .io_axi_aw_payload_cache      (axi_liteBridge_io_axi_aw_payload_cache[3:0]       ), //o
    .io_axi_aw_payload_qos        (axi_liteBridge_io_axi_aw_payload_qos[3:0]         ), //o
    .io_axi_aw_payload_prot       (axi_liteBridge_io_axi_aw_payload_prot[2:0]        ), //o
    .io_axi_w_valid               (axi_liteBridge_io_axi_w_valid                     ), //o
    .io_axi_w_ready               (axi_axiToLite_io_input_w_ready                    ), //i
    .io_axi_w_payload_data        (axi_liteBridge_io_axi_w_payload_data[31:0]        ), //o
    .io_axi_w_payload_strb        (axi_liteBridge_io_axi_w_payload_strb[3:0]         ), //o
    .io_axi_w_payload_last        (axi_liteBridge_io_axi_w_payload_last              ), //o
    .io_axi_b_valid               (axi_axiToLite_io_input_b_valid                    ), //i
    .io_axi_b_ready               (axi_liteBridge_io_axi_b_ready                     ), //o
    .io_axi_b_payload_id          (axi_axiToLite_io_input_b_payload_id[3:0]          ), //i
    .io_axi_b_payload_resp        (axi_axiToLite_io_input_b_payload_resp[1:0]        ), //i
    .io_axi_ar_valid              (axi_liteBridge_io_axi_ar_valid                    ), //o
    .io_axi_ar_ready              (axi_axiToLite_io_input_ar_ready                   ), //i
    .io_axi_ar_payload_addr       (axi_liteBridge_io_axi_ar_payload_addr[31:0]       ), //o
    .io_axi_ar_payload_id         (axi_liteBridge_io_axi_ar_payload_id[3:0]          ), //o
    .io_axi_ar_payload_region     (axi_liteBridge_io_axi_ar_payload_region[3:0]      ), //o
    .io_axi_ar_payload_len        (axi_liteBridge_io_axi_ar_payload_len[7:0]         ), //o
    .io_axi_ar_payload_size       (axi_liteBridge_io_axi_ar_payload_size[2:0]        ), //o
    .io_axi_ar_payload_burst      (axi_liteBridge_io_axi_ar_payload_burst[1:0]       ), //o
    .io_axi_ar_payload_lock       (axi_liteBridge_io_axi_ar_payload_lock             ), //o
    .io_axi_ar_payload_cache      (axi_liteBridge_io_axi_ar_payload_cache[3:0]       ), //o
    .io_axi_ar_payload_qos        (axi_liteBridge_io_axi_ar_payload_qos[3:0]         ), //o
    .io_axi_ar_payload_prot       (axi_liteBridge_io_axi_ar_payload_prot[2:0]        ), //o
    .io_axi_r_valid               (axi_axiToLite_io_input_r_valid                    ), //i
    .io_axi_r_ready               (axi_liteBridge_io_axi_r_ready                     ), //o
    .io_axi_r_payload_data        (axi_axiToLite_io_input_r_payload_data[31:0]       ), //i
    .io_axi_r_payload_id          (axi_axiToLite_io_input_r_payload_id[3:0]          ), //i
    .io_axi_r_payload_resp        (axi_axiToLite_io_input_r_payload_resp[1:0]        ), //i
    .io_axi_r_payload_last        (axi_axiToLite_io_input_r_payload_last             ), //i
    .io_axiClk                    (io_axiClk                                         ), //i
    .resetCtrl_axiReset           (resetCtrl_axiReset                                )  //i
  );
  vexAxi4ToAxiLiteBridge axi_axiToLite (
    .io_input_aw_valid          (axi_liteBridge_io_axi_aw_valid               ), //i
    .io_input_aw_ready          (axi_axiToLite_io_input_aw_ready              ), //o
    .io_input_aw_payload_addr   (axi_liteBridge_io_axi_aw_payload_addr[31:0]  ), //i
    .io_input_aw_payload_id     (axi_liteBridge_io_axi_aw_payload_id[3:0]     ), //i
    .io_input_aw_payload_region (axi_liteBridge_io_axi_aw_payload_region[3:0] ), //i
    .io_input_aw_payload_len    (axi_liteBridge_io_axi_aw_payload_len[7:0]    ), //i
    .io_input_aw_payload_size   (axi_liteBridge_io_axi_aw_payload_size[2:0]   ), //i
    .io_input_aw_payload_burst  (axi_liteBridge_io_axi_aw_payload_burst[1:0]  ), //i
    .io_input_aw_payload_lock   (axi_liteBridge_io_axi_aw_payload_lock        ), //i
    .io_input_aw_payload_cache  (axi_liteBridge_io_axi_aw_payload_cache[3:0]  ), //i
    .io_input_aw_payload_qos    (axi_liteBridge_io_axi_aw_payload_qos[3:0]    ), //i
    .io_input_aw_payload_prot   (axi_liteBridge_io_axi_aw_payload_prot[2:0]   ), //i
    .io_input_w_valid           (axi_liteBridge_io_axi_w_valid                ), //i
    .io_input_w_ready           (axi_axiToLite_io_input_w_ready               ), //o
    .io_input_w_payload_data    (axi_liteBridge_io_axi_w_payload_data[31:0]   ), //i
    .io_input_w_payload_strb    (axi_liteBridge_io_axi_w_payload_strb[3:0]    ), //i
    .io_input_w_payload_last    (axi_liteBridge_io_axi_w_payload_last         ), //i
    .io_input_b_valid           (axi_axiToLite_io_input_b_valid               ), //o
    .io_input_b_ready           (axi_liteBridge_io_axi_b_ready                ), //i
    .io_input_b_payload_id      (axi_axiToLite_io_input_b_payload_id[3:0]     ), //o
    .io_input_b_payload_resp    (axi_axiToLite_io_input_b_payload_resp[1:0]   ), //o
    .io_input_ar_valid          (axi_liteBridge_io_axi_ar_valid               ), //i
    .io_input_ar_ready          (axi_axiToLite_io_input_ar_ready              ), //o
    .io_input_ar_payload_addr   (axi_liteBridge_io_axi_ar_payload_addr[31:0]  ), //i
    .io_input_ar_payload_id     (axi_liteBridge_io_axi_ar_payload_id[3:0]     ), //i
    .io_input_ar_payload_region (axi_liteBridge_io_axi_ar_payload_region[3:0] ), //i
    .io_input_ar_payload_len    (axi_liteBridge_io_axi_ar_payload_len[7:0]    ), //i
    .io_input_ar_payload_size   (axi_liteBridge_io_axi_ar_payload_size[2:0]   ), //i
    .io_input_ar_payload_burst  (axi_liteBridge_io_axi_ar_payload_burst[1:0]  ), //i
    .io_input_ar_payload_lock   (axi_liteBridge_io_axi_ar_payload_lock        ), //i
    .io_input_ar_payload_cache  (axi_liteBridge_io_axi_ar_payload_cache[3:0]  ), //i
    .io_input_ar_payload_qos    (axi_liteBridge_io_axi_ar_payload_qos[3:0]    ), //i
    .io_input_ar_payload_prot   (axi_liteBridge_io_axi_ar_payload_prot[2:0]   ), //i
    .io_input_r_valid           (axi_axiToLite_io_input_r_valid               ), //o
    .io_input_r_ready           (axi_liteBridge_io_axi_r_ready                ), //i
    .io_input_r_payload_data    (axi_axiToLite_io_input_r_payload_data[31:0]  ), //o
    .io_input_r_payload_id      (axi_axiToLite_io_input_r_payload_id[3:0]     ), //o
    .io_input_r_payload_resp    (axi_axiToLite_io_input_r_payload_resp[1:0]   ), //o
    .io_input_r_payload_last    (axi_axiToLite_io_input_r_payload_last        ), //o
    .io_output_aw_valid         (axi_axiToLite_io_output_aw_valid             ), //o
    .io_output_aw_ready         (io_axiLite_aw_ready                          ), //i
    .io_output_aw_payload_addr  (axi_axiToLite_io_output_aw_payload_addr[31:0]), //o
    .io_output_aw_payload_prot  (axi_axiToLite_io_output_aw_payload_prot[2:0] ), //o
    .io_output_w_valid          (axi_axiToLite_io_output_w_valid              ), //o
    .io_output_w_ready          (io_axiLite_w_ready                           ), //i
    .io_output_w_payload_data   (axi_axiToLite_io_output_w_payload_data[31:0] ), //o
    .io_output_w_payload_strb   (axi_axiToLite_io_output_w_payload_strb[3:0]  ), //o
    .io_output_b_valid          (io_axiLite_b_valid                           ), //i
    .io_output_b_ready          (axi_axiToLite_io_output_b_ready              ), //o
    .io_output_b_payload_resp   (io_axiLite_b_payload_resp[1:0]               ), //i
    .io_output_ar_valid         (axi_axiToLite_io_output_ar_valid             ), //o
    .io_output_ar_ready         (io_axiLite_ar_ready                          ), //i
    .io_output_ar_payload_addr  (axi_axiToLite_io_output_ar_payload_addr[31:0]), //o
    .io_output_ar_payload_prot  (axi_axiToLite_io_output_ar_payload_prot[2:0] ), //o
    .io_output_r_valid          (io_axiLite_r_valid                           ), //i
    .io_output_r_ready          (axi_axiToLite_io_output_r_ready              ), //o
    .io_output_r_payload_data   (io_axiLite_r_payload_data[31:0]              ), //i
    .io_output_r_payload_resp   (io_axiLite_r_payload_resp[1:0]               )  //i
  );
  vexVexRiscv axi_core_cpu (
    .iBus_cmd_valid           (axi_core_cpu_iBus_cmd_valid                      ), //o
    .iBus_cmd_ready           (axi4ReadOnlyDecoder_io_input_ar_ready            ), //i
    .iBus_cmd_payload_pc      (axi_core_cpu_iBus_cmd_payload_pc[31:0]           ), //o
    .iBus_rsp_valid           (axi4ReadOnlyDecoder_io_input_r_valid             ), //i
    .iBus_rsp_payload_error   (axi_core_cpu_iBus_rsp_payload_error              ), //i
    .iBus_rsp_payload_inst    (axi4ReadOnlyDecoder_io_input_r_payload_data[31:0]), //i
    .timerInterrupt           (1'b0                                             ), //i
    .externalInterrupt        (io_coreInterrupt_buffercc_io_dataOut             ), //i
    .softwareInterrupt        (1'b0                                             ), //i
    .dBus_cmd_valid           (axi_core_cpu_dBus_cmd_valid                      ), //o
    .dBus_cmd_ready           (axi_core_cpu_dBus_cmd_ready                      ), //i
    .dBus_cmd_payload_wr      (axi_core_cpu_dBus_cmd_payload_wr                 ), //o
    .dBus_cmd_payload_mask    (axi_core_cpu_dBus_cmd_payload_mask[3:0]          ), //o
    .dBus_cmd_payload_address (axi_core_cpu_dBus_cmd_payload_address[31:0]      ), //o
    .dBus_cmd_payload_data    (axi_core_cpu_dBus_cmd_payload_data[31:0]         ), //o
    .dBus_cmd_payload_size    (axi_core_cpu_dBus_cmd_payload_size[1:0]          ), //o
    .dBus_rsp_ready           (io_input_r_stage_valid                           ), //i
    .dBus_rsp_error           (axi_core_cpu_dBus_rsp_error                      ), //i
    .dBus_rsp_data            (io_input_r_stage_payload_data[31:0]              ), //i
    .io_axiClk                (io_axiClk                                        ), //i
    .resetCtrl_axiReset       (resetCtrl_axiReset                               )  //i
  );
  (* keep_hierarchy = "TRUE" *) vexBufferCC_2 io_coreInterrupt_buffercc (
    .io_dataIn          (io_coreInterrupt                    ), //i
    .io_dataOut         (io_coreInterrupt_buffercc_io_dataOut), //o
    .io_axiClk          (io_axiClk                           ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                  )  //i
  );
  vexAxi4ReadOnlyDecoder axi4ReadOnlyDecoder (
    .io_input_ar_valid             (axi_core_cpu_iBus_cmd_valid                                         ), //i
    .io_input_ar_ready             (axi4ReadOnlyDecoder_io_input_ar_ready                               ), //o
    .io_input_ar_payload_addr      (axi4ReadOnlyDecoder_io_input_ar_payload_addr[31:0]                  ), //i
    .io_input_ar_payload_cache     (4'b1111                                                             ), //i
    .io_input_ar_payload_prot      (3'b110                                                              ), //i
    .io_input_r_valid              (axi4ReadOnlyDecoder_io_input_r_valid                                ), //o
    .io_input_r_ready              (1'b1                                                                ), //i
    .io_input_r_payload_data       (axi4ReadOnlyDecoder_io_input_r_payload_data[31:0]                   ), //o
    .io_input_r_payload_resp       (axi4ReadOnlyDecoder_io_input_r_payload_resp[1:0]                    ), //o
    .io_input_r_payload_last       (axi4ReadOnlyDecoder_io_input_r_payload_last                         ), //o
    .io_outputs_0_ar_valid         (axi4ReadOnlyDecoder_io_outputs_0_ar_valid                           ), //o
    .io_outputs_0_ar_ready         (io_outputs_0_ar_validPipe_fire                                      ), //i
    .io_outputs_0_ar_payload_addr  (axi4ReadOnlyDecoder_io_outputs_0_ar_payload_addr[31:0]              ), //o
    .io_outputs_0_ar_payload_cache (axi4ReadOnlyDecoder_io_outputs_0_ar_payload_cache[3:0]              ), //o
    .io_outputs_0_ar_payload_prot  (axi4ReadOnlyDecoder_io_outputs_0_ar_payload_prot[2:0]               ), //o
    .io_outputs_0_r_valid          (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_valid             ), //i
    .io_outputs_0_r_ready          (axi4ReadOnlyDecoder_io_outputs_0_r_ready                            ), //o
    .io_outputs_0_r_payload_data   (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_data[31:0]), //i
    .io_outputs_0_r_payload_resp   (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_resp[1:0] ), //i
    .io_outputs_0_r_payload_last   (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_last      ), //i
    .io_axiClk                     (io_axiClk                                                           ), //i
    .resetCtrl_axiReset            (resetCtrl_axiReset                                                  )  //i
  );
  vexAxi4SharedDecoder axi4SharedDecoder (
    .io_input_arw_valid                   (dBus_cmd_haltWhen_fork2_outputs_0_valid                                ), //i
    .io_input_arw_ready                   (axi4SharedDecoder_io_input_arw_ready                                   ), //o
    .io_input_arw_payload_addr            (dBus_cmd_haltWhen_fork2_outputs_0_payload_address[31:0]                ), //i
    .io_input_arw_payload_size            (axi4SharedDecoder_io_input_arw_payload_size[2:0]                       ), //i
    .io_input_arw_payload_cache           (4'b1111                                                                ), //i
    .io_input_arw_payload_prot            (3'b010                                                                 ), //i
    .io_input_arw_payload_write           (dBus_cmd_haltWhen_fork2_outputs_0_payload_wr                           ), //i
    .io_input_w_valid                     (dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_valid                      ), //i
    .io_input_w_ready                     (axi4SharedDecoder_io_input_w_ready                                     ), //o
    .io_input_w_payload_data              (dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_data[31:0]         ), //i
    .io_input_w_payload_strb              (axi4SharedDecoder_io_input_w_payload_strb[3:0]                         ), //i
    .io_input_w_payload_last              (1'b1                                                                   ), //i
    .io_input_b_valid                     (axi4SharedDecoder_io_input_b_valid                                     ), //o
    .io_input_b_ready                     (1'b1                                                                   ), //i
    .io_input_b_payload_resp              (axi4SharedDecoder_io_input_b_payload_resp[1:0]                         ), //o
    .io_input_r_valid                     (axi4SharedDecoder_io_input_r_valid                                     ), //o
    .io_input_r_ready                     (axi4SharedDecoder_io_input_r_ready                                     ), //i
    .io_input_r_payload_data              (axi4SharedDecoder_io_input_r_payload_data[31:0]                        ), //o
    .io_input_r_payload_resp              (axi4SharedDecoder_io_input_r_payload_resp[1:0]                         ), //o
    .io_input_r_payload_last              (axi4SharedDecoder_io_input_r_payload_last                              ), //o
    .io_sharedOutputs_0_arw_valid         (axi4SharedDecoder_io_sharedOutputs_0_arw_valid                         ), //o
    .io_sharedOutputs_0_arw_ready         (io_sharedOutputs_0_arw_validPipe_fire                                  ), //i
    .io_sharedOutputs_0_arw_payload_addr  (axi4SharedDecoder_io_sharedOutputs_0_arw_payload_addr[31:0]            ), //o
    .io_sharedOutputs_0_arw_payload_size  (axi4SharedDecoder_io_sharedOutputs_0_arw_payload_size[2:0]             ), //o
    .io_sharedOutputs_0_arw_payload_cache (axi4SharedDecoder_io_sharedOutputs_0_arw_payload_cache[3:0]            ), //o
    .io_sharedOutputs_0_arw_payload_prot  (axi4SharedDecoder_io_sharedOutputs_0_arw_payload_prot[2:0]             ), //o
    .io_sharedOutputs_0_arw_payload_write (axi4SharedDecoder_io_sharedOutputs_0_arw_payload_write                 ), //o
    .io_sharedOutputs_0_w_valid           (axi4SharedDecoder_io_sharedOutputs_0_w_valid                           ), //o
    .io_sharedOutputs_0_w_ready           (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_w_ready              ), //i
    .io_sharedOutputs_0_w_payload_data    (axi4SharedDecoder_io_sharedOutputs_0_w_payload_data[31:0]              ), //o
    .io_sharedOutputs_0_w_payload_strb    (axi4SharedDecoder_io_sharedOutputs_0_w_payload_strb[3:0]               ), //o
    .io_sharedOutputs_0_w_payload_last    (axi4SharedDecoder_io_sharedOutputs_0_w_payload_last                    ), //o
    .io_sharedOutputs_0_b_valid           (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_valid              ), //i
    .io_sharedOutputs_0_b_ready           (axi4SharedDecoder_io_sharedOutputs_0_b_ready                           ), //o
    .io_sharedOutputs_0_b_payload_resp    (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp[1:0]  ), //i
    .io_sharedOutputs_0_r_valid           (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_valid              ), //i
    .io_sharedOutputs_0_r_ready           (axi4SharedDecoder_io_sharedOutputs_0_r_ready                           ), //o
    .io_sharedOutputs_0_r_payload_data    (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data[31:0] ), //i
    .io_sharedOutputs_0_r_payload_resp    (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp[1:0]  ), //i
    .io_sharedOutputs_0_r_payload_last    (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last       ), //i
    .io_sharedOutputs_1_arw_valid         (axi4SharedDecoder_io_sharedOutputs_1_arw_valid                         ), //o
    .io_sharedOutputs_1_arw_ready         (io_sharedOutputs_1_arw_validPipe_fire                                  ), //i
    .io_sharedOutputs_1_arw_payload_addr  (axi4SharedDecoder_io_sharedOutputs_1_arw_payload_addr[31:0]            ), //o
    .io_sharedOutputs_1_arw_payload_size  (axi4SharedDecoder_io_sharedOutputs_1_arw_payload_size[2:0]             ), //o
    .io_sharedOutputs_1_arw_payload_cache (axi4SharedDecoder_io_sharedOutputs_1_arw_payload_cache[3:0]            ), //o
    .io_sharedOutputs_1_arw_payload_prot  (axi4SharedDecoder_io_sharedOutputs_1_arw_payload_prot[2:0]             ), //o
    .io_sharedOutputs_1_arw_payload_write (axi4SharedDecoder_io_sharedOutputs_1_arw_payload_write                 ), //o
    .io_sharedOutputs_1_w_valid           (axi4SharedDecoder_io_sharedOutputs_1_w_valid                           ), //o
    .io_sharedOutputs_1_w_ready           (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_w_ready                 ), //i
    .io_sharedOutputs_1_w_payload_data    (axi4SharedDecoder_io_sharedOutputs_1_w_payload_data[31:0]              ), //o
    .io_sharedOutputs_1_w_payload_strb    (axi4SharedDecoder_io_sharedOutputs_1_w_payload_strb[3:0]               ), //o
    .io_sharedOutputs_1_w_payload_last    (axi4SharedDecoder_io_sharedOutputs_1_w_payload_last                    ), //o
    .io_sharedOutputs_1_b_valid           (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_valid                 ), //i
    .io_sharedOutputs_1_b_ready           (axi4SharedDecoder_io_sharedOutputs_1_b_ready                           ), //o
    .io_sharedOutputs_1_b_payload_resp    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_resp[1:0]     ), //i
    .io_sharedOutputs_1_r_valid           (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_valid                 ), //i
    .io_sharedOutputs_1_r_ready           (axi4SharedDecoder_io_sharedOutputs_1_r_ready                           ), //o
    .io_sharedOutputs_1_r_payload_data    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_data[31:0]    ), //i
    .io_sharedOutputs_1_r_payload_resp    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_resp[1:0]     ), //i
    .io_sharedOutputs_1_r_payload_last    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_last          ), //i
    .io_sharedOutputs_2_arw_valid         (axi4SharedDecoder_io_sharedOutputs_2_arw_valid                         ), //o
    .io_sharedOutputs_2_arw_ready         (io_sharedOutputs_2_arw_validPipe_fire                                  ), //i
    .io_sharedOutputs_2_arw_payload_addr  (axi4SharedDecoder_io_sharedOutputs_2_arw_payload_addr[31:0]            ), //o
    .io_sharedOutputs_2_arw_payload_size  (axi4SharedDecoder_io_sharedOutputs_2_arw_payload_size[2:0]             ), //o
    .io_sharedOutputs_2_arw_payload_cache (axi4SharedDecoder_io_sharedOutputs_2_arw_payload_cache[3:0]            ), //o
    .io_sharedOutputs_2_arw_payload_prot  (axi4SharedDecoder_io_sharedOutputs_2_arw_payload_prot[2:0]             ), //o
    .io_sharedOutputs_2_arw_payload_write (axi4SharedDecoder_io_sharedOutputs_2_arw_payload_write                 ), //o
    .io_sharedOutputs_2_w_valid           (axi4SharedDecoder_io_sharedOutputs_2_w_valid                           ), //o
    .io_sharedOutputs_2_w_ready           (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_w_ready              ), //i
    .io_sharedOutputs_2_w_payload_data    (axi4SharedDecoder_io_sharedOutputs_2_w_payload_data[31:0]              ), //o
    .io_sharedOutputs_2_w_payload_strb    (axi4SharedDecoder_io_sharedOutputs_2_w_payload_strb[3:0]               ), //o
    .io_sharedOutputs_2_w_payload_last    (axi4SharedDecoder_io_sharedOutputs_2_w_payload_last                    ), //o
    .io_sharedOutputs_2_b_valid           (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_valid              ), //i
    .io_sharedOutputs_2_b_ready           (axi4SharedDecoder_io_sharedOutputs_2_b_ready                           ), //o
    .io_sharedOutputs_2_b_payload_resp    (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp[1:0]  ), //i
    .io_sharedOutputs_2_r_valid           (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_valid              ), //i
    .io_sharedOutputs_2_r_ready           (axi4SharedDecoder_io_sharedOutputs_2_r_ready                           ), //o
    .io_sharedOutputs_2_r_payload_data    (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data[31:0] ), //i
    .io_sharedOutputs_2_r_payload_resp    (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp[1:0]  ), //i
    .io_sharedOutputs_2_r_payload_last    (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last       ), //i
    .io_sharedOutputs_3_arw_valid         (axi4SharedDecoder_io_sharedOutputs_3_arw_valid                         ), //o
    .io_sharedOutputs_3_arw_ready         (io_sharedOutputs_3_arw_validPipe_fire                                  ), //i
    .io_sharedOutputs_3_arw_payload_addr  (axi4SharedDecoder_io_sharedOutputs_3_arw_payload_addr[31:0]            ), //o
    .io_sharedOutputs_3_arw_payload_size  (axi4SharedDecoder_io_sharedOutputs_3_arw_payload_size[2:0]             ), //o
    .io_sharedOutputs_3_arw_payload_cache (axi4SharedDecoder_io_sharedOutputs_3_arw_payload_cache[3:0]            ), //o
    .io_sharedOutputs_3_arw_payload_prot  (axi4SharedDecoder_io_sharedOutputs_3_arw_payload_prot[2:0]             ), //o
    .io_sharedOutputs_3_arw_payload_write (axi4SharedDecoder_io_sharedOutputs_3_arw_payload_write                 ), //o
    .io_sharedOutputs_3_w_valid           (axi4SharedDecoder_io_sharedOutputs_3_w_valid                           ), //o
    .io_sharedOutputs_3_w_ready           (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_w_ready             ), //i
    .io_sharedOutputs_3_w_payload_data    (axi4SharedDecoder_io_sharedOutputs_3_w_payload_data[31:0]              ), //o
    .io_sharedOutputs_3_w_payload_strb    (axi4SharedDecoder_io_sharedOutputs_3_w_payload_strb[3:0]               ), //o
    .io_sharedOutputs_3_w_payload_last    (axi4SharedDecoder_io_sharedOutputs_3_w_payload_last                    ), //o
    .io_sharedOutputs_3_b_valid           (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_valid             ), //i
    .io_sharedOutputs_3_b_ready           (axi4SharedDecoder_io_sharedOutputs_3_b_ready                           ), //o
    .io_sharedOutputs_3_b_payload_resp    (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp[1:0] ), //i
    .io_sharedOutputs_3_r_valid           (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_valid             ), //i
    .io_sharedOutputs_3_r_ready           (axi4SharedDecoder_io_sharedOutputs_3_r_ready                           ), //o
    .io_sharedOutputs_3_r_payload_data    (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data[31:0]), //i
    .io_sharedOutputs_3_r_payload_resp    (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp[1:0] ), //i
    .io_sharedOutputs_3_r_payload_last    (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last      ), //i
    .io_axiClk                            (io_axiClk                                                              ), //i
    .resetCtrl_axiReset                   (resetCtrl_axiReset                                                     )  //i
  );
  vexAxi4SharedArbiter axi_apbBridge_io_axi_arbiter (
    .io_sharedInputs_0_arw_valid         (io_sharedOutputs_1_arw_validPipe_valid                               ), //i
    .io_sharedInputs_0_arw_ready         (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_ready             ), //o
    .io_sharedInputs_0_arw_payload_addr  (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr[19:0]), //i
    .io_sharedInputs_0_arw_payload_id    (_zz_io_sharedInputs_0_arw_payload_id[3:0]                            ), //i
    .io_sharedInputs_0_arw_payload_len   (_zz_io_sharedInputs_0_arw_payload_len[7:0]                           ), //i
    .io_sharedInputs_0_arw_payload_size  (io_sharedOutputs_1_arw_validPipe_payload_size[2:0]                   ), //i
    .io_sharedInputs_0_arw_payload_burst (2'b01                                                                ), //i
    .io_sharedInputs_0_arw_payload_write (io_sharedOutputs_1_arw_validPipe_payload_write                       ), //i
    .io_sharedInputs_0_w_valid           (axi4SharedDecoder_io_sharedOutputs_1_w_valid                         ), //i
    .io_sharedInputs_0_w_ready           (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_w_ready               ), //o
    .io_sharedInputs_0_w_payload_data    (axi4SharedDecoder_io_sharedOutputs_1_w_payload_data[31:0]            ), //i
    .io_sharedInputs_0_w_payload_strb    (axi4SharedDecoder_io_sharedOutputs_1_w_payload_strb[3:0]             ), //i
    .io_sharedInputs_0_w_payload_last    (axi4SharedDecoder_io_sharedOutputs_1_w_payload_last                  ), //i
    .io_sharedInputs_0_b_valid           (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_valid               ), //o
    .io_sharedInputs_0_b_ready           (axi4SharedDecoder_io_sharedOutputs_1_b_ready                         ), //i
    .io_sharedInputs_0_b_payload_id      (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_id[3:0]     ), //o
    .io_sharedInputs_0_b_payload_resp    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_resp[1:0]   ), //o
    .io_sharedInputs_0_r_valid           (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_valid               ), //o
    .io_sharedInputs_0_r_ready           (axi4SharedDecoder_io_sharedOutputs_1_r_ready                         ), //i
    .io_sharedInputs_0_r_payload_data    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_data[31:0]  ), //o
    .io_sharedInputs_0_r_payload_id      (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_id[3:0]     ), //o
    .io_sharedInputs_0_r_payload_resp    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_resp[1:0]   ), //o
    .io_sharedInputs_0_r_payload_last    (axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_last        ), //o
    .io_output_arw_valid                 (axi_apbBridge_io_axi_arbiter_io_output_arw_valid                     ), //o
    .io_output_arw_ready                 (axi_apbBridge_io_axi_arbiter_io_output_arw_ready                     ), //i
    .io_output_arw_payload_addr          (axi_apbBridge_io_axi_arbiter_io_output_arw_payload_addr[19:0]        ), //o
    .io_output_arw_payload_id            (axi_apbBridge_io_axi_arbiter_io_output_arw_payload_id[3:0]           ), //o
    .io_output_arw_payload_len           (axi_apbBridge_io_axi_arbiter_io_output_arw_payload_len[7:0]          ), //o
    .io_output_arw_payload_size          (axi_apbBridge_io_axi_arbiter_io_output_arw_payload_size[2:0]         ), //o
    .io_output_arw_payload_burst         (axi_apbBridge_io_axi_arbiter_io_output_arw_payload_burst[1:0]        ), //o
    .io_output_arw_payload_write         (axi_apbBridge_io_axi_arbiter_io_output_arw_payload_write             ), //o
    .io_output_w_valid                   (axi_apbBridge_io_axi_arbiter_io_output_w_valid                       ), //o
    .io_output_w_ready                   (axi_apbBridge_io_axi_arbiter_io_output_w_ready                       ), //i
    .io_output_w_payload_data            (axi_apbBridge_io_axi_arbiter_io_output_w_payload_data[31:0]          ), //o
    .io_output_w_payload_strb            (axi_apbBridge_io_axi_arbiter_io_output_w_payload_strb[3:0]           ), //o
    .io_output_w_payload_last            (axi_apbBridge_io_axi_arbiter_io_output_w_payload_last                ), //o
    .io_output_b_valid                   (axi_apbBridge_io_axi_b_valid                                         ), //i
    .io_output_b_ready                   (axi_apbBridge_io_axi_arbiter_io_output_b_ready                       ), //o
    .io_output_b_payload_id              (axi_apbBridge_io_axi_b_payload_id[3:0]                               ), //i
    .io_output_b_payload_resp            (axi_apbBridge_io_axi_b_payload_resp[1:0]                             ), //i
    .io_output_r_valid                   (axi_apbBridge_io_axi_r_valid                                         ), //i
    .io_output_r_ready                   (axi_apbBridge_io_axi_arbiter_io_output_r_ready                       ), //o
    .io_output_r_payload_data            (axi_apbBridge_io_axi_r_payload_data[31:0]                            ), //i
    .io_output_r_payload_id              (axi_apbBridge_io_axi_r_payload_id[3:0]                               ), //i
    .io_output_r_payload_resp            (axi_apbBridge_io_axi_r_payload_resp[1:0]                             ), //i
    .io_output_r_payload_last            (axi_apbBridge_io_axi_r_payload_last                                  ), //i
    .io_axiClk                           (io_axiClk                                                            ), //i
    .resetCtrl_axiReset                  (resetCtrl_axiReset                                                   )  //i
  );
  vexAxi4SharedArbiter_1 axi_ramBridge_io_shared_arbiter (
    .io_readInputs_0_ar_valid             (io_outputs_0_ar_validPipe_valid                                       ), //i
    .io_readInputs_0_ar_ready             (axi_ramBridge_io_shared_arbiter_io_readInputs_0_ar_ready              ), //o
    .io_readInputs_0_ar_payload_addr      (io_outputs_0_ar_validPipe_payload_addr[31:0]                          ), //i
    .io_readInputs_0_ar_payload_id        (_zz_io_readInputs_0_ar_payload_id[2:0]                                ), //i
    .io_readInputs_0_ar_payload_region    (_zz_io_readInputs_0_ar_payload_region[3:0]                            ), //i
    .io_readInputs_0_ar_payload_len       (_zz_io_readInputs_0_ar_payload_len[7:0]                               ), //i
    .io_readInputs_0_ar_payload_size      (3'b010                                                                ), //i
    .io_readInputs_0_ar_payload_burst     (2'b01                                                                 ), //i
    .io_readInputs_0_ar_payload_lock      (1'b0                                                                  ), //i
    .io_readInputs_0_ar_payload_cache     (io_outputs_0_ar_validPipe_payload_cache[3:0]                          ), //i
    .io_readInputs_0_ar_payload_qos       (4'b0000                                                               ), //i
    .io_readInputs_0_ar_payload_prot      (io_outputs_0_ar_validPipe_payload_prot[2:0]                           ), //i
    .io_readInputs_0_r_valid              (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_valid               ), //o
    .io_readInputs_0_r_ready              (axi4ReadOnlyDecoder_io_outputs_0_r_ready                              ), //i
    .io_readInputs_0_r_payload_data       (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_data[31:0]  ), //o
    .io_readInputs_0_r_payload_id         (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_id[2:0]     ), //o
    .io_readInputs_0_r_payload_resp       (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_resp[1:0]   ), //o
    .io_readInputs_0_r_payload_last       (axi_ramBridge_io_shared_arbiter_io_readInputs_0_r_payload_last        ), //o
    .io_sharedInputs_0_arw_valid          (io_sharedOutputs_0_arw_validPipe_valid                                ), //i
    .io_sharedInputs_0_arw_ready          (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready           ), //o
    .io_sharedInputs_0_arw_payload_addr   (io_sharedOutputs_0_arw_validPipe_payload_addr[31:0]                   ), //i
    .io_sharedInputs_0_arw_payload_id     (_zz_io_sharedInputs_0_arw_payload_id_1[2:0]                           ), //i
    .io_sharedInputs_0_arw_payload_region (_zz_io_sharedInputs_0_arw_payload_region[3:0]                         ), //i
    .io_sharedInputs_0_arw_payload_len    (_zz_io_sharedInputs_0_arw_payload_len_1[7:0]                          ), //i
    .io_sharedInputs_0_arw_payload_size   (io_sharedOutputs_0_arw_validPipe_payload_size[2:0]                    ), //i
    .io_sharedInputs_0_arw_payload_burst  (2'b01                                                                 ), //i
    .io_sharedInputs_0_arw_payload_lock   (1'b0                                                                  ), //i
    .io_sharedInputs_0_arw_payload_cache  (io_sharedOutputs_0_arw_validPipe_payload_cache[3:0]                   ), //i
    .io_sharedInputs_0_arw_payload_qos    (4'b0000                                                               ), //i
    .io_sharedInputs_0_arw_payload_prot   (io_sharedOutputs_0_arw_validPipe_payload_prot[2:0]                    ), //i
    .io_sharedInputs_0_arw_payload_write  (io_sharedOutputs_0_arw_validPipe_payload_write                        ), //i
    .io_sharedInputs_0_w_valid            (axi4SharedDecoder_io_sharedOutputs_0_w_valid                          ), //i
    .io_sharedInputs_0_w_ready            (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_w_ready             ), //o
    .io_sharedInputs_0_w_payload_data     (axi4SharedDecoder_io_sharedOutputs_0_w_payload_data[31:0]             ), //i
    .io_sharedInputs_0_w_payload_strb     (axi4SharedDecoder_io_sharedOutputs_0_w_payload_strb[3:0]              ), //i
    .io_sharedInputs_0_w_payload_last     (axi4SharedDecoder_io_sharedOutputs_0_w_payload_last                   ), //i
    .io_sharedInputs_0_b_valid            (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_valid             ), //o
    .io_sharedInputs_0_b_ready            (axi4SharedDecoder_io_sharedOutputs_0_b_ready                          ), //i
    .io_sharedInputs_0_b_payload_id       (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_id[2:0]   ), //o
    .io_sharedInputs_0_b_payload_resp     (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp[1:0] ), //o
    .io_sharedInputs_0_r_valid            (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_valid             ), //o
    .io_sharedInputs_0_r_ready            (axi4SharedDecoder_io_sharedOutputs_0_r_ready                          ), //i
    .io_sharedInputs_0_r_payload_data     (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data[31:0]), //o
    .io_sharedInputs_0_r_payload_id       (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_id[2:0]   ), //o
    .io_sharedInputs_0_r_payload_resp     (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp[1:0] ), //o
    .io_sharedInputs_0_r_payload_last     (axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last      ), //o
    .io_output_arw_valid                  (axi_ramBridge_io_shared_arbiter_io_output_arw_valid                   ), //o
    .io_output_arw_ready                  (axi_ramBridge_io_shared_arbiter_io_output_arw_ready                   ), //i
    .io_output_arw_payload_addr           (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_addr[31:0]      ), //o
    .io_output_arw_payload_id             (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_id[3:0]         ), //o
    .io_output_arw_payload_region         (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_region[3:0]     ), //o
    .io_output_arw_payload_len            (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_len[7:0]        ), //o
    .io_output_arw_payload_size           (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_size[2:0]       ), //o
    .io_output_arw_payload_burst          (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_burst[1:0]      ), //o
    .io_output_arw_payload_lock           (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_lock            ), //o
    .io_output_arw_payload_cache          (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_cache[3:0]      ), //o
    .io_output_arw_payload_qos            (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_qos[3:0]        ), //o
    .io_output_arw_payload_prot           (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_prot[2:0]       ), //o
    .io_output_arw_payload_write          (axi_ramBridge_io_shared_arbiter_io_output_arw_payload_write           ), //o
    .io_output_w_valid                    (axi_ramBridge_io_shared_arbiter_io_output_w_valid                     ), //o
    .io_output_w_ready                    (io_output_w_rValidN                                                   ), //i
    .io_output_w_payload_data             (axi_ramBridge_io_shared_arbiter_io_output_w_payload_data[31:0]        ), //o
    .io_output_w_payload_strb             (axi_ramBridge_io_shared_arbiter_io_output_w_payload_strb[3:0]         ), //o
    .io_output_w_payload_last             (axi_ramBridge_io_shared_arbiter_io_output_w_payload_last              ), //o
    .io_output_b_valid                    (axi_ramBridge_io_shared_b_valid                                       ), //i
    .io_output_b_ready                    (axi_ramBridge_io_shared_arbiter_io_output_b_ready                     ), //o
    .io_output_b_payload_id               (axi_ramBridge_io_shared_b_payload_id[3:0]                             ), //i
    .io_output_b_payload_resp             (axi_ramBridge_io_shared_b_payload_resp[1:0]                           ), //i
    .io_output_r_valid                    (axi_ramBridge_io_shared_r_valid                                       ), //i
    .io_output_r_ready                    (axi_ramBridge_io_shared_arbiter_io_output_r_ready                     ), //o
    .io_output_r_payload_data             (axi_ramBridge_io_shared_r_payload_data[31:0]                          ), //i
    .io_output_r_payload_id               (axi_ramBridge_io_shared_r_payload_id[3:0]                             ), //i
    .io_output_r_payload_resp             (axi_ramBridge_io_shared_r_payload_resp[1:0]                           ), //i
    .io_output_r_payload_last             (axi_ramBridge_io_shared_r_payload_last                                ), //i
    .io_axiClk                            (io_axiClk                                                             ), //i
    .resetCtrl_axiReset                   (resetCtrl_axiReset                                                    )  //i
  );
  vexAxi4SharedArbiter_2 axi_extBridge_io_shared_arbiter (
    .io_sharedInputs_0_arw_valid          (io_sharedOutputs_2_arw_validPipe_valid                                ), //i
    .io_sharedInputs_0_arw_ready          (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready           ), //o
    .io_sharedInputs_0_arw_payload_addr   (io_sharedOutputs_2_arw_validPipe_payload_addr[31:0]                   ), //i
    .io_sharedInputs_0_arw_payload_id     (_zz_io_sharedInputs_0_arw_payload_id_2[3:0]                           ), //i
    .io_sharedInputs_0_arw_payload_region (_zz_io_sharedInputs_0_arw_payload_region_1[3:0]                       ), //i
    .io_sharedInputs_0_arw_payload_len    (_zz_io_sharedInputs_0_arw_payload_len_2[7:0]                          ), //i
    .io_sharedInputs_0_arw_payload_size   (io_sharedOutputs_2_arw_validPipe_payload_size[2:0]                    ), //i
    .io_sharedInputs_0_arw_payload_burst  (2'b01                                                                 ), //i
    .io_sharedInputs_0_arw_payload_lock   (1'b0                                                                  ), //i
    .io_sharedInputs_0_arw_payload_cache  (io_sharedOutputs_2_arw_validPipe_payload_cache[3:0]                   ), //i
    .io_sharedInputs_0_arw_payload_qos    (4'b0000                                                               ), //i
    .io_sharedInputs_0_arw_payload_prot   (io_sharedOutputs_2_arw_validPipe_payload_prot[2:0]                    ), //i
    .io_sharedInputs_0_arw_payload_write  (io_sharedOutputs_2_arw_validPipe_payload_write                        ), //i
    .io_sharedInputs_0_w_valid            (axi4SharedDecoder_io_sharedOutputs_2_w_valid                          ), //i
    .io_sharedInputs_0_w_ready            (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_w_ready             ), //o
    .io_sharedInputs_0_w_payload_data     (axi4SharedDecoder_io_sharedOutputs_2_w_payload_data[31:0]             ), //i
    .io_sharedInputs_0_w_payload_strb     (axi4SharedDecoder_io_sharedOutputs_2_w_payload_strb[3:0]              ), //i
    .io_sharedInputs_0_w_payload_last     (axi4SharedDecoder_io_sharedOutputs_2_w_payload_last                   ), //i
    .io_sharedInputs_0_b_valid            (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_valid             ), //o
    .io_sharedInputs_0_b_ready            (axi4SharedDecoder_io_sharedOutputs_2_b_ready                          ), //i
    .io_sharedInputs_0_b_payload_id       (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_id[3:0]   ), //o
    .io_sharedInputs_0_b_payload_resp     (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp[1:0] ), //o
    .io_sharedInputs_0_r_valid            (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_valid             ), //o
    .io_sharedInputs_0_r_ready            (axi4SharedDecoder_io_sharedOutputs_2_r_ready                          ), //i
    .io_sharedInputs_0_r_payload_data     (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data[31:0]), //o
    .io_sharedInputs_0_r_payload_id       (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_id[3:0]   ), //o
    .io_sharedInputs_0_r_payload_resp     (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp[1:0] ), //o
    .io_sharedInputs_0_r_payload_last     (axi_extBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last      ), //o
    .io_output_arw_valid                  (axi_extBridge_io_shared_arbiter_io_output_arw_valid                   ), //o
    .io_output_arw_ready                  (axi_extBridge_io_shared_arbiter_io_output_arw_ready                   ), //i
    .io_output_arw_payload_addr           (axi_extBridge_io_shared_arbiter_io_output_arw_payload_addr[31:0]      ), //o
    .io_output_arw_payload_id             (axi_extBridge_io_shared_arbiter_io_output_arw_payload_id[3:0]         ), //o
    .io_output_arw_payload_region         (axi_extBridge_io_shared_arbiter_io_output_arw_payload_region[3:0]     ), //o
    .io_output_arw_payload_len            (axi_extBridge_io_shared_arbiter_io_output_arw_payload_len[7:0]        ), //o
    .io_output_arw_payload_size           (axi_extBridge_io_shared_arbiter_io_output_arw_payload_size[2:0]       ), //o
    .io_output_arw_payload_burst          (axi_extBridge_io_shared_arbiter_io_output_arw_payload_burst[1:0]      ), //o
    .io_output_arw_payload_lock           (axi_extBridge_io_shared_arbiter_io_output_arw_payload_lock            ), //o
    .io_output_arw_payload_cache          (axi_extBridge_io_shared_arbiter_io_output_arw_payload_cache[3:0]      ), //o
    .io_output_arw_payload_qos            (axi_extBridge_io_shared_arbiter_io_output_arw_payload_qos[3:0]        ), //o
    .io_output_arw_payload_prot           (axi_extBridge_io_shared_arbiter_io_output_arw_payload_prot[2:0]       ), //o
    .io_output_arw_payload_write          (axi_extBridge_io_shared_arbiter_io_output_arw_payload_write           ), //o
    .io_output_w_valid                    (axi_extBridge_io_shared_arbiter_io_output_w_valid                     ), //o
    .io_output_w_ready                    (io_output_w_rValidN_1                                                 ), //i
    .io_output_w_payload_data             (axi_extBridge_io_shared_arbiter_io_output_w_payload_data[31:0]        ), //o
    .io_output_w_payload_strb             (axi_extBridge_io_shared_arbiter_io_output_w_payload_strb[3:0]         ), //o
    .io_output_w_payload_last             (axi_extBridge_io_shared_arbiter_io_output_w_payload_last              ), //o
    .io_output_b_valid                    (axi_extBridge_io_shared_b_valid                                       ), //i
    .io_output_b_ready                    (axi_extBridge_io_shared_arbiter_io_output_b_ready                     ), //o
    .io_output_b_payload_id               (axi_extBridge_io_shared_b_payload_id[3:0]                             ), //i
    .io_output_b_payload_resp             (axi_extBridge_io_shared_b_payload_resp[1:0]                           ), //i
    .io_output_r_valid                    (axi_extBridge_io_shared_r_valid                                       ), //i
    .io_output_r_ready                    (axi_extBridge_io_shared_arbiter_io_output_r_ready                     ), //o
    .io_output_r_payload_data             (axi_extBridge_io_shared_r_payload_data[31:0]                          ), //i
    .io_output_r_payload_id               (axi_extBridge_io_shared_r_payload_id[3:0]                             ), //i
    .io_output_r_payload_resp             (axi_extBridge_io_shared_r_payload_resp[1:0]                           ), //i
    .io_output_r_payload_last             (axi_extBridge_io_shared_r_payload_last                                ), //i
    .io_axiClk                            (io_axiClk                                                             ), //i
    .resetCtrl_axiReset                   (resetCtrl_axiReset                                                    )  //i
  );
  vexAxi4SharedArbiter_2 axi_liteBridge_io_shared_arbiter (
    .io_sharedInputs_0_arw_valid          (io_sharedOutputs_3_arw_validPipe_valid                                 ), //i
    .io_sharedInputs_0_arw_ready          (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready           ), //o
    .io_sharedInputs_0_arw_payload_addr   (io_sharedOutputs_3_arw_validPipe_payload_addr[31:0]                    ), //i
    .io_sharedInputs_0_arw_payload_id     (_zz_io_sharedInputs_0_arw_payload_id_3[3:0]                            ), //i
    .io_sharedInputs_0_arw_payload_region (_zz_io_sharedInputs_0_arw_payload_region_2[3:0]                        ), //i
    .io_sharedInputs_0_arw_payload_len    (_zz_io_sharedInputs_0_arw_payload_len_3[7:0]                           ), //i
    .io_sharedInputs_0_arw_payload_size   (io_sharedOutputs_3_arw_validPipe_payload_size[2:0]                     ), //i
    .io_sharedInputs_0_arw_payload_burst  (2'b01                                                                  ), //i
    .io_sharedInputs_0_arw_payload_lock   (1'b0                                                                   ), //i
    .io_sharedInputs_0_arw_payload_cache  (io_sharedOutputs_3_arw_validPipe_payload_cache[3:0]                    ), //i
    .io_sharedInputs_0_arw_payload_qos    (4'b0000                                                                ), //i
    .io_sharedInputs_0_arw_payload_prot   (io_sharedOutputs_3_arw_validPipe_payload_prot[2:0]                     ), //i
    .io_sharedInputs_0_arw_payload_write  (io_sharedOutputs_3_arw_validPipe_payload_write                         ), //i
    .io_sharedInputs_0_w_valid            (axi4SharedDecoder_io_sharedOutputs_3_w_valid                           ), //i
    .io_sharedInputs_0_w_ready            (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_w_ready             ), //o
    .io_sharedInputs_0_w_payload_data     (axi4SharedDecoder_io_sharedOutputs_3_w_payload_data[31:0]              ), //i
    .io_sharedInputs_0_w_payload_strb     (axi4SharedDecoder_io_sharedOutputs_3_w_payload_strb[3:0]               ), //i
    .io_sharedInputs_0_w_payload_last     (axi4SharedDecoder_io_sharedOutputs_3_w_payload_last                    ), //i
    .io_sharedInputs_0_b_valid            (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_valid             ), //o
    .io_sharedInputs_0_b_ready            (axi4SharedDecoder_io_sharedOutputs_3_b_ready                           ), //i
    .io_sharedInputs_0_b_payload_id       (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_id[3:0]   ), //o
    .io_sharedInputs_0_b_payload_resp     (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_b_payload_resp[1:0] ), //o
    .io_sharedInputs_0_r_valid            (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_valid             ), //o
    .io_sharedInputs_0_r_ready            (axi4SharedDecoder_io_sharedOutputs_3_r_ready                           ), //i
    .io_sharedInputs_0_r_payload_data     (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_data[31:0]), //o
    .io_sharedInputs_0_r_payload_id       (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_id[3:0]   ), //o
    .io_sharedInputs_0_r_payload_resp     (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_resp[1:0] ), //o
    .io_sharedInputs_0_r_payload_last     (axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_r_payload_last      ), //o
    .io_output_arw_valid                  (axi_liteBridge_io_shared_arbiter_io_output_arw_valid                   ), //o
    .io_output_arw_ready                  (axi_liteBridge_io_shared_arbiter_io_output_arw_ready                   ), //i
    .io_output_arw_payload_addr           (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_addr[31:0]      ), //o
    .io_output_arw_payload_id             (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_id[3:0]         ), //o
    .io_output_arw_payload_region         (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_region[3:0]     ), //o
    .io_output_arw_payload_len            (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_len[7:0]        ), //o
    .io_output_arw_payload_size           (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_size[2:0]       ), //o
    .io_output_arw_payload_burst          (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_burst[1:0]      ), //o
    .io_output_arw_payload_lock           (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_lock            ), //o
    .io_output_arw_payload_cache          (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_cache[3:0]      ), //o
    .io_output_arw_payload_qos            (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_qos[3:0]        ), //o
    .io_output_arw_payload_prot           (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_prot[2:0]       ), //o
    .io_output_arw_payload_write          (axi_liteBridge_io_shared_arbiter_io_output_arw_payload_write           ), //o
    .io_output_w_valid                    (axi_liteBridge_io_shared_arbiter_io_output_w_valid                     ), //o
    .io_output_w_ready                    (io_output_w_rValidN_2                                                  ), //i
    .io_output_w_payload_data             (axi_liteBridge_io_shared_arbiter_io_output_w_payload_data[31:0]        ), //o
    .io_output_w_payload_strb             (axi_liteBridge_io_shared_arbiter_io_output_w_payload_strb[3:0]         ), //o
    .io_output_w_payload_last             (axi_liteBridge_io_shared_arbiter_io_output_w_payload_last              ), //o
    .io_output_b_valid                    (axi_liteBridge_io_shared_b_valid                                       ), //i
    .io_output_b_ready                    (axi_liteBridge_io_shared_arbiter_io_output_b_ready                     ), //o
    .io_output_b_payload_id               (axi_liteBridge_io_shared_b_payload_id[3:0]                             ), //i
    .io_output_b_payload_resp             (axi_liteBridge_io_shared_b_payload_resp[1:0]                           ), //i
    .io_output_r_valid                    (axi_liteBridge_io_shared_r_valid                                       ), //i
    .io_output_r_ready                    (axi_liteBridge_io_shared_arbiter_io_output_r_ready                     ), //o
    .io_output_r_payload_data             (axi_liteBridge_io_shared_r_payload_data[31:0]                          ), //i
    .io_output_r_payload_id               (axi_liteBridge_io_shared_r_payload_id[3:0]                             ), //i
    .io_output_r_payload_resp             (axi_liteBridge_io_shared_r_payload_resp[1:0]                           ), //i
    .io_output_r_payload_last             (axi_liteBridge_io_shared_r_payload_last                                ), //i
    .io_axiClk                            (io_axiClk                                                              ), //i
    .resetCtrl_axiReset                   (resetCtrl_axiReset                                                     )  //i
  );
  vexApb3Decoder io_apb_decoder (
    .io_input_PADDR      (axi_apbBridge_io_apb_PADDR[19:0]     ), //i
    .io_input_PSEL       (axi_apbBridge_io_apb_PSEL            ), //i
    .io_input_PENABLE    (axi_apbBridge_io_apb_PENABLE         ), //i
    .io_input_PREADY     (io_apb_decoder_io_input_PREADY       ), //o
    .io_input_PWRITE     (axi_apbBridge_io_apb_PWRITE          ), //i
    .io_input_PWDATA     (axi_apbBridge_io_apb_PWDATA[31:0]    ), //i
    .io_input_PRDATA     (io_apb_decoder_io_input_PRDATA[31:0] ), //o
    .io_input_PSLVERROR  (io_apb_decoder_io_input_PSLVERROR    ), //o
    .io_output_PADDR     (io_apb_decoder_io_output_PADDR[19:0] ), //o
    .io_output_PSEL      (io_apb_decoder_io_output_PSEL        ), //o
    .io_output_PENABLE   (io_apb_decoder_io_output_PENABLE     ), //o
    .io_output_PREADY    (apb3Router_io_input_PREADY           ), //i
    .io_output_PWRITE    (io_apb_decoder_io_output_PWRITE      ), //o
    .io_output_PWDATA    (io_apb_decoder_io_output_PWDATA[31:0]), //o
    .io_output_PRDATA    (apb3Router_io_input_PRDATA[31:0]     ), //i
    .io_output_PSLVERROR (apb3Router_io_input_PSLVERROR        )  //i
  );
  vexApb3Router apb3Router (
    .io_input_PADDR         (io_apb_decoder_io_output_PADDR[19:0] ), //i
    .io_input_PSEL          (io_apb_decoder_io_output_PSEL        ), //i
    .io_input_PENABLE       (io_apb_decoder_io_output_PENABLE     ), //i
    .io_input_PREADY        (apb3Router_io_input_PREADY           ), //o
    .io_input_PWRITE        (io_apb_decoder_io_output_PWRITE      ), //i
    .io_input_PWDATA        (io_apb_decoder_io_output_PWDATA[31:0]), //i
    .io_input_PRDATA        (apb3Router_io_input_PRDATA[31:0]     ), //o
    .io_input_PSLVERROR     (apb3Router_io_input_PSLVERROR        ), //o
    .io_outputs_0_PADDR     (apb3Router_io_outputs_0_PADDR[19:0]  ), //o
    .io_outputs_0_PSEL      (apb3Router_io_outputs_0_PSEL         ), //o
    .io_outputs_0_PENABLE   (apb3Router_io_outputs_0_PENABLE      ), //o
    .io_outputs_0_PREADY    (axi_uartCtrl_io_apb_PREADY           ), //i
    .io_outputs_0_PWRITE    (apb3Router_io_outputs_0_PWRITE       ), //o
    .io_outputs_0_PWDATA    (apb3Router_io_outputs_0_PWDATA[31:0] ), //o
    .io_outputs_0_PRDATA    (axi_uartCtrl_io_apb_PRDATA[31:0]     ), //i
    .io_outputs_0_PSLVERROR (1'b0                                 ), //i
    .io_axiClk              (io_axiClk                            ), //i
    .resetCtrl_axiReset     (resetCtrl_axiReset                   )  //i
  );
  initial begin
    resetCtrl_systemResetCounter = 6'h0;
  end

  always @(*) begin
    resetCtrl_systemResetUnbuffered = 1'b0;
    if(when_RiscvCpu_l172) begin
      resetCtrl_systemResetUnbuffered = 1'b1;
    end
  end

  assign _zz_when_RiscvCpu_l172[5 : 0] = 6'h3f;
  assign when_RiscvCpu_l172 = (resetCtrl_systemResetCounter != _zz_when_RiscvCpu_l172);
  assign when_RiscvCpu_l176 = io_asyncReset_buffercc_io_dataOut;
  assign io_ramAxi_aw_valid = axi_ramBridge_io_axi_aw_valid;
  assign io_ramAxi_aw_payload_addr = axi_ramBridge_io_axi_aw_payload_addr;
  assign io_ramAxi_aw_payload_id = axi_ramBridge_io_axi_aw_payload_id;
  assign io_ramAxi_aw_payload_region = axi_ramBridge_io_axi_aw_payload_region;
  assign io_ramAxi_aw_payload_len = axi_ramBridge_io_axi_aw_payload_len;
  assign io_ramAxi_aw_payload_size = axi_ramBridge_io_axi_aw_payload_size;
  assign io_ramAxi_aw_payload_burst = axi_ramBridge_io_axi_aw_payload_burst;
  assign io_ramAxi_aw_payload_lock = axi_ramBridge_io_axi_aw_payload_lock;
  assign io_ramAxi_aw_payload_cache = axi_ramBridge_io_axi_aw_payload_cache;
  assign io_ramAxi_aw_payload_qos = axi_ramBridge_io_axi_aw_payload_qos;
  assign io_ramAxi_aw_payload_prot = axi_ramBridge_io_axi_aw_payload_prot;
  assign io_ramAxi_w_valid = axi_ramBridge_io_axi_w_valid;
  assign io_ramAxi_w_payload_data = axi_ramBridge_io_axi_w_payload_data;
  assign io_ramAxi_w_payload_strb = axi_ramBridge_io_axi_w_payload_strb;
  assign io_ramAxi_w_payload_last = axi_ramBridge_io_axi_w_payload_last;
  assign io_ramAxi_b_ready = axi_ramBridge_io_axi_b_ready;
  assign io_ramAxi_ar_valid = axi_ramBridge_io_axi_ar_valid;
  assign io_ramAxi_ar_payload_addr = axi_ramBridge_io_axi_ar_payload_addr;
  assign io_ramAxi_ar_payload_id = axi_ramBridge_io_axi_ar_payload_id;
  assign io_ramAxi_ar_payload_region = axi_ramBridge_io_axi_ar_payload_region;
  assign io_ramAxi_ar_payload_len = axi_ramBridge_io_axi_ar_payload_len;
  assign io_ramAxi_ar_payload_size = axi_ramBridge_io_axi_ar_payload_size;
  assign io_ramAxi_ar_payload_burst = axi_ramBridge_io_axi_ar_payload_burst;
  assign io_ramAxi_ar_payload_lock = axi_ramBridge_io_axi_ar_payload_lock;
  assign io_ramAxi_ar_payload_cache = axi_ramBridge_io_axi_ar_payload_cache;
  assign io_ramAxi_ar_payload_qos = axi_ramBridge_io_axi_ar_payload_qos;
  assign io_ramAxi_ar_payload_prot = axi_ramBridge_io_axi_ar_payload_prot;
  assign io_ramAxi_r_ready = axi_ramBridge_io_axi_r_ready;
  assign io_externalAxi_aw_valid = axi_extBridge_io_axi_aw_valid;
  assign io_externalAxi_aw_payload_addr = axi_extBridge_io_axi_aw_payload_addr;
  assign io_externalAxi_aw_payload_id = axi_extBridge_io_axi_aw_payload_id;
  assign io_externalAxi_aw_payload_region = axi_extBridge_io_axi_aw_payload_region;
  assign io_externalAxi_aw_payload_len = axi_extBridge_io_axi_aw_payload_len;
  assign io_externalAxi_aw_payload_size = axi_extBridge_io_axi_aw_payload_size;
  assign io_externalAxi_aw_payload_burst = axi_extBridge_io_axi_aw_payload_burst;
  assign io_externalAxi_aw_payload_lock = axi_extBridge_io_axi_aw_payload_lock;
  assign io_externalAxi_aw_payload_cache = axi_extBridge_io_axi_aw_payload_cache;
  assign io_externalAxi_aw_payload_qos = axi_extBridge_io_axi_aw_payload_qos;
  assign io_externalAxi_aw_payload_prot = axi_extBridge_io_axi_aw_payload_prot;
  assign io_externalAxi_w_valid = axi_extBridge_io_axi_w_valid;
  assign io_externalAxi_w_payload_data = axi_extBridge_io_axi_w_payload_data;
  assign io_externalAxi_w_payload_strb = axi_extBridge_io_axi_w_payload_strb;
  assign io_externalAxi_w_payload_last = axi_extBridge_io_axi_w_payload_last;
  assign io_externalAxi_b_ready = axi_extBridge_io_axi_b_ready;
  assign io_externalAxi_ar_valid = axi_extBridge_io_axi_ar_valid;
  assign io_externalAxi_ar_payload_addr = axi_extBridge_io_axi_ar_payload_addr;
  assign io_externalAxi_ar_payload_id = axi_extBridge_io_axi_ar_payload_id;
  assign io_externalAxi_ar_payload_region = axi_extBridge_io_axi_ar_payload_region;
  assign io_externalAxi_ar_payload_len = axi_extBridge_io_axi_ar_payload_len;
  assign io_externalAxi_ar_payload_size = axi_extBridge_io_axi_ar_payload_size;
  assign io_externalAxi_ar_payload_burst = axi_extBridge_io_axi_ar_payload_burst;
  assign io_externalAxi_ar_payload_lock = axi_extBridge_io_axi_ar_payload_lock;
  assign io_externalAxi_ar_payload_cache = axi_extBridge_io_axi_ar_payload_cache;
  assign io_externalAxi_ar_payload_qos = axi_extBridge_io_axi_ar_payload_qos;
  assign io_externalAxi_ar_payload_prot = axi_extBridge_io_axi_ar_payload_prot;
  assign io_externalAxi_r_ready = axi_extBridge_io_axi_r_ready;
  assign io_axiLite_aw_valid = axi_axiToLite_io_output_aw_valid;
  assign io_axiLite_aw_payload_addr = axi_axiToLite_io_output_aw_payload_addr;
  assign io_axiLite_aw_payload_prot = axi_axiToLite_io_output_aw_payload_prot;
  assign io_axiLite_w_valid = axi_axiToLite_io_output_w_valid;
  assign io_axiLite_w_payload_data = axi_axiToLite_io_output_w_payload_data;
  assign io_axiLite_w_payload_strb = axi_axiToLite_io_output_w_payload_strb;
  assign io_axiLite_b_ready = axi_axiToLite_io_output_b_ready;
  assign io_axiLite_ar_valid = axi_axiToLite_io_output_ar_valid;
  assign io_axiLite_ar_payload_addr = axi_axiToLite_io_output_ar_payload_addr;
  assign io_axiLite_ar_payload_prot = axi_axiToLite_io_output_ar_payload_prot;
  assign io_axiLite_r_ready = axi_axiToLite_io_output_r_ready;
  assign axi_core_cpu_iBus_rsp_payload_error = (! (axi4ReadOnlyDecoder_io_input_r_payload_resp == 2'b00));
  assign dBus_cmd_fire = (axi_core_cpu_dBus_cmd_valid && axi_core_cpu_dBus_cmd_ready);
  assign when_Utils_l732 = (dBus_cmd_fire && axi_core_cpu_dBus_cmd_payload_wr);
  always @(*) begin
    _zz_when_Utils_l767 = 1'b0;
    if(when_Utils_l732) begin
      _zz_when_Utils_l767 = 1'b1;
    end
  end

  always @(*) begin
    _zz_when_Utils_l767_1 = 1'b0;
    if((axi4SharedDecoder_io_input_b_valid && 1'b1)) begin
      _zz_when_Utils_l767_1 = 1'b1;
    end
  end

  assign when_Utils_l767 = (_zz_when_Utils_l767 && (! _zz_when_Utils_l767_1));
  always @(*) begin
    if(when_Utils_l767) begin
      _zz_dBus_cmd_haltWhen_valid_1 = 3'b001;
    end else begin
      if(when_Utils_l769) begin
        _zz_dBus_cmd_haltWhen_valid_1 = 3'b111;
      end else begin
        _zz_dBus_cmd_haltWhen_valid_1 = 3'b000;
      end
    end
  end

  assign when_Utils_l769 = ((! _zz_when_Utils_l767) && _zz_when_Utils_l767_1);
  assign _zz_dBus_cmd_haltWhen_valid_2 = (! ((((_zz_dBus_cmd_haltWhen_valid != 3'b000) && axi_core_cpu_dBus_cmd_valid) && (! axi_core_cpu_dBus_cmd_payload_wr)) || (_zz_dBus_cmd_haltWhen_valid == 3'b111)));
  assign dBus_cmd_haltWhen_valid = (axi_core_cpu_dBus_cmd_valid && _zz_dBus_cmd_haltWhen_valid_2);
  assign axi_core_cpu_dBus_cmd_ready = (dBus_cmd_haltWhen_ready && _zz_dBus_cmd_haltWhen_valid_2);
  assign dBus_cmd_haltWhen_payload_wr = axi_core_cpu_dBus_cmd_payload_wr;
  assign dBus_cmd_haltWhen_payload_mask = axi_core_cpu_dBus_cmd_payload_mask;
  assign dBus_cmd_haltWhen_payload_address = axi_core_cpu_dBus_cmd_payload_address;
  assign dBus_cmd_haltWhen_payload_data = axi_core_cpu_dBus_cmd_payload_data;
  assign dBus_cmd_haltWhen_payload_size = axi_core_cpu_dBus_cmd_payload_size;
  always @(*) begin
    dBus_cmd_haltWhen_ready = 1'b1;
    if(when_Stream_l1253) begin
      dBus_cmd_haltWhen_ready = 1'b0;
    end
    if(when_Stream_l1253_1) begin
      dBus_cmd_haltWhen_ready = 1'b0;
    end
  end

  assign when_Stream_l1253 = ((! dBus_cmd_haltWhen_fork2_outputs_0_ready) && dBus_cmd_haltWhen_fork2_logic_linkEnable_0);
  assign when_Stream_l1253_1 = ((! dBus_cmd_haltWhen_fork2_outputs_1_ready) && dBus_cmd_haltWhen_fork2_logic_linkEnable_1);
  assign dBus_cmd_haltWhen_fork2_outputs_0_valid = (dBus_cmd_haltWhen_valid && dBus_cmd_haltWhen_fork2_logic_linkEnable_0);
  assign dBus_cmd_haltWhen_fork2_outputs_0_payload_wr = dBus_cmd_haltWhen_payload_wr;
  assign dBus_cmd_haltWhen_fork2_outputs_0_payload_mask = dBus_cmd_haltWhen_payload_mask;
  assign dBus_cmd_haltWhen_fork2_outputs_0_payload_address = dBus_cmd_haltWhen_payload_address;
  assign dBus_cmd_haltWhen_fork2_outputs_0_payload_data = dBus_cmd_haltWhen_payload_data;
  assign dBus_cmd_haltWhen_fork2_outputs_0_payload_size = dBus_cmd_haltWhen_payload_size;
  assign dBus_cmd_haltWhen_fork2_outputs_0_fire = (dBus_cmd_haltWhen_fork2_outputs_0_valid && dBus_cmd_haltWhen_fork2_outputs_0_ready);
  assign dBus_cmd_haltWhen_fork2_outputs_1_valid = (dBus_cmd_haltWhen_valid && dBus_cmd_haltWhen_fork2_logic_linkEnable_1);
  assign dBus_cmd_haltWhen_fork2_outputs_1_payload_wr = dBus_cmd_haltWhen_payload_wr;
  assign dBus_cmd_haltWhen_fork2_outputs_1_payload_mask = dBus_cmd_haltWhen_payload_mask;
  assign dBus_cmd_haltWhen_fork2_outputs_1_payload_address = dBus_cmd_haltWhen_payload_address;
  assign dBus_cmd_haltWhen_fork2_outputs_1_payload_data = dBus_cmd_haltWhen_payload_data;
  assign dBus_cmd_haltWhen_fork2_outputs_1_payload_size = dBus_cmd_haltWhen_payload_size;
  assign dBus_cmd_haltWhen_fork2_outputs_1_fire = (dBus_cmd_haltWhen_fork2_outputs_1_valid && dBus_cmd_haltWhen_fork2_outputs_1_ready);
  assign dBus_cmd_haltWhen_fork2_outputs_0_ready = axi4SharedDecoder_io_input_arw_ready;
  assign when_Stream_l581 = (! dBus_cmd_haltWhen_fork2_outputs_1_payload_wr);
  always @(*) begin
    dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_valid = dBus_cmd_haltWhen_fork2_outputs_1_valid;
    if(when_Stream_l581) begin
      dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_valid = 1'b0;
    end
  end

  always @(*) begin
    dBus_cmd_haltWhen_fork2_outputs_1_ready = dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_ready;
    if(when_Stream_l581) begin
      dBus_cmd_haltWhen_fork2_outputs_1_ready = 1'b1;
    end
  end

  assign dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_wr = dBus_cmd_haltWhen_fork2_outputs_1_payload_wr;
  assign dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_mask = dBus_cmd_haltWhen_fork2_outputs_1_payload_mask;
  assign dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_address = dBus_cmd_haltWhen_fork2_outputs_1_payload_address;
  assign dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_data = dBus_cmd_haltWhen_fork2_outputs_1_payload_data;
  assign dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_size = dBus_cmd_haltWhen_fork2_outputs_1_payload_size;
  assign dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_ready = axi4SharedDecoder_io_input_w_ready;
  always @(*) begin
    case(dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_size)
      2'b00 : begin
        _zz_io_input_w_payload_strb = 4'b0001;
      end
      2'b01 : begin
        _zz_io_input_w_payload_strb = 4'b0011;
      end
      default : begin
        _zz_io_input_w_payload_strb = 4'b1111;
      end
    endcase
  end

  assign axi_core_cpu_dBus_rsp_error = (! (io_input_r_stage_payload_resp == 2'b00));
  assign io_outputs_0_ar_validPipe_fire = (io_outputs_0_ar_validPipe_valid && io_outputs_0_ar_validPipe_ready);
  assign io_outputs_0_ar_validPipe_valid = io_outputs_0_ar_rValid;
  assign io_outputs_0_ar_validPipe_payload_addr = axi4ReadOnlyDecoder_io_outputs_0_ar_payload_addr;
  assign io_outputs_0_ar_validPipe_payload_cache = axi4ReadOnlyDecoder_io_outputs_0_ar_payload_cache;
  assign io_outputs_0_ar_validPipe_payload_prot = axi4ReadOnlyDecoder_io_outputs_0_ar_payload_prot;
  assign io_outputs_0_ar_validPipe_ready = axi_ramBridge_io_shared_arbiter_io_readInputs_0_ar_ready;
  assign axi4ReadOnlyDecoder_io_input_ar_payload_addr = {axi_core_cpu_iBus_cmd_payload_pc[31 : 2],2'b00};
  assign io_sharedOutputs_0_arw_validPipe_fire = (io_sharedOutputs_0_arw_validPipe_valid && io_sharedOutputs_0_arw_validPipe_ready);
  assign io_sharedOutputs_0_arw_validPipe_valid = io_sharedOutputs_0_arw_rValid;
  assign io_sharedOutputs_0_arw_validPipe_payload_addr = axi4SharedDecoder_io_sharedOutputs_0_arw_payload_addr;
  assign io_sharedOutputs_0_arw_validPipe_payload_size = axi4SharedDecoder_io_sharedOutputs_0_arw_payload_size;
  assign io_sharedOutputs_0_arw_validPipe_payload_cache = axi4SharedDecoder_io_sharedOutputs_0_arw_payload_cache;
  assign io_sharedOutputs_0_arw_validPipe_payload_prot = axi4SharedDecoder_io_sharedOutputs_0_arw_payload_prot;
  assign io_sharedOutputs_0_arw_validPipe_payload_write = axi4SharedDecoder_io_sharedOutputs_0_arw_payload_write;
  assign io_sharedOutputs_0_arw_validPipe_ready = axi_ramBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready;
  assign io_sharedOutputs_1_arw_validPipe_fire = (io_sharedOutputs_1_arw_validPipe_valid && io_sharedOutputs_1_arw_validPipe_ready);
  assign io_sharedOutputs_1_arw_validPipe_valid = io_sharedOutputs_1_arw_rValid;
  assign io_sharedOutputs_1_arw_validPipe_payload_addr = axi4SharedDecoder_io_sharedOutputs_1_arw_payload_addr;
  assign io_sharedOutputs_1_arw_validPipe_payload_size = axi4SharedDecoder_io_sharedOutputs_1_arw_payload_size;
  assign io_sharedOutputs_1_arw_validPipe_payload_cache = axi4SharedDecoder_io_sharedOutputs_1_arw_payload_cache;
  assign io_sharedOutputs_1_arw_validPipe_payload_prot = axi4SharedDecoder_io_sharedOutputs_1_arw_payload_prot;
  assign io_sharedOutputs_1_arw_validPipe_payload_write = axi4SharedDecoder_io_sharedOutputs_1_arw_payload_write;
  assign io_sharedOutputs_1_arw_validPipe_ready = axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_ready;
  assign io_sharedOutputs_2_arw_validPipe_fire = (io_sharedOutputs_2_arw_validPipe_valid && io_sharedOutputs_2_arw_validPipe_ready);
  assign io_sharedOutputs_2_arw_validPipe_valid = io_sharedOutputs_2_arw_rValid;
  assign io_sharedOutputs_2_arw_validPipe_payload_addr = axi4SharedDecoder_io_sharedOutputs_2_arw_payload_addr;
  assign io_sharedOutputs_2_arw_validPipe_payload_size = axi4SharedDecoder_io_sharedOutputs_2_arw_payload_size;
  assign io_sharedOutputs_2_arw_validPipe_payload_cache = axi4SharedDecoder_io_sharedOutputs_2_arw_payload_cache;
  assign io_sharedOutputs_2_arw_validPipe_payload_prot = axi4SharedDecoder_io_sharedOutputs_2_arw_payload_prot;
  assign io_sharedOutputs_2_arw_validPipe_payload_write = axi4SharedDecoder_io_sharedOutputs_2_arw_payload_write;
  assign io_sharedOutputs_2_arw_validPipe_ready = axi_extBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready;
  assign io_sharedOutputs_3_arw_validPipe_fire = (io_sharedOutputs_3_arw_validPipe_valid && io_sharedOutputs_3_arw_validPipe_ready);
  assign io_sharedOutputs_3_arw_validPipe_valid = io_sharedOutputs_3_arw_rValid;
  assign io_sharedOutputs_3_arw_validPipe_payload_addr = axi4SharedDecoder_io_sharedOutputs_3_arw_payload_addr;
  assign io_sharedOutputs_3_arw_validPipe_payload_size = axi4SharedDecoder_io_sharedOutputs_3_arw_payload_size;
  assign io_sharedOutputs_3_arw_validPipe_payload_cache = axi4SharedDecoder_io_sharedOutputs_3_arw_payload_cache;
  assign io_sharedOutputs_3_arw_validPipe_payload_prot = axi4SharedDecoder_io_sharedOutputs_3_arw_payload_prot;
  assign io_sharedOutputs_3_arw_validPipe_payload_write = axi4SharedDecoder_io_sharedOutputs_3_arw_payload_write;
  assign io_sharedOutputs_3_arw_validPipe_ready = axi_liteBridge_io_shared_arbiter_io_sharedInputs_0_arw_ready;
  assign axi4SharedDecoder_io_input_arw_payload_size = {1'd0, dBus_cmd_haltWhen_fork2_outputs_0_payload_size};
  assign axi4SharedDecoder_io_input_w_payload_strb = (_zz_io_input_w_payload_strb <<< dBus_cmd_haltWhen_fork2_outputs_1_throwWhen_payload_address[1 : 0]);
  always @(*) begin
    axi4SharedDecoder_io_input_r_ready = io_input_r_stage_ready;
    if(when_Stream_l477) begin
      axi4SharedDecoder_io_input_r_ready = 1'b1;
    end
  end

  assign when_Stream_l477 = (! io_input_r_stage_valid);
  assign io_input_r_stage_valid = io_input_r_rValid;
  assign io_input_r_stage_payload_data = io_input_r_rData_data;
  assign io_input_r_stage_payload_resp = io_input_r_rData_resp;
  assign io_input_r_stage_payload_last = io_input_r_rData_last;
  assign io_input_r_stage_ready = 1'b1;
  assign axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr = io_sharedOutputs_1_arw_validPipe_payload_addr[19:0];
  assign _zz_io_sharedInputs_0_arw_payload_id[3 : 0] = 4'b0000;
  assign _zz_io_sharedInputs_0_arw_payload_len[7 : 0] = 8'h0;
  assign io_output_arw_halfPipe_fire = (io_output_arw_halfPipe_valid && io_output_arw_halfPipe_ready);
  assign axi_apbBridge_io_axi_arbiter_io_output_arw_ready = (! io_output_arw_rValid);
  assign io_output_arw_halfPipe_valid = io_output_arw_rValid;
  assign io_output_arw_halfPipe_payload_addr = io_output_arw_rData_addr;
  assign io_output_arw_halfPipe_payload_id = io_output_arw_rData_id;
  assign io_output_arw_halfPipe_payload_len = io_output_arw_rData_len;
  assign io_output_arw_halfPipe_payload_size = io_output_arw_rData_size;
  assign io_output_arw_halfPipe_payload_burst = io_output_arw_rData_burst;
  assign io_output_arw_halfPipe_payload_write = io_output_arw_rData_write;
  assign io_output_arw_halfPipe_ready = axi_apbBridge_io_axi_arw_ready;
  assign io_output_w_halfPipe_fire = (io_output_w_halfPipe_valid && io_output_w_halfPipe_ready);
  assign axi_apbBridge_io_axi_arbiter_io_output_w_ready = (! io_output_w_rValid);
  assign io_output_w_halfPipe_valid = io_output_w_rValid;
  assign io_output_w_halfPipe_payload_data = io_output_w_rData_data;
  assign io_output_w_halfPipe_payload_strb = io_output_w_rData_strb;
  assign io_output_w_halfPipe_payload_last = io_output_w_rData_last;
  assign io_output_w_halfPipe_ready = axi_apbBridge_io_axi_w_ready;
  assign _zz_io_readInputs_0_ar_payload_id[2 : 0] = 3'b000;
  assign _zz_io_readInputs_0_ar_payload_region[3 : 0] = 4'b0000;
  assign _zz_io_readInputs_0_ar_payload_len[7 : 0] = 8'h0;
  assign _zz_io_sharedInputs_0_arw_payload_id_1[2 : 0] = 3'b000;
  assign _zz_io_sharedInputs_0_arw_payload_region[3 : 0] = 4'b0000;
  assign _zz_io_sharedInputs_0_arw_payload_len_1[7 : 0] = 8'h0;
  assign io_output_arw_halfPipe_fire_1 = (io_output_arw_halfPipe_valid_1 && io_output_arw_halfPipe_ready_1);
  assign axi_ramBridge_io_shared_arbiter_io_output_arw_ready = (! io_output_arw_rValid_1);
  assign io_output_arw_halfPipe_valid_1 = io_output_arw_rValid_1;
  assign io_output_arw_halfPipe_payload_addr_1 = io_output_arw_rData_addr_1;
  assign io_output_arw_halfPipe_payload_id_1 = io_output_arw_rData_id_1;
  assign io_output_arw_halfPipe_payload_region = io_output_arw_rData_region;
  assign io_output_arw_halfPipe_payload_len_1 = io_output_arw_rData_len_1;
  assign io_output_arw_halfPipe_payload_size_1 = io_output_arw_rData_size_1;
  assign io_output_arw_halfPipe_payload_burst_1 = io_output_arw_rData_burst_1;
  assign io_output_arw_halfPipe_payload_lock = io_output_arw_rData_lock;
  assign io_output_arw_halfPipe_payload_cache = io_output_arw_rData_cache;
  assign io_output_arw_halfPipe_payload_qos = io_output_arw_rData_qos;
  assign io_output_arw_halfPipe_payload_prot = io_output_arw_rData_prot;
  assign io_output_arw_halfPipe_payload_write_1 = io_output_arw_rData_write_1;
  assign io_output_arw_halfPipe_ready_1 = axi_ramBridge_io_shared_arw_ready;
  assign io_output_w_s2mPipe_valid = (axi_ramBridge_io_shared_arbiter_io_output_w_valid || (! io_output_w_rValidN));
  assign io_output_w_s2mPipe_payload_data = (io_output_w_rValidN ? axi_ramBridge_io_shared_arbiter_io_output_w_payload_data : io_output_w_rData_data_1);
  assign io_output_w_s2mPipe_payload_strb = (io_output_w_rValidN ? axi_ramBridge_io_shared_arbiter_io_output_w_payload_strb : io_output_w_rData_strb_1);
  assign io_output_w_s2mPipe_payload_last = (io_output_w_rValidN ? axi_ramBridge_io_shared_arbiter_io_output_w_payload_last : io_output_w_rData_last_1);
  always @(*) begin
    io_output_w_s2mPipe_ready = io_output_w_s2mPipe_m2sPipe_ready;
    if(when_Stream_l477_1) begin
      io_output_w_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l477_1 = (! io_output_w_s2mPipe_m2sPipe_valid);
  assign io_output_w_s2mPipe_m2sPipe_valid = io_output_w_s2mPipe_rValid;
  assign io_output_w_s2mPipe_m2sPipe_payload_data = io_output_w_s2mPipe_rData_data;
  assign io_output_w_s2mPipe_m2sPipe_payload_strb = io_output_w_s2mPipe_rData_strb;
  assign io_output_w_s2mPipe_m2sPipe_payload_last = io_output_w_s2mPipe_rData_last;
  assign io_output_w_s2mPipe_m2sPipe_ready = axi_ramBridge_io_shared_w_ready;
  assign _zz_io_sharedInputs_0_arw_payload_id_2[3 : 0] = 4'b0000;
  assign _zz_io_sharedInputs_0_arw_payload_region_1[3 : 0] = 4'b0000;
  assign _zz_io_sharedInputs_0_arw_payload_len_2[7 : 0] = 8'h0;
  assign io_output_arw_halfPipe_fire_2 = (io_output_arw_halfPipe_valid_2 && io_output_arw_halfPipe_ready_2);
  assign axi_extBridge_io_shared_arbiter_io_output_arw_ready = (! io_output_arw_rValid_2);
  assign io_output_arw_halfPipe_valid_2 = io_output_arw_rValid_2;
  assign io_output_arw_halfPipe_payload_addr_2 = io_output_arw_rData_addr_2;
  assign io_output_arw_halfPipe_payload_id_2 = io_output_arw_rData_id_2;
  assign io_output_arw_halfPipe_payload_region_1 = io_output_arw_rData_region_1;
  assign io_output_arw_halfPipe_payload_len_2 = io_output_arw_rData_len_2;
  assign io_output_arw_halfPipe_payload_size_2 = io_output_arw_rData_size_2;
  assign io_output_arw_halfPipe_payload_burst_2 = io_output_arw_rData_burst_2;
  assign io_output_arw_halfPipe_payload_lock_1 = io_output_arw_rData_lock_1;
  assign io_output_arw_halfPipe_payload_cache_1 = io_output_arw_rData_cache_1;
  assign io_output_arw_halfPipe_payload_qos_1 = io_output_arw_rData_qos_1;
  assign io_output_arw_halfPipe_payload_prot_1 = io_output_arw_rData_prot_1;
  assign io_output_arw_halfPipe_payload_write_2 = io_output_arw_rData_write_2;
  assign io_output_arw_halfPipe_ready_2 = axi_extBridge_io_shared_arw_ready;
  assign io_output_w_s2mPipe_valid_1 = (axi_extBridge_io_shared_arbiter_io_output_w_valid || (! io_output_w_rValidN_1));
  assign io_output_w_s2mPipe_payload_data_1 = (io_output_w_rValidN_1 ? axi_extBridge_io_shared_arbiter_io_output_w_payload_data : io_output_w_rData_data_2);
  assign io_output_w_s2mPipe_payload_strb_1 = (io_output_w_rValidN_1 ? axi_extBridge_io_shared_arbiter_io_output_w_payload_strb : io_output_w_rData_strb_2);
  assign io_output_w_s2mPipe_payload_last_1 = (io_output_w_rValidN_1 ? axi_extBridge_io_shared_arbiter_io_output_w_payload_last : io_output_w_rData_last_2);
  always @(*) begin
    io_output_w_s2mPipe_ready_1 = io_output_w_s2mPipe_m2sPipe_ready_1;
    if(when_Stream_l477_2) begin
      io_output_w_s2mPipe_ready_1 = 1'b1;
    end
  end

  assign when_Stream_l477_2 = (! io_output_w_s2mPipe_m2sPipe_valid_1);
  assign io_output_w_s2mPipe_m2sPipe_valid_1 = io_output_w_s2mPipe_rValid_1;
  assign io_output_w_s2mPipe_m2sPipe_payload_data_1 = io_output_w_s2mPipe_rData_data_1;
  assign io_output_w_s2mPipe_m2sPipe_payload_strb_1 = io_output_w_s2mPipe_rData_strb_1;
  assign io_output_w_s2mPipe_m2sPipe_payload_last_1 = io_output_w_s2mPipe_rData_last_1;
  assign io_output_w_s2mPipe_m2sPipe_ready_1 = axi_extBridge_io_shared_w_ready;
  assign _zz_io_sharedInputs_0_arw_payload_id_3[3 : 0] = 4'b0000;
  assign _zz_io_sharedInputs_0_arw_payload_region_2[3 : 0] = 4'b0000;
  assign _zz_io_sharedInputs_0_arw_payload_len_3[7 : 0] = 8'h0;
  assign io_output_arw_halfPipe_fire_3 = (io_output_arw_halfPipe_valid_3 && io_output_arw_halfPipe_ready_3);
  assign axi_liteBridge_io_shared_arbiter_io_output_arw_ready = (! io_output_arw_rValid_3);
  assign io_output_arw_halfPipe_valid_3 = io_output_arw_rValid_3;
  assign io_output_arw_halfPipe_payload_addr_3 = io_output_arw_rData_addr_3;
  assign io_output_arw_halfPipe_payload_id_3 = io_output_arw_rData_id_3;
  assign io_output_arw_halfPipe_payload_region_2 = io_output_arw_rData_region_2;
  assign io_output_arw_halfPipe_payload_len_3 = io_output_arw_rData_len_3;
  assign io_output_arw_halfPipe_payload_size_3 = io_output_arw_rData_size_3;
  assign io_output_arw_halfPipe_payload_burst_3 = io_output_arw_rData_burst_3;
  assign io_output_arw_halfPipe_payload_lock_2 = io_output_arw_rData_lock_2;
  assign io_output_arw_halfPipe_payload_cache_2 = io_output_arw_rData_cache_2;
  assign io_output_arw_halfPipe_payload_qos_2 = io_output_arw_rData_qos_2;
  assign io_output_arw_halfPipe_payload_prot_2 = io_output_arw_rData_prot_2;
  assign io_output_arw_halfPipe_payload_write_3 = io_output_arw_rData_write_3;
  assign io_output_arw_halfPipe_ready_3 = axi_liteBridge_io_shared_arw_ready;
  assign io_output_w_s2mPipe_valid_2 = (axi_liteBridge_io_shared_arbiter_io_output_w_valid || (! io_output_w_rValidN_2));
  assign io_output_w_s2mPipe_payload_data_2 = (io_output_w_rValidN_2 ? axi_liteBridge_io_shared_arbiter_io_output_w_payload_data : io_output_w_rData_data_3);
  assign io_output_w_s2mPipe_payload_strb_2 = (io_output_w_rValidN_2 ? axi_liteBridge_io_shared_arbiter_io_output_w_payload_strb : io_output_w_rData_strb_3);
  assign io_output_w_s2mPipe_payload_last_2 = (io_output_w_rValidN_2 ? axi_liteBridge_io_shared_arbiter_io_output_w_payload_last : io_output_w_rData_last_3);
  always @(*) begin
    io_output_w_s2mPipe_ready_2 = io_output_w_s2mPipe_m2sPipe_ready_2;
    if(when_Stream_l477_3) begin
      io_output_w_s2mPipe_ready_2 = 1'b1;
    end
  end

  assign when_Stream_l477_3 = (! io_output_w_s2mPipe_m2sPipe_valid_2);
  assign io_output_w_s2mPipe_m2sPipe_valid_2 = io_output_w_s2mPipe_rValid_2;
  assign io_output_w_s2mPipe_m2sPipe_payload_data_2 = io_output_w_s2mPipe_rData_data_2;
  assign io_output_w_s2mPipe_m2sPipe_payload_strb_2 = io_output_w_s2mPipe_rData_strb_2;
  assign io_output_w_s2mPipe_m2sPipe_payload_last_2 = io_output_w_s2mPipe_rData_last_2;
  assign io_output_w_s2mPipe_m2sPipe_ready_2 = axi_liteBridge_io_shared_w_ready;
  assign axi_uartCtrl_io_apb_PADDR = apb3Router_io_outputs_0_PADDR[4:0];
  assign io_uart_txd = axi_uartCtrl_io_uart_txd;
  always @(posedge io_axiClk) begin
    if(when_RiscvCpu_l172) begin
      resetCtrl_systemResetCounter <= (resetCtrl_systemResetCounter + 6'h01);
    end
    if(when_RiscvCpu_l176) begin
      resetCtrl_systemResetCounter <= 6'h0;
    end
  end

  always @(posedge io_axiClk) begin
    resetCtrl_systemReset <= resetCtrl_systemResetUnbuffered;
    resetCtrl_axiReset <= resetCtrl_systemResetUnbuffered;
  end

  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      _zz_dBus_cmd_haltWhen_valid <= 3'b000;
      dBus_cmd_haltWhen_fork2_logic_linkEnable_0 <= 1'b1;
      dBus_cmd_haltWhen_fork2_logic_linkEnable_1 <= 1'b1;
      io_outputs_0_ar_rValid <= 1'b0;
      io_sharedOutputs_0_arw_rValid <= 1'b0;
      io_sharedOutputs_1_arw_rValid <= 1'b0;
      io_sharedOutputs_2_arw_rValid <= 1'b0;
      io_sharedOutputs_3_arw_rValid <= 1'b0;
      io_input_r_rValid <= 1'b0;
      io_output_arw_rValid <= 1'b0;
      io_output_w_rValid <= 1'b0;
      io_output_arw_rValid_1 <= 1'b0;
      io_output_w_rValidN <= 1'b1;
      io_output_w_s2mPipe_rValid <= 1'b0;
      io_output_arw_rValid_2 <= 1'b0;
      io_output_w_rValidN_1 <= 1'b1;
      io_output_w_s2mPipe_rValid_1 <= 1'b0;
      io_output_arw_rValid_3 <= 1'b0;
      io_output_w_rValidN_2 <= 1'b1;
      io_output_w_s2mPipe_rValid_2 <= 1'b0;
    end else begin
      _zz_dBus_cmd_haltWhen_valid <= (_zz_dBus_cmd_haltWhen_valid + _zz_dBus_cmd_haltWhen_valid_1);
      if(dBus_cmd_haltWhen_fork2_outputs_0_fire) begin
        dBus_cmd_haltWhen_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(dBus_cmd_haltWhen_fork2_outputs_1_fire) begin
        dBus_cmd_haltWhen_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(dBus_cmd_haltWhen_ready) begin
        dBus_cmd_haltWhen_fork2_logic_linkEnable_0 <= 1'b1;
        dBus_cmd_haltWhen_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(axi4ReadOnlyDecoder_io_outputs_0_ar_valid) begin
        io_outputs_0_ar_rValid <= 1'b1;
      end
      if(io_outputs_0_ar_validPipe_fire) begin
        io_outputs_0_ar_rValid <= 1'b0;
      end
      if(axi4SharedDecoder_io_sharedOutputs_0_arw_valid) begin
        io_sharedOutputs_0_arw_rValid <= 1'b1;
      end
      if(io_sharedOutputs_0_arw_validPipe_fire) begin
        io_sharedOutputs_0_arw_rValid <= 1'b0;
      end
      if(axi4SharedDecoder_io_sharedOutputs_1_arw_valid) begin
        io_sharedOutputs_1_arw_rValid <= 1'b1;
      end
      if(io_sharedOutputs_1_arw_validPipe_fire) begin
        io_sharedOutputs_1_arw_rValid <= 1'b0;
      end
      if(axi4SharedDecoder_io_sharedOutputs_2_arw_valid) begin
        io_sharedOutputs_2_arw_rValid <= 1'b1;
      end
      if(io_sharedOutputs_2_arw_validPipe_fire) begin
        io_sharedOutputs_2_arw_rValid <= 1'b0;
      end
      if(axi4SharedDecoder_io_sharedOutputs_3_arw_valid) begin
        io_sharedOutputs_3_arw_rValid <= 1'b1;
      end
      if(io_sharedOutputs_3_arw_validPipe_fire) begin
        io_sharedOutputs_3_arw_rValid <= 1'b0;
      end
      if(axi4SharedDecoder_io_input_r_ready) begin
        io_input_r_rValid <= axi4SharedDecoder_io_input_r_valid;
      end
      if(axi_apbBridge_io_axi_arbiter_io_output_arw_valid) begin
        io_output_arw_rValid <= 1'b1;
      end
      if(io_output_arw_halfPipe_fire) begin
        io_output_arw_rValid <= 1'b0;
      end
      if(axi_apbBridge_io_axi_arbiter_io_output_w_valid) begin
        io_output_w_rValid <= 1'b1;
      end
      if(io_output_w_halfPipe_fire) begin
        io_output_w_rValid <= 1'b0;
      end
      if(axi_ramBridge_io_shared_arbiter_io_output_arw_valid) begin
        io_output_arw_rValid_1 <= 1'b1;
      end
      if(io_output_arw_halfPipe_fire_1) begin
        io_output_arw_rValid_1 <= 1'b0;
      end
      if(axi_ramBridge_io_shared_arbiter_io_output_w_valid) begin
        io_output_w_rValidN <= 1'b0;
      end
      if(io_output_w_s2mPipe_ready) begin
        io_output_w_rValidN <= 1'b1;
      end
      if(io_output_w_s2mPipe_ready) begin
        io_output_w_s2mPipe_rValid <= io_output_w_s2mPipe_valid;
      end
      if(axi_extBridge_io_shared_arbiter_io_output_arw_valid) begin
        io_output_arw_rValid_2 <= 1'b1;
      end
      if(io_output_arw_halfPipe_fire_2) begin
        io_output_arw_rValid_2 <= 1'b0;
      end
      if(axi_extBridge_io_shared_arbiter_io_output_w_valid) begin
        io_output_w_rValidN_1 <= 1'b0;
      end
      if(io_output_w_s2mPipe_ready_1) begin
        io_output_w_rValidN_1 <= 1'b1;
      end
      if(io_output_w_s2mPipe_ready_1) begin
        io_output_w_s2mPipe_rValid_1 <= io_output_w_s2mPipe_valid_1;
      end
      if(axi_liteBridge_io_shared_arbiter_io_output_arw_valid) begin
        io_output_arw_rValid_3 <= 1'b1;
      end
      if(io_output_arw_halfPipe_fire_3) begin
        io_output_arw_rValid_3 <= 1'b0;
      end
      if(axi_liteBridge_io_shared_arbiter_io_output_w_valid) begin
        io_output_w_rValidN_2 <= 1'b0;
      end
      if(io_output_w_s2mPipe_ready_2) begin
        io_output_w_rValidN_2 <= 1'b1;
      end
      if(io_output_w_s2mPipe_ready_2) begin
        io_output_w_s2mPipe_rValid_2 <= io_output_w_s2mPipe_valid_2;
      end
    end
  end

  always @(posedge io_axiClk) begin
    if(axi4SharedDecoder_io_input_r_ready) begin
      io_input_r_rData_data <= axi4SharedDecoder_io_input_r_payload_data;
      io_input_r_rData_resp <= axi4SharedDecoder_io_input_r_payload_resp;
      io_input_r_rData_last <= axi4SharedDecoder_io_input_r_payload_last;
    end
    if(axi_apbBridge_io_axi_arbiter_io_output_arw_ready) begin
      io_output_arw_rData_addr <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_addr;
      io_output_arw_rData_id <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_id;
      io_output_arw_rData_len <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_len;
      io_output_arw_rData_size <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_size;
      io_output_arw_rData_burst <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_burst;
      io_output_arw_rData_write <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_write;
    end
    if(axi_apbBridge_io_axi_arbiter_io_output_w_ready) begin
      io_output_w_rData_data <= axi_apbBridge_io_axi_arbiter_io_output_w_payload_data;
      io_output_w_rData_strb <= axi_apbBridge_io_axi_arbiter_io_output_w_payload_strb;
      io_output_w_rData_last <= axi_apbBridge_io_axi_arbiter_io_output_w_payload_last;
    end
    if(axi_ramBridge_io_shared_arbiter_io_output_arw_ready) begin
      io_output_arw_rData_addr_1 <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_addr;
      io_output_arw_rData_id_1 <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_id;
      io_output_arw_rData_region <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_region;
      io_output_arw_rData_len_1 <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_len;
      io_output_arw_rData_size_1 <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_size;
      io_output_arw_rData_burst_1 <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_burst;
      io_output_arw_rData_lock <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_lock;
      io_output_arw_rData_cache <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_cache;
      io_output_arw_rData_qos <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_qos;
      io_output_arw_rData_prot <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_prot;
      io_output_arw_rData_write_1 <= axi_ramBridge_io_shared_arbiter_io_output_arw_payload_write;
    end
    if(io_output_w_rValidN) begin
      io_output_w_rData_data_1 <= axi_ramBridge_io_shared_arbiter_io_output_w_payload_data;
      io_output_w_rData_strb_1 <= axi_ramBridge_io_shared_arbiter_io_output_w_payload_strb;
      io_output_w_rData_last_1 <= axi_ramBridge_io_shared_arbiter_io_output_w_payload_last;
    end
    if(io_output_w_s2mPipe_ready) begin
      io_output_w_s2mPipe_rData_data <= io_output_w_s2mPipe_payload_data;
      io_output_w_s2mPipe_rData_strb <= io_output_w_s2mPipe_payload_strb;
      io_output_w_s2mPipe_rData_last <= io_output_w_s2mPipe_payload_last;
    end
    if(axi_extBridge_io_shared_arbiter_io_output_arw_ready) begin
      io_output_arw_rData_addr_2 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_addr;
      io_output_arw_rData_id_2 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_id;
      io_output_arw_rData_region_1 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_region;
      io_output_arw_rData_len_2 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_len;
      io_output_arw_rData_size_2 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_size;
      io_output_arw_rData_burst_2 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_burst;
      io_output_arw_rData_lock_1 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_lock;
      io_output_arw_rData_cache_1 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_cache;
      io_output_arw_rData_qos_1 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_qos;
      io_output_arw_rData_prot_1 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_prot;
      io_output_arw_rData_write_2 <= axi_extBridge_io_shared_arbiter_io_output_arw_payload_write;
    end
    if(io_output_w_rValidN_1) begin
      io_output_w_rData_data_2 <= axi_extBridge_io_shared_arbiter_io_output_w_payload_data;
      io_output_w_rData_strb_2 <= axi_extBridge_io_shared_arbiter_io_output_w_payload_strb;
      io_output_w_rData_last_2 <= axi_extBridge_io_shared_arbiter_io_output_w_payload_last;
    end
    if(io_output_w_s2mPipe_ready_1) begin
      io_output_w_s2mPipe_rData_data_1 <= io_output_w_s2mPipe_payload_data_1;
      io_output_w_s2mPipe_rData_strb_1 <= io_output_w_s2mPipe_payload_strb_1;
      io_output_w_s2mPipe_rData_last_1 <= io_output_w_s2mPipe_payload_last_1;
    end
    if(axi_liteBridge_io_shared_arbiter_io_output_arw_ready) begin
      io_output_arw_rData_addr_3 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_addr;
      io_output_arw_rData_id_3 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_id;
      io_output_arw_rData_region_2 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_region;
      io_output_arw_rData_len_3 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_len;
      io_output_arw_rData_size_3 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_size;
      io_output_arw_rData_burst_3 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_burst;
      io_output_arw_rData_lock_2 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_lock;
      io_output_arw_rData_cache_2 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_cache;
      io_output_arw_rData_qos_2 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_qos;
      io_output_arw_rData_prot_2 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_prot;
      io_output_arw_rData_write_3 <= axi_liteBridge_io_shared_arbiter_io_output_arw_payload_write;
    end
    if(io_output_w_rValidN_2) begin
      io_output_w_rData_data_3 <= axi_liteBridge_io_shared_arbiter_io_output_w_payload_data;
      io_output_w_rData_strb_3 <= axi_liteBridge_io_shared_arbiter_io_output_w_payload_strb;
      io_output_w_rData_last_3 <= axi_liteBridge_io_shared_arbiter_io_output_w_payload_last;
    end
    if(io_output_w_s2mPipe_ready_2) begin
      io_output_w_s2mPipe_rData_data_2 <= io_output_w_s2mPipe_payload_data_2;
      io_output_w_s2mPipe_rData_strb_2 <= io_output_w_s2mPipe_payload_strb_2;
      io_output_w_s2mPipe_rData_last_2 <= io_output_w_s2mPipe_payload_last_2;
    end
  end


endmodule

module vexApb3Router (
  input  wire [19:0]   io_input_PADDR,
  input  wire [0:0]    io_input_PSEL,
  input  wire          io_input_PENABLE,
  output wire          io_input_PREADY,
  input  wire          io_input_PWRITE,
  input  wire [31:0]   io_input_PWDATA,
  output wire [31:0]   io_input_PRDATA,
  output wire          io_input_PSLVERROR,
  output wire [19:0]   io_outputs_0_PADDR,
  output wire [0:0]    io_outputs_0_PSEL,
  output wire          io_outputs_0_PENABLE,
  input  wire          io_outputs_0_PREADY,
  output wire          io_outputs_0_PWRITE,
  output wire [31:0]   io_outputs_0_PWDATA,
  input  wire [31:0]   io_outputs_0_PRDATA,
  input  wire          io_outputs_0_PSLVERROR,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);


  assign io_outputs_0_PADDR = io_input_PADDR;
  assign io_outputs_0_PENABLE = io_input_PENABLE;
  assign io_outputs_0_PSEL[0] = io_input_PSEL[0];
  assign io_outputs_0_PWRITE = io_input_PWRITE;
  assign io_outputs_0_PWDATA = io_input_PWDATA;
  assign io_input_PREADY = io_outputs_0_PREADY;
  assign io_input_PRDATA = io_outputs_0_PRDATA;
  assign io_input_PSLVERROR = io_outputs_0_PSLVERROR;

endmodule

module vexApb3Decoder (
  input  wire [19:0]   io_input_PADDR,
  input  wire [0:0]    io_input_PSEL,
  input  wire          io_input_PENABLE,
  output reg           io_input_PREADY,
  input  wire          io_input_PWRITE,
  input  wire [31:0]   io_input_PWDATA,
  output wire [31:0]   io_input_PRDATA,
  output reg           io_input_PSLVERROR,
  output wire [19:0]   io_output_PADDR,
  output wire [0:0]    io_output_PSEL,
  output wire          io_output_PENABLE,
  input  wire          io_output_PREADY,
  output wire          io_output_PWRITE,
  output wire [31:0]   io_output_PWDATA,
  input  wire [31:0]   io_output_PRDATA,
  input  wire          io_output_PSLVERROR
);

  wire                when_Apb3Decoder_l88;

  assign io_output_PADDR = io_input_PADDR;
  assign io_output_PENABLE = io_input_PENABLE;
  assign io_output_PWRITE = io_input_PWRITE;
  assign io_output_PWDATA = io_input_PWDATA;
  assign io_output_PSEL[0] = (((io_input_PADDR & (~ 20'h00fff)) == 20'h0) && io_input_PSEL[0]);
  always @(*) begin
    io_input_PREADY = io_output_PREADY;
    if(when_Apb3Decoder_l88) begin
      io_input_PREADY = 1'b1;
    end
  end

  assign io_input_PRDATA = io_output_PRDATA;
  always @(*) begin
    io_input_PSLVERROR = io_output_PSLVERROR;
    if(when_Apb3Decoder_l88) begin
      io_input_PSLVERROR = 1'b1;
    end
  end

  assign when_Apb3Decoder_l88 = (io_input_PSEL[0] && (io_output_PSEL == 1'b0));

endmodule

//vexAxi4SharedArbiter_3 replaced by vexAxi4SharedArbiter_2

module vexAxi4SharedArbiter_2 (
  input  wire          io_sharedInputs_0_arw_valid,
  output wire          io_sharedInputs_0_arw_ready,
  input  wire [31:0]   io_sharedInputs_0_arw_payload_addr,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_id,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_region,
  input  wire [7:0]    io_sharedInputs_0_arw_payload_len,
  input  wire [2:0]    io_sharedInputs_0_arw_payload_size,
  input  wire [1:0]    io_sharedInputs_0_arw_payload_burst,
  input  wire [0:0]    io_sharedInputs_0_arw_payload_lock,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_cache,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_qos,
  input  wire [2:0]    io_sharedInputs_0_arw_payload_prot,
  input  wire          io_sharedInputs_0_arw_payload_write,
  input  wire          io_sharedInputs_0_w_valid,
  output wire          io_sharedInputs_0_w_ready,
  input  wire [31:0]   io_sharedInputs_0_w_payload_data,
  input  wire [3:0]    io_sharedInputs_0_w_payload_strb,
  input  wire          io_sharedInputs_0_w_payload_last,
  output wire          io_sharedInputs_0_b_valid,
  input  wire          io_sharedInputs_0_b_ready,
  output wire [3:0]    io_sharedInputs_0_b_payload_id,
  output wire [1:0]    io_sharedInputs_0_b_payload_resp,
  output wire          io_sharedInputs_0_r_valid,
  input  wire          io_sharedInputs_0_r_ready,
  output wire [31:0]   io_sharedInputs_0_r_payload_data,
  output wire [3:0]    io_sharedInputs_0_r_payload_id,
  output wire [1:0]    io_sharedInputs_0_r_payload_resp,
  output wire          io_sharedInputs_0_r_payload_last,
  output wire          io_output_arw_valid,
  input  wire          io_output_arw_ready,
  output wire [31:0]   io_output_arw_payload_addr,
  output wire [3:0]    io_output_arw_payload_id,
  output wire [3:0]    io_output_arw_payload_region,
  output wire [7:0]    io_output_arw_payload_len,
  output wire [2:0]    io_output_arw_payload_size,
  output wire [1:0]    io_output_arw_payload_burst,
  output wire [0:0]    io_output_arw_payload_lock,
  output wire [3:0]    io_output_arw_payload_cache,
  output wire [3:0]    io_output_arw_payload_qos,
  output wire [2:0]    io_output_arw_payload_prot,
  output wire          io_output_arw_payload_write,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [31:0]   io_output_w_payload_data,
  output wire [3:0]    io_output_w_payload_strb,
  output wire          io_output_w_payload_last,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [3:0]    io_output_b_payload_id,
  input  wire [1:0]    io_output_b_payload_resp,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [31:0]   io_output_r_payload_data,
  input  wire [3:0]    io_output_r_payload_id,
  input  wire [1:0]    io_output_r_payload_resp,
  input  wire          io_output_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 cmdArbiter_io_output_ready;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_pop_ready;
  wire                cmdArbiter_io_inputs_0_ready;
  wire                cmdArbiter_io_output_valid;
  wire       [31:0]   cmdArbiter_io_output_payload_addr;
  wire       [3:0]    cmdArbiter_io_output_payload_id;
  wire       [3:0]    cmdArbiter_io_output_payload_region;
  wire       [7:0]    cmdArbiter_io_output_payload_len;
  wire       [2:0]    cmdArbiter_io_output_payload_size;
  wire       [1:0]    cmdArbiter_io_output_payload_burst;
  wire       [0:0]    cmdArbiter_io_output_payload_lock;
  wire       [3:0]    cmdArbiter_io_output_payload_cache;
  wire       [3:0]    cmdArbiter_io_output_payload_qos;
  wire       [2:0]    cmdArbiter_io_output_payload_prot;
  wire                cmdArbiter_io_output_payload_write;
  wire       [0:0]    cmdArbiter_io_chosenOH;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_push_ready;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_pop_valid;
  wire       [2:0]    cmdRouteFork_throwWhen_translated_fifo_io_occupancy;
  wire       [2:0]    cmdRouteFork_throwWhen_translated_fifo_io_availability;
  wire                inputsCmd_0_valid;
  wire                inputsCmd_0_ready;
  wire       [31:0]   inputsCmd_0_payload_addr;
  wire       [3:0]    inputsCmd_0_payload_id;
  wire       [3:0]    inputsCmd_0_payload_region;
  wire       [7:0]    inputsCmd_0_payload_len;
  wire       [2:0]    inputsCmd_0_payload_size;
  wire       [1:0]    inputsCmd_0_payload_burst;
  wire       [0:0]    inputsCmd_0_payload_lock;
  wire       [3:0]    inputsCmd_0_payload_cache;
  wire       [3:0]    inputsCmd_0_payload_qos;
  wire       [2:0]    inputsCmd_0_payload_prot;
  wire                inputsCmd_0_payload_write;
  wire                cmdOutputFork_valid;
  wire                cmdOutputFork_ready;
  wire       [31:0]   cmdOutputFork_payload_addr;
  wire       [3:0]    cmdOutputFork_payload_id;
  wire       [3:0]    cmdOutputFork_payload_region;
  wire       [7:0]    cmdOutputFork_payload_len;
  wire       [2:0]    cmdOutputFork_payload_size;
  wire       [1:0]    cmdOutputFork_payload_burst;
  wire       [0:0]    cmdOutputFork_payload_lock;
  wire       [3:0]    cmdOutputFork_payload_cache;
  wire       [3:0]    cmdOutputFork_payload_qos;
  wire       [2:0]    cmdOutputFork_payload_prot;
  wire                cmdOutputFork_payload_write;
  wire                cmdRouteFork_valid;
  reg                 cmdRouteFork_ready;
  wire       [31:0]   cmdRouteFork_payload_addr;
  wire       [3:0]    cmdRouteFork_payload_id;
  wire       [3:0]    cmdRouteFork_payload_region;
  wire       [7:0]    cmdRouteFork_payload_len;
  wire       [2:0]    cmdRouteFork_payload_size;
  wire       [1:0]    cmdRouteFork_payload_burst;
  wire       [0:0]    cmdRouteFork_payload_lock;
  wire       [3:0]    cmdRouteFork_payload_cache;
  wire       [3:0]    cmdRouteFork_payload_qos;
  wire       [2:0]    cmdRouteFork_payload_prot;
  wire                cmdRouteFork_payload_write;
  reg                 cmdArbiter_io_output_fork2_logic_linkEnable_0;
  reg                 cmdArbiter_io_output_fork2_logic_linkEnable_1;
  wire                when_Stream_l1253;
  wire                when_Stream_l1253_1;
  wire                cmdOutputFork_fire;
  wire                cmdRouteFork_fire;
  wire                when_Stream_l581;
  reg                 cmdRouteFork_throwWhen_valid;
  wire                cmdRouteFork_throwWhen_ready;
  wire       [31:0]   cmdRouteFork_throwWhen_payload_addr;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_id;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_region;
  wire       [7:0]    cmdRouteFork_throwWhen_payload_len;
  wire       [2:0]    cmdRouteFork_throwWhen_payload_size;
  wire       [1:0]    cmdRouteFork_throwWhen_payload_burst;
  wire       [0:0]    cmdRouteFork_throwWhen_payload_lock;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_cache;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_qos;
  wire       [2:0]    cmdRouteFork_throwWhen_payload_prot;
  wire                cmdRouteFork_throwWhen_payload_write;
  wire                cmdRouteFork_throwWhen_translated_valid;
  wire                cmdRouteFork_throwWhen_translated_ready;
  wire                writeLogic_routeDataInput_valid;
  wire                writeLogic_routeDataInput_ready;
  wire       [31:0]   writeLogic_routeDataInput_payload_data;
  wire       [3:0]    writeLogic_routeDataInput_payload_strb;
  wire                writeLogic_routeDataInput_payload_last;
  wire                io_output_w_fire;
  wire                writeLogic_writeRspSels_0;
  wire                readRspSels_0;

  vexStreamArbiter_2 cmdArbiter (
    .io_inputs_0_valid          (inputsCmd_0_valid                       ), //i
    .io_inputs_0_ready          (cmdArbiter_io_inputs_0_ready            ), //o
    .io_inputs_0_payload_addr   (inputsCmd_0_payload_addr[31:0]          ), //i
    .io_inputs_0_payload_id     (inputsCmd_0_payload_id[3:0]             ), //i
    .io_inputs_0_payload_region (inputsCmd_0_payload_region[3:0]         ), //i
    .io_inputs_0_payload_len    (inputsCmd_0_payload_len[7:0]            ), //i
    .io_inputs_0_payload_size   (inputsCmd_0_payload_size[2:0]           ), //i
    .io_inputs_0_payload_burst  (inputsCmd_0_payload_burst[1:0]          ), //i
    .io_inputs_0_payload_lock   (inputsCmd_0_payload_lock                ), //i
    .io_inputs_0_payload_cache  (inputsCmd_0_payload_cache[3:0]          ), //i
    .io_inputs_0_payload_qos    (inputsCmd_0_payload_qos[3:0]            ), //i
    .io_inputs_0_payload_prot   (inputsCmd_0_payload_prot[2:0]           ), //i
    .io_inputs_0_payload_write  (inputsCmd_0_payload_write               ), //i
    .io_output_valid            (cmdArbiter_io_output_valid              ), //o
    .io_output_ready            (cmdArbiter_io_output_ready              ), //i
    .io_output_payload_addr     (cmdArbiter_io_output_payload_addr[31:0] ), //o
    .io_output_payload_id       (cmdArbiter_io_output_payload_id[3:0]    ), //o
    .io_output_payload_region   (cmdArbiter_io_output_payload_region[3:0]), //o
    .io_output_payload_len      (cmdArbiter_io_output_payload_len[7:0]   ), //o
    .io_output_payload_size     (cmdArbiter_io_output_payload_size[2:0]  ), //o
    .io_output_payload_burst    (cmdArbiter_io_output_payload_burst[1:0] ), //o
    .io_output_payload_lock     (cmdArbiter_io_output_payload_lock       ), //o
    .io_output_payload_cache    (cmdArbiter_io_output_payload_cache[3:0] ), //o
    .io_output_payload_qos      (cmdArbiter_io_output_payload_qos[3:0]   ), //o
    .io_output_payload_prot     (cmdArbiter_io_output_payload_prot[2:0]  ), //o
    .io_output_payload_write    (cmdArbiter_io_output_payload_write      ), //o
    .io_chosenOH                (cmdArbiter_io_chosenOH                  ), //o
    .io_axiClk                  (io_axiClk                               ), //i
    .resetCtrl_axiReset         (resetCtrl_axiReset                      )  //i
  );
  vexStreamFifoLowLatency_1 cmdRouteFork_throwWhen_translated_fifo (
    .io_push_valid      (cmdRouteFork_throwWhen_translated_valid                    ), //i
    .io_push_ready      (cmdRouteFork_throwWhen_translated_fifo_io_push_ready       ), //o
    .io_pop_valid       (cmdRouteFork_throwWhen_translated_fifo_io_pop_valid        ), //o
    .io_pop_ready       (cmdRouteFork_throwWhen_translated_fifo_io_pop_ready        ), //i
    .io_flush           (1'b0                                                       ), //i
    .io_occupancy       (cmdRouteFork_throwWhen_translated_fifo_io_occupancy[2:0]   ), //o
    .io_availability    (cmdRouteFork_throwWhen_translated_fifo_io_availability[2:0]), //o
    .io_axiClk          (io_axiClk                                                  ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                                         )  //i
  );
  assign inputsCmd_0_valid = io_sharedInputs_0_arw_valid;
  assign io_sharedInputs_0_arw_ready = inputsCmd_0_ready;
  assign inputsCmd_0_payload_addr = io_sharedInputs_0_arw_payload_addr;
  assign inputsCmd_0_payload_id = io_sharedInputs_0_arw_payload_id;
  assign inputsCmd_0_payload_region = io_sharedInputs_0_arw_payload_region;
  assign inputsCmd_0_payload_len = io_sharedInputs_0_arw_payload_len;
  assign inputsCmd_0_payload_size = io_sharedInputs_0_arw_payload_size;
  assign inputsCmd_0_payload_burst = io_sharedInputs_0_arw_payload_burst;
  assign inputsCmd_0_payload_lock = io_sharedInputs_0_arw_payload_lock;
  assign inputsCmd_0_payload_cache = io_sharedInputs_0_arw_payload_cache;
  assign inputsCmd_0_payload_qos = io_sharedInputs_0_arw_payload_qos;
  assign inputsCmd_0_payload_prot = io_sharedInputs_0_arw_payload_prot;
  assign inputsCmd_0_payload_write = io_sharedInputs_0_arw_payload_write;
  assign inputsCmd_0_ready = cmdArbiter_io_inputs_0_ready;
  always @(*) begin
    cmdArbiter_io_output_ready = 1'b1;
    if(when_Stream_l1253) begin
      cmdArbiter_io_output_ready = 1'b0;
    end
    if(when_Stream_l1253_1) begin
      cmdArbiter_io_output_ready = 1'b0;
    end
  end

  assign when_Stream_l1253 = ((! cmdOutputFork_ready) && cmdArbiter_io_output_fork2_logic_linkEnable_0);
  assign when_Stream_l1253_1 = ((! cmdRouteFork_ready) && cmdArbiter_io_output_fork2_logic_linkEnable_1);
  assign cmdOutputFork_valid = (cmdArbiter_io_output_valid && cmdArbiter_io_output_fork2_logic_linkEnable_0);
  assign cmdOutputFork_payload_addr = cmdArbiter_io_output_payload_addr;
  assign cmdOutputFork_payload_id = cmdArbiter_io_output_payload_id;
  assign cmdOutputFork_payload_region = cmdArbiter_io_output_payload_region;
  assign cmdOutputFork_payload_len = cmdArbiter_io_output_payload_len;
  assign cmdOutputFork_payload_size = cmdArbiter_io_output_payload_size;
  assign cmdOutputFork_payload_burst = cmdArbiter_io_output_payload_burst;
  assign cmdOutputFork_payload_lock = cmdArbiter_io_output_payload_lock;
  assign cmdOutputFork_payload_cache = cmdArbiter_io_output_payload_cache;
  assign cmdOutputFork_payload_qos = cmdArbiter_io_output_payload_qos;
  assign cmdOutputFork_payload_prot = cmdArbiter_io_output_payload_prot;
  assign cmdOutputFork_payload_write = cmdArbiter_io_output_payload_write;
  assign cmdOutputFork_fire = (cmdOutputFork_valid && cmdOutputFork_ready);
  assign cmdRouteFork_valid = (cmdArbiter_io_output_valid && cmdArbiter_io_output_fork2_logic_linkEnable_1);
  assign cmdRouteFork_payload_addr = cmdArbiter_io_output_payload_addr;
  assign cmdRouteFork_payload_id = cmdArbiter_io_output_payload_id;
  assign cmdRouteFork_payload_region = cmdArbiter_io_output_payload_region;
  assign cmdRouteFork_payload_len = cmdArbiter_io_output_payload_len;
  assign cmdRouteFork_payload_size = cmdArbiter_io_output_payload_size;
  assign cmdRouteFork_payload_burst = cmdArbiter_io_output_payload_burst;
  assign cmdRouteFork_payload_lock = cmdArbiter_io_output_payload_lock;
  assign cmdRouteFork_payload_cache = cmdArbiter_io_output_payload_cache;
  assign cmdRouteFork_payload_qos = cmdArbiter_io_output_payload_qos;
  assign cmdRouteFork_payload_prot = cmdArbiter_io_output_payload_prot;
  assign cmdRouteFork_payload_write = cmdArbiter_io_output_payload_write;
  assign cmdRouteFork_fire = (cmdRouteFork_valid && cmdRouteFork_ready);
  assign io_output_arw_valid = cmdOutputFork_valid;
  assign cmdOutputFork_ready = io_output_arw_ready;
  assign io_output_arw_payload_addr = cmdOutputFork_payload_addr;
  assign io_output_arw_payload_region = cmdOutputFork_payload_region;
  assign io_output_arw_payload_len = cmdOutputFork_payload_len;
  assign io_output_arw_payload_size = cmdOutputFork_payload_size;
  assign io_output_arw_payload_burst = cmdOutputFork_payload_burst;
  assign io_output_arw_payload_lock = cmdOutputFork_payload_lock;
  assign io_output_arw_payload_cache = cmdOutputFork_payload_cache;
  assign io_output_arw_payload_qos = cmdOutputFork_payload_qos;
  assign io_output_arw_payload_prot = cmdOutputFork_payload_prot;
  assign io_output_arw_payload_write = cmdOutputFork_payload_write;
  assign io_output_arw_payload_id = (cmdOutputFork_payload_write ? cmdOutputFork_payload_id : cmdOutputFork_payload_id);
  assign when_Stream_l581 = (! cmdRouteFork_payload_write);
  always @(*) begin
    cmdRouteFork_throwWhen_valid = cmdRouteFork_valid;
    if(when_Stream_l581) begin
      cmdRouteFork_throwWhen_valid = 1'b0;
    end
  end

  always @(*) begin
    cmdRouteFork_ready = cmdRouteFork_throwWhen_ready;
    if(when_Stream_l581) begin
      cmdRouteFork_ready = 1'b1;
    end
  end

  assign cmdRouteFork_throwWhen_payload_addr = cmdRouteFork_payload_addr;
  assign cmdRouteFork_throwWhen_payload_id = cmdRouteFork_payload_id;
  assign cmdRouteFork_throwWhen_payload_region = cmdRouteFork_payload_region;
  assign cmdRouteFork_throwWhen_payload_len = cmdRouteFork_payload_len;
  assign cmdRouteFork_throwWhen_payload_size = cmdRouteFork_payload_size;
  assign cmdRouteFork_throwWhen_payload_burst = cmdRouteFork_payload_burst;
  assign cmdRouteFork_throwWhen_payload_lock = cmdRouteFork_payload_lock;
  assign cmdRouteFork_throwWhen_payload_cache = cmdRouteFork_payload_cache;
  assign cmdRouteFork_throwWhen_payload_qos = cmdRouteFork_payload_qos;
  assign cmdRouteFork_throwWhen_payload_prot = cmdRouteFork_payload_prot;
  assign cmdRouteFork_throwWhen_payload_write = cmdRouteFork_payload_write;
  assign cmdRouteFork_throwWhen_translated_valid = cmdRouteFork_throwWhen_valid;
  assign cmdRouteFork_throwWhen_ready = cmdRouteFork_throwWhen_translated_ready;
  assign cmdRouteFork_throwWhen_translated_ready = cmdRouteFork_throwWhen_translated_fifo_io_push_ready;
  assign writeLogic_routeDataInput_valid = io_sharedInputs_0_w_valid;
  assign writeLogic_routeDataInput_ready = io_sharedInputs_0_w_ready;
  assign writeLogic_routeDataInput_payload_data = io_sharedInputs_0_w_payload_data;
  assign writeLogic_routeDataInput_payload_strb = io_sharedInputs_0_w_payload_strb;
  assign writeLogic_routeDataInput_payload_last = io_sharedInputs_0_w_payload_last;
  assign io_output_w_valid = (cmdRouteFork_throwWhen_translated_fifo_io_pop_valid && writeLogic_routeDataInput_valid);
  assign io_output_w_payload_data = writeLogic_routeDataInput_payload_data;
  assign io_output_w_payload_strb = writeLogic_routeDataInput_payload_strb;
  assign io_output_w_payload_last = writeLogic_routeDataInput_payload_last;
  assign io_sharedInputs_0_w_ready = ((cmdRouteFork_throwWhen_translated_fifo_io_pop_valid && io_output_w_ready) && 1'b1);
  assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
  assign cmdRouteFork_throwWhen_translated_fifo_io_pop_ready = (io_output_w_fire && io_output_w_payload_last);
  assign writeLogic_writeRspSels_0 = 1'b1;
  assign io_sharedInputs_0_b_valid = (io_output_b_valid && writeLogic_writeRspSels_0);
  assign io_sharedInputs_0_b_payload_resp = io_output_b_payload_resp;
  assign io_sharedInputs_0_b_payload_id = io_output_b_payload_id;
  assign io_output_b_ready = io_sharedInputs_0_b_ready;
  assign readRspSels_0 = 1'b1;
  assign io_sharedInputs_0_r_valid = (io_output_r_valid && readRspSels_0);
  assign io_sharedInputs_0_r_payload_data = io_output_r_payload_data;
  assign io_sharedInputs_0_r_payload_resp = io_output_r_payload_resp;
  assign io_sharedInputs_0_r_payload_last = io_output_r_payload_last;
  assign io_sharedInputs_0_r_payload_id = io_output_r_payload_id;
  assign io_output_r_ready = io_sharedInputs_0_r_ready;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
      cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
    end else begin
      if(cmdOutputFork_fire) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdRouteFork_fire) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(cmdArbiter_io_output_ready) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
        cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
      end
    end
  end


endmodule

module vexAxi4SharedArbiter_1 (
  input  wire          io_readInputs_0_ar_valid,
  output wire          io_readInputs_0_ar_ready,
  input  wire [31:0]   io_readInputs_0_ar_payload_addr,
  input  wire [2:0]    io_readInputs_0_ar_payload_id,
  input  wire [3:0]    io_readInputs_0_ar_payload_region,
  input  wire [7:0]    io_readInputs_0_ar_payload_len,
  input  wire [2:0]    io_readInputs_0_ar_payload_size,
  input  wire [1:0]    io_readInputs_0_ar_payload_burst,
  input  wire [0:0]    io_readInputs_0_ar_payload_lock,
  input  wire [3:0]    io_readInputs_0_ar_payload_cache,
  input  wire [3:0]    io_readInputs_0_ar_payload_qos,
  input  wire [2:0]    io_readInputs_0_ar_payload_prot,
  output wire          io_readInputs_0_r_valid,
  input  wire          io_readInputs_0_r_ready,
  output wire [31:0]   io_readInputs_0_r_payload_data,
  output wire [2:0]    io_readInputs_0_r_payload_id,
  output wire [1:0]    io_readInputs_0_r_payload_resp,
  output wire          io_readInputs_0_r_payload_last,
  input  wire          io_sharedInputs_0_arw_valid,
  output wire          io_sharedInputs_0_arw_ready,
  input  wire [31:0]   io_sharedInputs_0_arw_payload_addr,
  input  wire [2:0]    io_sharedInputs_0_arw_payload_id,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_region,
  input  wire [7:0]    io_sharedInputs_0_arw_payload_len,
  input  wire [2:0]    io_sharedInputs_0_arw_payload_size,
  input  wire [1:0]    io_sharedInputs_0_arw_payload_burst,
  input  wire [0:0]    io_sharedInputs_0_arw_payload_lock,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_cache,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_qos,
  input  wire [2:0]    io_sharedInputs_0_arw_payload_prot,
  input  wire          io_sharedInputs_0_arw_payload_write,
  input  wire          io_sharedInputs_0_w_valid,
  output wire          io_sharedInputs_0_w_ready,
  input  wire [31:0]   io_sharedInputs_0_w_payload_data,
  input  wire [3:0]    io_sharedInputs_0_w_payload_strb,
  input  wire          io_sharedInputs_0_w_payload_last,
  output wire          io_sharedInputs_0_b_valid,
  input  wire          io_sharedInputs_0_b_ready,
  output wire [2:0]    io_sharedInputs_0_b_payload_id,
  output wire [1:0]    io_sharedInputs_0_b_payload_resp,
  output wire          io_sharedInputs_0_r_valid,
  input  wire          io_sharedInputs_0_r_ready,
  output wire [31:0]   io_sharedInputs_0_r_payload_data,
  output wire [2:0]    io_sharedInputs_0_r_payload_id,
  output wire [1:0]    io_sharedInputs_0_r_payload_resp,
  output wire          io_sharedInputs_0_r_payload_last,
  output wire          io_output_arw_valid,
  input  wire          io_output_arw_ready,
  output wire [31:0]   io_output_arw_payload_addr,
  output wire [3:0]    io_output_arw_payload_id,
  output wire [3:0]    io_output_arw_payload_region,
  output wire [7:0]    io_output_arw_payload_len,
  output wire [2:0]    io_output_arw_payload_size,
  output wire [1:0]    io_output_arw_payload_burst,
  output wire [0:0]    io_output_arw_payload_lock,
  output wire [3:0]    io_output_arw_payload_cache,
  output wire [3:0]    io_output_arw_payload_qos,
  output wire [2:0]    io_output_arw_payload_prot,
  output wire          io_output_arw_payload_write,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [31:0]   io_output_w_payload_data,
  output wire [3:0]    io_output_w_payload_strb,
  output wire          io_output_w_payload_last,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [3:0]    io_output_b_payload_id,
  input  wire [1:0]    io_output_b_payload_resp,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [31:0]   io_output_r_payload_data,
  input  wire [3:0]    io_output_r_payload_id,
  input  wire [1:0]    io_output_r_payload_resp,
  input  wire          io_output_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 cmdArbiter_io_output_ready;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_pop_ready;
  wire                cmdArbiter_io_inputs_0_ready;
  wire                cmdArbiter_io_inputs_1_ready;
  wire                cmdArbiter_io_output_valid;
  wire       [31:0]   cmdArbiter_io_output_payload_addr;
  wire       [2:0]    cmdArbiter_io_output_payload_id;
  wire       [3:0]    cmdArbiter_io_output_payload_region;
  wire       [7:0]    cmdArbiter_io_output_payload_len;
  wire       [2:0]    cmdArbiter_io_output_payload_size;
  wire       [1:0]    cmdArbiter_io_output_payload_burst;
  wire       [0:0]    cmdArbiter_io_output_payload_lock;
  wire       [3:0]    cmdArbiter_io_output_payload_cache;
  wire       [3:0]    cmdArbiter_io_output_payload_qos;
  wire       [2:0]    cmdArbiter_io_output_payload_prot;
  wire                cmdArbiter_io_output_payload_write;
  wire       [0:0]    cmdArbiter_io_chosen;
  wire       [1:0]    cmdArbiter_io_chosenOH;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_push_ready;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_pop_valid;
  wire       [2:0]    cmdRouteFork_throwWhen_translated_fifo_io_occupancy;
  wire       [2:0]    cmdRouteFork_throwWhen_translated_fifo_io_availability;
  wire       [1:0]    _zz__zz_io_output_arw_payload_id;
  wire       [3:0]    _zz_io_output_arw_payload_id_1;
  wire       [2:0]    _zz_io_output_arw_payload_id_2;
  reg                 _zz_io_output_r_ready;
  wire                inputsCmd_0_valid;
  wire                inputsCmd_0_ready;
  wire       [31:0]   inputsCmd_0_payload_addr;
  wire       [2:0]    inputsCmd_0_payload_id;
  wire       [3:0]    inputsCmd_0_payload_region;
  wire       [7:0]    inputsCmd_0_payload_len;
  wire       [2:0]    inputsCmd_0_payload_size;
  wire       [1:0]    inputsCmd_0_payload_burst;
  wire       [0:0]    inputsCmd_0_payload_lock;
  wire       [3:0]    inputsCmd_0_payload_cache;
  wire       [3:0]    inputsCmd_0_payload_qos;
  wire       [2:0]    inputsCmd_0_payload_prot;
  wire                inputsCmd_0_payload_write;
  wire                inputsCmd_1_valid;
  wire                inputsCmd_1_ready;
  wire       [31:0]   inputsCmd_1_payload_addr;
  wire       [2:0]    inputsCmd_1_payload_id;
  wire       [3:0]    inputsCmd_1_payload_region;
  wire       [7:0]    inputsCmd_1_payload_len;
  wire       [2:0]    inputsCmd_1_payload_size;
  wire       [1:0]    inputsCmd_1_payload_burst;
  wire       [0:0]    inputsCmd_1_payload_lock;
  wire       [3:0]    inputsCmd_1_payload_cache;
  wire       [3:0]    inputsCmd_1_payload_qos;
  wire       [2:0]    inputsCmd_1_payload_prot;
  wire                inputsCmd_1_payload_write;
  wire                cmdOutputFork_valid;
  wire                cmdOutputFork_ready;
  wire       [31:0]   cmdOutputFork_payload_addr;
  wire       [2:0]    cmdOutputFork_payload_id;
  wire       [3:0]    cmdOutputFork_payload_region;
  wire       [7:0]    cmdOutputFork_payload_len;
  wire       [2:0]    cmdOutputFork_payload_size;
  wire       [1:0]    cmdOutputFork_payload_burst;
  wire       [0:0]    cmdOutputFork_payload_lock;
  wire       [3:0]    cmdOutputFork_payload_cache;
  wire       [3:0]    cmdOutputFork_payload_qos;
  wire       [2:0]    cmdOutputFork_payload_prot;
  wire                cmdOutputFork_payload_write;
  wire                cmdRouteFork_valid;
  reg                 cmdRouteFork_ready;
  wire       [31:0]   cmdRouteFork_payload_addr;
  wire       [2:0]    cmdRouteFork_payload_id;
  wire       [3:0]    cmdRouteFork_payload_region;
  wire       [7:0]    cmdRouteFork_payload_len;
  wire       [2:0]    cmdRouteFork_payload_size;
  wire       [1:0]    cmdRouteFork_payload_burst;
  wire       [0:0]    cmdRouteFork_payload_lock;
  wire       [3:0]    cmdRouteFork_payload_cache;
  wire       [3:0]    cmdRouteFork_payload_qos;
  wire       [2:0]    cmdRouteFork_payload_prot;
  wire                cmdRouteFork_payload_write;
  reg                 cmdArbiter_io_output_fork2_logic_linkEnable_0;
  reg                 cmdArbiter_io_output_fork2_logic_linkEnable_1;
  wire                when_Stream_l1253;
  wire                when_Stream_l1253_1;
  wire                cmdOutputFork_fire;
  wire                cmdRouteFork_fire;
  wire                _zz_io_output_arw_payload_id;
  wire                when_Stream_l581;
  reg                 cmdRouteFork_throwWhen_valid;
  wire                cmdRouteFork_throwWhen_ready;
  wire       [31:0]   cmdRouteFork_throwWhen_payload_addr;
  wire       [2:0]    cmdRouteFork_throwWhen_payload_id;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_region;
  wire       [7:0]    cmdRouteFork_throwWhen_payload_len;
  wire       [2:0]    cmdRouteFork_throwWhen_payload_size;
  wire       [1:0]    cmdRouteFork_throwWhen_payload_burst;
  wire       [0:0]    cmdRouteFork_throwWhen_payload_lock;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_cache;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_qos;
  wire       [2:0]    cmdRouteFork_throwWhen_payload_prot;
  wire                cmdRouteFork_throwWhen_payload_write;
  wire                cmdRouteFork_throwWhen_translated_valid;
  wire                cmdRouteFork_throwWhen_translated_ready;
  wire                writeLogic_routeDataInput_valid;
  wire                writeLogic_routeDataInput_ready;
  wire       [31:0]   writeLogic_routeDataInput_payload_data;
  wire       [3:0]    writeLogic_routeDataInput_payload_strb;
  wire                writeLogic_routeDataInput_payload_last;
  wire                io_output_w_fire;
  wire                writeLogic_writeRspSels_0;
  wire       [0:0]    readRspIndex;
  wire                readRspSels_0;
  wire                readRspSels_1;

  assign _zz__zz_io_output_arw_payload_id = {cmdArbiter_io_chosenOH[1 : 1],cmdArbiter_io_chosenOH[0 : 0]};
  assign _zz_io_output_arw_payload_id_2 = cmdOutputFork_payload_id;
  assign _zz_io_output_arw_payload_id_1 = {1'd0, _zz_io_output_arw_payload_id_2};
  vexStreamArbiter_1 cmdArbiter (
    .io_inputs_0_valid          (inputsCmd_0_valid                       ), //i
    .io_inputs_0_ready          (cmdArbiter_io_inputs_0_ready            ), //o
    .io_inputs_0_payload_addr   (inputsCmd_0_payload_addr[31:0]          ), //i
    .io_inputs_0_payload_id     (inputsCmd_0_payload_id[2:0]             ), //i
    .io_inputs_0_payload_region (inputsCmd_0_payload_region[3:0]         ), //i
    .io_inputs_0_payload_len    (inputsCmd_0_payload_len[7:0]            ), //i
    .io_inputs_0_payload_size   (inputsCmd_0_payload_size[2:0]           ), //i
    .io_inputs_0_payload_burst  (inputsCmd_0_payload_burst[1:0]          ), //i
    .io_inputs_0_payload_lock   (inputsCmd_0_payload_lock                ), //i
    .io_inputs_0_payload_cache  (inputsCmd_0_payload_cache[3:0]          ), //i
    .io_inputs_0_payload_qos    (inputsCmd_0_payload_qos[3:0]            ), //i
    .io_inputs_0_payload_prot   (inputsCmd_0_payload_prot[2:0]           ), //i
    .io_inputs_0_payload_write  (inputsCmd_0_payload_write               ), //i
    .io_inputs_1_valid          (inputsCmd_1_valid                       ), //i
    .io_inputs_1_ready          (cmdArbiter_io_inputs_1_ready            ), //o
    .io_inputs_1_payload_addr   (inputsCmd_1_payload_addr[31:0]          ), //i
    .io_inputs_1_payload_id     (inputsCmd_1_payload_id[2:0]             ), //i
    .io_inputs_1_payload_region (inputsCmd_1_payload_region[3:0]         ), //i
    .io_inputs_1_payload_len    (inputsCmd_1_payload_len[7:0]            ), //i
    .io_inputs_1_payload_size   (inputsCmd_1_payload_size[2:0]           ), //i
    .io_inputs_1_payload_burst  (inputsCmd_1_payload_burst[1:0]          ), //i
    .io_inputs_1_payload_lock   (inputsCmd_1_payload_lock                ), //i
    .io_inputs_1_payload_cache  (inputsCmd_1_payload_cache[3:0]          ), //i
    .io_inputs_1_payload_qos    (inputsCmd_1_payload_qos[3:0]            ), //i
    .io_inputs_1_payload_prot   (inputsCmd_1_payload_prot[2:0]           ), //i
    .io_inputs_1_payload_write  (inputsCmd_1_payload_write               ), //i
    .io_output_valid            (cmdArbiter_io_output_valid              ), //o
    .io_output_ready            (cmdArbiter_io_output_ready              ), //i
    .io_output_payload_addr     (cmdArbiter_io_output_payload_addr[31:0] ), //o
    .io_output_payload_id       (cmdArbiter_io_output_payload_id[2:0]    ), //o
    .io_output_payload_region   (cmdArbiter_io_output_payload_region[3:0]), //o
    .io_output_payload_len      (cmdArbiter_io_output_payload_len[7:0]   ), //o
    .io_output_payload_size     (cmdArbiter_io_output_payload_size[2:0]  ), //o
    .io_output_payload_burst    (cmdArbiter_io_output_payload_burst[1:0] ), //o
    .io_output_payload_lock     (cmdArbiter_io_output_payload_lock       ), //o
    .io_output_payload_cache    (cmdArbiter_io_output_payload_cache[3:0] ), //o
    .io_output_payload_qos      (cmdArbiter_io_output_payload_qos[3:0]   ), //o
    .io_output_payload_prot     (cmdArbiter_io_output_payload_prot[2:0]  ), //o
    .io_output_payload_write    (cmdArbiter_io_output_payload_write      ), //o
    .io_chosen                  (cmdArbiter_io_chosen                    ), //o
    .io_chosenOH                (cmdArbiter_io_chosenOH[1:0]             ), //o
    .io_axiClk                  (io_axiClk                               ), //i
    .resetCtrl_axiReset         (resetCtrl_axiReset                      )  //i
  );
  vexStreamFifoLowLatency_1 cmdRouteFork_throwWhen_translated_fifo (
    .io_push_valid      (cmdRouteFork_throwWhen_translated_valid                    ), //i
    .io_push_ready      (cmdRouteFork_throwWhen_translated_fifo_io_push_ready       ), //o
    .io_pop_valid       (cmdRouteFork_throwWhen_translated_fifo_io_pop_valid        ), //o
    .io_pop_ready       (cmdRouteFork_throwWhen_translated_fifo_io_pop_ready        ), //i
    .io_flush           (1'b0                                                       ), //i
    .io_occupancy       (cmdRouteFork_throwWhen_translated_fifo_io_occupancy[2:0]   ), //o
    .io_availability    (cmdRouteFork_throwWhen_translated_fifo_io_availability[2:0]), //o
    .io_axiClk          (io_axiClk                                                  ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                                         )  //i
  );
  always @(*) begin
    case(readRspIndex)
      1'b0 : _zz_io_output_r_ready = io_readInputs_0_r_ready;
      default : _zz_io_output_r_ready = io_sharedInputs_0_r_ready;
    endcase
  end

  assign inputsCmd_0_valid = io_readInputs_0_ar_valid;
  assign io_readInputs_0_ar_ready = inputsCmd_0_ready;
  assign inputsCmd_0_payload_addr = io_readInputs_0_ar_payload_addr;
  assign inputsCmd_0_payload_id = io_readInputs_0_ar_payload_id;
  assign inputsCmd_0_payload_region = io_readInputs_0_ar_payload_region;
  assign inputsCmd_0_payload_len = io_readInputs_0_ar_payload_len;
  assign inputsCmd_0_payload_size = io_readInputs_0_ar_payload_size;
  assign inputsCmd_0_payload_burst = io_readInputs_0_ar_payload_burst;
  assign inputsCmd_0_payload_lock = io_readInputs_0_ar_payload_lock;
  assign inputsCmd_0_payload_cache = io_readInputs_0_ar_payload_cache;
  assign inputsCmd_0_payload_qos = io_readInputs_0_ar_payload_qos;
  assign inputsCmd_0_payload_prot = io_readInputs_0_ar_payload_prot;
  assign inputsCmd_0_payload_write = 1'b0;
  assign inputsCmd_1_valid = io_sharedInputs_0_arw_valid;
  assign io_sharedInputs_0_arw_ready = inputsCmd_1_ready;
  assign inputsCmd_1_payload_addr = io_sharedInputs_0_arw_payload_addr;
  assign inputsCmd_1_payload_id = io_sharedInputs_0_arw_payload_id;
  assign inputsCmd_1_payload_region = io_sharedInputs_0_arw_payload_region;
  assign inputsCmd_1_payload_len = io_sharedInputs_0_arw_payload_len;
  assign inputsCmd_1_payload_size = io_sharedInputs_0_arw_payload_size;
  assign inputsCmd_1_payload_burst = io_sharedInputs_0_arw_payload_burst;
  assign inputsCmd_1_payload_lock = io_sharedInputs_0_arw_payload_lock;
  assign inputsCmd_1_payload_cache = io_sharedInputs_0_arw_payload_cache;
  assign inputsCmd_1_payload_qos = io_sharedInputs_0_arw_payload_qos;
  assign inputsCmd_1_payload_prot = io_sharedInputs_0_arw_payload_prot;
  assign inputsCmd_1_payload_write = io_sharedInputs_0_arw_payload_write;
  assign inputsCmd_0_ready = cmdArbiter_io_inputs_0_ready;
  assign inputsCmd_1_ready = cmdArbiter_io_inputs_1_ready;
  always @(*) begin
    cmdArbiter_io_output_ready = 1'b1;
    if(when_Stream_l1253) begin
      cmdArbiter_io_output_ready = 1'b0;
    end
    if(when_Stream_l1253_1) begin
      cmdArbiter_io_output_ready = 1'b0;
    end
  end

  assign when_Stream_l1253 = ((! cmdOutputFork_ready) && cmdArbiter_io_output_fork2_logic_linkEnable_0);
  assign when_Stream_l1253_1 = ((! cmdRouteFork_ready) && cmdArbiter_io_output_fork2_logic_linkEnable_1);
  assign cmdOutputFork_valid = (cmdArbiter_io_output_valid && cmdArbiter_io_output_fork2_logic_linkEnable_0);
  assign cmdOutputFork_payload_addr = cmdArbiter_io_output_payload_addr;
  assign cmdOutputFork_payload_id = cmdArbiter_io_output_payload_id;
  assign cmdOutputFork_payload_region = cmdArbiter_io_output_payload_region;
  assign cmdOutputFork_payload_len = cmdArbiter_io_output_payload_len;
  assign cmdOutputFork_payload_size = cmdArbiter_io_output_payload_size;
  assign cmdOutputFork_payload_burst = cmdArbiter_io_output_payload_burst;
  assign cmdOutputFork_payload_lock = cmdArbiter_io_output_payload_lock;
  assign cmdOutputFork_payload_cache = cmdArbiter_io_output_payload_cache;
  assign cmdOutputFork_payload_qos = cmdArbiter_io_output_payload_qos;
  assign cmdOutputFork_payload_prot = cmdArbiter_io_output_payload_prot;
  assign cmdOutputFork_payload_write = cmdArbiter_io_output_payload_write;
  assign cmdOutputFork_fire = (cmdOutputFork_valid && cmdOutputFork_ready);
  assign cmdRouteFork_valid = (cmdArbiter_io_output_valid && cmdArbiter_io_output_fork2_logic_linkEnable_1);
  assign cmdRouteFork_payload_addr = cmdArbiter_io_output_payload_addr;
  assign cmdRouteFork_payload_id = cmdArbiter_io_output_payload_id;
  assign cmdRouteFork_payload_region = cmdArbiter_io_output_payload_region;
  assign cmdRouteFork_payload_len = cmdArbiter_io_output_payload_len;
  assign cmdRouteFork_payload_size = cmdArbiter_io_output_payload_size;
  assign cmdRouteFork_payload_burst = cmdArbiter_io_output_payload_burst;
  assign cmdRouteFork_payload_lock = cmdArbiter_io_output_payload_lock;
  assign cmdRouteFork_payload_cache = cmdArbiter_io_output_payload_cache;
  assign cmdRouteFork_payload_qos = cmdArbiter_io_output_payload_qos;
  assign cmdRouteFork_payload_prot = cmdArbiter_io_output_payload_prot;
  assign cmdRouteFork_payload_write = cmdArbiter_io_output_payload_write;
  assign cmdRouteFork_fire = (cmdRouteFork_valid && cmdRouteFork_ready);
  assign io_output_arw_valid = cmdOutputFork_valid;
  assign cmdOutputFork_ready = io_output_arw_ready;
  assign io_output_arw_payload_addr = cmdOutputFork_payload_addr;
  assign io_output_arw_payload_region = cmdOutputFork_payload_region;
  assign io_output_arw_payload_len = cmdOutputFork_payload_len;
  assign io_output_arw_payload_size = cmdOutputFork_payload_size;
  assign io_output_arw_payload_burst = cmdOutputFork_payload_burst;
  assign io_output_arw_payload_lock = cmdOutputFork_payload_lock;
  assign io_output_arw_payload_cache = cmdOutputFork_payload_cache;
  assign io_output_arw_payload_qos = cmdOutputFork_payload_qos;
  assign io_output_arw_payload_prot = cmdOutputFork_payload_prot;
  assign io_output_arw_payload_write = cmdOutputFork_payload_write;
  assign _zz_io_output_arw_payload_id = _zz__zz_io_output_arw_payload_id[1];
  assign io_output_arw_payload_id = (cmdOutputFork_payload_write ? _zz_io_output_arw_payload_id_1 : {_zz_io_output_arw_payload_id,cmdOutputFork_payload_id});
  assign when_Stream_l581 = (! cmdRouteFork_payload_write);
  always @(*) begin
    cmdRouteFork_throwWhen_valid = cmdRouteFork_valid;
    if(when_Stream_l581) begin
      cmdRouteFork_throwWhen_valid = 1'b0;
    end
  end

  always @(*) begin
    cmdRouteFork_ready = cmdRouteFork_throwWhen_ready;
    if(when_Stream_l581) begin
      cmdRouteFork_ready = 1'b1;
    end
  end

  assign cmdRouteFork_throwWhen_payload_addr = cmdRouteFork_payload_addr;
  assign cmdRouteFork_throwWhen_payload_id = cmdRouteFork_payload_id;
  assign cmdRouteFork_throwWhen_payload_region = cmdRouteFork_payload_region;
  assign cmdRouteFork_throwWhen_payload_len = cmdRouteFork_payload_len;
  assign cmdRouteFork_throwWhen_payload_size = cmdRouteFork_payload_size;
  assign cmdRouteFork_throwWhen_payload_burst = cmdRouteFork_payload_burst;
  assign cmdRouteFork_throwWhen_payload_lock = cmdRouteFork_payload_lock;
  assign cmdRouteFork_throwWhen_payload_cache = cmdRouteFork_payload_cache;
  assign cmdRouteFork_throwWhen_payload_qos = cmdRouteFork_payload_qos;
  assign cmdRouteFork_throwWhen_payload_prot = cmdRouteFork_payload_prot;
  assign cmdRouteFork_throwWhen_payload_write = cmdRouteFork_payload_write;
  assign cmdRouteFork_throwWhen_translated_valid = cmdRouteFork_throwWhen_valid;
  assign cmdRouteFork_throwWhen_ready = cmdRouteFork_throwWhen_translated_ready;
  assign cmdRouteFork_throwWhen_translated_ready = cmdRouteFork_throwWhen_translated_fifo_io_push_ready;
  assign writeLogic_routeDataInput_valid = io_sharedInputs_0_w_valid;
  assign writeLogic_routeDataInput_ready = io_sharedInputs_0_w_ready;
  assign writeLogic_routeDataInput_payload_data = io_sharedInputs_0_w_payload_data;
  assign writeLogic_routeDataInput_payload_strb = io_sharedInputs_0_w_payload_strb;
  assign writeLogic_routeDataInput_payload_last = io_sharedInputs_0_w_payload_last;
  assign io_output_w_valid = (cmdRouteFork_throwWhen_translated_fifo_io_pop_valid && writeLogic_routeDataInput_valid);
  assign io_output_w_payload_data = writeLogic_routeDataInput_payload_data;
  assign io_output_w_payload_strb = writeLogic_routeDataInput_payload_strb;
  assign io_output_w_payload_last = writeLogic_routeDataInput_payload_last;
  assign io_sharedInputs_0_w_ready = ((cmdRouteFork_throwWhen_translated_fifo_io_pop_valid && io_output_w_ready) && 1'b1);
  assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
  assign cmdRouteFork_throwWhen_translated_fifo_io_pop_ready = (io_output_w_fire && io_output_w_payload_last);
  assign writeLogic_writeRspSels_0 = 1'b1;
  assign io_sharedInputs_0_b_valid = (io_output_b_valid && writeLogic_writeRspSels_0);
  assign io_sharedInputs_0_b_payload_resp = io_output_b_payload_resp;
  assign io_sharedInputs_0_b_payload_id = io_output_b_payload_id[2:0];
  assign io_output_b_ready = io_sharedInputs_0_b_ready;
  assign readRspIndex = io_output_r_payload_id[3 : 3];
  assign readRspSels_0 = (readRspIndex == 1'b0);
  assign readRspSels_1 = (readRspIndex == 1'b1);
  assign io_readInputs_0_r_valid = (io_output_r_valid && readRspSels_0);
  assign io_readInputs_0_r_payload_data = io_output_r_payload_data;
  assign io_readInputs_0_r_payload_resp = io_output_r_payload_resp;
  assign io_readInputs_0_r_payload_last = io_output_r_payload_last;
  assign io_readInputs_0_r_payload_id = io_output_r_payload_id[2:0];
  assign io_sharedInputs_0_r_valid = (io_output_r_valid && readRspSels_1);
  assign io_sharedInputs_0_r_payload_data = io_output_r_payload_data;
  assign io_sharedInputs_0_r_payload_resp = io_output_r_payload_resp;
  assign io_sharedInputs_0_r_payload_last = io_output_r_payload_last;
  assign io_sharedInputs_0_r_payload_id = io_output_r_payload_id[2:0];
  assign io_output_r_ready = _zz_io_output_r_ready;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
      cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
    end else begin
      if(cmdOutputFork_fire) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdRouteFork_fire) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(cmdArbiter_io_output_ready) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
        cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
      end
    end
  end


endmodule

module vexAxi4SharedArbiter (
  input  wire          io_sharedInputs_0_arw_valid,
  output wire          io_sharedInputs_0_arw_ready,
  input  wire [19:0]   io_sharedInputs_0_arw_payload_addr,
  input  wire [3:0]    io_sharedInputs_0_arw_payload_id,
  input  wire [7:0]    io_sharedInputs_0_arw_payload_len,
  input  wire [2:0]    io_sharedInputs_0_arw_payload_size,
  input  wire [1:0]    io_sharedInputs_0_arw_payload_burst,
  input  wire          io_sharedInputs_0_arw_payload_write,
  input  wire          io_sharedInputs_0_w_valid,
  output wire          io_sharedInputs_0_w_ready,
  input  wire [31:0]   io_sharedInputs_0_w_payload_data,
  input  wire [3:0]    io_sharedInputs_0_w_payload_strb,
  input  wire          io_sharedInputs_0_w_payload_last,
  output wire          io_sharedInputs_0_b_valid,
  input  wire          io_sharedInputs_0_b_ready,
  output wire [3:0]    io_sharedInputs_0_b_payload_id,
  output wire [1:0]    io_sharedInputs_0_b_payload_resp,
  output wire          io_sharedInputs_0_r_valid,
  input  wire          io_sharedInputs_0_r_ready,
  output wire [31:0]   io_sharedInputs_0_r_payload_data,
  output wire [3:0]    io_sharedInputs_0_r_payload_id,
  output wire [1:0]    io_sharedInputs_0_r_payload_resp,
  output wire          io_sharedInputs_0_r_payload_last,
  output wire          io_output_arw_valid,
  input  wire          io_output_arw_ready,
  output wire [19:0]   io_output_arw_payload_addr,
  output wire [3:0]    io_output_arw_payload_id,
  output wire [7:0]    io_output_arw_payload_len,
  output wire [2:0]    io_output_arw_payload_size,
  output wire [1:0]    io_output_arw_payload_burst,
  output wire          io_output_arw_payload_write,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [31:0]   io_output_w_payload_data,
  output wire [3:0]    io_output_w_payload_strb,
  output wire          io_output_w_payload_last,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [3:0]    io_output_b_payload_id,
  input  wire [1:0]    io_output_b_payload_resp,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [31:0]   io_output_r_payload_data,
  input  wire [3:0]    io_output_r_payload_id,
  input  wire [1:0]    io_output_r_payload_resp,
  input  wire          io_output_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 cmdArbiter_io_output_ready;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_pop_ready;
  wire                cmdArbiter_io_inputs_0_ready;
  wire                cmdArbiter_io_output_valid;
  wire       [19:0]   cmdArbiter_io_output_payload_addr;
  wire       [3:0]    cmdArbiter_io_output_payload_id;
  wire       [7:0]    cmdArbiter_io_output_payload_len;
  wire       [2:0]    cmdArbiter_io_output_payload_size;
  wire       [1:0]    cmdArbiter_io_output_payload_burst;
  wire                cmdArbiter_io_output_payload_write;
  wire       [0:0]    cmdArbiter_io_chosenOH;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_push_ready;
  wire                cmdRouteFork_throwWhen_translated_fifo_io_pop_valid;
  wire       [2:0]    cmdRouteFork_throwWhen_translated_fifo_io_occupancy;
  wire       [2:0]    cmdRouteFork_throwWhen_translated_fifo_io_availability;
  wire                inputsCmd_0_valid;
  wire                inputsCmd_0_ready;
  wire       [19:0]   inputsCmd_0_payload_addr;
  wire       [3:0]    inputsCmd_0_payload_id;
  wire       [7:0]    inputsCmd_0_payload_len;
  wire       [2:0]    inputsCmd_0_payload_size;
  wire       [1:0]    inputsCmd_0_payload_burst;
  wire                inputsCmd_0_payload_write;
  wire                cmdOutputFork_valid;
  wire                cmdOutputFork_ready;
  wire       [19:0]   cmdOutputFork_payload_addr;
  wire       [3:0]    cmdOutputFork_payload_id;
  wire       [7:0]    cmdOutputFork_payload_len;
  wire       [2:0]    cmdOutputFork_payload_size;
  wire       [1:0]    cmdOutputFork_payload_burst;
  wire                cmdOutputFork_payload_write;
  wire                cmdRouteFork_valid;
  reg                 cmdRouteFork_ready;
  wire       [19:0]   cmdRouteFork_payload_addr;
  wire       [3:0]    cmdRouteFork_payload_id;
  wire       [7:0]    cmdRouteFork_payload_len;
  wire       [2:0]    cmdRouteFork_payload_size;
  wire       [1:0]    cmdRouteFork_payload_burst;
  wire                cmdRouteFork_payload_write;
  reg                 cmdArbiter_io_output_fork2_logic_linkEnable_0;
  reg                 cmdArbiter_io_output_fork2_logic_linkEnable_1;
  wire                when_Stream_l1253;
  wire                when_Stream_l1253_1;
  wire                cmdOutputFork_fire;
  wire                cmdRouteFork_fire;
  wire                when_Stream_l581;
  reg                 cmdRouteFork_throwWhen_valid;
  wire                cmdRouteFork_throwWhen_ready;
  wire       [19:0]   cmdRouteFork_throwWhen_payload_addr;
  wire       [3:0]    cmdRouteFork_throwWhen_payload_id;
  wire       [7:0]    cmdRouteFork_throwWhen_payload_len;
  wire       [2:0]    cmdRouteFork_throwWhen_payload_size;
  wire       [1:0]    cmdRouteFork_throwWhen_payload_burst;
  wire                cmdRouteFork_throwWhen_payload_write;
  wire                cmdRouteFork_throwWhen_translated_valid;
  wire                cmdRouteFork_throwWhen_translated_ready;
  wire                writeLogic_routeDataInput_valid;
  wire                writeLogic_routeDataInput_ready;
  wire       [31:0]   writeLogic_routeDataInput_payload_data;
  wire       [3:0]    writeLogic_routeDataInput_payload_strb;
  wire                writeLogic_routeDataInput_payload_last;
  wire                io_output_w_fire;
  wire                writeLogic_writeRspSels_0;
  wire                readRspSels_0;

  vexStreamArbiter cmdArbiter (
    .io_inputs_0_valid         (inputsCmd_0_valid                      ), //i
    .io_inputs_0_ready         (cmdArbiter_io_inputs_0_ready           ), //o
    .io_inputs_0_payload_addr  (inputsCmd_0_payload_addr[19:0]         ), //i
    .io_inputs_0_payload_id    (inputsCmd_0_payload_id[3:0]            ), //i
    .io_inputs_0_payload_len   (inputsCmd_0_payload_len[7:0]           ), //i
    .io_inputs_0_payload_size  (inputsCmd_0_payload_size[2:0]          ), //i
    .io_inputs_0_payload_burst (inputsCmd_0_payload_burst[1:0]         ), //i
    .io_inputs_0_payload_write (inputsCmd_0_payload_write              ), //i
    .io_output_valid           (cmdArbiter_io_output_valid             ), //o
    .io_output_ready           (cmdArbiter_io_output_ready             ), //i
    .io_output_payload_addr    (cmdArbiter_io_output_payload_addr[19:0]), //o
    .io_output_payload_id      (cmdArbiter_io_output_payload_id[3:0]   ), //o
    .io_output_payload_len     (cmdArbiter_io_output_payload_len[7:0]  ), //o
    .io_output_payload_size    (cmdArbiter_io_output_payload_size[2:0] ), //o
    .io_output_payload_burst   (cmdArbiter_io_output_payload_burst[1:0]), //o
    .io_output_payload_write   (cmdArbiter_io_output_payload_write     ), //o
    .io_chosenOH               (cmdArbiter_io_chosenOH                 ), //o
    .io_axiClk                 (io_axiClk                              ), //i
    .resetCtrl_axiReset        (resetCtrl_axiReset                     )  //i
  );
  vexStreamFifoLowLatency_1 cmdRouteFork_throwWhen_translated_fifo (
    .io_push_valid      (cmdRouteFork_throwWhen_translated_valid                    ), //i
    .io_push_ready      (cmdRouteFork_throwWhen_translated_fifo_io_push_ready       ), //o
    .io_pop_valid       (cmdRouteFork_throwWhen_translated_fifo_io_pop_valid        ), //o
    .io_pop_ready       (cmdRouteFork_throwWhen_translated_fifo_io_pop_ready        ), //i
    .io_flush           (1'b0                                                       ), //i
    .io_occupancy       (cmdRouteFork_throwWhen_translated_fifo_io_occupancy[2:0]   ), //o
    .io_availability    (cmdRouteFork_throwWhen_translated_fifo_io_availability[2:0]), //o
    .io_axiClk          (io_axiClk                                                  ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                                         )  //i
  );
  assign inputsCmd_0_valid = io_sharedInputs_0_arw_valid;
  assign io_sharedInputs_0_arw_ready = inputsCmd_0_ready;
  assign inputsCmd_0_payload_addr = io_sharedInputs_0_arw_payload_addr;
  assign inputsCmd_0_payload_id = io_sharedInputs_0_arw_payload_id;
  assign inputsCmd_0_payload_len = io_sharedInputs_0_arw_payload_len;
  assign inputsCmd_0_payload_size = io_sharedInputs_0_arw_payload_size;
  assign inputsCmd_0_payload_burst = io_sharedInputs_0_arw_payload_burst;
  assign inputsCmd_0_payload_write = io_sharedInputs_0_arw_payload_write;
  assign inputsCmd_0_ready = cmdArbiter_io_inputs_0_ready;
  always @(*) begin
    cmdArbiter_io_output_ready = 1'b1;
    if(when_Stream_l1253) begin
      cmdArbiter_io_output_ready = 1'b0;
    end
    if(when_Stream_l1253_1) begin
      cmdArbiter_io_output_ready = 1'b0;
    end
  end

  assign when_Stream_l1253 = ((! cmdOutputFork_ready) && cmdArbiter_io_output_fork2_logic_linkEnable_0);
  assign when_Stream_l1253_1 = ((! cmdRouteFork_ready) && cmdArbiter_io_output_fork2_logic_linkEnable_1);
  assign cmdOutputFork_valid = (cmdArbiter_io_output_valid && cmdArbiter_io_output_fork2_logic_linkEnable_0);
  assign cmdOutputFork_payload_addr = cmdArbiter_io_output_payload_addr;
  assign cmdOutputFork_payload_id = cmdArbiter_io_output_payload_id;
  assign cmdOutputFork_payload_len = cmdArbiter_io_output_payload_len;
  assign cmdOutputFork_payload_size = cmdArbiter_io_output_payload_size;
  assign cmdOutputFork_payload_burst = cmdArbiter_io_output_payload_burst;
  assign cmdOutputFork_payload_write = cmdArbiter_io_output_payload_write;
  assign cmdOutputFork_fire = (cmdOutputFork_valid && cmdOutputFork_ready);
  assign cmdRouteFork_valid = (cmdArbiter_io_output_valid && cmdArbiter_io_output_fork2_logic_linkEnable_1);
  assign cmdRouteFork_payload_addr = cmdArbiter_io_output_payload_addr;
  assign cmdRouteFork_payload_id = cmdArbiter_io_output_payload_id;
  assign cmdRouteFork_payload_len = cmdArbiter_io_output_payload_len;
  assign cmdRouteFork_payload_size = cmdArbiter_io_output_payload_size;
  assign cmdRouteFork_payload_burst = cmdArbiter_io_output_payload_burst;
  assign cmdRouteFork_payload_write = cmdArbiter_io_output_payload_write;
  assign cmdRouteFork_fire = (cmdRouteFork_valid && cmdRouteFork_ready);
  assign io_output_arw_valid = cmdOutputFork_valid;
  assign cmdOutputFork_ready = io_output_arw_ready;
  assign io_output_arw_payload_addr = cmdOutputFork_payload_addr;
  assign io_output_arw_payload_len = cmdOutputFork_payload_len;
  assign io_output_arw_payload_size = cmdOutputFork_payload_size;
  assign io_output_arw_payload_burst = cmdOutputFork_payload_burst;
  assign io_output_arw_payload_write = cmdOutputFork_payload_write;
  assign io_output_arw_payload_id = (cmdOutputFork_payload_write ? cmdOutputFork_payload_id : cmdOutputFork_payload_id);
  assign when_Stream_l581 = (! cmdRouteFork_payload_write);
  always @(*) begin
    cmdRouteFork_throwWhen_valid = cmdRouteFork_valid;
    if(when_Stream_l581) begin
      cmdRouteFork_throwWhen_valid = 1'b0;
    end
  end

  always @(*) begin
    cmdRouteFork_ready = cmdRouteFork_throwWhen_ready;
    if(when_Stream_l581) begin
      cmdRouteFork_ready = 1'b1;
    end
  end

  assign cmdRouteFork_throwWhen_payload_addr = cmdRouteFork_payload_addr;
  assign cmdRouteFork_throwWhen_payload_id = cmdRouteFork_payload_id;
  assign cmdRouteFork_throwWhen_payload_len = cmdRouteFork_payload_len;
  assign cmdRouteFork_throwWhen_payload_size = cmdRouteFork_payload_size;
  assign cmdRouteFork_throwWhen_payload_burst = cmdRouteFork_payload_burst;
  assign cmdRouteFork_throwWhen_payload_write = cmdRouteFork_payload_write;
  assign cmdRouteFork_throwWhen_translated_valid = cmdRouteFork_throwWhen_valid;
  assign cmdRouteFork_throwWhen_ready = cmdRouteFork_throwWhen_translated_ready;
  assign cmdRouteFork_throwWhen_translated_ready = cmdRouteFork_throwWhen_translated_fifo_io_push_ready;
  assign writeLogic_routeDataInput_valid = io_sharedInputs_0_w_valid;
  assign writeLogic_routeDataInput_ready = io_sharedInputs_0_w_ready;
  assign writeLogic_routeDataInput_payload_data = io_sharedInputs_0_w_payload_data;
  assign writeLogic_routeDataInput_payload_strb = io_sharedInputs_0_w_payload_strb;
  assign writeLogic_routeDataInput_payload_last = io_sharedInputs_0_w_payload_last;
  assign io_output_w_valid = (cmdRouteFork_throwWhen_translated_fifo_io_pop_valid && writeLogic_routeDataInput_valid);
  assign io_output_w_payload_data = writeLogic_routeDataInput_payload_data;
  assign io_output_w_payload_strb = writeLogic_routeDataInput_payload_strb;
  assign io_output_w_payload_last = writeLogic_routeDataInput_payload_last;
  assign io_sharedInputs_0_w_ready = ((cmdRouteFork_throwWhen_translated_fifo_io_pop_valid && io_output_w_ready) && 1'b1);
  assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
  assign cmdRouteFork_throwWhen_translated_fifo_io_pop_ready = (io_output_w_fire && io_output_w_payload_last);
  assign writeLogic_writeRspSels_0 = 1'b1;
  assign io_sharedInputs_0_b_valid = (io_output_b_valid && writeLogic_writeRspSels_0);
  assign io_sharedInputs_0_b_payload_resp = io_output_b_payload_resp;
  assign io_sharedInputs_0_b_payload_id = io_output_b_payload_id;
  assign io_output_b_ready = io_sharedInputs_0_b_ready;
  assign readRspSels_0 = 1'b1;
  assign io_sharedInputs_0_r_valid = (io_output_r_valid && readRspSels_0);
  assign io_sharedInputs_0_r_payload_data = io_output_r_payload_data;
  assign io_sharedInputs_0_r_payload_resp = io_output_r_payload_resp;
  assign io_sharedInputs_0_r_payload_last = io_output_r_payload_last;
  assign io_sharedInputs_0_r_payload_id = io_output_r_payload_id;
  assign io_output_r_ready = io_sharedInputs_0_r_ready;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
      cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
    end else begin
      if(cmdOutputFork_fire) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdRouteFork_fire) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(cmdArbiter_io_output_ready) begin
        cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
        cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
      end
    end
  end


endmodule

module vexAxi4SharedDecoder (
  input  wire          io_input_arw_valid,
  output wire          io_input_arw_ready,
  input  wire [31:0]   io_input_arw_payload_addr,
  input  wire [2:0]    io_input_arw_payload_size,
  input  wire [3:0]    io_input_arw_payload_cache,
  input  wire [2:0]    io_input_arw_payload_prot,
  input  wire          io_input_arw_payload_write,
  input  wire          io_input_w_valid,
  output wire          io_input_w_ready,
  input  wire [31:0]   io_input_w_payload_data,
  input  wire [3:0]    io_input_w_payload_strb,
  input  wire          io_input_w_payload_last,
  output wire          io_input_b_valid,
  input  wire          io_input_b_ready,
  output reg  [1:0]    io_input_b_payload_resp,
  output wire          io_input_r_valid,
  input  wire          io_input_r_ready,
  output wire [31:0]   io_input_r_payload_data,
  output reg  [1:0]    io_input_r_payload_resp,
  output reg           io_input_r_payload_last,
  output wire          io_sharedOutputs_0_arw_valid,
  input  wire          io_sharedOutputs_0_arw_ready,
  output wire [31:0]   io_sharedOutputs_0_arw_payload_addr,
  output wire [2:0]    io_sharedOutputs_0_arw_payload_size,
  output wire [3:0]    io_sharedOutputs_0_arw_payload_cache,
  output wire [2:0]    io_sharedOutputs_0_arw_payload_prot,
  output wire          io_sharedOutputs_0_arw_payload_write,
  output wire          io_sharedOutputs_0_w_valid,
  input  wire          io_sharedOutputs_0_w_ready,
  output wire [31:0]   io_sharedOutputs_0_w_payload_data,
  output wire [3:0]    io_sharedOutputs_0_w_payload_strb,
  output wire          io_sharedOutputs_0_w_payload_last,
  input  wire          io_sharedOutputs_0_b_valid,
  output wire          io_sharedOutputs_0_b_ready,
  input  wire [1:0]    io_sharedOutputs_0_b_payload_resp,
  input  wire          io_sharedOutputs_0_r_valid,
  output wire          io_sharedOutputs_0_r_ready,
  input  wire [31:0]   io_sharedOutputs_0_r_payload_data,
  input  wire [1:0]    io_sharedOutputs_0_r_payload_resp,
  input  wire          io_sharedOutputs_0_r_payload_last,
  output wire          io_sharedOutputs_1_arw_valid,
  input  wire          io_sharedOutputs_1_arw_ready,
  output wire [31:0]   io_sharedOutputs_1_arw_payload_addr,
  output wire [2:0]    io_sharedOutputs_1_arw_payload_size,
  output wire [3:0]    io_sharedOutputs_1_arw_payload_cache,
  output wire [2:0]    io_sharedOutputs_1_arw_payload_prot,
  output wire          io_sharedOutputs_1_arw_payload_write,
  output wire          io_sharedOutputs_1_w_valid,
  input  wire          io_sharedOutputs_1_w_ready,
  output wire [31:0]   io_sharedOutputs_1_w_payload_data,
  output wire [3:0]    io_sharedOutputs_1_w_payload_strb,
  output wire          io_sharedOutputs_1_w_payload_last,
  input  wire          io_sharedOutputs_1_b_valid,
  output wire          io_sharedOutputs_1_b_ready,
  input  wire [1:0]    io_sharedOutputs_1_b_payload_resp,
  input  wire          io_sharedOutputs_1_r_valid,
  output wire          io_sharedOutputs_1_r_ready,
  input  wire [31:0]   io_sharedOutputs_1_r_payload_data,
  input  wire [1:0]    io_sharedOutputs_1_r_payload_resp,
  input  wire          io_sharedOutputs_1_r_payload_last,
  output wire          io_sharedOutputs_2_arw_valid,
  input  wire          io_sharedOutputs_2_arw_ready,
  output wire [31:0]   io_sharedOutputs_2_arw_payload_addr,
  output wire [2:0]    io_sharedOutputs_2_arw_payload_size,
  output wire [3:0]    io_sharedOutputs_2_arw_payload_cache,
  output wire [2:0]    io_sharedOutputs_2_arw_payload_prot,
  output wire          io_sharedOutputs_2_arw_payload_write,
  output wire          io_sharedOutputs_2_w_valid,
  input  wire          io_sharedOutputs_2_w_ready,
  output wire [31:0]   io_sharedOutputs_2_w_payload_data,
  output wire [3:0]    io_sharedOutputs_2_w_payload_strb,
  output wire          io_sharedOutputs_2_w_payload_last,
  input  wire          io_sharedOutputs_2_b_valid,
  output wire          io_sharedOutputs_2_b_ready,
  input  wire [1:0]    io_sharedOutputs_2_b_payload_resp,
  input  wire          io_sharedOutputs_2_r_valid,
  output wire          io_sharedOutputs_2_r_ready,
  input  wire [31:0]   io_sharedOutputs_2_r_payload_data,
  input  wire [1:0]    io_sharedOutputs_2_r_payload_resp,
  input  wire          io_sharedOutputs_2_r_payload_last,
  output wire          io_sharedOutputs_3_arw_valid,
  input  wire          io_sharedOutputs_3_arw_ready,
  output wire [31:0]   io_sharedOutputs_3_arw_payload_addr,
  output wire [2:0]    io_sharedOutputs_3_arw_payload_size,
  output wire [3:0]    io_sharedOutputs_3_arw_payload_cache,
  output wire [2:0]    io_sharedOutputs_3_arw_payload_prot,
  output wire          io_sharedOutputs_3_arw_payload_write,
  output wire          io_sharedOutputs_3_w_valid,
  input  wire          io_sharedOutputs_3_w_ready,
  output wire [31:0]   io_sharedOutputs_3_w_payload_data,
  output wire [3:0]    io_sharedOutputs_3_w_payload_strb,
  output wire          io_sharedOutputs_3_w_payload_last,
  input  wire          io_sharedOutputs_3_b_valid,
  output wire          io_sharedOutputs_3_b_ready,
  input  wire [1:0]    io_sharedOutputs_3_b_payload_resp,
  input  wire          io_sharedOutputs_3_r_valid,
  output wire          io_sharedOutputs_3_r_ready,
  input  wire [31:0]   io_sharedOutputs_3_r_payload_data,
  input  wire [1:0]    io_sharedOutputs_3_r_payload_resp,
  input  wire          io_sharedOutputs_3_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire                errorSlave_io_axi_arw_valid;
  wire                errorSlave_io_axi_w_valid;
  wire                errorSlave_io_axi_arw_ready;
  wire                errorSlave_io_axi_w_ready;
  wire                errorSlave_io_axi_b_valid;
  wire       [1:0]    errorSlave_io_axi_b_payload_resp;
  wire                errorSlave_io_axi_r_valid;
  wire       [31:0]   errorSlave_io_axi_r_payload_data;
  wire       [1:0]    errorSlave_io_axi_r_payload_resp;
  wire                errorSlave_io_axi_r_payload_last;
  reg        [1:0]    _zz_io_input_b_payload_resp;
  reg        [31:0]   _zz_io_input_r_payload_data;
  reg        [1:0]    _zz_io_input_r_payload_resp;
  reg                 _zz_io_input_r_payload_last;
  reg        [2:0]    _zz_pendingCmdCounter;
  reg        [2:0]    _zz_pendingCmdCounter_1;
  reg        [2:0]    _zz_pendingCmdCounter_2;
  wire                cmdAllowedStart;
  wire                io_input_arw_fire;
  wire                io_input_b_fire;
  wire                io_input_r_fire;
  wire                when_Utils_l798;
  reg        [2:0]    pendingCmdCounter;
  wire       [2:0]    _zz_pendingCmdCounter_3;
  wire                when_Utils_l732;
  wire                io_input_w_fire;
  wire                when_Utils_l735;
  reg                 pendingDataCounter_incrementIt;
  reg                 pendingDataCounter_decrementIt;
  wire       [2:0]    pendingDataCounter_valueNext;
  reg        [2:0]    pendingDataCounter_value;
  wire                pendingDataCounter_mayOverflow;
  wire                pendingDataCounter_mayUnderflow;
  wire                pendingDataCounter_willOverflowIfInc;
  wire                pendingDataCounter_willOverflow;
  wire                pendingDataCounter_willUnderflowIfDec;
  wire                pendingDataCounter_willUnderflow;
  reg        [2:0]    pendingDataCounter_finalIncrement;
  wire                when_Utils_l767;
  wire                when_Utils_l769;
  wire       [3:0]    decodedCmdSels;
  wire                decodedCmdError;
  reg        [3:0]    pendingSels;
  reg                 pendingError;
  wire                allowCmd;
  wire                allowData;
  reg                 _zz_cmdAllowedStart;
  wire       [3:0]    _zz_io_sharedOutputs_0_arw_valid;
  wire       [3:0]    _zz_io_sharedOutputs_0_w_valid;
  wire       [3:0]    _zz_writeRspIndex;
  wire                _zz_writeRspIndex_1;
  wire                _zz_writeRspIndex_2;
  wire                _zz_writeRspIndex_3;
  wire       [1:0]    writeRspIndex;
  wire       [3:0]    _zz_readRspIndex;
  wire                _zz_readRspIndex_1;
  wire                _zz_readRspIndex_2;
  wire                _zz_readRspIndex_3;
  wire       [1:0]    readRspIndex;

  vexAxi4SharedErrorSlave errorSlave (
    .io_axi_arw_valid         (errorSlave_io_axi_arw_valid           ), //i
    .io_axi_arw_ready         (errorSlave_io_axi_arw_ready           ), //o
    .io_axi_arw_payload_addr  (io_input_arw_payload_addr[31:0]       ), //i
    .io_axi_arw_payload_size  (io_input_arw_payload_size[2:0]        ), //i
    .io_axi_arw_payload_cache (io_input_arw_payload_cache[3:0]       ), //i
    .io_axi_arw_payload_prot  (io_input_arw_payload_prot[2:0]        ), //i
    .io_axi_arw_payload_write (io_input_arw_payload_write            ), //i
    .io_axi_w_valid           (errorSlave_io_axi_w_valid             ), //i
    .io_axi_w_ready           (errorSlave_io_axi_w_ready             ), //o
    .io_axi_w_payload_data    (io_input_w_payload_data[31:0]         ), //i
    .io_axi_w_payload_strb    (io_input_w_payload_strb[3:0]          ), //i
    .io_axi_w_payload_last    (io_input_w_payload_last               ), //i
    .io_axi_b_valid           (errorSlave_io_axi_b_valid             ), //o
    .io_axi_b_ready           (io_input_b_ready                      ), //i
    .io_axi_b_payload_resp    (errorSlave_io_axi_b_payload_resp[1:0] ), //o
    .io_axi_r_valid           (errorSlave_io_axi_r_valid             ), //o
    .io_axi_r_ready           (io_input_r_ready                      ), //i
    .io_axi_r_payload_data    (errorSlave_io_axi_r_payload_data[31:0]), //o
    .io_axi_r_payload_resp    (errorSlave_io_axi_r_payload_resp[1:0] ), //o
    .io_axi_r_payload_last    (errorSlave_io_axi_r_payload_last      ), //o
    .io_axiClk                (io_axiClk                             ), //i
    .resetCtrl_axiReset       (resetCtrl_axiReset                    )  //i
  );
  always @(*) begin
    case(writeRspIndex)
      2'b00 : _zz_io_input_b_payload_resp = io_sharedOutputs_0_b_payload_resp;
      2'b01 : _zz_io_input_b_payload_resp = io_sharedOutputs_1_b_payload_resp;
      2'b10 : _zz_io_input_b_payload_resp = io_sharedOutputs_2_b_payload_resp;
      default : _zz_io_input_b_payload_resp = io_sharedOutputs_3_b_payload_resp;
    endcase
  end

  always @(*) begin
    case(readRspIndex)
      2'b00 : begin
        _zz_io_input_r_payload_data = io_sharedOutputs_0_r_payload_data;
        _zz_io_input_r_payload_resp = io_sharedOutputs_0_r_payload_resp;
        _zz_io_input_r_payload_last = io_sharedOutputs_0_r_payload_last;
      end
      2'b01 : begin
        _zz_io_input_r_payload_data = io_sharedOutputs_1_r_payload_data;
        _zz_io_input_r_payload_resp = io_sharedOutputs_1_r_payload_resp;
        _zz_io_input_r_payload_last = io_sharedOutputs_1_r_payload_last;
      end
      2'b10 : begin
        _zz_io_input_r_payload_data = io_sharedOutputs_2_r_payload_data;
        _zz_io_input_r_payload_resp = io_sharedOutputs_2_r_payload_resp;
        _zz_io_input_r_payload_last = io_sharedOutputs_2_r_payload_last;
      end
      default : begin
        _zz_io_input_r_payload_data = io_sharedOutputs_3_r_payload_data;
        _zz_io_input_r_payload_resp = io_sharedOutputs_3_r_payload_resp;
        _zz_io_input_r_payload_last = io_sharedOutputs_3_r_payload_last;
      end
    endcase
  end

  always @(*) begin
    _zz_pendingCmdCounter = _zz_pendingCmdCounter_1;
    if(when_Utils_l798) begin
      _zz_pendingCmdCounter = (_zz_pendingCmdCounter_1 - 3'b001);
    end
  end

  always @(*) begin
    _zz_pendingCmdCounter_1 = _zz_pendingCmdCounter_2;
    if(io_input_b_fire) begin
      _zz_pendingCmdCounter_1 = (_zz_pendingCmdCounter_2 - 3'b001);
    end
  end

  always @(*) begin
    _zz_pendingCmdCounter_2 = _zz_pendingCmdCounter_3;
    if(io_input_arw_fire) begin
      _zz_pendingCmdCounter_2 = (_zz_pendingCmdCounter_3 + 3'b001);
    end
  end

  assign io_input_arw_fire = (io_input_arw_valid && io_input_arw_ready);
  assign io_input_b_fire = (io_input_b_valid && io_input_b_ready);
  assign io_input_r_fire = (io_input_r_valid && io_input_r_ready);
  assign when_Utils_l798 = (io_input_r_fire && io_input_r_payload_last);
  assign _zz_pendingCmdCounter_3 = pendingCmdCounter;
  assign when_Utils_l732 = (cmdAllowedStart && io_input_arw_payload_write);
  assign io_input_w_fire = (io_input_w_valid && io_input_w_ready);
  assign when_Utils_l735 = (io_input_w_fire && io_input_w_payload_last);
  always @(*) begin
    pendingDataCounter_incrementIt = 1'b0;
    if(when_Utils_l732) begin
      pendingDataCounter_incrementIt = 1'b1;
    end
  end

  always @(*) begin
    pendingDataCounter_decrementIt = 1'b0;
    if(when_Utils_l735) begin
      pendingDataCounter_decrementIt = 1'b1;
    end
  end

  assign pendingDataCounter_mayOverflow = (pendingDataCounter_value == 3'b111);
  assign pendingDataCounter_mayUnderflow = (pendingDataCounter_value == 3'b000);
  assign pendingDataCounter_willOverflowIfInc = (pendingDataCounter_mayOverflow && (! pendingDataCounter_decrementIt));
  assign pendingDataCounter_willOverflow = (pendingDataCounter_willOverflowIfInc && pendingDataCounter_incrementIt);
  assign pendingDataCounter_willUnderflowIfDec = (pendingDataCounter_mayUnderflow && (! pendingDataCounter_incrementIt));
  assign pendingDataCounter_willUnderflow = (pendingDataCounter_willUnderflowIfDec && pendingDataCounter_decrementIt);
  assign when_Utils_l767 = (pendingDataCounter_incrementIt && (! pendingDataCounter_decrementIt));
  always @(*) begin
    if(when_Utils_l767) begin
      pendingDataCounter_finalIncrement = 3'b001;
    end else begin
      if(when_Utils_l769) begin
        pendingDataCounter_finalIncrement = 3'b111;
      end else begin
        pendingDataCounter_finalIncrement = 3'b000;
      end
    end
  end

  assign when_Utils_l769 = ((! pendingDataCounter_incrementIt) && pendingDataCounter_decrementIt);
  assign pendingDataCounter_valueNext = (pendingDataCounter_value + pendingDataCounter_finalIncrement);
  assign decodedCmdSels = {((io_input_arw_payload_addr & (~ 32'h000003ff)) == 32'hc0000000),{((io_input_arw_payload_addr & (~ 32'h000fffff)) == 32'ha0000000),{((io_input_arw_payload_addr & (~ 32'h00000fff)) == 32'hf0000000),((io_input_arw_payload_addr & (~ 32'h0001ffff)) == 32'h80000000)}}};
  assign decodedCmdError = (decodedCmdSels == 4'b0000);
  assign allowCmd = ((pendingCmdCounter == 3'b000) || ((pendingCmdCounter != 3'b111) && (pendingSels == decodedCmdSels)));
  assign allowData = (pendingDataCounter_value != 3'b000);
  assign cmdAllowedStart = ((io_input_arw_valid && allowCmd) && _zz_cmdAllowedStart);
  assign io_input_arw_ready = (((|(decodedCmdSels & {io_sharedOutputs_3_arw_ready,{io_sharedOutputs_2_arw_ready,{io_sharedOutputs_1_arw_ready,io_sharedOutputs_0_arw_ready}}})) || (decodedCmdError && errorSlave_io_axi_arw_ready)) && allowCmd);
  assign errorSlave_io_axi_arw_valid = ((io_input_arw_valid && decodedCmdError) && allowCmd);
  assign _zz_io_sharedOutputs_0_arw_valid = decodedCmdSels[3 : 0];
  assign io_sharedOutputs_0_arw_valid = ((io_input_arw_valid && _zz_io_sharedOutputs_0_arw_valid[0]) && allowCmd);
  assign io_sharedOutputs_0_arw_payload_addr = io_input_arw_payload_addr;
  assign io_sharedOutputs_0_arw_payload_size = io_input_arw_payload_size;
  assign io_sharedOutputs_0_arw_payload_cache = io_input_arw_payload_cache;
  assign io_sharedOutputs_0_arw_payload_prot = io_input_arw_payload_prot;
  assign io_sharedOutputs_0_arw_payload_write = io_input_arw_payload_write;
  assign io_sharedOutputs_1_arw_valid = ((io_input_arw_valid && _zz_io_sharedOutputs_0_arw_valid[1]) && allowCmd);
  assign io_sharedOutputs_1_arw_payload_addr = io_input_arw_payload_addr;
  assign io_sharedOutputs_1_arw_payload_size = io_input_arw_payload_size;
  assign io_sharedOutputs_1_arw_payload_cache = io_input_arw_payload_cache;
  assign io_sharedOutputs_1_arw_payload_prot = io_input_arw_payload_prot;
  assign io_sharedOutputs_1_arw_payload_write = io_input_arw_payload_write;
  assign io_sharedOutputs_2_arw_valid = ((io_input_arw_valid && _zz_io_sharedOutputs_0_arw_valid[2]) && allowCmd);
  assign io_sharedOutputs_2_arw_payload_addr = io_input_arw_payload_addr;
  assign io_sharedOutputs_2_arw_payload_size = io_input_arw_payload_size;
  assign io_sharedOutputs_2_arw_payload_cache = io_input_arw_payload_cache;
  assign io_sharedOutputs_2_arw_payload_prot = io_input_arw_payload_prot;
  assign io_sharedOutputs_2_arw_payload_write = io_input_arw_payload_write;
  assign io_sharedOutputs_3_arw_valid = ((io_input_arw_valid && _zz_io_sharedOutputs_0_arw_valid[3]) && allowCmd);
  assign io_sharedOutputs_3_arw_payload_addr = io_input_arw_payload_addr;
  assign io_sharedOutputs_3_arw_payload_size = io_input_arw_payload_size;
  assign io_sharedOutputs_3_arw_payload_cache = io_input_arw_payload_cache;
  assign io_sharedOutputs_3_arw_payload_prot = io_input_arw_payload_prot;
  assign io_sharedOutputs_3_arw_payload_write = io_input_arw_payload_write;
  assign io_input_w_ready = (((|(pendingSels[3 : 0] & {io_sharedOutputs_3_w_ready,{io_sharedOutputs_2_w_ready,{io_sharedOutputs_1_w_ready,io_sharedOutputs_0_w_ready}}})) || (pendingError && errorSlave_io_axi_w_ready)) && allowData);
  assign errorSlave_io_axi_w_valid = ((io_input_w_valid && pendingError) && allowData);
  assign _zz_io_sharedOutputs_0_w_valid = pendingSels[3 : 0];
  assign io_sharedOutputs_0_w_valid = ((io_input_w_valid && _zz_io_sharedOutputs_0_w_valid[0]) && allowData);
  assign io_sharedOutputs_0_w_payload_data = io_input_w_payload_data;
  assign io_sharedOutputs_0_w_payload_strb = io_input_w_payload_strb;
  assign io_sharedOutputs_0_w_payload_last = io_input_w_payload_last;
  assign io_sharedOutputs_1_w_valid = ((io_input_w_valid && _zz_io_sharedOutputs_0_w_valid[1]) && allowData);
  assign io_sharedOutputs_1_w_payload_data = io_input_w_payload_data;
  assign io_sharedOutputs_1_w_payload_strb = io_input_w_payload_strb;
  assign io_sharedOutputs_1_w_payload_last = io_input_w_payload_last;
  assign io_sharedOutputs_2_w_valid = ((io_input_w_valid && _zz_io_sharedOutputs_0_w_valid[2]) && allowData);
  assign io_sharedOutputs_2_w_payload_data = io_input_w_payload_data;
  assign io_sharedOutputs_2_w_payload_strb = io_input_w_payload_strb;
  assign io_sharedOutputs_2_w_payload_last = io_input_w_payload_last;
  assign io_sharedOutputs_3_w_valid = ((io_input_w_valid && _zz_io_sharedOutputs_0_w_valid[3]) && allowData);
  assign io_sharedOutputs_3_w_payload_data = io_input_w_payload_data;
  assign io_sharedOutputs_3_w_payload_strb = io_input_w_payload_strb;
  assign io_sharedOutputs_3_w_payload_last = io_input_w_payload_last;
  assign _zz_writeRspIndex = pendingSels[3 : 0];
  assign _zz_writeRspIndex_1 = _zz_writeRspIndex[3];
  assign _zz_writeRspIndex_2 = (_zz_writeRspIndex[1] || _zz_writeRspIndex_1);
  assign _zz_writeRspIndex_3 = (_zz_writeRspIndex[2] || _zz_writeRspIndex_1);
  assign writeRspIndex = {_zz_writeRspIndex_3,_zz_writeRspIndex_2};
  assign io_input_b_valid = ((|{io_sharedOutputs_3_b_valid,{io_sharedOutputs_2_b_valid,{io_sharedOutputs_1_b_valid,io_sharedOutputs_0_b_valid}}}) || errorSlave_io_axi_b_valid);
  always @(*) begin
    io_input_b_payload_resp = _zz_io_input_b_payload_resp;
    if(pendingError) begin
      io_input_b_payload_resp = errorSlave_io_axi_b_payload_resp;
    end
  end

  assign io_sharedOutputs_0_b_ready = io_input_b_ready;
  assign io_sharedOutputs_1_b_ready = io_input_b_ready;
  assign io_sharedOutputs_2_b_ready = io_input_b_ready;
  assign io_sharedOutputs_3_b_ready = io_input_b_ready;
  assign _zz_readRspIndex = pendingSels[3 : 0];
  assign _zz_readRspIndex_1 = _zz_readRspIndex[3];
  assign _zz_readRspIndex_2 = (_zz_readRspIndex[1] || _zz_readRspIndex_1);
  assign _zz_readRspIndex_3 = (_zz_readRspIndex[2] || _zz_readRspIndex_1);
  assign readRspIndex = {_zz_readRspIndex_3,_zz_readRspIndex_2};
  assign io_input_r_valid = ((|{io_sharedOutputs_3_r_valid,{io_sharedOutputs_2_r_valid,{io_sharedOutputs_1_r_valid,io_sharedOutputs_0_r_valid}}}) || errorSlave_io_axi_r_valid);
  assign io_input_r_payload_data = _zz_io_input_r_payload_data;
  always @(*) begin
    io_input_r_payload_resp = _zz_io_input_r_payload_resp;
    if(pendingError) begin
      io_input_r_payload_resp = errorSlave_io_axi_r_payload_resp;
    end
  end

  always @(*) begin
    io_input_r_payload_last = _zz_io_input_r_payload_last;
    if(pendingError) begin
      io_input_r_payload_last = errorSlave_io_axi_r_payload_last;
    end
  end

  assign io_sharedOutputs_0_r_ready = io_input_r_ready;
  assign io_sharedOutputs_1_r_ready = io_input_r_ready;
  assign io_sharedOutputs_2_r_ready = io_input_r_ready;
  assign io_sharedOutputs_3_r_ready = io_input_r_ready;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      pendingCmdCounter <= 3'b000;
      pendingDataCounter_value <= 3'b000;
      pendingSels <= 4'b0000;
      pendingError <= 1'b0;
      _zz_cmdAllowedStart <= 1'b1;
    end else begin
      pendingCmdCounter <= _zz_pendingCmdCounter;
      pendingDataCounter_value <= pendingDataCounter_valueNext;
      if(cmdAllowedStart) begin
        pendingSels <= decodedCmdSels;
      end
      if(cmdAllowedStart) begin
        pendingError <= decodedCmdError;
      end
      if(cmdAllowedStart) begin
        _zz_cmdAllowedStart <= 1'b0;
      end
      if(io_input_arw_ready) begin
        _zz_cmdAllowedStart <= 1'b1;
      end
    end
  end


endmodule

module vexAxi4ReadOnlyDecoder (
  input  wire          io_input_ar_valid,
  output wire          io_input_ar_ready,
  input  wire [31:0]   io_input_ar_payload_addr,
  input  wire [3:0]    io_input_ar_payload_cache,
  input  wire [2:0]    io_input_ar_payload_prot,
  output reg           io_input_r_valid,
  input  wire          io_input_r_ready,
  output wire [31:0]   io_input_r_payload_data,
  output reg  [1:0]    io_input_r_payload_resp,
  output reg           io_input_r_payload_last,
  output wire          io_outputs_0_ar_valid,
  input  wire          io_outputs_0_ar_ready,
  output wire [31:0]   io_outputs_0_ar_payload_addr,
  output wire [3:0]    io_outputs_0_ar_payload_cache,
  output wire [2:0]    io_outputs_0_ar_payload_prot,
  input  wire          io_outputs_0_r_valid,
  output wire          io_outputs_0_r_ready,
  input  wire [31:0]   io_outputs_0_r_payload_data,
  input  wire [1:0]    io_outputs_0_r_payload_resp,
  input  wire          io_outputs_0_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire                errorSlave_io_axi_ar_valid;
  wire                errorSlave_io_axi_ar_ready;
  wire                errorSlave_io_axi_r_valid;
  wire       [31:0]   errorSlave_io_axi_r_payload_data;
  wire       [1:0]    errorSlave_io_axi_r_payload_resp;
  wire                errorSlave_io_axi_r_payload_last;
  wire                io_input_ar_fire;
  wire                io_input_r_fire;
  wire                when_Utils_l735;
  reg                 pendingCmdCounter_incrementIt;
  reg                 pendingCmdCounter_decrementIt;
  wire       [2:0]    pendingCmdCounter_valueNext;
  reg        [2:0]    pendingCmdCounter_value;
  wire                pendingCmdCounter_mayOverflow;
  wire                pendingCmdCounter_mayUnderflow;
  wire                pendingCmdCounter_willOverflowIfInc;
  wire                pendingCmdCounter_willOverflow;
  wire                pendingCmdCounter_willUnderflowIfDec;
  wire                pendingCmdCounter_willUnderflow;
  reg        [2:0]    pendingCmdCounter_finalIncrement;
  wire                when_Utils_l767;
  wire                when_Utils_l769;
  wire       [0:0]    decodedCmdSels;
  wire                decodedCmdError;
  reg        [0:0]    pendingSels;
  reg                 pendingError;
  wire                allowCmd;

  vexAxi4ReadOnlyErrorSlave errorSlave (
    .io_axi_ar_valid         (errorSlave_io_axi_ar_valid            ), //i
    .io_axi_ar_ready         (errorSlave_io_axi_ar_ready            ), //o
    .io_axi_ar_payload_addr  (io_input_ar_payload_addr[31:0]        ), //i
    .io_axi_ar_payload_cache (io_input_ar_payload_cache[3:0]        ), //i
    .io_axi_ar_payload_prot  (io_input_ar_payload_prot[2:0]         ), //i
    .io_axi_r_valid          (errorSlave_io_axi_r_valid             ), //o
    .io_axi_r_ready          (io_input_r_ready                      ), //i
    .io_axi_r_payload_data   (errorSlave_io_axi_r_payload_data[31:0]), //o
    .io_axi_r_payload_resp   (errorSlave_io_axi_r_payload_resp[1:0] ), //o
    .io_axi_r_payload_last   (errorSlave_io_axi_r_payload_last      ), //o
    .io_axiClk               (io_axiClk                             ), //i
    .resetCtrl_axiReset      (resetCtrl_axiReset                    )  //i
  );
  assign io_input_ar_fire = (io_input_ar_valid && io_input_ar_ready);
  assign io_input_r_fire = (io_input_r_valid && io_input_r_ready);
  assign when_Utils_l735 = (io_input_r_fire && io_input_r_payload_last);
  always @(*) begin
    pendingCmdCounter_incrementIt = 1'b0;
    if(io_input_ar_fire) begin
      pendingCmdCounter_incrementIt = 1'b1;
    end
  end

  always @(*) begin
    pendingCmdCounter_decrementIt = 1'b0;
    if(when_Utils_l735) begin
      pendingCmdCounter_decrementIt = 1'b1;
    end
  end

  assign pendingCmdCounter_mayOverflow = (pendingCmdCounter_value == 3'b111);
  assign pendingCmdCounter_mayUnderflow = (pendingCmdCounter_value == 3'b000);
  assign pendingCmdCounter_willOverflowIfInc = (pendingCmdCounter_mayOverflow && (! pendingCmdCounter_decrementIt));
  assign pendingCmdCounter_willOverflow = (pendingCmdCounter_willOverflowIfInc && pendingCmdCounter_incrementIt);
  assign pendingCmdCounter_willUnderflowIfDec = (pendingCmdCounter_mayUnderflow && (! pendingCmdCounter_incrementIt));
  assign pendingCmdCounter_willUnderflow = (pendingCmdCounter_willUnderflowIfDec && pendingCmdCounter_decrementIt);
  assign when_Utils_l767 = (pendingCmdCounter_incrementIt && (! pendingCmdCounter_decrementIt));
  always @(*) begin
    if(when_Utils_l767) begin
      pendingCmdCounter_finalIncrement = 3'b001;
    end else begin
      if(when_Utils_l769) begin
        pendingCmdCounter_finalIncrement = 3'b111;
      end else begin
        pendingCmdCounter_finalIncrement = 3'b000;
      end
    end
  end

  assign when_Utils_l769 = ((! pendingCmdCounter_incrementIt) && pendingCmdCounter_decrementIt);
  assign pendingCmdCounter_valueNext = (pendingCmdCounter_value + pendingCmdCounter_finalIncrement);
  assign decodedCmdSels = (((io_input_ar_payload_addr & (~ 32'h0001ffff)) == 32'h80000000) && io_input_ar_valid);
  assign decodedCmdError = (decodedCmdSels == 1'b0);
  assign allowCmd = ((pendingCmdCounter_value == 3'b000) || ((pendingCmdCounter_value != 3'b111) && (pendingSels == decodedCmdSels)));
  assign io_input_ar_ready = (((|(decodedCmdSels & io_outputs_0_ar_ready)) || (decodedCmdError && errorSlave_io_axi_ar_ready)) && allowCmd);
  assign errorSlave_io_axi_ar_valid = ((io_input_ar_valid && decodedCmdError) && allowCmd);
  assign io_outputs_0_ar_valid = ((io_input_ar_valid && decodedCmdSels[0]) && allowCmd);
  assign io_outputs_0_ar_payload_addr = io_input_ar_payload_addr;
  assign io_outputs_0_ar_payload_cache = io_input_ar_payload_cache;
  assign io_outputs_0_ar_payload_prot = io_input_ar_payload_prot;
  always @(*) begin
    io_input_r_valid = (|io_outputs_0_r_valid);
    if(errorSlave_io_axi_r_valid) begin
      io_input_r_valid = 1'b1;
    end
  end

  assign io_input_r_payload_data = io_outputs_0_r_payload_data;
  always @(*) begin
    io_input_r_payload_resp = io_outputs_0_r_payload_resp;
    if(pendingError) begin
      io_input_r_payload_resp = errorSlave_io_axi_r_payload_resp;
    end
  end

  always @(*) begin
    io_input_r_payload_last = io_outputs_0_r_payload_last;
    if(pendingError) begin
      io_input_r_payload_last = errorSlave_io_axi_r_payload_last;
    end
  end

  assign io_outputs_0_r_ready = io_input_r_ready;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      pendingCmdCounter_value <= 3'b000;
      pendingSels <= 1'b0;
      pendingError <= 1'b0;
    end else begin
      pendingCmdCounter_value <= pendingCmdCounter_valueNext;
      if(io_input_ar_ready) begin
        pendingSels <= decodedCmdSels;
      end
      if(io_input_ar_ready) begin
        pendingError <= decodedCmdError;
      end
    end
  end


endmodule

module vexBufferCC_2 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge io_axiClk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

module vexVexRiscv (
  output wire          iBus_cmd_valid,
  input  wire          iBus_cmd_ready,
  output wire [31:0]   iBus_cmd_payload_pc,
  input  wire          iBus_rsp_valid,
  input  wire          iBus_rsp_payload_error,
  input  wire [31:0]   iBus_rsp_payload_inst,
  input  wire          timerInterrupt,
  input  wire          externalInterrupt,
  input  wire          softwareInterrupt,
  output wire          dBus_cmd_valid,
  input  wire          dBus_cmd_ready,
  output wire          dBus_cmd_payload_wr,
  output wire [3:0]    dBus_cmd_payload_mask,
  output wire [31:0]   dBus_cmd_payload_address,
  output wire [31:0]   dBus_cmd_payload_data,
  output wire [1:0]    dBus_cmd_payload_size,
  input  wire          dBus_rsp_ready,
  input  wire          dBus_rsp_error,
  input  wire [31:0]   dBus_rsp_data,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);
  localparam vexShiftCtrlEnum_DISABLE_1 = 2'd0;
  localparam vexShiftCtrlEnum_SLL_1 = 2'd1;
  localparam vexShiftCtrlEnum_SRL_1 = 2'd2;
  localparam vexShiftCtrlEnum_SRA_1 = 2'd3;
  localparam vexEnvCtrlEnum_NONE = 1'd0;
  localparam vexEnvCtrlEnum_XRET = 1'd1;
  localparam vexBranchCtrlEnum_INC = 2'd0;
  localparam vexBranchCtrlEnum_B = 2'd1;
  localparam vexBranchCtrlEnum_JAL = 2'd2;
  localparam vexBranchCtrlEnum_JALR = 2'd3;
  localparam vexAluBitwiseCtrlEnum_XOR_1 = 2'd0;
  localparam vexAluBitwiseCtrlEnum_OR_1 = 2'd1;
  localparam vexAluBitwiseCtrlEnum_AND_1 = 2'd2;
  localparam vexSrc2CtrlEnum_RS = 2'd0;
  localparam vexSrc2CtrlEnum_IMI = 2'd1;
  localparam vexSrc2CtrlEnum_IMS = 2'd2;
  localparam vexSrc2CtrlEnum_PC = 2'd3;
  localparam vexAluCtrlEnum_ADD_SUB = 2'd0;
  localparam vexAluCtrlEnum_SLT_SLTU = 2'd1;
  localparam vexAluCtrlEnum_BITWISE = 2'd2;
  localparam vexSrc1CtrlEnum_RS = 2'd0;
  localparam vexSrc1CtrlEnum_IMU = 2'd1;
  localparam vexSrc1CtrlEnum_PC_INCREMENT = 2'd2;
  localparam vexSrc1CtrlEnum_URS1 = 2'd3;

  wire                IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready;
  reg        [31:0]   RegFilePlugin_regFile_spinal_port0;
  reg        [31:0]   RegFilePlugin_regFile_spinal_port1;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
  wire       [31:0]   IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
  wire       [0:0]    IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy;
  wire       [0:0]    IBusSimplePlugin_rspJoin_rspBuffer_c_io_availability;
  wire       [51:0]   _zz_memory_MUL_LOW;
  wire       [51:0]   _zz_memory_MUL_LOW_1;
  wire       [51:0]   _zz_memory_MUL_LOW_2;
  wire       [32:0]   _zz_memory_MUL_LOW_3;
  wire       [51:0]   _zz_memory_MUL_LOW_4;
  wire       [49:0]   _zz_memory_MUL_LOW_5;
  wire       [51:0]   _zz_memory_MUL_LOW_6;
  wire       [49:0]   _zz_memory_MUL_LOW_7;
  wire       [31:0]   _zz_execute_SHIFT_RIGHT;
  wire       [32:0]   _zz_execute_SHIFT_RIGHT_1;
  wire       [32:0]   _zz_execute_SHIFT_RIGHT_2;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_1;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_2;
  wire                _zz_decode_LEGAL_INSTRUCTION_3;
  wire       [0:0]    _zz_decode_LEGAL_INSTRUCTION_4;
  wire       [10:0]   _zz_decode_LEGAL_INSTRUCTION_5;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_6;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_7;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_8;
  wire                _zz_decode_LEGAL_INSTRUCTION_9;
  wire       [0:0]    _zz_decode_LEGAL_INSTRUCTION_10;
  wire       [4:0]    _zz_decode_LEGAL_INSTRUCTION_11;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_12;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_13;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_14;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_15;
  wire       [31:0]   _zz_decode_LEGAL_INSTRUCTION_16;
  wire       [2:0]    _zz__zz_IBusSimplePlugin_jump_pcLoad_payload_1;
  reg        [31:0]   _zz_IBusSimplePlugin_jump_pcLoad_payload_4;
  wire       [1:0]    _zz_IBusSimplePlugin_jump_pcLoad_payload_5;
  wire       [31:0]   _zz_IBusSimplePlugin_fetchPc_pc;
  wire       [2:0]    _zz_IBusSimplePlugin_fetchPc_pc_1;
  wire       [11:0]   _zz__zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
  wire       [31:0]   _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_2;
  wire       [19:0]   _zz__zz_2;
  wire       [11:0]   _zz__zz_4;
  wire       [31:0]   _zz__zz_6;
  wire       [31:0]   _zz__zz_6_1;
  wire       [19:0]   _zz__zz_IBusSimplePlugin_predictionJumpInterface_payload;
  wire       [11:0]   _zz__zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
  wire                _zz_IBusSimplePlugin_predictionJumpInterface_payload_4;
  wire                _zz_IBusSimplePlugin_predictionJumpInterface_payload_5;
  wire                _zz_IBusSimplePlugin_predictionJumpInterface_payload_6;
  wire       [2:0]    _zz_IBusSimplePlugin_pending_next;
  wire       [2:0]    _zz_IBusSimplePlugin_pending_next_1;
  wire       [0:0]    _zz_IBusSimplePlugin_pending_next_2;
  wire       [2:0]    _zz_IBusSimplePlugin_pending_next_3;
  wire       [0:0]    _zz_IBusSimplePlugin_pending_next_4;
  wire       [2:0]    _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter;
  wire       [0:0]    _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1;
  wire       [2:0]    _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_2;
  wire       [0:0]    _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_3;
  wire       [2:0]    _zz_DBusSimplePlugin_memoryExceptionPort_payload_code;
  wire       [31:0]   _zz__zz_decode_IS_CSR;
  wire                _zz__zz_decode_IS_CSR_1;
  wire                _zz__zz_decode_IS_CSR_2;
  wire       [0:0]    _zz__zz_decode_IS_CSR_3;
  wire       [0:0]    _zz__zz_decode_IS_CSR_4;
  wire       [0:0]    _zz__zz_decode_IS_CSR_5;
  wire                _zz__zz_decode_IS_CSR_6;
  wire       [0:0]    _zz__zz_decode_IS_CSR_7;
  wire       [22:0]   _zz__zz_decode_IS_CSR_8;
  wire                _zz__zz_decode_IS_CSR_9;
  wire       [0:0]    _zz__zz_decode_IS_CSR_10;
  wire                _zz__zz_decode_IS_CSR_11;
  wire       [31:0]   _zz__zz_decode_IS_CSR_12;
  wire       [0:0]    _zz__zz_decode_IS_CSR_13;
  wire                _zz__zz_decode_IS_CSR_14;
  wire                _zz__zz_decode_IS_CSR_15;
  wire       [18:0]   _zz__zz_decode_IS_CSR_16;
  wire                _zz__zz_decode_IS_CSR_17;
  wire       [0:0]    _zz__zz_decode_IS_CSR_18;
  wire                _zz__zz_decode_IS_CSR_19;
  wire       [31:0]   _zz__zz_decode_IS_CSR_20;
  wire       [0:0]    _zz__zz_decode_IS_CSR_21;
  wire                _zz__zz_decode_IS_CSR_22;
  wire                _zz__zz_decode_IS_CSR_23;
  wire       [14:0]   _zz__zz_decode_IS_CSR_24;
  wire       [0:0]    _zz__zz_decode_IS_CSR_25;
  wire       [31:0]   _zz__zz_decode_IS_CSR_26;
  wire       [0:0]    _zz__zz_decode_IS_CSR_27;
  wire       [31:0]   _zz__zz_decode_IS_CSR_28;
  wire       [2:0]    _zz__zz_decode_IS_CSR_29;
  wire       [31:0]   _zz__zz_decode_IS_CSR_30;
  wire       [31:0]   _zz__zz_decode_IS_CSR_31;
  wire                _zz__zz_decode_IS_CSR_32;
  wire                _zz__zz_decode_IS_CSR_33;
  wire       [31:0]   _zz__zz_decode_IS_CSR_34;
  wire       [31:0]   _zz__zz_decode_IS_CSR_35;
  wire       [0:0]    _zz__zz_decode_IS_CSR_36;
  wire       [0:0]    _zz__zz_decode_IS_CSR_37;
  wire       [31:0]   _zz__zz_decode_IS_CSR_38;
  wire       [3:0]    _zz__zz_decode_IS_CSR_39;
  wire                _zz__zz_decode_IS_CSR_40;
  wire       [31:0]   _zz__zz_decode_IS_CSR_41;
  wire       [0:0]    _zz__zz_decode_IS_CSR_42;
  wire       [31:0]   _zz__zz_decode_IS_CSR_43;
  wire       [31:0]   _zz__zz_decode_IS_CSR_44;
  wire       [0:0]    _zz__zz_decode_IS_CSR_45;
  wire       [31:0]   _zz__zz_decode_IS_CSR_46;
  wire       [31:0]   _zz__zz_decode_IS_CSR_47;
  wire       [10:0]   _zz__zz_decode_IS_CSR_48;
  wire       [4:0]    _zz__zz_decode_IS_CSR_49;
  wire                _zz__zz_decode_IS_CSR_50;
  wire       [31:0]   _zz__zz_decode_IS_CSR_51;
  wire       [0:0]    _zz__zz_decode_IS_CSR_52;
  wire       [31:0]   _zz__zz_decode_IS_CSR_53;
  wire       [31:0]   _zz__zz_decode_IS_CSR_54;
  wire       [1:0]    _zz__zz_decode_IS_CSR_55;
  wire                _zz__zz_decode_IS_CSR_56;
  wire       [31:0]   _zz__zz_decode_IS_CSR_57;
  wire                _zz__zz_decode_IS_CSR_58;
  wire       [31:0]   _zz__zz_decode_IS_CSR_59;
  wire                _zz__zz_decode_IS_CSR_60;
  wire       [0:0]    _zz__zz_decode_IS_CSR_61;
  wire       [31:0]   _zz__zz_decode_IS_CSR_62;
  wire       [31:0]   _zz__zz_decode_IS_CSR_63;
  wire       [3:0]    _zz__zz_decode_IS_CSR_64;
  wire                _zz__zz_decode_IS_CSR_65;
  wire       [31:0]   _zz__zz_decode_IS_CSR_66;
  wire       [0:0]    _zz__zz_decode_IS_CSR_67;
  wire       [31:0]   _zz__zz_decode_IS_CSR_68;
  wire       [31:0]   _zz__zz_decode_IS_CSR_69;
  wire       [1:0]    _zz__zz_decode_IS_CSR_70;
  wire                _zz__zz_decode_IS_CSR_71;
  wire                _zz__zz_decode_IS_CSR_72;
  wire       [0:0]    _zz__zz_decode_IS_CSR_73;
  wire       [0:0]    _zz__zz_decode_IS_CSR_74;
  wire       [0:0]    _zz__zz_decode_IS_CSR_75;
  wire       [31:0]   _zz__zz_decode_IS_CSR_76;
  wire       [31:0]   _zz__zz_decode_IS_CSR_77;
  wire       [7:0]    _zz__zz_decode_IS_CSR_78;
  wire       [1:0]    _zz__zz_decode_IS_CSR_79;
  wire                _zz__zz_decode_IS_CSR_80;
  wire       [31:0]   _zz__zz_decode_IS_CSR_81;
  wire                _zz__zz_decode_IS_CSR_82;
  wire                _zz__zz_decode_IS_CSR_83;
  wire       [31:0]   _zz__zz_decode_IS_CSR_84;
  wire       [0:0]    _zz__zz_decode_IS_CSR_85;
  wire       [0:0]    _zz__zz_decode_IS_CSR_86;
  wire       [31:0]   _zz__zz_decode_IS_CSR_87;
  wire       [31:0]   _zz__zz_decode_IS_CSR_88;
  wire       [4:0]    _zz__zz_decode_IS_CSR_89;
  wire                _zz__zz_decode_IS_CSR_90;
  wire       [0:0]    _zz__zz_decode_IS_CSR_91;
  wire       [31:0]   _zz__zz_decode_IS_CSR_92;
  wire       [2:0]    _zz__zz_decode_IS_CSR_93;
  wire                _zz__zz_decode_IS_CSR_94;
  wire                _zz__zz_decode_IS_CSR_95;
  wire       [0:0]    _zz__zz_decode_IS_CSR_96;
  wire       [0:0]    _zz__zz_decode_IS_CSR_97;
  wire       [31:0]   _zz__zz_decode_IS_CSR_98;
  wire       [2:0]    _zz__zz_decode_IS_CSR_99;
  wire                _zz__zz_decode_IS_CSR_100;
  wire                _zz__zz_decode_IS_CSR_101;
  wire       [0:0]    _zz__zz_decode_IS_CSR_102;
  wire       [0:0]    _zz__zz_decode_IS_CSR_103;
  wire       [0:0]    _zz__zz_decode_IS_CSR_104;
  wire       [0:0]    _zz__zz_decode_IS_CSR_105;
  wire       [0:0]    _zz__zz_decode_IS_CSR_106;
  wire       [0:0]    _zz__zz_decode_IS_CSR_107;
  wire       [0:0]    _zz__zz_decode_IS_CSR_108;
  wire       [0:0]    _zz__zz_decode_IS_CSR_109;
  wire                _zz_RegFilePlugin_regFile_port;
  wire                _zz_decode_RegFilePlugin_rs1Data;
  wire                _zz_RegFilePlugin_regFile_port_1;
  wire                _zz_decode_RegFilePlugin_rs2Data;
  wire       [0:0]    _zz__zz_execute_REGFILE_WRITE_DATA;
  wire       [2:0]    _zz__zz_execute_SRC1;
  wire       [4:0]    _zz__zz_execute_SRC1_1;
  wire       [11:0]   _zz__zz_execute_SRC2_2;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_1;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_2;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_3;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_4;
  wire       [65:0]   _zz_writeBack_MulPlugin_result;
  wire       [65:0]   _zz_writeBack_MulPlugin_result_1;
  wire       [31:0]   _zz__zz_decode_RS2_2;
  wire       [31:0]   _zz__zz_decode_RS2_2_1;
  wire       [5:0]    _zz_memory_DivPlugin_div_counter_valueNext;
  wire       [0:0]    _zz_memory_DivPlugin_div_counter_valueNext_1;
  wire       [32:0]   _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator;
  wire       [31:0]   _zz_memory_DivPlugin_div_stage_0_outRemainder;
  wire       [31:0]   _zz_memory_DivPlugin_div_stage_0_outRemainder_1;
  wire       [32:0]   _zz_memory_DivPlugin_div_stage_0_outNumerator;
  wire       [32:0]   _zz_memory_DivPlugin_div_result_1;
  wire       [32:0]   _zz_memory_DivPlugin_div_result_2;
  wire       [32:0]   _zz_memory_DivPlugin_div_result_3;
  wire       [32:0]   _zz_memory_DivPlugin_div_result_4;
  wire       [0:0]    _zz_memory_DivPlugin_div_result_5;
  wire       [32:0]   _zz_memory_DivPlugin_rs1_2;
  wire       [0:0]    _zz_memory_DivPlugin_rs1_3;
  wire       [31:0]   _zz_memory_DivPlugin_rs2_1;
  wire       [0:0]    _zz_memory_DivPlugin_rs2_2;
  wire       [19:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_2;
  wire       [11:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_4;
  wire       [31:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_6;
  wire       [31:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1;
  wire       [31:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2;
  wire       [19:0]   _zz__zz_execute_BranchPlugin_branch_src2_2;
  wire       [11:0]   _zz__zz_execute_BranchPlugin_branch_src2_4;
  wire       [0:0]    _zz_execute_BranchPlugin_branch_src2_6;
  wire       [7:0]    _zz_execute_BranchPlugin_branch_src2_7;
  wire                _zz_execute_BranchPlugin_branch_src2_8;
  wire       [0:0]    _zz_execute_BranchPlugin_branch_src2_9;
  wire       [0:0]    _zz_execute_BranchPlugin_branch_src2_10;
  wire       [2:0]    _zz_execute_BranchPlugin_branch_src2_11;
  wire       [1:0]    _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1;
  wire       [1:0]    _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1_1;
  wire       [1:0]    _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3;
  wire       [1:0]    _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3_1;
  wire                _zz_when;
  wire                _zz_when_1;
  wire       [51:0]   memory_MUL_LOW;
  wire       [31:0]   memory_MEMORY_READ_DATA;
  wire       [31:0]   execute_BRANCH_CALC;
  wire                execute_BRANCH_DO;
  wire       [33:0]   memory_MUL_HH;
  wire       [33:0]   execute_MUL_HH;
  wire       [33:0]   execute_MUL_HL;
  wire       [33:0]   execute_MUL_LH;
  wire       [31:0]   execute_MUL_LL;
  wire       [31:0]   execute_SHIFT_RIGHT;
  wire       [31:0]   writeBack_REGFILE_WRITE_DATA;
  wire       [31:0]   execute_REGFILE_WRITE_DATA;
  wire       [1:0]    memory_MEMORY_ADDRESS_LOW;
  wire       [1:0]    execute_MEMORY_ADDRESS_LOW;
  wire                decode_CSR_READ_OPCODE;
  wire                decode_CSR_WRITE_OPCODE;
  wire                decode_PREDICTION_HAD_BRANCHED1;
  wire                decode_SRC2_FORCE_ZERO;
  wire       [0:0]    _zz_memory_to_writeBack_ENV_CTRL;
  wire       [0:0]    _zz_memory_to_writeBack_ENV_CTRL_1;
  wire       [0:0]    _zz_execute_to_memory_ENV_CTRL;
  wire       [0:0]    _zz_execute_to_memory_ENV_CTRL_1;
  wire       [0:0]    decode_ENV_CTRL;
  wire       [0:0]    _zz_decode_ENV_CTRL;
  wire       [0:0]    _zz_decode_to_execute_ENV_CTRL;
  wire       [0:0]    _zz_decode_to_execute_ENV_CTRL_1;
  wire                decode_IS_CSR;
  wire       [1:0]    _zz_decode_to_execute_BRANCH_CTRL;
  wire       [1:0]    _zz_decode_to_execute_BRANCH_CTRL_1;
  wire                decode_IS_RS2_SIGNED;
  wire                decode_IS_RS1_SIGNED;
  wire                decode_IS_DIV;
  wire                memory_IS_MUL;
  wire                execute_IS_MUL;
  wire                decode_IS_MUL;
  wire       [1:0]    _zz_execute_to_memory_SHIFT_CTRL;
  wire       [1:0]    _zz_execute_to_memory_SHIFT_CTRL_1;
  wire       [1:0]    decode_SHIFT_CTRL;
  wire       [1:0]    _zz_decode_SHIFT_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SHIFT_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SHIFT_CTRL_1;
  wire       [1:0]    decode_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_decode_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
  wire                decode_SRC_LESS_UNSIGNED;
  wire                decode_MEMORY_STORE;
  wire                execute_BYPASSABLE_MEMORY_STAGE;
  wire                decode_BYPASSABLE_MEMORY_STAGE;
  wire                decode_BYPASSABLE_EXECUTE_STAGE;
  wire       [1:0]    decode_SRC2_CTRL;
  wire       [1:0]    _zz_decode_SRC2_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC2_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC2_CTRL_1;
  wire       [1:0]    decode_ALU_CTRL;
  wire       [1:0]    _zz_decode_ALU_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_CTRL_1;
  wire                decode_MEMORY_ENABLE;
  wire       [1:0]    decode_SRC1_CTRL;
  wire       [1:0]    _zz_decode_SRC1_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC1_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC1_CTRL_1;
  wire       [31:0]   writeBack_FORMAL_PC_NEXT;
  wire       [31:0]   memory_FORMAL_PC_NEXT;
  wire       [31:0]   execute_FORMAL_PC_NEXT;
  wire       [31:0]   decode_FORMAL_PC_NEXT;
  wire       [31:0]   memory_PC;
  wire                execute_CSR_READ_OPCODE;
  wire                execute_CSR_WRITE_OPCODE;
  wire                execute_IS_CSR;
  wire       [0:0]    memory_ENV_CTRL;
  wire       [0:0]    _zz_memory_ENV_CTRL;
  wire       [0:0]    execute_ENV_CTRL;
  wire       [0:0]    _zz_execute_ENV_CTRL;
  wire       [0:0]    writeBack_ENV_CTRL;
  wire       [0:0]    _zz_writeBack_ENV_CTRL;
  wire       [31:0]   memory_BRANCH_CALC;
  wire                memory_BRANCH_DO;
  wire       [31:0]   execute_PC;
  wire                execute_PREDICTION_HAD_BRANCHED1;
  wire                execute_BRANCH_COND_RESULT;
  wire       [1:0]    execute_BRANCH_CTRL;
  wire       [1:0]    _zz_execute_BRANCH_CTRL;
  wire                decode_RS2_USE;
  wire                decode_RS1_USE;
  reg        [31:0]   _zz_decode_RS2;
  wire                execute_REGFILE_WRITE_VALID;
  wire                execute_BYPASSABLE_EXECUTE_STAGE;
  wire                memory_REGFILE_WRITE_VALID;
  wire                memory_BYPASSABLE_MEMORY_STAGE;
  wire                writeBack_REGFILE_WRITE_VALID;
  reg        [31:0]   decode_RS2;
  reg        [31:0]   decode_RS1;
  wire                execute_IS_RS1_SIGNED;
  wire                execute_IS_DIV;
  wire                execute_IS_RS2_SIGNED;
  wire       [31:0]   memory_INSTRUCTION;
  wire                memory_IS_DIV;
  wire                writeBack_IS_MUL;
  wire       [33:0]   writeBack_MUL_HH;
  wire       [51:0]   writeBack_MUL_LOW;
  wire       [33:0]   memory_MUL_HL;
  wire       [33:0]   memory_MUL_LH;
  wire       [31:0]   memory_MUL_LL;
  (* keep , syn_keep *) wire       [31:0]   execute_RS1 /* synthesis syn_keep = 1 */ ;
  wire       [31:0]   memory_SHIFT_RIGHT;
  reg        [31:0]   _zz_decode_RS2_1;
  wire       [1:0]    memory_SHIFT_CTRL;
  wire       [1:0]    _zz_memory_SHIFT_CTRL;
  wire       [1:0]    execute_SHIFT_CTRL;
  wire       [1:0]    _zz_execute_SHIFT_CTRL;
  wire                execute_SRC_LESS_UNSIGNED;
  wire                execute_SRC2_FORCE_ZERO;
  wire                execute_SRC_USE_SUB_LESS;
  wire       [31:0]   _zz_execute_to_memory_PC;
  wire       [1:0]    execute_SRC2_CTRL;
  wire       [1:0]    _zz_execute_SRC2_CTRL;
  wire       [1:0]    execute_SRC1_CTRL;
  wire       [1:0]    _zz_execute_SRC1_CTRL;
  wire                decode_SRC_USE_SUB_LESS;
  wire                decode_SRC_ADD_ZERO;
  wire       [31:0]   execute_SRC_ADD_SUB;
  wire                execute_SRC_LESS;
  wire       [1:0]    execute_ALU_CTRL;
  wire       [1:0]    _zz_execute_ALU_CTRL;
  wire       [31:0]   execute_SRC2;
  wire       [31:0]   execute_SRC1;
  wire       [1:0]    execute_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_execute_ALU_BITWISE_CTRL;
  wire       [31:0]   _zz_lastStageRegFileWrite_payload_address;
  wire                _zz_lastStageRegFileWrite_valid;
  reg                 _zz_1;
  wire       [31:0]   decode_INSTRUCTION_ANTICIPATED;
  reg                 decode_REGFILE_WRITE_VALID;
  wire                decode_LEGAL_INSTRUCTION;
  wire       [0:0]    _zz_decode_ENV_CTRL_1;
  wire       [1:0]    _zz_decode_BRANCH_CTRL;
  wire       [1:0]    _zz_decode_SHIFT_CTRL_1;
  wire       [1:0]    _zz_decode_ALU_BITWISE_CTRL_1;
  wire       [1:0]    _zz_decode_SRC2_CTRL_1;
  wire       [1:0]    _zz_decode_ALU_CTRL_1;
  wire       [1:0]    _zz_decode_SRC1_CTRL_1;
  reg        [31:0]   _zz_decode_RS2_2;
  wire                writeBack_MEMORY_ENABLE;
  wire       [1:0]    writeBack_MEMORY_ADDRESS_LOW;
  wire       [31:0]   writeBack_MEMORY_READ_DATA;
  wire                memory_ALIGNEMENT_FAULT;
  wire       [31:0]   memory_REGFILE_WRITE_DATA;
  wire                memory_MEMORY_STORE;
  wire                memory_MEMORY_ENABLE;
  wire       [31:0]   execute_SRC_ADD;
  (* keep , syn_keep *) wire       [31:0]   execute_RS2 /* synthesis syn_keep = 1 */ ;
  wire       [31:0]   execute_INSTRUCTION;
  wire                execute_MEMORY_STORE;
  wire                execute_MEMORY_ENABLE;
  wire                execute_ALIGNEMENT_FAULT;
  wire       [1:0]    decode_BRANCH_CTRL;
  wire       [1:0]    _zz_decode_BRANCH_CTRL_1;
  reg        [31:0]   _zz_memory_to_writeBack_FORMAL_PC_NEXT;
  reg        [31:0]   _zz_decode_to_execute_FORMAL_PC_NEXT;
  wire       [31:0]   decode_PC;
  wire       [31:0]   decode_INSTRUCTION;
  wire       [31:0]   writeBack_PC;
  wire       [31:0]   writeBack_INSTRUCTION;
  wire                decode_arbitration_haltItself;
  reg                 decode_arbitration_haltByOther;
  reg                 decode_arbitration_removeIt;
  wire                decode_arbitration_flushIt;
  reg                 decode_arbitration_flushNext;
  reg                 decode_arbitration_isValid;
  wire                decode_arbitration_isStuck;
  wire                decode_arbitration_isStuckByOthers;
  wire                decode_arbitration_isFlushed;
  wire                decode_arbitration_isMoving;
  wire                decode_arbitration_isFiring;
  reg                 execute_arbitration_haltItself;
  wire                execute_arbitration_haltByOther;
  reg                 execute_arbitration_removeIt;
  wire                execute_arbitration_flushIt;
  wire                execute_arbitration_flushNext;
  reg                 execute_arbitration_isValid;
  wire                execute_arbitration_isStuck;
  wire                execute_arbitration_isStuckByOthers;
  wire                execute_arbitration_isFlushed;
  wire                execute_arbitration_isMoving;
  wire                execute_arbitration_isFiring;
  reg                 memory_arbitration_haltItself;
  wire                memory_arbitration_haltByOther;
  reg                 memory_arbitration_removeIt;
  wire                memory_arbitration_flushIt;
  reg                 memory_arbitration_flushNext;
  reg                 memory_arbitration_isValid;
  wire                memory_arbitration_isStuck;
  wire                memory_arbitration_isStuckByOthers;
  wire                memory_arbitration_isFlushed;
  wire                memory_arbitration_isMoving;
  wire                memory_arbitration_isFiring;
  wire                writeBack_arbitration_haltItself;
  wire                writeBack_arbitration_haltByOther;
  reg                 writeBack_arbitration_removeIt;
  wire                writeBack_arbitration_flushIt;
  reg                 writeBack_arbitration_flushNext;
  reg                 writeBack_arbitration_isValid;
  wire                writeBack_arbitration_isStuck;
  wire                writeBack_arbitration_isStuckByOthers;
  wire                writeBack_arbitration_isFlushed;
  wire                writeBack_arbitration_isMoving;
  wire                writeBack_arbitration_isFiring;
  wire       [31:0]   lastStageInstruction /* verilator public */ ;
  wire       [31:0]   lastStagePc /* verilator public */ ;
  wire                lastStageIsValid /* verilator public */ ;
  wire                lastStageIsFiring /* verilator public */ ;
  reg                 IBusSimplePlugin_fetcherHalt;
  wire                IBusSimplePlugin_forceNoDecodeCond;
  reg                 IBusSimplePlugin_incomingInstruction;
  wire                IBusSimplePlugin_predictionJumpInterface_valid;
  (* keep , syn_keep *) wire       [31:0]   IBusSimplePlugin_predictionJumpInterface_payload /* synthesis syn_keep = 1 */ ;
  reg                 IBusSimplePlugin_decodePrediction_cmd_hadBranch;
  wire                IBusSimplePlugin_decodePrediction_rsp_wasWrong;
  wire                IBusSimplePlugin_pcValids_0;
  wire                IBusSimplePlugin_pcValids_1;
  wire                IBusSimplePlugin_pcValids_2;
  wire                IBusSimplePlugin_pcValids_3;
  wire                IBusSimplePlugin_decodeExceptionPort_valid;
  reg        [3:0]    IBusSimplePlugin_decodeExceptionPort_payload_code;
  wire       [31:0]   IBusSimplePlugin_decodeExceptionPort_payload_badAddr;
  reg                 DBusSimplePlugin_memoryExceptionPort_valid;
  reg        [3:0]    DBusSimplePlugin_memoryExceptionPort_payload_code;
  wire       [31:0]   DBusSimplePlugin_memoryExceptionPort_payload_badAddr;
  wire                decodeExceptionPort_valid;
  wire       [3:0]    decodeExceptionPort_payload_code;
  wire       [31:0]   decodeExceptionPort_payload_badAddr;
  wire                BranchPlugin_jumpInterface_valid;
  wire       [31:0]   BranchPlugin_jumpInterface_payload;
  wire                BranchPlugin_branchExceptionPort_valid;
  wire       [3:0]    BranchPlugin_branchExceptionPort_payload_code;
  wire       [31:0]   BranchPlugin_branchExceptionPort_payload_badAddr;
  wire                BranchPlugin_inDebugNoFetchFlag;
  wire       [31:0]   CsrPlugin_csrMapping_readDataSignal;
  wire       [31:0]   CsrPlugin_csrMapping_readDataInit;
  wire       [31:0]   CsrPlugin_csrMapping_writeDataSignal;
  reg                 CsrPlugin_csrMapping_allowCsrSignal;
  wire                CsrPlugin_csrMapping_hazardFree;
  wire                CsrPlugin_csrMapping_doForceFailCsr;
  wire                CsrPlugin_inWfi /* verilator public */ ;
  wire                CsrPlugin_thirdPartyWake;
  reg                 CsrPlugin_jumpInterface_valid;
  reg        [31:0]   CsrPlugin_jumpInterface_payload;
  wire                CsrPlugin_exceptionPendings_0;
  wire                CsrPlugin_exceptionPendings_1;
  wire                CsrPlugin_exceptionPendings_2;
  wire                CsrPlugin_exceptionPendings_3;
  wire                contextSwitching;
  reg        [1:0]    CsrPlugin_privilege;
  wire                CsrPlugin_forceMachineWire;
  wire                CsrPlugin_allowInterrupts;
  wire                CsrPlugin_allowException;
  wire                CsrPlugin_allowEbreakException;
  wire                CsrPlugin_xretAwayFromMachine;
  wire                IBusSimplePlugin_externalFlush;
  wire                IBusSimplePlugin_jump_pcLoad_valid;
  wire       [31:0]   IBusSimplePlugin_jump_pcLoad_payload;
  wire       [2:0]    _zz_IBusSimplePlugin_jump_pcLoad_payload;
  wire       [2:0]    _zz_IBusSimplePlugin_jump_pcLoad_payload_1;
  wire                _zz_IBusSimplePlugin_jump_pcLoad_payload_2;
  wire                _zz_IBusSimplePlugin_jump_pcLoad_payload_3;
  wire                IBusSimplePlugin_fetchPc_output_valid;
  wire                IBusSimplePlugin_fetchPc_output_ready;
  wire       [31:0]   IBusSimplePlugin_fetchPc_output_payload;
  reg        [31:0]   IBusSimplePlugin_fetchPc_pcReg /* verilator public */ ;
  reg                 IBusSimplePlugin_fetchPc_correction;
  reg                 IBusSimplePlugin_fetchPc_correctionReg;
  wire                IBusSimplePlugin_fetchPc_output_fire;
  wire                IBusSimplePlugin_fetchPc_corrected;
  reg                 IBusSimplePlugin_fetchPc_pcRegPropagate;
  reg                 IBusSimplePlugin_fetchPc_booted;
  reg                 IBusSimplePlugin_fetchPc_inc;
  wire                when_Fetcher_l133;
  wire                when_Fetcher_l133_1;
  reg        [31:0]   IBusSimplePlugin_fetchPc_pc;
  reg                 IBusSimplePlugin_fetchPc_flushed;
  wire                when_Fetcher_l160;
  wire                IBusSimplePlugin_iBusRsp_redoFetch;
  wire                IBusSimplePlugin_iBusRsp_stages_0_input_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  wire                IBusSimplePlugin_iBusRsp_stages_0_output_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_0_output_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_stages_0_output_payload;
  reg                 IBusSimplePlugin_iBusRsp_stages_0_halt;
  wire                IBusSimplePlugin_iBusRsp_stages_1_input_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_1_input_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  wire                IBusSimplePlugin_iBusRsp_stages_1_output_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_1_output_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_stages_1_output_payload;
  wire                IBusSimplePlugin_iBusRsp_stages_1_halt;
  wire                _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  wire                IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_payload;
  wire                _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready;
  wire                IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_payload;
  wire                IBusSimplePlugin_iBusRsp_flush;
  wire                IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_ready;
  wire                IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid;
  wire                IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_ready;
  reg                 _zz_IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid;
  reg                 IBusSimplePlugin_iBusRsp_readyForError;
  wire                IBusSimplePlugin_iBusRsp_output_valid;
  wire                IBusSimplePlugin_iBusRsp_output_ready;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_output_payload_pc;
  wire                IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
  wire       [31:0]   IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
  wire                IBusSimplePlugin_iBusRsp_output_payload_isRvc;
  wire                IBusSimplePlugin_injector_decodeInput_valid;
  wire                IBusSimplePlugin_injector_decodeInput_ready;
  wire       [31:0]   IBusSimplePlugin_injector_decodeInput_payload_pc;
  wire                IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
  wire       [31:0]   IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  wire                IBusSimplePlugin_injector_decodeInput_payload_isRvc;
  reg                 _zz_IBusSimplePlugin_injector_decodeInput_valid;
  reg        [31:0]   _zz_IBusSimplePlugin_injector_decodeInput_payload_pc;
  reg                 _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
  reg        [31:0]   _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  reg                 _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc;
  wire                when_Fetcher_l322;
  reg                 IBusSimplePlugin_injector_nextPcCalc_valids_0;
  wire                when_Fetcher_l331;
  reg                 IBusSimplePlugin_injector_nextPcCalc_valids_1;
  wire                when_Fetcher_l331_1;
  reg                 IBusSimplePlugin_injector_nextPcCalc_valids_2;
  wire                when_Fetcher_l331_2;
  reg                 IBusSimplePlugin_injector_nextPcCalc_valids_3;
  wire                when_Fetcher_l331_3;
  reg                 IBusSimplePlugin_injector_nextPcCalc_valids_4;
  wire                when_Fetcher_l331_4;
  reg        [31:0]   IBusSimplePlugin_injector_formal_rawInDecode;
  wire                _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
  reg        [18:0]   _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1;
  wire                _zz_2;
  reg        [10:0]   _zz_3;
  wire                _zz_4;
  reg        [18:0]   _zz_5;
  reg                 _zz_6;
  wire                _zz_IBusSimplePlugin_predictionJumpInterface_payload;
  reg        [10:0]   _zz_IBusSimplePlugin_predictionJumpInterface_payload_1;
  wire                _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
  reg        [18:0]   _zz_IBusSimplePlugin_predictionJumpInterface_payload_3;
  wire                IBusSimplePlugin_cmd_valid;
  wire                IBusSimplePlugin_cmd_ready;
  wire       [31:0]   IBusSimplePlugin_cmd_payload_pc;
  wire                IBusSimplePlugin_cmd_s2mPipe_valid;
  wire                IBusSimplePlugin_cmd_s2mPipe_ready;
  wire       [31:0]   IBusSimplePlugin_cmd_s2mPipe_payload_pc;
  reg                 IBusSimplePlugin_cmd_rValidN;
  reg        [31:0]   IBusSimplePlugin_cmd_rData_pc;
  wire                IBusSimplePlugin_pending_inc;
  wire                IBusSimplePlugin_pending_dec;
  reg        [2:0]    IBusSimplePlugin_pending_value;
  wire       [2:0]    IBusSimplePlugin_pending_next;
  wire                IBusSimplePlugin_cmdFork_canEmit;
  wire                when_IBusSimplePlugin_l306;
  wire                IBusSimplePlugin_cmd_fire;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_output_valid;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_output_ready;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error;
  wire       [31:0]   IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst;
  reg        [2:0]    IBusSimplePlugin_rspJoin_rspBuffer_discardCounter;
  wire                iBus_rsp_toStream_valid;
  wire                iBus_rsp_toStream_ready;
  wire                iBus_rsp_toStream_payload_error;
  wire       [31:0]   iBus_rsp_toStream_payload_inst;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_flush;
  wire                IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire;
  wire       [31:0]   IBusSimplePlugin_rspJoin_fetchRsp_pc;
  reg                 IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  wire       [31:0]   IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  wire                IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  wire                when_IBusSimplePlugin_l378;
  wire                IBusSimplePlugin_rspJoin_join_valid;
  wire                IBusSimplePlugin_rspJoin_join_ready;
  wire       [31:0]   IBusSimplePlugin_rspJoin_join_payload_pc;
  wire                IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  wire       [31:0]   IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  wire                IBusSimplePlugin_rspJoin_join_payload_isRvc;
  reg                 IBusSimplePlugin_rspJoin_exceptionDetected;
  wire                IBusSimplePlugin_rspJoin_join_fire;
  wire                _zz_IBusSimplePlugin_rspJoin_join_ready;
  wire                IBusSimplePlugin_rspJoin_join_haltWhen_valid;
  wire                IBusSimplePlugin_rspJoin_join_haltWhen_ready;
  wire       [31:0]   IBusSimplePlugin_rspJoin_join_haltWhen_payload_pc;
  wire                IBusSimplePlugin_rspJoin_join_haltWhen_payload_rsp_error;
  wire       [31:0]   IBusSimplePlugin_rspJoin_join_haltWhen_payload_rsp_inst;
  wire                IBusSimplePlugin_rspJoin_join_haltWhen_payload_isRvc;
  wire                when_IBusSimplePlugin_l404;
  wire                _zz_dBus_cmd_valid;
  reg                 execute_DBusSimplePlugin_skipCmd;
  reg        [31:0]   _zz_dBus_cmd_payload_data;
  wire                when_DBusSimplePlugin_l435;
  reg        [3:0]    _zz_execute_DBusSimplePlugin_formalMask;
  wire       [3:0]    execute_DBusSimplePlugin_formalMask;
  wire                when_DBusSimplePlugin_l490;
  wire                when_DBusSimplePlugin_l497;
  wire                when_DBusSimplePlugin_l523;
  reg        [31:0]   writeBack_DBusSimplePlugin_rspShifted;
  wire       [1:0]    switch_Misc_l245;
  wire                _zz_writeBack_DBusSimplePlugin_rspFormated;
  reg        [31:0]   _zz_writeBack_DBusSimplePlugin_rspFormated_1;
  wire                _zz_writeBack_DBusSimplePlugin_rspFormated_2;
  reg        [31:0]   _zz_writeBack_DBusSimplePlugin_rspFormated_3;
  reg        [31:0]   writeBack_DBusSimplePlugin_rspFormated;
  wire                when_DBusSimplePlugin_l566;
  wire       [28:0]   _zz_decode_IS_CSR;
  wire                _zz_decode_IS_CSR_1;
  wire                _zz_decode_IS_CSR_2;
  wire                _zz_decode_IS_CSR_3;
  wire                _zz_decode_IS_CSR_4;
  wire                _zz_decode_IS_CSR_5;
  wire       [1:0]    _zz_decode_SRC1_CTRL_2;
  wire       [1:0]    _zz_decode_ALU_CTRL_2;
  wire       [1:0]    _zz_decode_SRC2_CTRL_2;
  wire       [1:0]    _zz_decode_ALU_BITWISE_CTRL_2;
  wire       [1:0]    _zz_decode_SHIFT_CTRL_2;
  wire       [1:0]    _zz_decode_BRANCH_CTRL_2;
  wire       [0:0]    _zz_decode_ENV_CTRL_2;
  wire                when_RegFilePlugin_l63;
  wire       [4:0]    decode_RegFilePlugin_regFileReadAddress1;
  wire       [4:0]    decode_RegFilePlugin_regFileReadAddress2;
  wire       [31:0]   decode_RegFilePlugin_rs1Data;
  wire       [31:0]   decode_RegFilePlugin_rs2Data;
  reg                 lastStageRegFileWrite_valid /* verilator public */ ;
  reg        [4:0]    lastStageRegFileWrite_payload_address /* verilator public */ ;
  reg        [31:0]   lastStageRegFileWrite_payload_data /* verilator public */ ;
  reg                 _zz_10;
  reg        [31:0]   execute_IntAluPlugin_bitwise;
  reg        [31:0]   _zz_execute_REGFILE_WRITE_DATA;
  reg        [31:0]   _zz_execute_SRC1;
  wire                _zz_execute_SRC2;
  reg        [19:0]   _zz_execute_SRC2_1;
  wire                _zz_execute_SRC2_2;
  reg        [19:0]   _zz_execute_SRC2_3;
  reg        [31:0]   _zz_execute_SRC2_4;
  reg        [31:0]   execute_SrcPlugin_addSub;
  wire                execute_SrcPlugin_less;
  wire       [4:0]    execute_FullBarrelShifterPlugin_amplitude;
  reg        [31:0]   _zz_execute_FullBarrelShifterPlugin_reversed;
  wire       [31:0]   execute_FullBarrelShifterPlugin_reversed;
  reg        [31:0]   _zz_decode_RS2_3;
  reg                 execute_MulPlugin_aSigned;
  reg                 execute_MulPlugin_bSigned;
  wire       [31:0]   execute_MulPlugin_a;
  wire       [31:0]   execute_MulPlugin_b;
  wire       [1:0]    switch_MulPlugin_l87;
  wire       [15:0]   execute_MulPlugin_aULow;
  wire       [15:0]   execute_MulPlugin_bULow;
  wire       [16:0]   execute_MulPlugin_aSLow;
  wire       [16:0]   execute_MulPlugin_bSLow;
  wire       [16:0]   execute_MulPlugin_aHigh;
  wire       [16:0]   execute_MulPlugin_bHigh;
  wire       [65:0]   writeBack_MulPlugin_result;
  wire                when_MulPlugin_l147;
  wire       [1:0]    switch_MulPlugin_l148;
  reg        [32:0]   memory_DivPlugin_rs1;
  reg        [31:0]   memory_DivPlugin_rs2;
  reg        [64:0]   memory_DivPlugin_accumulator;
  wire                memory_DivPlugin_frontendOk;
  reg                 memory_DivPlugin_div_needRevert;
  reg                 memory_DivPlugin_div_counter_willIncrement;
  reg                 memory_DivPlugin_div_counter_willClear;
  reg        [5:0]    memory_DivPlugin_div_counter_valueNext;
  reg        [5:0]    memory_DivPlugin_div_counter_value;
  wire                memory_DivPlugin_div_counter_willOverflowIfInc;
  wire                memory_DivPlugin_div_counter_willOverflow;
  reg                 memory_DivPlugin_div_done;
  wire                when_MulDivIterativePlugin_l126;
  wire                when_MulDivIterativePlugin_l126_1;
  reg        [31:0]   memory_DivPlugin_div_result;
  wire                when_MulDivIterativePlugin_l128;
  wire                when_MulDivIterativePlugin_l129;
  wire                when_MulDivIterativePlugin_l132;
  wire       [31:0]   _zz_memory_DivPlugin_div_stage_0_remainderShifted;
  wire       [32:0]   memory_DivPlugin_div_stage_0_remainderShifted;
  wire       [32:0]   memory_DivPlugin_div_stage_0_remainderMinusDenominator;
  wire       [31:0]   memory_DivPlugin_div_stage_0_outRemainder;
  wire       [31:0]   memory_DivPlugin_div_stage_0_outNumerator;
  wire                when_MulDivIterativePlugin_l151;
  wire       [31:0]   _zz_memory_DivPlugin_div_result;
  wire                when_MulDivIterativePlugin_l162;
  wire                _zz_memory_DivPlugin_rs2;
  wire                _zz_memory_DivPlugin_rs1;
  reg        [32:0]   _zz_memory_DivPlugin_rs1_1;
  reg                 HazardSimplePlugin_src0Hazard;
  reg                 HazardSimplePlugin_src1Hazard;
  wire                HazardSimplePlugin_writeBackWrites_valid;
  wire       [4:0]    HazardSimplePlugin_writeBackWrites_payload_address;
  wire       [31:0]   HazardSimplePlugin_writeBackWrites_payload_data;
  reg                 HazardSimplePlugin_writeBackBuffer_valid;
  reg        [4:0]    HazardSimplePlugin_writeBackBuffer_payload_address;
  reg        [31:0]   HazardSimplePlugin_writeBackBuffer_payload_data;
  wire                HazardSimplePlugin_addr0Match;
  wire                HazardSimplePlugin_addr1Match;
  wire                when_HazardSimplePlugin_l47;
  wire                when_HazardSimplePlugin_l48;
  wire                when_HazardSimplePlugin_l51;
  wire                when_HazardSimplePlugin_l45;
  wire                when_HazardSimplePlugin_l57;
  wire                when_HazardSimplePlugin_l58;
  wire                when_HazardSimplePlugin_l48_1;
  wire                when_HazardSimplePlugin_l51_1;
  wire                when_HazardSimplePlugin_l45_1;
  wire                when_HazardSimplePlugin_l57_1;
  wire                when_HazardSimplePlugin_l58_1;
  wire                when_HazardSimplePlugin_l48_2;
  wire                when_HazardSimplePlugin_l51_2;
  wire                when_HazardSimplePlugin_l45_2;
  wire                when_HazardSimplePlugin_l57_2;
  wire                when_HazardSimplePlugin_l58_2;
  wire                when_HazardSimplePlugin_l105;
  wire                when_HazardSimplePlugin_l108;
  wire                when_HazardSimplePlugin_l113;
  wire                execute_BranchPlugin_eq;
  wire       [2:0]    switch_Misc_l245_1;
  reg                 _zz_execute_BRANCH_COND_RESULT;
  reg                 _zz_execute_BRANCH_COND_RESULT_1;
  wire                _zz_execute_BranchPlugin_missAlignedTarget;
  reg        [19:0]   _zz_execute_BranchPlugin_missAlignedTarget_1;
  wire                _zz_execute_BranchPlugin_missAlignedTarget_2;
  reg        [10:0]   _zz_execute_BranchPlugin_missAlignedTarget_3;
  wire                _zz_execute_BranchPlugin_missAlignedTarget_4;
  reg        [18:0]   _zz_execute_BranchPlugin_missAlignedTarget_5;
  reg                 _zz_execute_BranchPlugin_missAlignedTarget_6;
  wire                execute_BranchPlugin_missAlignedTarget;
  reg        [31:0]   execute_BranchPlugin_branch_src1;
  reg        [31:0]   execute_BranchPlugin_branch_src2;
  wire                _zz_execute_BranchPlugin_branch_src2;
  reg        [19:0]   _zz_execute_BranchPlugin_branch_src2_1;
  wire                _zz_execute_BranchPlugin_branch_src2_2;
  reg        [10:0]   _zz_execute_BranchPlugin_branch_src2_3;
  wire                _zz_execute_BranchPlugin_branch_src2_4;
  reg        [18:0]   _zz_execute_BranchPlugin_branch_src2_5;
  wire       [31:0]   execute_BranchPlugin_branchAdder;
  wire       [1:0]    CsrPlugin_misa_base;
  wire       [25:0]   CsrPlugin_misa_extensions;
  wire       [1:0]    CsrPlugin_mtvec_mode;
  wire       [29:0]   CsrPlugin_mtvec_base;
  reg        [31:0]   CsrPlugin_mepc;
  reg                 CsrPlugin_mstatus_MIE;
  reg                 CsrPlugin_mstatus_MPIE;
  reg        [1:0]    CsrPlugin_mstatus_MPP;
  reg                 CsrPlugin_mip_MEIP;
  reg                 CsrPlugin_mip_MTIP;
  reg                 CsrPlugin_mip_MSIP;
  reg                 CsrPlugin_mie_MEIE;
  reg                 CsrPlugin_mie_MTIE;
  reg                 CsrPlugin_mie_MSIE;
  reg                 CsrPlugin_mcause_interrupt;
  reg        [3:0]    CsrPlugin_mcause_exceptionCode;
  reg        [31:0]   CsrPlugin_mtval;
  reg        [63:0]   CsrPlugin_mcycle;
  reg        [63:0]   CsrPlugin_minstret;
  wire                _zz_when_CsrPlugin_l1302;
  wire                _zz_when_CsrPlugin_l1302_1;
  wire                _zz_when_CsrPlugin_l1302_2;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
  reg                 CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
  reg        [3:0]    CsrPlugin_exceptionPortCtrl_exceptionContext_code;
  reg        [31:0]   CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
  wire       [1:0]    CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped;
  wire       [1:0]    CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
  wire       [1:0]    _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code;
  wire                _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1;
  wire       [1:0]    _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_2;
  wire                _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3;
  wire                when_CsrPlugin_l1259;
  wire                when_CsrPlugin_l1259_1;
  wire                when_CsrPlugin_l1259_2;
  wire                when_CsrPlugin_l1259_3;
  wire                when_CsrPlugin_l1272;
  reg                 CsrPlugin_interrupt_valid;
  reg        [3:0]    CsrPlugin_interrupt_code /* verilator public */ ;
  reg        [1:0]    CsrPlugin_interrupt_targetPrivilege;
  wire                when_CsrPlugin_l1296;
  wire                when_CsrPlugin_l1302;
  wire                when_CsrPlugin_l1302_1;
  wire                when_CsrPlugin_l1302_2;
  wire                CsrPlugin_exception;
  wire                CsrPlugin_lastStageWasWfi;
  reg                 CsrPlugin_pipelineLiberator_pcValids_0;
  reg                 CsrPlugin_pipelineLiberator_pcValids_1;
  reg                 CsrPlugin_pipelineLiberator_pcValids_2;
  wire                CsrPlugin_pipelineLiberator_active;
  wire                when_CsrPlugin_l1335;
  wire                when_CsrPlugin_l1335_1;
  wire                when_CsrPlugin_l1335_2;
  wire                when_CsrPlugin_l1340;
  reg                 CsrPlugin_pipelineLiberator_done;
  wire                when_CsrPlugin_l1346;
  wire                CsrPlugin_interruptJump /* verilator public */ ;
  reg                 CsrPlugin_hadException /* verilator public */ ;
  reg        [1:0]    CsrPlugin_targetPrivilege;
  reg        [3:0]    CsrPlugin_trapCause;
  wire                CsrPlugin_trapCauseEbreakDebug;
  reg        [1:0]    CsrPlugin_xtvec_mode;
  reg        [29:0]   CsrPlugin_xtvec_base;
  wire                CsrPlugin_trapEnterDebug;
  wire                when_CsrPlugin_l1390;
  wire                when_CsrPlugin_l1398;
  wire                when_CsrPlugin_l1456;
  wire       [1:0]    switch_CsrPlugin_l1460;
  reg                 execute_CsrPlugin_wfiWake;
  wire                when_CsrPlugin_l1527;
  wire                execute_CsrPlugin_blockedBySideEffects;
  reg                 execute_CsrPlugin_illegalAccess;
  reg                 execute_CsrPlugin_illegalInstruction;
  wire                when_CsrPlugin_l1547;
  wire                when_CsrPlugin_l1548;
  reg                 execute_CsrPlugin_writeInstruction;
  reg                 execute_CsrPlugin_readInstruction;
  wire                execute_CsrPlugin_writeEnable;
  wire                execute_CsrPlugin_readEnable;
  wire       [31:0]   execute_CsrPlugin_readToWriteData;
  wire                switch_Misc_l245_2;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_writeDataSignal;
  wire                when_CsrPlugin_l1587;
  wire                when_CsrPlugin_l1591;
  wire       [11:0]   execute_CsrPlugin_csrAddress;
  wire                when_Pipeline_l124;
  reg        [31:0]   decode_to_execute_PC;
  wire                when_Pipeline_l124_1;
  reg        [31:0]   execute_to_memory_PC;
  wire                when_Pipeline_l124_2;
  reg        [31:0]   memory_to_writeBack_PC;
  wire                when_Pipeline_l124_3;
  reg        [31:0]   decode_to_execute_INSTRUCTION;
  wire                when_Pipeline_l124_4;
  reg        [31:0]   execute_to_memory_INSTRUCTION;
  wire                when_Pipeline_l124_5;
  reg        [31:0]   memory_to_writeBack_INSTRUCTION;
  wire                when_Pipeline_l124_6;
  reg        [31:0]   decode_to_execute_FORMAL_PC_NEXT;
  wire                when_Pipeline_l124_7;
  reg        [31:0]   execute_to_memory_FORMAL_PC_NEXT;
  wire                when_Pipeline_l124_8;
  reg        [31:0]   memory_to_writeBack_FORMAL_PC_NEXT;
  wire                when_Pipeline_l124_9;
  reg        [1:0]    decode_to_execute_SRC1_CTRL;
  wire                when_Pipeline_l124_10;
  reg                 decode_to_execute_SRC_USE_SUB_LESS;
  wire                when_Pipeline_l124_11;
  reg                 decode_to_execute_MEMORY_ENABLE;
  wire                when_Pipeline_l124_12;
  reg                 execute_to_memory_MEMORY_ENABLE;
  wire                when_Pipeline_l124_13;
  reg                 memory_to_writeBack_MEMORY_ENABLE;
  wire                when_Pipeline_l124_14;
  reg        [1:0]    decode_to_execute_ALU_CTRL;
  wire                when_Pipeline_l124_15;
  reg        [1:0]    decode_to_execute_SRC2_CTRL;
  wire                when_Pipeline_l124_16;
  reg                 decode_to_execute_REGFILE_WRITE_VALID;
  wire                when_Pipeline_l124_17;
  reg                 execute_to_memory_REGFILE_WRITE_VALID;
  wire                when_Pipeline_l124_18;
  reg                 memory_to_writeBack_REGFILE_WRITE_VALID;
  wire                when_Pipeline_l124_19;
  reg                 decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  wire                when_Pipeline_l124_20;
  reg                 decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  wire                when_Pipeline_l124_21;
  reg                 execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  wire                when_Pipeline_l124_22;
  reg                 decode_to_execute_MEMORY_STORE;
  wire                when_Pipeline_l124_23;
  reg                 execute_to_memory_MEMORY_STORE;
  wire                when_Pipeline_l124_24;
  reg                 decode_to_execute_SRC_LESS_UNSIGNED;
  wire                when_Pipeline_l124_25;
  reg        [1:0]    decode_to_execute_ALU_BITWISE_CTRL;
  wire                when_Pipeline_l124_26;
  reg        [1:0]    decode_to_execute_SHIFT_CTRL;
  wire                when_Pipeline_l124_27;
  reg        [1:0]    execute_to_memory_SHIFT_CTRL;
  wire                when_Pipeline_l124_28;
  reg                 decode_to_execute_IS_MUL;
  wire                when_Pipeline_l124_29;
  reg                 execute_to_memory_IS_MUL;
  wire                when_Pipeline_l124_30;
  reg                 memory_to_writeBack_IS_MUL;
  wire                when_Pipeline_l124_31;
  reg                 decode_to_execute_IS_DIV;
  wire                when_Pipeline_l124_32;
  reg                 execute_to_memory_IS_DIV;
  wire                when_Pipeline_l124_33;
  reg                 decode_to_execute_IS_RS1_SIGNED;
  wire                when_Pipeline_l124_34;
  reg                 decode_to_execute_IS_RS2_SIGNED;
  wire                when_Pipeline_l124_35;
  reg        [1:0]    decode_to_execute_BRANCH_CTRL;
  wire                when_Pipeline_l124_36;
  reg                 decode_to_execute_IS_CSR;
  wire                when_Pipeline_l124_37;
  reg        [0:0]    decode_to_execute_ENV_CTRL;
  wire                when_Pipeline_l124_38;
  reg        [0:0]    execute_to_memory_ENV_CTRL;
  wire                when_Pipeline_l124_39;
  reg        [0:0]    memory_to_writeBack_ENV_CTRL;
  wire                when_Pipeline_l124_40;
  reg        [31:0]   decode_to_execute_RS1;
  wire                when_Pipeline_l124_41;
  reg        [31:0]   decode_to_execute_RS2;
  wire                when_Pipeline_l124_42;
  reg                 decode_to_execute_SRC2_FORCE_ZERO;
  wire                when_Pipeline_l124_43;
  reg                 decode_to_execute_PREDICTION_HAD_BRANCHED1;
  wire                when_Pipeline_l124_44;
  reg                 decode_to_execute_CSR_WRITE_OPCODE;
  wire                when_Pipeline_l124_45;
  reg                 decode_to_execute_CSR_READ_OPCODE;
  wire                when_Pipeline_l124_46;
  reg                 execute_to_memory_ALIGNEMENT_FAULT;
  wire                when_Pipeline_l124_47;
  reg        [1:0]    execute_to_memory_MEMORY_ADDRESS_LOW;
  wire                when_Pipeline_l124_48;
  reg        [1:0]    memory_to_writeBack_MEMORY_ADDRESS_LOW;
  wire                when_Pipeline_l124_49;
  reg        [31:0]   execute_to_memory_REGFILE_WRITE_DATA;
  wire                when_Pipeline_l124_50;
  reg        [31:0]   memory_to_writeBack_REGFILE_WRITE_DATA;
  wire                when_Pipeline_l124_51;
  reg        [31:0]   execute_to_memory_SHIFT_RIGHT;
  wire                when_Pipeline_l124_52;
  reg        [31:0]   execute_to_memory_MUL_LL;
  wire                when_Pipeline_l124_53;
  reg        [33:0]   execute_to_memory_MUL_LH;
  wire                when_Pipeline_l124_54;
  reg        [33:0]   execute_to_memory_MUL_HL;
  wire                when_Pipeline_l124_55;
  reg        [33:0]   execute_to_memory_MUL_HH;
  wire                when_Pipeline_l124_56;
  reg        [33:0]   memory_to_writeBack_MUL_HH;
  wire                when_Pipeline_l124_57;
  reg                 execute_to_memory_BRANCH_DO;
  wire                when_Pipeline_l124_58;
  reg        [31:0]   execute_to_memory_BRANCH_CALC;
  wire                when_Pipeline_l124_59;
  reg        [31:0]   memory_to_writeBack_MEMORY_READ_DATA;
  wire                when_Pipeline_l124_60;
  reg        [51:0]   memory_to_writeBack_MUL_LOW;
  wire                when_Pipeline_l151;
  wire                when_Pipeline_l154;
  wire                when_Pipeline_l151_1;
  wire                when_Pipeline_l154_1;
  wire                when_Pipeline_l151_2;
  wire                when_Pipeline_l154_2;
  wire                when_CsrPlugin_l1669;
  reg                 execute_CsrPlugin_csr_768;
  wire                when_CsrPlugin_l1669_1;
  reg                 execute_CsrPlugin_csr_836;
  wire                when_CsrPlugin_l1669_2;
  reg                 execute_CsrPlugin_csr_772;
  wire                when_CsrPlugin_l1669_3;
  reg                 execute_CsrPlugin_csr_833;
  wire                when_CsrPlugin_l1669_4;
  reg                 execute_CsrPlugin_csr_834;
  wire                when_CsrPlugin_l1669_5;
  reg                 execute_CsrPlugin_csr_835;
  wire                when_CsrPlugin_l1669_6;
  reg                 execute_CsrPlugin_csr_2816;
  wire                when_CsrPlugin_l1669_7;
  reg                 execute_CsrPlugin_csr_2944;
  wire                when_CsrPlugin_l1669_8;
  reg                 execute_CsrPlugin_csr_2818;
  wire                when_CsrPlugin_l1669_9;
  reg                 execute_CsrPlugin_csr_2946;
  wire       [1:0]    switch_CsrPlugin_l1031;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_1;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_2;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_3;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_4;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_5;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_6;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_7;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_8;
  reg        [31:0]   _zz_CsrPlugin_csrMapping_readDataInit_9;
  wire                when_CsrPlugin_l1702;
  wire       [11:0]   _zz_when_CsrPlugin_l1709;
  wire                when_CsrPlugin_l1709;
  reg                 when_CsrPlugin_l1719;
  wire                when_CsrPlugin_l1717;
  wire                when_CsrPlugin_l1725;
  `ifndef SYNTHESIS
  reg [31:0] _zz_memory_to_writeBack_ENV_CTRL_string;
  reg [31:0] _zz_memory_to_writeBack_ENV_CTRL_1_string;
  reg [31:0] _zz_execute_to_memory_ENV_CTRL_string;
  reg [31:0] _zz_execute_to_memory_ENV_CTRL_1_string;
  reg [31:0] decode_ENV_CTRL_string;
  reg [31:0] _zz_decode_ENV_CTRL_string;
  reg [31:0] _zz_decode_to_execute_ENV_CTRL_string;
  reg [31:0] _zz_decode_to_execute_ENV_CTRL_1_string;
  reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_string;
  reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_1_string;
  reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_string;
  reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_1_string;
  reg [71:0] decode_SHIFT_CTRL_string;
  reg [71:0] _zz_decode_SHIFT_CTRL_string;
  reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_string;
  reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_1_string;
  reg [39:0] decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string;
  reg [23:0] decode_SRC2_CTRL_string;
  reg [23:0] _zz_decode_SRC2_CTRL_string;
  reg [23:0] _zz_decode_to_execute_SRC2_CTRL_string;
  reg [23:0] _zz_decode_to_execute_SRC2_CTRL_1_string;
  reg [63:0] decode_ALU_CTRL_string;
  reg [63:0] _zz_decode_ALU_CTRL_string;
  reg [63:0] _zz_decode_to_execute_ALU_CTRL_string;
  reg [63:0] _zz_decode_to_execute_ALU_CTRL_1_string;
  reg [95:0] decode_SRC1_CTRL_string;
  reg [95:0] _zz_decode_SRC1_CTRL_string;
  reg [95:0] _zz_decode_to_execute_SRC1_CTRL_string;
  reg [95:0] _zz_decode_to_execute_SRC1_CTRL_1_string;
  reg [31:0] memory_ENV_CTRL_string;
  reg [31:0] _zz_memory_ENV_CTRL_string;
  reg [31:0] execute_ENV_CTRL_string;
  reg [31:0] _zz_execute_ENV_CTRL_string;
  reg [31:0] writeBack_ENV_CTRL_string;
  reg [31:0] _zz_writeBack_ENV_CTRL_string;
  reg [31:0] execute_BRANCH_CTRL_string;
  reg [31:0] _zz_execute_BRANCH_CTRL_string;
  reg [71:0] memory_SHIFT_CTRL_string;
  reg [71:0] _zz_memory_SHIFT_CTRL_string;
  reg [71:0] execute_SHIFT_CTRL_string;
  reg [71:0] _zz_execute_SHIFT_CTRL_string;
  reg [23:0] execute_SRC2_CTRL_string;
  reg [23:0] _zz_execute_SRC2_CTRL_string;
  reg [95:0] execute_SRC1_CTRL_string;
  reg [95:0] _zz_execute_SRC1_CTRL_string;
  reg [63:0] execute_ALU_CTRL_string;
  reg [63:0] _zz_execute_ALU_CTRL_string;
  reg [39:0] execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_execute_ALU_BITWISE_CTRL_string;
  reg [31:0] _zz_decode_ENV_CTRL_1_string;
  reg [31:0] _zz_decode_BRANCH_CTRL_string;
  reg [71:0] _zz_decode_SHIFT_CTRL_1_string;
  reg [39:0] _zz_decode_ALU_BITWISE_CTRL_1_string;
  reg [23:0] _zz_decode_SRC2_CTRL_1_string;
  reg [63:0] _zz_decode_ALU_CTRL_1_string;
  reg [95:0] _zz_decode_SRC1_CTRL_1_string;
  reg [31:0] decode_BRANCH_CTRL_string;
  reg [31:0] _zz_decode_BRANCH_CTRL_1_string;
  reg [95:0] _zz_decode_SRC1_CTRL_2_string;
  reg [63:0] _zz_decode_ALU_CTRL_2_string;
  reg [23:0] _zz_decode_SRC2_CTRL_2_string;
  reg [39:0] _zz_decode_ALU_BITWISE_CTRL_2_string;
  reg [71:0] _zz_decode_SHIFT_CTRL_2_string;
  reg [31:0] _zz_decode_BRANCH_CTRL_2_string;
  reg [31:0] _zz_decode_ENV_CTRL_2_string;
  reg [95:0] decode_to_execute_SRC1_CTRL_string;
  reg [63:0] decode_to_execute_ALU_CTRL_string;
  reg [23:0] decode_to_execute_SRC2_CTRL_string;
  reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [71:0] decode_to_execute_SHIFT_CTRL_string;
  reg [71:0] execute_to_memory_SHIFT_CTRL_string;
  reg [31:0] decode_to_execute_BRANCH_CTRL_string;
  reg [31:0] decode_to_execute_ENV_CTRL_string;
  reg [31:0] execute_to_memory_ENV_CTRL_string;
  reg [31:0] memory_to_writeBack_ENV_CTRL_string;
  `endif

  reg [31:0] RegFilePlugin_regFile [0:31] /* verilator public */ ;

  assign _zz_when = (|{decodeExceptionPort_valid,IBusSimplePlugin_decodeExceptionPort_valid});
  assign _zz_when_1 = (|{BranchPlugin_branchExceptionPort_valid,DBusSimplePlugin_memoryExceptionPort_valid});
  assign _zz_memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW_1) + $signed(_zz_memory_MUL_LOW_4));
  assign _zz_memory_MUL_LOW_1 = ($signed(52'h0) + $signed(_zz_memory_MUL_LOW_2));
  assign _zz_memory_MUL_LOW_3 = {1'b0,memory_MUL_LL};
  assign _zz_memory_MUL_LOW_2 = {{19{_zz_memory_MUL_LOW_3[32]}}, _zz_memory_MUL_LOW_3};
  assign _zz_memory_MUL_LOW_5 = ({16'd0,memory_MUL_LH} <<< 5'd16);
  assign _zz_memory_MUL_LOW_4 = {{2{_zz_memory_MUL_LOW_5[49]}}, _zz_memory_MUL_LOW_5};
  assign _zz_memory_MUL_LOW_7 = ({16'd0,memory_MUL_HL} <<< 5'd16);
  assign _zz_memory_MUL_LOW_6 = {{2{_zz_memory_MUL_LOW_7[49]}}, _zz_memory_MUL_LOW_7};
  assign _zz_execute_SHIFT_RIGHT_1 = ($signed(_zz_execute_SHIFT_RIGHT_2) >>> execute_FullBarrelShifterPlugin_amplitude);
  assign _zz_execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT_1[31 : 0];
  assign _zz_execute_SHIFT_RIGHT_2 = {((execute_SHIFT_CTRL == vexShiftCtrlEnum_SRA_1) && execute_FullBarrelShifterPlugin_reversed[31]),execute_FullBarrelShifterPlugin_reversed};
  assign _zz__zz_IBusSimplePlugin_jump_pcLoad_payload_1 = (_zz_IBusSimplePlugin_jump_pcLoad_payload - 3'b001);
  assign _zz_IBusSimplePlugin_fetchPc_pc_1 = {IBusSimplePlugin_fetchPc_inc,2'b00};
  assign _zz_IBusSimplePlugin_fetchPc_pc = {29'd0, _zz_IBusSimplePlugin_fetchPc_pc_1};
  assign _zz__zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_2 = {{_zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz__zz_2 = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz__zz_4 = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz__zz_6 = {{_zz_3,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz__zz_6_1 = {{_zz_5,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz__zz_IBusSimplePlugin_predictionJumpInterface_payload = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz__zz_IBusSimplePlugin_predictionJumpInterface_payload_2 = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_IBusSimplePlugin_pending_next = (IBusSimplePlugin_pending_value + _zz_IBusSimplePlugin_pending_next_1);
  assign _zz_IBusSimplePlugin_pending_next_2 = IBusSimplePlugin_pending_inc;
  assign _zz_IBusSimplePlugin_pending_next_1 = {2'd0, _zz_IBusSimplePlugin_pending_next_2};
  assign _zz_IBusSimplePlugin_pending_next_4 = IBusSimplePlugin_pending_dec;
  assign _zz_IBusSimplePlugin_pending_next_3 = {2'd0, _zz_IBusSimplePlugin_pending_next_4};
  assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1 = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter != 3'b000));
  assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter = {2'd0, _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1};
  assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_3 = IBusSimplePlugin_pending_dec;
  assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_2 = {2'd0, _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_3};
  assign _zz_DBusSimplePlugin_memoryExceptionPort_payload_code = (memory_MEMORY_STORE ? 3'b110 : 3'b100);
  assign _zz__zz_execute_REGFILE_WRITE_DATA = execute_SRC_LESS;
  assign _zz__zz_execute_SRC1 = 3'b100;
  assign _zz__zz_execute_SRC1_1 = execute_INSTRUCTION[19 : 15];
  assign _zz__zz_execute_SRC2_2 = {execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]};
  assign _zz_execute_SrcPlugin_addSub = ($signed(_zz_execute_SrcPlugin_addSub_1) + $signed(_zz_execute_SrcPlugin_addSub_4));
  assign _zz_execute_SrcPlugin_addSub_1 = ($signed(_zz_execute_SrcPlugin_addSub_2) + $signed(_zz_execute_SrcPlugin_addSub_3));
  assign _zz_execute_SrcPlugin_addSub_2 = execute_SRC1;
  assign _zz_execute_SrcPlugin_addSub_3 = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
  assign _zz_execute_SrcPlugin_addSub_4 = (execute_SRC_USE_SUB_LESS ? 32'h00000001 : 32'h0);
  assign _zz_writeBack_MulPlugin_result = {{14{writeBack_MUL_LOW[51]}}, writeBack_MUL_LOW};
  assign _zz_writeBack_MulPlugin_result_1 = ({32'd0,writeBack_MUL_HH} <<< 6'd32);
  assign _zz__zz_decode_RS2_2 = writeBack_MUL_LOW[31 : 0];
  assign _zz__zz_decode_RS2_2_1 = writeBack_MulPlugin_result[63 : 32];
  assign _zz_memory_DivPlugin_div_counter_valueNext_1 = memory_DivPlugin_div_counter_willIncrement;
  assign _zz_memory_DivPlugin_div_counter_valueNext = {5'd0, _zz_memory_DivPlugin_div_counter_valueNext_1};
  assign _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator = {1'd0, memory_DivPlugin_rs2};
  assign _zz_memory_DivPlugin_div_stage_0_outRemainder = memory_DivPlugin_div_stage_0_remainderMinusDenominator[31:0];
  assign _zz_memory_DivPlugin_div_stage_0_outRemainder_1 = memory_DivPlugin_div_stage_0_remainderShifted[31:0];
  assign _zz_memory_DivPlugin_div_stage_0_outNumerator = {_zz_memory_DivPlugin_div_stage_0_remainderShifted,(! memory_DivPlugin_div_stage_0_remainderMinusDenominator[32])};
  assign _zz_memory_DivPlugin_div_result_1 = _zz_memory_DivPlugin_div_result_2;
  assign _zz_memory_DivPlugin_div_result_2 = _zz_memory_DivPlugin_div_result_3;
  assign _zz_memory_DivPlugin_div_result_3 = ({memory_DivPlugin_div_needRevert,(memory_DivPlugin_div_needRevert ? (~ _zz_memory_DivPlugin_div_result) : _zz_memory_DivPlugin_div_result)} + _zz_memory_DivPlugin_div_result_4);
  assign _zz_memory_DivPlugin_div_result_5 = memory_DivPlugin_div_needRevert;
  assign _zz_memory_DivPlugin_div_result_4 = {32'd0, _zz_memory_DivPlugin_div_result_5};
  assign _zz_memory_DivPlugin_rs1_3 = _zz_memory_DivPlugin_rs1;
  assign _zz_memory_DivPlugin_rs1_2 = {32'd0, _zz_memory_DivPlugin_rs1_3};
  assign _zz_memory_DivPlugin_rs2_2 = _zz_memory_DivPlugin_rs2;
  assign _zz_memory_DivPlugin_rs2_1 = {31'd0, _zz_memory_DivPlugin_rs2_2};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_2 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_4 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6 = {_zz_execute_BranchPlugin_missAlignedTarget_1,execute_INSTRUCTION[31 : 20]};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1 = {{_zz_execute_BranchPlugin_missAlignedTarget_3,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2 = {{_zz_execute_BranchPlugin_missAlignedTarget_5,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz__zz_execute_BranchPlugin_branch_src2_2 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz__zz_execute_BranchPlugin_branch_src2_4 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_execute_BranchPlugin_branch_src2_11 = 3'b100;
  assign _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 = (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code & (~ _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1_1));
  assign _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1_1 = (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code - 2'b01);
  assign _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3 = (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_2 & (~ _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3_1));
  assign _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3_1 = (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_2 - 2'b01);
  assign _zz_decode_RegFilePlugin_rs1Data = 1'b1;
  assign _zz_decode_RegFilePlugin_rs2Data = 1'b1;
  assign _zz_IBusSimplePlugin_jump_pcLoad_payload_5 = {_zz_IBusSimplePlugin_jump_pcLoad_payload_3,_zz_IBusSimplePlugin_jump_pcLoad_payload_2};
  assign _zz_decode_LEGAL_INSTRUCTION = 32'h0000107f;
  assign _zz_decode_LEGAL_INSTRUCTION_1 = (decode_INSTRUCTION & 32'h0000207f);
  assign _zz_decode_LEGAL_INSTRUCTION_2 = 32'h00002073;
  assign _zz_decode_LEGAL_INSTRUCTION_3 = ((decode_INSTRUCTION & 32'h0000407f) == 32'h00004063);
  assign _zz_decode_LEGAL_INSTRUCTION_4 = ((decode_INSTRUCTION & 32'h0000207f) == 32'h00002013);
  assign _zz_decode_LEGAL_INSTRUCTION_5 = {((decode_INSTRUCTION & 32'h0000107f) == 32'h00000013),{((decode_INSTRUCTION & 32'h0000603f) == 32'h00000023),{((decode_INSTRUCTION & _zz_decode_LEGAL_INSTRUCTION_6) == 32'h00000003),{(_zz_decode_LEGAL_INSTRUCTION_7 == _zz_decode_LEGAL_INSTRUCTION_8),{_zz_decode_LEGAL_INSTRUCTION_9,{_zz_decode_LEGAL_INSTRUCTION_10,_zz_decode_LEGAL_INSTRUCTION_11}}}}}};
  assign _zz_decode_LEGAL_INSTRUCTION_6 = 32'h0000207f;
  assign _zz_decode_LEGAL_INSTRUCTION_7 = (decode_INSTRUCTION & 32'h0000505f);
  assign _zz_decode_LEGAL_INSTRUCTION_8 = 32'h00000003;
  assign _zz_decode_LEGAL_INSTRUCTION_9 = ((decode_INSTRUCTION & 32'h0000707b) == 32'h00000063);
  assign _zz_decode_LEGAL_INSTRUCTION_10 = ((decode_INSTRUCTION & 32'h0000607f) == 32'h0000000f);
  assign _zz_decode_LEGAL_INSTRUCTION_11 = {((decode_INSTRUCTION & 32'hfc00007f) == 32'h00000033),{((decode_INSTRUCTION & 32'hbe00705f) == 32'h00005013),{((decode_INSTRUCTION & _zz_decode_LEGAL_INSTRUCTION_12) == 32'h00001013),{(_zz_decode_LEGAL_INSTRUCTION_13 == _zz_decode_LEGAL_INSTRUCTION_14),(_zz_decode_LEGAL_INSTRUCTION_15 == _zz_decode_LEGAL_INSTRUCTION_16)}}}};
  assign _zz_decode_LEGAL_INSTRUCTION_12 = 32'hfe00305f;
  assign _zz_decode_LEGAL_INSTRUCTION_13 = (decode_INSTRUCTION & 32'hbe00707f);
  assign _zz_decode_LEGAL_INSTRUCTION_14 = 32'h00000033;
  assign _zz_decode_LEGAL_INSTRUCTION_15 = (decode_INSTRUCTION & 32'hdfffffff);
  assign _zz_decode_LEGAL_INSTRUCTION_16 = 32'h10200073;
  assign _zz_IBusSimplePlugin_predictionJumpInterface_payload_4 = decode_INSTRUCTION[31];
  assign _zz_IBusSimplePlugin_predictionJumpInterface_payload_5 = decode_INSTRUCTION[31];
  assign _zz_IBusSimplePlugin_predictionJumpInterface_payload_6 = decode_INSTRUCTION[7];
  assign _zz__zz_decode_IS_CSR = 32'h00003050;
  assign _zz__zz_decode_IS_CSR_1 = ((decode_INSTRUCTION & 32'h00001050) == 32'h00001050);
  assign _zz__zz_decode_IS_CSR_2 = ((decode_INSTRUCTION & 32'h00002050) == 32'h00002050);
  assign _zz__zz_decode_IS_CSR_3 = _zz_decode_IS_CSR_4;
  assign _zz__zz_decode_IS_CSR_4 = ((decode_INSTRUCTION & 32'h0000001c) == 32'h00000004);
  assign _zz__zz_decode_IS_CSR_5 = ((decode_INSTRUCTION & 32'h00000058) == 32'h00000040);
  assign _zz__zz_decode_IS_CSR_6 = (|_zz_decode_IS_CSR_5);
  assign _zz__zz_decode_IS_CSR_7 = (|_zz_decode_IS_CSR_5);
  assign _zz__zz_decode_IS_CSR_8 = {(|_zz__zz_decode_IS_CSR_9),{(|_zz__zz_decode_IS_CSR_10),{_zz__zz_decode_IS_CSR_11,{_zz__zz_decode_IS_CSR_13,_zz__zz_decode_IS_CSR_16}}}};
  assign _zz__zz_decode_IS_CSR_9 = ((decode_INSTRUCTION & 32'h02004064) == 32'h02004020);
  assign _zz__zz_decode_IS_CSR_10 = ((decode_INSTRUCTION & 32'h02004074) == 32'h02000030);
  assign _zz__zz_decode_IS_CSR_11 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_12) == 32'h00005010));
  assign _zz__zz_decode_IS_CSR_13 = (|{_zz__zz_decode_IS_CSR_14,_zz__zz_decode_IS_CSR_15});
  assign _zz__zz_decode_IS_CSR_16 = {(|_zz__zz_decode_IS_CSR_17),{(|_zz__zz_decode_IS_CSR_18),{_zz__zz_decode_IS_CSR_19,{_zz__zz_decode_IS_CSR_21,_zz__zz_decode_IS_CSR_24}}}};
  assign _zz__zz_decode_IS_CSR_12 = 32'h02007054;
  assign _zz__zz_decode_IS_CSR_14 = ((decode_INSTRUCTION & 32'h40003054) == 32'h40001010);
  assign _zz__zz_decode_IS_CSR_15 = ((decode_INSTRUCTION & 32'h02007054) == 32'h00001010);
  assign _zz__zz_decode_IS_CSR_17 = ((decode_INSTRUCTION & 32'h00000064) == 32'h00000024);
  assign _zz__zz_decode_IS_CSR_18 = ((decode_INSTRUCTION & 32'h00001000) == 32'h00001000);
  assign _zz__zz_decode_IS_CSR_19 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_20) == 32'h00002000));
  assign _zz__zz_decode_IS_CSR_21 = (|{_zz__zz_decode_IS_CSR_22,_zz__zz_decode_IS_CSR_23});
  assign _zz__zz_decode_IS_CSR_24 = {(|{_zz__zz_decode_IS_CSR_25,_zz__zz_decode_IS_CSR_27}),{(|_zz__zz_decode_IS_CSR_29),{_zz__zz_decode_IS_CSR_33,{_zz__zz_decode_IS_CSR_36,_zz__zz_decode_IS_CSR_48}}}};
  assign _zz__zz_decode_IS_CSR_20 = 32'h00003000;
  assign _zz__zz_decode_IS_CSR_22 = ((decode_INSTRUCTION & 32'h00002010) == 32'h00002000);
  assign _zz__zz_decode_IS_CSR_23 = ((decode_INSTRUCTION & 32'h00005000) == 32'h00001000);
  assign _zz__zz_decode_IS_CSR_25 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_26) == 32'h00000020);
  assign _zz__zz_decode_IS_CSR_27 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_28) == 32'h00000020);
  assign _zz__zz_decode_IS_CSR_29 = {(_zz__zz_decode_IS_CSR_30 == _zz__zz_decode_IS_CSR_31),{_zz_decode_IS_CSR_2,_zz__zz_decode_IS_CSR_32}};
  assign _zz__zz_decode_IS_CSR_33 = (|(_zz__zz_decode_IS_CSR_34 == _zz__zz_decode_IS_CSR_35));
  assign _zz__zz_decode_IS_CSR_36 = (|{_zz__zz_decode_IS_CSR_37,_zz__zz_decode_IS_CSR_39});
  assign _zz__zz_decode_IS_CSR_48 = {(|_zz__zz_decode_IS_CSR_49),{_zz__zz_decode_IS_CSR_60,{_zz__zz_decode_IS_CSR_73,_zz__zz_decode_IS_CSR_78}}};
  assign _zz__zz_decode_IS_CSR_26 = 32'h00000034;
  assign _zz__zz_decode_IS_CSR_28 = 32'h00000064;
  assign _zz__zz_decode_IS_CSR_30 = (decode_INSTRUCTION & 32'h00000050);
  assign _zz__zz_decode_IS_CSR_31 = 32'h00000040;
  assign _zz__zz_decode_IS_CSR_32 = ((decode_INSTRUCTION & 32'h00003040) == 32'h00000040);
  assign _zz__zz_decode_IS_CSR_34 = (decode_INSTRUCTION & 32'h00000020);
  assign _zz__zz_decode_IS_CSR_35 = 32'h00000020;
  assign _zz__zz_decode_IS_CSR_37 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_38) == 32'h00000040);
  assign _zz__zz_decode_IS_CSR_39 = {_zz_decode_IS_CSR_3,{_zz__zz_decode_IS_CSR_40,{_zz__zz_decode_IS_CSR_42,_zz__zz_decode_IS_CSR_45}}};
  assign _zz__zz_decode_IS_CSR_49 = {_zz_decode_IS_CSR_3,{_zz__zz_decode_IS_CSR_50,{_zz__zz_decode_IS_CSR_52,_zz__zz_decode_IS_CSR_55}}};
  assign _zz__zz_decode_IS_CSR_60 = (|{_zz_decode_IS_CSR_4,{_zz__zz_decode_IS_CSR_61,_zz__zz_decode_IS_CSR_64}});
  assign _zz__zz_decode_IS_CSR_73 = (|{_zz__zz_decode_IS_CSR_74,_zz__zz_decode_IS_CSR_75});
  assign _zz__zz_decode_IS_CSR_78 = {(|_zz__zz_decode_IS_CSR_79),{_zz__zz_decode_IS_CSR_82,{_zz__zz_decode_IS_CSR_85,_zz__zz_decode_IS_CSR_89}}};
  assign _zz__zz_decode_IS_CSR_38 = 32'h00000040;
  assign _zz__zz_decode_IS_CSR_40 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_41) == 32'h00004020);
  assign _zz__zz_decode_IS_CSR_42 = (_zz__zz_decode_IS_CSR_43 == _zz__zz_decode_IS_CSR_44);
  assign _zz__zz_decode_IS_CSR_45 = (_zz__zz_decode_IS_CSR_46 == _zz__zz_decode_IS_CSR_47);
  assign _zz__zz_decode_IS_CSR_50 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_51) == 32'h00002010);
  assign _zz__zz_decode_IS_CSR_52 = (_zz__zz_decode_IS_CSR_53 == _zz__zz_decode_IS_CSR_54);
  assign _zz__zz_decode_IS_CSR_55 = {_zz__zz_decode_IS_CSR_56,_zz__zz_decode_IS_CSR_58};
  assign _zz__zz_decode_IS_CSR_61 = (_zz__zz_decode_IS_CSR_62 == _zz__zz_decode_IS_CSR_63);
  assign _zz__zz_decode_IS_CSR_64 = {_zz__zz_decode_IS_CSR_65,{_zz__zz_decode_IS_CSR_67,_zz__zz_decode_IS_CSR_70}};
  assign _zz__zz_decode_IS_CSR_74 = _zz_decode_IS_CSR_3;
  assign _zz__zz_decode_IS_CSR_75 = (_zz__zz_decode_IS_CSR_76 == _zz__zz_decode_IS_CSR_77);
  assign _zz__zz_decode_IS_CSR_79 = {_zz_decode_IS_CSR_3,_zz__zz_decode_IS_CSR_80};
  assign _zz__zz_decode_IS_CSR_82 = (|_zz__zz_decode_IS_CSR_83);
  assign _zz__zz_decode_IS_CSR_85 = (|_zz__zz_decode_IS_CSR_86);
  assign _zz__zz_decode_IS_CSR_89 = {_zz__zz_decode_IS_CSR_90,{_zz__zz_decode_IS_CSR_96,_zz__zz_decode_IS_CSR_99}};
  assign _zz__zz_decode_IS_CSR_41 = 32'h00004020;
  assign _zz__zz_decode_IS_CSR_43 = (decode_INSTRUCTION & 32'h00000030);
  assign _zz__zz_decode_IS_CSR_44 = 32'h00000010;
  assign _zz__zz_decode_IS_CSR_46 = (decode_INSTRUCTION & 32'h02000020);
  assign _zz__zz_decode_IS_CSR_47 = 32'h00000020;
  assign _zz__zz_decode_IS_CSR_51 = 32'h00002030;
  assign _zz__zz_decode_IS_CSR_53 = (decode_INSTRUCTION & 32'h00001030);
  assign _zz__zz_decode_IS_CSR_54 = 32'h00000010;
  assign _zz__zz_decode_IS_CSR_56 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_57) == 32'h00002020);
  assign _zz__zz_decode_IS_CSR_58 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_59) == 32'h00000020);
  assign _zz__zz_decode_IS_CSR_62 = (decode_INSTRUCTION & 32'h00001010);
  assign _zz__zz_decode_IS_CSR_63 = 32'h00001010;
  assign _zz__zz_decode_IS_CSR_65 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_66) == 32'h00002010);
  assign _zz__zz_decode_IS_CSR_67 = (_zz__zz_decode_IS_CSR_68 == _zz__zz_decode_IS_CSR_69);
  assign _zz__zz_decode_IS_CSR_70 = {_zz__zz_decode_IS_CSR_71,_zz__zz_decode_IS_CSR_72};
  assign _zz__zz_decode_IS_CSR_76 = (decode_INSTRUCTION & 32'h00000070);
  assign _zz__zz_decode_IS_CSR_77 = 32'h00000020;
  assign _zz__zz_decode_IS_CSR_80 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_81) == 32'h0);
  assign _zz__zz_decode_IS_CSR_83 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_84) == 32'h00004010);
  assign _zz__zz_decode_IS_CSR_86 = (_zz__zz_decode_IS_CSR_87 == _zz__zz_decode_IS_CSR_88);
  assign _zz__zz_decode_IS_CSR_90 = (|{_zz__zz_decode_IS_CSR_91,_zz__zz_decode_IS_CSR_93});
  assign _zz__zz_decode_IS_CSR_96 = (|_zz__zz_decode_IS_CSR_97);
  assign _zz__zz_decode_IS_CSR_99 = {_zz__zz_decode_IS_CSR_100,{_zz__zz_decode_IS_CSR_104,_zz__zz_decode_IS_CSR_107}};
  assign _zz__zz_decode_IS_CSR_57 = 32'h02002060;
  assign _zz__zz_decode_IS_CSR_59 = 32'h02003020;
  assign _zz__zz_decode_IS_CSR_66 = 32'h00002010;
  assign _zz__zz_decode_IS_CSR_68 = (decode_INSTRUCTION & 32'h00000050);
  assign _zz__zz_decode_IS_CSR_69 = 32'h00000010;
  assign _zz__zz_decode_IS_CSR_71 = ((decode_INSTRUCTION & 32'h0000000c) == 32'h00000004);
  assign _zz__zz_decode_IS_CSR_72 = ((decode_INSTRUCTION & 32'h00000028) == 32'h0);
  assign _zz__zz_decode_IS_CSR_81 = 32'h00000020;
  assign _zz__zz_decode_IS_CSR_84 = 32'h00004014;
  assign _zz__zz_decode_IS_CSR_87 = (decode_INSTRUCTION & 32'h00006014);
  assign _zz__zz_decode_IS_CSR_88 = 32'h00002010;
  assign _zz__zz_decode_IS_CSR_91 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_92) == 32'h0);
  assign _zz__zz_decode_IS_CSR_93 = {_zz_decode_IS_CSR_2,{_zz__zz_decode_IS_CSR_94,_zz__zz_decode_IS_CSR_95}};
  assign _zz__zz_decode_IS_CSR_97 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_98) == 32'h0);
  assign _zz__zz_decode_IS_CSR_100 = (|{_zz__zz_decode_IS_CSR_101,{_zz__zz_decode_IS_CSR_102,_zz__zz_decode_IS_CSR_103}});
  assign _zz__zz_decode_IS_CSR_104 = (|{_zz__zz_decode_IS_CSR_105,_zz__zz_decode_IS_CSR_106});
  assign _zz__zz_decode_IS_CSR_107 = (|{_zz__zz_decode_IS_CSR_108,_zz__zz_decode_IS_CSR_109});
  assign _zz__zz_decode_IS_CSR_92 = 32'h00000044;
  assign _zz__zz_decode_IS_CSR_94 = ((decode_INSTRUCTION & 32'h00006004) == 32'h00002000);
  assign _zz__zz_decode_IS_CSR_95 = ((decode_INSTRUCTION & 32'h00005004) == 32'h00001000);
  assign _zz__zz_decode_IS_CSR_98 = 32'h00000058;
  assign _zz__zz_decode_IS_CSR_101 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000040);
  assign _zz__zz_decode_IS_CSR_102 = ((decode_INSTRUCTION & 32'h00002014) == 32'h00002010);
  assign _zz__zz_decode_IS_CSR_103 = ((decode_INSTRUCTION & 32'h40000034) == 32'h40000030);
  assign _zz__zz_decode_IS_CSR_105 = ((decode_INSTRUCTION & 32'h00000014) == 32'h00000004);
  assign _zz__zz_decode_IS_CSR_106 = _zz_decode_IS_CSR_1;
  assign _zz__zz_decode_IS_CSR_108 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000004);
  assign _zz__zz_decode_IS_CSR_109 = _zz_decode_IS_CSR_1;
  assign _zz_execute_BranchPlugin_branch_src2_6 = execute_INSTRUCTION[31];
  assign _zz_execute_BranchPlugin_branch_src2_7 = execute_INSTRUCTION[19 : 12];
  assign _zz_execute_BranchPlugin_branch_src2_8 = execute_INSTRUCTION[20];
  assign _zz_execute_BranchPlugin_branch_src2_9 = execute_INSTRUCTION[31];
  assign _zz_execute_BranchPlugin_branch_src2_10 = execute_INSTRUCTION[7];
  always @(posedge io_axiClk) begin
    if(_zz_decode_RegFilePlugin_rs1Data) begin
      RegFilePlugin_regFile_spinal_port0 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress1];
    end
  end

  always @(posedge io_axiClk) begin
    if(_zz_decode_RegFilePlugin_rs2Data) begin
      RegFilePlugin_regFile_spinal_port1 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress2];
    end
  end

  always @(posedge io_axiClk) begin
    if(_zz_1) begin
      RegFilePlugin_regFile[lastStageRegFileWrite_payload_address] <= lastStageRegFileWrite_payload_data;
    end
  end

  vexStreamFifoLowLatency IBusSimplePlugin_rspJoin_rspBuffer_c (
    .io_push_valid         (iBus_rsp_toStream_valid                                       ), //i
    .io_push_ready         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready            ), //o
    .io_push_payload_error (iBus_rsp_toStream_payload_error                               ), //i
    .io_push_payload_inst  (iBus_rsp_toStream_payload_inst[31:0]                          ), //i
    .io_pop_valid          (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid             ), //o
    .io_pop_ready          (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready             ), //i
    .io_pop_payload_error  (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error     ), //o
    .io_pop_payload_inst   (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst[31:0]), //o
    .io_flush              (1'b0                                                          ), //i
    .io_occupancy          (IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy             ), //o
    .io_availability       (IBusSimplePlugin_rspJoin_rspBuffer_c_io_availability          ), //o
    .io_axiClk             (io_axiClk                                                     ), //i
    .resetCtrl_axiReset    (resetCtrl_axiReset                                            )  //i
  );
  always @(*) begin
    case(_zz_IBusSimplePlugin_jump_pcLoad_payload_5)
      2'b00 : _zz_IBusSimplePlugin_jump_pcLoad_payload_4 = CsrPlugin_jumpInterface_payload;
      2'b01 : _zz_IBusSimplePlugin_jump_pcLoad_payload_4 = BranchPlugin_jumpInterface_payload;
      default : _zz_IBusSimplePlugin_jump_pcLoad_payload_4 = IBusSimplePlugin_predictionJumpInterface_payload;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(_zz_memory_to_writeBack_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_memory_to_writeBack_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_memory_to_writeBack_ENV_CTRL_string = "XRET";
      default : _zz_memory_to_writeBack_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_memory_to_writeBack_ENV_CTRL_1)
      vexEnvCtrlEnum_NONE : _zz_memory_to_writeBack_ENV_CTRL_1_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_memory_to_writeBack_ENV_CTRL_1_string = "XRET";
      default : _zz_memory_to_writeBack_ENV_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_to_memory_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_execute_to_memory_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_execute_to_memory_ENV_CTRL_string = "XRET";
      default : _zz_execute_to_memory_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_to_memory_ENV_CTRL_1)
      vexEnvCtrlEnum_NONE : _zz_execute_to_memory_ENV_CTRL_1_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_execute_to_memory_ENV_CTRL_1_string = "XRET";
      default : _zz_execute_to_memory_ENV_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(decode_ENV_CTRL)
      vexEnvCtrlEnum_NONE : decode_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : decode_ENV_CTRL_string = "XRET";
      default : decode_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_decode_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_decode_ENV_CTRL_string = "XRET";
      default : _zz_decode_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_decode_to_execute_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_decode_to_execute_ENV_CTRL_string = "XRET";
      default : _zz_decode_to_execute_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ENV_CTRL_1)
      vexEnvCtrlEnum_NONE : _zz_decode_to_execute_ENV_CTRL_1_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_decode_to_execute_ENV_CTRL_1_string = "XRET";
      default : _zz_decode_to_execute_ENV_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : _zz_decode_to_execute_BRANCH_CTRL_string = "INC ";
      vexBranchCtrlEnum_B : _zz_decode_to_execute_BRANCH_CTRL_string = "B   ";
      vexBranchCtrlEnum_JAL : _zz_decode_to_execute_BRANCH_CTRL_string = "JAL ";
      vexBranchCtrlEnum_JALR : _zz_decode_to_execute_BRANCH_CTRL_string = "JALR";
      default : _zz_decode_to_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_BRANCH_CTRL_1)
      vexBranchCtrlEnum_INC : _zz_decode_to_execute_BRANCH_CTRL_1_string = "INC ";
      vexBranchCtrlEnum_B : _zz_decode_to_execute_BRANCH_CTRL_1_string = "B   ";
      vexBranchCtrlEnum_JAL : _zz_decode_to_execute_BRANCH_CTRL_1_string = "JAL ";
      vexBranchCtrlEnum_JALR : _zz_decode_to_execute_BRANCH_CTRL_1_string = "JALR";
      default : _zz_decode_to_execute_BRANCH_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_to_memory_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_execute_to_memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_to_memory_SHIFT_CTRL_1)
      vexShiftCtrlEnum_DISABLE_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRA_1    ";
      default : _zz_execute_to_memory_SHIFT_CTRL_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : decode_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : decode_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : decode_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : decode_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : _zz_decode_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_decode_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_decode_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_decode_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_decode_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_decode_to_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SHIFT_CTRL_1)
      vexShiftCtrlEnum_DISABLE_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRA_1    ";
      default : _zz_decode_to_execute_SHIFT_CTRL_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_XOR_1 : decode_ALU_BITWISE_CTRL_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : decode_ALU_BITWISE_CTRL_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : decode_ALU_BITWISE_CTRL_string = "AND_1";
      default : decode_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_XOR_1 : _zz_decode_ALU_BITWISE_CTRL_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : _zz_decode_ALU_BITWISE_CTRL_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : _zz_decode_ALU_BITWISE_CTRL_string = "AND_1";
      default : _zz_decode_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_XOR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_BITWISE_CTRL_1)
      vexAluBitwiseCtrlEnum_XOR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "AND_1";
      default : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : decode_SRC2_CTRL_string = "RS ";
      vexSrc2CtrlEnum_IMI : decode_SRC2_CTRL_string = "IMI";
      vexSrc2CtrlEnum_IMS : decode_SRC2_CTRL_string = "IMS";
      vexSrc2CtrlEnum_PC : decode_SRC2_CTRL_string = "PC ";
      default : decode_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : _zz_decode_SRC2_CTRL_string = "RS ";
      vexSrc2CtrlEnum_IMI : _zz_decode_SRC2_CTRL_string = "IMI";
      vexSrc2CtrlEnum_IMS : _zz_decode_SRC2_CTRL_string = "IMS";
      vexSrc2CtrlEnum_PC : _zz_decode_SRC2_CTRL_string = "PC ";
      default : _zz_decode_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : _zz_decode_to_execute_SRC2_CTRL_string = "RS ";
      vexSrc2CtrlEnum_IMI : _zz_decode_to_execute_SRC2_CTRL_string = "IMI";
      vexSrc2CtrlEnum_IMS : _zz_decode_to_execute_SRC2_CTRL_string = "IMS";
      vexSrc2CtrlEnum_PC : _zz_decode_to_execute_SRC2_CTRL_string = "PC ";
      default : _zz_decode_to_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC2_CTRL_1)
      vexSrc2CtrlEnum_RS : _zz_decode_to_execute_SRC2_CTRL_1_string = "RS ";
      vexSrc2CtrlEnum_IMI : _zz_decode_to_execute_SRC2_CTRL_1_string = "IMI";
      vexSrc2CtrlEnum_IMS : _zz_decode_to_execute_SRC2_CTRL_1_string = "IMS";
      vexSrc2CtrlEnum_PC : _zz_decode_to_execute_SRC2_CTRL_1_string = "PC ";
      default : _zz_decode_to_execute_SRC2_CTRL_1_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_ALU_CTRL)
      vexAluCtrlEnum_ADD_SUB : decode_ALU_CTRL_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : decode_ALU_CTRL_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : decode_ALU_CTRL_string = "BITWISE ";
      default : decode_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_CTRL)
      vexAluCtrlEnum_ADD_SUB : _zz_decode_ALU_CTRL_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : _zz_decode_ALU_CTRL_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : _zz_decode_ALU_CTRL_string = "BITWISE ";
      default : _zz_decode_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_CTRL)
      vexAluCtrlEnum_ADD_SUB : _zz_decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : _zz_decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : _zz_decode_to_execute_ALU_CTRL_string = "BITWISE ";
      default : _zz_decode_to_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_CTRL_1)
      vexAluCtrlEnum_ADD_SUB : _zz_decode_to_execute_ALU_CTRL_1_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : _zz_decode_to_execute_ALU_CTRL_1_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : _zz_decode_to_execute_ALU_CTRL_1_string = "BITWISE ";
      default : _zz_decode_to_execute_ALU_CTRL_1_string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : decode_SRC1_CTRL_string = "RS          ";
      vexSrc1CtrlEnum_IMU : decode_SRC1_CTRL_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : decode_SRC1_CTRL_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : decode_SRC1_CTRL_string = "URS1        ";
      default : decode_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : _zz_decode_SRC1_CTRL_string = "RS          ";
      vexSrc1CtrlEnum_IMU : _zz_decode_SRC1_CTRL_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : _zz_decode_SRC1_CTRL_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : _zz_decode_SRC1_CTRL_string = "URS1        ";
      default : _zz_decode_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : _zz_decode_to_execute_SRC1_CTRL_string = "RS          ";
      vexSrc1CtrlEnum_IMU : _zz_decode_to_execute_SRC1_CTRL_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : _zz_decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : _zz_decode_to_execute_SRC1_CTRL_string = "URS1        ";
      default : _zz_decode_to_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC1_CTRL_1)
      vexSrc1CtrlEnum_RS : _zz_decode_to_execute_SRC1_CTRL_1_string = "RS          ";
      vexSrc1CtrlEnum_IMU : _zz_decode_to_execute_SRC1_CTRL_1_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : _zz_decode_to_execute_SRC1_CTRL_1_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : _zz_decode_to_execute_SRC1_CTRL_1_string = "URS1        ";
      default : _zz_decode_to_execute_SRC1_CTRL_1_string = "????????????";
    endcase
  end
  always @(*) begin
    case(memory_ENV_CTRL)
      vexEnvCtrlEnum_NONE : memory_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : memory_ENV_CTRL_string = "XRET";
      default : memory_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_memory_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_memory_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_memory_ENV_CTRL_string = "XRET";
      default : _zz_memory_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(execute_ENV_CTRL)
      vexEnvCtrlEnum_NONE : execute_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : execute_ENV_CTRL_string = "XRET";
      default : execute_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_execute_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_execute_ENV_CTRL_string = "XRET";
      default : _zz_execute_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(writeBack_ENV_CTRL)
      vexEnvCtrlEnum_NONE : writeBack_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : writeBack_ENV_CTRL_string = "XRET";
      default : writeBack_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_writeBack_ENV_CTRL)
      vexEnvCtrlEnum_NONE : _zz_writeBack_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_writeBack_ENV_CTRL_string = "XRET";
      default : _zz_writeBack_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(execute_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : execute_BRANCH_CTRL_string = "INC ";
      vexBranchCtrlEnum_B : execute_BRANCH_CTRL_string = "B   ";
      vexBranchCtrlEnum_JAL : execute_BRANCH_CTRL_string = "JAL ";
      vexBranchCtrlEnum_JALR : execute_BRANCH_CTRL_string = "JALR";
      default : execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : _zz_execute_BRANCH_CTRL_string = "INC ";
      vexBranchCtrlEnum_B : _zz_execute_BRANCH_CTRL_string = "B   ";
      vexBranchCtrlEnum_JAL : _zz_execute_BRANCH_CTRL_string = "JAL ";
      vexBranchCtrlEnum_JALR : _zz_execute_BRANCH_CTRL_string = "JALR";
      default : _zz_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(memory_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : memory_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : memory_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : memory_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : memory_SHIFT_CTRL_string = "SRA_1    ";
      default : memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_memory_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : _zz_memory_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_memory_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_memory_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_memory_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : execute_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : execute_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : execute_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : execute_SHIFT_CTRL_string = "SRA_1    ";
      default : execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : _zz_execute_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_execute_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_execute_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : execute_SRC2_CTRL_string = "RS ";
      vexSrc2CtrlEnum_IMI : execute_SRC2_CTRL_string = "IMI";
      vexSrc2CtrlEnum_IMS : execute_SRC2_CTRL_string = "IMS";
      vexSrc2CtrlEnum_PC : execute_SRC2_CTRL_string = "PC ";
      default : execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : _zz_execute_SRC2_CTRL_string = "RS ";
      vexSrc2CtrlEnum_IMI : _zz_execute_SRC2_CTRL_string = "IMI";
      vexSrc2CtrlEnum_IMS : _zz_execute_SRC2_CTRL_string = "IMS";
      vexSrc2CtrlEnum_PC : _zz_execute_SRC2_CTRL_string = "PC ";
      default : _zz_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(execute_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : execute_SRC1_CTRL_string = "RS          ";
      vexSrc1CtrlEnum_IMU : execute_SRC1_CTRL_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : execute_SRC1_CTRL_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : execute_SRC1_CTRL_string = "URS1        ";
      default : execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : _zz_execute_SRC1_CTRL_string = "RS          ";
      vexSrc1CtrlEnum_IMU : _zz_execute_SRC1_CTRL_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : _zz_execute_SRC1_CTRL_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : _zz_execute_SRC1_CTRL_string = "URS1        ";
      default : _zz_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(execute_ALU_CTRL)
      vexAluCtrlEnum_ADD_SUB : execute_ALU_CTRL_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : execute_ALU_CTRL_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : execute_ALU_CTRL_string = "BITWISE ";
      default : execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_ALU_CTRL)
      vexAluCtrlEnum_ADD_SUB : _zz_execute_ALU_CTRL_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : _zz_execute_ALU_CTRL_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : _zz_execute_ALU_CTRL_string = "BITWISE ";
      default : _zz_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(execute_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_XOR_1 : execute_ALU_BITWISE_CTRL_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_XOR_1 : _zz_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : _zz_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : _zz_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : _zz_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ENV_CTRL_1)
      vexEnvCtrlEnum_NONE : _zz_decode_ENV_CTRL_1_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_decode_ENV_CTRL_1_string = "XRET";
      default : _zz_decode_ENV_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : _zz_decode_BRANCH_CTRL_string = "INC ";
      vexBranchCtrlEnum_B : _zz_decode_BRANCH_CTRL_string = "B   ";
      vexBranchCtrlEnum_JAL : _zz_decode_BRANCH_CTRL_string = "JAL ";
      vexBranchCtrlEnum_JALR : _zz_decode_BRANCH_CTRL_string = "JALR";
      default : _zz_decode_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SHIFT_CTRL_1)
      vexShiftCtrlEnum_DISABLE_1 : _zz_decode_SHIFT_CTRL_1_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_decode_SHIFT_CTRL_1_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_decode_SHIFT_CTRL_1_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_decode_SHIFT_CTRL_1_string = "SRA_1    ";
      default : _zz_decode_SHIFT_CTRL_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_BITWISE_CTRL_1)
      vexAluBitwiseCtrlEnum_XOR_1 : _zz_decode_ALU_BITWISE_CTRL_1_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : _zz_decode_ALU_BITWISE_CTRL_1_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : _zz_decode_ALU_BITWISE_CTRL_1_string = "AND_1";
      default : _zz_decode_ALU_BITWISE_CTRL_1_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC2_CTRL_1)
      vexSrc2CtrlEnum_RS : _zz_decode_SRC2_CTRL_1_string = "RS ";
      vexSrc2CtrlEnum_IMI : _zz_decode_SRC2_CTRL_1_string = "IMI";
      vexSrc2CtrlEnum_IMS : _zz_decode_SRC2_CTRL_1_string = "IMS";
      vexSrc2CtrlEnum_PC : _zz_decode_SRC2_CTRL_1_string = "PC ";
      default : _zz_decode_SRC2_CTRL_1_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_CTRL_1)
      vexAluCtrlEnum_ADD_SUB : _zz_decode_ALU_CTRL_1_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : _zz_decode_ALU_CTRL_1_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : _zz_decode_ALU_CTRL_1_string = "BITWISE ";
      default : _zz_decode_ALU_CTRL_1_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC1_CTRL_1)
      vexSrc1CtrlEnum_RS : _zz_decode_SRC1_CTRL_1_string = "RS          ";
      vexSrc1CtrlEnum_IMU : _zz_decode_SRC1_CTRL_1_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : _zz_decode_SRC1_CTRL_1_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : _zz_decode_SRC1_CTRL_1_string = "URS1        ";
      default : _zz_decode_SRC1_CTRL_1_string = "????????????";
    endcase
  end
  always @(*) begin
    case(decode_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : decode_BRANCH_CTRL_string = "INC ";
      vexBranchCtrlEnum_B : decode_BRANCH_CTRL_string = "B   ";
      vexBranchCtrlEnum_JAL : decode_BRANCH_CTRL_string = "JAL ";
      vexBranchCtrlEnum_JALR : decode_BRANCH_CTRL_string = "JALR";
      default : decode_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_BRANCH_CTRL_1)
      vexBranchCtrlEnum_INC : _zz_decode_BRANCH_CTRL_1_string = "INC ";
      vexBranchCtrlEnum_B : _zz_decode_BRANCH_CTRL_1_string = "B   ";
      vexBranchCtrlEnum_JAL : _zz_decode_BRANCH_CTRL_1_string = "JAL ";
      vexBranchCtrlEnum_JALR : _zz_decode_BRANCH_CTRL_1_string = "JALR";
      default : _zz_decode_BRANCH_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC1_CTRL_2)
      vexSrc1CtrlEnum_RS : _zz_decode_SRC1_CTRL_2_string = "RS          ";
      vexSrc1CtrlEnum_IMU : _zz_decode_SRC1_CTRL_2_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : _zz_decode_SRC1_CTRL_2_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : _zz_decode_SRC1_CTRL_2_string = "URS1        ";
      default : _zz_decode_SRC1_CTRL_2_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_CTRL_2)
      vexAluCtrlEnum_ADD_SUB : _zz_decode_ALU_CTRL_2_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : _zz_decode_ALU_CTRL_2_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : _zz_decode_ALU_CTRL_2_string = "BITWISE ";
      default : _zz_decode_ALU_CTRL_2_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC2_CTRL_2)
      vexSrc2CtrlEnum_RS : _zz_decode_SRC2_CTRL_2_string = "RS ";
      vexSrc2CtrlEnum_IMI : _zz_decode_SRC2_CTRL_2_string = "IMI";
      vexSrc2CtrlEnum_IMS : _zz_decode_SRC2_CTRL_2_string = "IMS";
      vexSrc2CtrlEnum_PC : _zz_decode_SRC2_CTRL_2_string = "PC ";
      default : _zz_decode_SRC2_CTRL_2_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_BITWISE_CTRL_2)
      vexAluBitwiseCtrlEnum_XOR_1 : _zz_decode_ALU_BITWISE_CTRL_2_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : _zz_decode_ALU_BITWISE_CTRL_2_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : _zz_decode_ALU_BITWISE_CTRL_2_string = "AND_1";
      default : _zz_decode_ALU_BITWISE_CTRL_2_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SHIFT_CTRL_2)
      vexShiftCtrlEnum_DISABLE_1 : _zz_decode_SHIFT_CTRL_2_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : _zz_decode_SHIFT_CTRL_2_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : _zz_decode_SHIFT_CTRL_2_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : _zz_decode_SHIFT_CTRL_2_string = "SRA_1    ";
      default : _zz_decode_SHIFT_CTRL_2_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_BRANCH_CTRL_2)
      vexBranchCtrlEnum_INC : _zz_decode_BRANCH_CTRL_2_string = "INC ";
      vexBranchCtrlEnum_B : _zz_decode_BRANCH_CTRL_2_string = "B   ";
      vexBranchCtrlEnum_JAL : _zz_decode_BRANCH_CTRL_2_string = "JAL ";
      vexBranchCtrlEnum_JALR : _zz_decode_BRANCH_CTRL_2_string = "JALR";
      default : _zz_decode_BRANCH_CTRL_2_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ENV_CTRL_2)
      vexEnvCtrlEnum_NONE : _zz_decode_ENV_CTRL_2_string = "NONE";
      vexEnvCtrlEnum_XRET : _zz_decode_ENV_CTRL_2_string = "XRET";
      default : _zz_decode_ENV_CTRL_2_string = "????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : decode_to_execute_SRC1_CTRL_string = "RS          ";
      vexSrc1CtrlEnum_IMU : decode_to_execute_SRC1_CTRL_string = "IMU         ";
      vexSrc1CtrlEnum_PC_INCREMENT : decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
      vexSrc1CtrlEnum_URS1 : decode_to_execute_SRC1_CTRL_string = "URS1        ";
      default : decode_to_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ALU_CTRL)
      vexAluCtrlEnum_ADD_SUB : decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
      vexAluCtrlEnum_SLT_SLTU : decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
      vexAluCtrlEnum_BITWISE : decode_to_execute_ALU_CTRL_string = "BITWISE ";
      default : decode_to_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : decode_to_execute_SRC2_CTRL_string = "RS ";
      vexSrc2CtrlEnum_IMI : decode_to_execute_SRC2_CTRL_string = "IMI";
      vexSrc2CtrlEnum_IMS : decode_to_execute_SRC2_CTRL_string = "IMS";
      vexSrc2CtrlEnum_PC : decode_to_execute_SRC2_CTRL_string = "PC ";
      default : decode_to_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_XOR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      vexAluBitwiseCtrlEnum_OR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      vexAluBitwiseCtrlEnum_AND_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_to_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_to_memory_SHIFT_CTRL)
      vexShiftCtrlEnum_DISABLE_1 : execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
      vexShiftCtrlEnum_SLL_1 : execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
      vexShiftCtrlEnum_SRL_1 : execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
      vexShiftCtrlEnum_SRA_1 : execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
      default : execute_to_memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : decode_to_execute_BRANCH_CTRL_string = "INC ";
      vexBranchCtrlEnum_B : decode_to_execute_BRANCH_CTRL_string = "B   ";
      vexBranchCtrlEnum_JAL : decode_to_execute_BRANCH_CTRL_string = "JAL ";
      vexBranchCtrlEnum_JALR : decode_to_execute_BRANCH_CTRL_string = "JALR";
      default : decode_to_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ENV_CTRL)
      vexEnvCtrlEnum_NONE : decode_to_execute_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : decode_to_execute_ENV_CTRL_string = "XRET";
      default : decode_to_execute_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(execute_to_memory_ENV_CTRL)
      vexEnvCtrlEnum_NONE : execute_to_memory_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : execute_to_memory_ENV_CTRL_string = "XRET";
      default : execute_to_memory_ENV_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(memory_to_writeBack_ENV_CTRL)
      vexEnvCtrlEnum_NONE : memory_to_writeBack_ENV_CTRL_string = "NONE";
      vexEnvCtrlEnum_XRET : memory_to_writeBack_ENV_CTRL_string = "XRET";
      default : memory_to_writeBack_ENV_CTRL_string = "????";
    endcase
  end
  `endif

  assign memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW) + $signed(_zz_memory_MUL_LOW_6));
  assign memory_MEMORY_READ_DATA = dBus_rsp_data;
  assign execute_BRANCH_CALC = {execute_BranchPlugin_branchAdder[31 : 1],1'b0};
  assign execute_BRANCH_DO = ((execute_PREDICTION_HAD_BRANCHED1 != execute_BRANCH_COND_RESULT) || execute_BranchPlugin_missAlignedTarget);
  assign memory_MUL_HH = execute_to_memory_MUL_HH;
  assign execute_MUL_HH = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bHigh));
  assign execute_MUL_HL = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bSLow));
  assign execute_MUL_LH = ($signed(execute_MulPlugin_aSLow) * $signed(execute_MulPlugin_bHigh));
  assign execute_MUL_LL = (execute_MulPlugin_aULow * execute_MulPlugin_bULow);
  assign execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT;
  assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
  assign execute_REGFILE_WRITE_DATA = _zz_execute_REGFILE_WRITE_DATA;
  assign memory_MEMORY_ADDRESS_LOW = execute_to_memory_MEMORY_ADDRESS_LOW;
  assign execute_MEMORY_ADDRESS_LOW = dBus_cmd_payload_address[1 : 0];
  assign decode_CSR_READ_OPCODE = (decode_INSTRUCTION[13 : 7] != 7'h20);
  assign decode_CSR_WRITE_OPCODE = (! (((decode_INSTRUCTION[14 : 13] == 2'b01) && (decode_INSTRUCTION[19 : 15] == 5'h0)) || ((decode_INSTRUCTION[14 : 13] == 2'b11) && (decode_INSTRUCTION[19 : 15] == 5'h0))));
  assign decode_PREDICTION_HAD_BRANCHED1 = IBusSimplePlugin_decodePrediction_cmd_hadBranch;
  assign decode_SRC2_FORCE_ZERO = (decode_SRC_ADD_ZERO && (! decode_SRC_USE_SUB_LESS));
  assign _zz_memory_to_writeBack_ENV_CTRL = _zz_memory_to_writeBack_ENV_CTRL_1;
  assign _zz_execute_to_memory_ENV_CTRL = _zz_execute_to_memory_ENV_CTRL_1;
  assign decode_ENV_CTRL = _zz_decode_ENV_CTRL;
  assign _zz_decode_to_execute_ENV_CTRL = _zz_decode_to_execute_ENV_CTRL_1;
  assign decode_IS_CSR = _zz_decode_IS_CSR[27];
  assign _zz_decode_to_execute_BRANCH_CTRL = _zz_decode_to_execute_BRANCH_CTRL_1;
  assign decode_IS_RS2_SIGNED = _zz_decode_IS_CSR[24];
  assign decode_IS_RS1_SIGNED = _zz_decode_IS_CSR[23];
  assign decode_IS_DIV = _zz_decode_IS_CSR[22];
  assign memory_IS_MUL = execute_to_memory_IS_MUL;
  assign execute_IS_MUL = decode_to_execute_IS_MUL;
  assign decode_IS_MUL = _zz_decode_IS_CSR[21];
  assign _zz_execute_to_memory_SHIFT_CTRL = _zz_execute_to_memory_SHIFT_CTRL_1;
  assign decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL;
  assign _zz_decode_to_execute_SHIFT_CTRL = _zz_decode_to_execute_SHIFT_CTRL_1;
  assign decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL;
  assign _zz_decode_to_execute_ALU_BITWISE_CTRL = _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
  assign decode_SRC_LESS_UNSIGNED = _zz_decode_IS_CSR[15];
  assign decode_MEMORY_STORE = _zz_decode_IS_CSR[12];
  assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  assign decode_BYPASSABLE_MEMORY_STAGE = _zz_decode_IS_CSR[11];
  assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_decode_IS_CSR[10];
  assign decode_SRC2_CTRL = _zz_decode_SRC2_CTRL;
  assign _zz_decode_to_execute_SRC2_CTRL = _zz_decode_to_execute_SRC2_CTRL_1;
  assign decode_ALU_CTRL = _zz_decode_ALU_CTRL;
  assign _zz_decode_to_execute_ALU_CTRL = _zz_decode_to_execute_ALU_CTRL_1;
  assign decode_MEMORY_ENABLE = _zz_decode_IS_CSR[3];
  assign decode_SRC1_CTRL = _zz_decode_SRC1_CTRL;
  assign _zz_decode_to_execute_SRC1_CTRL = _zz_decode_to_execute_SRC1_CTRL_1;
  assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
  assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = (decode_PC + 32'h00000004);
  assign memory_PC = execute_to_memory_PC;
  assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
  assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
  assign execute_IS_CSR = decode_to_execute_IS_CSR;
  assign memory_ENV_CTRL = _zz_memory_ENV_CTRL;
  assign execute_ENV_CTRL = _zz_execute_ENV_CTRL;
  assign writeBack_ENV_CTRL = _zz_writeBack_ENV_CTRL;
  assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
  assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
  assign execute_PC = decode_to_execute_PC;
  assign execute_PREDICTION_HAD_BRANCHED1 = decode_to_execute_PREDICTION_HAD_BRANCHED1;
  assign execute_BRANCH_COND_RESULT = _zz_execute_BRANCH_COND_RESULT_1;
  assign execute_BRANCH_CTRL = _zz_execute_BRANCH_CTRL;
  assign decode_RS2_USE = _zz_decode_IS_CSR[14];
  assign decode_RS1_USE = _zz_decode_IS_CSR[4];
  always @(*) begin
    _zz_decode_RS2 = execute_REGFILE_WRITE_DATA;
    if(when_CsrPlugin_l1587) begin
      _zz_decode_RS2 = CsrPlugin_csrMapping_readDataSignal;
    end
  end

  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
  assign memory_BYPASSABLE_MEMORY_STAGE = execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
  always @(*) begin
    decode_RS2 = decode_RegFilePlugin_rs2Data;
    if(HazardSimplePlugin_writeBackBuffer_valid) begin
      if(HazardSimplePlugin_addr1Match) begin
        decode_RS2 = HazardSimplePlugin_writeBackBuffer_payload_data;
      end
    end
    if(when_HazardSimplePlugin_l45) begin
      if(when_HazardSimplePlugin_l47) begin
        if(when_HazardSimplePlugin_l51) begin
          decode_RS2 = _zz_decode_RS2_2;
        end
      end
    end
    if(when_HazardSimplePlugin_l45_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l51_1) begin
          decode_RS2 = _zz_decode_RS2_1;
        end
      end
    end
    if(when_HazardSimplePlugin_l45_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l51_2) begin
          decode_RS2 = _zz_decode_RS2;
        end
      end
    end
  end

  always @(*) begin
    decode_RS1 = decode_RegFilePlugin_rs1Data;
    if(HazardSimplePlugin_writeBackBuffer_valid) begin
      if(HazardSimplePlugin_addr0Match) begin
        decode_RS1 = HazardSimplePlugin_writeBackBuffer_payload_data;
      end
    end
    if(when_HazardSimplePlugin_l45) begin
      if(when_HazardSimplePlugin_l47) begin
        if(when_HazardSimplePlugin_l48) begin
          decode_RS1 = _zz_decode_RS2_2;
        end
      end
    end
    if(when_HazardSimplePlugin_l45_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l48_1) begin
          decode_RS1 = _zz_decode_RS2_1;
        end
      end
    end
    if(when_HazardSimplePlugin_l45_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l48_2) begin
          decode_RS1 = _zz_decode_RS2;
        end
      end
    end
  end

  assign execute_IS_RS1_SIGNED = decode_to_execute_IS_RS1_SIGNED;
  assign execute_IS_DIV = decode_to_execute_IS_DIV;
  assign execute_IS_RS2_SIGNED = decode_to_execute_IS_RS2_SIGNED;
  assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
  assign memory_IS_DIV = execute_to_memory_IS_DIV;
  assign writeBack_IS_MUL = memory_to_writeBack_IS_MUL;
  assign writeBack_MUL_HH = memory_to_writeBack_MUL_HH;
  assign writeBack_MUL_LOW = memory_to_writeBack_MUL_LOW;
  assign memory_MUL_HL = execute_to_memory_MUL_HL;
  assign memory_MUL_LH = execute_to_memory_MUL_LH;
  assign memory_MUL_LL = execute_to_memory_MUL_LL;
  assign execute_RS1 = decode_to_execute_RS1;
  assign memory_SHIFT_RIGHT = execute_to_memory_SHIFT_RIGHT;
  always @(*) begin
    _zz_decode_RS2_1 = memory_REGFILE_WRITE_DATA;
    if(memory_arbitration_isValid) begin
      case(memory_SHIFT_CTRL)
        vexShiftCtrlEnum_SLL_1 : begin
          _zz_decode_RS2_1 = _zz_decode_RS2_3;
        end
        vexShiftCtrlEnum_SRL_1, vexShiftCtrlEnum_SRA_1 : begin
          _zz_decode_RS2_1 = memory_SHIFT_RIGHT;
        end
        default : begin
        end
      endcase
    end
    if(when_MulDivIterativePlugin_l128) begin
      _zz_decode_RS2_1 = memory_DivPlugin_div_result;
    end
  end

  assign memory_SHIFT_CTRL = _zz_memory_SHIFT_CTRL;
  assign execute_SHIFT_CTRL = _zz_execute_SHIFT_CTRL;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign execute_SRC2_FORCE_ZERO = decode_to_execute_SRC2_FORCE_ZERO;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign _zz_execute_to_memory_PC = execute_PC;
  assign execute_SRC2_CTRL = _zz_execute_SRC2_CTRL;
  assign execute_SRC1_CTRL = _zz_execute_SRC1_CTRL;
  assign decode_SRC_USE_SUB_LESS = _zz_decode_IS_CSR[2];
  assign decode_SRC_ADD_ZERO = _zz_decode_IS_CSR[18];
  assign execute_SRC_ADD_SUB = execute_SrcPlugin_addSub;
  assign execute_SRC_LESS = execute_SrcPlugin_less;
  assign execute_ALU_CTRL = _zz_execute_ALU_CTRL;
  assign execute_SRC2 = _zz_execute_SRC2_4;
  assign execute_SRC1 = _zz_execute_SRC1;
  assign execute_ALU_BITWISE_CTRL = _zz_execute_ALU_BITWISE_CTRL;
  assign _zz_lastStageRegFileWrite_payload_address = writeBack_INSTRUCTION;
  assign _zz_lastStageRegFileWrite_valid = writeBack_REGFILE_WRITE_VALID;
  always @(*) begin
    _zz_1 = 1'b0;
    if(lastStageRegFileWrite_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign decode_INSTRUCTION_ANTICIPATED = (decode_arbitration_isStuck ? decode_INSTRUCTION : IBusSimplePlugin_iBusRsp_output_payload_rsp_inst);
  always @(*) begin
    decode_REGFILE_WRITE_VALID = _zz_decode_IS_CSR[9];
    if(when_RegFilePlugin_l63) begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  assign decode_LEGAL_INSTRUCTION = (|{((decode_INSTRUCTION & 32'h0000005f) == 32'h00000017),{((decode_INSTRUCTION & 32'h0000007f) == 32'h0000006f),{((decode_INSTRUCTION & _zz_decode_LEGAL_INSTRUCTION) == 32'h00001073),{(_zz_decode_LEGAL_INSTRUCTION_1 == _zz_decode_LEGAL_INSTRUCTION_2),{_zz_decode_LEGAL_INSTRUCTION_3,{_zz_decode_LEGAL_INSTRUCTION_4,_zz_decode_LEGAL_INSTRUCTION_5}}}}}});
  always @(*) begin
    _zz_decode_RS2_2 = writeBack_REGFILE_WRITE_DATA;
    if(when_DBusSimplePlugin_l566) begin
      _zz_decode_RS2_2 = writeBack_DBusSimplePlugin_rspFormated;
    end
    if(when_MulPlugin_l147) begin
      case(switch_MulPlugin_l148)
        2'b00 : begin
          _zz_decode_RS2_2 = _zz__zz_decode_RS2_2;
        end
        default : begin
          _zz_decode_RS2_2 = _zz__zz_decode_RS2_2_1;
        end
      endcase
    end
  end

  assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
  assign writeBack_MEMORY_ADDRESS_LOW = memory_to_writeBack_MEMORY_ADDRESS_LOW;
  assign writeBack_MEMORY_READ_DATA = memory_to_writeBack_MEMORY_READ_DATA;
  assign memory_ALIGNEMENT_FAULT = execute_to_memory_ALIGNEMENT_FAULT;
  assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
  assign memory_MEMORY_STORE = execute_to_memory_MEMORY_STORE;
  assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
  assign execute_SRC_ADD = execute_SrcPlugin_addSub;
  assign execute_RS2 = decode_to_execute_RS2;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign execute_MEMORY_STORE = decode_to_execute_MEMORY_STORE;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  assign execute_ALIGNEMENT_FAULT = (((dBus_cmd_payload_size == 2'b10) && (dBus_cmd_payload_address[1 : 0] != 2'b00)) || ((dBus_cmd_payload_size == 2'b01) && (dBus_cmd_payload_address[0 : 0] != 1'b0)));
  assign decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_1;
  always @(*) begin
    _zz_memory_to_writeBack_FORMAL_PC_NEXT = memory_FORMAL_PC_NEXT;
    if(BranchPlugin_jumpInterface_valid) begin
      _zz_memory_to_writeBack_FORMAL_PC_NEXT = BranchPlugin_jumpInterface_payload;
    end
  end

  always @(*) begin
    _zz_decode_to_execute_FORMAL_PC_NEXT = decode_FORMAL_PC_NEXT;
    if(IBusSimplePlugin_predictionJumpInterface_valid) begin
      _zz_decode_to_execute_FORMAL_PC_NEXT = IBusSimplePlugin_predictionJumpInterface_payload;
    end
  end

  assign decode_PC = IBusSimplePlugin_injector_decodeInput_payload_pc;
  assign decode_INSTRUCTION = IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  assign writeBack_PC = memory_to_writeBack_PC;
  assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
  assign decode_arbitration_haltItself = 1'b0;
  always @(*) begin
    decode_arbitration_haltByOther = 1'b0;
    if(when_HazardSimplePlugin_l113) begin
      decode_arbitration_haltByOther = 1'b1;
    end
    if(CsrPlugin_pipelineLiberator_active) begin
      decode_arbitration_haltByOther = 1'b1;
    end
    if(when_CsrPlugin_l1527) begin
      decode_arbitration_haltByOther = 1'b1;
    end
  end

  always @(*) begin
    decode_arbitration_removeIt = 1'b0;
    if(_zz_when) begin
      decode_arbitration_removeIt = 1'b1;
    end
    if(decode_arbitration_isFlushed) begin
      decode_arbitration_removeIt = 1'b1;
    end
  end

  assign decode_arbitration_flushIt = 1'b0;
  always @(*) begin
    decode_arbitration_flushNext = 1'b0;
    if(IBusSimplePlugin_predictionJumpInterface_valid) begin
      decode_arbitration_flushNext = 1'b1;
    end
    if(_zz_when) begin
      decode_arbitration_flushNext = 1'b1;
    end
  end

  always @(*) begin
    execute_arbitration_haltItself = 1'b0;
    if(when_DBusSimplePlugin_l435) begin
      execute_arbitration_haltItself = 1'b1;
    end
    if(when_CsrPlugin_l1591) begin
      if(execute_CsrPlugin_blockedBySideEffects) begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
  end

  assign execute_arbitration_haltByOther = 1'b0;
  always @(*) begin
    execute_arbitration_removeIt = 1'b0;
    if(execute_arbitration_isFlushed) begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  assign execute_arbitration_flushIt = 1'b0;
  assign execute_arbitration_flushNext = 1'b0;
  always @(*) begin
    memory_arbitration_haltItself = 1'b0;
    if(when_DBusSimplePlugin_l490) begin
      memory_arbitration_haltItself = 1'b1;
    end
    if(when_MulDivIterativePlugin_l128) begin
      if(when_MulDivIterativePlugin_l129) begin
        memory_arbitration_haltItself = 1'b1;
      end
    end
  end

  assign memory_arbitration_haltByOther = 1'b0;
  always @(*) begin
    memory_arbitration_removeIt = 1'b0;
    if(_zz_when_1) begin
      memory_arbitration_removeIt = 1'b1;
    end
    if(memory_arbitration_isFlushed) begin
      memory_arbitration_removeIt = 1'b1;
    end
  end

  assign memory_arbitration_flushIt = 1'b0;
  always @(*) begin
    memory_arbitration_flushNext = 1'b0;
    if(BranchPlugin_jumpInterface_valid) begin
      memory_arbitration_flushNext = 1'b1;
    end
    if(_zz_when_1) begin
      memory_arbitration_flushNext = 1'b1;
    end
  end

  assign writeBack_arbitration_haltItself = 1'b0;
  assign writeBack_arbitration_haltByOther = 1'b0;
  always @(*) begin
    writeBack_arbitration_removeIt = 1'b0;
    if(writeBack_arbitration_isFlushed) begin
      writeBack_arbitration_removeIt = 1'b1;
    end
  end

  assign writeBack_arbitration_flushIt = 1'b0;
  always @(*) begin
    writeBack_arbitration_flushNext = 1'b0;
    if(when_CsrPlugin_l1390) begin
      writeBack_arbitration_flushNext = 1'b1;
    end
    if(when_CsrPlugin_l1456) begin
      writeBack_arbitration_flushNext = 1'b1;
    end
  end

  assign lastStageInstruction = writeBack_INSTRUCTION;
  assign lastStagePc = writeBack_PC;
  assign lastStageIsValid = writeBack_arbitration_isValid;
  assign lastStageIsFiring = writeBack_arbitration_isFiring;
  always @(*) begin
    IBusSimplePlugin_fetcherHalt = 1'b0;
    if(when_CsrPlugin_l1272) begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
    end
    if(when_CsrPlugin_l1390) begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
    end
    if(when_CsrPlugin_l1456) begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
    end
  end

  assign IBusSimplePlugin_forceNoDecodeCond = 1'b0;
  always @(*) begin
    IBusSimplePlugin_incomingInstruction = 1'b0;
    if(IBusSimplePlugin_iBusRsp_stages_1_input_valid) begin
      IBusSimplePlugin_incomingInstruction = 1'b1;
    end
    if(IBusSimplePlugin_injector_decodeInput_valid) begin
      IBusSimplePlugin_incomingInstruction = 1'b1;
    end
  end

  assign BranchPlugin_inDebugNoFetchFlag = 1'b0;
  always @(*) begin
    CsrPlugin_csrMapping_allowCsrSignal = 1'b0;
    if(when_CsrPlugin_l1702) begin
      CsrPlugin_csrMapping_allowCsrSignal = 1'b1;
    end
    if(when_CsrPlugin_l1709) begin
      CsrPlugin_csrMapping_allowCsrSignal = 1'b1;
    end
  end

  assign CsrPlugin_csrMapping_doForceFailCsr = 1'b0;
  assign CsrPlugin_csrMapping_readDataSignal = CsrPlugin_csrMapping_readDataInit;
  assign CsrPlugin_inWfi = 1'b0;
  assign CsrPlugin_thirdPartyWake = 1'b0;
  always @(*) begin
    CsrPlugin_jumpInterface_valid = 1'b0;
    if(when_CsrPlugin_l1390) begin
      CsrPlugin_jumpInterface_valid = 1'b1;
    end
    if(when_CsrPlugin_l1456) begin
      CsrPlugin_jumpInterface_valid = 1'b1;
    end
  end

  always @(*) begin
    CsrPlugin_jumpInterface_payload = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    if(when_CsrPlugin_l1390) begin
      CsrPlugin_jumpInterface_payload = {CsrPlugin_xtvec_base,2'b00};
    end
    if(when_CsrPlugin_l1456) begin
      case(switch_CsrPlugin_l1460)
        2'b11 : begin
          CsrPlugin_jumpInterface_payload = CsrPlugin_mepc;
        end
        default : begin
        end
      endcase
    end
  end

  assign CsrPlugin_forceMachineWire = 1'b0;
  assign CsrPlugin_allowInterrupts = 1'b1;
  assign CsrPlugin_allowException = 1'b1;
  assign CsrPlugin_allowEbreakException = 1'b1;
  assign CsrPlugin_xretAwayFromMachine = 1'b0;
  assign IBusSimplePlugin_externalFlush = (|{writeBack_arbitration_flushNext,{memory_arbitration_flushNext,{execute_arbitration_flushNext,decode_arbitration_flushNext}}});
  assign IBusSimplePlugin_jump_pcLoad_valid = (|{CsrPlugin_jumpInterface_valid,{BranchPlugin_jumpInterface_valid,IBusSimplePlugin_predictionJumpInterface_valid}});
  assign _zz_IBusSimplePlugin_jump_pcLoad_payload = {IBusSimplePlugin_predictionJumpInterface_valid,{BranchPlugin_jumpInterface_valid,CsrPlugin_jumpInterface_valid}};
  assign _zz_IBusSimplePlugin_jump_pcLoad_payload_1 = (_zz_IBusSimplePlugin_jump_pcLoad_payload & (~ _zz__zz_IBusSimplePlugin_jump_pcLoad_payload_1));
  assign _zz_IBusSimplePlugin_jump_pcLoad_payload_2 = _zz_IBusSimplePlugin_jump_pcLoad_payload_1[1];
  assign _zz_IBusSimplePlugin_jump_pcLoad_payload_3 = _zz_IBusSimplePlugin_jump_pcLoad_payload_1[2];
  assign IBusSimplePlugin_jump_pcLoad_payload = _zz_IBusSimplePlugin_jump_pcLoad_payload_4;
  always @(*) begin
    IBusSimplePlugin_fetchPc_correction = 1'b0;
    if(IBusSimplePlugin_jump_pcLoad_valid) begin
      IBusSimplePlugin_fetchPc_correction = 1'b1;
    end
  end

  assign IBusSimplePlugin_fetchPc_output_fire = (IBusSimplePlugin_fetchPc_output_valid && IBusSimplePlugin_fetchPc_output_ready);
  assign IBusSimplePlugin_fetchPc_corrected = (IBusSimplePlugin_fetchPc_correction || IBusSimplePlugin_fetchPc_correctionReg);
  always @(*) begin
    IBusSimplePlugin_fetchPc_pcRegPropagate = 1'b0;
    if(IBusSimplePlugin_iBusRsp_stages_1_input_ready) begin
      IBusSimplePlugin_fetchPc_pcRegPropagate = 1'b1;
    end
  end

  assign when_Fetcher_l133 = (IBusSimplePlugin_fetchPc_correction || IBusSimplePlugin_fetchPc_pcRegPropagate);
  assign when_Fetcher_l133_1 = ((! IBusSimplePlugin_fetchPc_output_valid) && IBusSimplePlugin_fetchPc_output_ready);
  always @(*) begin
    IBusSimplePlugin_fetchPc_pc = (IBusSimplePlugin_fetchPc_pcReg + _zz_IBusSimplePlugin_fetchPc_pc);
    if(IBusSimplePlugin_jump_pcLoad_valid) begin
      IBusSimplePlugin_fetchPc_pc = IBusSimplePlugin_jump_pcLoad_payload;
    end
    IBusSimplePlugin_fetchPc_pc[0] = 1'b0;
    IBusSimplePlugin_fetchPc_pc[1] = 1'b0;
  end

  always @(*) begin
    IBusSimplePlugin_fetchPc_flushed = 1'b0;
    if(IBusSimplePlugin_jump_pcLoad_valid) begin
      IBusSimplePlugin_fetchPc_flushed = 1'b1;
    end
  end

  assign when_Fetcher_l160 = (IBusSimplePlugin_fetchPc_booted && ((IBusSimplePlugin_fetchPc_output_ready || IBusSimplePlugin_fetchPc_correction) || IBusSimplePlugin_fetchPc_pcRegPropagate));
  assign IBusSimplePlugin_fetchPc_output_valid = ((! IBusSimplePlugin_fetcherHalt) && IBusSimplePlugin_fetchPc_booted);
  assign IBusSimplePlugin_fetchPc_output_payload = IBusSimplePlugin_fetchPc_pc;
  assign IBusSimplePlugin_iBusRsp_redoFetch = 1'b0;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_valid = IBusSimplePlugin_fetchPc_output_valid;
  assign IBusSimplePlugin_fetchPc_output_ready = IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_payload = IBusSimplePlugin_fetchPc_output_payload;
  always @(*) begin
    IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b0;
    if(when_IBusSimplePlugin_l306) begin
      IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b1;
    end
  end

  assign _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready = (! IBusSimplePlugin_iBusRsp_stages_0_halt);
  assign IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready);
  assign IBusSimplePlugin_iBusRsp_stages_0_input_ready = (IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_ready && _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready);
  assign IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_payload = IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_valid = IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_valid;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_ready = IBusSimplePlugin_iBusRsp_stages_0_output_ready;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_payload = IBusSimplePlugin_iBusRsp_stages_0_input_haltWhen_payload;
  assign IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b0;
  assign _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready = (! IBusSimplePlugin_iBusRsp_stages_1_halt);
  assign IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready);
  assign IBusSimplePlugin_iBusRsp_stages_1_input_ready = (IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_ready && _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready);
  assign IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_payload = IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_1_output_valid = IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_valid;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_ready = IBusSimplePlugin_iBusRsp_stages_1_output_ready;
  assign IBusSimplePlugin_iBusRsp_stages_1_output_payload = IBusSimplePlugin_iBusRsp_stages_1_input_haltWhen_payload;
  assign IBusSimplePlugin_iBusRsp_flush = (IBusSimplePlugin_externalFlush || IBusSimplePlugin_iBusRsp_redoFetch);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_valid = IBusSimplePlugin_iBusRsp_stages_0_output_valid;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_ready = IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_ready;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_ready = ((1'b0 && (! IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid)) || IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_ready);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid = _zz_IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_valid = IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_ready = IBusSimplePlugin_iBusRsp_stages_1_input_ready;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_payload = IBusSimplePlugin_fetchPc_pcReg;
  always @(*) begin
    IBusSimplePlugin_iBusRsp_readyForError = 1'b1;
    if(IBusSimplePlugin_injector_decodeInput_valid) begin
      IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
    end
    if(when_Fetcher_l322) begin
      IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
    end
  end

  assign IBusSimplePlugin_iBusRsp_output_ready = ((1'b0 && (! IBusSimplePlugin_injector_decodeInput_valid)) || IBusSimplePlugin_injector_decodeInput_ready);
  assign IBusSimplePlugin_injector_decodeInput_valid = _zz_IBusSimplePlugin_injector_decodeInput_valid;
  assign IBusSimplePlugin_injector_decodeInput_payload_pc = _zz_IBusSimplePlugin_injector_decodeInput_payload_pc;
  assign IBusSimplePlugin_injector_decodeInput_payload_rsp_error = _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
  assign IBusSimplePlugin_injector_decodeInput_payload_rsp_inst = _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  assign IBusSimplePlugin_injector_decodeInput_payload_isRvc = _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc;
  assign when_Fetcher_l322 = (! IBusSimplePlugin_pcValids_0);
  assign when_Fetcher_l331 = (! (! IBusSimplePlugin_iBusRsp_stages_1_input_ready));
  assign when_Fetcher_l331_1 = (! (! IBusSimplePlugin_injector_decodeInput_ready));
  assign when_Fetcher_l331_2 = (! execute_arbitration_isStuck);
  assign when_Fetcher_l331_3 = (! memory_arbitration_isStuck);
  assign when_Fetcher_l331_4 = (! writeBack_arbitration_isStuck);
  assign IBusSimplePlugin_pcValids_0 = IBusSimplePlugin_injector_nextPcCalc_valids_1;
  assign IBusSimplePlugin_pcValids_1 = IBusSimplePlugin_injector_nextPcCalc_valids_2;
  assign IBusSimplePlugin_pcValids_2 = IBusSimplePlugin_injector_nextPcCalc_valids_3;
  assign IBusSimplePlugin_pcValids_3 = IBusSimplePlugin_injector_nextPcCalc_valids_4;
  assign IBusSimplePlugin_injector_decodeInput_ready = (! decode_arbitration_isStuck);
  always @(*) begin
    decode_arbitration_isValid = IBusSimplePlugin_injector_decodeInput_valid;
    if(IBusSimplePlugin_forceNoDecodeCond) begin
      decode_arbitration_isValid = 1'b0;
    end
  end

  assign _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch = _zz__zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch[11];
  always @(*) begin
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[18] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[17] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[16] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[15] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[14] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[13] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[12] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[11] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[10] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[9] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[8] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[7] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[6] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[5] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[4] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[3] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[2] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[1] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_1[0] = _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch;
  end

  always @(*) begin
    IBusSimplePlugin_decodePrediction_cmd_hadBranch = ((decode_BRANCH_CTRL == vexBranchCtrlEnum_JAL) || ((decode_BRANCH_CTRL == vexBranchCtrlEnum_B) && _zz_IBusSimplePlugin_decodePrediction_cmd_hadBranch_2[31]));
    if(_zz_6) begin
      IBusSimplePlugin_decodePrediction_cmd_hadBranch = 1'b0;
    end
  end

  assign _zz_2 = _zz__zz_2[19];
  always @(*) begin
    _zz_3[10] = _zz_2;
    _zz_3[9] = _zz_2;
    _zz_3[8] = _zz_2;
    _zz_3[7] = _zz_2;
    _zz_3[6] = _zz_2;
    _zz_3[5] = _zz_2;
    _zz_3[4] = _zz_2;
    _zz_3[3] = _zz_2;
    _zz_3[2] = _zz_2;
    _zz_3[1] = _zz_2;
    _zz_3[0] = _zz_2;
  end

  assign _zz_4 = _zz__zz_4[11];
  always @(*) begin
    _zz_5[18] = _zz_4;
    _zz_5[17] = _zz_4;
    _zz_5[16] = _zz_4;
    _zz_5[15] = _zz_4;
    _zz_5[14] = _zz_4;
    _zz_5[13] = _zz_4;
    _zz_5[12] = _zz_4;
    _zz_5[11] = _zz_4;
    _zz_5[10] = _zz_4;
    _zz_5[9] = _zz_4;
    _zz_5[8] = _zz_4;
    _zz_5[7] = _zz_4;
    _zz_5[6] = _zz_4;
    _zz_5[5] = _zz_4;
    _zz_5[4] = _zz_4;
    _zz_5[3] = _zz_4;
    _zz_5[2] = _zz_4;
    _zz_5[1] = _zz_4;
    _zz_5[0] = _zz_4;
  end

  always @(*) begin
    case(decode_BRANCH_CTRL)
      vexBranchCtrlEnum_JAL : begin
        _zz_6 = _zz__zz_6[1];
      end
      default : begin
        _zz_6 = _zz__zz_6_1[1];
      end
    endcase
  end

  assign IBusSimplePlugin_predictionJumpInterface_valid = (decode_arbitration_isValid && IBusSimplePlugin_decodePrediction_cmd_hadBranch);
  assign _zz_IBusSimplePlugin_predictionJumpInterface_payload = _zz__zz_IBusSimplePlugin_predictionJumpInterface_payload[19];
  always @(*) begin
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[10] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[9] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[8] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[7] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[6] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[5] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[4] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[3] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[2] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[1] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_1[0] = _zz_IBusSimplePlugin_predictionJumpInterface_payload;
  end

  assign _zz_IBusSimplePlugin_predictionJumpInterface_payload_2 = _zz__zz_IBusSimplePlugin_predictionJumpInterface_payload_2[11];
  always @(*) begin
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[18] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[17] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[16] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[15] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[14] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[13] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[12] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[11] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[10] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[9] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[8] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[7] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[6] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[5] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[4] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[3] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[2] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[1] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
    _zz_IBusSimplePlugin_predictionJumpInterface_payload_3[0] = _zz_IBusSimplePlugin_predictionJumpInterface_payload_2;
  end

  assign IBusSimplePlugin_predictionJumpInterface_payload = (decode_PC + ((decode_BRANCH_CTRL == vexBranchCtrlEnum_JAL) ? {{_zz_IBusSimplePlugin_predictionJumpInterface_payload_1,{{{_zz_IBusSimplePlugin_predictionJumpInterface_payload_4,decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_IBusSimplePlugin_predictionJumpInterface_payload_3,{{{_zz_IBusSimplePlugin_predictionJumpInterface_payload_5,_zz_IBusSimplePlugin_predictionJumpInterface_payload_6},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0}));
  assign IBusSimplePlugin_cmd_ready = IBusSimplePlugin_cmd_rValidN;
  assign IBusSimplePlugin_cmd_s2mPipe_valid = (IBusSimplePlugin_cmd_valid || (! IBusSimplePlugin_cmd_rValidN));
  assign IBusSimplePlugin_cmd_s2mPipe_payload_pc = (IBusSimplePlugin_cmd_rValidN ? IBusSimplePlugin_cmd_payload_pc : IBusSimplePlugin_cmd_rData_pc);
  assign iBus_cmd_valid = IBusSimplePlugin_cmd_s2mPipe_valid;
  assign IBusSimplePlugin_cmd_s2mPipe_ready = iBus_cmd_ready;
  assign iBus_cmd_payload_pc = IBusSimplePlugin_cmd_s2mPipe_payload_pc;
  assign IBusSimplePlugin_pending_next = (_zz_IBusSimplePlugin_pending_next - _zz_IBusSimplePlugin_pending_next_3);
  assign IBusSimplePlugin_cmdFork_canEmit = (IBusSimplePlugin_iBusRsp_stages_0_output_ready && (IBusSimplePlugin_pending_value != 3'b111));
  assign when_IBusSimplePlugin_l306 = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && ((! IBusSimplePlugin_cmdFork_canEmit) || (! IBusSimplePlugin_cmd_ready)));
  assign IBusSimplePlugin_cmd_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && IBusSimplePlugin_cmdFork_canEmit);
  assign IBusSimplePlugin_cmd_fire = (IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready);
  assign IBusSimplePlugin_pending_inc = IBusSimplePlugin_cmd_fire;
  assign IBusSimplePlugin_cmd_payload_pc = {IBusSimplePlugin_iBusRsp_stages_0_input_payload[31 : 2],2'b00};
  assign iBus_rsp_toStream_valid = iBus_rsp_valid;
  assign iBus_rsp_toStream_payload_error = iBus_rsp_payload_error;
  assign iBus_rsp_toStream_payload_inst = iBus_rsp_payload_inst;
  assign iBus_rsp_toStream_ready = IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
  assign IBusSimplePlugin_rspJoin_rspBuffer_flush = ((IBusSimplePlugin_rspJoin_rspBuffer_discardCounter != 3'b000) || IBusSimplePlugin_iBusRsp_flush);
  assign IBusSimplePlugin_rspJoin_rspBuffer_output_valid = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter == 3'b000));
  assign IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
  assign IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
  assign IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready = (IBusSimplePlugin_rspJoin_rspBuffer_output_ready || IBusSimplePlugin_rspJoin_rspBuffer_flush);
  assign IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready);
  assign IBusSimplePlugin_pending_dec = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire;
  assign IBusSimplePlugin_rspJoin_fetchRsp_isRvc = 1'b0;
  assign IBusSimplePlugin_rspJoin_fetchRsp_pc = IBusSimplePlugin_iBusRsp_stages_1_output_payload;
  always @(*) begin
    IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error;
    if(when_IBusSimplePlugin_l378) begin
      IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = 1'b0;
    end
  end

  assign IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst = IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst;
  assign when_IBusSimplePlugin_l378 = (! IBusSimplePlugin_rspJoin_rspBuffer_output_valid);
  always @(*) begin
    IBusSimplePlugin_rspJoin_exceptionDetected = 1'b0;
    if(when_IBusSimplePlugin_l404) begin
      IBusSimplePlugin_rspJoin_exceptionDetected = 1'b1;
    end
  end

  assign IBusSimplePlugin_rspJoin_join_valid = (IBusSimplePlugin_iBusRsp_stages_1_output_valid && IBusSimplePlugin_rspJoin_rspBuffer_output_valid);
  assign IBusSimplePlugin_rspJoin_join_payload_pc = IBusSimplePlugin_rspJoin_fetchRsp_pc;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_error = IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_inst = IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  assign IBusSimplePlugin_rspJoin_join_payload_isRvc = IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  assign IBusSimplePlugin_rspJoin_join_fire = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_valid ? IBusSimplePlugin_rspJoin_join_fire : IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_rspJoin_rspBuffer_output_ready = IBusSimplePlugin_rspJoin_join_fire;
  assign _zz_IBusSimplePlugin_rspJoin_join_ready = (! IBusSimplePlugin_rspJoin_exceptionDetected);
  assign IBusSimplePlugin_rspJoin_join_haltWhen_valid = (IBusSimplePlugin_rspJoin_join_valid && _zz_IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_rspJoin_join_ready = (IBusSimplePlugin_rspJoin_join_haltWhen_ready && _zz_IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_rspJoin_join_haltWhen_payload_pc = IBusSimplePlugin_rspJoin_join_payload_pc;
  assign IBusSimplePlugin_rspJoin_join_haltWhen_payload_rsp_error = IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  assign IBusSimplePlugin_rspJoin_join_haltWhen_payload_rsp_inst = IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  assign IBusSimplePlugin_rspJoin_join_haltWhen_payload_isRvc = IBusSimplePlugin_rspJoin_join_payload_isRvc;
  assign IBusSimplePlugin_iBusRsp_output_valid = IBusSimplePlugin_rspJoin_join_haltWhen_valid;
  assign IBusSimplePlugin_rspJoin_join_haltWhen_ready = IBusSimplePlugin_iBusRsp_output_ready;
  assign IBusSimplePlugin_iBusRsp_output_payload_pc = IBusSimplePlugin_rspJoin_join_haltWhen_payload_pc;
  assign IBusSimplePlugin_iBusRsp_output_payload_rsp_error = IBusSimplePlugin_rspJoin_join_haltWhen_payload_rsp_error;
  assign IBusSimplePlugin_iBusRsp_output_payload_rsp_inst = IBusSimplePlugin_rspJoin_join_haltWhen_payload_rsp_inst;
  assign IBusSimplePlugin_iBusRsp_output_payload_isRvc = IBusSimplePlugin_rspJoin_join_haltWhen_payload_isRvc;
  always @(*) begin
    IBusSimplePlugin_decodeExceptionPort_payload_code = 4'bxxxx;
    if(when_IBusSimplePlugin_l404) begin
      IBusSimplePlugin_decodeExceptionPort_payload_code = 4'b0001;
    end
  end

  assign IBusSimplePlugin_decodeExceptionPort_payload_badAddr = {IBusSimplePlugin_rspJoin_join_payload_pc[31 : 2],2'b00};
  assign when_IBusSimplePlugin_l404 = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_payload_rsp_error);
  assign IBusSimplePlugin_decodeExceptionPort_valid = (IBusSimplePlugin_rspJoin_exceptionDetected && IBusSimplePlugin_iBusRsp_readyForError);
  assign _zz_dBus_cmd_valid = 1'b0;
  always @(*) begin
    execute_DBusSimplePlugin_skipCmd = 1'b0;
    if(execute_ALIGNEMENT_FAULT) begin
      execute_DBusSimplePlugin_skipCmd = 1'b1;
    end
  end

  assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_DBusSimplePlugin_skipCmd)) && (! _zz_dBus_cmd_valid));
  assign dBus_cmd_payload_wr = execute_MEMORY_STORE;
  assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
  always @(*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_dBus_cmd_payload_data = {{{execute_RS2[7 : 0],execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_dBus_cmd_payload_data = {execute_RS2[15 : 0],execute_RS2[15 : 0]};
      end
      default : begin
        _zz_dBus_cmd_payload_data = execute_RS2[31 : 0];
      end
    endcase
  end

  assign dBus_cmd_payload_data = _zz_dBus_cmd_payload_data;
  assign when_DBusSimplePlugin_l435 = ((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_DBusSimplePlugin_skipCmd)) && (! _zz_dBus_cmd_valid));
  always @(*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_execute_DBusSimplePlugin_formalMask = 4'b0001;
      end
      2'b01 : begin
        _zz_execute_DBusSimplePlugin_formalMask = 4'b0011;
      end
      default : begin
        _zz_execute_DBusSimplePlugin_formalMask = 4'b1111;
      end
    endcase
  end

  assign execute_DBusSimplePlugin_formalMask = (_zz_execute_DBusSimplePlugin_formalMask <<< dBus_cmd_payload_address[1 : 0]);
  assign dBus_cmd_payload_mask = execute_DBusSimplePlugin_formalMask;
  assign dBus_cmd_payload_address = execute_SRC_ADD;
  assign when_DBusSimplePlugin_l490 = (((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! memory_MEMORY_STORE)) && ((! dBus_rsp_ready) || 1'b0));
  always @(*) begin
    DBusSimplePlugin_memoryExceptionPort_valid = 1'b0;
    if(when_DBusSimplePlugin_l497) begin
      DBusSimplePlugin_memoryExceptionPort_valid = 1'b1;
    end
    if(memory_ALIGNEMENT_FAULT) begin
      DBusSimplePlugin_memoryExceptionPort_valid = 1'b1;
    end
    if(when_DBusSimplePlugin_l523) begin
      DBusSimplePlugin_memoryExceptionPort_valid = 1'b0;
    end
  end

  always @(*) begin
    DBusSimplePlugin_memoryExceptionPort_payload_code = 4'bxxxx;
    if(when_DBusSimplePlugin_l497) begin
      DBusSimplePlugin_memoryExceptionPort_payload_code = 4'b0101;
    end
    if(memory_ALIGNEMENT_FAULT) begin
      DBusSimplePlugin_memoryExceptionPort_payload_code = {1'd0, _zz_DBusSimplePlugin_memoryExceptionPort_payload_code};
    end
  end

  assign DBusSimplePlugin_memoryExceptionPort_payload_badAddr = memory_REGFILE_WRITE_DATA;
  assign when_DBusSimplePlugin_l497 = ((dBus_rsp_ready && dBus_rsp_error) && (! memory_MEMORY_STORE));
  assign when_DBusSimplePlugin_l523 = (! ((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (1'b1 || (! memory_arbitration_isStuckByOthers))));
  always @(*) begin
    writeBack_DBusSimplePlugin_rspShifted = writeBack_MEMORY_READ_DATA;
    case(writeBack_MEMORY_ADDRESS_LOW)
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[15 : 8];
      end
      2'b10 : begin
        writeBack_DBusSimplePlugin_rspShifted[15 : 0] = writeBack_MEMORY_READ_DATA[31 : 16];
      end
      2'b11 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[31 : 24];
      end
      default : begin
      end
    endcase
  end

  assign switch_Misc_l245 = writeBack_INSTRUCTION[13 : 12];
  assign _zz_writeBack_DBusSimplePlugin_rspFormated = (writeBack_DBusSimplePlugin_rspShifted[7] && (! writeBack_INSTRUCTION[14]));
  always @(*) begin
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[31] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[30] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[29] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[28] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[27] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[26] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[25] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[24] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[23] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[22] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[21] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[20] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[19] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[18] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[17] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[16] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[15] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[14] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[13] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[12] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[11] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[10] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[9] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[8] = _zz_writeBack_DBusSimplePlugin_rspFormated;
    _zz_writeBack_DBusSimplePlugin_rspFormated_1[7 : 0] = writeBack_DBusSimplePlugin_rspShifted[7 : 0];
  end

  assign _zz_writeBack_DBusSimplePlugin_rspFormated_2 = (writeBack_DBusSimplePlugin_rspShifted[15] && (! writeBack_INSTRUCTION[14]));
  always @(*) begin
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[31] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[30] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[29] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[28] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[27] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[26] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[25] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[24] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[23] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[22] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[21] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[20] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[19] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[18] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[17] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[16] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    _zz_writeBack_DBusSimplePlugin_rspFormated_3[15 : 0] = writeBack_DBusSimplePlugin_rspShifted[15 : 0];
  end

  always @(*) begin
    case(switch_Misc_l245)
      2'b00 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_writeBack_DBusSimplePlugin_rspFormated_1;
      end
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_writeBack_DBusSimplePlugin_rspFormated_3;
      end
      default : begin
        writeBack_DBusSimplePlugin_rspFormated = writeBack_DBusSimplePlugin_rspShifted;
      end
    endcase
  end

  assign when_DBusSimplePlugin_l566 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
  assign _zz_decode_IS_CSR_1 = ((decode_INSTRUCTION & 32'h00004050) == 32'h00004050);
  assign _zz_decode_IS_CSR_2 = ((decode_INSTRUCTION & 32'h00000018) == 32'h0);
  assign _zz_decode_IS_CSR_3 = ((decode_INSTRUCTION & 32'h00000004) == 32'h00000004);
  assign _zz_decode_IS_CSR_4 = ((decode_INSTRUCTION & 32'h00000048) == 32'h00000048);
  assign _zz_decode_IS_CSR_5 = ((decode_INSTRUCTION & 32'h00001000) == 32'h0);
  assign _zz_decode_IS_CSR = {(|((decode_INSTRUCTION & _zz__zz_decode_IS_CSR) == 32'h00000050)),{(|{_zz__zz_decode_IS_CSR_1,_zz__zz_decode_IS_CSR_2}),{(|{_zz__zz_decode_IS_CSR_3,_zz__zz_decode_IS_CSR_4}),{(|_zz__zz_decode_IS_CSR_5),{_zz__zz_decode_IS_CSR_6,{_zz__zz_decode_IS_CSR_7,_zz__zz_decode_IS_CSR_8}}}}}};
  assign _zz_decode_SRC1_CTRL_2 = _zz_decode_IS_CSR[1 : 0];
  assign _zz_decode_SRC1_CTRL_1 = _zz_decode_SRC1_CTRL_2;
  assign _zz_decode_ALU_CTRL_2 = _zz_decode_IS_CSR[6 : 5];
  assign _zz_decode_ALU_CTRL_1 = _zz_decode_ALU_CTRL_2;
  assign _zz_decode_SRC2_CTRL_2 = _zz_decode_IS_CSR[8 : 7];
  assign _zz_decode_SRC2_CTRL_1 = _zz_decode_SRC2_CTRL_2;
  assign _zz_decode_ALU_BITWISE_CTRL_2 = _zz_decode_IS_CSR[17 : 16];
  assign _zz_decode_ALU_BITWISE_CTRL_1 = _zz_decode_ALU_BITWISE_CTRL_2;
  assign _zz_decode_SHIFT_CTRL_2 = _zz_decode_IS_CSR[20 : 19];
  assign _zz_decode_SHIFT_CTRL_1 = _zz_decode_SHIFT_CTRL_2;
  assign _zz_decode_BRANCH_CTRL_2 = _zz_decode_IS_CSR[26 : 25];
  assign _zz_decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_2;
  assign _zz_decode_ENV_CTRL_2 = _zz_decode_IS_CSR[28 : 28];
  assign _zz_decode_ENV_CTRL_1 = _zz_decode_ENV_CTRL_2;
  assign decodeExceptionPort_valid = (decode_arbitration_isValid && (! decode_LEGAL_INSTRUCTION));
  assign decodeExceptionPort_payload_code = 4'b0010;
  assign decodeExceptionPort_payload_badAddr = decode_INSTRUCTION;
  assign when_RegFilePlugin_l63 = (decode_INSTRUCTION[11 : 7] == 5'h0);
  assign decode_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION_ANTICIPATED[19 : 15];
  assign decode_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION_ANTICIPATED[24 : 20];
  assign decode_RegFilePlugin_rs1Data = RegFilePlugin_regFile_spinal_port0;
  assign decode_RegFilePlugin_rs2Data = RegFilePlugin_regFile_spinal_port1;
  always @(*) begin
    lastStageRegFileWrite_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
    if(_zz_10) begin
      lastStageRegFileWrite_valid = 1'b1;
    end
  end

  always @(*) begin
    lastStageRegFileWrite_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
    if(_zz_10) begin
      lastStageRegFileWrite_payload_address = 5'h0;
    end
  end

  always @(*) begin
    lastStageRegFileWrite_payload_data = _zz_decode_RS2_2;
    if(_zz_10) begin
      lastStageRegFileWrite_payload_data = 32'h0;
    end
  end

  always @(*) begin
    case(execute_ALU_BITWISE_CTRL)
      vexAluBitwiseCtrlEnum_AND_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
      end
      vexAluBitwiseCtrlEnum_OR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
      end
      default : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
      end
    endcase
  end

  always @(*) begin
    case(execute_ALU_CTRL)
      vexAluCtrlEnum_BITWISE : begin
        _zz_execute_REGFILE_WRITE_DATA = execute_IntAluPlugin_bitwise;
      end
      vexAluCtrlEnum_SLT_SLTU : begin
        _zz_execute_REGFILE_WRITE_DATA = {31'd0, _zz__zz_execute_REGFILE_WRITE_DATA};
      end
      default : begin
        _zz_execute_REGFILE_WRITE_DATA = execute_SRC_ADD_SUB;
      end
    endcase
  end

  always @(*) begin
    case(execute_SRC1_CTRL)
      vexSrc1CtrlEnum_RS : begin
        _zz_execute_SRC1 = execute_RS1;
      end
      vexSrc1CtrlEnum_PC_INCREMENT : begin
        _zz_execute_SRC1 = {29'd0, _zz__zz_execute_SRC1};
      end
      vexSrc1CtrlEnum_IMU : begin
        _zz_execute_SRC1 = {execute_INSTRUCTION[31 : 12],12'h0};
      end
      default : begin
        _zz_execute_SRC1 = {27'd0, _zz__zz_execute_SRC1_1};
      end
    endcase
  end

  assign _zz_execute_SRC2 = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_SRC2_1[19] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[18] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[17] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[16] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[15] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[14] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[13] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[12] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[11] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[10] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[9] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[8] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[7] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[6] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[5] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[4] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[3] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[2] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[1] = _zz_execute_SRC2;
    _zz_execute_SRC2_1[0] = _zz_execute_SRC2;
  end

  assign _zz_execute_SRC2_2 = _zz__zz_execute_SRC2_2[11];
  always @(*) begin
    _zz_execute_SRC2_3[19] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[18] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[17] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[16] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[15] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[14] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[13] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[12] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[11] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[10] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[9] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[8] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[7] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[6] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[5] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[4] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[3] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[2] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[1] = _zz_execute_SRC2_2;
    _zz_execute_SRC2_3[0] = _zz_execute_SRC2_2;
  end

  always @(*) begin
    case(execute_SRC2_CTRL)
      vexSrc2CtrlEnum_RS : begin
        _zz_execute_SRC2_4 = execute_RS2;
      end
      vexSrc2CtrlEnum_IMI : begin
        _zz_execute_SRC2_4 = {_zz_execute_SRC2_1,execute_INSTRUCTION[31 : 20]};
      end
      vexSrc2CtrlEnum_IMS : begin
        _zz_execute_SRC2_4 = {_zz_execute_SRC2_3,{execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_execute_SRC2_4 = _zz_execute_to_memory_PC;
      end
    endcase
  end

  always @(*) begin
    execute_SrcPlugin_addSub = _zz_execute_SrcPlugin_addSub;
    if(execute_SRC2_FORCE_ZERO) begin
      execute_SrcPlugin_addSub = execute_SRC1;
    end
  end

  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign execute_FullBarrelShifterPlugin_amplitude = execute_SRC2[4 : 0];
  always @(*) begin
    _zz_execute_FullBarrelShifterPlugin_reversed[0] = execute_SRC1[31];
    _zz_execute_FullBarrelShifterPlugin_reversed[1] = execute_SRC1[30];
    _zz_execute_FullBarrelShifterPlugin_reversed[2] = execute_SRC1[29];
    _zz_execute_FullBarrelShifterPlugin_reversed[3] = execute_SRC1[28];
    _zz_execute_FullBarrelShifterPlugin_reversed[4] = execute_SRC1[27];
    _zz_execute_FullBarrelShifterPlugin_reversed[5] = execute_SRC1[26];
    _zz_execute_FullBarrelShifterPlugin_reversed[6] = execute_SRC1[25];
    _zz_execute_FullBarrelShifterPlugin_reversed[7] = execute_SRC1[24];
    _zz_execute_FullBarrelShifterPlugin_reversed[8] = execute_SRC1[23];
    _zz_execute_FullBarrelShifterPlugin_reversed[9] = execute_SRC1[22];
    _zz_execute_FullBarrelShifterPlugin_reversed[10] = execute_SRC1[21];
    _zz_execute_FullBarrelShifterPlugin_reversed[11] = execute_SRC1[20];
    _zz_execute_FullBarrelShifterPlugin_reversed[12] = execute_SRC1[19];
    _zz_execute_FullBarrelShifterPlugin_reversed[13] = execute_SRC1[18];
    _zz_execute_FullBarrelShifterPlugin_reversed[14] = execute_SRC1[17];
    _zz_execute_FullBarrelShifterPlugin_reversed[15] = execute_SRC1[16];
    _zz_execute_FullBarrelShifterPlugin_reversed[16] = execute_SRC1[15];
    _zz_execute_FullBarrelShifterPlugin_reversed[17] = execute_SRC1[14];
    _zz_execute_FullBarrelShifterPlugin_reversed[18] = execute_SRC1[13];
    _zz_execute_FullBarrelShifterPlugin_reversed[19] = execute_SRC1[12];
    _zz_execute_FullBarrelShifterPlugin_reversed[20] = execute_SRC1[11];
    _zz_execute_FullBarrelShifterPlugin_reversed[21] = execute_SRC1[10];
    _zz_execute_FullBarrelShifterPlugin_reversed[22] = execute_SRC1[9];
    _zz_execute_FullBarrelShifterPlugin_reversed[23] = execute_SRC1[8];
    _zz_execute_FullBarrelShifterPlugin_reversed[24] = execute_SRC1[7];
    _zz_execute_FullBarrelShifterPlugin_reversed[25] = execute_SRC1[6];
    _zz_execute_FullBarrelShifterPlugin_reversed[26] = execute_SRC1[5];
    _zz_execute_FullBarrelShifterPlugin_reversed[27] = execute_SRC1[4];
    _zz_execute_FullBarrelShifterPlugin_reversed[28] = execute_SRC1[3];
    _zz_execute_FullBarrelShifterPlugin_reversed[29] = execute_SRC1[2];
    _zz_execute_FullBarrelShifterPlugin_reversed[30] = execute_SRC1[1];
    _zz_execute_FullBarrelShifterPlugin_reversed[31] = execute_SRC1[0];
  end

  assign execute_FullBarrelShifterPlugin_reversed = ((execute_SHIFT_CTRL == vexShiftCtrlEnum_SLL_1) ? _zz_execute_FullBarrelShifterPlugin_reversed : execute_SRC1);
  always @(*) begin
    _zz_decode_RS2_3[0] = memory_SHIFT_RIGHT[31];
    _zz_decode_RS2_3[1] = memory_SHIFT_RIGHT[30];
    _zz_decode_RS2_3[2] = memory_SHIFT_RIGHT[29];
    _zz_decode_RS2_3[3] = memory_SHIFT_RIGHT[28];
    _zz_decode_RS2_3[4] = memory_SHIFT_RIGHT[27];
    _zz_decode_RS2_3[5] = memory_SHIFT_RIGHT[26];
    _zz_decode_RS2_3[6] = memory_SHIFT_RIGHT[25];
    _zz_decode_RS2_3[7] = memory_SHIFT_RIGHT[24];
    _zz_decode_RS2_3[8] = memory_SHIFT_RIGHT[23];
    _zz_decode_RS2_3[9] = memory_SHIFT_RIGHT[22];
    _zz_decode_RS2_3[10] = memory_SHIFT_RIGHT[21];
    _zz_decode_RS2_3[11] = memory_SHIFT_RIGHT[20];
    _zz_decode_RS2_3[12] = memory_SHIFT_RIGHT[19];
    _zz_decode_RS2_3[13] = memory_SHIFT_RIGHT[18];
    _zz_decode_RS2_3[14] = memory_SHIFT_RIGHT[17];
    _zz_decode_RS2_3[15] = memory_SHIFT_RIGHT[16];
    _zz_decode_RS2_3[16] = memory_SHIFT_RIGHT[15];
    _zz_decode_RS2_3[17] = memory_SHIFT_RIGHT[14];
    _zz_decode_RS2_3[18] = memory_SHIFT_RIGHT[13];
    _zz_decode_RS2_3[19] = memory_SHIFT_RIGHT[12];
    _zz_decode_RS2_3[20] = memory_SHIFT_RIGHT[11];
    _zz_decode_RS2_3[21] = memory_SHIFT_RIGHT[10];
    _zz_decode_RS2_3[22] = memory_SHIFT_RIGHT[9];
    _zz_decode_RS2_3[23] = memory_SHIFT_RIGHT[8];
    _zz_decode_RS2_3[24] = memory_SHIFT_RIGHT[7];
    _zz_decode_RS2_3[25] = memory_SHIFT_RIGHT[6];
    _zz_decode_RS2_3[26] = memory_SHIFT_RIGHT[5];
    _zz_decode_RS2_3[27] = memory_SHIFT_RIGHT[4];
    _zz_decode_RS2_3[28] = memory_SHIFT_RIGHT[3];
    _zz_decode_RS2_3[29] = memory_SHIFT_RIGHT[2];
    _zz_decode_RS2_3[30] = memory_SHIFT_RIGHT[1];
    _zz_decode_RS2_3[31] = memory_SHIFT_RIGHT[0];
  end

  assign execute_MulPlugin_a = execute_RS1;
  assign execute_MulPlugin_b = execute_RS2;
  assign switch_MulPlugin_l87 = execute_INSTRUCTION[13 : 12];
  always @(*) begin
    case(switch_MulPlugin_l87)
      2'b01 : begin
        execute_MulPlugin_aSigned = 1'b1;
      end
      2'b10 : begin
        execute_MulPlugin_aSigned = 1'b1;
      end
      default : begin
        execute_MulPlugin_aSigned = 1'b0;
      end
    endcase
  end

  always @(*) begin
    case(switch_MulPlugin_l87)
      2'b01 : begin
        execute_MulPlugin_bSigned = 1'b1;
      end
      2'b10 : begin
        execute_MulPlugin_bSigned = 1'b0;
      end
      default : begin
        execute_MulPlugin_bSigned = 1'b0;
      end
    endcase
  end

  assign execute_MulPlugin_aULow = execute_MulPlugin_a[15 : 0];
  assign execute_MulPlugin_bULow = execute_MulPlugin_b[15 : 0];
  assign execute_MulPlugin_aSLow = {1'b0,execute_MulPlugin_a[15 : 0]};
  assign execute_MulPlugin_bSLow = {1'b0,execute_MulPlugin_b[15 : 0]};
  assign execute_MulPlugin_aHigh = {(execute_MulPlugin_aSigned && execute_MulPlugin_a[31]),execute_MulPlugin_a[31 : 16]};
  assign execute_MulPlugin_bHigh = {(execute_MulPlugin_bSigned && execute_MulPlugin_b[31]),execute_MulPlugin_b[31 : 16]};
  assign writeBack_MulPlugin_result = ($signed(_zz_writeBack_MulPlugin_result) + $signed(_zz_writeBack_MulPlugin_result_1));
  assign when_MulPlugin_l147 = (writeBack_arbitration_isValid && writeBack_IS_MUL);
  assign switch_MulPlugin_l148 = writeBack_INSTRUCTION[13 : 12];
  assign memory_DivPlugin_frontendOk = 1'b1;
  always @(*) begin
    memory_DivPlugin_div_counter_willIncrement = 1'b0;
    if(when_MulDivIterativePlugin_l128) begin
      if(when_MulDivIterativePlugin_l132) begin
        memory_DivPlugin_div_counter_willIncrement = 1'b1;
      end
    end
  end

  always @(*) begin
    memory_DivPlugin_div_counter_willClear = 1'b0;
    if(when_MulDivIterativePlugin_l162) begin
      memory_DivPlugin_div_counter_willClear = 1'b1;
    end
  end

  assign memory_DivPlugin_div_counter_willOverflowIfInc = (memory_DivPlugin_div_counter_value == 6'h21);
  assign memory_DivPlugin_div_counter_willOverflow = (memory_DivPlugin_div_counter_willOverflowIfInc && memory_DivPlugin_div_counter_willIncrement);
  always @(*) begin
    if(memory_DivPlugin_div_counter_willOverflow) begin
      memory_DivPlugin_div_counter_valueNext = 6'h0;
    end else begin
      memory_DivPlugin_div_counter_valueNext = (memory_DivPlugin_div_counter_value + _zz_memory_DivPlugin_div_counter_valueNext);
    end
    if(memory_DivPlugin_div_counter_willClear) begin
      memory_DivPlugin_div_counter_valueNext = 6'h0;
    end
  end

  assign when_MulDivIterativePlugin_l126 = (memory_DivPlugin_div_counter_value == 6'h20);
  assign when_MulDivIterativePlugin_l126_1 = (! memory_arbitration_isStuck);
  assign when_MulDivIterativePlugin_l128 = (memory_arbitration_isValid && memory_IS_DIV);
  assign when_MulDivIterativePlugin_l129 = ((! memory_DivPlugin_frontendOk) || (! memory_DivPlugin_div_done));
  assign when_MulDivIterativePlugin_l132 = (memory_DivPlugin_frontendOk && (! memory_DivPlugin_div_done));
  assign _zz_memory_DivPlugin_div_stage_0_remainderShifted = memory_DivPlugin_rs1[31 : 0];
  assign memory_DivPlugin_div_stage_0_remainderShifted = {memory_DivPlugin_accumulator[31 : 0],_zz_memory_DivPlugin_div_stage_0_remainderShifted[31]};
  assign memory_DivPlugin_div_stage_0_remainderMinusDenominator = (memory_DivPlugin_div_stage_0_remainderShifted - _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator);
  assign memory_DivPlugin_div_stage_0_outRemainder = ((! memory_DivPlugin_div_stage_0_remainderMinusDenominator[32]) ? _zz_memory_DivPlugin_div_stage_0_outRemainder : _zz_memory_DivPlugin_div_stage_0_outRemainder_1);
  assign memory_DivPlugin_div_stage_0_outNumerator = _zz_memory_DivPlugin_div_stage_0_outNumerator[31:0];
  assign when_MulDivIterativePlugin_l151 = (memory_DivPlugin_div_counter_value == 6'h20);
  assign _zz_memory_DivPlugin_div_result = (memory_INSTRUCTION[13] ? memory_DivPlugin_accumulator[31 : 0] : memory_DivPlugin_rs1[31 : 0]);
  assign when_MulDivIterativePlugin_l162 = (! memory_arbitration_isStuck);
  assign _zz_memory_DivPlugin_rs2 = (execute_RS2[31] && execute_IS_RS2_SIGNED);
  assign _zz_memory_DivPlugin_rs1 = (1'b0 || ((execute_IS_DIV && execute_RS1[31]) && execute_IS_RS1_SIGNED));
  always @(*) begin
    _zz_memory_DivPlugin_rs1_1[32] = (execute_IS_RS1_SIGNED && execute_RS1[31]);
    _zz_memory_DivPlugin_rs1_1[31 : 0] = execute_RS1;
  end

  always @(*) begin
    HazardSimplePlugin_src0Hazard = 1'b0;
    if(when_HazardSimplePlugin_l57) begin
      if(when_HazardSimplePlugin_l58) begin
        if(when_HazardSimplePlugin_l48) begin
          HazardSimplePlugin_src0Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l57_1) begin
      if(when_HazardSimplePlugin_l58_1) begin
        if(when_HazardSimplePlugin_l48_1) begin
          HazardSimplePlugin_src0Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l57_2) begin
      if(when_HazardSimplePlugin_l58_2) begin
        if(when_HazardSimplePlugin_l48_2) begin
          HazardSimplePlugin_src0Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l105) begin
      HazardSimplePlugin_src0Hazard = 1'b0;
    end
  end

  always @(*) begin
    HazardSimplePlugin_src1Hazard = 1'b0;
    if(when_HazardSimplePlugin_l57) begin
      if(when_HazardSimplePlugin_l58) begin
        if(when_HazardSimplePlugin_l51) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l57_1) begin
      if(when_HazardSimplePlugin_l58_1) begin
        if(when_HazardSimplePlugin_l51_1) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l57_2) begin
      if(when_HazardSimplePlugin_l58_2) begin
        if(when_HazardSimplePlugin_l51_2) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l108) begin
      HazardSimplePlugin_src1Hazard = 1'b0;
    end
  end

  assign HazardSimplePlugin_writeBackWrites_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
  assign HazardSimplePlugin_writeBackWrites_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
  assign HazardSimplePlugin_writeBackWrites_payload_data = _zz_decode_RS2_2;
  assign HazardSimplePlugin_addr0Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[19 : 15]);
  assign HazardSimplePlugin_addr1Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[24 : 20]);
  assign when_HazardSimplePlugin_l47 = 1'b1;
  assign when_HazardSimplePlugin_l48 = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
  assign when_HazardSimplePlugin_l51 = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
  assign when_HazardSimplePlugin_l45 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l57 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l58 = (1'b0 || (! when_HazardSimplePlugin_l47));
  assign when_HazardSimplePlugin_l48_1 = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
  assign when_HazardSimplePlugin_l51_1 = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
  assign when_HazardSimplePlugin_l45_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l57_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l58_1 = (1'b0 || (! memory_BYPASSABLE_MEMORY_STAGE));
  assign when_HazardSimplePlugin_l48_2 = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
  assign when_HazardSimplePlugin_l51_2 = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
  assign when_HazardSimplePlugin_l45_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l57_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l58_2 = (1'b0 || (! execute_BYPASSABLE_EXECUTE_STAGE));
  assign when_HazardSimplePlugin_l105 = (! decode_RS1_USE);
  assign when_HazardSimplePlugin_l108 = (! decode_RS2_USE);
  assign when_HazardSimplePlugin_l113 = (decode_arbitration_isValid && (HazardSimplePlugin_src0Hazard || HazardSimplePlugin_src1Hazard));
  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign switch_Misc_l245_1 = execute_INSTRUCTION[14 : 12];
  always @(*) begin
    case(switch_Misc_l245_1)
      3'b000 : begin
        _zz_execute_BRANCH_COND_RESULT = execute_BranchPlugin_eq;
      end
      3'b001 : begin
        _zz_execute_BRANCH_COND_RESULT = (! execute_BranchPlugin_eq);
      end
      3'b101 : begin
        _zz_execute_BRANCH_COND_RESULT = (! execute_SRC_LESS);
      end
      3'b111 : begin
        _zz_execute_BRANCH_COND_RESULT = (! execute_SRC_LESS);
      end
      default : begin
        _zz_execute_BRANCH_COND_RESULT = execute_SRC_LESS;
      end
    endcase
  end

  always @(*) begin
    case(execute_BRANCH_CTRL)
      vexBranchCtrlEnum_INC : begin
        _zz_execute_BRANCH_COND_RESULT_1 = 1'b0;
      end
      vexBranchCtrlEnum_JAL : begin
        _zz_execute_BRANCH_COND_RESULT_1 = 1'b1;
      end
      vexBranchCtrlEnum_JALR : begin
        _zz_execute_BRANCH_COND_RESULT_1 = 1'b1;
      end
      default : begin
        _zz_execute_BRANCH_COND_RESULT_1 = _zz_execute_BRANCH_COND_RESULT;
      end
    endcase
  end

  assign _zz_execute_BranchPlugin_missAlignedTarget = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_BranchPlugin_missAlignedTarget_1[19] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[18] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[17] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[16] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[15] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[14] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[13] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[12] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[11] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[10] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[9] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[8] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[7] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[6] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[5] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[4] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[3] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[2] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[1] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[0] = _zz_execute_BranchPlugin_missAlignedTarget;
  end

  assign _zz_execute_BranchPlugin_missAlignedTarget_2 = _zz__zz_execute_BranchPlugin_missAlignedTarget_2[19];
  always @(*) begin
    _zz_execute_BranchPlugin_missAlignedTarget_3[10] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[9] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[8] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[7] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[6] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[5] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[4] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[3] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[2] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[1] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[0] = _zz_execute_BranchPlugin_missAlignedTarget_2;
  end

  assign _zz_execute_BranchPlugin_missAlignedTarget_4 = _zz__zz_execute_BranchPlugin_missAlignedTarget_4[11];
  always @(*) begin
    _zz_execute_BranchPlugin_missAlignedTarget_5[18] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[17] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[16] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[15] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[14] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[13] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[12] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[11] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[10] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[9] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[8] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[7] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[6] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[5] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[4] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[3] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[2] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[1] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[0] = _zz_execute_BranchPlugin_missAlignedTarget_4;
  end

  always @(*) begin
    case(execute_BRANCH_CTRL)
      vexBranchCtrlEnum_JALR : begin
        _zz_execute_BranchPlugin_missAlignedTarget_6 = (_zz__zz_execute_BranchPlugin_missAlignedTarget_6[1] ^ execute_RS1[1]);
      end
      vexBranchCtrlEnum_JAL : begin
        _zz_execute_BranchPlugin_missAlignedTarget_6 = _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1[1];
      end
      default : begin
        _zz_execute_BranchPlugin_missAlignedTarget_6 = _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2[1];
      end
    endcase
  end

  assign execute_BranchPlugin_missAlignedTarget = (execute_BRANCH_COND_RESULT && _zz_execute_BranchPlugin_missAlignedTarget_6);
  always @(*) begin
    case(execute_BRANCH_CTRL)
      vexBranchCtrlEnum_JALR : begin
        execute_BranchPlugin_branch_src1 = execute_RS1;
      end
      default : begin
        execute_BranchPlugin_branch_src1 = execute_PC;
      end
    endcase
  end

  assign _zz_execute_BranchPlugin_branch_src2 = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_BranchPlugin_branch_src2_1[19] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[18] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[17] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[16] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[15] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[14] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[13] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[12] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[11] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[10] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[9] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[8] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[7] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[6] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[5] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[4] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[3] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[2] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[1] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[0] = _zz_execute_BranchPlugin_branch_src2;
  end

  always @(*) begin
    case(execute_BRANCH_CTRL)
      vexBranchCtrlEnum_JALR : begin
        execute_BranchPlugin_branch_src2 = {_zz_execute_BranchPlugin_branch_src2_1,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        execute_BranchPlugin_branch_src2 = ((execute_BRANCH_CTRL == vexBranchCtrlEnum_JAL) ? {{_zz_execute_BranchPlugin_branch_src2_3,{{{_zz_execute_BranchPlugin_branch_src2_6,_zz_execute_BranchPlugin_branch_src2_7},_zz_execute_BranchPlugin_branch_src2_8},execute_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_execute_BranchPlugin_branch_src2_5,{{{_zz_execute_BranchPlugin_branch_src2_9,_zz_execute_BranchPlugin_branch_src2_10},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0});
        if(execute_PREDICTION_HAD_BRANCHED1) begin
          execute_BranchPlugin_branch_src2 = {29'd0, _zz_execute_BranchPlugin_branch_src2_11};
        end
      end
    endcase
  end

  assign _zz_execute_BranchPlugin_branch_src2_2 = _zz__zz_execute_BranchPlugin_branch_src2_2[19];
  always @(*) begin
    _zz_execute_BranchPlugin_branch_src2_3[10] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[9] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[8] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[7] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[6] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[5] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[4] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[3] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[2] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[1] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[0] = _zz_execute_BranchPlugin_branch_src2_2;
  end

  assign _zz_execute_BranchPlugin_branch_src2_4 = _zz__zz_execute_BranchPlugin_branch_src2_4[11];
  always @(*) begin
    _zz_execute_BranchPlugin_branch_src2_5[18] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[17] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[16] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[15] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[14] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[13] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[12] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[11] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[10] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[9] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[8] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[7] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[6] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[5] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[4] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[3] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[2] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[1] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[0] = _zz_execute_BranchPlugin_branch_src2_4;
  end

  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign BranchPlugin_jumpInterface_valid = ((memory_arbitration_isValid && memory_BRANCH_DO) && (! 1'b0));
  assign BranchPlugin_jumpInterface_payload = memory_BRANCH_CALC;
  assign BranchPlugin_branchExceptionPort_valid = (memory_arbitration_isValid && (memory_BRANCH_DO && memory_BRANCH_CALC[1]));
  assign BranchPlugin_branchExceptionPort_payload_code = 4'b0000;
  assign BranchPlugin_branchExceptionPort_payload_badAddr = memory_BRANCH_CALC;
  assign IBusSimplePlugin_decodePrediction_rsp_wasWrong = BranchPlugin_jumpInterface_valid;
  always @(*) begin
    CsrPlugin_privilege = 2'b11;
    if(CsrPlugin_forceMachineWire) begin
      CsrPlugin_privilege = 2'b11;
    end
  end

  assign CsrPlugin_misa_base = 2'b01;
  assign CsrPlugin_misa_extensions = 26'h0000042;
  assign CsrPlugin_mtvec_mode = 2'b00;
  assign CsrPlugin_mtvec_base = 30'h20000008;
  assign _zz_when_CsrPlugin_l1302 = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
  assign _zz_when_CsrPlugin_l1302_1 = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
  assign _zz_when_CsrPlugin_l1302_2 = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped = 2'b11;
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = ((CsrPlugin_privilege < CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped) ? CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped : CsrPlugin_privilege);
  assign _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code = {decodeExceptionPort_valid,IBusSimplePlugin_decodeExceptionPort_valid};
  assign _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 = _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1[0];
  assign _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_2 = {BranchPlugin_branchExceptionPort_valid,DBusSimplePlugin_memoryExceptionPort_valid};
  assign _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3 = _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3[0];
  always @(*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    if(_zz_when) begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_decode = 1'b1;
    end
    if(decode_arbitration_isFlushed) begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_decode = 1'b0;
    end
  end

  always @(*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    if(execute_arbitration_isFlushed) begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b0;
    end
  end

  always @(*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_memory = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    if(_zz_when_1) begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b1;
    end
    if(memory_arbitration_isFlushed) begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b0;
    end
  end

  always @(*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    if(writeBack_arbitration_isFlushed) begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = 1'b0;
    end
  end

  assign when_CsrPlugin_l1259 = (! decode_arbitration_isStuck);
  assign when_CsrPlugin_l1259_1 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1259_2 = (! memory_arbitration_isStuck);
  assign when_CsrPlugin_l1259_3 = (! writeBack_arbitration_isStuck);
  assign when_CsrPlugin_l1272 = (|{CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack,{CsrPlugin_exceptionPortCtrl_exceptionValids_memory,{CsrPlugin_exceptionPortCtrl_exceptionValids_execute,CsrPlugin_exceptionPortCtrl_exceptionValids_decode}}});
  assign CsrPlugin_exceptionPendings_0 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  assign CsrPlugin_exceptionPendings_1 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  assign CsrPlugin_exceptionPendings_2 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
  assign CsrPlugin_exceptionPendings_3 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
  assign when_CsrPlugin_l1296 = (CsrPlugin_mstatus_MIE || (CsrPlugin_privilege < 2'b11));
  assign when_CsrPlugin_l1302 = ((_zz_when_CsrPlugin_l1302 && 1'b1) && (! 1'b0));
  assign when_CsrPlugin_l1302_1 = ((_zz_when_CsrPlugin_l1302_1 && 1'b1) && (! 1'b0));
  assign when_CsrPlugin_l1302_2 = ((_zz_when_CsrPlugin_l1302_2 && 1'b1) && (! 1'b0));
  assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack && CsrPlugin_allowException);
  assign CsrPlugin_lastStageWasWfi = 1'b0;
  assign CsrPlugin_pipelineLiberator_active = ((CsrPlugin_interrupt_valid && CsrPlugin_allowInterrupts) && decode_arbitration_isValid);
  assign when_CsrPlugin_l1335 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1335_1 = (! memory_arbitration_isStuck);
  assign when_CsrPlugin_l1335_2 = (! writeBack_arbitration_isStuck);
  assign when_CsrPlugin_l1340 = ((! CsrPlugin_pipelineLiberator_active) || decode_arbitration_removeIt);
  always @(*) begin
    CsrPlugin_pipelineLiberator_done = CsrPlugin_pipelineLiberator_pcValids_2;
    if(when_CsrPlugin_l1346) begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
    if(CsrPlugin_hadException) begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
  end

  assign when_CsrPlugin_l1346 = (|{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack,{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory,CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute}});
  assign CsrPlugin_interruptJump = ((CsrPlugin_interrupt_valid && CsrPlugin_pipelineLiberator_done) && CsrPlugin_allowInterrupts);
  always @(*) begin
    CsrPlugin_targetPrivilege = CsrPlugin_interrupt_targetPrivilege;
    if(CsrPlugin_hadException) begin
      CsrPlugin_targetPrivilege = CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
    end
  end

  always @(*) begin
    CsrPlugin_trapCause = CsrPlugin_interrupt_code;
    if(CsrPlugin_hadException) begin
      CsrPlugin_trapCause = CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    end
  end

  assign CsrPlugin_trapCauseEbreakDebug = 1'b0;
  always @(*) begin
    CsrPlugin_xtvec_mode = 2'bxx;
    case(CsrPlugin_targetPrivilege)
      2'b11 : begin
        CsrPlugin_xtvec_mode = CsrPlugin_mtvec_mode;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    CsrPlugin_xtvec_base = 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(CsrPlugin_targetPrivilege)
      2'b11 : begin
        CsrPlugin_xtvec_base = CsrPlugin_mtvec_base;
      end
      default : begin
      end
    endcase
  end

  assign CsrPlugin_trapEnterDebug = 1'b0;
  assign when_CsrPlugin_l1390 = (CsrPlugin_hadException || CsrPlugin_interruptJump);
  assign when_CsrPlugin_l1398 = (! CsrPlugin_trapEnterDebug);
  assign when_CsrPlugin_l1456 = (writeBack_arbitration_isValid && (writeBack_ENV_CTRL == vexEnvCtrlEnum_XRET));
  assign switch_CsrPlugin_l1460 = writeBack_INSTRUCTION[29 : 28];
  assign contextSwitching = CsrPlugin_jumpInterface_valid;
  assign when_CsrPlugin_l1527 = (|{(writeBack_arbitration_isValid && (writeBack_ENV_CTRL == vexEnvCtrlEnum_XRET)),{(memory_arbitration_isValid && (memory_ENV_CTRL == vexEnvCtrlEnum_XRET)),(execute_arbitration_isValid && (execute_ENV_CTRL == vexEnvCtrlEnum_XRET))}});
  assign execute_CsrPlugin_blockedBySideEffects = ((|{writeBack_arbitration_isValid,memory_arbitration_isValid}) || 1'b0);
  always @(*) begin
    execute_CsrPlugin_illegalAccess = 1'b1;
    if(execute_CsrPlugin_csr_768) begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
    if(execute_CsrPlugin_csr_836) begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
    if(execute_CsrPlugin_csr_772) begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
    if(execute_CsrPlugin_csr_833) begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
    if(execute_CsrPlugin_csr_834) begin
      if(execute_CSR_READ_OPCODE) begin
        execute_CsrPlugin_illegalAccess = 1'b0;
      end
    end
    if(execute_CsrPlugin_csr_835) begin
      if(execute_CSR_READ_OPCODE) begin
        execute_CsrPlugin_illegalAccess = 1'b0;
      end
    end
    if(execute_CsrPlugin_csr_2816) begin
      if(execute_CSR_READ_OPCODE) begin
        execute_CsrPlugin_illegalAccess = 1'b0;
      end
    end
    if(execute_CsrPlugin_csr_2944) begin
      if(execute_CSR_READ_OPCODE) begin
        execute_CsrPlugin_illegalAccess = 1'b0;
      end
    end
    if(execute_CsrPlugin_csr_2818) begin
      if(execute_CSR_READ_OPCODE) begin
        execute_CsrPlugin_illegalAccess = 1'b0;
      end
    end
    if(execute_CsrPlugin_csr_2946) begin
      if(execute_CSR_READ_OPCODE) begin
        execute_CsrPlugin_illegalAccess = 1'b0;
      end
    end
    if(CsrPlugin_csrMapping_allowCsrSignal) begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
    if(when_CsrPlugin_l1719) begin
      execute_CsrPlugin_illegalAccess = 1'b1;
    end
    if(when_CsrPlugin_l1725) begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
  end

  always @(*) begin
    execute_CsrPlugin_illegalInstruction = 1'b0;
    if(when_CsrPlugin_l1547) begin
      if(when_CsrPlugin_l1548) begin
        execute_CsrPlugin_illegalInstruction = 1'b1;
      end
    end
  end

  assign when_CsrPlugin_l1547 = (execute_arbitration_isValid && (execute_ENV_CTRL == vexEnvCtrlEnum_XRET));
  assign when_CsrPlugin_l1548 = (CsrPlugin_privilege < execute_INSTRUCTION[29 : 28]);
  always @(*) begin
    execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
    if(when_CsrPlugin_l1719) begin
      execute_CsrPlugin_writeInstruction = 1'b0;
    end
  end

  always @(*) begin
    execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
    if(when_CsrPlugin_l1719) begin
      execute_CsrPlugin_readInstruction = 1'b0;
    end
  end

  assign execute_CsrPlugin_writeEnable = (execute_CsrPlugin_writeInstruction && (! execute_arbitration_isStuck));
  assign execute_CsrPlugin_readEnable = (execute_CsrPlugin_readInstruction && (! execute_arbitration_isStuck));
  assign CsrPlugin_csrMapping_hazardFree = (! execute_CsrPlugin_blockedBySideEffects);
  assign execute_CsrPlugin_readToWriteData = CsrPlugin_csrMapping_readDataSignal;
  assign switch_Misc_l245_2 = execute_INSTRUCTION[13];
  always @(*) begin
    case(switch_Misc_l245_2)
      1'b0 : begin
        _zz_CsrPlugin_csrMapping_writeDataSignal = execute_SRC1;
      end
      default : begin
        _zz_CsrPlugin_csrMapping_writeDataSignal = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readToWriteData & (~ execute_SRC1)) : (execute_CsrPlugin_readToWriteData | execute_SRC1));
      end
    endcase
  end

  assign CsrPlugin_csrMapping_writeDataSignal = _zz_CsrPlugin_csrMapping_writeDataSignal;
  assign when_CsrPlugin_l1587 = (execute_arbitration_isValid && execute_IS_CSR);
  assign when_CsrPlugin_l1591 = (execute_arbitration_isValid && (execute_IS_CSR || 1'b0));
  assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
  assign when_Pipeline_l124 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_1 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_2 = ((! writeBack_arbitration_isStuck) && (! CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack));
  assign when_Pipeline_l124_3 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_4 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_5 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_6 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_7 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_8 = (! writeBack_arbitration_isStuck);
  assign _zz_decode_to_execute_SRC1_CTRL_1 = decode_SRC1_CTRL;
  assign _zz_decode_SRC1_CTRL = _zz_decode_SRC1_CTRL_1;
  assign when_Pipeline_l124_9 = (! execute_arbitration_isStuck);
  assign _zz_execute_SRC1_CTRL = decode_to_execute_SRC1_CTRL;
  assign when_Pipeline_l124_10 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_11 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_12 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_13 = (! writeBack_arbitration_isStuck);
  assign _zz_decode_to_execute_ALU_CTRL_1 = decode_ALU_CTRL;
  assign _zz_decode_ALU_CTRL = _zz_decode_ALU_CTRL_1;
  assign when_Pipeline_l124_14 = (! execute_arbitration_isStuck);
  assign _zz_execute_ALU_CTRL = decode_to_execute_ALU_CTRL;
  assign _zz_decode_to_execute_SRC2_CTRL_1 = decode_SRC2_CTRL;
  assign _zz_decode_SRC2_CTRL = _zz_decode_SRC2_CTRL_1;
  assign when_Pipeline_l124_15 = (! execute_arbitration_isStuck);
  assign _zz_execute_SRC2_CTRL = decode_to_execute_SRC2_CTRL;
  assign when_Pipeline_l124_16 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_17 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_18 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_19 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_20 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_21 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_22 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_23 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_24 = (! execute_arbitration_isStuck);
  assign _zz_decode_to_execute_ALU_BITWISE_CTRL_1 = decode_ALU_BITWISE_CTRL;
  assign _zz_decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL_1;
  assign when_Pipeline_l124_25 = (! execute_arbitration_isStuck);
  assign _zz_execute_ALU_BITWISE_CTRL = decode_to_execute_ALU_BITWISE_CTRL;
  assign _zz_decode_to_execute_SHIFT_CTRL_1 = decode_SHIFT_CTRL;
  assign _zz_execute_to_memory_SHIFT_CTRL_1 = execute_SHIFT_CTRL;
  assign _zz_decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL_1;
  assign when_Pipeline_l124_26 = (! execute_arbitration_isStuck);
  assign _zz_execute_SHIFT_CTRL = decode_to_execute_SHIFT_CTRL;
  assign when_Pipeline_l124_27 = (! memory_arbitration_isStuck);
  assign _zz_memory_SHIFT_CTRL = execute_to_memory_SHIFT_CTRL;
  assign when_Pipeline_l124_28 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_29 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_30 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_31 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_32 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_33 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_34 = (! execute_arbitration_isStuck);
  assign _zz_decode_to_execute_BRANCH_CTRL_1 = decode_BRANCH_CTRL;
  assign _zz_decode_BRANCH_CTRL_1 = _zz_decode_BRANCH_CTRL;
  assign when_Pipeline_l124_35 = (! execute_arbitration_isStuck);
  assign _zz_execute_BRANCH_CTRL = decode_to_execute_BRANCH_CTRL;
  assign when_Pipeline_l124_36 = (! execute_arbitration_isStuck);
  assign _zz_decode_to_execute_ENV_CTRL_1 = decode_ENV_CTRL;
  assign _zz_execute_to_memory_ENV_CTRL_1 = execute_ENV_CTRL;
  assign _zz_memory_to_writeBack_ENV_CTRL_1 = memory_ENV_CTRL;
  assign _zz_decode_ENV_CTRL = _zz_decode_ENV_CTRL_1;
  assign when_Pipeline_l124_37 = (! execute_arbitration_isStuck);
  assign _zz_execute_ENV_CTRL = decode_to_execute_ENV_CTRL;
  assign when_Pipeline_l124_38 = (! memory_arbitration_isStuck);
  assign _zz_memory_ENV_CTRL = execute_to_memory_ENV_CTRL;
  assign when_Pipeline_l124_39 = (! writeBack_arbitration_isStuck);
  assign _zz_writeBack_ENV_CTRL = memory_to_writeBack_ENV_CTRL;
  assign when_Pipeline_l124_40 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_41 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_42 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_43 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_44 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_45 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_46 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_47 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_48 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_49 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_50 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_51 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_52 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_53 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_54 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_55 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_56 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_57 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_58 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_59 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_60 = (! writeBack_arbitration_isStuck);
  assign decode_arbitration_isFlushed = ((|{writeBack_arbitration_flushNext,{memory_arbitration_flushNext,execute_arbitration_flushNext}}) || (|{writeBack_arbitration_flushIt,{memory_arbitration_flushIt,{execute_arbitration_flushIt,decode_arbitration_flushIt}}}));
  assign execute_arbitration_isFlushed = ((|{writeBack_arbitration_flushNext,memory_arbitration_flushNext}) || (|{writeBack_arbitration_flushIt,{memory_arbitration_flushIt,execute_arbitration_flushIt}}));
  assign memory_arbitration_isFlushed = ((|writeBack_arbitration_flushNext) || (|{writeBack_arbitration_flushIt,memory_arbitration_flushIt}));
  assign writeBack_arbitration_isFlushed = (1'b0 || (|writeBack_arbitration_flushIt));
  assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
  assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
  assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
  assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
  assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
  assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
  assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
  assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
  assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
  assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
  assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
  assign when_Pipeline_l151 = ((! execute_arbitration_isStuck) || execute_arbitration_removeIt);
  assign when_Pipeline_l154 = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign when_Pipeline_l151_1 = ((! memory_arbitration_isStuck) || memory_arbitration_removeIt);
  assign when_Pipeline_l154_1 = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign when_Pipeline_l151_2 = ((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt);
  assign when_Pipeline_l154_2 = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign when_CsrPlugin_l1669 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_1 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_2 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_3 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_4 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_5 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_6 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_7 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_8 = (! execute_arbitration_isStuck);
  assign when_CsrPlugin_l1669_9 = (! execute_arbitration_isStuck);
  assign switch_CsrPlugin_l1031 = CsrPlugin_csrMapping_writeDataSignal[12 : 11];
  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit = 32'h0;
    if(execute_CsrPlugin_csr_768) begin
      _zz_CsrPlugin_csrMapping_readDataInit[7 : 7] = CsrPlugin_mstatus_MPIE;
      _zz_CsrPlugin_csrMapping_readDataInit[3 : 3] = CsrPlugin_mstatus_MIE;
      _zz_CsrPlugin_csrMapping_readDataInit[12 : 11] = CsrPlugin_mstatus_MPP;
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_1 = 32'h0;
    if(execute_CsrPlugin_csr_836) begin
      _zz_CsrPlugin_csrMapping_readDataInit_1[11 : 11] = CsrPlugin_mip_MEIP;
      _zz_CsrPlugin_csrMapping_readDataInit_1[7 : 7] = CsrPlugin_mip_MTIP;
      _zz_CsrPlugin_csrMapping_readDataInit_1[3 : 3] = CsrPlugin_mip_MSIP;
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_2 = 32'h0;
    if(execute_CsrPlugin_csr_772) begin
      _zz_CsrPlugin_csrMapping_readDataInit_2[11 : 11] = CsrPlugin_mie_MEIE;
      _zz_CsrPlugin_csrMapping_readDataInit_2[7 : 7] = CsrPlugin_mie_MTIE;
      _zz_CsrPlugin_csrMapping_readDataInit_2[3 : 3] = CsrPlugin_mie_MSIE;
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_3 = 32'h0;
    if(execute_CsrPlugin_csr_833) begin
      _zz_CsrPlugin_csrMapping_readDataInit_3[31 : 0] = CsrPlugin_mepc;
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_4 = 32'h0;
    if(execute_CsrPlugin_csr_834) begin
      _zz_CsrPlugin_csrMapping_readDataInit_4[31 : 31] = CsrPlugin_mcause_interrupt;
      _zz_CsrPlugin_csrMapping_readDataInit_4[3 : 0] = CsrPlugin_mcause_exceptionCode;
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_5 = 32'h0;
    if(execute_CsrPlugin_csr_835) begin
      _zz_CsrPlugin_csrMapping_readDataInit_5[31 : 0] = CsrPlugin_mtval;
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_6 = 32'h0;
    if(execute_CsrPlugin_csr_2816) begin
      _zz_CsrPlugin_csrMapping_readDataInit_6[31 : 0] = CsrPlugin_mcycle[31 : 0];
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_7 = 32'h0;
    if(execute_CsrPlugin_csr_2944) begin
      _zz_CsrPlugin_csrMapping_readDataInit_7[31 : 0] = CsrPlugin_mcycle[63 : 32];
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_8 = 32'h0;
    if(execute_CsrPlugin_csr_2818) begin
      _zz_CsrPlugin_csrMapping_readDataInit_8[31 : 0] = CsrPlugin_minstret[31 : 0];
    end
  end

  always @(*) begin
    _zz_CsrPlugin_csrMapping_readDataInit_9 = 32'h0;
    if(execute_CsrPlugin_csr_2946) begin
      _zz_CsrPlugin_csrMapping_readDataInit_9[31 : 0] = CsrPlugin_minstret[63 : 32];
    end
  end

  assign CsrPlugin_csrMapping_readDataInit = ((((_zz_CsrPlugin_csrMapping_readDataInit | _zz_CsrPlugin_csrMapping_readDataInit_1) | (_zz_CsrPlugin_csrMapping_readDataInit_2 | _zz_CsrPlugin_csrMapping_readDataInit_3)) | ((_zz_CsrPlugin_csrMapping_readDataInit_4 | _zz_CsrPlugin_csrMapping_readDataInit_5) | (_zz_CsrPlugin_csrMapping_readDataInit_6 | _zz_CsrPlugin_csrMapping_readDataInit_7))) | (_zz_CsrPlugin_csrMapping_readDataInit_8 | _zz_CsrPlugin_csrMapping_readDataInit_9));
  assign when_CsrPlugin_l1702 = ((execute_arbitration_isValid && execute_IS_CSR) && (({execute_CsrPlugin_csrAddress[11 : 2],2'b00} == 12'h3a0) || ({execute_CsrPlugin_csrAddress[11 : 4],4'b0000} == 12'h3b0)));
  assign _zz_when_CsrPlugin_l1709 = (execute_CsrPlugin_csrAddress & 12'hf60);
  assign when_CsrPlugin_l1709 = (((execute_arbitration_isValid && execute_IS_CSR) && (5'h03 <= execute_CsrPlugin_csrAddress[4 : 0])) && (((_zz_when_CsrPlugin_l1709 == 12'hb00) || (((_zz_when_CsrPlugin_l1709 == 12'hc00) && (! execute_CsrPlugin_writeInstruction)) && (CsrPlugin_privilege == 2'b11))) || ((execute_CsrPlugin_csrAddress & 12'hfe0) == 12'h320)));
  always @(*) begin
    when_CsrPlugin_l1719 = CsrPlugin_csrMapping_doForceFailCsr;
    if(when_CsrPlugin_l1717) begin
      when_CsrPlugin_l1719 = 1'b1;
    end
  end

  assign when_CsrPlugin_l1717 = (CsrPlugin_privilege < execute_CsrPlugin_csrAddress[9 : 8]);
  assign when_CsrPlugin_l1725 = ((! execute_arbitration_isValid) || (! execute_IS_CSR));
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      IBusSimplePlugin_fetchPc_pcReg <= 32'h80000000;
      IBusSimplePlugin_fetchPc_correctionReg <= 1'b0;
      IBusSimplePlugin_fetchPc_booted <= 1'b0;
      IBusSimplePlugin_fetchPc_inc <= 1'b0;
      _zz_IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid <= 1'b0;
      _zz_IBusSimplePlugin_injector_decodeInput_valid <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      IBusSimplePlugin_cmd_rValidN <= 1'b1;
      IBusSimplePlugin_pending_value <= 3'b000;
      IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= 3'b000;
      _zz_10 <= 1'b1;
      memory_DivPlugin_div_counter_value <= 6'h0;
      HazardSimplePlugin_writeBackBuffer_valid <= 1'b0;
      CsrPlugin_mstatus_MIE <= 1'b0;
      CsrPlugin_mstatus_MPIE <= 1'b0;
      CsrPlugin_mstatus_MPP <= 2'b11;
      CsrPlugin_mie_MEIE <= 1'b0;
      CsrPlugin_mie_MTIE <= 1'b0;
      CsrPlugin_mie_MSIE <= 1'b0;
      CsrPlugin_mcycle <= 64'h0;
      CsrPlugin_minstret <= 64'h0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
      CsrPlugin_interrupt_valid <= 1'b0;
      CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
      CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
      CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
      CsrPlugin_hadException <= 1'b0;
      execute_CsrPlugin_wfiWake <= 1'b0;
      execute_arbitration_isValid <= 1'b0;
      memory_arbitration_isValid <= 1'b0;
      writeBack_arbitration_isValid <= 1'b0;
    end else begin
      if(IBusSimplePlugin_fetchPc_correction) begin
        IBusSimplePlugin_fetchPc_correctionReg <= 1'b1;
      end
      if(IBusSimplePlugin_fetchPc_output_fire) begin
        IBusSimplePlugin_fetchPc_correctionReg <= 1'b0;
      end
      IBusSimplePlugin_fetchPc_booted <= 1'b1;
      if(when_Fetcher_l133) begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusSimplePlugin_fetchPc_output_fire) begin
        IBusSimplePlugin_fetchPc_inc <= 1'b1;
      end
      if(when_Fetcher_l133_1) begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(when_Fetcher_l160) begin
        IBusSimplePlugin_fetchPc_pcReg <= IBusSimplePlugin_fetchPc_pc;
      end
      if(IBusSimplePlugin_iBusRsp_flush) begin
        _zz_IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid <= 1'b0;
      end
      if(IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_ready) begin
        _zz_IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_m2sPipe_valid <= (IBusSimplePlugin_iBusRsp_stages_0_output_toEvent_valid && (! 1'b0));
      end
      if(decode_arbitration_removeIt) begin
        _zz_IBusSimplePlugin_injector_decodeInput_valid <= 1'b0;
      end
      if(IBusSimplePlugin_iBusRsp_output_ready) begin
        _zz_IBusSimplePlugin_injector_decodeInput_valid <= (IBusSimplePlugin_iBusRsp_output_valid && (! IBusSimplePlugin_externalFlush));
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if(when_Fetcher_l331) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if(when_Fetcher_l331_1) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= IBusSimplePlugin_injector_nextPcCalc_valids_0;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if(when_Fetcher_l331_2) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_2 <= IBusSimplePlugin_injector_nextPcCalc_valids_1;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      end
      if(when_Fetcher_l331_3) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_3 <= IBusSimplePlugin_injector_nextPcCalc_valids_2;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      end
      if(when_Fetcher_l331_4) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_4 <= IBusSimplePlugin_injector_nextPcCalc_valids_3;
      end
      if(IBusSimplePlugin_fetchPc_flushed) begin
        IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      end
      if(IBusSimplePlugin_cmd_valid) begin
        IBusSimplePlugin_cmd_rValidN <= 1'b0;
      end
      if(IBusSimplePlugin_cmd_s2mPipe_ready) begin
        IBusSimplePlugin_cmd_rValidN <= 1'b1;
      end
      IBusSimplePlugin_pending_value <= IBusSimplePlugin_pending_next;
      IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter - _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter);
      if(IBusSimplePlugin_iBusRsp_flush) begin
        IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= (IBusSimplePlugin_pending_value - _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_2);
      end
      _zz_10 <= 1'b0;
      memory_DivPlugin_div_counter_value <= memory_DivPlugin_div_counter_valueNext;
      HazardSimplePlugin_writeBackBuffer_valid <= HazardSimplePlugin_writeBackWrites_valid;
      CsrPlugin_mcycle <= (CsrPlugin_mcycle + 64'h0000000000000001);
      if(writeBack_arbitration_isFiring) begin
        CsrPlugin_minstret <= (CsrPlugin_minstret + 64'h0000000000000001);
      end
      if(when_CsrPlugin_l1259) begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= 1'b0;
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
      end
      if(when_CsrPlugin_l1259_1) begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= (CsrPlugin_exceptionPortCtrl_exceptionValids_decode && (! decode_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
      end
      if(when_CsrPlugin_l1259_2) begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && (! execute_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
      end
      if(when_CsrPlugin_l1259_3) begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= (CsrPlugin_exceptionPortCtrl_exceptionValids_memory && (! memory_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
      end
      CsrPlugin_interrupt_valid <= 1'b0;
      if(when_CsrPlugin_l1296) begin
        if(when_CsrPlugin_l1302) begin
          CsrPlugin_interrupt_valid <= 1'b1;
        end
        if(when_CsrPlugin_l1302_1) begin
          CsrPlugin_interrupt_valid <= 1'b1;
        end
        if(when_CsrPlugin_l1302_2) begin
          CsrPlugin_interrupt_valid <= 1'b1;
        end
      end
      if(CsrPlugin_pipelineLiberator_active) begin
        if(when_CsrPlugin_l1335) begin
          CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b1;
        end
        if(when_CsrPlugin_l1335_1) begin
          CsrPlugin_pipelineLiberator_pcValids_1 <= CsrPlugin_pipelineLiberator_pcValids_0;
        end
        if(when_CsrPlugin_l1335_2) begin
          CsrPlugin_pipelineLiberator_pcValids_2 <= CsrPlugin_pipelineLiberator_pcValids_1;
        end
      end
      if(when_CsrPlugin_l1340) begin
        CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
        CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
        CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
      end
      if(CsrPlugin_interruptJump) begin
        CsrPlugin_interrupt_valid <= 1'b0;
      end
      CsrPlugin_hadException <= CsrPlugin_exception;
      if(when_CsrPlugin_l1390) begin
        if(when_CsrPlugin_l1398) begin
          case(CsrPlugin_targetPrivilege)
            2'b11 : begin
              CsrPlugin_mstatus_MIE <= 1'b0;
              CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
              CsrPlugin_mstatus_MPP <= CsrPlugin_privilege;
            end
            default : begin
            end
          endcase
        end
      end
      if(when_CsrPlugin_l1456) begin
        case(switch_CsrPlugin_l1460)
          2'b11 : begin
            CsrPlugin_mstatus_MPP <= 2'b00;
            CsrPlugin_mstatus_MIE <= CsrPlugin_mstatus_MPIE;
            CsrPlugin_mstatus_MPIE <= 1'b1;
          end
          default : begin
          end
        endcase
      end
      execute_CsrPlugin_wfiWake <= ((|{_zz_when_CsrPlugin_l1302_2,{_zz_when_CsrPlugin_l1302_1,_zz_when_CsrPlugin_l1302}}) || CsrPlugin_thirdPartyWake);
      if(when_Pipeline_l151) begin
        execute_arbitration_isValid <= 1'b0;
      end
      if(when_Pipeline_l154) begin
        execute_arbitration_isValid <= decode_arbitration_isValid;
      end
      if(when_Pipeline_l151_1) begin
        memory_arbitration_isValid <= 1'b0;
      end
      if(when_Pipeline_l154_1) begin
        memory_arbitration_isValid <= execute_arbitration_isValid;
      end
      if(when_Pipeline_l151_2) begin
        writeBack_arbitration_isValid <= 1'b0;
      end
      if(when_Pipeline_l154_2) begin
        writeBack_arbitration_isValid <= memory_arbitration_isValid;
      end
      if(execute_CsrPlugin_csr_768) begin
        if(execute_CsrPlugin_writeEnable) begin
          CsrPlugin_mstatus_MPIE <= CsrPlugin_csrMapping_writeDataSignal[7];
          CsrPlugin_mstatus_MIE <= CsrPlugin_csrMapping_writeDataSignal[3];
          case(switch_CsrPlugin_l1031)
            2'b11 : begin
              CsrPlugin_mstatus_MPP <= 2'b11;
            end
            default : begin
            end
          endcase
        end
      end
      if(execute_CsrPlugin_csr_772) begin
        if(execute_CsrPlugin_writeEnable) begin
          CsrPlugin_mie_MEIE <= CsrPlugin_csrMapping_writeDataSignal[11];
          CsrPlugin_mie_MTIE <= CsrPlugin_csrMapping_writeDataSignal[7];
          CsrPlugin_mie_MSIE <= CsrPlugin_csrMapping_writeDataSignal[3];
        end
      end
    end
  end

  always @(posedge io_axiClk) begin
    if(IBusSimplePlugin_iBusRsp_output_ready) begin
      _zz_IBusSimplePlugin_injector_decodeInput_payload_pc <= IBusSimplePlugin_iBusRsp_output_payload_pc;
      _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error <= IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
      _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
      _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc <= IBusSimplePlugin_iBusRsp_output_payload_isRvc;
    end
    if(IBusSimplePlugin_injector_decodeInput_ready) begin
      IBusSimplePlugin_injector_formal_rawInDecode <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
    end
    if(IBusSimplePlugin_cmd_ready) begin
      IBusSimplePlugin_cmd_rData_pc <= IBusSimplePlugin_cmd_payload_pc;
    end
    if(when_MulDivIterativePlugin_l126) begin
      memory_DivPlugin_div_done <= 1'b1;
    end
    if(when_MulDivIterativePlugin_l126_1) begin
      memory_DivPlugin_div_done <= 1'b0;
    end
    if(when_MulDivIterativePlugin_l128) begin
      if(when_MulDivIterativePlugin_l132) begin
        memory_DivPlugin_rs1[31 : 0] <= memory_DivPlugin_div_stage_0_outNumerator;
        memory_DivPlugin_accumulator[31 : 0] <= memory_DivPlugin_div_stage_0_outRemainder;
        if(when_MulDivIterativePlugin_l151) begin
          memory_DivPlugin_div_result <= _zz_memory_DivPlugin_div_result_1[31:0];
        end
      end
    end
    if(when_MulDivIterativePlugin_l162) begin
      memory_DivPlugin_accumulator <= 65'h0;
      memory_DivPlugin_rs1 <= ((_zz_memory_DivPlugin_rs1 ? (~ _zz_memory_DivPlugin_rs1_1) : _zz_memory_DivPlugin_rs1_1) + _zz_memory_DivPlugin_rs1_2);
      memory_DivPlugin_rs2 <= ((_zz_memory_DivPlugin_rs2 ? (~ execute_RS2) : execute_RS2) + _zz_memory_DivPlugin_rs2_1);
      memory_DivPlugin_div_needRevert <= ((_zz_memory_DivPlugin_rs1 ^ (_zz_memory_DivPlugin_rs2 && (! execute_INSTRUCTION[13]))) && (! (((execute_RS2 == 32'h0) && execute_IS_RS2_SIGNED) && (! execute_INSTRUCTION[13]))));
    end
    HazardSimplePlugin_writeBackBuffer_payload_address <= HazardSimplePlugin_writeBackWrites_payload_address;
    HazardSimplePlugin_writeBackBuffer_payload_data <= HazardSimplePlugin_writeBackWrites_payload_data;
    CsrPlugin_mip_MEIP <= externalInterrupt;
    CsrPlugin_mip_MTIP <= timerInterrupt;
    CsrPlugin_mip_MSIP <= softwareInterrupt;
    if(_zz_when) begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 ? IBusSimplePlugin_decodeExceptionPort_payload_code : decodeExceptionPort_payload_code);
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 ? IBusSimplePlugin_decodeExceptionPort_payload_badAddr : decodeExceptionPort_payload_badAddr);
    end
    if(_zz_when_1) begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3 ? DBusSimplePlugin_memoryExceptionPort_payload_code : BranchPlugin_branchExceptionPort_payload_code);
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_3 ? DBusSimplePlugin_memoryExceptionPort_payload_badAddr : BranchPlugin_branchExceptionPort_payload_badAddr);
    end
    if(when_CsrPlugin_l1296) begin
      if(when_CsrPlugin_l1302) begin
        CsrPlugin_interrupt_code <= 4'b0111;
        CsrPlugin_interrupt_targetPrivilege <= 2'b11;
      end
      if(when_CsrPlugin_l1302_1) begin
        CsrPlugin_interrupt_code <= 4'b0011;
        CsrPlugin_interrupt_targetPrivilege <= 2'b11;
      end
      if(when_CsrPlugin_l1302_2) begin
        CsrPlugin_interrupt_code <= 4'b1011;
        CsrPlugin_interrupt_targetPrivilege <= 2'b11;
      end
    end
    if(when_CsrPlugin_l1390) begin
      if(when_CsrPlugin_l1398) begin
        case(CsrPlugin_targetPrivilege)
          2'b11 : begin
            CsrPlugin_mcause_interrupt <= (! CsrPlugin_hadException);
            CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
            CsrPlugin_mepc <= writeBack_PC;
            if(CsrPlugin_hadException) begin
              CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
            end
          end
          default : begin
          end
        endcase
      end
    end
    if(when_Pipeline_l124) begin
      decode_to_execute_PC <= decode_PC;
    end
    if(when_Pipeline_l124_1) begin
      execute_to_memory_PC <= _zz_execute_to_memory_PC;
    end
    if(when_Pipeline_l124_2) begin
      memory_to_writeBack_PC <= memory_PC;
    end
    if(when_Pipeline_l124_3) begin
      decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
    end
    if(when_Pipeline_l124_4) begin
      execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
    end
    if(when_Pipeline_l124_5) begin
      memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
    end
    if(when_Pipeline_l124_6) begin
      decode_to_execute_FORMAL_PC_NEXT <= _zz_decode_to_execute_FORMAL_PC_NEXT;
    end
    if(when_Pipeline_l124_7) begin
      execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
    end
    if(when_Pipeline_l124_8) begin
      memory_to_writeBack_FORMAL_PC_NEXT <= _zz_memory_to_writeBack_FORMAL_PC_NEXT;
    end
    if(when_Pipeline_l124_9) begin
      decode_to_execute_SRC1_CTRL <= _zz_decode_to_execute_SRC1_CTRL;
    end
    if(when_Pipeline_l124_10) begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if(when_Pipeline_l124_11) begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if(when_Pipeline_l124_12) begin
      execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
    end
    if(when_Pipeline_l124_13) begin
      memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
    end
    if(when_Pipeline_l124_14) begin
      decode_to_execute_ALU_CTRL <= _zz_decode_to_execute_ALU_CTRL;
    end
    if(when_Pipeline_l124_15) begin
      decode_to_execute_SRC2_CTRL <= _zz_decode_to_execute_SRC2_CTRL;
    end
    if(when_Pipeline_l124_16) begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if(when_Pipeline_l124_17) begin
      execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
    end
    if(when_Pipeline_l124_18) begin
      memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
    end
    if(when_Pipeline_l124_19) begin
      decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
    end
    if(when_Pipeline_l124_20) begin
      decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
    end
    if(when_Pipeline_l124_21) begin
      execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
    end
    if(when_Pipeline_l124_22) begin
      decode_to_execute_MEMORY_STORE <= decode_MEMORY_STORE;
    end
    if(when_Pipeline_l124_23) begin
      execute_to_memory_MEMORY_STORE <= execute_MEMORY_STORE;
    end
    if(when_Pipeline_l124_24) begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if(when_Pipeline_l124_25) begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_decode_to_execute_ALU_BITWISE_CTRL;
    end
    if(when_Pipeline_l124_26) begin
      decode_to_execute_SHIFT_CTRL <= _zz_decode_to_execute_SHIFT_CTRL;
    end
    if(when_Pipeline_l124_27) begin
      execute_to_memory_SHIFT_CTRL <= _zz_execute_to_memory_SHIFT_CTRL;
    end
    if(when_Pipeline_l124_28) begin
      decode_to_execute_IS_MUL <= decode_IS_MUL;
    end
    if(when_Pipeline_l124_29) begin
      execute_to_memory_IS_MUL <= execute_IS_MUL;
    end
    if(when_Pipeline_l124_30) begin
      memory_to_writeBack_IS_MUL <= memory_IS_MUL;
    end
    if(when_Pipeline_l124_31) begin
      decode_to_execute_IS_DIV <= decode_IS_DIV;
    end
    if(when_Pipeline_l124_32) begin
      execute_to_memory_IS_DIV <= execute_IS_DIV;
    end
    if(when_Pipeline_l124_33) begin
      decode_to_execute_IS_RS1_SIGNED <= decode_IS_RS1_SIGNED;
    end
    if(when_Pipeline_l124_34) begin
      decode_to_execute_IS_RS2_SIGNED <= decode_IS_RS2_SIGNED;
    end
    if(when_Pipeline_l124_35) begin
      decode_to_execute_BRANCH_CTRL <= _zz_decode_to_execute_BRANCH_CTRL;
    end
    if(when_Pipeline_l124_36) begin
      decode_to_execute_IS_CSR <= decode_IS_CSR;
    end
    if(when_Pipeline_l124_37) begin
      decode_to_execute_ENV_CTRL <= _zz_decode_to_execute_ENV_CTRL;
    end
    if(when_Pipeline_l124_38) begin
      execute_to_memory_ENV_CTRL <= _zz_execute_to_memory_ENV_CTRL;
    end
    if(when_Pipeline_l124_39) begin
      memory_to_writeBack_ENV_CTRL <= _zz_memory_to_writeBack_ENV_CTRL;
    end
    if(when_Pipeline_l124_40) begin
      decode_to_execute_RS1 <= decode_RS1;
    end
    if(when_Pipeline_l124_41) begin
      decode_to_execute_RS2 <= decode_RS2;
    end
    if(when_Pipeline_l124_42) begin
      decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
    end
    if(when_Pipeline_l124_43) begin
      decode_to_execute_PREDICTION_HAD_BRANCHED1 <= decode_PREDICTION_HAD_BRANCHED1;
    end
    if(when_Pipeline_l124_44) begin
      decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
    end
    if(when_Pipeline_l124_45) begin
      decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
    end
    if(when_Pipeline_l124_46) begin
      execute_to_memory_ALIGNEMENT_FAULT <= execute_ALIGNEMENT_FAULT;
    end
    if(when_Pipeline_l124_47) begin
      execute_to_memory_MEMORY_ADDRESS_LOW <= execute_MEMORY_ADDRESS_LOW;
    end
    if(when_Pipeline_l124_48) begin
      memory_to_writeBack_MEMORY_ADDRESS_LOW <= memory_MEMORY_ADDRESS_LOW;
    end
    if(when_Pipeline_l124_49) begin
      execute_to_memory_REGFILE_WRITE_DATA <= _zz_decode_RS2;
    end
    if(when_Pipeline_l124_50) begin
      memory_to_writeBack_REGFILE_WRITE_DATA <= _zz_decode_RS2_1;
    end
    if(when_Pipeline_l124_51) begin
      execute_to_memory_SHIFT_RIGHT <= execute_SHIFT_RIGHT;
    end
    if(when_Pipeline_l124_52) begin
      execute_to_memory_MUL_LL <= execute_MUL_LL;
    end
    if(when_Pipeline_l124_53) begin
      execute_to_memory_MUL_LH <= execute_MUL_LH;
    end
    if(when_Pipeline_l124_54) begin
      execute_to_memory_MUL_HL <= execute_MUL_HL;
    end
    if(when_Pipeline_l124_55) begin
      execute_to_memory_MUL_HH <= execute_MUL_HH;
    end
    if(when_Pipeline_l124_56) begin
      memory_to_writeBack_MUL_HH <= memory_MUL_HH;
    end
    if(when_Pipeline_l124_57) begin
      execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
    end
    if(when_Pipeline_l124_58) begin
      execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
    end
    if(when_Pipeline_l124_59) begin
      memory_to_writeBack_MEMORY_READ_DATA <= memory_MEMORY_READ_DATA;
    end
    if(when_Pipeline_l124_60) begin
      memory_to_writeBack_MUL_LOW <= memory_MUL_LOW;
    end
    if(when_CsrPlugin_l1669) begin
      execute_CsrPlugin_csr_768 <= (decode_INSTRUCTION[31 : 20] == 12'h300);
    end
    if(when_CsrPlugin_l1669_1) begin
      execute_CsrPlugin_csr_836 <= (decode_INSTRUCTION[31 : 20] == 12'h344);
    end
    if(when_CsrPlugin_l1669_2) begin
      execute_CsrPlugin_csr_772 <= (decode_INSTRUCTION[31 : 20] == 12'h304);
    end
    if(when_CsrPlugin_l1669_3) begin
      execute_CsrPlugin_csr_833 <= (decode_INSTRUCTION[31 : 20] == 12'h341);
    end
    if(when_CsrPlugin_l1669_4) begin
      execute_CsrPlugin_csr_834 <= (decode_INSTRUCTION[31 : 20] == 12'h342);
    end
    if(when_CsrPlugin_l1669_5) begin
      execute_CsrPlugin_csr_835 <= (decode_INSTRUCTION[31 : 20] == 12'h343);
    end
    if(when_CsrPlugin_l1669_6) begin
      execute_CsrPlugin_csr_2816 <= (decode_INSTRUCTION[31 : 20] == 12'hb00);
    end
    if(when_CsrPlugin_l1669_7) begin
      execute_CsrPlugin_csr_2944 <= (decode_INSTRUCTION[31 : 20] == 12'hb80);
    end
    if(when_CsrPlugin_l1669_8) begin
      execute_CsrPlugin_csr_2818 <= (decode_INSTRUCTION[31 : 20] == 12'hb02);
    end
    if(when_CsrPlugin_l1669_9) begin
      execute_CsrPlugin_csr_2946 <= (decode_INSTRUCTION[31 : 20] == 12'hb82);
    end
    if(execute_CsrPlugin_csr_836) begin
      if(execute_CsrPlugin_writeEnable) begin
        CsrPlugin_mip_MSIP <= CsrPlugin_csrMapping_writeDataSignal[3];
      end
    end
    if(execute_CsrPlugin_csr_833) begin
      if(execute_CsrPlugin_writeEnable) begin
        CsrPlugin_mepc <= CsrPlugin_csrMapping_writeDataSignal[31 : 0];
      end
    end
  end


endmodule

module vexAxi4ToAxiLiteBridge (
  input  wire          io_input_aw_valid,
  output wire          io_input_aw_ready,
  input  wire [31:0]   io_input_aw_payload_addr,
  input  wire [3:0]    io_input_aw_payload_id,
  input  wire [3:0]    io_input_aw_payload_region,
  input  wire [7:0]    io_input_aw_payload_len,
  input  wire [2:0]    io_input_aw_payload_size,
  input  wire [1:0]    io_input_aw_payload_burst,
  input  wire [0:0]    io_input_aw_payload_lock,
  input  wire [3:0]    io_input_aw_payload_cache,
  input  wire [3:0]    io_input_aw_payload_qos,
  input  wire [2:0]    io_input_aw_payload_prot,
  input  wire          io_input_w_valid,
  output wire          io_input_w_ready,
  input  wire [31:0]   io_input_w_payload_data,
  input  wire [3:0]    io_input_w_payload_strb,
  input  wire          io_input_w_payload_last,
  output wire          io_input_b_valid,
  input  wire          io_input_b_ready,
  output wire [3:0]    io_input_b_payload_id,
  output wire [1:0]    io_input_b_payload_resp,
  input  wire          io_input_ar_valid,
  output wire          io_input_ar_ready,
  input  wire [31:0]   io_input_ar_payload_addr,
  input  wire [3:0]    io_input_ar_payload_id,
  input  wire [3:0]    io_input_ar_payload_region,
  input  wire [7:0]    io_input_ar_payload_len,
  input  wire [2:0]    io_input_ar_payload_size,
  input  wire [1:0]    io_input_ar_payload_burst,
  input  wire [0:0]    io_input_ar_payload_lock,
  input  wire [3:0]    io_input_ar_payload_cache,
  input  wire [3:0]    io_input_ar_payload_qos,
  input  wire [2:0]    io_input_ar_payload_prot,
  output wire          io_input_r_valid,
  input  wire          io_input_r_ready,
  output wire [31:0]   io_input_r_payload_data,
  output wire [3:0]    io_input_r_payload_id,
  output wire [1:0]    io_input_r_payload_resp,
  output wire          io_input_r_payload_last,
  output wire          io_output_aw_valid,
  input  wire          io_output_aw_ready,
  output wire [31:0]   io_output_aw_payload_addr,
  output wire [2:0]    io_output_aw_payload_prot,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [31:0]   io_output_w_payload_data,
  output wire [3:0]    io_output_w_payload_strb,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [1:0]    io_output_b_payload_resp,
  output wire          io_output_ar_valid,
  input  wire          io_output_ar_ready,
  output wire [31:0]   io_output_ar_payload_addr,
  output wire [2:0]    io_output_ar_payload_prot,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [31:0]   io_output_r_payload_data,
  input  wire [1:0]    io_output_r_payload_resp
);


  assign io_output_ar_valid = io_input_ar_valid;
  assign io_output_ar_payload_addr = io_input_ar_payload_addr;
  assign io_output_ar_payload_prot = io_input_ar_payload_prot;
  assign io_input_ar_ready = io_output_ar_ready;
  assign io_input_r_valid = io_output_r_valid;
  assign io_input_r_payload_data = io_output_r_payload_data;
  assign io_input_r_payload_resp = io_output_r_payload_resp;
  assign io_input_r_payload_last = 1'b1;
  assign io_input_r_payload_id = 4'b0000;
  assign io_output_r_ready = io_input_r_ready;
  assign io_output_aw_valid = io_input_aw_valid;
  assign io_output_aw_payload_addr = io_input_aw_payload_addr;
  assign io_output_aw_payload_prot = io_input_aw_payload_prot;
  assign io_input_aw_ready = io_output_aw_ready;
  assign io_output_w_valid = io_input_w_valid;
  assign io_output_w_payload_data = io_input_w_payload_data;
  assign io_output_w_payload_strb = io_input_w_payload_strb;
  assign io_input_w_ready = io_output_w_ready;
  assign io_input_b_valid = io_output_b_valid;
  assign io_input_b_payload_resp = io_output_b_payload_resp;
  assign io_input_b_payload_id = 4'b0000;
  assign io_output_b_ready = io_input_b_ready;

endmodule

//vexAxi4SharedToAxi4_2 replaced by vexAxi4SharedToAxi4

//vexAxi4SharedToAxi4_1 replaced by vexAxi4SharedToAxi4

module vexAxi4SharedToAxi4 (
  input  wire          io_shared_arw_valid,
  output reg           io_shared_arw_ready,
  input  wire [31:0]   io_shared_arw_payload_addr,
  input  wire [3:0]    io_shared_arw_payload_id,
  input  wire [3:0]    io_shared_arw_payload_region,
  input  wire [7:0]    io_shared_arw_payload_len,
  input  wire [2:0]    io_shared_arw_payload_size,
  input  wire [1:0]    io_shared_arw_payload_burst,
  input  wire [0:0]    io_shared_arw_payload_lock,
  input  wire [3:0]    io_shared_arw_payload_cache,
  input  wire [3:0]    io_shared_arw_payload_qos,
  input  wire [2:0]    io_shared_arw_payload_prot,
  input  wire          io_shared_arw_payload_write,
  input  wire          io_shared_w_valid,
  output wire          io_shared_w_ready,
  input  wire [31:0]   io_shared_w_payload_data,
  input  wire [3:0]    io_shared_w_payload_strb,
  input  wire          io_shared_w_payload_last,
  output wire          io_shared_b_valid,
  input  wire          io_shared_b_ready,
  output wire [3:0]    io_shared_b_payload_id,
  output wire [1:0]    io_shared_b_payload_resp,
  output wire          io_shared_r_valid,
  input  wire          io_shared_r_ready,
  output wire [31:0]   io_shared_r_payload_data,
  output wire [3:0]    io_shared_r_payload_id,
  output wire [1:0]    io_shared_r_payload_resp,
  output wire          io_shared_r_payload_last,
  output wire          io_axi_aw_valid,
  input  wire          io_axi_aw_ready,
  output wire [31:0]   io_axi_aw_payload_addr,
  output wire [3:0]    io_axi_aw_payload_id,
  output wire [3:0]    io_axi_aw_payload_region,
  output wire [7:0]    io_axi_aw_payload_len,
  output wire [2:0]    io_axi_aw_payload_size,
  output wire [1:0]    io_axi_aw_payload_burst,
  output wire [0:0]    io_axi_aw_payload_lock,
  output wire [3:0]    io_axi_aw_payload_cache,
  output wire [3:0]    io_axi_aw_payload_qos,
  output wire [2:0]    io_axi_aw_payload_prot,
  output wire          io_axi_w_valid,
  input  wire          io_axi_w_ready,
  output wire [31:0]   io_axi_w_payload_data,
  output wire [3:0]    io_axi_w_payload_strb,
  output wire          io_axi_w_payload_last,
  input  wire          io_axi_b_valid,
  output wire          io_axi_b_ready,
  input  wire [3:0]    io_axi_b_payload_id,
  input  wire [1:0]    io_axi_b_payload_resp,
  output wire          io_axi_ar_valid,
  input  wire          io_axi_ar_ready,
  output wire [31:0]   io_axi_ar_payload_addr,
  output wire [3:0]    io_axi_ar_payload_id,
  output wire [3:0]    io_axi_ar_payload_region,
  output wire [7:0]    io_axi_ar_payload_len,
  output wire [2:0]    io_axi_ar_payload_size,
  output wire [1:0]    io_axi_ar_payload_burst,
  output wire [0:0]    io_axi_ar_payload_lock,
  output wire [3:0]    io_axi_ar_payload_cache,
  output wire [3:0]    io_axi_ar_payload_qos,
  output wire [2:0]    io_axi_ar_payload_prot,
  input  wire          io_axi_r_valid,
  output wire          io_axi_r_ready,
  input  wire [31:0]   io_axi_r_payload_data,
  input  wire [3:0]    io_axi_r_payload_id,
  input  wire [1:0]    io_axi_r_payload_resp,
  input  wire          io_axi_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire                arFork_valid;
  wire                arFork_ready;
  wire       [31:0]   arFork_payload_addr;
  wire       [3:0]    arFork_payload_id;
  wire       [3:0]    arFork_payload_region;
  wire       [7:0]    arFork_payload_len;
  wire       [2:0]    arFork_payload_size;
  wire       [1:0]    arFork_payload_burst;
  wire       [0:0]    arFork_payload_lock;
  wire       [3:0]    arFork_payload_cache;
  wire       [3:0]    arFork_payload_qos;
  wire       [2:0]    arFork_payload_prot;
  wire                arFork_payload_write;
  wire                awFork_valid;
  wire                awFork_ready;
  wire       [31:0]   awFork_payload_addr;
  wire       [3:0]    awFork_payload_id;
  wire       [3:0]    awFork_payload_region;
  wire       [7:0]    awFork_payload_len;
  wire       [2:0]    awFork_payload_size;
  wire       [1:0]    awFork_payload_burst;
  wire       [0:0]    awFork_payload_lock;
  wire       [3:0]    awFork_payload_cache;
  wire       [3:0]    awFork_payload_qos;
  wire       [2:0]    awFork_payload_prot;
  wire                awFork_payload_write;
  reg                 io_shared_arw_fork2_logic_linkEnable_0;
  reg                 io_shared_arw_fork2_logic_linkEnable_1;
  wire                when_Stream_l1253;
  wire                when_Stream_l1253_1;
  wire                arFork_fire;
  wire                awFork_fire;

  always @(*) begin
    io_shared_arw_ready = 1'b1;
    if(when_Stream_l1253) begin
      io_shared_arw_ready = 1'b0;
    end
    if(when_Stream_l1253_1) begin
      io_shared_arw_ready = 1'b0;
    end
  end

  assign when_Stream_l1253 = ((! arFork_ready) && io_shared_arw_fork2_logic_linkEnable_0);
  assign when_Stream_l1253_1 = ((! awFork_ready) && io_shared_arw_fork2_logic_linkEnable_1);
  assign arFork_valid = (io_shared_arw_valid && io_shared_arw_fork2_logic_linkEnable_0);
  assign arFork_payload_addr = io_shared_arw_payload_addr;
  assign arFork_payload_id = io_shared_arw_payload_id;
  assign arFork_payload_region = io_shared_arw_payload_region;
  assign arFork_payload_len = io_shared_arw_payload_len;
  assign arFork_payload_size = io_shared_arw_payload_size;
  assign arFork_payload_burst = io_shared_arw_payload_burst;
  assign arFork_payload_lock = io_shared_arw_payload_lock;
  assign arFork_payload_cache = io_shared_arw_payload_cache;
  assign arFork_payload_qos = io_shared_arw_payload_qos;
  assign arFork_payload_prot = io_shared_arw_payload_prot;
  assign arFork_payload_write = io_shared_arw_payload_write;
  assign arFork_fire = (arFork_valid && arFork_ready);
  assign awFork_valid = (io_shared_arw_valid && io_shared_arw_fork2_logic_linkEnable_1);
  assign awFork_payload_addr = io_shared_arw_payload_addr;
  assign awFork_payload_id = io_shared_arw_payload_id;
  assign awFork_payload_region = io_shared_arw_payload_region;
  assign awFork_payload_len = io_shared_arw_payload_len;
  assign awFork_payload_size = io_shared_arw_payload_size;
  assign awFork_payload_burst = io_shared_arw_payload_burst;
  assign awFork_payload_lock = io_shared_arw_payload_lock;
  assign awFork_payload_cache = io_shared_arw_payload_cache;
  assign awFork_payload_qos = io_shared_arw_payload_qos;
  assign awFork_payload_prot = io_shared_arw_payload_prot;
  assign awFork_payload_write = io_shared_arw_payload_write;
  assign awFork_fire = (awFork_valid && awFork_ready);
  assign io_axi_ar_valid = (arFork_valid && (! arFork_payload_write));
  assign io_axi_ar_payload_addr = arFork_payload_addr;
  assign io_axi_ar_payload_id = arFork_payload_id;
  assign io_axi_ar_payload_region = arFork_payload_region;
  assign io_axi_ar_payload_len = arFork_payload_len;
  assign io_axi_ar_payload_size = arFork_payload_size;
  assign io_axi_ar_payload_burst = arFork_payload_burst;
  assign io_axi_ar_payload_lock = arFork_payload_lock;
  assign io_axi_ar_payload_cache = arFork_payload_cache;
  assign io_axi_ar_payload_qos = arFork_payload_qos;
  assign io_axi_ar_payload_prot = arFork_payload_prot;
  assign arFork_ready = (io_axi_ar_ready || arFork_payload_write);
  assign io_axi_aw_valid = (awFork_valid && awFork_payload_write);
  assign io_axi_aw_payload_addr = awFork_payload_addr;
  assign io_axi_aw_payload_id = awFork_payload_id;
  assign io_axi_aw_payload_region = awFork_payload_region;
  assign io_axi_aw_payload_len = awFork_payload_len;
  assign io_axi_aw_payload_size = awFork_payload_size;
  assign io_axi_aw_payload_burst = awFork_payload_burst;
  assign io_axi_aw_payload_lock = awFork_payload_lock;
  assign io_axi_aw_payload_cache = awFork_payload_cache;
  assign io_axi_aw_payload_qos = awFork_payload_qos;
  assign io_axi_aw_payload_prot = awFork_payload_prot;
  assign awFork_ready = (io_axi_aw_ready || (! awFork_payload_write));
  assign io_axi_w_valid = io_shared_w_valid;
  assign io_shared_w_ready = io_axi_w_ready;
  assign io_axi_w_payload_data = io_shared_w_payload_data;
  assign io_axi_w_payload_strb = io_shared_w_payload_strb;
  assign io_axi_w_payload_last = io_shared_w_payload_last;
  assign io_shared_b_valid = io_axi_b_valid;
  assign io_axi_b_ready = io_shared_b_ready;
  assign io_shared_b_payload_id = io_axi_b_payload_id;
  assign io_shared_b_payload_resp = io_axi_b_payload_resp;
  assign io_shared_r_valid = io_axi_r_valid;
  assign io_axi_r_ready = io_shared_r_ready;
  assign io_shared_r_payload_data = io_axi_r_payload_data;
  assign io_shared_r_payload_id = io_axi_r_payload_id;
  assign io_shared_r_payload_resp = io_axi_r_payload_resp;
  assign io_shared_r_payload_last = io_axi_r_payload_last;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      io_shared_arw_fork2_logic_linkEnable_0 <= 1'b1;
      io_shared_arw_fork2_logic_linkEnable_1 <= 1'b1;
    end else begin
      if(arFork_fire) begin
        io_shared_arw_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(awFork_fire) begin
        io_shared_arw_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_shared_arw_ready) begin
        io_shared_arw_fork2_logic_linkEnable_0 <= 1'b1;
        io_shared_arw_fork2_logic_linkEnable_1 <= 1'b1;
      end
    end
  end


endmodule

module vexApb3UartCtrl (
  input  wire [4:0]    io_apb_PADDR /* verilator public */ ,
  input  wire [0:0]    io_apb_PSEL /* verilator public */ ,
  input  wire          io_apb_PENABLE /* verilator public */ ,
  output wire          io_apb_PREADY /* verilator public */ ,
  input  wire          io_apb_PWRITE /* verilator public */ ,
  input  wire [31:0]   io_apb_PWDATA /* verilator public */ ,
  output reg  [31:0]   io_apb_PRDATA /* verilator public */ ,
  output wire          io_uart_txd,
  input  wire          io_uart_rxd,
  output wire          io_interrupt,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);
  localparam vexUartStopType_ONE = 1'd0;
  localparam vexUartStopType_TWO = 1'd1;
  localparam vexUartParityType_NONE = 2'd0;
  localparam vexUartParityType_EVEN = 2'd1;
  localparam vexUartParityType_ODD = 2'd2;

  reg                 uartCtrl_io_read_queueWithOccupancy_io_pop_ready;
  wire                uartCtrl_io_write_ready;
  wire                uartCtrl_io_read_valid;
  wire       [7:0]    uartCtrl_io_read_payload;
  wire                uartCtrl_io_uart_txd;
  wire                uartCtrl_io_readError;
  wire                uartCtrl_io_readBreak;
  wire                bridge_write_streamUnbuffered_queueWithOccupancy_io_push_ready;
  wire                bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid;
  wire       [7:0]    bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_payload;
  wire       [4:0]    bridge_write_streamUnbuffered_queueWithOccupancy_io_occupancy;
  wire       [4:0]    bridge_write_streamUnbuffered_queueWithOccupancy_io_availability;
  wire                uartCtrl_io_read_queueWithOccupancy_io_push_ready;
  wire                uartCtrl_io_read_queueWithOccupancy_io_pop_valid;
  wire       [7:0]    uartCtrl_io_read_queueWithOccupancy_io_pop_payload;
  wire       [4:0]    uartCtrl_io_read_queueWithOccupancy_io_occupancy;
  wire       [4:0]    uartCtrl_io_read_queueWithOccupancy_io_availability;
  wire       [0:0]    _zz_bridge_misc_readError;
  wire       [0:0]    _zz_bridge_misc_readOverflowError;
  wire       [0:0]    _zz_bridge_misc_breakDetected;
  wire       [0:0]    _zz_bridge_misc_doBreak;
  wire       [0:0]    _zz_bridge_misc_doBreak_1;
  wire       [4:0]    _zz_io_apb_PRDATA;
  wire                busCtrl_readErrorFlag;
  wire                busCtrl_writeErrorFlag;
  wire                busCtrl_askWrite;
  wire                busCtrl_askRead;
  wire                busCtrl_doWrite;
  wire                busCtrl_doRead;
  wire                bridge_busCtrlWrapped_readErrorFlag;
  wire                bridge_busCtrlWrapped_writeErrorFlag;
  reg        [2:0]    bridge_uartConfigReg_frame_dataLength;
  reg        [0:0]    bridge_uartConfigReg_frame_stop;
  reg        [1:0]    bridge_uartConfigReg_frame_parity;
  reg        [19:0]   bridge_uartConfigReg_clockDivider;
  reg                 _zz_bridge_write_streamUnbuffered_valid;
  wire                bridge_write_streamUnbuffered_valid;
  wire                bridge_write_streamUnbuffered_ready;
  wire       [7:0]    bridge_write_streamUnbuffered_payload;
  reg                 bridge_read_streamBreaked_valid;
  reg                 bridge_read_streamBreaked_ready;
  wire       [7:0]    bridge_read_streamBreaked_payload;
  reg                 bridge_interruptCtrl_writeIntEnable;
  reg                 bridge_interruptCtrl_readIntEnable;
  wire                bridge_interruptCtrl_readInt;
  wire                bridge_interruptCtrl_writeInt;
  wire                bridge_interruptCtrl_interrupt;
  reg                 bridge_misc_readError;
  reg                 when_BusSlaveFactory_l341;
  wire                when_BusSlaveFactory_l347;
  reg                 bridge_misc_readOverflowError;
  reg                 when_BusSlaveFactory_l341_1;
  wire                when_BusSlaveFactory_l347_1;
  wire                uartCtrl_io_read_isStall;
  reg                 bridge_misc_breakDetected;
  reg                 uartCtrl_io_readBreak_regNext;
  wire                when_UartCtrl_l155;
  reg                 when_BusSlaveFactory_l341_2;
  wire                when_BusSlaveFactory_l347_2;
  reg                 bridge_misc_doBreak;
  reg                 when_BusSlaveFactory_l377;
  wire                when_BusSlaveFactory_l379;
  reg                 when_BusSlaveFactory_l341_3;
  wire                when_BusSlaveFactory_l347_3;
  wire       [1:0]    _zz_bridge_uartConfigReg_frame_parity;
  wire       [0:0]    _zz_bridge_uartConfigReg_frame_stop;
  wire                when_Apb3SlaveFactory_l81;
  `ifndef SYNTHESIS
  reg [23:0] bridge_uartConfigReg_frame_stop_string;
  reg [31:0] bridge_uartConfigReg_frame_parity_string;
  reg [31:0] _zz_bridge_uartConfigReg_frame_parity_string;
  reg [23:0] _zz_bridge_uartConfigReg_frame_stop_string;
  `endif


  assign _zz_bridge_misc_readError = 1'b0;
  assign _zz_bridge_misc_readOverflowError = 1'b0;
  assign _zz_bridge_misc_breakDetected = 1'b0;
  assign _zz_bridge_misc_doBreak = 1'b1;
  assign _zz_bridge_misc_doBreak_1 = 1'b0;
  assign _zz_io_apb_PRDATA = (5'h10 - bridge_write_streamUnbuffered_queueWithOccupancy_io_occupancy);
  vexUartCtrl uartCtrl (
    .io_config_frame_dataLength (bridge_uartConfigReg_frame_dataLength[2:0]                          ), //i
    .io_config_frame_stop       (bridge_uartConfigReg_frame_stop                                     ), //i
    .io_config_frame_parity     (bridge_uartConfigReg_frame_parity[1:0]                              ), //i
    .io_config_clockDivider     (bridge_uartConfigReg_clockDivider[19:0]                             ), //i
    .io_write_valid             (bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid       ), //i
    .io_write_ready             (uartCtrl_io_write_ready                                             ), //o
    .io_write_payload           (bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_payload[7:0]), //i
    .io_read_valid              (uartCtrl_io_read_valid                                              ), //o
    .io_read_ready              (uartCtrl_io_read_queueWithOccupancy_io_push_ready                   ), //i
    .io_read_payload            (uartCtrl_io_read_payload[7:0]                                       ), //o
    .io_uart_txd                (uartCtrl_io_uart_txd                                                ), //o
    .io_uart_rxd                (io_uart_rxd                                                         ), //i
    .io_readError               (uartCtrl_io_readError                                               ), //o
    .io_writeBreak              (bridge_misc_doBreak                                                 ), //i
    .io_readBreak               (uartCtrl_io_readBreak                                               ), //o
    .io_axiClk                  (io_axiClk                                                           ), //i
    .resetCtrl_axiReset         (resetCtrl_axiReset                                                  )  //i
  );
  vexStreamFifo bridge_write_streamUnbuffered_queueWithOccupancy (
    .io_push_valid      (bridge_write_streamUnbuffered_valid                                  ), //i
    .io_push_ready      (bridge_write_streamUnbuffered_queueWithOccupancy_io_push_ready       ), //o
    .io_push_payload    (bridge_write_streamUnbuffered_payload[7:0]                           ), //i
    .io_pop_valid       (bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid        ), //o
    .io_pop_ready       (uartCtrl_io_write_ready                                              ), //i
    .io_pop_payload     (bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_payload[7:0] ), //o
    .io_flush           (1'b0                                                                 ), //i
    .io_occupancy       (bridge_write_streamUnbuffered_queueWithOccupancy_io_occupancy[4:0]   ), //o
    .io_availability    (bridge_write_streamUnbuffered_queueWithOccupancy_io_availability[4:0]), //o
    .io_axiClk          (io_axiClk                                                            ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                                                   )  //i
  );
  vexStreamFifo uartCtrl_io_read_queueWithOccupancy (
    .io_push_valid      (uartCtrl_io_read_valid                                  ), //i
    .io_push_ready      (uartCtrl_io_read_queueWithOccupancy_io_push_ready       ), //o
    .io_push_payload    (uartCtrl_io_read_payload[7:0]                           ), //i
    .io_pop_valid       (uartCtrl_io_read_queueWithOccupancy_io_pop_valid        ), //o
    .io_pop_ready       (uartCtrl_io_read_queueWithOccupancy_io_pop_ready        ), //i
    .io_pop_payload     (uartCtrl_io_read_queueWithOccupancy_io_pop_payload[7:0] ), //o
    .io_flush           (1'b0                                                    ), //i
    .io_occupancy       (uartCtrl_io_read_queueWithOccupancy_io_occupancy[4:0]   ), //o
    .io_availability    (uartCtrl_io_read_queueWithOccupancy_io_availability[4:0]), //o
    .io_axiClk          (io_axiClk                                               ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset                                      )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(bridge_uartConfigReg_frame_stop)
      vexUartStopType_ONE : bridge_uartConfigReg_frame_stop_string = "ONE";
      vexUartStopType_TWO : bridge_uartConfigReg_frame_stop_string = "TWO";
      default : bridge_uartConfigReg_frame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(bridge_uartConfigReg_frame_parity)
      vexUartParityType_NONE : bridge_uartConfigReg_frame_parity_string = "NONE";
      vexUartParityType_EVEN : bridge_uartConfigReg_frame_parity_string = "EVEN";
      vexUartParityType_ODD : bridge_uartConfigReg_frame_parity_string = "ODD ";
      default : bridge_uartConfigReg_frame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_bridge_uartConfigReg_frame_parity)
      vexUartParityType_NONE : _zz_bridge_uartConfigReg_frame_parity_string = "NONE";
      vexUartParityType_EVEN : _zz_bridge_uartConfigReg_frame_parity_string = "EVEN";
      vexUartParityType_ODD : _zz_bridge_uartConfigReg_frame_parity_string = "ODD ";
      default : _zz_bridge_uartConfigReg_frame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_bridge_uartConfigReg_frame_stop)
      vexUartStopType_ONE : _zz_bridge_uartConfigReg_frame_stop_string = "ONE";
      vexUartStopType_TWO : _zz_bridge_uartConfigReg_frame_stop_string = "TWO";
      default : _zz_bridge_uartConfigReg_frame_stop_string = "???";
    endcase
  end
  `endif

  assign io_uart_txd = uartCtrl_io_uart_txd;
  assign busCtrl_readErrorFlag = 1'b0;
  assign busCtrl_writeErrorFlag = 1'b0;
  assign io_apb_PREADY = 1'b1;
  always @(*) begin
    io_apb_PRDATA = 32'h0;
    case(io_apb_PADDR)
      5'h0 : begin
        io_apb_PRDATA[16 : 16] = (bridge_read_streamBreaked_valid ^ 1'b0);
        io_apb_PRDATA[7 : 0] = bridge_read_streamBreaked_payload;
      end
      5'h04 : begin
        io_apb_PRDATA[20 : 16] = _zz_io_apb_PRDATA;
        io_apb_PRDATA[15 : 15] = bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid;
        io_apb_PRDATA[28 : 24] = uartCtrl_io_read_queueWithOccupancy_io_occupancy;
        io_apb_PRDATA[0 : 0] = bridge_interruptCtrl_writeIntEnable;
        io_apb_PRDATA[1 : 1] = bridge_interruptCtrl_readIntEnable;
        io_apb_PRDATA[8 : 8] = bridge_interruptCtrl_writeInt;
        io_apb_PRDATA[9 : 9] = bridge_interruptCtrl_readInt;
      end
      5'h10 : begin
        io_apb_PRDATA[0 : 0] = bridge_misc_readError;
        io_apb_PRDATA[1 : 1] = bridge_misc_readOverflowError;
        io_apb_PRDATA[8 : 8] = uartCtrl_io_readBreak;
        io_apb_PRDATA[9 : 9] = bridge_misc_breakDetected;
      end
      default : begin
      end
    endcase
  end

  assign busCtrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
  assign busCtrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (! io_apb_PWRITE));
  assign busCtrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
  assign busCtrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
  assign bridge_busCtrlWrapped_readErrorFlag = 1'b0;
  assign bridge_busCtrlWrapped_writeErrorFlag = 1'b0;
  always @(*) begin
    _zz_bridge_write_streamUnbuffered_valid = 1'b0;
    case(io_apb_PADDR)
      5'h0 : begin
        if(busCtrl_doWrite) begin
          _zz_bridge_write_streamUnbuffered_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign bridge_write_streamUnbuffered_valid = _zz_bridge_write_streamUnbuffered_valid;
  assign bridge_write_streamUnbuffered_payload = io_apb_PWDATA[7 : 0];
  assign bridge_write_streamUnbuffered_ready = bridge_write_streamUnbuffered_queueWithOccupancy_io_push_ready;
  always @(*) begin
    bridge_read_streamBreaked_valid = uartCtrl_io_read_queueWithOccupancy_io_pop_valid;
    if(uartCtrl_io_readBreak) begin
      bridge_read_streamBreaked_valid = 1'b0;
    end
  end

  always @(*) begin
    uartCtrl_io_read_queueWithOccupancy_io_pop_ready = bridge_read_streamBreaked_ready;
    if(uartCtrl_io_readBreak) begin
      uartCtrl_io_read_queueWithOccupancy_io_pop_ready = 1'b1;
    end
  end

  assign bridge_read_streamBreaked_payload = uartCtrl_io_read_queueWithOccupancy_io_pop_payload;
  always @(*) begin
    bridge_read_streamBreaked_ready = 1'b0;
    case(io_apb_PADDR)
      5'h0 : begin
        if(busCtrl_doRead) begin
          bridge_read_streamBreaked_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign bridge_interruptCtrl_readInt = (bridge_interruptCtrl_readIntEnable && bridge_read_streamBreaked_valid);
  assign bridge_interruptCtrl_writeInt = (bridge_interruptCtrl_writeIntEnable && (! bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid));
  assign bridge_interruptCtrl_interrupt = (bridge_interruptCtrl_readInt || bridge_interruptCtrl_writeInt);
  always @(*) begin
    when_BusSlaveFactory_l341 = 1'b0;
    case(io_apb_PADDR)
      5'h10 : begin
        if(busCtrl_doWrite) begin
          when_BusSlaveFactory_l341 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347 = io_apb_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l341_1 = 1'b0;
    case(io_apb_PADDR)
      5'h10 : begin
        if(busCtrl_doWrite) begin
          when_BusSlaveFactory_l341_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_1 = io_apb_PWDATA[1];
  assign uartCtrl_io_read_isStall = (uartCtrl_io_read_valid && (! uartCtrl_io_read_queueWithOccupancy_io_push_ready));
  assign when_UartCtrl_l155 = (uartCtrl_io_readBreak && (! uartCtrl_io_readBreak_regNext));
  always @(*) begin
    when_BusSlaveFactory_l341_2 = 1'b0;
    case(io_apb_PADDR)
      5'h10 : begin
        if(busCtrl_doWrite) begin
          when_BusSlaveFactory_l341_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_2 = io_apb_PWDATA[9];
  always @(*) begin
    when_BusSlaveFactory_l377 = 1'b0;
    case(io_apb_PADDR)
      5'h10 : begin
        if(busCtrl_doWrite) begin
          when_BusSlaveFactory_l377 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379 = io_apb_PWDATA[10];
  always @(*) begin
    when_BusSlaveFactory_l341_3 = 1'b0;
    case(io_apb_PADDR)
      5'h10 : begin
        if(busCtrl_doWrite) begin
          when_BusSlaveFactory_l341_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_3 = io_apb_PWDATA[11];
  assign io_interrupt = bridge_interruptCtrl_interrupt;
  assign _zz_bridge_uartConfigReg_frame_parity = io_apb_PWDATA[9 : 8];
  assign _zz_bridge_uartConfigReg_frame_stop = io_apb_PWDATA[16 : 16];
  assign when_Apb3SlaveFactory_l81 = ((io_apb_PADDR & (~ 5'h03)) == 5'h08);
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      bridge_uartConfigReg_clockDivider <= 20'h0;
      bridge_interruptCtrl_writeIntEnable <= 1'b0;
      bridge_interruptCtrl_readIntEnable <= 1'b0;
      bridge_misc_readError <= 1'b0;
      bridge_misc_readOverflowError <= 1'b0;
      bridge_misc_breakDetected <= 1'b0;
      bridge_misc_doBreak <= 1'b0;
    end else begin
      if(when_BusSlaveFactory_l341) begin
        if(when_BusSlaveFactory_l347) begin
          bridge_misc_readError <= _zz_bridge_misc_readError[0];
        end
      end
      if(uartCtrl_io_readError) begin
        bridge_misc_readError <= 1'b1;
      end
      if(when_BusSlaveFactory_l341_1) begin
        if(when_BusSlaveFactory_l347_1) begin
          bridge_misc_readOverflowError <= _zz_bridge_misc_readOverflowError[0];
        end
      end
      if(uartCtrl_io_read_isStall) begin
        bridge_misc_readOverflowError <= 1'b1;
      end
      if(when_UartCtrl_l155) begin
        bridge_misc_breakDetected <= 1'b1;
      end
      if(when_BusSlaveFactory_l341_2) begin
        if(when_BusSlaveFactory_l347_2) begin
          bridge_misc_breakDetected <= _zz_bridge_misc_breakDetected[0];
        end
      end
      if(when_BusSlaveFactory_l377) begin
        if(when_BusSlaveFactory_l379) begin
          bridge_misc_doBreak <= _zz_bridge_misc_doBreak[0];
        end
      end
      if(when_BusSlaveFactory_l341_3) begin
        if(when_BusSlaveFactory_l347_3) begin
          bridge_misc_doBreak <= _zz_bridge_misc_doBreak_1[0];
        end
      end
      case(io_apb_PADDR)
        5'h04 : begin
          if(busCtrl_doWrite) begin
            bridge_interruptCtrl_writeIntEnable <= io_apb_PWDATA[0];
            bridge_interruptCtrl_readIntEnable <= io_apb_PWDATA[1];
          end
        end
        default : begin
        end
      endcase
      if(when_Apb3SlaveFactory_l81) begin
        if(busCtrl_doWrite) begin
          bridge_uartConfigReg_clockDivider[19 : 0] <= io_apb_PWDATA[19 : 0];
        end
      end
    end
  end

  always @(posedge io_axiClk) begin
    uartCtrl_io_readBreak_regNext <= uartCtrl_io_readBreak;
    case(io_apb_PADDR)
      5'h0c : begin
        if(busCtrl_doWrite) begin
          bridge_uartConfigReg_frame_dataLength <= io_apb_PWDATA[2 : 0];
          bridge_uartConfigReg_frame_parity <= _zz_bridge_uartConfigReg_frame_parity;
          bridge_uartConfigReg_frame_stop <= _zz_bridge_uartConfigReg_frame_stop;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module vexAxi4SharedToApb3Bridge (
  input  wire          io_axi_arw_valid,
  output reg           io_axi_arw_ready,
  input  wire [19:0]   io_axi_arw_payload_addr,
  input  wire [3:0]    io_axi_arw_payload_id,
  input  wire [7:0]    io_axi_arw_payload_len,
  input  wire [2:0]    io_axi_arw_payload_size,
  input  wire [1:0]    io_axi_arw_payload_burst,
  input  wire          io_axi_arw_payload_write,
  input  wire          io_axi_w_valid,
  output reg           io_axi_w_ready,
  input  wire [31:0]   io_axi_w_payload_data,
  input  wire [3:0]    io_axi_w_payload_strb,
  input  wire          io_axi_w_payload_last,
  output reg           io_axi_b_valid,
  input  wire          io_axi_b_ready,
  output wire [3:0]    io_axi_b_payload_id,
  output wire [1:0]    io_axi_b_payload_resp,
  output reg           io_axi_r_valid,
  input  wire          io_axi_r_ready,
  output wire [31:0]   io_axi_r_payload_data,
  output wire [3:0]    io_axi_r_payload_id,
  output wire [1:0]    io_axi_r_payload_resp,
  output wire          io_axi_r_payload_last,
  output wire [19:0]   io_apb_PADDR,
  output reg  [0:0]    io_apb_PSEL,
  output reg           io_apb_PENABLE,
  input  wire          io_apb_PREADY,
  output wire          io_apb_PWRITE,
  output wire [31:0]   io_apb_PWDATA,
  input  wire [31:0]   io_apb_PRDATA,
  input  wire          io_apb_PSLVERROR,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);
  localparam vexAxi4ToApb3BridgePhase_SETUP = 2'd0;
  localparam vexAxi4ToApb3BridgePhase_ACCESS_1 = 2'd1;
  localparam vexAxi4ToApb3BridgePhase_RESPONSE = 2'd2;

  reg        [1:0]    phase;
  reg                 write;
  reg        [31:0]   readedData;
  reg        [3:0]    id;
  wire                when_Axi4SharedToApb3Bridge_l91;
  wire                when_Axi4SharedToApb3Bridge_l97;
  `ifndef SYNTHESIS
  reg [63:0] phase_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : phase_string = "SETUP   ";
      vexAxi4ToApb3BridgePhase_ACCESS_1 : phase_string = "ACCESS_1";
      vexAxi4ToApb3BridgePhase_RESPONSE : phase_string = "RESPONSE";
      default : phase_string = "????????";
    endcase
  end
  `endif

  always @(*) begin
    io_axi_arw_ready = 1'b0;
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
        if(when_Axi4SharedToApb3Bridge_l91) begin
          if(when_Axi4SharedToApb3Bridge_l97) begin
            io_axi_arw_ready = 1'b1;
          end
        end
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
        if(io_apb_PREADY) begin
          io_axi_arw_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_axi_w_ready = 1'b0;
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
        if(when_Axi4SharedToApb3Bridge_l91) begin
          if(when_Axi4SharedToApb3Bridge_l97) begin
            io_axi_w_ready = 1'b1;
          end
        end
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
        if(io_apb_PREADY) begin
          io_axi_w_ready = write;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_axi_b_valid = 1'b0;
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
      end
      default : begin
        if(write) begin
          io_axi_b_valid = 1'b1;
        end
      end
    endcase
  end

  always @(*) begin
    io_axi_r_valid = 1'b0;
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
      end
      default : begin
        if(!write) begin
          io_axi_r_valid = 1'b1;
        end
      end
    endcase
  end

  always @(*) begin
    io_apb_PSEL[0] = 1'b0;
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
        if(when_Axi4SharedToApb3Bridge_l91) begin
          io_apb_PSEL[0] = 1'b1;
          if(when_Axi4SharedToApb3Bridge_l97) begin
            io_apb_PSEL[0] = 1'b0;
          end
        end
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
        io_apb_PSEL[0] = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_apb_PENABLE = 1'b0;
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
        io_apb_PENABLE = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign when_Axi4SharedToApb3Bridge_l91 = (io_axi_arw_valid && ((! io_axi_arw_payload_write) || io_axi_w_valid));
  assign when_Axi4SharedToApb3Bridge_l97 = (io_axi_arw_payload_write && (io_axi_w_payload_strb == 4'b0000));
  assign io_apb_PADDR = io_axi_arw_payload_addr;
  assign io_apb_PWDATA = io_axi_w_payload_data;
  assign io_apb_PWRITE = io_axi_arw_payload_write;
  assign io_axi_r_payload_resp = {io_apb_PSLVERROR,1'b0};
  assign io_axi_b_payload_resp = {io_apb_PSLVERROR,1'b0};
  assign io_axi_r_payload_id = id;
  assign io_axi_b_payload_id = id;
  assign io_axi_r_payload_data = readedData;
  assign io_axi_r_payload_last = 1'b1;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      phase <= vexAxi4ToApb3BridgePhase_SETUP;
    end else begin
      case(phase)
        vexAxi4ToApb3BridgePhase_SETUP : begin
          if(when_Axi4SharedToApb3Bridge_l91) begin
            phase <= vexAxi4ToApb3BridgePhase_ACCESS_1;
            if(when_Axi4SharedToApb3Bridge_l97) begin
              phase <= vexAxi4ToApb3BridgePhase_RESPONSE;
            end
          end
        end
        vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
          if(io_apb_PREADY) begin
            phase <= vexAxi4ToApb3BridgePhase_RESPONSE;
          end
        end
        default : begin
          if(write) begin
            if(io_axi_b_ready) begin
              phase <= vexAxi4ToApb3BridgePhase_SETUP;
            end
          end else begin
            if(io_axi_r_ready) begin
              phase <= vexAxi4ToApb3BridgePhase_SETUP;
            end
          end
        end
      endcase
    end
  end

  always @(posedge io_axiClk) begin
    case(phase)
      vexAxi4ToApb3BridgePhase_SETUP : begin
        write <= io_axi_arw_payload_write;
        id <= io_axi_arw_payload_id;
      end
      vexAxi4ToApb3BridgePhase_ACCESS_1 : begin
        if(io_apb_PREADY) begin
          readedData <= io_apb_PRDATA;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module vexBufferCC_1 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          io_axiClk
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge io_axiClk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

//vexStreamFifoLowLatency_4 replaced by vexStreamFifoLowLatency_1

//vexStreamArbiter_3 replaced by vexStreamArbiter_2

//vexStreamFifoLowLatency_3 replaced by vexStreamFifoLowLatency_1

module vexStreamArbiter_2 (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire [31:0]   io_inputs_0_payload_addr,
  input  wire [3:0]    io_inputs_0_payload_id,
  input  wire [3:0]    io_inputs_0_payload_region,
  input  wire [7:0]    io_inputs_0_payload_len,
  input  wire [2:0]    io_inputs_0_payload_size,
  input  wire [1:0]    io_inputs_0_payload_burst,
  input  wire [0:0]    io_inputs_0_payload_lock,
  input  wire [3:0]    io_inputs_0_payload_cache,
  input  wire [3:0]    io_inputs_0_payload_qos,
  input  wire [2:0]    io_inputs_0_payload_prot,
  input  wire          io_inputs_0_payload_write,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [31:0]   io_output_payload_addr,
  output wire [3:0]    io_output_payload_id,
  output wire [3:0]    io_output_payload_region,
  output wire [7:0]    io_output_payload_len,
  output wire [2:0]    io_output_payload_size,
  output wire [1:0]    io_output_payload_burst,
  output wire [0:0]    io_output_payload_lock,
  output wire [3:0]    io_output_payload_cache,
  output wire [3:0]    io_output_payload_qos,
  output wire [2:0]    io_output_payload_prot,
  output wire          io_output_payload_write,
  output wire [0:0]    io_chosenOH,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire       [1:0]    _zz__zz_maskProposal_0_2;
  wire       [1:0]    _zz__zz_maskProposal_0_2_1;
  wire       [0:0]    _zz__zz_maskProposal_0_2_2;
  wire       [0:0]    _zz_maskProposal_0_3;
  reg                 locked;
  wire                maskProposal_0;
  reg                 maskLocked_0;
  wire                maskRouted_0;
  wire       [0:0]    _zz_maskProposal_0;
  wire       [1:0]    _zz_maskProposal_0_1;
  wire       [1:0]    _zz_maskProposal_0_2;
  wire                io_output_fire;

  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = maskLocked_0;
  assign _zz__zz_maskProposal_0_2_1 = {1'd0, _zz__zz_maskProposal_0_2_2};
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[1 : 1] | _zz_maskProposal_0_2[0 : 0]);
  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign _zz_maskProposal_0 = io_inputs_0_valid;
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_output_valid = (io_inputs_0_valid && maskRouted_0);
  assign io_output_payload_addr = io_inputs_0_payload_addr;
  assign io_output_payload_id = io_inputs_0_payload_id;
  assign io_output_payload_region = io_inputs_0_payload_region;
  assign io_output_payload_len = io_inputs_0_payload_len;
  assign io_output_payload_size = io_inputs_0_payload_size;
  assign io_output_payload_burst = io_inputs_0_payload_burst;
  assign io_output_payload_lock = io_inputs_0_payload_lock;
  assign io_output_payload_cache = io_inputs_0_payload_cache;
  assign io_output_payload_qos = io_inputs_0_payload_qos;
  assign io_output_payload_prot = io_inputs_0_payload_prot;
  assign io_output_payload_write = io_inputs_0_payload_write;
  assign io_inputs_0_ready = ((1'b0 || maskRouted_0) && io_output_ready);
  assign io_chosenOH = maskRouted_0;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(io_output_fire) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

//vexStreamFifoLowLatency_2 replaced by vexStreamFifoLowLatency_1

module vexStreamArbiter_1 (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire [31:0]   io_inputs_0_payload_addr,
  input  wire [2:0]    io_inputs_0_payload_id,
  input  wire [3:0]    io_inputs_0_payload_region,
  input  wire [7:0]    io_inputs_0_payload_len,
  input  wire [2:0]    io_inputs_0_payload_size,
  input  wire [1:0]    io_inputs_0_payload_burst,
  input  wire [0:0]    io_inputs_0_payload_lock,
  input  wire [3:0]    io_inputs_0_payload_cache,
  input  wire [3:0]    io_inputs_0_payload_qos,
  input  wire [2:0]    io_inputs_0_payload_prot,
  input  wire          io_inputs_0_payload_write,
  input  wire          io_inputs_1_valid,
  output wire          io_inputs_1_ready,
  input  wire [31:0]   io_inputs_1_payload_addr,
  input  wire [2:0]    io_inputs_1_payload_id,
  input  wire [3:0]    io_inputs_1_payload_region,
  input  wire [7:0]    io_inputs_1_payload_len,
  input  wire [2:0]    io_inputs_1_payload_size,
  input  wire [1:0]    io_inputs_1_payload_burst,
  input  wire [0:0]    io_inputs_1_payload_lock,
  input  wire [3:0]    io_inputs_1_payload_cache,
  input  wire [3:0]    io_inputs_1_payload_qos,
  input  wire [2:0]    io_inputs_1_payload_prot,
  input  wire          io_inputs_1_payload_write,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [31:0]   io_output_payload_addr,
  output wire [2:0]    io_output_payload_id,
  output wire [3:0]    io_output_payload_region,
  output wire [7:0]    io_output_payload_len,
  output wire [2:0]    io_output_payload_size,
  output wire [1:0]    io_output_payload_burst,
  output wire [0:0]    io_output_payload_lock,
  output wire [3:0]    io_output_payload_cache,
  output wire [3:0]    io_output_payload_qos,
  output wire [2:0]    io_output_payload_prot,
  output wire          io_output_payload_write,
  output wire [0:0]    io_chosen,
  output wire [1:0]    io_chosenOH,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire       [3:0]    _zz__zz_maskProposal_0_2;
  wire       [3:0]    _zz__zz_maskProposal_0_2_1;
  wire       [1:0]    _zz__zz_maskProposal_0_2_2;
  reg                 locked;
  wire                maskProposal_0;
  wire                maskProposal_1;
  reg                 maskLocked_0;
  reg                 maskLocked_1;
  wire                maskRouted_0;
  wire                maskRouted_1;
  wire       [1:0]    _zz_maskProposal_0;
  wire       [3:0]    _zz_maskProposal_0_1;
  wire       [3:0]    _zz_maskProposal_0_2;
  wire       [1:0]    _zz_maskProposal_0_3;
  wire                io_output_fire;
  wire                _zz_io_chosen;

  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = {maskLocked_0,maskLocked_1};
  assign _zz__zz_maskProposal_0_2_1 = {2'd0, _zz__zz_maskProposal_0_2_2};
  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_maskProposal_0 = {io_inputs_1_valid,io_inputs_0_valid};
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[3 : 2] | _zz_maskProposal_0_2[1 : 0]);
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign maskProposal_1 = _zz_maskProposal_0_3[1];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_output_valid = ((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1));
  assign io_output_payload_addr = (maskRouted_0 ? io_inputs_0_payload_addr : io_inputs_1_payload_addr);
  assign io_output_payload_id = (maskRouted_0 ? io_inputs_0_payload_id : io_inputs_1_payload_id);
  assign io_output_payload_region = (maskRouted_0 ? io_inputs_0_payload_region : io_inputs_1_payload_region);
  assign io_output_payload_len = (maskRouted_0 ? io_inputs_0_payload_len : io_inputs_1_payload_len);
  assign io_output_payload_size = (maskRouted_0 ? io_inputs_0_payload_size : io_inputs_1_payload_size);
  assign io_output_payload_burst = (maskRouted_0 ? io_inputs_0_payload_burst : io_inputs_1_payload_burst);
  assign io_output_payload_lock = (maskRouted_0 ? io_inputs_0_payload_lock : io_inputs_1_payload_lock);
  assign io_output_payload_cache = (maskRouted_0 ? io_inputs_0_payload_cache : io_inputs_1_payload_cache);
  assign io_output_payload_qos = (maskRouted_0 ? io_inputs_0_payload_qos : io_inputs_1_payload_qos);
  assign io_output_payload_prot = (maskRouted_0 ? io_inputs_0_payload_prot : io_inputs_1_payload_prot);
  assign io_output_payload_write = (maskRouted_0 ? io_inputs_0_payload_write : io_inputs_1_payload_write);
  assign io_inputs_0_ready = ((1'b0 || maskRouted_0) && io_output_ready);
  assign io_inputs_1_ready = ((1'b0 || maskRouted_1) && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_io_chosen = io_chosenOH[1];
  assign io_chosen = _zz_io_chosen;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b0;
      maskLocked_1 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
        maskLocked_1 <= maskRouted_1;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(io_output_fire) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module vexStreamFifoLowLatency_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  input  wire          io_flush,
  output wire [2:0]    io_occupancy,
  output wire [2:0]    io_availability,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire                fifo_io_push_ready;
  wire                fifo_io_pop_valid;
  wire       [2:0]    fifo_io_occupancy;
  wire       [2:0]    fifo_io_availability;

  vexStreamFifo_3 fifo (
    .io_push_valid      (io_push_valid            ), //i
    .io_push_ready      (fifo_io_push_ready       ), //o
    .io_pop_valid       (fifo_io_pop_valid        ), //o
    .io_pop_ready       (io_pop_ready             ), //i
    .io_flush           (io_flush                 ), //i
    .io_occupancy       (fifo_io_occupancy[2:0]   ), //o
    .io_availability    (fifo_io_availability[2:0]), //o
    .io_axiClk          (io_axiClk                ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset       )  //i
  );
  assign io_push_ready = fifo_io_push_ready;
  assign io_pop_valid = fifo_io_pop_valid;
  assign io_occupancy = fifo_io_occupancy;
  assign io_availability = fifo_io_availability;

endmodule

module vexStreamArbiter (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire [19:0]   io_inputs_0_payload_addr,
  input  wire [3:0]    io_inputs_0_payload_id,
  input  wire [7:0]    io_inputs_0_payload_len,
  input  wire [2:0]    io_inputs_0_payload_size,
  input  wire [1:0]    io_inputs_0_payload_burst,
  input  wire          io_inputs_0_payload_write,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [19:0]   io_output_payload_addr,
  output wire [3:0]    io_output_payload_id,
  output wire [7:0]    io_output_payload_len,
  output wire [2:0]    io_output_payload_size,
  output wire [1:0]    io_output_payload_burst,
  output wire          io_output_payload_write,
  output wire [0:0]    io_chosenOH,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire       [1:0]    _zz__zz_maskProposal_0_2;
  wire       [1:0]    _zz__zz_maskProposal_0_2_1;
  wire       [0:0]    _zz__zz_maskProposal_0_2_2;
  wire       [0:0]    _zz_maskProposal_0_3;
  reg                 locked;
  wire                maskProposal_0;
  reg                 maskLocked_0;
  wire                maskRouted_0;
  wire       [0:0]    _zz_maskProposal_0;
  wire       [1:0]    _zz_maskProposal_0_1;
  wire       [1:0]    _zz_maskProposal_0_2;
  wire                io_output_fire;

  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = maskLocked_0;
  assign _zz__zz_maskProposal_0_2_1 = {1'd0, _zz__zz_maskProposal_0_2_2};
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[1 : 1] | _zz_maskProposal_0_2[0 : 0]);
  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign _zz_maskProposal_0 = io_inputs_0_valid;
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_output_valid = (io_inputs_0_valid && maskRouted_0);
  assign io_output_payload_addr = io_inputs_0_payload_addr;
  assign io_output_payload_id = io_inputs_0_payload_id;
  assign io_output_payload_len = io_inputs_0_payload_len;
  assign io_output_payload_size = io_inputs_0_payload_size;
  assign io_output_payload_burst = io_inputs_0_payload_burst;
  assign io_output_payload_write = io_inputs_0_payload_write;
  assign io_inputs_0_ready = ((1'b0 || maskRouted_0) && io_output_ready);
  assign io_chosenOH = maskRouted_0;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(io_output_fire) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module vexAxi4SharedErrorSlave (
  input  wire          io_axi_arw_valid,
  output wire          io_axi_arw_ready,
  input  wire [31:0]   io_axi_arw_payload_addr,
  input  wire [2:0]    io_axi_arw_payload_size,
  input  wire [3:0]    io_axi_arw_payload_cache,
  input  wire [2:0]    io_axi_arw_payload_prot,
  input  wire          io_axi_arw_payload_write,
  input  wire          io_axi_w_valid,
  output wire          io_axi_w_ready,
  input  wire [31:0]   io_axi_w_payload_data,
  input  wire [3:0]    io_axi_w_payload_strb,
  input  wire          io_axi_w_payload_last,
  output wire          io_axi_b_valid,
  input  wire          io_axi_b_ready,
  output wire [1:0]    io_axi_b_payload_resp,
  output wire          io_axi_r_valid,
  input  wire          io_axi_r_ready,
  output wire [31:0]   io_axi_r_payload_data,
  output wire [1:0]    io_axi_r_payload_resp,
  output wire          io_axi_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 consumeData;
  reg                 sendReadRsp;
  reg                 sendWriteRsp;
  reg        [7:0]    remaining;
  wire                remainingZero;
  wire                io_axi_arw_fire;
  wire                io_axi_w_fire;
  wire                when_Axi4ErrorSlave_l92;
  wire                io_axi_b_fire;

  assign remainingZero = (remaining == 8'h0);
  assign io_axi_arw_ready = (! ((consumeData || sendWriteRsp) || sendReadRsp));
  assign io_axi_arw_fire = (io_axi_arw_valid && io_axi_arw_ready);
  assign io_axi_w_ready = consumeData;
  assign io_axi_w_fire = (io_axi_w_valid && io_axi_w_ready);
  assign when_Axi4ErrorSlave_l92 = (io_axi_w_fire && io_axi_w_payload_last);
  assign io_axi_b_valid = sendWriteRsp;
  assign io_axi_b_payload_resp = 2'b11;
  assign io_axi_b_fire = (io_axi_b_valid && io_axi_b_ready);
  assign io_axi_r_valid = sendReadRsp;
  assign io_axi_r_payload_resp = 2'b11;
  assign io_axi_r_payload_last = remainingZero;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      consumeData <= 1'b0;
      sendReadRsp <= 1'b0;
      sendWriteRsp <= 1'b0;
    end else begin
      if(io_axi_arw_fire) begin
        consumeData <= io_axi_arw_payload_write;
        sendReadRsp <= (! io_axi_arw_payload_write);
      end
      if(when_Axi4ErrorSlave_l92) begin
        consumeData <= 1'b0;
        sendWriteRsp <= 1'b1;
      end
      if(io_axi_b_fire) begin
        sendWriteRsp <= 1'b0;
      end
      if(sendReadRsp) begin
        if(io_axi_r_ready) begin
          if(remainingZero) begin
            sendReadRsp <= 1'b0;
          end
        end
      end
    end
  end

  always @(posedge io_axiClk) begin
    if(io_axi_arw_fire) begin
      remaining <= 8'h0;
    end
    if(sendReadRsp) begin
      if(io_axi_r_ready) begin
        remaining <= (remaining - 8'h01);
      end
    end
  end


endmodule

module vexAxi4ReadOnlyErrorSlave (
  input  wire          io_axi_ar_valid,
  output wire          io_axi_ar_ready,
  input  wire [31:0]   io_axi_ar_payload_addr,
  input  wire [3:0]    io_axi_ar_payload_cache,
  input  wire [2:0]    io_axi_ar_payload_prot,
  output wire          io_axi_r_valid,
  input  wire          io_axi_r_ready,
  output wire [31:0]   io_axi_r_payload_data,
  output wire [1:0]    io_axi_r_payload_resp,
  output wire          io_axi_r_payload_last,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 sendRsp;
  reg        [7:0]    remaining;
  wire                remainingZero;
  wire                io_axi_ar_fire;

  assign remainingZero = (remaining == 8'h0);
  assign io_axi_ar_ready = (! sendRsp);
  assign io_axi_ar_fire = (io_axi_ar_valid && io_axi_ar_ready);
  assign io_axi_r_valid = sendRsp;
  assign io_axi_r_payload_resp = 2'b11;
  assign io_axi_r_payload_last = remainingZero;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      sendRsp <= 1'b0;
    end else begin
      if(io_axi_ar_fire) begin
        sendRsp <= 1'b1;
      end
      if(sendRsp) begin
        if(io_axi_r_ready) begin
          if(remainingZero) begin
            sendRsp <= 1'b0;
          end
        end
      end
    end
  end

  always @(posedge io_axiClk) begin
    if(io_axi_ar_fire) begin
      remaining <= 8'h0;
    end
    if(sendRsp) begin
      if(io_axi_r_ready) begin
        remaining <= (remaining - 8'h01);
      end
    end
  end


endmodule

module vexStreamFifoLowLatency (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire          io_push_payload_error,
  input  wire [31:0]   io_push_payload_inst,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire          io_pop_payload_error,
  output wire [31:0]   io_pop_payload_inst,
  input  wire          io_flush,
  output wire [0:0]    io_occupancy,
  output wire [0:0]    io_availability,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  wire                fifo_io_push_ready;
  wire                fifo_io_pop_valid;
  wire                fifo_io_pop_payload_error;
  wire       [31:0]   fifo_io_pop_payload_inst;
  wire       [0:0]    fifo_io_occupancy;
  wire       [0:0]    fifo_io_availability;

  vexStreamFifo_2 fifo (
    .io_push_valid         (io_push_valid                 ), //i
    .io_push_ready         (fifo_io_push_ready            ), //o
    .io_push_payload_error (io_push_payload_error         ), //i
    .io_push_payload_inst  (io_push_payload_inst[31:0]    ), //i
    .io_pop_valid          (fifo_io_pop_valid             ), //o
    .io_pop_ready          (io_pop_ready                  ), //i
    .io_pop_payload_error  (fifo_io_pop_payload_error     ), //o
    .io_pop_payload_inst   (fifo_io_pop_payload_inst[31:0]), //o
    .io_flush              (io_flush                      ), //i
    .io_occupancy          (fifo_io_occupancy             ), //o
    .io_availability       (fifo_io_availability          ), //o
    .io_axiClk             (io_axiClk                     ), //i
    .resetCtrl_axiReset    (resetCtrl_axiReset            )  //i
  );
  assign io_push_ready = fifo_io_push_ready;
  assign io_pop_valid = fifo_io_pop_valid;
  assign io_pop_payload_error = fifo_io_pop_payload_error;
  assign io_pop_payload_inst = fifo_io_pop_payload_inst;
  assign io_occupancy = fifo_io_occupancy;
  assign io_availability = fifo_io_availability;

endmodule

//vexStreamFifo_1 replaced by vexStreamFifo

module vexStreamFifo (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [7:0]    io_push_payload,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [7:0]    io_pop_payload,
  input  wire          io_flush,
  output wire [4:0]    io_occupancy,
  output wire [4:0]    io_availability,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg        [7:0]    logic_ram_spinal_port1;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [4:0]    logic_ptr_push;
  reg        [4:0]    logic_ptr_pop;
  wire       [4:0]    logic_ptr_occupancy;
  wire       [4:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1455;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [3:0]    logic_push_onRam_write_payload_address;
  wire       [7:0]    logic_push_onRam_write_payload_data;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [3:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [3:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [3:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l477;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [3:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [7:0]    logic_pop_sync_readPort_rsp;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [3:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [7:0]    logic_pop_sync_readArbitation_translated_payload;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [4:0]    logic_pop_sync_popReg;
  reg [7:0] logic_ram [0:15];

  always @(posedge io_axiClk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data;
    end
  end

  always @(posedge io_axiClk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1455 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 5'h10) == 5'h0);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[3:0];
  assign logic_push_onRam_write_payload_data = io_push_payload;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[3:0];
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l477) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l477 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign logic_pop_sync_readPort_rsp = logic_ram_spinal_port1;
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload = logic_pop_sync_readPort_rsp;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload = logic_pop_sync_readArbitation_translated_payload;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (5'h10 - logic_ptr_occupancy);
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      logic_ptr_push <= 5'h0;
      logic_ptr_pop <= 5'h0;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 5'h0;
    end else begin
      if(when_Stream_l1455) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 5'h01);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 5'h01);
      end
      if(io_flush) begin
        logic_ptr_push <= 5'h0;
        logic_ptr_pop <= 5'h0;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 5'h0;
      end
    end
  end

  always @(posedge io_axiClk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

module vexUartCtrl (
  input  wire [2:0]    io_config_frame_dataLength,
  input  wire [0:0]    io_config_frame_stop,
  input  wire [1:0]    io_config_frame_parity,
  input  wire [19:0]   io_config_clockDivider,
  input  wire          io_write_valid,
  output reg           io_write_ready,
  input  wire [7:0]    io_write_payload,
  output wire          io_read_valid,
  input  wire          io_read_ready,
  output wire [7:0]    io_read_payload,
  output wire          io_uart_txd,
  input  wire          io_uart_rxd,
  output wire          io_readError,
  input  wire          io_writeBreak,
  output wire          io_readBreak,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);
  localparam vexUartStopType_ONE = 1'd0;
  localparam vexUartStopType_TWO = 1'd1;
  localparam vexUartParityType_NONE = 2'd0;
  localparam vexUartParityType_EVEN = 2'd1;
  localparam vexUartParityType_ODD = 2'd2;

  wire                tx_io_write_ready;
  wire                tx_io_txd;
  wire                rx_io_read_valid;
  wire       [7:0]    rx_io_read_payload;
  wire                rx_io_rts;
  wire                rx_io_error;
  wire                rx_io_break;
  reg        [19:0]   clockDivider_counter;
  wire                clockDivider_tick;
  reg                 clockDivider_tickReg;
  reg                 io_write_throwWhen_valid;
  wire                io_write_throwWhen_ready;
  wire       [7:0]    io_write_throwWhen_payload;
  `ifndef SYNTHESIS
  reg [23:0] io_config_frame_stop_string;
  reg [31:0] io_config_frame_parity_string;
  `endif


  vexUartCtrlTx tx (
    .io_configFrame_dataLength (io_config_frame_dataLength[2:0]), //i
    .io_configFrame_stop       (io_config_frame_stop           ), //i
    .io_configFrame_parity     (io_config_frame_parity[1:0]    ), //i
    .io_samplingTick           (clockDivider_tickReg           ), //i
    .io_write_valid            (io_write_throwWhen_valid       ), //i
    .io_write_ready            (tx_io_write_ready              ), //o
    .io_write_payload          (io_write_throwWhen_payload[7:0]), //i
    .io_cts                    (1'b0                           ), //i
    .io_txd                    (tx_io_txd                      ), //o
    .io_break                  (io_writeBreak                  ), //i
    .io_axiClk                 (io_axiClk                      ), //i
    .resetCtrl_axiReset        (resetCtrl_axiReset             )  //i
  );
  vexUartCtrlRx rx (
    .io_configFrame_dataLength (io_config_frame_dataLength[2:0]), //i
    .io_configFrame_stop       (io_config_frame_stop           ), //i
    .io_configFrame_parity     (io_config_frame_parity[1:0]    ), //i
    .io_samplingTick           (clockDivider_tickReg           ), //i
    .io_read_valid             (rx_io_read_valid               ), //o
    .io_read_ready             (io_read_ready                  ), //i
    .io_read_payload           (rx_io_read_payload[7:0]        ), //o
    .io_rxd                    (io_uart_rxd                    ), //i
    .io_rts                    (rx_io_rts                      ), //o
    .io_error                  (rx_io_error                    ), //o
    .io_break                  (rx_io_break                    ), //o
    .io_axiClk                 (io_axiClk                      ), //i
    .resetCtrl_axiReset        (resetCtrl_axiReset             )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_config_frame_stop)
      vexUartStopType_ONE : io_config_frame_stop_string = "ONE";
      vexUartStopType_TWO : io_config_frame_stop_string = "TWO";
      default : io_config_frame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_config_frame_parity)
      vexUartParityType_NONE : io_config_frame_parity_string = "NONE";
      vexUartParityType_EVEN : io_config_frame_parity_string = "EVEN";
      vexUartParityType_ODD : io_config_frame_parity_string = "ODD ";
      default : io_config_frame_parity_string = "????";
    endcase
  end
  `endif

  assign clockDivider_tick = (clockDivider_counter == 20'h0);
  always @(*) begin
    io_write_throwWhen_valid = io_write_valid;
    if(rx_io_break) begin
      io_write_throwWhen_valid = 1'b0;
    end
  end

  always @(*) begin
    io_write_ready = io_write_throwWhen_ready;
    if(rx_io_break) begin
      io_write_ready = 1'b1;
    end
  end

  assign io_write_throwWhen_payload = io_write_payload;
  assign io_write_throwWhen_ready = tx_io_write_ready;
  assign io_read_valid = rx_io_read_valid;
  assign io_read_payload = rx_io_read_payload;
  assign io_uart_txd = tx_io_txd;
  assign io_readError = rx_io_error;
  assign io_readBreak = rx_io_break;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      clockDivider_counter <= 20'h0;
      clockDivider_tickReg <= 1'b0;
    end else begin
      clockDivider_tickReg <= clockDivider_tick;
      clockDivider_counter <= (clockDivider_counter - 20'h00001);
      if(clockDivider_tick) begin
        clockDivider_counter <= io_config_clockDivider;
      end
    end
  end


endmodule

//vexStreamFifo_6 replaced by vexStreamFifo_3

//vexStreamFifo_5 replaced by vexStreamFifo_3

//vexStreamFifo_4 replaced by vexStreamFifo_3

module vexStreamFifo_3 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  output reg           io_pop_valid,
  input  wire          io_pop_ready,
  input  wire          io_flush,
  output wire [2:0]    io_occupancy,
  output wire [2:0]    io_availability,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [2:0]    logic_ptr_push;
  reg        [2:0]    logic_ptr_pop;
  wire       [2:0]    logic_ptr_occupancy;
  wire       [2:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1455;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [1:0]    logic_push_onRam_write_payload_address;
  wire                logic_pop_addressGen_valid;
  wire                logic_pop_addressGen_ready;
  wire       [1:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_addressGen_translated_valid;
  wire                logic_pop_addressGen_translated_ready;

  assign when_Stream_l1455 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 3'b100) == 3'b000);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  always @(*) begin
    logic_ptr_doPush = io_push_fire;
    if(logic_ptr_empty) begin
      if(io_pop_ready) begin
        logic_ptr_doPush = 1'b0;
      end
    end
  end

  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[1:0];
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[1:0];
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_translated_valid = logic_pop_addressGen_valid;
  assign logic_pop_addressGen_ready = logic_pop_addressGen_translated_ready;
  always @(*) begin
    io_pop_valid = logic_pop_addressGen_translated_valid;
    if(logic_ptr_empty) begin
      io_pop_valid = io_push_valid;
    end
  end

  assign logic_pop_addressGen_translated_ready = io_pop_ready;
  assign logic_ptr_popOnIo = logic_ptr_pop;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (3'b100 - logic_ptr_occupancy);
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      logic_ptr_push <= 3'b000;
      logic_ptr_pop <= 3'b000;
      logic_ptr_wentUp <= 1'b0;
    end else begin
      if(when_Stream_l1455) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 3'b001);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 3'b001);
      end
      if(io_flush) begin
        logic_ptr_push <= 3'b000;
        logic_ptr_pop <= 3'b000;
      end
    end
  end


endmodule

module vexStreamFifo_2 (
  input  wire          io_push_valid,
  output reg           io_push_ready,
  input  wire          io_push_payload_error,
  input  wire [31:0]   io_push_payload_inst,
  output reg           io_pop_valid,
  input  wire          io_pop_ready,
  output reg           io_pop_payload_error,
  output reg  [31:0]   io_pop_payload_inst,
  input  wire          io_flush,
  output wire [0:0]    io_occupancy,
  output wire [0:0]    io_availability,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  reg                 oneStage_doFlush;
  wire                oneStage_buffer_valid;
  wire                oneStage_buffer_ready;
  wire                oneStage_buffer_payload_error;
  wire       [31:0]   oneStage_buffer_payload_inst;
  reg                 io_push_rValid;
  reg                 io_push_rData_error;
  reg        [31:0]   io_push_rData_inst;
  wire                when_Stream_l477;
  wire                when_Stream_l1432;

  always @(*) begin
    oneStage_doFlush = io_flush;
    if(when_Stream_l1432) begin
      if(io_pop_ready) begin
        oneStage_doFlush = 1'b1;
      end
    end
  end

  always @(*) begin
    io_push_ready = oneStage_buffer_ready;
    if(when_Stream_l477) begin
      io_push_ready = 1'b1;
    end
  end

  assign when_Stream_l477 = (! oneStage_buffer_valid);
  assign oneStage_buffer_valid = io_push_rValid;
  assign oneStage_buffer_payload_error = io_push_rData_error;
  assign oneStage_buffer_payload_inst = io_push_rData_inst;
  always @(*) begin
    io_pop_valid = oneStage_buffer_valid;
    if(when_Stream_l1432) begin
      io_pop_valid = io_push_valid;
    end
  end

  assign oneStage_buffer_ready = io_pop_ready;
  always @(*) begin
    io_pop_payload_error = oneStage_buffer_payload_error;
    if(when_Stream_l1432) begin
      io_pop_payload_error = io_push_payload_error;
    end
  end

  always @(*) begin
    io_pop_payload_inst = oneStage_buffer_payload_inst;
    if(when_Stream_l1432) begin
      io_pop_payload_inst = io_push_payload_inst;
    end
  end

  assign io_occupancy = oneStage_buffer_valid;
  assign io_availability = (! oneStage_buffer_valid);
  assign when_Stream_l1432 = (! oneStage_buffer_valid);
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      io_push_rValid <= 1'b0;
    end else begin
      if(io_push_ready) begin
        io_push_rValid <= io_push_valid;
      end
      if(oneStage_doFlush) begin
        io_push_rValid <= 1'b0;
      end
    end
  end

  always @(posedge io_axiClk) begin
    if(io_push_ready) begin
      io_push_rData_error <= io_push_payload_error;
      io_push_rData_inst <= io_push_payload_inst;
    end
  end


endmodule

module vexUartCtrlRx (
  input  wire [2:0]    io_configFrame_dataLength,
  input  wire [0:0]    io_configFrame_stop,
  input  wire [1:0]    io_configFrame_parity,
  input  wire          io_samplingTick,
  output wire          io_read_valid,
  input  wire          io_read_ready,
  output wire [7:0]    io_read_payload,
  input  wire          io_rxd,
  output wire          io_rts,
  output reg           io_error,
  output wire          io_break,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);
  localparam vexUartStopType_ONE = 1'd0;
  localparam vexUartStopType_TWO = 1'd1;
  localparam vexUartParityType_NONE = 2'd0;
  localparam vexUartParityType_EVEN = 2'd1;
  localparam vexUartParityType_ODD = 2'd2;
  localparam vexUartCtrlRxState_IDLE = 3'd0;
  localparam vexUartCtrlRxState_START = 3'd1;
  localparam vexUartCtrlRxState_DATA = 3'd2;
  localparam vexUartCtrlRxState_PARITY = 3'd3;
  localparam vexUartCtrlRxState_STOP = 3'd4;

  wire                io_rxd_buffercc_io_dataOut;
  wire                _zz_sampler_value;
  wire                _zz_sampler_value_1;
  wire                _zz_sampler_value_2;
  wire                _zz_sampler_value_3;
  wire                _zz_sampler_value_4;
  wire                _zz_sampler_value_5;
  wire                _zz_sampler_value_6;
  wire       [2:0]    _zz_when_UartCtrlRx_l139;
  wire       [0:0]    _zz_when_UartCtrlRx_l139_1;
  reg                 _zz_io_rts;
  wire                sampler_synchroniser;
  wire                sampler_samples_0;
  reg                 sampler_samples_1;
  reg                 sampler_samples_2;
  reg                 sampler_samples_3;
  reg                 sampler_samples_4;
  reg                 sampler_value;
  reg                 sampler_tick;
  reg        [2:0]    bitTimer_counter;
  reg                 bitTimer_tick;
  wire                when_UartCtrlRx_l43;
  reg        [2:0]    bitCounter_value;
  reg        [6:0]    break_counter;
  wire                break_valid;
  wire                when_UartCtrlRx_l69;
  reg        [2:0]    stateMachine_state;
  reg                 stateMachine_parity;
  reg        [7:0]    stateMachine_shifter;
  reg                 stateMachine_validReg;
  wire                when_UartCtrlRx_l93;
  wire                when_UartCtrlRx_l103;
  wire                when_UartCtrlRx_l111;
  wire                when_UartCtrlRx_l113;
  wire                when_UartCtrlRx_l125;
  wire                when_UartCtrlRx_l136;
  wire                when_UartCtrlRx_l139;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  `endif


  assign _zz_when_UartCtrlRx_l139_1 = ((io_configFrame_stop == vexUartStopType_ONE) ? 1'b0 : 1'b1);
  assign _zz_when_UartCtrlRx_l139 = {2'd0, _zz_when_UartCtrlRx_l139_1};
  assign _zz_sampler_value = ((((1'b0 || ((_zz_sampler_value_1 && sampler_samples_1) && sampler_samples_2)) || (((_zz_sampler_value_2 && sampler_samples_0) && sampler_samples_1) && sampler_samples_3)) || (((1'b1 && sampler_samples_0) && sampler_samples_2) && sampler_samples_3)) || (((1'b1 && sampler_samples_1) && sampler_samples_2) && sampler_samples_3));
  assign _zz_sampler_value_3 = (((1'b1 && sampler_samples_0) && sampler_samples_1) && sampler_samples_4);
  assign _zz_sampler_value_4 = ((1'b1 && sampler_samples_0) && sampler_samples_2);
  assign _zz_sampler_value_5 = (1'b1 && sampler_samples_1);
  assign _zz_sampler_value_6 = 1'b1;
  assign _zz_sampler_value_1 = (1'b1 && sampler_samples_0);
  assign _zz_sampler_value_2 = 1'b1;
  (* keep_hierarchy = "TRUE" *) vexBufferCC io_rxd_buffercc (
    .io_dataIn          (io_rxd                    ), //i
    .io_dataOut         (io_rxd_buffercc_io_dataOut), //o
    .io_axiClk          (io_axiClk                 ), //i
    .resetCtrl_axiReset (resetCtrl_axiReset        )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      vexUartStopType_ONE : io_configFrame_stop_string = "ONE";
      vexUartStopType_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      vexUartParityType_NONE : io_configFrame_parity_string = "NONE";
      vexUartParityType_EVEN : io_configFrame_parity_string = "EVEN";
      vexUartParityType_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      vexUartCtrlRxState_IDLE : stateMachine_state_string = "IDLE  ";
      vexUartCtrlRxState_START : stateMachine_state_string = "START ";
      vexUartCtrlRxState_DATA : stateMachine_state_string = "DATA  ";
      vexUartCtrlRxState_PARITY : stateMachine_state_string = "PARITY";
      vexUartCtrlRxState_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    io_error = 1'b0;
    case(stateMachine_state)
      vexUartCtrlRxState_IDLE : begin
      end
      vexUartCtrlRxState_START : begin
      end
      vexUartCtrlRxState_DATA : begin
      end
      vexUartCtrlRxState_PARITY : begin
        if(bitTimer_tick) begin
          if(!when_UartCtrlRx_l125) begin
            io_error = 1'b1;
          end
        end
      end
      default : begin
        if(bitTimer_tick) begin
          if(when_UartCtrlRx_l136) begin
            io_error = 1'b1;
          end
        end
      end
    endcase
  end

  assign io_rts = _zz_io_rts;
  assign sampler_synchroniser = io_rxd_buffercc_io_dataOut;
  assign sampler_samples_0 = sampler_synchroniser;
  always @(*) begin
    bitTimer_tick = 1'b0;
    if(sampler_tick) begin
      if(when_UartCtrlRx_l43) begin
        bitTimer_tick = 1'b1;
      end
    end
  end

  assign when_UartCtrlRx_l43 = (bitTimer_counter == 3'b000);
  assign break_valid = (break_counter == 7'h68);
  assign when_UartCtrlRx_l69 = (io_samplingTick && (! break_valid));
  assign io_break = break_valid;
  assign io_read_valid = stateMachine_validReg;
  assign when_UartCtrlRx_l93 = ((sampler_tick && (! sampler_value)) && (! break_valid));
  assign when_UartCtrlRx_l103 = (sampler_value == 1'b1);
  assign when_UartCtrlRx_l111 = (bitCounter_value == io_configFrame_dataLength);
  assign when_UartCtrlRx_l113 = (io_configFrame_parity == vexUartParityType_NONE);
  assign when_UartCtrlRx_l125 = (stateMachine_parity == sampler_value);
  assign when_UartCtrlRx_l136 = (! sampler_value);
  assign when_UartCtrlRx_l139 = (bitCounter_value == _zz_when_UartCtrlRx_l139);
  assign io_read_payload = stateMachine_shifter;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      _zz_io_rts <= 1'b0;
      sampler_samples_1 <= 1'b1;
      sampler_samples_2 <= 1'b1;
      sampler_samples_3 <= 1'b1;
      sampler_samples_4 <= 1'b1;
      sampler_value <= 1'b1;
      sampler_tick <= 1'b0;
      break_counter <= 7'h0;
      stateMachine_state <= vexUartCtrlRxState_IDLE;
      stateMachine_validReg <= 1'b0;
    end else begin
      _zz_io_rts <= (! io_read_ready);
      if(io_samplingTick) begin
        sampler_samples_1 <= sampler_samples_0;
      end
      if(io_samplingTick) begin
        sampler_samples_2 <= sampler_samples_1;
      end
      if(io_samplingTick) begin
        sampler_samples_3 <= sampler_samples_2;
      end
      if(io_samplingTick) begin
        sampler_samples_4 <= sampler_samples_3;
      end
      sampler_value <= ((((((_zz_sampler_value || _zz_sampler_value_3) || (_zz_sampler_value_4 && sampler_samples_4)) || ((_zz_sampler_value_5 && sampler_samples_2) && sampler_samples_4)) || (((_zz_sampler_value_6 && sampler_samples_0) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_1) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_2) && sampler_samples_3) && sampler_samples_4));
      sampler_tick <= io_samplingTick;
      if(sampler_value) begin
        break_counter <= 7'h0;
      end else begin
        if(when_UartCtrlRx_l69) begin
          break_counter <= (break_counter + 7'h01);
        end
      end
      stateMachine_validReg <= 1'b0;
      case(stateMachine_state)
        vexUartCtrlRxState_IDLE : begin
          if(when_UartCtrlRx_l93) begin
            stateMachine_state <= vexUartCtrlRxState_START;
          end
        end
        vexUartCtrlRxState_START : begin
          if(bitTimer_tick) begin
            stateMachine_state <= vexUartCtrlRxState_DATA;
            if(when_UartCtrlRx_l103) begin
              stateMachine_state <= vexUartCtrlRxState_IDLE;
            end
          end
        end
        vexUartCtrlRxState_DATA : begin
          if(bitTimer_tick) begin
            if(when_UartCtrlRx_l111) begin
              if(when_UartCtrlRx_l113) begin
                stateMachine_state <= vexUartCtrlRxState_STOP;
                stateMachine_validReg <= 1'b1;
              end else begin
                stateMachine_state <= vexUartCtrlRxState_PARITY;
              end
            end
          end
        end
        vexUartCtrlRxState_PARITY : begin
          if(bitTimer_tick) begin
            if(when_UartCtrlRx_l125) begin
              stateMachine_state <= vexUartCtrlRxState_STOP;
              stateMachine_validReg <= 1'b1;
            end else begin
              stateMachine_state <= vexUartCtrlRxState_IDLE;
            end
          end
        end
        default : begin
          if(bitTimer_tick) begin
            if(when_UartCtrlRx_l136) begin
              stateMachine_state <= vexUartCtrlRxState_IDLE;
            end else begin
              if(when_UartCtrlRx_l139) begin
                stateMachine_state <= vexUartCtrlRxState_IDLE;
              end
            end
          end
        end
      endcase
    end
  end

  always @(posedge io_axiClk) begin
    if(sampler_tick) begin
      bitTimer_counter <= (bitTimer_counter - 3'b001);
    end
    if(bitTimer_tick) begin
      bitCounter_value <= (bitCounter_value + 3'b001);
    end
    if(bitTimer_tick) begin
      stateMachine_parity <= (stateMachine_parity ^ sampler_value);
    end
    case(stateMachine_state)
      vexUartCtrlRxState_IDLE : begin
        if(when_UartCtrlRx_l93) begin
          bitTimer_counter <= 3'b010;
        end
      end
      vexUartCtrlRxState_START : begin
        if(bitTimer_tick) begin
          bitCounter_value <= 3'b000;
          stateMachine_parity <= (io_configFrame_parity == vexUartParityType_ODD);
        end
      end
      vexUartCtrlRxState_DATA : begin
        if(bitTimer_tick) begin
          stateMachine_shifter[bitCounter_value] <= sampler_value;
          if(when_UartCtrlRx_l111) begin
            bitCounter_value <= 3'b000;
          end
        end
      end
      vexUartCtrlRxState_PARITY : begin
        if(bitTimer_tick) begin
          bitCounter_value <= 3'b000;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module vexUartCtrlTx (
  input  wire [2:0]    io_configFrame_dataLength,
  input  wire [0:0]    io_configFrame_stop,
  input  wire [1:0]    io_configFrame_parity,
  input  wire          io_samplingTick,
  input  wire          io_write_valid,
  output reg           io_write_ready,
  input  wire [7:0]    io_write_payload,
  input  wire          io_cts,
  output wire          io_txd,
  input  wire          io_break,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);
  localparam vexUartStopType_ONE = 1'd0;
  localparam vexUartStopType_TWO = 1'd1;
  localparam vexUartParityType_NONE = 2'd0;
  localparam vexUartParityType_EVEN = 2'd1;
  localparam vexUartParityType_ODD = 2'd2;
  localparam vexUartCtrlTxState_IDLE = 3'd0;
  localparam vexUartCtrlTxState_START = 3'd1;
  localparam vexUartCtrlTxState_DATA = 3'd2;
  localparam vexUartCtrlTxState_PARITY = 3'd3;
  localparam vexUartCtrlTxState_STOP = 3'd4;

  wire       [2:0]    _zz_clockDivider_counter_valueNext;
  wire       [0:0]    _zz_clockDivider_counter_valueNext_1;
  wire       [2:0]    _zz_when_UartCtrlTx_l93;
  wire       [0:0]    _zz_when_UartCtrlTx_l93_1;
  reg                 clockDivider_counter_willIncrement;
  wire                clockDivider_counter_willClear;
  reg        [2:0]    clockDivider_counter_valueNext;
  reg        [2:0]    clockDivider_counter_value;
  wire                clockDivider_counter_willOverflowIfInc;
  wire                clockDivider_counter_willOverflow;
  reg        [2:0]    tickCounter_value;
  reg        [2:0]    stateMachine_state;
  reg                 stateMachine_parity;
  reg                 stateMachine_txd;
  wire                when_UartCtrlTx_l58;
  wire                when_UartCtrlTx_l73;
  wire                when_UartCtrlTx_l76;
  wire                when_UartCtrlTx_l93;
  wire       [2:0]    _zz_stateMachine_state;
  reg                 _zz_io_txd;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  reg [47:0] _zz_stateMachine_state_string;
  `endif


  assign _zz_clockDivider_counter_valueNext_1 = clockDivider_counter_willIncrement;
  assign _zz_clockDivider_counter_valueNext = {2'd0, _zz_clockDivider_counter_valueNext_1};
  assign _zz_when_UartCtrlTx_l93_1 = ((io_configFrame_stop == vexUartStopType_ONE) ? 1'b0 : 1'b1);
  assign _zz_when_UartCtrlTx_l93 = {2'd0, _zz_when_UartCtrlTx_l93_1};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      vexUartStopType_ONE : io_configFrame_stop_string = "ONE";
      vexUartStopType_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      vexUartParityType_NONE : io_configFrame_parity_string = "NONE";
      vexUartParityType_EVEN : io_configFrame_parity_string = "EVEN";
      vexUartParityType_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      vexUartCtrlTxState_IDLE : stateMachine_state_string = "IDLE  ";
      vexUartCtrlTxState_START : stateMachine_state_string = "START ";
      vexUartCtrlTxState_DATA : stateMachine_state_string = "DATA  ";
      vexUartCtrlTxState_PARITY : stateMachine_state_string = "PARITY";
      vexUartCtrlTxState_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_stateMachine_state)
      vexUartCtrlTxState_IDLE : _zz_stateMachine_state_string = "IDLE  ";
      vexUartCtrlTxState_START : _zz_stateMachine_state_string = "START ";
      vexUartCtrlTxState_DATA : _zz_stateMachine_state_string = "DATA  ";
      vexUartCtrlTxState_PARITY : _zz_stateMachine_state_string = "PARITY";
      vexUartCtrlTxState_STOP : _zz_stateMachine_state_string = "STOP  ";
      default : _zz_stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    clockDivider_counter_willIncrement = 1'b0;
    if(io_samplingTick) begin
      clockDivider_counter_willIncrement = 1'b1;
    end
  end

  assign clockDivider_counter_willClear = 1'b0;
  assign clockDivider_counter_willOverflowIfInc = (clockDivider_counter_value == 3'b111);
  assign clockDivider_counter_willOverflow = (clockDivider_counter_willOverflowIfInc && clockDivider_counter_willIncrement);
  always @(*) begin
    clockDivider_counter_valueNext = (clockDivider_counter_value + _zz_clockDivider_counter_valueNext);
    if(clockDivider_counter_willClear) begin
      clockDivider_counter_valueNext = 3'b000;
    end
  end

  always @(*) begin
    stateMachine_txd = 1'b1;
    case(stateMachine_state)
      vexUartCtrlTxState_IDLE : begin
      end
      vexUartCtrlTxState_START : begin
        stateMachine_txd = 1'b0;
      end
      vexUartCtrlTxState_DATA : begin
        stateMachine_txd = io_write_payload[tickCounter_value];
      end
      vexUartCtrlTxState_PARITY : begin
        stateMachine_txd = stateMachine_parity;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_write_ready = io_break;
    case(stateMachine_state)
      vexUartCtrlTxState_IDLE : begin
      end
      vexUartCtrlTxState_START : begin
      end
      vexUartCtrlTxState_DATA : begin
        if(clockDivider_counter_willOverflow) begin
          if(when_UartCtrlTx_l73) begin
            io_write_ready = 1'b1;
          end
        end
      end
      vexUartCtrlTxState_PARITY : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UartCtrlTx_l58 = ((io_write_valid && (! io_cts)) && clockDivider_counter_willOverflow);
  assign when_UartCtrlTx_l73 = (tickCounter_value == io_configFrame_dataLength);
  assign when_UartCtrlTx_l76 = (io_configFrame_parity == vexUartParityType_NONE);
  assign when_UartCtrlTx_l93 = (tickCounter_value == _zz_when_UartCtrlTx_l93);
  assign _zz_stateMachine_state = (io_write_valid ? vexUartCtrlTxState_START : vexUartCtrlTxState_IDLE);
  assign io_txd = _zz_io_txd;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      clockDivider_counter_value <= 3'b000;
      stateMachine_state <= vexUartCtrlTxState_IDLE;
      _zz_io_txd <= 1'b1;
    end else begin
      clockDivider_counter_value <= clockDivider_counter_valueNext;
      case(stateMachine_state)
        vexUartCtrlTxState_IDLE : begin
          if(when_UartCtrlTx_l58) begin
            stateMachine_state <= vexUartCtrlTxState_START;
          end
        end
        vexUartCtrlTxState_START : begin
          if(clockDivider_counter_willOverflow) begin
            stateMachine_state <= vexUartCtrlTxState_DATA;
          end
        end
        vexUartCtrlTxState_DATA : begin
          if(clockDivider_counter_willOverflow) begin
            if(when_UartCtrlTx_l73) begin
              if(when_UartCtrlTx_l76) begin
                stateMachine_state <= vexUartCtrlTxState_STOP;
              end else begin
                stateMachine_state <= vexUartCtrlTxState_PARITY;
              end
            end
          end
        end
        vexUartCtrlTxState_PARITY : begin
          if(clockDivider_counter_willOverflow) begin
            stateMachine_state <= vexUartCtrlTxState_STOP;
          end
        end
        default : begin
          if(clockDivider_counter_willOverflow) begin
            if(when_UartCtrlTx_l93) begin
              stateMachine_state <= _zz_stateMachine_state;
            end
          end
        end
      endcase
      _zz_io_txd <= (stateMachine_txd && (! io_break));
    end
  end

  always @(posedge io_axiClk) begin
    if(clockDivider_counter_willOverflow) begin
      tickCounter_value <= (tickCounter_value + 3'b001);
    end
    if(clockDivider_counter_willOverflow) begin
      stateMachine_parity <= (stateMachine_parity ^ stateMachine_txd);
    end
    case(stateMachine_state)
      vexUartCtrlTxState_IDLE : begin
      end
      vexUartCtrlTxState_START : begin
        if(clockDivider_counter_willOverflow) begin
          stateMachine_parity <= (io_configFrame_parity == vexUartParityType_ODD);
          tickCounter_value <= 3'b000;
        end
      end
      vexUartCtrlTxState_DATA : begin
        if(clockDivider_counter_willOverflow) begin
          if(when_UartCtrlTx_l73) begin
            tickCounter_value <= 3'b000;
          end
        end
      end
      vexUartCtrlTxState_PARITY : begin
        if(clockDivider_counter_willOverflow) begin
          tickCounter_value <= 3'b000;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module vexBufferCC (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          io_axiClk,
  input  wire          resetCtrl_axiReset
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge io_axiClk) begin
    if(resetCtrl_axiReset) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule
