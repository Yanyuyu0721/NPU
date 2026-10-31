`timescale 1ns/1ps
`default_nettype none
`include "top_tiny_npu.vh"
// Common-clock adapter only: all three clocks MUST be the same source.
// Shared reset also resets RAM transaction state. No asynchronous-clock support.
module edge_im2col_soc #(parameter integer MEM_BYTES=180224) (
    // -------------------------------------------------------------------------
    // Clock & Reset Channel
    // -------------------------------------------------------------------------
    input  wire                          tiny_npu_clk             ,
    input  wire                          tiny_npu_rst_n           ,

    // -------------------------------------------------------------------------
    // Interrupt Channel
    // -------------------------------------------------------------------------
    output wire                          tiny_npu_sync_intr       ,

    // -------------------------------------------------------------------------
    // Instruction / Status AXI-Lite Slave Interface (Input from Host)
    // -------------------------------------------------------------------------
    // CDC Clock/Reset
    input  wire                          tiny_npu_i_m_clk         ,
    input  wire                          tiny_npu_i_m_rst_n       ,
    
    // Write Address Channel
    input  wire [`CMD_ADDR_WIDTH-1:0]    tiny_npu_i_s_axil_awaddr , // (input )
    input  wire [2:0]                    tiny_npu_i_s_axil_awprot , // (input )
    input  wire                          tiny_npu_i_s_axil_awvalid, // (input )
    output wire                          tiny_npu_i_s_axil_awready, // (output)
    
    // Write Data Channel
    input  wire [`CMD_DATA_WIDTH-1:0]    tiny_npu_i_s_axil_wdata  , // (input )
    input  wire [`CMD_DATA_WIDTH/8-1:0]  tiny_npu_i_s_axil_wstrb  , // (input )
    input  wire                          tiny_npu_i_s_axil_wvalid , // (input )
    output wire                          tiny_npu_i_s_axil_wready , // (output)
    
    // Write Response Channel
    output wire [1:0]                    tiny_npu_i_s_axil_bresp  , // (output)
    output wire                          tiny_npu_i_s_axil_bvalid , // (output)
    input  wire                          tiny_npu_i_s_axil_bready , // (input )
    
    // Read Address Channel
    input  wire [`CMD_ADDR_WIDTH-1:0]    tiny_npu_i_s_axil_araddr , // (input )
    input  wire [2:0]                    tiny_npu_i_s_axil_arprot , // (input )
    input  wire                          tiny_npu_i_s_axil_arvalid, // (input )
    output wire                          tiny_npu_i_s_axil_arready, // (output)
    
    // Read Data Channel
    output wire [`CMD_DATA_WIDTH-1:0]    tiny_npu_i_s_axil_rdata  , // (output)
    output wire [1:0]                    tiny_npu_i_s_axil_rresp  , // (output)
    output wire                          tiny_npu_i_s_axil_rvalid , // (output)
    input  wire                          tiny_npu_i_s_axil_rready , // (input )

    // -------------------------------------------------------------------------
    // Data AXI Master Interface (Output to Memory/System)
    // -------------------------------------------------------------------------
    // CDC Clock/Reset
    input  wire                          tiny_npu_d_s_clk         ,
    input  wire                          tiny_npu_d_s_rst_n       ,

    // Write Address Channel
    output wire [3:0]                    tiny_npu_d_m_axi_awid    , // (output)
    output wire [`ADDR_WIDTH-1:0]        tiny_npu_d_m_axi_awaddr  , // (output)
    output wire [7:0]                    tiny_npu_d_m_axi_awlen   , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_awsize  , // (output)
    output wire [1:0]                    tiny_npu_d_m_axi_awburst , // (output)
    output wire                          tiny_npu_d_m_axi_awlock  , // (output)
    output wire [3:0]                    tiny_npu_d_m_axi_awcache , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_awprot  , // (output)
    output wire                          tiny_npu_d_m_axi_awvalid , // (output)
    input  wire                          tiny_npu_d_m_axi_awready , // (input )
    
    // Write Data Channel
    output wire [`DATA_WIDTH-1:0]        tiny_npu_d_m_axi_wdata   , // (output)
    output wire [`DATA_WIDTH/8-1:0]      tiny_npu_d_m_axi_wstrb   , // (output)
    output wire                          tiny_npu_d_m_axi_wlast   , // (output)
    output wire                          tiny_npu_d_m_axi_wvalid  , // (output)
    input  wire                          tiny_npu_d_m_axi_wready  , // (input )
    
    // Write Response Channel
    input  wire [3:0]                    tiny_npu_d_m_axi_bid     , // (input )
    input  wire [1:0]                    tiny_npu_d_m_axi_bresp   , // (input )
    input  wire                          tiny_npu_d_m_axi_bvalid  , // (input )
    output wire                          tiny_npu_d_m_axi_bready  , // (output)
    
    // Read Address Channel
    output wire [3:0]                    tiny_npu_d_m_axi_arid    , // (output)
    output wire [`ADDR_WIDTH-1:0]        tiny_npu_d_m_axi_araddr  , // (output)
    output wire [7:0]                    tiny_npu_d_m_axi_arlen   , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_arsize  , // (output)
    output wire [1:0]                    tiny_npu_d_m_axi_arburst , // (output)
    output wire                          tiny_npu_d_m_axi_arlock  , // (output)
    output wire [3:0]                    tiny_npu_d_m_axi_arcache , // (output)
    output wire [2:0]                    tiny_npu_d_m_axi_arprot  , // (output)
    output wire                          tiny_npu_d_m_axi_arvalid , // (output)
    input  wire                          tiny_npu_d_m_axi_arready , // (input )
    
    // Read Data Channel
    input  wire [3:0]                    tiny_npu_d_m_axi_rid     , // (input )
    input  wire [`DATA_WIDTH-1:0]        tiny_npu_d_m_axi_rdata   , // (input )
    input  wire [1:0]                    tiny_npu_d_m_axi_rresp   , // (input )
    input  wire                          tiny_npu_d_m_axi_rlast   , // (input )
    input  wire                          tiny_npu_d_m_axi_rvalid  , // (input )
    output wire                          tiny_npu_d_m_axi_rready    // (output)
);
wire [`CMD_ADDR_WIDTH-1:0] n_awaddr;
wire [2:0] n_awprot;
wire  n_awvalid;
wire  n_awready;
wire [`CMD_DATA_WIDTH-1:0] n_wdata;
wire [`CMD_DATA_WIDTH/8-1:0] n_wstrb;
wire  n_wvalid;
wire  n_wready;
wire [1:0] n_bresp;
wire  n_bvalid;
wire  n_bready;
wire [`CMD_ADDR_WIDTH-1:0] n_araddr;
wire [2:0] n_arprot;
wire  n_arvalid;
wire  n_arready;
wire [`CMD_DATA_WIDTH-1:0] n_rdata;
wire [1:0] n_rresp;
wire  n_rvalid;
wire  n_rready;
wire [3:0] n_axi_awid;
wire [`ADDR_WIDTH-1:0] n_axi_awaddr;
wire [7:0] n_axi_awlen;
wire [2:0] n_axi_awsize;
wire [1:0] n_axi_awburst;
wire  n_axi_awlock;
wire [3:0] n_axi_awcache;
wire [2:0] n_axi_awprot;
wire  n_axi_awvalid;
wire  n_axi_awready;
wire [`DATA_WIDTH-1:0] n_axi_wdata;
wire [`DATA_WIDTH/8-1:0] n_axi_wstrb;
wire  n_axi_wlast;
wire  n_axi_wvalid;
wire  n_axi_wready;
wire [3:0] n_axi_bid;
wire [1:0] n_axi_bresp;
wire  n_axi_bvalid;
wire  n_axi_bready;
wire [3:0] n_axi_arid;
wire [`ADDR_WIDTH-1:0] n_axi_araddr;
wire [7:0] n_axi_arlen;
wire [2:0] n_axi_arsize;
wire [1:0] n_axi_arburst;
wire  n_axi_arlock;
wire [3:0] n_axi_arcache;
wire [2:0] n_axi_arprot;
wire  n_axi_arvalid;
wire  n_axi_arready;
wire [3:0] n_axi_rid;
wire [`DATA_WIDTH-1:0] n_axi_rdata;
wire [1:0] n_axi_rresp;
wire  n_axi_rlast;
wire  n_axi_rvalid;
wire  n_axi_rready;
wire [3:0] c_axi_awid;
wire [`ADDR_WIDTH-1:0] c_axi_awaddr;
wire [7:0] c_axi_awlen;
wire [2:0] c_axi_awsize;
wire [1:0] c_axi_awburst;
wire  c_axi_awlock;
wire [3:0] c_axi_awcache;
wire [2:0] c_axi_awprot;
wire  c_axi_awvalid;
wire  c_axi_awready;
wire [`DATA_WIDTH-1:0] c_axi_wdata;
wire [`DATA_WIDTH/8-1:0] c_axi_wstrb;
wire  c_axi_wlast;
wire  c_axi_wvalid;
wire  c_axi_wready;
wire [3:0] c_axi_bid;
wire [1:0] c_axi_bresp;
wire  c_axi_bvalid;
wire  c_axi_bready;
wire [3:0] c_axi_arid;
wire [`ADDR_WIDTH-1:0] c_axi_araddr;
wire [7:0] c_axi_arlen;
wire [2:0] c_axi_arsize;
wire [1:0] c_axi_arburst;
wire  c_axi_arlock;
wire [3:0] c_axi_arcache;
wire [2:0] c_axi_arprot;
wire  c_axi_arvalid;
wire  c_axi_arready;
wire [3:0] c_axi_rid;
wire [`DATA_WIDTH-1:0] c_axi_rdata;
wire [1:0] c_axi_rresp;
wire  c_axi_rlast;
wire  c_axi_rvalid;
wire  c_axi_rready;
wire clk=tiny_npu_clk;
wire rst_n=tiny_npu_rst_n & tiny_npu_i_m_rst_n & tiny_npu_d_s_rst_n;

logic owner_q,armed_q,start_q,reject_q;
wire cp_busy,cp_done,cp_error; wire [3:0] cp_code;
logic [31:0] src_q,dst_q,config_q,cycles_q,mode_q,padding_q;
logic [15:0] c_q,h_q,w_q,oh_q,ow_q;
logic [31:0] rd_count_q,aw_count_q,wd_count_q;
// A nonfinal W beat may precede AW and be followed by a VALID gap. Reserve
// ownership until WLAST; wd_count_q then retains the completed burst until B.
logic partial_write_q;
wire bus_ar=tiny_npu_d_m_axi_arvalid && tiny_npu_d_m_axi_arready;
wire bus_r=tiny_npu_d_m_axi_rvalid && tiny_npu_d_m_axi_rready && tiny_npu_d_m_axi_rlast;
wire bus_aw=tiny_npu_d_m_axi_awvalid && tiny_npu_d_m_axi_awready;
wire bus_w_beat=tiny_npu_d_m_axi_wvalid && tiny_npu_d_m_axi_wready;
wire bus_w=bus_w_beat && tiny_npu_d_m_axi_wlast;
wire bus_b=tiny_npu_d_m_axi_bvalid && tiny_npu_d_m_axi_bready;
wire drained=(rd_count_q==0)&&(aw_count_q==0)&&(wd_count_q==0)&&!partial_write_q;
wire can_start=!owner_q&&!cp_busy&&drained&&!n_axi_arvalid&&!n_axi_awvalid&&!n_axi_wvalid;
wire status_busy=owner_q||cp_busy||start_q;
// Mask the old sticky completion during the one-cycle registered START launch.
wire [31:0] status_word={24'b0,(cp_error?cp_code:(reject_q?4'd8:4'd0)),1'b0,
                        (cp_error||reject_q),(cp_done&&!reject_q&&!start_q&&(!owner_q||armed_q)),status_busy};
function automatic [31:0] merge_bytes(input [31:0] old_value,new_value,input [3:0] strb);
 integer i;
 begin
  merge_bytes=old_value;
  for(i=0;i<4;i=i+1) if(strb[i]) merge_bytes[i*8+:8]=new_value[i*8+:8];
 end
endfunction
function automatic [15:0] merge_half(input [15:0] old_value,new_value,input [1:0] strb);
 begin
  merge_half={strb[1]?new_value[15:8]:old_value[15:8],strb[0]?new_value[7:0]:old_value[7:0]};
 end
endfunction
// AXI-Lite permits AW and W in either order. Each is captured once; the pair
// remains reserved until its B response is consumed, including forwarded writes.
logic aw_hold_q,w_hold_q;
logic [31:0] awaddr_q,wdata_q;
logic [2:0] awprot_q;
logic [3:0] wstrb_q;
logic [1:0] wr_state_q;
localparam [1:0] WR_CAPTURE=0,WR_SEND=1,WR_RESPONSE=2,WR_LOCAL=3;
logic aw_sent_q,w_sent_q;
logic [1:0] local_bresp_q;
wire local_write=(awaddr_q[31:8]==24'hc00001);
wire [31:0] merged_src=merge_bytes(src_q,wdata_q,wstrb_q);
wire [31:0] merged_dst=merge_bytes(dst_q,wdata_q,wstrb_q);
wire [15:0] merged_c=merge_half(c_q,wdata_q[15:0],wstrb_q[1:0]);
wire [15:0] merged_h=merge_half(h_q,wdata_q[15:0],wstrb_q[1:0]);
wire [15:0] merged_w=merge_half(w_q,wdata_q[15:0],wstrb_q[1:0]);
wire [15:0] merged_oh=merge_half(oh_q,wdata_q[15:0],wstrb_q[1:0]);
wire [15:0] merged_ow=merge_half(ow_q,wdata_q[15:0],wstrb_q[1:0]);
assign tiny_npu_i_s_axil_awready=(wr_state_q==WR_CAPTURE)&&!aw_hold_q;
assign tiny_npu_i_s_axil_wready=(wr_state_q==WR_CAPTURE)&&!w_hold_q;
assign n_awaddr=awaddr_q; assign n_awprot=awprot_q;
assign n_wdata=wdata_q; assign n_wstrb=wstrb_q;
assign n_awvalid=(wr_state_q==WR_SEND)&&!aw_sent_q;
assign n_wvalid=(wr_state_q==WR_SEND)&&!w_sent_q;
assign tiny_npu_i_s_axil_bvalid=(wr_state_q==WR_LOCAL)||((wr_state_q==WR_RESPONSE)&&n_bvalid);
assign tiny_npu_i_s_axil_bresp=(wr_state_q==WR_LOCAL)?local_bresp_q:n_bresp;
assign n_bready=(wr_state_q==WR_RESPONSE)&&tiny_npu_i_s_axil_bready;

logic [1:0] rd_state_q;
localparam [1:0] RD_CAPTURE=0,RD_SEND=1,RD_RESPONSE=2,RD_LOCAL=3;
logic [31:0] araddr_q,local_rdata_q;
logic [2:0] arprot_q;
logic [1:0] local_rresp_q;
assign tiny_npu_i_s_axil_arready=(rd_state_q==RD_CAPTURE);
assign n_araddr=araddr_q; assign n_arprot=arprot_q;
assign n_arvalid=(rd_state_q==RD_SEND);
assign n_rready=(rd_state_q==RD_RESPONSE)&&tiny_npu_i_s_axil_rready;
assign tiny_npu_i_s_axil_rvalid=(rd_state_q==RD_LOCAL)||((rd_state_q==RD_RESPONSE)&&n_rvalid);
assign tiny_npu_i_s_axil_rdata=(rd_state_q==RD_LOCAL)?local_rdata_q:n_rdata;
assign tiny_npu_i_s_axil_rresp=(rd_state_q==RD_LOCAL)?local_rresp_q:n_rresp;

always_ff @(posedge clk) begin
 if(!rst_n) begin
  owner_q<=0;armed_q<=0;start_q<=0;reject_q<=0;
  src_q<=0;dst_q<=0;config_q<=0;mode_q<=0;padding_q<=0;c_q<=0;h_q<=0;w_q<=0;oh_q<=0;ow_q<=0;cycles_q<=0;
  rd_count_q<=0;aw_count_q<=0;wd_count_q<=0;partial_write_q<=0;
  wr_state_q<=WR_CAPTURE;aw_hold_q<=0;w_hold_q<=0;aw_sent_q<=0;w_sent_q<=0;
  awaddr_q<=0;awprot_q<=0;wdata_q<=0;wstrb_q<=0;local_bresp_q<=0;
  rd_state_q<=RD_CAPTURE;araddr_q<=0;arprot_q<=0;local_rdata_q<=0;local_rresp_q<=0;
 end else begin
  start_q<=0;
  // Track every accepted W beat, including a partial W-first burst with no AW.
  // AXI4 has no W interleaving: WLAST transfers reservation to wd_count_q.
  // AXI-compliant slaves never return unmatched RLAST/B responses.
  if(bus_w_beat) partial_write_q<=!tiny_npu_d_m_axi_wlast;
  case({bus_ar,bus_r}) 2'b10:rd_count_q<=rd_count_q+1'b1;2'b01:rd_count_q<=rd_count_q-1'b1;default:;endcase
  case({bus_aw,bus_b}) 2'b10:aw_count_q<=aw_count_q+1'b1;2'b01:aw_count_q<=aw_count_q-1'b1;default:;endcase
  case({bus_w,bus_b}) 2'b10:wd_count_q<=wd_count_q+1'b1;2'b01:wd_count_q<=wd_count_q-1'b1;default:;endcase
  if(owner_q) begin
   cycles_q<=cycles_q+1'b1;
   if(cp_busy) armed_q<=1;
   // cp_busy has been observed since this start: old sticky done cannot release.
   // A malformed RLAST leaves rd_count nonzero and requires shared reset.
   if(armed_q&&!cp_busy&&cp_done&&drained) begin owner_q<=0;armed_q<=0;end
  end
  case(wr_state_q)
   WR_CAPTURE:begin
    if(tiny_npu_i_s_axil_awvalid&&tiny_npu_i_s_axil_awready) begin aw_hold_q<=1;awaddr_q<=tiny_npu_i_s_axil_awaddr;awprot_q<=tiny_npu_i_s_axil_awprot;end
    if(tiny_npu_i_s_axil_wvalid&&tiny_npu_i_s_axil_wready) begin w_hold_q<=1;wdata_q<=tiny_npu_i_s_axil_wdata;wstrb_q<=tiny_npu_i_s_axil_wstrb;end
    if(aw_hold_q&&w_hold_q) begin
     if(!local_write) begin wr_state_q<=WR_SEND;aw_sent_q<=0;w_sent_q<=0;end
     else begin
      wr_state_q<=WR_LOCAL;local_bresp_q<=0;
      case(awaddr_q[7:0])
       8'h00:if(wstrb_q[0]&&wdata_q[0]) begin
        if(can_start) begin owner_q<=1;armed_q<=0;start_q<=1;reject_q<=0;cycles_q<=0;end
        else begin local_bresp_q<=2;reject_q<=1;end
       end
       8'h04,8'h08,8'h0c,8'h10,8'h14,8'h18,8'h1c,8'h20,8'h28,8'h2c:begin
        if(status_busy) local_bresp_q<=2;
        else case(awaddr_q[7:0])
         8'h04:src_q<=merged_src;8'h08:dst_q<=merged_dst;8'h0c:c_q<=merged_c[15:0];
         8'h10:h_q<=merged_h[15:0];8'h14:w_q<=merged_w[15:0];
         8'h18:oh_q<=merged_oh[15:0];8'h1c:ow_q<=merged_ow[15:0];
         8'h20:config_q<=merge_bytes(config_q,wdata_q,wstrb_q);
         // Reserved mode bits are rejected, never silently enable an extension.
         8'h28:if((merge_bytes(mode_q,wdata_q,wstrb_q)&32'hfffffffe)!=0) local_bresp_q<=2;
               else mode_q<=merge_bytes(mode_q,wdata_q,wstrb_q);
         8'h2c:padding_q<=merge_bytes(padding_q,wdata_q,wstrb_q);
         default:;
        endcase
       end
       default:local_bresp_q<=2;
      endcase
     end
    end
   end
   WR_SEND:begin
    if(n_awvalid&&n_awready) aw_sent_q<=1;
    if(n_wvalid&&n_wready) w_sent_q<=1;
    if((aw_sent_q||n_awready)&&(w_sent_q||n_wready)) wr_state_q<=WR_RESPONSE;
   end
   WR_RESPONSE,WR_LOCAL:if(tiny_npu_i_s_axil_bvalid&&tiny_npu_i_s_axil_bready) begin wr_state_q<=WR_CAPTURE;aw_hold_q<=0;w_hold_q<=0;end
   default:wr_state_q<=WR_CAPTURE;
  endcase
  case(rd_state_q)
   RD_CAPTURE:if(tiny_npu_i_s_axil_arvalid&&tiny_npu_i_s_axil_arready) begin
    araddr_q<=tiny_npu_i_s_axil_araddr;arprot_q<=tiny_npu_i_s_axil_arprot;
    if(tiny_npu_i_s_axil_araddr[31:8]!=24'hc00001) rd_state_q<=RD_SEND;
    else begin
     rd_state_q<=RD_LOCAL;local_rresp_q<=0;local_rdata_q<=0;
     case(tiny_npu_i_s_axil_araddr[7:0])
      8'h00:local_rdata_q<=status_word;8'h04:local_rdata_q<=src_q;8'h08:local_rdata_q<=dst_q;
      8'h0c:local_rdata_q<={16'b0,c_q};8'h10:local_rdata_q<={16'b0,h_q};8'h14:local_rdata_q<={16'b0,w_q};
      8'h18:local_rdata_q<={16'b0,oh_q};8'h1c:local_rdata_q<={16'b0,ow_q};
      8'h20:local_rdata_q<=config_q;8'h24:local_rdata_q<=cycles_q;
      8'h28:local_rdata_q<=mode_q;8'h2c:local_rdata_q<=padding_q;8'h30:local_rdata_q<=32'd1;
      default:local_rresp_q<=2;
     endcase
    end
   end
   RD_SEND:if(n_arready) rd_state_q<=RD_RESPONSE;
   RD_RESPONSE,RD_LOCAL:if(tiny_npu_i_s_axil_rvalid&&tiny_npu_i_s_axil_rready) rd_state_q<=RD_CAPTURE;
   default:rd_state_q<=RD_CAPTURE;
  endcase
 end
