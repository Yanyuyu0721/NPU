// Generator : SpinalHDL v1.12.0    git head : 1aa7d7b5732f11cca2dd83bacc2a4cb92ca8e5c9
// Component : axil_cdc
// Git hash  : 40e5b973fc363aa52aac66891be1841b4b2bbaad

`timescale 1ns/1ps

module axil_cdc (
  input  wire          s_axil_clk,
  input  wire          s_axil_rst_n,
  input  wire          m_axil_clk,
  input  wire          m_axil_rst_n,
  input  wire          s_axil_aw_valid,
  output wire          s_axil_aw_ready,
  input  wire [31:0]   s_axil_aw_payload_addr,
  input  wire [2:0]    s_axil_aw_payload_prot,
  input  wire          s_axil_w_valid,
  output wire          s_axil_w_ready,
  input  wire [31:0]   s_axil_w_payload_data,
  input  wire [3:0]    s_axil_w_payload_strb,
  output wire          s_axil_b_valid,
  input  wire          s_axil_b_ready,
  output wire [1:0]    s_axil_b_payload_resp,
  input  wire          s_axil_ar_valid,
  output wire          s_axil_ar_ready,
  input  wire [31:0]   s_axil_ar_payload_addr,
  input  wire [2:0]    s_axil_ar_payload_prot,
  output wire          s_axil_r_valid,
  input  wire          s_axil_r_ready,
  output wire [31:0]   s_axil_r_payload_data,
  output wire [1:0]    s_axil_r_payload_resp,
  output wire          m_axil_aw_valid,
  input  wire          m_axil_aw_ready,
  output wire [31:0]   m_axil_aw_payload_addr,
  output wire [2:0]    m_axil_aw_payload_prot,
  output wire          m_axil_w_valid,
  input  wire          m_axil_w_ready,
  output wire [31:0]   m_axil_w_payload_data,
  output wire [3:0]    m_axil_w_payload_strb,
  input  wire          m_axil_b_valid,
  output wire          m_axil_b_ready,
  input  wire [1:0]    m_axil_b_payload_resp,
  output wire          m_axil_ar_valid,
  input  wire          m_axil_ar_ready,
  output wire [31:0]   m_axil_ar_payload_addr,
  output wire [2:0]    m_axil_ar_payload_prot,
  input  wire          m_axil_r_valid,
  output wire          m_axil_r_ready,
  input  wire [31:0]   m_axil_r_payload_data,
  input  wire [1:0]    m_axil_r_payload_resp
);

  wire                awFifo_io_push_ready;
  wire                awFifo_io_pop_valid;
  wire       [31:0]   awFifo_io_pop_payload_addr;
  wire       [2:0]    awFifo_io_pop_payload_prot;
  wire       [2:0]    awFifo_io_pushOccupancy;
  wire       [2:0]    awFifo_io_popOccupancy;
  wire                awFifo_toplevel_s_axil_rst_n_synchronized_1;
  wire                wFifo_io_push_ready;
  wire                wFifo_io_pop_valid;
  wire       [31:0]   wFifo_io_pop_payload_data;
  wire       [3:0]    wFifo_io_pop_payload_strb;
  wire       [2:0]    wFifo_io_pushOccupancy;
  wire       [2:0]    wFifo_io_popOccupancy;
  wire                arFifo_io_push_ready;
  wire                arFifo_io_pop_valid;
  wire       [31:0]   arFifo_io_pop_payload_addr;
  wire       [2:0]    arFifo_io_pop_payload_prot;
  wire       [2:0]    arFifo_io_pushOccupancy;
  wire       [2:0]    arFifo_io_popOccupancy;
  wire                bFifo_io_push_ready;
  wire                bFifo_io_pop_valid;
  wire       [1:0]    bFifo_io_pop_payload_resp;
  wire       [2:0]    bFifo_io_pushOccupancy;
  wire       [2:0]    bFifo_io_popOccupancy;
  wire                bFifo_toplevel_m_axil_rst_n_synchronized_1;
  wire                rFifo_io_push_ready;
  wire                rFifo_io_pop_valid;
  wire       [31:0]   rFifo_io_pop_payload_data;
  wire       [1:0]    rFifo_io_pop_payload_resp;
  wire       [2:0]    rFifo_io_pushOccupancy;
  wire       [2:0]    rFifo_io_popOccupancy;

  AxilStreamFifoCC awFifo (
    .io_push_valid                        (s_axil_aw_valid                            ), //i
    .io_push_ready                        (awFifo_io_push_ready                       ), //o
    .io_push_payload_addr                 (s_axil_aw_payload_addr[31:0]               ), //i
    .io_push_payload_prot                 (s_axil_aw_payload_prot[2:0]                ), //i
    .io_pop_valid                         (awFifo_io_pop_valid                        ), //o
    .io_pop_ready                         (m_axil_aw_ready                            ), //i
    .io_pop_payload_addr                  (awFifo_io_pop_payload_addr[31:0]           ), //o
    .io_pop_payload_prot                  (awFifo_io_pop_payload_prot[2:0]            ), //o
    .io_pushOccupancy                     (awFifo_io_pushOccupancy[2:0]               ), //o
    .io_popOccupancy                      (awFifo_io_popOccupancy[2:0]                ), //o
    .s_axil_clk                           (s_axil_clk                                 ), //i
    .s_axil_rst_n                         (s_axil_rst_n                               ), //i
    .m_axil_clk                           (m_axil_clk                                 ), //i
    .toplevel_s_axil_rst_n_synchronized_1 (awFifo_toplevel_s_axil_rst_n_synchronized_1)  //o
  );
  AxilStreamFifoCC_1 wFifo (
    .io_push_valid                        (s_axil_w_valid                             ), //i
    .io_push_ready                        (wFifo_io_push_ready                        ), //o
    .io_push_payload_data                 (s_axil_w_payload_data[31:0]                ), //i
    .io_push_payload_strb                 (s_axil_w_payload_strb[3:0]                 ), //i
    .io_pop_valid                         (wFifo_io_pop_valid                         ), //o
    .io_pop_ready                         (m_axil_w_ready                             ), //i
    .io_pop_payload_data                  (wFifo_io_pop_payload_data[31:0]            ), //o
    .io_pop_payload_strb                  (wFifo_io_pop_payload_strb[3:0]             ), //o
    .io_pushOccupancy                     (wFifo_io_pushOccupancy[2:0]                ), //o
    .io_popOccupancy                      (wFifo_io_popOccupancy[2:0]                 ), //o
    .s_axil_clk                           (s_axil_clk                                 ), //i
    .s_axil_rst_n                         (s_axil_rst_n                               ), //i
    .m_axil_clk                           (m_axil_clk                                 ), //i
    .toplevel_s_axil_rst_n_synchronized_1 (awFifo_toplevel_s_axil_rst_n_synchronized_1)  //i
  );
  AxilStreamFifoCC_2 arFifo (
    .io_push_valid                        (s_axil_ar_valid                            ), //i
    .io_push_ready                        (arFifo_io_push_ready                       ), //o
    .io_push_payload_addr                 (s_axil_ar_payload_addr[31:0]               ), //i
    .io_push_payload_prot                 (s_axil_ar_payload_prot[2:0]                ), //i
    .io_pop_valid                         (arFifo_io_pop_valid                        ), //o
    .io_pop_ready                         (m_axil_ar_ready                            ), //i
    .io_pop_payload_addr                  (arFifo_io_pop_payload_addr[31:0]           ), //o
    .io_pop_payload_prot                  (arFifo_io_pop_payload_prot[2:0]            ), //o
    .io_pushOccupancy                     (arFifo_io_pushOccupancy[2:0]               ), //o
    .io_popOccupancy                      (arFifo_io_popOccupancy[2:0]                ), //o
    .s_axil_clk                           (s_axil_clk                                 ), //i
    .s_axil_rst_n                         (s_axil_rst_n                               ), //i
    .m_axil_clk                           (m_axil_clk                                 ), //i
    .toplevel_s_axil_rst_n_synchronized_1 (awFifo_toplevel_s_axil_rst_n_synchronized_1)  //i
  );
  AxilStreamFifoCC_3 bFifo (
    .io_push_valid                        (m_axil_b_valid                            ), //i
    .io_push_ready                        (bFifo_io_push_ready                       ), //o
    .io_push_payload_resp                 (m_axil_b_payload_resp[1:0]                ), //i
    .io_pop_valid                         (bFifo_io_pop_valid                        ), //o
    .io_pop_ready                         (s_axil_b_ready                            ), //i
    .io_pop_payload_resp                  (bFifo_io_pop_payload_resp[1:0]            ), //o
    .io_pushOccupancy                     (bFifo_io_pushOccupancy[2:0]               ), //o
    .io_popOccupancy                      (bFifo_io_popOccupancy[2:0]                ), //o
    .m_axil_clk                           (m_axil_clk                                ), //i
    .m_axil_rst_n                         (m_axil_rst_n                              ), //i
    .s_axil_clk                           (s_axil_clk                                ), //i
    .toplevel_m_axil_rst_n_synchronized_1 (bFifo_toplevel_m_axil_rst_n_synchronized_1)  //o
  );
  AxilStreamFifoCC_4 rFifo (
    .io_push_valid                        (m_axil_r_valid                            ), //i
    .io_push_ready                        (rFifo_io_push_ready                       ), //o
    .io_push_payload_data                 (m_axil_r_payload_data[31:0]               ), //i
    .io_push_payload_resp                 (m_axil_r_payload_resp[1:0]                ), //i
    .io_pop_valid                         (rFifo_io_pop_valid                        ), //o
    .io_pop_ready                         (s_axil_r_ready                            ), //i
    .io_pop_payload_data                  (rFifo_io_pop_payload_data[31:0]           ), //o
    .io_pop_payload_resp                  (rFifo_io_pop_payload_resp[1:0]            ), //o
    .io_pushOccupancy                     (rFifo_io_pushOccupancy[2:0]               ), //o
    .io_popOccupancy                      (rFifo_io_popOccupancy[2:0]                ), //o
    .m_axil_clk                           (m_axil_clk                                ), //i
    .m_axil_rst_n                         (m_axil_rst_n                              ), //i
    .s_axil_clk                           (s_axil_clk                                ), //i
    .toplevel_m_axil_rst_n_synchronized_1 (bFifo_toplevel_m_axil_rst_n_synchronized_1)  //i
  );
  assign s_axil_aw_ready = awFifo_io_push_ready;
  assign m_axil_aw_valid = awFifo_io_pop_valid;
  assign m_axil_aw_payload_addr = awFifo_io_pop_payload_addr;
  assign m_axil_aw_payload_prot = awFifo_io_pop_payload_prot;
  assign s_axil_w_ready = wFifo_io_push_ready;
  assign m_axil_w_valid = wFifo_io_pop_valid;
  assign m_axil_w_payload_data = wFifo_io_pop_payload_data;
  assign m_axil_w_payload_strb = wFifo_io_pop_payload_strb;
  assign s_axil_ar_ready = arFifo_io_push_ready;
  assign m_axil_ar_valid = arFifo_io_pop_valid;
  assign m_axil_ar_payload_addr = arFifo_io_pop_payload_addr;
  assign m_axil_ar_payload_prot = arFifo_io_pop_payload_prot;
  assign m_axil_b_ready = bFifo_io_push_ready;
  assign s_axil_b_valid = bFifo_io_pop_valid;
  assign s_axil_b_payload_resp = bFifo_io_pop_payload_resp;
  assign m_axil_r_ready = rFifo_io_push_ready;
  assign s_axil_r_valid = rFifo_io_pop_valid;
  assign s_axil_r_payload_data = rFifo_io_pop_payload_data;
  assign s_axil_r_payload_resp = rFifo_io_pop_payload_resp;

endmodule

module AxilStreamFifoCC_4 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_data,
  input  wire [1:0]    io_push_payload_resp,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_data,
  output wire [1:0]    io_pop_payload_resp,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          m_axil_clk,
  input  wire          m_axil_rst_n,
  input  wire          s_axil_clk,
  input  wire          toplevel_m_axil_rst_n_synchronized_1
);

  reg        [33:0]   ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [33:0]   _zz_ram_port_1;
  wire       [2:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [2:0]    popToPushGray;
  wire       [2:0]    pushToPopGray;
  reg        [2:0]    pushCC_pushPtr;
  wire       [2:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    pushCC_pushPtrGray;
  wire       [2:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  reg        [2:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [2:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [2:0]    popCC_popPtrGray;
  wire       [2:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [1:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [1:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [1:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [1:0]    popCC_readPort_cmd_payload;
  wire       [31:0]   popCC_readPort_rsp_data;
  wire       [1:0]    popCC_readPort_rsp_resp;
  wire       [33:0]   _zz_popCC_readPort_rsp_data;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_data;
  wire       [1:0]    popCC_readArbitation_translated_payload_resp;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  (* ram_style = "distributed" *)reg [33:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_resp,io_push_payload_data};
  always @(posedge m_axil_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge s_axil_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxilBufferCC_7 popToPushGray_buffercc (
    .io_dataIn    (popToPushGray[2:0]                    ), //i
    .io_dataOut   (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .m_axil_clk   (m_axil_clk                            ), //i
    .m_axil_rst_n (m_axil_rst_n                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_11 pushToPopGray_buffercc (
    .io_dataIn                            (pushToPopGray[2:0]                    ), //i
    .io_dataOut                           (pushToPopGray_buffercc_io_dataOut[2:0]), //o
    .s_axil_clk                           (s_axil_clk                            ), //i
    .toplevel_m_axil_rst_n_synchronized_1 (toplevel_m_axil_rst_n_synchronized_1  )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 3'b001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[2 : 1] == (~ pushCC_popPtrGray[2 : 1])) && (pushCC_pushPtrGray[0 : 0] == pushCC_popPtrGray[0 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = pushCC_popPtrGray[2];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}});
  assign popCC_popPtrPlus = (popCC_popPtr + 3'b001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[1:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l399) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l399 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign _zz_popCC_readPort_rsp_data = ram_spinal_port1;
  assign popCC_readPort_rsp_data = _zz_popCC_readPort_rsp_data[31 : 0];
  assign popCC_readPort_rsp_resp = _zz_popCC_readPort_rsp_data[33 : 32];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_data = popCC_readPort_rsp_data;
  assign popCC_readArbitation_translated_payload_resp = popCC_readPort_rsp_resp;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = popCC_readArbitation_translated_payload_data;
  assign io_pop_payload_resp = popCC_readArbitation_translated_payload_resp;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge m_axil_clk) begin
    if(!m_axil_rst_n) begin
      pushCC_pushPtr <= 3'b000;
      pushCC_pushPtrGray <= 3'b000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge s_axil_clk) begin
    if(!toplevel_m_axil_rst_n_synchronized_1) begin
      popCC_popPtr <= 3'b000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 3'b000;
      popCC_ptrToOccupancy <= 3'b000;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge s_axil_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxilStreamFifoCC_3 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [1:0]    io_push_payload_resp,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [1:0]    io_pop_payload_resp,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          m_axil_clk,
  input  wire          m_axil_rst_n,
  input  wire          s_axil_clk,
  output wire          toplevel_m_axil_rst_n_synchronized_1
);

  reg        [1:0]    ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire                toplevel_m_axil_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [2:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [2:0]    popToPushGray;
  wire       [2:0]    pushToPopGray;
  reg        [2:0]    pushCC_pushPtr;
  wire       [2:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    pushCC_pushPtrGray;
  wire       [2:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  wire                toplevel_m_axil_rst_n_asyncAssertSyncDeassert;
  wire                toplevel_m_axil_rst_n_synchronized;
  reg        [2:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [2:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [2:0]    popCC_popPtrGray;
  wire       [2:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [1:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [1:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [1:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [1:0]    popCC_readPort_cmd_payload;
  wire       [1:0]    popCC_readPort_rsp_resp;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [1:0]    popCC_readArbitation_translated_payload_resp;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  reg [1:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  always @(posedge m_axil_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= io_push_payload_resp;
    end
  end

  always @(posedge s_axil_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxilBufferCC_7 popToPushGray_buffercc (
    .io_dataIn    (popToPushGray[2:0]                    ), //i
    .io_dataOut   (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .m_axil_clk   (m_axil_clk                            ), //i
    .m_axil_rst_n (m_axil_rst_n                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_8 toplevel_m_axil_rst_n_asyncAssertSyncDeassert_buffercc (
    .io_dataIn    (toplevel_m_axil_rst_n_asyncAssertSyncDeassert                    ), //i
    .io_dataOut   (toplevel_m_axil_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut), //o
    .s_axil_clk   (s_axil_clk                                                       ), //i
    .m_axil_rst_n (m_axil_rst_n                                                     )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_9 pushToPopGray_buffercc (
    .io_dataIn                          (pushToPopGray[2:0]                    ), //i
    .io_dataOut                         (pushToPopGray_buffercc_io_dataOut[2:0]), //o
    .s_axil_clk                         (s_axil_clk                            ), //i
    .toplevel_m_axil_rst_n_synchronized (toplevel_m_axil_rst_n_synchronized    )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 3'b001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[2 : 1] == (~ pushCC_popPtrGray[2 : 1])) && (pushCC_pushPtrGray[0 : 0] == pushCC_popPtrGray[0 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = pushCC_popPtrGray[2];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}});
  assign toplevel_m_axil_rst_n_asyncAssertSyncDeassert = (1'b1 ^ 1'b0);
  assign toplevel_m_axil_rst_n_synchronized = toplevel_m_axil_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  assign popCC_popPtrPlus = (popCC_popPtr + 3'b001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[1:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l399) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l399 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign popCC_readPort_rsp_resp = ram_spinal_port1[1 : 0];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_resp = popCC_readPort_rsp_resp;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_resp = popCC_readArbitation_translated_payload_resp;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  assign toplevel_m_axil_rst_n_synchronized_1 = toplevel_m_axil_rst_n_synchronized;
  always @(posedge m_axil_clk) begin
    if(!m_axil_rst_n) begin
      pushCC_pushPtr <= 3'b000;
      pushCC_pushPtrGray <= 3'b000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge s_axil_clk) begin
    if(!toplevel_m_axil_rst_n_synchronized) begin
      popCC_popPtr <= 3'b000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 3'b000;
      popCC_ptrToOccupancy <= 3'b000;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge s_axil_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxilStreamFifoCC_2 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_addr,
  input  wire [2:0]    io_push_payload_prot,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_addr,
  output wire [2:0]    io_pop_payload_prot,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          s_axil_clk,
  input  wire          s_axil_rst_n,
  input  wire          m_axil_clk,
  input  wire          toplevel_s_axil_rst_n_synchronized_1
);

  reg        [34:0]   ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [34:0]   _zz_ram_port_1;
  wire       [2:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [2:0]    popToPushGray;
  wire       [2:0]    pushToPopGray;
  reg        [2:0]    pushCC_pushPtr;
  wire       [2:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    pushCC_pushPtrGray;
  wire       [2:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  reg        [2:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [2:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [2:0]    popCC_popPtrGray;
  wire       [2:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [1:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [1:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [1:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [1:0]    popCC_readPort_cmd_payload;
  wire       [31:0]   popCC_readPort_rsp_addr;
  wire       [2:0]    popCC_readPort_rsp_prot;
  wire       [34:0]   _zz_popCC_readPort_rsp_addr;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_addr;
  wire       [2:0]    popCC_readArbitation_translated_payload_prot;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  (* ram_style = "distributed" *)reg [34:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_prot,io_push_payload_addr};
  always @(posedge s_axil_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge m_axil_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxilBufferCC popToPushGray_buffercc (
    .io_dataIn    (popToPushGray[2:0]                    ), //i
    .io_dataOut   (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .s_axil_clk   (s_axil_clk                            ), //i
    .s_axil_rst_n (s_axil_rst_n                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_4 pushToPopGray_buffercc (
    .io_dataIn                            (pushToPopGray[2:0]                    ), //i
    .io_dataOut                           (pushToPopGray_buffercc_io_dataOut[2:0]), //o
    .m_axil_clk                           (m_axil_clk                            ), //i
    .toplevel_s_axil_rst_n_synchronized_1 (toplevel_s_axil_rst_n_synchronized_1  )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 3'b001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[2 : 1] == (~ pushCC_popPtrGray[2 : 1])) && (pushCC_pushPtrGray[0 : 0] == pushCC_popPtrGray[0 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = pushCC_popPtrGray[2];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}});
  assign popCC_popPtrPlus = (popCC_popPtr + 3'b001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[1:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l399) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l399 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign _zz_popCC_readPort_rsp_addr = ram_spinal_port1;
  assign popCC_readPort_rsp_addr = _zz_popCC_readPort_rsp_addr[31 : 0];
  assign popCC_readPort_rsp_prot = _zz_popCC_readPort_rsp_addr[34 : 32];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_addr = popCC_readPort_rsp_addr;
  assign popCC_readArbitation_translated_payload_prot = popCC_readPort_rsp_prot;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_addr = popCC_readArbitation_translated_payload_addr;
  assign io_pop_payload_prot = popCC_readArbitation_translated_payload_prot;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge s_axil_clk) begin
    if(!s_axil_rst_n) begin
      pushCC_pushPtr <= 3'b000;
      pushCC_pushPtrGray <= 3'b000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge m_axil_clk) begin
    if(!toplevel_s_axil_rst_n_synchronized_1) begin
      popCC_popPtr <= 3'b000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 3'b000;
      popCC_ptrToOccupancy <= 3'b000;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge m_axil_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxilStreamFifoCC_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_data,
  input  wire [3:0]    io_push_payload_strb,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_data,
  output wire [3:0]    io_pop_payload_strb,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          s_axil_clk,
  input  wire          s_axil_rst_n,
  input  wire          m_axil_clk,
  input  wire          toplevel_s_axil_rst_n_synchronized_1
);

  reg        [35:0]   ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [35:0]   _zz_ram_port_1;
  wire       [2:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [2:0]    popToPushGray;
  wire       [2:0]    pushToPopGray;
  reg        [2:0]    pushCC_pushPtr;
  wire       [2:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    pushCC_pushPtrGray;
  wire       [2:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  reg        [2:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [2:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [2:0]    popCC_popPtrGray;
  wire       [2:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [1:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [1:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [1:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [1:0]    popCC_readPort_cmd_payload;
  wire       [31:0]   popCC_readPort_rsp_data;
  wire       [3:0]    popCC_readPort_rsp_strb;
  wire       [35:0]   _zz_popCC_readPort_rsp_data;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_data;
  wire       [3:0]    popCC_readArbitation_translated_payload_strb;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
 (* ram_style = "distributed" *) reg [35:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_strb,io_push_payload_data};
  always @(posedge s_axil_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge m_axil_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxilBufferCC popToPushGray_buffercc (
    .io_dataIn    (popToPushGray[2:0]                    ), //i
    .io_dataOut   (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .s_axil_clk   (s_axil_clk                            ), //i
    .s_axil_rst_n (s_axil_rst_n                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_4 pushToPopGray_buffercc (
    .io_dataIn                            (pushToPopGray[2:0]                    ), //i
    .io_dataOut                           (pushToPopGray_buffercc_io_dataOut[2:0]), //o
    .m_axil_clk                           (m_axil_clk                            ), //i
    .toplevel_s_axil_rst_n_synchronized_1 (toplevel_s_axil_rst_n_synchronized_1  )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 3'b001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[2 : 1] == (~ pushCC_popPtrGray[2 : 1])) && (pushCC_pushPtrGray[0 : 0] == pushCC_popPtrGray[0 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = pushCC_popPtrGray[2];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}});
  assign popCC_popPtrPlus = (popCC_popPtr + 3'b001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[1:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l399) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l399 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign _zz_popCC_readPort_rsp_data = ram_spinal_port1;
  assign popCC_readPort_rsp_data = _zz_popCC_readPort_rsp_data[31 : 0];
  assign popCC_readPort_rsp_strb = _zz_popCC_readPort_rsp_data[35 : 32];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_data = popCC_readPort_rsp_data;
  assign popCC_readArbitation_translated_payload_strb = popCC_readPort_rsp_strb;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = popCC_readArbitation_translated_payload_data;
  assign io_pop_payload_strb = popCC_readArbitation_translated_payload_strb;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge s_axil_clk) begin
    if(!s_axil_rst_n) begin
      pushCC_pushPtr <= 3'b000;
      pushCC_pushPtrGray <= 3'b000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge m_axil_clk) begin
    if(!toplevel_s_axil_rst_n_synchronized_1) begin
      popCC_popPtr <= 3'b000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 3'b000;
      popCC_ptrToOccupancy <= 3'b000;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge m_axil_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxilStreamFifoCC (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_addr,
  input  wire [2:0]    io_push_payload_prot,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_addr,
  output wire [2:0]    io_pop_payload_prot,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          s_axil_clk,
  input  wire          s_axil_rst_n,
  input  wire          m_axil_clk,
  output wire          toplevel_s_axil_rst_n_synchronized_1
);

  reg        [34:0]   ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire                toplevel_s_axil_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [34:0]   _zz_ram_port_1;
  wire       [2:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [2:0]    popToPushGray;
  wire       [2:0]    pushToPopGray;
  reg        [2:0]    pushCC_pushPtr;
  wire       [2:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    pushCC_pushPtrGray;
  wire       [2:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  wire                toplevel_s_axil_rst_n_asyncAssertSyncDeassert;
  wire                toplevel_s_axil_rst_n_synchronized;
  reg        [2:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [2:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [2:0]    popCC_popPtrGray;
  wire       [2:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [1:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [1:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [1:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [1:0]    popCC_readPort_cmd_payload;
  wire       [31:0]   popCC_readPort_rsp_addr;
  wire       [2:0]    popCC_readPort_rsp_prot;
  wire       [34:0]   _zz_popCC_readPort_rsp_addr;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_addr;
  wire       [2:0]    popCC_readArbitation_translated_payload_prot;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  (* ram_style = "distributed" *)reg [34:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_prot,io_push_payload_addr};
  always @(posedge s_axil_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge m_axil_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxilBufferCC popToPushGray_buffercc (
    .io_dataIn    (popToPushGray[2:0]                    ), //i
    .io_dataOut   (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .s_axil_clk   (s_axil_clk                            ), //i
    .s_axil_rst_n (s_axil_rst_n                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_1 toplevel_s_axil_rst_n_asyncAssertSyncDeassert_buffercc (
    .io_dataIn    (toplevel_s_axil_rst_n_asyncAssertSyncDeassert                    ), //i
    .io_dataOut   (toplevel_s_axil_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut), //o
    .m_axil_clk   (m_axil_clk                                                       ), //i
    .s_axil_rst_n (s_axil_rst_n                                                     )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxilBufferCC_2 pushToPopGray_buffercc (
    .io_dataIn                          (pushToPopGray[2:0]                    ), //i
    .io_dataOut                         (pushToPopGray_buffercc_io_dataOut[2:0]), //o
    .m_axil_clk                         (m_axil_clk                            ), //i
    .toplevel_s_axil_rst_n_synchronized (toplevel_s_axil_rst_n_synchronized    )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 3'b001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[2 : 1] == (~ pushCC_popPtrGray[2 : 1])) && (pushCC_pushPtrGray[0 : 0] == pushCC_popPtrGray[0 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = pushCC_popPtrGray[2];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}});
  assign toplevel_s_axil_rst_n_asyncAssertSyncDeassert = (1'b1 ^ 1'b0);
  assign toplevel_s_axil_rst_n_synchronized = toplevel_s_axil_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  assign popCC_popPtrPlus = (popCC_popPtr + 3'b001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[1:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l399) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l399 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign _zz_popCC_readPort_rsp_addr = ram_spinal_port1;
  assign popCC_readPort_rsp_addr = _zz_popCC_readPort_rsp_addr[31 : 0];
  assign popCC_readPort_rsp_prot = _zz_popCC_readPort_rsp_addr[34 : 32];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_addr = popCC_readPort_rsp_addr;
  assign popCC_readArbitation_translated_payload_prot = popCC_readPort_rsp_prot;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_addr = popCC_readArbitation_translated_payload_addr;
  assign io_pop_payload_prot = popCC_readArbitation_translated_payload_prot;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  assign toplevel_s_axil_rst_n_synchronized_1 = toplevel_s_axil_rst_n_synchronized;
  always @(posedge s_axil_clk) begin
    if(!s_axil_rst_n) begin
      pushCC_pushPtr <= 3'b000;
      pushCC_pushPtrGray <= 3'b000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge m_axil_clk) begin
    if(!toplevel_s_axil_rst_n_synchronized) begin
      popCC_popPtr <= 3'b000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 3'b000;
      popCC_ptrToOccupancy <= 3'b000;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge m_axil_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxilBufferCC_11 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          s_axil_clk,
  input  wire          toplevel_m_axil_rst_n_synchronized_1
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axil_clk) begin
    if(!toplevel_m_axil_rst_n_synchronized_1) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

//AxilBufferCC_10 replaced by AxilBufferCC_7

module AxilBufferCC_9 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          s_axil_clk,
  input  wire          toplevel_m_axil_rst_n_synchronized
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axil_clk) begin
    if(!toplevel_m_axil_rst_n_synchronized) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxilBufferCC_8 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          s_axil_clk,
  input  wire          m_axil_rst_n
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axil_clk) begin
    if(!m_axil_rst_n) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxilBufferCC_7 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          m_axil_clk,
  input  wire          m_axil_rst_n
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axil_clk) begin
    if(!m_axil_rst_n) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

//AxilBufferCC_6 replaced by AxilBufferCC_4

//AxilBufferCC_5 replaced by AxilBufferCC

module AxilBufferCC_4 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          m_axil_clk,
  input  wire          toplevel_s_axil_rst_n_synchronized_1
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axil_clk) begin
    if(!toplevel_s_axil_rst_n_synchronized_1) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

//AxilBufferCC_3 replaced by AxilBufferCC

module AxilBufferCC_2 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          m_axil_clk,
  input  wire          toplevel_s_axil_rst_n_synchronized
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axil_clk) begin
    if(!toplevel_s_axil_rst_n_synchronized) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxilBufferCC_1 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          m_axil_clk,
  input  wire          s_axil_rst_n
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axil_clk) begin
    if(!s_axil_rst_n) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxilBufferCC (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          s_axil_clk,
  input  wire          s_axil_rst_n
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axil_clk) begin
    if(!s_axil_rst_n) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule
