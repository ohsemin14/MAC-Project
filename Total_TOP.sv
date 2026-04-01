module Total_TOP #(
  parameter Array_size = 8
)(
  input logic clk,
  input logic reset_n,
  input logic start,

  // 외부 포트
  input logic signed [7:0] A_mat_in [0:Array_size-1][0:7],
  input logic signed [7:0] W_mat_in [0:Array_size-1][0:7],

  output logic signed [7:0] result_out [0:Array_size-1][0:Array_size-1]
);

logic valid_wire;
logic acc_clear_wire;
logic signed [7:0] a_array_wire[0:Array_size-1];
logic signed [7:0] w_array_wire[0:Array_size-1];

MAC_Controller#(
  .Array_size(Array_size),
  .Matrix_K(8)
) u_controller(
  .clk(clk),
  .reset_n(reset_n),
  .start(start),
  .valid_out(valid_wire),
  .acc_clear_out(acc_clear_wire),
  .a_out(a_array_wire),
  .w_out(w_array_wire),
  .A_mat_in(A_mat_in),
  .W_mat_in(W_mat_in)
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
  .valid_out(),
  .result_out(result_out)
);

endmodule