// Generator : SpinalHDL v1.12.0    git head : 1aa7d7b5732f11cca2dd83bacc2a4cb92ca8e5c9
// Component : axi_cdc
// Git hash  : ca23e6e6990ca6ba552c231317fb1e71964bdeac

`timescale 1ns/1ps

module axi_cdc (
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n,
  input  wire          m_axi_clk,
  input  wire          m_axi_rst_n,
  input  wire          s_axi_aw_valid,
  output wire          s_axi_aw_ready,
  input  wire [31:0]   s_axi_aw_payload_addr,
  input  wire [3:0]    s_axi_aw_payload_id,
  input  wire [3:0]    s_axi_aw_payload_region,
  input  wire [7:0]    s_axi_aw_payload_len,
  input  wire [2:0]    s_axi_aw_payload_size,
  input  wire [1:0]    s_axi_aw_payload_burst,
  input  wire [0:0]    s_axi_aw_payload_lock,
  input  wire [3:0]    s_axi_aw_payload_cache,
  input  wire [3:0]    s_axi_aw_payload_qos,
  input  wire [2:0]    s_axi_aw_payload_prot,
  input  wire          s_axi_w_valid,
  output wire          s_axi_w_ready,
  input  wire [63:0]   s_axi_w_payload_data,
  input  wire [7:0]    s_axi_w_payload_strb,
  input  wire          s_axi_w_payload_last,
  output wire          s_axi_b_valid,
  input  wire          s_axi_b_ready,
  output wire [3:0]    s_axi_b_payload_id,
  output wire [1:0]    s_axi_b_payload_resp,
  input  wire          s_axi_ar_valid,
  output wire          s_axi_ar_ready,
  input  wire [31:0]   s_axi_ar_payload_addr,
  input  wire [3:0]    s_axi_ar_payload_id,
  input  wire [3:0]    s_axi_ar_payload_region,
  input  wire [7:0]    s_axi_ar_payload_len,
  input  wire [2:0]    s_axi_ar_payload_size,
  input  wire [1:0]    s_axi_ar_payload_burst,
  input  wire [0:0]    s_axi_ar_payload_lock,
  input  wire [3:0]    s_axi_ar_payload_cache,
  input  wire [3:0]    s_axi_ar_payload_qos,
  input  wire [2:0]    s_axi_ar_payload_prot,
  output wire          s_axi_r_valid,
  input  wire          s_axi_r_ready,
  output wire [63:0]   s_axi_r_payload_data,
  output wire [3:0]    s_axi_r_payload_id,
  output wire [1:0]    s_axi_r_payload_resp,
  output wire          s_axi_r_payload_last,
  output wire          m_axi_aw_valid,
  input  wire          m_axi_aw_ready,
  output wire [31:0]   m_axi_aw_payload_addr,
  output wire [3:0]    m_axi_aw_payload_id,
  output wire [3:0]    m_axi_aw_payload_region,
  output wire [7:0]    m_axi_aw_payload_len,
  output wire [2:0]    m_axi_aw_payload_size,
  output wire [1:0]    m_axi_aw_payload_burst,
  output wire [0:0]    m_axi_aw_payload_lock,
  output wire [3:0]    m_axi_aw_payload_cache,
  output wire [3:0]    m_axi_aw_payload_qos,
  output wire [2:0]    m_axi_aw_payload_prot,
  output wire          m_axi_w_valid,
  input  wire          m_axi_w_ready,
  output wire [63:0]   m_axi_w_payload_data,
  output wire [7:0]    m_axi_w_payload_strb,
  output wire          m_axi_w_payload_last,
  input  wire          m_axi_b_valid,
  output wire          m_axi_b_ready,
  input  wire [3:0]    m_axi_b_payload_id,
  input  wire [1:0]    m_axi_b_payload_resp,
  output wire          m_axi_ar_valid,
  input  wire          m_axi_ar_ready,
  output wire [31:0]   m_axi_ar_payload_addr,
  output wire [3:0]    m_axi_ar_payload_id,
  output wire [3:0]    m_axi_ar_payload_region,
  output wire [7:0]    m_axi_ar_payload_len,
  output wire [2:0]    m_axi_ar_payload_size,
  output wire [1:0]    m_axi_ar_payload_burst,
  output wire [0:0]    m_axi_ar_payload_lock,
  output wire [3:0]    m_axi_ar_payload_cache,
  output wire [3:0]    m_axi_ar_payload_qos,
  output wire [2:0]    m_axi_ar_payload_prot,
  input  wire          m_axi_r_valid,
  output wire          m_axi_r_ready,
  input  wire [63:0]   m_axi_r_payload_data,
  input  wire [3:0]    m_axi_r_payload_id,
  input  wire [1:0]    m_axi_r_payload_resp,
  input  wire          m_axi_r_payload_last
);

  wire                cdc_io_input_ar_ready;
  wire                cdc_io_input_aw_ready;
  wire                cdc_io_input_w_ready;
  wire                cdc_io_input_r_valid;
  wire       [63:0]   cdc_io_input_r_payload_data;
  wire       [3:0]    cdc_io_input_r_payload_id;
  wire       [1:0]    cdc_io_input_r_payload_resp;
  wire                cdc_io_input_r_payload_last;
  wire                cdc_io_input_b_valid;
  wire       [3:0]    cdc_io_input_b_payload_id;
  wire       [1:0]    cdc_io_input_b_payload_resp;
  wire                cdc_io_output_ar_valid;
  wire       [31:0]   cdc_io_output_ar_payload_addr;
  wire       [3:0]    cdc_io_output_ar_payload_id;
  wire       [3:0]    cdc_io_output_ar_payload_region;
  wire       [7:0]    cdc_io_output_ar_payload_len;
  wire       [2:0]    cdc_io_output_ar_payload_size;
  wire       [1:0]    cdc_io_output_ar_payload_burst;
  wire       [0:0]    cdc_io_output_ar_payload_lock;
  wire       [3:0]    cdc_io_output_ar_payload_cache;
  wire       [3:0]    cdc_io_output_ar_payload_qos;
  wire       [2:0]    cdc_io_output_ar_payload_prot;
  wire                cdc_io_output_aw_valid;
  wire       [31:0]   cdc_io_output_aw_payload_addr;
  wire       [3:0]    cdc_io_output_aw_payload_id;
  wire       [3:0]    cdc_io_output_aw_payload_region;
  wire       [7:0]    cdc_io_output_aw_payload_len;
  wire       [2:0]    cdc_io_output_aw_payload_size;
  wire       [1:0]    cdc_io_output_aw_payload_burst;
  wire       [0:0]    cdc_io_output_aw_payload_lock;
  wire       [3:0]    cdc_io_output_aw_payload_cache;
  wire       [3:0]    cdc_io_output_aw_payload_qos;
  wire       [2:0]    cdc_io_output_aw_payload_prot;
  wire                cdc_io_output_w_valid;
  wire       [63:0]   cdc_io_output_w_payload_data;
  wire       [7:0]    cdc_io_output_w_payload_strb;
  wire                cdc_io_output_w_payload_last;
  wire                cdc_io_output_r_ready;
  wire                cdc_io_output_b_ready;

  AxiAxi4CC cdc (
    .io_input_aw_valid           (s_axi_aw_valid                      ), //i
    .io_input_aw_ready           (cdc_io_input_aw_ready               ), //o
    .io_input_aw_payload_addr    (s_axi_aw_payload_addr[31:0]         ), //i
    .io_input_aw_payload_id      (s_axi_aw_payload_id[3:0]            ), //i
    .io_input_aw_payload_region  (s_axi_aw_payload_region[3:0]        ), //i
    .io_input_aw_payload_len     (s_axi_aw_payload_len[7:0]           ), //i
    .io_input_aw_payload_size    (s_axi_aw_payload_size[2:0]          ), //i
    .io_input_aw_payload_burst   (s_axi_aw_payload_burst[1:0]         ), //i
    .io_input_aw_payload_lock    (s_axi_aw_payload_lock               ), //i
    .io_input_aw_payload_cache   (s_axi_aw_payload_cache[3:0]         ), //i
    .io_input_aw_payload_qos     (s_axi_aw_payload_qos[3:0]           ), //i
    .io_input_aw_payload_prot    (s_axi_aw_payload_prot[2:0]          ), //i
    .io_input_w_valid            (s_axi_w_valid                       ), //i
    .io_input_w_ready            (cdc_io_input_w_ready                ), //o
    .io_input_w_payload_data     (s_axi_w_payload_data[63:0]          ), //i
    .io_input_w_payload_strb     (s_axi_w_payload_strb[7:0]           ), //i
    .io_input_w_payload_last     (s_axi_w_payload_last                ), //i
    .io_input_b_valid            (cdc_io_input_b_valid                ), //o
    .io_input_b_ready            (s_axi_b_ready                       ), //i
    .io_input_b_payload_id       (cdc_io_input_b_payload_id[3:0]      ), //o
    .io_input_b_payload_resp     (cdc_io_input_b_payload_resp[1:0]    ), //o
    .io_input_ar_valid           (s_axi_ar_valid                      ), //i
    .io_input_ar_ready           (cdc_io_input_ar_ready               ), //o
    .io_input_ar_payload_addr    (s_axi_ar_payload_addr[31:0]         ), //i
    .io_input_ar_payload_id      (s_axi_ar_payload_id[3:0]            ), //i
    .io_input_ar_payload_region  (s_axi_ar_payload_region[3:0]        ), //i
    .io_input_ar_payload_len     (s_axi_ar_payload_len[7:0]           ), //i
    .io_input_ar_payload_size    (s_axi_ar_payload_size[2:0]          ), //i
    .io_input_ar_payload_burst   (s_axi_ar_payload_burst[1:0]         ), //i
    .io_input_ar_payload_lock    (s_axi_ar_payload_lock               ), //i
    .io_input_ar_payload_cache   (s_axi_ar_payload_cache[3:0]         ), //i
    .io_input_ar_payload_qos     (s_axi_ar_payload_qos[3:0]           ), //i
    .io_input_ar_payload_prot    (s_axi_ar_payload_prot[2:0]          ), //i
    .io_input_r_valid            (cdc_io_input_r_valid                ), //o
    .io_input_r_ready            (s_axi_r_ready                       ), //i
    .io_input_r_payload_data     (cdc_io_input_r_payload_data[63:0]   ), //o
    .io_input_r_payload_id       (cdc_io_input_r_payload_id[3:0]      ), //o
    .io_input_r_payload_resp     (cdc_io_input_r_payload_resp[1:0]    ), //o
    .io_input_r_payload_last     (cdc_io_input_r_payload_last         ), //o
    .io_output_aw_valid          (cdc_io_output_aw_valid              ), //o
    .io_output_aw_ready          (m_axi_aw_ready                      ), //i
    .io_output_aw_payload_addr   (cdc_io_output_aw_payload_addr[31:0] ), //o
    .io_output_aw_payload_id     (cdc_io_output_aw_payload_id[3:0]    ), //o
    .io_output_aw_payload_region (cdc_io_output_aw_payload_region[3:0]), //o
    .io_output_aw_payload_len    (cdc_io_output_aw_payload_len[7:0]   ), //o
    .io_output_aw_payload_size   (cdc_io_output_aw_payload_size[2:0]  ), //o
    .io_output_aw_payload_burst  (cdc_io_output_aw_payload_burst[1:0] ), //o
    .io_output_aw_payload_lock   (cdc_io_output_aw_payload_lock       ), //o
    .io_output_aw_payload_cache  (cdc_io_output_aw_payload_cache[3:0] ), //o
    .io_output_aw_payload_qos    (cdc_io_output_aw_payload_qos[3:0]   ), //o
    .io_output_aw_payload_prot   (cdc_io_output_aw_payload_prot[2:0]  ), //o
    .io_output_w_valid           (cdc_io_output_w_valid               ), //o
    .io_output_w_ready           (m_axi_w_ready                       ), //i
    .io_output_w_payload_data    (cdc_io_output_w_payload_data[63:0]  ), //o
    .io_output_w_payload_strb    (cdc_io_output_w_payload_strb[7:0]   ), //o
    .io_output_w_payload_last    (cdc_io_output_w_payload_last        ), //o
    .io_output_b_valid           (m_axi_b_valid                       ), //i
    .io_output_b_ready           (cdc_io_output_b_ready               ), //o
    .io_output_b_payload_id      (m_axi_b_payload_id[3:0]             ), //i
    .io_output_b_payload_resp    (m_axi_b_payload_resp[1:0]           ), //i
    .io_output_ar_valid          (cdc_io_output_ar_valid              ), //o
    .io_output_ar_ready          (m_axi_ar_ready                      ), //i
    .io_output_ar_payload_addr   (cdc_io_output_ar_payload_addr[31:0] ), //o
    .io_output_ar_payload_id     (cdc_io_output_ar_payload_id[3:0]    ), //o
    .io_output_ar_payload_region (cdc_io_output_ar_payload_region[3:0]), //o
    .io_output_ar_payload_len    (cdc_io_output_ar_payload_len[7:0]   ), //o
    .io_output_ar_payload_size   (cdc_io_output_ar_payload_size[2:0]  ), //o
    .io_output_ar_payload_burst  (cdc_io_output_ar_payload_burst[1:0] ), //o
    .io_output_ar_payload_lock   (cdc_io_output_ar_payload_lock       ), //o
    .io_output_ar_payload_cache  (cdc_io_output_ar_payload_cache[3:0] ), //o
    .io_output_ar_payload_qos    (cdc_io_output_ar_payload_qos[3:0]   ), //o
    .io_output_ar_payload_prot   (cdc_io_output_ar_payload_prot[2:0]  ), //o
    .io_output_r_valid           (m_axi_r_valid                       ), //i
    .io_output_r_ready           (cdc_io_output_r_ready               ), //o
    .io_output_r_payload_data    (m_axi_r_payload_data[63:0]          ), //i
    .io_output_r_payload_id      (m_axi_r_payload_id[3:0]             ), //i
    .io_output_r_payload_resp    (m_axi_r_payload_resp[1:0]           ), //i
    .io_output_r_payload_last    (m_axi_r_payload_last                ), //i
    .s_axi_clk                   (s_axi_clk                           ), //i
    .s_axi_rst_n                 (s_axi_rst_n                         ), //i
    .m_axi_clk                   (m_axi_clk                           ), //i
    .m_axi_rst_n                 (m_axi_rst_n                         )  //i
  );
  assign s_axi_ar_ready = cdc_io_input_ar_ready;
  assign s_axi_aw_ready = cdc_io_input_aw_ready;
  assign s_axi_w_ready = cdc_io_input_w_ready;
  assign s_axi_r_valid = cdc_io_input_r_valid;
  assign s_axi_r_payload_data = cdc_io_input_r_payload_data;
  assign s_axi_r_payload_last = cdc_io_input_r_payload_last;
  assign s_axi_r_payload_id = cdc_io_input_r_payload_id;
  assign s_axi_r_payload_resp = cdc_io_input_r_payload_resp;
  assign s_axi_b_valid = cdc_io_input_b_valid;
  assign s_axi_b_payload_id = cdc_io_input_b_payload_id;
  assign s_axi_b_payload_resp = cdc_io_input_b_payload_resp;
  assign m_axi_ar_valid = cdc_io_output_ar_valid;
  assign m_axi_ar_payload_addr = cdc_io_output_ar_payload_addr;
  assign m_axi_ar_payload_id = cdc_io_output_ar_payload_id;
  assign m_axi_ar_payload_region = cdc_io_output_ar_payload_region;
  assign m_axi_ar_payload_len = cdc_io_output_ar_payload_len;
  assign m_axi_ar_payload_size = cdc_io_output_ar_payload_size;
  assign m_axi_ar_payload_burst = cdc_io_output_ar_payload_burst;
  assign m_axi_ar_payload_lock = cdc_io_output_ar_payload_lock;
  assign m_axi_ar_payload_cache = cdc_io_output_ar_payload_cache;
  assign m_axi_ar_payload_qos = cdc_io_output_ar_payload_qos;
  assign m_axi_ar_payload_prot = cdc_io_output_ar_payload_prot;
  assign m_axi_aw_valid = cdc_io_output_aw_valid;
  assign m_axi_aw_payload_addr = cdc_io_output_aw_payload_addr;
  assign m_axi_aw_payload_id = cdc_io_output_aw_payload_id;
  assign m_axi_aw_payload_region = cdc_io_output_aw_payload_region;
  assign m_axi_aw_payload_len = cdc_io_output_aw_payload_len;
  assign m_axi_aw_payload_size = cdc_io_output_aw_payload_size;
  assign m_axi_aw_payload_burst = cdc_io_output_aw_payload_burst;
  assign m_axi_aw_payload_lock = cdc_io_output_aw_payload_lock;
  assign m_axi_aw_payload_cache = cdc_io_output_aw_payload_cache;
  assign m_axi_aw_payload_qos = cdc_io_output_aw_payload_qos;
  assign m_axi_aw_payload_prot = cdc_io_output_aw_payload_prot;
  assign m_axi_w_valid = cdc_io_output_w_valid;
  assign m_axi_w_payload_data = cdc_io_output_w_payload_data;
  assign m_axi_w_payload_strb = cdc_io_output_w_payload_strb;
  assign m_axi_w_payload_last = cdc_io_output_w_payload_last;
  assign m_axi_r_ready = cdc_io_output_r_ready;
  assign m_axi_b_ready = cdc_io_output_b_ready;

endmodule

module AxiAxi4CC (
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
  input  wire [63:0]   io_input_w_payload_data,
  input  wire [7:0]    io_input_w_payload_strb,
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
  output wire [63:0]   io_input_r_payload_data,
  output wire [3:0]    io_input_r_payload_id,
  output wire [1:0]    io_input_r_payload_resp,
  output wire          io_input_r_payload_last,
  output wire          io_output_aw_valid,
  input  wire          io_output_aw_ready,
  output wire [31:0]   io_output_aw_payload_addr,
  output wire [3:0]    io_output_aw_payload_id,
  output wire [3:0]    io_output_aw_payload_region,
  output wire [7:0]    io_output_aw_payload_len,
  output wire [2:0]    io_output_aw_payload_size,
  output wire [1:0]    io_output_aw_payload_burst,
  output wire [0:0]    io_output_aw_payload_lock,
  output wire [3:0]    io_output_aw_payload_cache,
  output wire [3:0]    io_output_aw_payload_qos,
  output wire [2:0]    io_output_aw_payload_prot,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [63:0]   io_output_w_payload_data,
  output wire [7:0]    io_output_w_payload_strb,
  output wire          io_output_w_payload_last,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [3:0]    io_output_b_payload_id,
  input  wire [1:0]    io_output_b_payload_resp,
  output wire          io_output_ar_valid,
  input  wire          io_output_ar_ready,
  output wire [31:0]   io_output_ar_payload_addr,
  output wire [3:0]    io_output_ar_payload_id,
  output wire [3:0]    io_output_ar_payload_region,
  output wire [7:0]    io_output_ar_payload_len,
  output wire [2:0]    io_output_ar_payload_size,
  output wire [1:0]    io_output_ar_payload_burst,
  output wire [0:0]    io_output_ar_payload_lock,
  output wire [3:0]    io_output_ar_payload_cache,
  output wire [3:0]    io_output_ar_payload_qos,
  output wire [2:0]    io_output_ar_payload_prot,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [63:0]   io_output_r_payload_data,
  input  wire [3:0]    io_output_r_payload_id,
  input  wire [1:0]    io_output_r_payload_resp,
  input  wire          io_output_r_payload_last,
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n,
  input  wire          m_axi_clk,
  input  wire          m_axi_rst_n
);

  wire                io_input_ar_queue_io_push_ready;
  wire                io_input_ar_queue_io_pop_valid;
  wire       [31:0]   io_input_ar_queue_io_pop_payload_addr;
  wire       [3:0]    io_input_ar_queue_io_pop_payload_id;
  wire       [3:0]    io_input_ar_queue_io_pop_payload_region;
  wire       [7:0]    io_input_ar_queue_io_pop_payload_len;
  wire       [2:0]    io_input_ar_queue_io_pop_payload_size;
  wire       [1:0]    io_input_ar_queue_io_pop_payload_burst;
  wire       [0:0]    io_input_ar_queue_io_pop_payload_lock;
  wire       [3:0]    io_input_ar_queue_io_pop_payload_cache;
  wire       [3:0]    io_input_ar_queue_io_pop_payload_qos;
  wire       [2:0]    io_input_ar_queue_io_pop_payload_prot;
  wire       [2:0]    io_input_ar_queue_io_pushOccupancy;
  wire       [2:0]    io_input_ar_queue_io_popOccupancy;
  wire                io_input_ar_queue_cdc_toplevel_s_axi_rst_n_synchronized_1;
  wire                io_output_r_queue_io_push_ready;
  wire                io_output_r_queue_io_pop_valid;
  wire       [63:0]   io_output_r_queue_io_pop_payload_data;
  wire       [3:0]    io_output_r_queue_io_pop_payload_id;
  wire       [1:0]    io_output_r_queue_io_pop_payload_resp;
  wire                io_output_r_queue_io_pop_payload_last;
  wire       [3:0]    io_output_r_queue_io_pushOccupancy;
  wire       [3:0]    io_output_r_queue_io_popOccupancy;
  wire                io_output_r_queue_cdc_toplevel_m_axi_rst_n_synchronized_1;
  wire                io_input_aw_queue_io_push_ready;
  wire                io_input_aw_queue_io_pop_valid;
  wire       [31:0]   io_input_aw_queue_io_pop_payload_addr;
  wire       [3:0]    io_input_aw_queue_io_pop_payload_id;
  wire       [3:0]    io_input_aw_queue_io_pop_payload_region;
  wire       [7:0]    io_input_aw_queue_io_pop_payload_len;
  wire       [2:0]    io_input_aw_queue_io_pop_payload_size;
  wire       [1:0]    io_input_aw_queue_io_pop_payload_burst;
  wire       [0:0]    io_input_aw_queue_io_pop_payload_lock;
  wire       [3:0]    io_input_aw_queue_io_pop_payload_cache;
  wire       [3:0]    io_input_aw_queue_io_pop_payload_qos;
  wire       [2:0]    io_input_aw_queue_io_pop_payload_prot;
  wire       [2:0]    io_input_aw_queue_io_pushOccupancy;
  wire       [2:0]    io_input_aw_queue_io_popOccupancy;
  wire                io_input_w_queue_io_push_ready;
  wire                io_input_w_queue_io_pop_valid;
  wire       [63:0]   io_input_w_queue_io_pop_payload_data;
  wire       [7:0]    io_input_w_queue_io_pop_payload_strb;
  wire                io_input_w_queue_io_pop_payload_last;
  wire       [3:0]    io_input_w_queue_io_pushOccupancy;
  wire       [3:0]    io_input_w_queue_io_popOccupancy;
  wire                io_output_b_queue_io_push_ready;
  wire                io_output_b_queue_io_pop_valid;
  wire       [3:0]    io_output_b_queue_io_pop_payload_id;
  wire       [1:0]    io_output_b_queue_io_pop_payload_resp;
  wire       [2:0]    io_output_b_queue_io_pushOccupancy;
  wire       [2:0]    io_output_b_queue_io_popOccupancy;

  AxiStreamFifoCC io_input_ar_queue (
    .io_push_valid                           (io_input_ar_valid                                        ), //i
    .io_push_ready                           (io_input_ar_queue_io_push_ready                          ), //o
    .io_push_payload_addr                    (io_input_ar_payload_addr[31:0]                           ), //i
    .io_push_payload_id                      (io_input_ar_payload_id[3:0]                              ), //i
    .io_push_payload_region                  (io_input_ar_payload_region[3:0]                          ), //i
    .io_push_payload_len                     (io_input_ar_payload_len[7:0]                             ), //i
    .io_push_payload_size                    (io_input_ar_payload_size[2:0]                            ), //i
    .io_push_payload_burst                   (io_input_ar_payload_burst[1:0]                           ), //i
    .io_push_payload_lock                    (io_input_ar_payload_lock                                 ), //i
    .io_push_payload_cache                   (io_input_ar_payload_cache[3:0]                           ), //i
    .io_push_payload_qos                     (io_input_ar_payload_qos[3:0]                             ), //i
    .io_push_payload_prot                    (io_input_ar_payload_prot[2:0]                            ), //i
    .io_pop_valid                            (io_input_ar_queue_io_pop_valid                           ), //o
    .io_pop_ready                            (io_output_ar_ready                                       ), //i
    .io_pop_payload_addr                     (io_input_ar_queue_io_pop_payload_addr[31:0]              ), //o
    .io_pop_payload_id                       (io_input_ar_queue_io_pop_payload_id[3:0]                 ), //o
    .io_pop_payload_region                   (io_input_ar_queue_io_pop_payload_region[3:0]             ), //o
    .io_pop_payload_len                      (io_input_ar_queue_io_pop_payload_len[7:0]                ), //o
    .io_pop_payload_size                     (io_input_ar_queue_io_pop_payload_size[2:0]               ), //o
    .io_pop_payload_burst                    (io_input_ar_queue_io_pop_payload_burst[1:0]              ), //o
    .io_pop_payload_lock                     (io_input_ar_queue_io_pop_payload_lock                    ), //o
    .io_pop_payload_cache                    (io_input_ar_queue_io_pop_payload_cache[3:0]              ), //o
    .io_pop_payload_qos                      (io_input_ar_queue_io_pop_payload_qos[3:0]                ), //o
    .io_pop_payload_prot                     (io_input_ar_queue_io_pop_payload_prot[2:0]               ), //o
    .io_pushOccupancy                        (io_input_ar_queue_io_pushOccupancy[2:0]                  ), //o
    .io_popOccupancy                         (io_input_ar_queue_io_popOccupancy[2:0]                   ), //o
    .s_axi_clk                               (s_axi_clk                                                ), //i
    .s_axi_rst_n                             (s_axi_rst_n                                              ), //i
    .m_axi_clk                               (m_axi_clk                                                ), //i
    .cdc_toplevel_s_axi_rst_n_synchronized_1 (io_input_ar_queue_cdc_toplevel_s_axi_rst_n_synchronized_1)  //o
  );
  AxiStreamFifoCC_1 io_output_r_queue (
    .io_push_valid                           (io_output_r_valid                                        ), //i
    .io_push_ready                           (io_output_r_queue_io_push_ready                          ), //o
    .io_push_payload_data                    (io_output_r_payload_data[63:0]                           ), //i
    .io_push_payload_id                      (io_output_r_payload_id[3:0]                              ), //i
    .io_push_payload_resp                    (io_output_r_payload_resp[1:0]                            ), //i
    .io_push_payload_last                    (io_output_r_payload_last                                 ), //i
    .io_pop_valid                            (io_output_r_queue_io_pop_valid                           ), //o
    .io_pop_ready                            (io_input_r_ready                                         ), //i
    .io_pop_payload_data                     (io_output_r_queue_io_pop_payload_data[63:0]              ), //o
    .io_pop_payload_id                       (io_output_r_queue_io_pop_payload_id[3:0]                 ), //o
    .io_pop_payload_resp                     (io_output_r_queue_io_pop_payload_resp[1:0]               ), //o
    .io_pop_payload_last                     (io_output_r_queue_io_pop_payload_last                    ), //o
    .io_pushOccupancy                        (io_output_r_queue_io_pushOccupancy[3:0]                  ), //o
    .io_popOccupancy                         (io_output_r_queue_io_popOccupancy[3:0]                   ), //o
    .m_axi_clk                               (m_axi_clk                                                ), //i
    .m_axi_rst_n                             (m_axi_rst_n                                              ), //i
    .s_axi_clk                               (s_axi_clk                                                ), //i
    .cdc_toplevel_m_axi_rst_n_synchronized_1 (io_output_r_queue_cdc_toplevel_m_axi_rst_n_synchronized_1)  //o
  );
  AxiStreamFifoCC_2 io_input_aw_queue (
    .io_push_valid                           (io_input_aw_valid                                        ), //i
    .io_push_ready                           (io_input_aw_queue_io_push_ready                          ), //o
    .io_push_payload_addr                    (io_input_aw_payload_addr[31:0]                           ), //i
    .io_push_payload_id                      (io_input_aw_payload_id[3:0]                              ), //i
    .io_push_payload_region                  (io_input_aw_payload_region[3:0]                          ), //i
    .io_push_payload_len                     (io_input_aw_payload_len[7:0]                             ), //i
    .io_push_payload_size                    (io_input_aw_payload_size[2:0]                            ), //i
    .io_push_payload_burst                   (io_input_aw_payload_burst[1:0]                           ), //i
    .io_push_payload_lock                    (io_input_aw_payload_lock                                 ), //i
    .io_push_payload_cache                   (io_input_aw_payload_cache[3:0]                           ), //i
    .io_push_payload_qos                     (io_input_aw_payload_qos[3:0]                             ), //i
    .io_push_payload_prot                    (io_input_aw_payload_prot[2:0]                            ), //i
    .io_pop_valid                            (io_input_aw_queue_io_pop_valid                           ), //o
    .io_pop_ready                            (io_output_aw_ready                                       ), //i
    .io_pop_payload_addr                     (io_input_aw_queue_io_pop_payload_addr[31:0]              ), //o
    .io_pop_payload_id                       (io_input_aw_queue_io_pop_payload_id[3:0]                 ), //o
    .io_pop_payload_region                   (io_input_aw_queue_io_pop_payload_region[3:0]             ), //o
    .io_pop_payload_len                      (io_input_aw_queue_io_pop_payload_len[7:0]                ), //o
    .io_pop_payload_size                     (io_input_aw_queue_io_pop_payload_size[2:0]               ), //o
    .io_pop_payload_burst                    (io_input_aw_queue_io_pop_payload_burst[1:0]              ), //o
    .io_pop_payload_lock                     (io_input_aw_queue_io_pop_payload_lock                    ), //o
    .io_pop_payload_cache                    (io_input_aw_queue_io_pop_payload_cache[3:0]              ), //o
    .io_pop_payload_qos                      (io_input_aw_queue_io_pop_payload_qos[3:0]                ), //o
    .io_pop_payload_prot                     (io_input_aw_queue_io_pop_payload_prot[2:0]               ), //o
    .io_pushOccupancy                        (io_input_aw_queue_io_pushOccupancy[2:0]                  ), //o
    .io_popOccupancy                         (io_input_aw_queue_io_popOccupancy[2:0]                   ), //o
    .s_axi_clk                               (s_axi_clk                                                ), //i
    .s_axi_rst_n                             (s_axi_rst_n                                              ), //i
    .m_axi_clk                               (m_axi_clk                                                ), //i
    .cdc_toplevel_s_axi_rst_n_synchronized_1 (io_input_ar_queue_cdc_toplevel_s_axi_rst_n_synchronized_1)  //i
  );
  AxiStreamFifoCC_3 io_input_w_queue (
    .io_push_valid                           (io_input_w_valid                                         ), //i
    .io_push_ready                           (io_input_w_queue_io_push_ready                           ), //o
    .io_push_payload_data                    (io_input_w_payload_data[63:0]                            ), //i
    .io_push_payload_strb                    (io_input_w_payload_strb[7:0]                             ), //i
    .io_push_payload_last                    (io_input_w_payload_last                                  ), //i
    .io_pop_valid                            (io_input_w_queue_io_pop_valid                            ), //o
    .io_pop_ready                            (io_output_w_ready                                        ), //i
    .io_pop_payload_data                     (io_input_w_queue_io_pop_payload_data[63:0]               ), //o
    .io_pop_payload_strb                     (io_input_w_queue_io_pop_payload_strb[7:0]                ), //o
    .io_pop_payload_last                     (io_input_w_queue_io_pop_payload_last                     ), //o
    .io_pushOccupancy                        (io_input_w_queue_io_pushOccupancy[3:0]                   ), //o
    .io_popOccupancy                         (io_input_w_queue_io_popOccupancy[3:0]                    ), //o
    .s_axi_clk                               (s_axi_clk                                                ), //i
    .s_axi_rst_n                             (s_axi_rst_n                                              ), //i
    .m_axi_clk                               (m_axi_clk                                                ), //i
    .cdc_toplevel_s_axi_rst_n_synchronized_1 (io_input_ar_queue_cdc_toplevel_s_axi_rst_n_synchronized_1)  //i
  );
  AxiStreamFifoCC_4 io_output_b_queue (
    .io_push_valid                           (io_output_b_valid                                        ), //i
    .io_push_ready                           (io_output_b_queue_io_push_ready                          ), //o
    .io_push_payload_id                      (io_output_b_payload_id[3:0]                              ), //i
    .io_push_payload_resp                    (io_output_b_payload_resp[1:0]                            ), //i
    .io_pop_valid                            (io_output_b_queue_io_pop_valid                           ), //o
    .io_pop_ready                            (io_input_b_ready                                         ), //i
    .io_pop_payload_id                       (io_output_b_queue_io_pop_payload_id[3:0]                 ), //o
    .io_pop_payload_resp                     (io_output_b_queue_io_pop_payload_resp[1:0]               ), //o
    .io_pushOccupancy                        (io_output_b_queue_io_pushOccupancy[2:0]                  ), //o
    .io_popOccupancy                         (io_output_b_queue_io_popOccupancy[2:0]                   ), //o
    .m_axi_clk                               (m_axi_clk                                                ), //i
    .m_axi_rst_n                             (m_axi_rst_n                                              ), //i
    .s_axi_clk                               (s_axi_clk                                                ), //i
    .cdc_toplevel_m_axi_rst_n_synchronized_1 (io_output_r_queue_cdc_toplevel_m_axi_rst_n_synchronized_1)  //i
  );
  assign io_input_ar_ready = io_input_ar_queue_io_push_ready;
  assign io_output_ar_valid = io_input_ar_queue_io_pop_valid;
  assign io_output_ar_payload_addr = io_input_ar_queue_io_pop_payload_addr;
  assign io_output_ar_payload_id = io_input_ar_queue_io_pop_payload_id;
  assign io_output_ar_payload_region = io_input_ar_queue_io_pop_payload_region;
  assign io_output_ar_payload_len = io_input_ar_queue_io_pop_payload_len;
  assign io_output_ar_payload_size = io_input_ar_queue_io_pop_payload_size;
  assign io_output_ar_payload_burst = io_input_ar_queue_io_pop_payload_burst;
  assign io_output_ar_payload_lock = io_input_ar_queue_io_pop_payload_lock;
  assign io_output_ar_payload_cache = io_input_ar_queue_io_pop_payload_cache;
  assign io_output_ar_payload_qos = io_input_ar_queue_io_pop_payload_qos;
  assign io_output_ar_payload_prot = io_input_ar_queue_io_pop_payload_prot;
  assign io_output_r_ready = io_output_r_queue_io_push_ready;
  assign io_input_r_valid = io_output_r_queue_io_pop_valid;
  assign io_input_r_payload_data = io_output_r_queue_io_pop_payload_data;
  assign io_input_r_payload_id = io_output_r_queue_io_pop_payload_id;
  assign io_input_r_payload_resp = io_output_r_queue_io_pop_payload_resp;
  assign io_input_r_payload_last = io_output_r_queue_io_pop_payload_last;
  assign io_input_aw_ready = io_input_aw_queue_io_push_ready;
  assign io_output_aw_valid = io_input_aw_queue_io_pop_valid;
  assign io_output_aw_payload_addr = io_input_aw_queue_io_pop_payload_addr;
  assign io_output_aw_payload_id = io_input_aw_queue_io_pop_payload_id;
  assign io_output_aw_payload_region = io_input_aw_queue_io_pop_payload_region;
  assign io_output_aw_payload_len = io_input_aw_queue_io_pop_payload_len;
  assign io_output_aw_payload_size = io_input_aw_queue_io_pop_payload_size;
  assign io_output_aw_payload_burst = io_input_aw_queue_io_pop_payload_burst;
  assign io_output_aw_payload_lock = io_input_aw_queue_io_pop_payload_lock;
  assign io_output_aw_payload_cache = io_input_aw_queue_io_pop_payload_cache;
  assign io_output_aw_payload_qos = io_input_aw_queue_io_pop_payload_qos;
  assign io_output_aw_payload_prot = io_input_aw_queue_io_pop_payload_prot;
  assign io_input_w_ready = io_input_w_queue_io_push_ready;
  assign io_output_w_valid = io_input_w_queue_io_pop_valid;
  assign io_output_w_payload_data = io_input_w_queue_io_pop_payload_data;
  assign io_output_w_payload_strb = io_input_w_queue_io_pop_payload_strb;
  assign io_output_w_payload_last = io_input_w_queue_io_pop_payload_last;
  assign io_output_b_ready = io_output_b_queue_io_push_ready;
  assign io_input_b_valid = io_output_b_queue_io_pop_valid;
  assign io_input_b_payload_id = io_output_b_queue_io_pop_payload_id;
  assign io_input_b_payload_resp = io_output_b_queue_io_pop_payload_resp;

endmodule

module AxiStreamFifoCC_4 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [3:0]    io_push_payload_id,
  input  wire [1:0]    io_push_payload_resp,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [3:0]    io_pop_payload_id,
  output wire [1:0]    io_pop_payload_resp,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          m_axi_clk,
  input  wire          m_axi_rst_n,
  input  wire          s_axi_clk,
  input  wire          cdc_toplevel_m_axi_rst_n_synchronized_1
);

  reg        [5:0]    ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [5:0]    _zz_ram_port_1;
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
  wire       [3:0]    popCC_readPort_rsp_id;
  wire       [1:0]    popCC_readPort_rsp_resp;
  wire       [5:0]    _zz_popCC_readPort_rsp_id;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [3:0]    popCC_readArbitation_translated_payload_id;
  wire       [1:0]    popCC_readArbitation_translated_payload_resp;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  reg [5:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_resp,io_push_payload_id};
  always @(posedge m_axi_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge s_axi_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxiBufferCC_10 popToPushGray_buffercc (
    .io_dataIn   (popToPushGray[2:0]                    ), //i
    .io_dataOut  (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .m_axi_clk   (m_axi_clk                             ), //i
    .m_axi_rst_n (m_axi_rst_n                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_11 pushToPopGray_buffercc (
    .io_dataIn                               (pushToPopGray[2:0]                     ), //i
    .io_dataOut                              (pushToPopGray_buffercc_io_dataOut[2:0] ), //o
    .s_axi_clk                               (s_axi_clk                              ), //i
    .cdc_toplevel_m_axi_rst_n_synchronized_1 (cdc_toplevel_m_axi_rst_n_synchronized_1)  //i
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
  assign _zz_popCC_readPort_rsp_id = ram_spinal_port1;
  assign popCC_readPort_rsp_id = _zz_popCC_readPort_rsp_id[3 : 0];
  assign popCC_readPort_rsp_resp = _zz_popCC_readPort_rsp_id[5 : 4];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_id = popCC_readPort_rsp_id;
  assign popCC_readArbitation_translated_payload_resp = popCC_readPort_rsp_resp;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_id = popCC_readArbitation_translated_payload_id;
  assign io_pop_payload_resp = popCC_readArbitation_translated_payload_resp;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge m_axi_clk) begin
    if(!m_axi_rst_n) begin
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

  always @(posedge s_axi_clk) begin
    if(!cdc_toplevel_m_axi_rst_n_synchronized_1) begin
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

  always @(posedge s_axi_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxiStreamFifoCC_3 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [63:0]   io_push_payload_data,
  input  wire [7:0]    io_push_payload_strb,
  input  wire          io_push_payload_last,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [63:0]   io_pop_payload_data,
  output wire [7:0]    io_pop_payload_strb,
  output wire          io_pop_payload_last,
  output wire [3:0]    io_pushOccupancy,
  output wire [3:0]    io_popOccupancy,
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n,
  input  wire          m_axi_clk,
  input  wire          cdc_toplevel_s_axi_rst_n_synchronized_1
);

  reg        [72:0]   ram_spinal_port1;
  wire       [3:0]    popToPushGray_buffercc_io_dataOut;
  wire       [3:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [3:0]    _zz_pushCC_pushPtrGray;
  wire       [2:0]    _zz_ram_port;
  wire       [72:0]   _zz_ram_port_1;
  wire       [3:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [3:0]    popToPushGray;
  wire       [3:0]    pushToPopGray;
  reg        [3:0]    pushCC_pushPtr;
  wire       [3:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    pushCC_pushPtrGray;
  wire       [3:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  wire                _zz_io_pushOccupancy_2;
  reg        [3:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [3:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [3:0]    popCC_popPtrGray;
  wire       [3:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [2:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [2:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [2:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [2:0]    popCC_readPort_cmd_payload;
  wire       [63:0]   popCC_readPort_rsp_data;
  wire       [7:0]    popCC_readPort_rsp_strb;
  wire                popCC_readPort_rsp_last;
  wire       [72:0]   _zz_popCC_readPort_rsp_data;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [2:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [63:0]   popCC_readArbitation_translated_payload_data;
  wire       [7:0]    popCC_readArbitation_translated_payload_strb;
  wire                popCC_readArbitation_translated_payload_last;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    popCC_ptrToPush;
  reg        [3:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  wire                _zz_io_popOccupancy_2;
  reg [72:0] ram [0:7];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[2:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_last,{io_push_payload_strb,io_push_payload_data}};
  always @(posedge s_axi_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge m_axi_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxiBufferCC_8 popToPushGray_buffercc (
    .io_dataIn   (popToPushGray[3:0]                    ), //i
    .io_dataOut  (popToPushGray_buffercc_io_dataOut[3:0]), //o
    .s_axi_clk   (s_axi_clk                             ), //i
    .s_axi_rst_n (s_axi_rst_n                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_9 pushToPopGray_buffercc (
    .io_dataIn                               (pushToPopGray[3:0]                     ), //i
    .io_dataOut                              (pushToPopGray_buffercc_io_dataOut[3:0] ), //o
    .m_axi_clk                               (m_axi_clk                              ), //i
    .cdc_toplevel_s_axi_rst_n_synchronized_1 (cdc_toplevel_s_axi_rst_n_synchronized_1)  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 4'b0001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[3 : 2] == (~ pushCC_popPtrGray[3 : 2])) && (pushCC_pushPtrGray[1 : 0] == pushCC_popPtrGray[1 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = (pushCC_popPtrGray[2] ^ _zz_io_pushOccupancy_2);
  assign _zz_io_pushOccupancy_2 = pushCC_popPtrGray[3];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_2,{_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}}});
  assign popCC_popPtrPlus = (popCC_popPtr + 4'b0001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[2:0];
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
  assign popCC_readPort_rsp_data = _zz_popCC_readPort_rsp_data[63 : 0];
  assign popCC_readPort_rsp_strb = _zz_popCC_readPort_rsp_data[71 : 64];
  assign popCC_readPort_rsp_last = _zz_popCC_readPort_rsp_data[72];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_data = popCC_readPort_rsp_data;
  assign popCC_readArbitation_translated_payload_strb = popCC_readPort_rsp_strb;
  assign popCC_readArbitation_translated_payload_last = popCC_readPort_rsp_last;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = popCC_readArbitation_translated_payload_data;
  assign io_pop_payload_strb = popCC_readArbitation_translated_payload_strb;
  assign io_pop_payload_last = popCC_readArbitation_translated_payload_last;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = (popCC_pushPtrGray[2] ^ _zz_io_popOccupancy_2);
  assign _zz_io_popOccupancy_2 = popCC_pushPtrGray[3];
  assign io_popOccupancy = ({_zz_io_popOccupancy_2,{_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge s_axi_clk) begin
    if(!s_axi_rst_n) begin
      pushCC_pushPtr <= 4'b0000;
      pushCC_pushPtrGray <= 4'b0000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge m_axi_clk) begin
    if(!cdc_toplevel_s_axi_rst_n_synchronized_1) begin
      popCC_popPtr <= 4'b0000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 4'b0000;
      popCC_ptrToOccupancy <= 4'b0000;
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

  always @(posedge m_axi_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxiStreamFifoCC_2 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_addr,
  input  wire [3:0]    io_push_payload_id,
  input  wire [3:0]    io_push_payload_region,
  input  wire [7:0]    io_push_payload_len,
  input  wire [2:0]    io_push_payload_size,
  input  wire [1:0]    io_push_payload_burst,
  input  wire [0:0]    io_push_payload_lock,
  input  wire [3:0]    io_push_payload_cache,
  input  wire [3:0]    io_push_payload_qos,
  input  wire [2:0]    io_push_payload_prot,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_addr,
  output wire [3:0]    io_pop_payload_id,
  output wire [3:0]    io_pop_payload_region,
  output wire [7:0]    io_pop_payload_len,
  output wire [2:0]    io_pop_payload_size,
  output wire [1:0]    io_pop_payload_burst,
  output wire [0:0]    io_pop_payload_lock,
  output wire [3:0]    io_pop_payload_cache,
  output wire [3:0]    io_pop_payload_qos,
  output wire [2:0]    io_pop_payload_prot,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n,
  input  wire          m_axi_clk,
  input  wire          cdc_toplevel_s_axi_rst_n_synchronized_1
);

  reg        [64:0]   ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [64:0]   _zz_ram_port_1;
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
  wire       [3:0]    popCC_readPort_rsp_id;
  wire       [3:0]    popCC_readPort_rsp_region;
  wire       [7:0]    popCC_readPort_rsp_len;
  wire       [2:0]    popCC_readPort_rsp_size;
  wire       [1:0]    popCC_readPort_rsp_burst;
  wire       [0:0]    popCC_readPort_rsp_lock;
  wire       [3:0]    popCC_readPort_rsp_cache;
  wire       [3:0]    popCC_readPort_rsp_qos;
  wire       [2:0]    popCC_readPort_rsp_prot;
  wire       [64:0]   _zz_popCC_readPort_rsp_addr;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_addr;
  wire       [3:0]    popCC_readArbitation_translated_payload_id;
  wire       [3:0]    popCC_readArbitation_translated_payload_region;
  wire       [7:0]    popCC_readArbitation_translated_payload_len;
  wire       [2:0]    popCC_readArbitation_translated_payload_size;
  wire       [1:0]    popCC_readArbitation_translated_payload_burst;
  wire       [0:0]    popCC_readArbitation_translated_payload_lock;
  wire       [3:0]    popCC_readArbitation_translated_payload_cache;
  wire       [3:0]    popCC_readArbitation_translated_payload_qos;
  wire       [2:0]    popCC_readArbitation_translated_payload_prot;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  reg [64:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_prot,{io_push_payload_qos,{io_push_payload_cache,{io_push_payload_lock,{io_push_payload_burst,{io_push_payload_size,{io_push_payload_len,{io_push_payload_region,{io_push_payload_id,io_push_payload_addr}}}}}}}}};
  always @(posedge s_axi_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge m_axi_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxiBufferCC popToPushGray_buffercc (
    .io_dataIn   (popToPushGray[2:0]                    ), //i
    .io_dataOut  (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .s_axi_clk   (s_axi_clk                             ), //i
    .s_axi_rst_n (s_axi_rst_n                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_7 pushToPopGray_buffercc (
    .io_dataIn                               (pushToPopGray[2:0]                     ), //i
    .io_dataOut                              (pushToPopGray_buffercc_io_dataOut[2:0] ), //o
    .m_axi_clk                               (m_axi_clk                              ), //i
    .cdc_toplevel_s_axi_rst_n_synchronized_1 (cdc_toplevel_s_axi_rst_n_synchronized_1)  //i
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
  assign popCC_readPort_rsp_id = _zz_popCC_readPort_rsp_addr[35 : 32];
  assign popCC_readPort_rsp_region = _zz_popCC_readPort_rsp_addr[39 : 36];
  assign popCC_readPort_rsp_len = _zz_popCC_readPort_rsp_addr[47 : 40];
  assign popCC_readPort_rsp_size = _zz_popCC_readPort_rsp_addr[50 : 48];
  assign popCC_readPort_rsp_burst = _zz_popCC_readPort_rsp_addr[52 : 51];
  assign popCC_readPort_rsp_lock = _zz_popCC_readPort_rsp_addr[53 : 53];
  assign popCC_readPort_rsp_cache = _zz_popCC_readPort_rsp_addr[57 : 54];
  assign popCC_readPort_rsp_qos = _zz_popCC_readPort_rsp_addr[61 : 58];
  assign popCC_readPort_rsp_prot = _zz_popCC_readPort_rsp_addr[64 : 62];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_addr = popCC_readPort_rsp_addr;
  assign popCC_readArbitation_translated_payload_id = popCC_readPort_rsp_id;
  assign popCC_readArbitation_translated_payload_region = popCC_readPort_rsp_region;
  assign popCC_readArbitation_translated_payload_len = popCC_readPort_rsp_len;
  assign popCC_readArbitation_translated_payload_size = popCC_readPort_rsp_size;
  assign popCC_readArbitation_translated_payload_burst = popCC_readPort_rsp_burst;
  assign popCC_readArbitation_translated_payload_lock = popCC_readPort_rsp_lock;
  assign popCC_readArbitation_translated_payload_cache = popCC_readPort_rsp_cache;
  assign popCC_readArbitation_translated_payload_qos = popCC_readPort_rsp_qos;
  assign popCC_readArbitation_translated_payload_prot = popCC_readPort_rsp_prot;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_addr = popCC_readArbitation_translated_payload_addr;
  assign io_pop_payload_id = popCC_readArbitation_translated_payload_id;
  assign io_pop_payload_region = popCC_readArbitation_translated_payload_region;
  assign io_pop_payload_len = popCC_readArbitation_translated_payload_len;
  assign io_pop_payload_size = popCC_readArbitation_translated_payload_size;
  assign io_pop_payload_burst = popCC_readArbitation_translated_payload_burst;
  assign io_pop_payload_lock = popCC_readArbitation_translated_payload_lock;
  assign io_pop_payload_cache = popCC_readArbitation_translated_payload_cache;
  assign io_pop_payload_qos = popCC_readArbitation_translated_payload_qos;
  assign io_pop_payload_prot = popCC_readArbitation_translated_payload_prot;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge s_axi_clk) begin
    if(!s_axi_rst_n) begin
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

  always @(posedge m_axi_clk) begin
    if(!cdc_toplevel_s_axi_rst_n_synchronized_1) begin
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

  always @(posedge m_axi_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxiStreamFifoCC_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [63:0]   io_push_payload_data,
  input  wire [3:0]    io_push_payload_id,
  input  wire [1:0]    io_push_payload_resp,
  input  wire          io_push_payload_last,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [63:0]   io_pop_payload_data,
  output wire [3:0]    io_pop_payload_id,
  output wire [1:0]    io_pop_payload_resp,
  output wire          io_pop_payload_last,
  output wire [3:0]    io_pushOccupancy,
  output wire [3:0]    io_popOccupancy,
  input  wire          m_axi_clk,
  input  wire          m_axi_rst_n,
  input  wire          s_axi_clk,
  output wire          cdc_toplevel_m_axi_rst_n_synchronized_1
);

  reg        [70:0]   ram_spinal_port1;
  wire       [3:0]    popToPushGray_buffercc_io_dataOut;
  wire                cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  wire       [3:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [3:0]    _zz_pushCC_pushPtrGray;
  wire       [2:0]    _zz_ram_port;
  wire       [70:0]   _zz_ram_port_1;
  wire       [3:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [3:0]    popToPushGray;
  wire       [3:0]    pushToPopGray;
  reg        [3:0]    pushCC_pushPtr;
  wire       [3:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    pushCC_pushPtrGray;
  wire       [3:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  wire                _zz_io_pushOccupancy_2;
  wire                cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert;
  wire                cdc_toplevel_m_axi_rst_n_synchronized;
  reg        [3:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [3:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [3:0]    popCC_popPtrGray;
  wire       [3:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [2:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [2:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [2:0]    popCC_addressGen_rData;
  wire                when_Stream_l399;
  wire                popCC_readPort_cmd_valid;
  wire       [2:0]    popCC_readPort_cmd_payload;
  wire       [63:0]   popCC_readPort_rsp_data;
  wire       [3:0]    popCC_readPort_rsp_id;
  wire       [1:0]    popCC_readPort_rsp_resp;
  wire                popCC_readPort_rsp_last;
  wire       [70:0]   _zz_popCC_readPort_rsp_data;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [2:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [63:0]   popCC_readArbitation_translated_payload_data;
  wire       [3:0]    popCC_readArbitation_translated_payload_id;
  wire       [1:0]    popCC_readArbitation_translated_payload_resp;
  wire                popCC_readArbitation_translated_payload_last;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    popCC_ptrToPush;
  reg        [3:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  wire                _zz_io_popOccupancy_2;
  reg [70:0] ram [0:7];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[2:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_last,{io_push_payload_resp,{io_push_payload_id,io_push_payload_data}}};
  always @(posedge m_axi_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge s_axi_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxiBufferCC_3 popToPushGray_buffercc (
    .io_dataIn   (popToPushGray[3:0]                    ), //i
    .io_dataOut  (popToPushGray_buffercc_io_dataOut[3:0]), //o
    .m_axi_clk   (m_axi_clk                             ), //i
    .m_axi_rst_n (m_axi_rst_n                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_4 cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert_buffercc (
    .io_dataIn   (cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert                    ), //i
    .io_dataOut  (cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut), //o
    .s_axi_clk   (s_axi_clk                                                           ), //i
    .m_axi_rst_n (m_axi_rst_n                                                         )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_5 pushToPopGray_buffercc (
    .io_dataIn                             (pushToPopGray[3:0]                    ), //i
    .io_dataOut                            (pushToPopGray_buffercc_io_dataOut[3:0]), //o
    .s_axi_clk                             (s_axi_clk                             ), //i
    .cdc_toplevel_m_axi_rst_n_synchronized (cdc_toplevel_m_axi_rst_n_synchronized )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 4'b0001);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[3 : 2] == (~ pushCC_popPtrGray[3 : 2])) && (pushCC_pushPtrGray[1 : 0] == pushCC_popPtrGray[1 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = (pushCC_popPtrGray[2] ^ _zz_io_pushOccupancy_2);
  assign _zz_io_pushOccupancy_2 = pushCC_popPtrGray[3];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_2,{_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}}});
  assign cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert = (1'b1 ^ 1'b0);
  assign cdc_toplevel_m_axi_rst_n_synchronized = cdc_toplevel_m_axi_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  assign popCC_popPtrPlus = (popCC_popPtr + 4'b0001);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[2:0];
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
  assign popCC_readPort_rsp_data = _zz_popCC_readPort_rsp_data[63 : 0];
  assign popCC_readPort_rsp_id = _zz_popCC_readPort_rsp_data[67 : 64];
  assign popCC_readPort_rsp_resp = _zz_popCC_readPort_rsp_data[69 : 68];
  assign popCC_readPort_rsp_last = _zz_popCC_readPort_rsp_data[70];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_data = popCC_readPort_rsp_data;
  assign popCC_readArbitation_translated_payload_id = popCC_readPort_rsp_id;
  assign popCC_readArbitation_translated_payload_resp = popCC_readPort_rsp_resp;
  assign popCC_readArbitation_translated_payload_last = popCC_readPort_rsp_last;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = popCC_readArbitation_translated_payload_data;
  assign io_pop_payload_id = popCC_readArbitation_translated_payload_id;
  assign io_pop_payload_resp = popCC_readArbitation_translated_payload_resp;
  assign io_pop_payload_last = popCC_readArbitation_translated_payload_last;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = (popCC_pushPtrGray[2] ^ _zz_io_popOccupancy_2);
  assign _zz_io_popOccupancy_2 = popCC_pushPtrGray[3];
  assign io_popOccupancy = ({_zz_io_popOccupancy_2,{_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  assign cdc_toplevel_m_axi_rst_n_synchronized_1 = cdc_toplevel_m_axi_rst_n_synchronized;
  always @(posedge m_axi_clk) begin
    if(!m_axi_rst_n) begin
      pushCC_pushPtr <= 4'b0000;
      pushCC_pushPtrGray <= 4'b0000;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge s_axi_clk) begin
    if(!cdc_toplevel_m_axi_rst_n_synchronized) begin
      popCC_popPtr <= 4'b0000;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 4'b0000;
      popCC_ptrToOccupancy <= 4'b0000;
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

  always @(posedge s_axi_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxiStreamFifoCC (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_addr,
  input  wire [3:0]    io_push_payload_id,
  input  wire [3:0]    io_push_payload_region,
  input  wire [7:0]    io_push_payload_len,
  input  wire [2:0]    io_push_payload_size,
  input  wire [1:0]    io_push_payload_burst,
  input  wire [0:0]    io_push_payload_lock,
  input  wire [3:0]    io_push_payload_cache,
  input  wire [3:0]    io_push_payload_qos,
  input  wire [2:0]    io_push_payload_prot,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_addr,
  output wire [3:0]    io_pop_payload_id,
  output wire [3:0]    io_pop_payload_region,
  output wire [7:0]    io_pop_payload_len,
  output wire [2:0]    io_pop_payload_size,
  output wire [1:0]    io_pop_payload_burst,
  output wire [0:0]    io_pop_payload_lock,
  output wire [3:0]    io_pop_payload_cache,
  output wire [3:0]    io_pop_payload_qos,
  output wire [2:0]    io_pop_payload_prot,
  output wire [2:0]    io_pushOccupancy,
  output wire [2:0]    io_popOccupancy,
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n,
  input  wire          m_axi_clk,
  output wire          cdc_toplevel_s_axi_rst_n_synchronized_1
);

  reg        [64:0]   ram_spinal_port1;
  wire       [2:0]    popToPushGray_buffercc_io_dataOut;
  wire                cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
  wire       [2:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [2:0]    _zz_pushCC_pushPtrGray;
  wire       [1:0]    _zz_ram_port;
  wire       [64:0]   _zz_ram_port_1;
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
  wire                cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert;
  wire                cdc_toplevel_s_axi_rst_n_synchronized;
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
  wire       [3:0]    popCC_readPort_rsp_id;
  wire       [3:0]    popCC_readPort_rsp_region;
  wire       [7:0]    popCC_readPort_rsp_len;
  wire       [2:0]    popCC_readPort_rsp_size;
  wire       [1:0]    popCC_readPort_rsp_burst;
  wire       [0:0]    popCC_readPort_rsp_lock;
  wire       [3:0]    popCC_readPort_rsp_cache;
  wire       [3:0]    popCC_readPort_rsp_qos;
  wire       [2:0]    popCC_readPort_rsp_prot;
  wire       [64:0]   _zz_popCC_readPort_rsp_addr;
  wire                popCC_addressGen_toFlowFire_valid;
  wire       [1:0]    popCC_addressGen_toFlowFire_payload;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_addr;
  wire       [3:0]    popCC_readArbitation_translated_payload_id;
  wire       [3:0]    popCC_readArbitation_translated_payload_region;
  wire       [7:0]    popCC_readArbitation_translated_payload_len;
  wire       [2:0]    popCC_readArbitation_translated_payload_size;
  wire       [1:0]    popCC_readArbitation_translated_payload_burst;
  wire       [0:0]    popCC_readArbitation_translated_payload_lock;
  wire       [3:0]    popCC_readArbitation_translated_payload_cache;
  wire       [3:0]    popCC_readArbitation_translated_payload_qos;
  wire       [2:0]    popCC_readArbitation_translated_payload_prot;
  wire                popCC_readArbitation_fire;
  (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    popCC_ptrToPush;
  reg        [2:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  reg [64:0] ram [0:3];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[1:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_prot,{io_push_payload_qos,{io_push_payload_cache,{io_push_payload_lock,{io_push_payload_burst,{io_push_payload_size,{io_push_payload_len,{io_push_payload_region,{io_push_payload_id,io_push_payload_addr}}}}}}}}};
  always @(posedge s_axi_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge m_axi_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) AxiBufferCC popToPushGray_buffercc (
    .io_dataIn   (popToPushGray[2:0]                    ), //i
    .io_dataOut  (popToPushGray_buffercc_io_dataOut[2:0]), //o
    .s_axi_clk   (s_axi_clk                             ), //i
    .s_axi_rst_n (s_axi_rst_n                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_1 cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert_buffercc (
    .io_dataIn   (cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert                    ), //i
    .io_dataOut  (cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut), //o
    .m_axi_clk   (m_axi_clk                                                           ), //i
    .s_axi_rst_n (s_axi_rst_n                                                         )  //i
  );
  (* keep_hierarchy = "TRUE" *) AxiBufferCC_2 pushToPopGray_buffercc (
    .io_dataIn                             (pushToPopGray[2:0]                    ), //i
    .io_dataOut                            (pushToPopGray_buffercc_io_dataOut[2:0]), //o
    .m_axi_clk                             (m_axi_clk                             ), //i
    .cdc_toplevel_s_axi_rst_n_synchronized (cdc_toplevel_s_axi_rst_n_synchronized )  //i
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
  assign cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert = (1'b1 ^ 1'b0);
  assign cdc_toplevel_s_axi_rst_n_synchronized = cdc_toplevel_s_axi_rst_n_asyncAssertSyncDeassert_buffercc_io_dataOut;
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
  assign popCC_readPort_rsp_id = _zz_popCC_readPort_rsp_addr[35 : 32];
  assign popCC_readPort_rsp_region = _zz_popCC_readPort_rsp_addr[39 : 36];
  assign popCC_readPort_rsp_len = _zz_popCC_readPort_rsp_addr[47 : 40];
  assign popCC_readPort_rsp_size = _zz_popCC_readPort_rsp_addr[50 : 48];
  assign popCC_readPort_rsp_burst = _zz_popCC_readPort_rsp_addr[52 : 51];
  assign popCC_readPort_rsp_lock = _zz_popCC_readPort_rsp_addr[53 : 53];
  assign popCC_readPort_rsp_cache = _zz_popCC_readPort_rsp_addr[57 : 54];
  assign popCC_readPort_rsp_qos = _zz_popCC_readPort_rsp_addr[61 : 58];
  assign popCC_readPort_rsp_prot = _zz_popCC_readPort_rsp_addr[64 : 62];
  assign popCC_addressGen_toFlowFire_valid = popCC_addressGen_fire;
  assign popCC_addressGen_toFlowFire_payload = popCC_addressGen_payload;
  assign popCC_readPort_cmd_valid = popCC_addressGen_toFlowFire_valid;
  assign popCC_readPort_cmd_payload = popCC_addressGen_toFlowFire_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_addr = popCC_readPort_rsp_addr;
  assign popCC_readArbitation_translated_payload_id = popCC_readPort_rsp_id;
  assign popCC_readArbitation_translated_payload_region = popCC_readPort_rsp_region;
  assign popCC_readArbitation_translated_payload_len = popCC_readPort_rsp_len;
  assign popCC_readArbitation_translated_payload_size = popCC_readPort_rsp_size;
  assign popCC_readArbitation_translated_payload_burst = popCC_readPort_rsp_burst;
  assign popCC_readArbitation_translated_payload_lock = popCC_readPort_rsp_lock;
  assign popCC_readArbitation_translated_payload_cache = popCC_readPort_rsp_cache;
  assign popCC_readArbitation_translated_payload_qos = popCC_readPort_rsp_qos;
  assign popCC_readArbitation_translated_payload_prot = popCC_readPort_rsp_prot;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_addr = popCC_readArbitation_translated_payload_addr;
  assign io_pop_payload_id = popCC_readArbitation_translated_payload_id;
  assign io_pop_payload_region = popCC_readArbitation_translated_payload_region;
  assign io_pop_payload_len = popCC_readArbitation_translated_payload_len;
  assign io_pop_payload_size = popCC_readArbitation_translated_payload_size;
  assign io_pop_payload_burst = popCC_readArbitation_translated_payload_burst;
  assign io_pop_payload_lock = popCC_readArbitation_translated_payload_lock;
  assign io_pop_payload_cache = popCC_readArbitation_translated_payload_cache;
  assign io_pop_payload_qos = popCC_readArbitation_translated_payload_qos;
  assign io_pop_payload_prot = popCC_readArbitation_translated_payload_prot;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = popCC_pushPtrGray[2];
  assign io_popOccupancy = ({_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  assign cdc_toplevel_s_axi_rst_n_synchronized_1 = cdc_toplevel_s_axi_rst_n_synchronized;
  always @(posedge s_axi_clk) begin
    if(!s_axi_rst_n) begin
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

  always @(posedge m_axi_clk) begin
    if(!cdc_toplevel_s_axi_rst_n_synchronized) begin
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

  always @(posedge m_axi_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module AxiBufferCC_11 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          s_axi_clk,
  input  wire          cdc_toplevel_m_axi_rst_n_synchronized_1
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axi_clk) begin
    if(!cdc_toplevel_m_axi_rst_n_synchronized_1) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_10 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          m_axi_clk,
  input  wire          m_axi_rst_n
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axi_clk) begin
    if(!m_axi_rst_n) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_9 (
  input  wire [3:0]    io_dataIn,
  output wire [3:0]    io_dataOut,
  input  wire          m_axi_clk,
  input  wire          cdc_toplevel_s_axi_rst_n_synchronized_1
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    buffers_0;
  (* async_reg = "true" *) reg        [3:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axi_clk) begin
    if(!cdc_toplevel_s_axi_rst_n_synchronized_1) begin
      buffers_0 <= 4'b0000;
      buffers_1 <= 4'b0000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_8 (
  input  wire [3:0]    io_dataIn,
  output wire [3:0]    io_dataOut,
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    buffers_0;
  (* async_reg = "true" *) reg        [3:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axi_clk) begin
    if(!s_axi_rst_n) begin
      buffers_0 <= 4'b0000;
      buffers_1 <= 4'b0000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_7 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          m_axi_clk,
  input  wire          cdc_toplevel_s_axi_rst_n_synchronized_1
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axi_clk) begin
    if(!cdc_toplevel_s_axi_rst_n_synchronized_1) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

//AxiBufferCC_6 replaced by AxiBufferCC

module AxiBufferCC_5 (
  input  wire [3:0]    io_dataIn,
  output wire [3:0]    io_dataOut,
  input  wire          s_axi_clk,
  input  wire          cdc_toplevel_m_axi_rst_n_synchronized
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    buffers_0;
  (* async_reg = "true" *) reg        [3:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axi_clk) begin
    if(!cdc_toplevel_m_axi_rst_n_synchronized) begin
      buffers_0 <= 4'b0000;
      buffers_1 <= 4'b0000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_4 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          s_axi_clk,
  input  wire          m_axi_rst_n
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axi_clk) begin
    if(!m_axi_rst_n) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_3 (
  input  wire [3:0]    io_dataIn,
  output wire [3:0]    io_dataOut,
  input  wire          m_axi_clk,
  input  wire          m_axi_rst_n
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [3:0]    buffers_0;
  (* async_reg = "true" *) reg        [3:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axi_clk) begin
    if(!m_axi_rst_n) begin
      buffers_0 <= 4'b0000;
      buffers_1 <= 4'b0000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_2 (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          m_axi_clk,
  input  wire          cdc_toplevel_s_axi_rst_n_synchronized
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axi_clk) begin
    if(!cdc_toplevel_s_axi_rst_n_synchronized) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC_1 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          m_axi_clk,
  input  wire          s_axi_rst_n
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge m_axi_clk) begin
    if(!s_axi_rst_n) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module AxiBufferCC (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          s_axi_clk,
  input  wire          s_axi_rst_n
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge s_axi_clk) begin
    if(!s_axi_rst_n) begin
      buffers_0 <= 3'b000;
      buffers_1 <= 3'b000;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule