// Generator : SpinalHDL v1.12.0    git head : 1aa7d7b5732f11cca2dd83bacc2a4cb92ca8e5c9
// Component : AxilRegister
// Git hash  : eec80fc7678d97d0494bd39004b6242be7d38ba5

`timescale 1ns/1ps
`include "top_tiny_npu.vh"
module axil_register (
//  input  wire          s_axil_aw_valid,
//  output wire          s_axil_aw_ready,
//  input  wire [31:0]   s_axil_aw_payload_addr,
//   input  wire [2:0]    s_axil_aw_payload_prot,
//  input  wire          s_axil_w_valid,
//  output wire          s_axil_w_ready,
//  input  wire [31:0]   s_axil_w_payload_data,
//  input  wire [7:0]    s_axil_w_payload_strb,
//  output wire          s_axil_b_valid,
//  input  wire          s_axil_b_ready,
//  output wire [1:0]    s_axil_b_payload_resp,

  input  wire          s_axil_ar_valid,
  output wire          s_axil_ar_ready,
  input  wire [31:0]   s_axil_ar_payload_addr,
  input  wire [2:0]    s_axil_ar_payload_prot,
  output wire          s_axil_r_valid,
  input  wire          s_axil_r_ready,
  output wire [31:0]   s_axil_r_payload_data,
  output wire [1:0]    s_axil_r_payload_resp,
  input  wire [31:0]   intr_mask,
  input  wire [31:0]   intr_status,
  input  wire [31:0]   intr_raw_status,
  input  wire [31:0]   tiny_npu_status,
  input  wire [31:0]   systolic_status,
  input  wire [31:0]   cdma_status,
  input  wire          clk,
  input  wire          resetn
);

  wire                factory_readErrorFlag;
//  wire                factory_writeErrorFlag;
  wire                factory_readHaltRequest;
//  wire                factory_writeHaltRequest;
//  wire                factory_writeJoinEvent_valid;
//  wire                factory_writeJoinEvent_ready;
//  wire                factory_writeOccur;
//  reg        [1:0]    factory_writeRsp_resp;
//  wire                factory_writeJoinEvent_translated_valid;
//  wire                factory_writeJoinEvent_translated_ready;
//  wire       [1:0]    factory_writeJoinEvent_translated_payload_resp;
//  wire                _zz_factory_writeJoinEvent_translated_ready;
//  wire                factory_writeJoinEvent_translated_haltWhen_valid;
//  wire                factory_writeJoinEvent_translated_haltWhen_ready;
//  wire       [1:0]    factory_writeJoinEvent_translated_haltWhen_payload_resp;
//  wire                factory_writeJoinEvent_translated_haltWhen_halfPipe_valid;
//  wire                factory_writeJoinEvent_translated_haltWhen_halfPipe_ready;
//  wire       [1:0]    factory_writeJoinEvent_translated_haltWhen_halfPipe_payload_resp;
//  reg                 factory_writeJoinEvent_translated_haltWhen_rValid;
//  wire                factory_writeJoinEvent_translated_haltWhen_halfPipe_fire;
//  reg        [1:0]    factory_writeJoinEvent_translated_haltWhen_rData_resp;
  wire                factory_readDataStage_valid;
  wire                factory_readDataStage_ready;
  wire       [31:0]   factory_readDataStage_payload_addr;
  wire       [2:0]    factory_readDataStage_payload_prot;
  reg                 s_axil_ar_rValid;
  wire                factory_readDataStage_fire;
  reg        [31:0]   s_axil_ar_rData_addr;
  reg        [2:0]    s_axil_ar_rData_prot;
  reg        [31:0]   factory_readRsp_data;
  reg        [1:0]    factory_readRsp_resp;
  wire                _zz_factory_readDataStage_ready;
  wire                factory_readDataStage_haltWhen_valid;
  wire                factory_readDataStage_haltWhen_ready;
  wire       [31:0]   factory_readDataStage_haltWhen_payload_addr;
  wire       [2:0]    factory_readDataStage_haltWhen_payload_prot;
  wire                factory_readDataStage_haltWhen_translated_valid;
  wire                factory_readDataStage_haltWhen_translated_ready;
  wire       [31:0]   factory_readDataStage_haltWhen_translated_payload_data;
  wire       [1:0]    factory_readDataStage_haltWhen_translated_payload_resp;
  wire       [31:0]   factory_readAddressMasked;
//  wire       [31:0]   factory_writeAddressMasked;
  wire                factory_readOccur;

  assign factory_readErrorFlag = 1'b0;
//  assign factory_writeErrorFlag = 1'b0;
  assign factory_readHaltRequest = 1'b0;
//  assign factory_writeHaltRequest = 1'b0;
//  assign factory_writeOccur = (factory_writeJoinEvent_valid && factory_writeJoinEvent_ready);
//   assign factory_writeJoinEvent_valid = (s_axil_aw_valid && s_axil_w_valid);
//  assign s_axil_aw_ready = factory_writeOccur;
//  assign s_axil_w_ready = factory_writeOccur;
//  assign factory_writeJoinEvent_translated_valid = factory_writeJoinEvent_valid;
//  assign factory_writeJoinEvent_ready = factory_writeJoinEvent_translated_ready;
//  assign factory_writeJoinEvent_translated_payload_resp = factory_writeRsp_resp;
//  assign _zz_factory_writeJoinEvent_translated_ready = (! factory_writeHaltRequest);
//  assign factory_writeJoinEvent_translated_haltWhen_valid = (factory_writeJoinEvent_translated_valid && _zz_factory_writeJoinEvent_translated_ready);
//  assign factory_writeJoinEvent_translated_ready = (factory_writeJoinEvent_translated_haltWhen_ready && _zz_factory_writeJoinEvent_translated_ready);
//  assign factory_writeJoinEvent_translated_haltWhen_payload_resp = factory_writeJoinEvent_translated_payload_resp;
//  assign factory_writeJoinEvent_translated_haltWhen_halfPipe_fire = (factory_writeJoinEvent_translated_haltWhen_halfPipe_valid && factory_writeJoinEvent_translated_haltWhen_halfPipe_ready);
//  assign factory_writeJoinEvent_translated_haltWhen_ready = (! factory_writeJoinEvent_translated_haltWhen_rValid);
//  assign factory_writeJoinEvent_translated_haltWhen_halfPipe_valid = factory_writeJoinEvent_translated_haltWhen_rValid;
//  assign factory_writeJoinEvent_translated_haltWhen_halfPipe_payload_resp = factory_writeJoinEvent_translated_haltWhen_rData_resp;
//  assign s_axil_b_valid = factory_writeJoinEvent_translated_haltWhen_halfPipe_valid;
//  assign factory_writeJoinEvent_translated_haltWhen_halfPipe_ready = s_axil_b_ready;
//  assign s_axil_b_payload_resp = factory_writeJoinEvent_translated_haltWhen_halfPipe_payload_resp;
  assign factory_readDataStage_fire = (factory_readDataStage_valid && factory_readDataStage_ready);
  assign s_axil_ar_ready = (! s_axil_ar_rValid);
  assign factory_readDataStage_valid = s_axil_ar_rValid;
  assign factory_readDataStage_payload_addr = s_axil_ar_rData_addr;
  assign factory_readDataStage_payload_prot = s_axil_ar_rData_prot;
  assign _zz_factory_readDataStage_ready = (! factory_readHaltRequest);
  assign factory_readDataStage_haltWhen_valid = (factory_readDataStage_valid && _zz_factory_readDataStage_ready);
  assign factory_readDataStage_ready = (factory_readDataStage_haltWhen_ready && _zz_factory_readDataStage_ready);
  assign factory_readDataStage_haltWhen_payload_addr = factory_readDataStage_payload_addr;
  assign factory_readDataStage_haltWhen_payload_prot = factory_readDataStage_payload_prot;
  assign factory_readDataStage_haltWhen_translated_valid = factory_readDataStage_haltWhen_valid;
  assign factory_readDataStage_haltWhen_ready = factory_readDataStage_haltWhen_translated_ready;
  assign factory_readDataStage_haltWhen_translated_payload_data = factory_readRsp_data;
  assign factory_readDataStage_haltWhen_translated_payload_resp = factory_readRsp_resp;
  assign s_axil_r_valid = factory_readDataStage_haltWhen_translated_valid;
  assign factory_readDataStage_haltWhen_translated_ready = s_axil_r_ready;
  assign s_axil_r_payload_data = factory_readDataStage_haltWhen_translated_payload_data;
  assign s_axil_r_payload_resp = factory_readDataStage_haltWhen_translated_payload_resp;
//  always @(*) begin
//    if(factory_writeErrorFlag) begin
//      factory_writeRsp_resp = 2'b10;
//    end else begin
//      factory_writeRsp_resp = 2'b00;
//    end
//  end

  always @(*) begin
    if(factory_readErrorFlag) begin
      factory_readRsp_resp = 2'b10;
    end else begin
      factory_readRsp_resp = 2'b00;
    end
  end

  always @(*) begin
    factory_readRsp_data = 64'h0;
    case(factory_readAddressMasked)
      `REG_INTR_STATUS : begin
        factory_readRsp_data[31 : 0] = intr_status;
      end
      `REG_INTR_RAW_STATUS : begin
        factory_readRsp_data[31 : 0] = intr_raw_status;
      end
      `REG_INTR_MASK : begin
        factory_readRsp_data[31 : 0] = intr_mask;
      end
      `REG_TINY_NPU_STATUS : begin
        factory_readRsp_data[31 : 0] = tiny_npu_status;
      end
      `REG_SYSTOLIC_STATUS : begin
        factory_readRsp_data[31 : 0] = systolic_status;
      end
      `REG_CDMA_STATUS : begin
        factory_readRsp_data[31 : 0] = cdma_status;
      end
      default : begin
      end
    endcase
  end

  assign factory_readAddressMasked = (factory_readDataStage_payload_addr & (~ 32'h00000003));
//  assign factory_writeAddressMasked = (s_axil_aw_payload_addr & (~ 32'h00000007));
  assign factory_readOccur = (s_axil_r_valid && s_axil_r_ready);
  always @(posedge clk) begin
    if(!resetn) begin
//      factory_writeJoinEvent_translated_haltWhen_rValid <= 1'b0;
      s_axil_ar_rValid <= 1'b0;
    end else begin
//      if(factory_writeJoinEvent_translated_haltWhen_valid) begin
//        factory_writeJoinEvent_translated_haltWhen_rValid <= 1'b1;
//      end
//      if(factory_writeJoinEvent_translated_haltWhen_halfPipe_fire) begin
//        factory_writeJoinEvent_translated_haltWhen_rValid <= 1'b0;
//      end
      if(s_axil_ar_valid) begin
        s_axil_ar_rValid <= 1'b1;
      end
      if(factory_readDataStage_fire) begin
        s_axil_ar_rValid <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
//    if(factory_writeJoinEvent_translated_haltWhen_ready) begin
//      factory_writeJoinEvent_translated_haltWhen_rData_resp <= factory_writeJoinEvent_translated_haltWhen_payload_resp;
//    end
    if(s_axil_ar_ready) begin
      s_axil_ar_rData_addr <= s_axil_ar_payload_addr;
      s_axil_ar_rData_prot <= s_axil_ar_payload_prot;
    end
  end


endmodule
