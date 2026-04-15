module Total_TOP #(
  parameter Array_size = 8
)(
  input logic clk,
  input logic reset_n,
  input logic start,

  // A행렬 메모리
  input logic [63:0] adata,
  input logic [2:0] addr_a,
  input logic we_a, // 활성화 신호

  // W행렬 메모리
  input logic [63:0] wdata, 
  input logic [2:0] addr_w,
  input logic we_w,

  input logic [2:0] addr_res,
  output logic [63:0] rdata,

  output logic mac_done // 연산 완료 상태 신호 포트
);

// 내부 배선 연결
// PE 사이를 연결하거나, 외부에서 들어온 신호를 PE에 전달할 선 데이터용 Wire
logic valid_wire;
logic acc_clear_wire;
logic signed [7:0] a_array_wire[0:Array_size-1];
logic signed [7:0] w_array_wire[0:Array_size-1];

logic [2:0] mac_read_addr;
logic [63:0] a_buffer_q; 
logic [63:0] w_buffer_q;

logic signed [Array_size*Array_size*8-1:0] result_out_wire;
logic data_en;
logic capture_pulse;

skewing_file #(
  .Array_size(Array_size)
) u_skewing(
  .clk(clk),
  .reset_n(reset_n),
  .a_q(a_buffer_q),
  .w_q(w_buffer_q),
  .a_array_out(a_array_wire),
  .w_array_out(w_array_wire),
  .data_en(data_en)
);

output_reg #(
  .Array_size(Array_size)
) u_output_reg(
  .clk(clk),
  .reset_n(reset_n),
  .valid_in(capture_pulse),
  .addr_res(addr_res),
  .result_in(result_out_wire),
  .rdata(rdata)
);

M10K_buffer#(
  .ADDR_WIDTH(3),
  .BYTE_WIDTH(8),
  .BYTES(8)
) u_M10K_buffer_a(
  .waddr(addr_a),
  .raddr(mac_read_addr),
  .be(8'hFF),
  .wdata(adata),
  .we(we_a),
  .clk(clk),
  .q(a_buffer_q)
);

M10K_buffer#(
  .ADDR_WIDTH(3),
  .BYTE_WIDTH(8),
  .BYTES(8)
) u_M10K_buffer_w(
  .waddr(addr_w),
  .raddr(mac_read_addr),
  .be(8'hFF),
  .wdata(wdata),
  .we(we_w),
  .clk(clk),
  .q(w_buffer_q)
);

MAC_Controller#(
  .Array_size(Array_size),
  .Matrix_K(8)
) u_controller(
  .clk(clk),
  .reset_n(reset_n),
  .start(start),
  .valid_out(valid_wire),
  .acc_clear_out(acc_clear_wire),
  .data_en(data_en),
  .mac_addr_out(mac_read_addr),
  .capture_pulse(capture_pulse)
);

TOP_MAC#(
  .Array_size(Array_size)
) u_MAC(
  .clk(clk),
  .reset_n(reset_n),
  .a_in_array(a_array_wire),
  .w_in_array(w_array_wire),
  .valid_in(valid_wire),
  .acc_clear(acc_clear_wire),
  .valid_out(mac_done),
  .result_out(result_out_wire)
);

endmodule