end

assign tiny_npu_d_m_axi_awid=owner_q?c_axi_awid:n_axi_awid;
assign tiny_npu_d_m_axi_awaddr=owner_q?c_axi_awaddr:n_axi_awaddr;
assign tiny_npu_d_m_axi_awlen=owner_q?c_axi_awlen:n_axi_awlen;
assign tiny_npu_d_m_axi_awsize=owner_q?c_axi_awsize:n_axi_awsize;
assign tiny_npu_d_m_axi_awburst=owner_q?c_axi_awburst:n_axi_awburst;
assign tiny_npu_d_m_axi_awlock=owner_q?c_axi_awlock:n_axi_awlock;
assign tiny_npu_d_m_axi_awcache=owner_q?c_axi_awcache:n_axi_awcache;
assign tiny_npu_d_m_axi_awprot=owner_q?c_axi_awprot:n_axi_awprot;
assign tiny_npu_d_m_axi_awvalid=owner_q?c_axi_awvalid:n_axi_awvalid;
assign n_axi_awready=!owner_q && tiny_npu_d_m_axi_awready;
assign c_axi_awready=owner_q && tiny_npu_d_m_axi_awready;
assign tiny_npu_d_m_axi_wdata=owner_q?c_axi_wdata:n_axi_wdata;
assign tiny_npu_d_m_axi_wstrb=owner_q?c_axi_wstrb:n_axi_wstrb;
assign tiny_npu_d_m_axi_wlast=owner_q?c_axi_wlast:n_axi_wlast;
assign tiny_npu_d_m_axi_wvalid=owner_q?c_axi_wvalid:n_axi_wvalid;
assign n_axi_wready=!owner_q && tiny_npu_d_m_axi_wready;
assign c_axi_wready=owner_q && tiny_npu_d_m_axi_wready;
assign n_axi_bid=tiny_npu_d_m_axi_bid;
assign c_axi_bid=tiny_npu_d_m_axi_bid;
assign n_axi_bresp=tiny_npu_d_m_axi_bresp;
assign c_axi_bresp=tiny_npu_d_m_axi_bresp;
assign n_axi_bvalid=!owner_q && tiny_npu_d_m_axi_bvalid;
assign c_axi_bvalid=owner_q && tiny_npu_d_m_axi_bvalid;
assign tiny_npu_d_m_axi_bready=owner_q?c_axi_bready:n_axi_bready;
assign tiny_npu_d_m_axi_arid=owner_q?c_axi_arid:n_axi_arid;
assign tiny_npu_d_m_axi_araddr=owner_q?c_axi_araddr:n_axi_araddr;
assign tiny_npu_d_m_axi_arlen=owner_q?c_axi_arlen:n_axi_arlen;
assign tiny_npu_d_m_axi_arsize=owner_q?c_axi_arsize:n_axi_arsize;
assign tiny_npu_d_m_axi_arburst=owner_q?c_axi_arburst:n_axi_arburst;
assign tiny_npu_d_m_axi_arlock=owner_q?c_axi_arlock:n_axi_arlock;
assign tiny_npu_d_m_axi_arcache=owner_q?c_axi_arcache:n_axi_arcache;
assign tiny_npu_d_m_axi_arprot=owner_q?c_axi_arprot:n_axi_arprot;
assign tiny_npu_d_m_axi_arvalid=owner_q?c_axi_arvalid:n_axi_arvalid;
assign n_axi_arready=!owner_q && tiny_npu_d_m_axi_arready;
assign c_axi_arready=owner_q && tiny_npu_d_m_axi_arready;
assign n_axi_rid=tiny_npu_d_m_axi_rid;
assign c_axi_rid=tiny_npu_d_m_axi_rid;
assign n_axi_rdata=tiny_npu_d_m_axi_rdata;
assign c_axi_rdata=tiny_npu_d_m_axi_rdata;
assign n_axi_rresp=tiny_npu_d_m_axi_rresp;
assign c_axi_rresp=tiny_npu_d_m_axi_rresp;
assign n_axi_rlast=tiny_npu_d_m_axi_rlast;
assign c_axi_rlast=tiny_npu_d_m_axi_rlast;
assign n_axi_rvalid=!owner_q && tiny_npu_d_m_axi_rvalid;
assign c_axi_rvalid=owner_q && tiny_npu_d_m_axi_rvalid;
assign tiny_npu_d_m_axi_rready=owner_q?c_axi_rready:n_axi_rready;
top_tiny_npu_wrapper u_npu (
 .tiny_npu_clk(tiny_npu_clk),
 .tiny_npu_rst_n(rst_n),
 .tiny_npu_sync_intr(tiny_npu_sync_intr),
 .tiny_npu_i_m_clk(tiny_npu_i_m_clk),
 .tiny_npu_i_m_rst_n(rst_n),
 .tiny_npu_i_s_axil_awaddr(n_awaddr),
 .tiny_npu_i_s_axil_awprot(n_awprot),
 .tiny_npu_i_s_axil_awvalid(n_awvalid),
 .tiny_npu_i_s_axil_awready(n_awready),
 .tiny_npu_i_s_axil_wdata(n_wdata),
 .tiny_npu_i_s_axil_wstrb(n_wstrb),
 .tiny_npu_i_s_axil_wvalid(n_wvalid),
 .tiny_npu_i_s_axil_wready(n_wready),
 .tiny_npu_i_s_axil_bresp(n_bresp),
 .tiny_npu_i_s_axil_bvalid(n_bvalid),
 .tiny_npu_i_s_axil_bready(n_bready),
 .tiny_npu_i_s_axil_araddr(n_araddr),
 .tiny_npu_i_s_axil_arprot(n_arprot),
 .tiny_npu_i_s_axil_arvalid(n_arvalid),
 .tiny_npu_i_s_axil_arready(n_arready),
 .tiny_npu_i_s_axil_rdata(n_rdata),
 .tiny_npu_i_s_axil_rresp(n_rresp),
 .tiny_npu_i_s_axil_rvalid(n_rvalid),
 .tiny_npu_i_s_axil_rready(n_rready),
 .tiny_npu_d_s_clk(tiny_npu_d_s_clk),
 .tiny_npu_d_s_rst_n(rst_n),
 .tiny_npu_d_m_axi_awid(n_axi_awid),
 .tiny_npu_d_m_axi_awaddr(n_axi_awaddr),
 .tiny_npu_d_m_axi_awlen(n_axi_awlen),
 .tiny_npu_d_m_axi_awsize(n_axi_awsize),
 .tiny_npu_d_m_axi_awburst(n_axi_awburst),
 .tiny_npu_d_m_axi_awlock(n_axi_awlock),
 .tiny_npu_d_m_axi_awcache(n_axi_awcache),
 .tiny_npu_d_m_axi_awprot(n_axi_awprot),
 .tiny_npu_d_m_axi_awvalid(n_axi_awvalid),
 .tiny_npu_d_m_axi_awready(n_axi_awready),
 .tiny_npu_d_m_axi_wdata(n_axi_wdata),
 .tiny_npu_d_m_axi_wstrb(n_axi_wstrb),
 .tiny_npu_d_m_axi_wlast(n_axi_wlast),
 .tiny_npu_d_m_axi_wvalid(n_axi_wvalid),
 .tiny_npu_d_m_axi_wready(n_axi_wready),
 .tiny_npu_d_m_axi_bid(n_axi_bid),
 .tiny_npu_d_m_axi_bresp(n_axi_bresp),
 .tiny_npu_d_m_axi_bvalid(n_axi_bvalid),
 .tiny_npu_d_m_axi_bready(n_axi_bready),
 .tiny_npu_d_m_axi_arid(n_axi_arid),
 .tiny_npu_d_m_axi_araddr(n_axi_araddr),
 .tiny_npu_d_m_axi_arlen(n_axi_arlen),
 .tiny_npu_d_m_axi_arsize(n_axi_arsize),
 .tiny_npu_d_m_axi_arburst(n_axi_arburst),
 .tiny_npu_d_m_axi_arlock(n_axi_arlock),
 .tiny_npu_d_m_axi_arcache(n_axi_arcache),
 .tiny_npu_d_m_axi_arprot(n_axi_arprot),
 .tiny_npu_d_m_axi_arvalid(n_axi_arvalid),
 .tiny_npu_d_m_axi_arready(n_axi_arready),
 .tiny_npu_d_m_axi_rid(n_axi_rid),
 .tiny_npu_d_m_axi_rdata(n_axi_rdata),
 .tiny_npu_d_m_axi_rresp(n_axi_rresp),
 .tiny_npu_d_m_axi_rlast(n_axi_rlast),
 .tiny_npu_d_m_axi_rvalid(n_axi_rvalid),
 .tiny_npu_d_m_axi_rready(n_axi_rready)
);
edge_im2col_axi #(.MEM_BYTES(MEM_BYTES)) u_im2col (
.clk(clk),.rst_n(rst_n),.start(start_q),.src_base(src_q),.dst_base(dst_q),
.channels(c_q),.height(h_q),.width(w_q),.out_height(oh_q),.out_width(ow_q),
.kernel_size(config_q[2:0]),.stride(config_q[5:4]),.pad(config_q[9:8]),.pad_value(config_q[23:16]),
.hwc_mode(mode_q[0]),.pad_top(padding_q[7:0]),.pad_bottom(padding_q[15:8]),
.pad_left(padding_q[23:16]),.pad_right(padding_q[31:24]),
.busy(cp_busy),.done(cp_done),.error(cp_error),.error_code(cp_code),
.m_axi_awid(c_axi_awid),
.m_axi_awaddr(c_axi_awaddr),
.m_axi_awlen(c_axi_awlen),
.m_axi_awsize(c_axi_awsize),
.m_axi_awburst(c_axi_awburst),
.m_axi_awlock(c_axi_awlock),
.m_axi_awcache(c_axi_awcache),
.m_axi_awprot(c_axi_awprot),
.m_axi_awvalid(c_axi_awvalid),
.m_axi_awready(c_axi_awready),
.m_axi_wdata(c_axi_wdata),
.m_axi_wstrb(c_axi_wstrb),
.m_axi_wlast(c_axi_wlast),
.m_axi_wvalid(c_axi_wvalid),
.m_axi_wready(c_axi_wready),
.m_axi_bid(c_axi_bid),
.m_axi_bresp(c_axi_bresp),
.m_axi_bvalid(c_axi_bvalid),
.m_axi_bready(c_axi_bready),
.m_axi_arid(c_axi_arid),
.m_axi_araddr(c_axi_araddr),
.m_axi_arlen(c_axi_arlen),
.m_axi_arsize(c_axi_arsize),
.m_axi_arburst(c_axi_arburst),
.m_axi_arlock(c_axi_arlock),
.m_axi_arcache(c_axi_arcache),
.m_axi_arprot(c_axi_arprot),
.m_axi_arvalid(c_axi_arvalid),
.m_axi_arready(c_axi_arready),
.m_axi_rid(c_axi_rid),
.m_axi_rdata(c_axi_rdata),
.m_axi_rresp(c_axi_rresp),
.m_axi_rlast(c_axi_rlast),
.m_axi_rvalid(c_axi_rvalid),
.m_axi_rready(c_axi_rready)
);
endmodule
`default_nettype wire
