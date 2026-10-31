`timescale 1ns/1ps
`default_nettype none
// CHW INT8 -> [out_y][out_x][channel][kernel_y][kernel_x] INT8.
// One clock/reset domain. All configuration is captured on start while !busy.
// done/error are sticky until the next accepted start or synchronous reset.
// Reset MUST also reset the attached slave/owner arbiter: pending AXI traffic is
// abandoned on reset. RLAST/ID corruption is a protocol fault requiring that
// shared reset before reuse; SLVERR/DECERR also abort without further accesses.
// No source/destination overlap is allowed. Destination must be 8-byte aligned.
// Physical addresses are checked at full width before issuing any transaction.
// A cached aligned source word can read guard bytes beside the requested source
// tensor, but never outside MEM_BYTES (which must be a multiple of eight).
module edge_im2col_axi #(
  parameter integer MEM_BYTES = 180224
)(
  // Explicit net kind is required by Vivado 2018.3 with default_nettype none.
  input wire logic clk,input wire logic rst_n,input wire logic start,
  input wire logic [31:0] src_base,input wire logic [31:0] dst_base,
  input wire logic [15:0] channels,input wire logic [15:0] height,input wire logic [15:0] width,
  input wire logic [15:0] out_height,input wire logic [15:0] out_width,
  input wire logic [2:0] kernel_size,input wire logic [1:0] stride,input wire logic [1:0] pad,
  input wire logic [7:0] pad_value,
  input wire logic hwc_mode,
  input wire logic [7:0] pad_top,pad_bottom,pad_left,pad_right,
  output logic busy,output logic done,output logic error,output logic [3:0] error_code,
  output logic [3:0] m_axi_awid,output logic [31:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,output logic m_axi_awlock,
  output logic [3:0] m_axi_awcache,output logic [2:0] m_axi_awprot,
  output logic m_axi_awvalid,input wire logic m_axi_awready,
  output logic [63:0] m_axi_wdata,output logic [7:0] m_axi_wstrb,
  output logic m_axi_wlast,output logic m_axi_wvalid,input wire logic m_axi_wready,
  input wire logic [3:0] m_axi_bid,input wire logic [1:0] m_axi_bresp,
  input wire logic m_axi_bvalid,output logic m_axi_bready,
  output logic [3:0] m_axi_arid,output logic [31:0] m_axi_araddr,
  output logic [7:0] m_axi_arlen,output logic [2:0] m_axi_arsize,
  output logic [1:0] m_axi_arburst,output logic m_axi_arlock,
  output logic [3:0] m_axi_arcache,output logic [2:0] m_axi_arprot,
  output logic m_axi_arvalid,input wire logic m_axi_arready,
  input wire logic [3:0] m_axi_rid,input wire logic [63:0] m_axi_rdata,
  input wire logic [1:0] m_axi_rresp,input wire logic m_axi_rlast,
  input wire logic m_axi_rvalid,output logic m_axi_rready
);
  localparam logic [3:0] S_IDLE=0,S_CHECK=1,S_MUL=2,S_RANGE=3,S_BYTE=4,
                         S_AR=5,S_R=6,S_WRITE=7,S_B=8;
  logic [3:0] state_q;
  logic [31:0] src_q,dst_q,plane_q,src_span_q,total_q,remaining_q;
  logic [15:0] channels_q,height_q,width_q,oh_q,ow_q;
  logic [2:0] kernel_q;
  logic [1:0] stride_q,pad_q;
  logic [7:0] pad_value_q;
  logic hwc_q;
  logic [7:0] pt_q,pb_q,pl_q,pr_q;
  logic [31:0] row_stride_q,pixel_step,row_step,channel_step,pad_cols,stride_cols;
  // A single 32-cycle shift/add multiplier handles only setup. No DSP or RAM.
  logic [63:0] mul_acc_q,mul_a_q;
  logic [31:0] mul_b_q;
  logic [5:0] mul_count_q;
  logic [2:0] mul_stage_q;
  logic [63:0] mul_sum;
  logic [31:0] inner_bytes;
  logic [17:0] padded_h,padded_w,expected_oh,expected_ow;
  logic [32:0] src_end,dst_end;
  logic [31:0] pad_rows,stride_rows;
  logic [15:0] oy_q,ox_q,ch_q;
  logic [2:0] ky_q,kx_q,lane_q;
  logic signed [18:0] origin_y_q,origin_x_q,iy_q,ix_q;
  logic signed [32:0] window_y_q,window_q,channel_addr_q,row_addr_q,byte_addr_q;
  logic [31:0] read_addr_q,cache_addr_q;
  logic [63:0] cache_data_q,pack_q;
  logic [7:0] strb_q;
  logic cache_valid_q,aw_pending_q,w_pending_q;
  logic in_bounds,cache_hit;
  logic [7:0] next_byte;

  always_comb begin
    padded_h={2'b0,height_q}+(hwc_q?{10'b0,pt_q}+{10'b0,pb_q}:{15'b0,pad_q,1'b0});
    padded_w={2'b0,width_q}+(hwc_q?{10'b0,pl_q}+{10'b0,pr_q}:{15'b0,pad_q,1'b0});
    expected_oh=padded_h-{15'b0,kernel_q};
    expected_ow=padded_w-{15'b0,kernel_q};
    if(stride_q==2) begin expected_oh=expected_oh>>1;expected_ow=expected_ow>>1;end
    expected_oh=expected_oh+18'd1;expected_ow=expected_ow+18'd1;
    inner_bytes=kernel_q==4?({16'b0,channels_q}<<4):kernel_q==3?({16'b0,channels_q}<<3)+{16'b0,channels_q}:
      ({16'b0,channels_q}<<4)+({16'b0,channels_q}<<3)+{16'b0,channels_q};
    mul_sum=mul_acc_q+(mul_b_q[0]?mul_a_q:64'd0);
    src_end={1'b0,src_q}+{1'b0,src_span_q};
    dst_end={1'b0,dst_q}+{1'b0,total_q};
    pixel_step=hwc_q?{16'b0,channels_q}:32'd1;
    row_step=hwc_q?row_stride_q:{16'b0,width_q};
    channel_step=hwc_q?32'd1:plane_q;
    pad_rows=pt_q==2?(row_step<<1):pt_q==1?row_step:32'd0;
    pad_cols=pl_q==2?(pixel_step<<1):pl_q==1?pixel_step:32'd0;
    stride_rows=stride_q==2?(row_step<<1):row_step;
    stride_cols=stride_q==2?(pixel_step<<1):pixel_step;
    in_bounds=(iy_q>=0)&&(iy_q<$signed({3'b0,height_q}))&&
              (ix_q>=0)&&(ix_q<$signed({3'b0,width_q}));
    cache_hit=cache_valid_q&&(cache_addr_q=={byte_addr_q[31:3],3'b000});
    next_byte=in_bounds?cache_data_q[byte_addr_q[2:0]*8+:8]:pad_value_q;
    m_axi_awid=0;m_axi_awaddr=dst_q;m_axi_awlen=0;m_axi_awsize=3;
    m_axi_awburst=1;m_axi_awlock=0;m_axi_awcache=0;m_axi_awprot=0;
    m_axi_awvalid=(state_q==S_WRITE)&&aw_pending_q;
    m_axi_wdata=pack_q;m_axi_wstrb=strb_q;m_axi_wlast=1;
    m_axi_wvalid=(state_q==S_WRITE)&&w_pending_q;
    m_axi_bready=(state_q==S_B);
    m_axi_arid=0;m_axi_araddr=read_addr_q;m_axi_arlen=0;m_axi_arsize=3;
    m_axi_arburst=1;m_axi_arlock=0;m_axi_arcache=0;m_axi_arprot=0;
    m_axi_arvalid=(state_q==S_AR);
    m_axi_rready=(state_q==S_R);
  end

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state_q<=S_IDLE;busy<=0;done<=0;error<=0;error_code<=0;
      src_q<=0;dst_q<=0;plane_q<=0;src_span_q<=0;total_q<=0;remaining_q<=0;
      channels_q<=0;height_q<=0;width_q<=0;oh_q<=0;ow_q<=0;
      kernel_q<=0;stride_q<=0;pad_q<=0;pad_value_q<=0;
      hwc_q<=0;pt_q<=0;pb_q<=0;pl_q<=0;pr_q<=0;row_stride_q<=0;
      mul_acc_q<=0;mul_a_q<=0;mul_b_q<=0;mul_count_q<=0;mul_stage_q<=0;
      oy_q<=0;ox_q<=0;ch_q<=0;ky_q<=0;kx_q<=0;lane_q<=0;
      origin_y_q<=0;origin_x_q<=0;iy_q<=0;ix_q<=0;
      window_y_q<=0;window_q<=0;channel_addr_q<=0;row_addr_q<=0;byte_addr_q<=0;
      read_addr_q<=0;cache_addr_q<=0;cache_data_q<=0;pack_q<=0;strb_q<=0;
      cache_valid_q<=0;aw_pending_q<=0;w_pending_q<=0;
    end else begin
      case(state_q)
        S_IDLE: if(start) begin
          src_q<=src_base;dst_q<=dst_base;channels_q<=channels;height_q<=height;width_q<=width;
          oh_q<=out_height;ow_q<=out_width;kernel_q<=kernel_size;stride_q<=stride;pad_q<=pad;pad_value_q<=pad_value;
          hwc_q<=hwc_mode;
          pt_q<=hwc_mode?pad_top:{6'b0,pad};pb_q<=hwc_mode?pad_bottom:{6'b0,pad};
          pl_q<=hwc_mode?pad_left:{6'b0,pad};pr_q<=hwc_mode?pad_right:{6'b0,pad};
          busy<=1;done<=0;error<=0;error_code<=0;cache_valid_q<=0;state_q<=S_CHECK;
        end
        S_CHECK: begin
          if(channels_q==0||height_q==0||width_q==0||oh_q==0||ow_q==0||
            (kernel_q!=3&&kernel_q!=5&&!(hwc_q&&kernel_q==4))||(stride_q!=1&&stride_q!=2)||
            pt_q>2||pb_q>2||pl_q>2||pr_q>2||
            padded_h<{15'b0,kernel_q}||padded_w<{15'b0,kernel_q}||
            expected_oh!={2'b0,oh_q}||expected_ow!={2'b0,ow_q}) begin
            error_code<=1;error<=1;busy<=0;done<=1;state_q<=S_IDLE;
          end else if(dst_q[2:0]!=0) begin
            error_code<=2;error<=1;busy<=0;done<=1;state_q<=S_IDLE;
          end else begin
            mul_a_q<={48'b0,height_q};mul_b_q<={16'b0,width_q};mul_acc_q<=0;mul_count_q<=0;mul_stage_q<=0;state_q<=S_MUL;
          end
        end
        S_MUL: begin
          if(mul_count_q==31) begin
            mul_acc_q<=0;mul_count_q<=0;
            // Reject before narrowing a product, including dimensions whose
            // tensor product exceeds 32 bits or the complete physical RAM.
            if(mul_sum==0||mul_sum>{32'b0,MEM_BYTES[31:0]}) begin
              error_code<=3;error<=1;busy<=0;done<=1;state_q<=S_IDLE;
            end else case(mul_stage_q)
              0: begin plane_q<=mul_sum[31:0];mul_a_q<=mul_sum;mul_b_q<={16'b0,channels_q};mul_stage_q<=1;end
              1: begin src_span_q<=mul_sum[31:0];mul_a_q<={48'b0,oh_q};mul_b_q<={16'b0,ow_q};mul_stage_q<=2;end
              2: begin mul_a_q<=mul_sum;mul_b_q<=inner_bytes;mul_stage_q<=3;end
              3: begin total_q<=mul_sum[31:0];remaining_q<=mul_sum[31:0];
                 mul_a_q<={48'b0,width_q};mul_b_q<={16'b0,channels_q};mul_stage_q<=4;end
              4: begin row_stride_q<=mul_sum[31:0];state_q<=S_RANGE;end
            endcase
          end else begin
            mul_acc_q<=mul_sum;mul_a_q<=mul_a_q<<1;mul_b_q<=mul_b_q>>1;mul_count_q<=mul_count_q+1'b1;
          end
        end
        S_RANGE: begin
          if(src_end>{1'b0,MEM_BYTES[31:0]}||dst_end>{1'b0,MEM_BYTES[31:0]}) begin
            error_code<=3;error<=1;busy<=0;done<=1;state_q<=S_IDLE;
          end else if(({1'b0,src_q}<dst_end)&&({1'b0,dst_q}<src_end)) begin
            error_code<=4;error<=1;busy<=0;done<=1;state_q<=S_IDLE;
          end else begin
            oy_q<=0;ox_q<=0;ch_q<=0;ky_q<=0;kx_q<=0;lane_q<=0;pack_q<=0;strb_q<=0;
            origin_y_q<=-$signed({11'b0,pt_q});origin_x_q<=-$signed({11'b0,pl_q});
            iy_q<=-$signed({11'b0,pt_q});ix_q<=-$signed({11'b0,pl_q});
            window_y_q<=$signed({1'b0,src_q})-$signed({1'b0,pad_rows});
            window_q<=$signed({1'b0,src_q})-$signed({1'b0,pad_rows})-$signed({1'b0,pad_cols});
            channel_addr_q<=$signed({1'b0,src_q})-$signed({1'b0,pad_rows})-$signed({1'b0,pad_cols});
            row_addr_q<=$signed({1'b0,src_q})-$signed({1'b0,pad_rows})-$signed({1'b0,pad_cols});
            byte_addr_q<=$signed({1'b0,src_q})-$signed({1'b0,pad_rows})-$signed({1'b0,pad_cols});
            state_q<=S_BYTE;
          end
        end
        S_BYTE: begin
          if(in_bounds&&!cache_hit) begin
            read_addr_q<={byte_addr_q[31:3],3'b000};state_q<=S_AR;
          end else begin
            pack_q[lane_q*8+:8]<=next_byte;strb_q[lane_q]<=1;
            remaining_q<=remaining_q-1'b1;
            if(lane_q==7||remaining_q==1) begin state_q<=S_WRITE;aw_pending_q<=1;w_pending_q<=1;end
            else lane_q<=lane_q+1'b1;
            // Incremental CHW/HWC addresses; output order is always [p][ci][ky][kx].
            if(kx_q+3'd1<kernel_q) begin
              kx_q<=kx_q+1'b1;ix_q<=ix_q+19'sd1;byte_addr_q<=byte_addr_q+$signed({1'b0,pixel_step});
            end else begin
              kx_q<=0;ix_q<=origin_x_q;
              if(ky_q+3'd1<kernel_q) begin
                ky_q<=ky_q+1'b1;iy_q<=iy_q+19'sd1;
                row_addr_q<=row_addr_q+$signed({1'b0,row_step});byte_addr_q<=row_addr_q+$signed({1'b0,row_step});
              end else begin
                ky_q<=0;iy_q<=origin_y_q;
                if(ch_q+16'd1<channels_q) begin
                  ch_q<=ch_q+1'b1;channel_addr_q<=channel_addr_q+$signed({1'b0,channel_step});
                  row_addr_q<=channel_addr_q+$signed({1'b0,channel_step});byte_addr_q<=channel_addr_q+$signed({1'b0,channel_step});
                end else begin
                  ch_q<=0;
                  if(ox_q+16'd1<ow_q) begin
                    ox_q<=ox_q+1'b1;origin_x_q<=origin_x_q+$signed({17'b0,stride_q});ix_q<=origin_x_q+$signed({17'b0,stride_q});
                    window_q<=window_q+$signed({1'b0,stride_cols});channel_addr_q<=window_q+$signed({1'b0,stride_cols});
                    row_addr_q<=window_q+$signed({1'b0,stride_cols});byte_addr_q<=window_q+$signed({1'b0,stride_cols});
                  end else begin
                    ox_q<=0;oy_q<=oy_q+1'b1;origin_x_q<=-$signed({11'b0,pl_q});ix_q<=-$signed({11'b0,pl_q});
                    origin_y_q<=origin_y_q+$signed({17'b0,stride_q});iy_q<=origin_y_q+$signed({17'b0,stride_q});
                    window_y_q<=window_y_q+$signed({1'b0,stride_rows});
                    window_q<=window_y_q+$signed({1'b0,stride_rows})-$signed({1'b0,pad_cols});
                    channel_addr_q<=window_y_q+$signed({1'b0,stride_rows})-$signed({1'b0,pad_cols});
                    row_addr_q<=window_y_q+$signed({1'b0,stride_rows})-$signed({1'b0,pad_cols});
                    byte_addr_q<=window_y_q+$signed({1'b0,stride_rows})-$signed({1'b0,pad_cols});
                  end
                end
              end
            end
          end
        end
        S_AR: if(m_axi_arready) state_q<=S_R;
        S_R: if(m_axi_rvalid) begin
          if(m_axi_rresp!=0||!m_axi_rlast||m_axi_rid!=0) begin
            error_code<=5;error<=1;busy<=0;done<=1;state_q<=S_IDLE;cache_valid_q<=0;
          end else begin cache_data_q<=m_axi_rdata;cache_addr_q<=read_addr_q;cache_valid_q<=1;state_q<=S_BYTE;end
        end
        S_WRITE: begin
          if(m_axi_awready) aw_pending_q<=0;
          if(m_axi_wready) w_pending_q<=0;
          if((!aw_pending_q||m_axi_awready)&&(!w_pending_q||m_axi_wready)) state_q<=S_B;
        end
        S_B: if(m_axi_bvalid) begin
          if(m_axi_bresp!=0||m_axi_bid!=0) begin
            error_code<=6;error<=1;busy<=0;done<=1;state_q<=S_IDLE;
          end else if(remaining_q==0) begin busy<=0;done<=1;state_q<=S_IDLE;end
          else begin dst_q<=dst_q+32'd8;lane_q<=0;pack_q<=0;strb_q<=0;state_q<=S_BYTE;end
        end
        default: begin state_q<=S_IDLE;busy<=0;error<=1;error_code<=7;done<=1;end
      endcase
    end
  end
endmodule
`default_nettype wire
