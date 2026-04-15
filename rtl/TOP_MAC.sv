module TOP_MAC #(
  parameter int Array_size = 8 // 8x8
)(
  input logic clk,
  input logic reset_n,
  // 2차원 배열 포트
  input logic signed [7:0] a_in_array [0:Array_size-1],
  input logic signed [7:0] w_in_array [0:Array_size-1],

  input logic valid_in,
  input logic acc_clear,

  output logic valid_out,
  // 현재는 8x8로 64개가 나와야함.
  output logic signed [Array_size*Array_size*8-1:0] result_out
  //output logic signed [7:0] result_out [0:Array_size-1][0:Array_size-1]
);

// 내부 배선 연결
// PE 사이를 연결하거나, 외부에서 들어온 신호를 PE에 전달할 선 데이터용 Wire
logic signed [7:0] a_wire [0:Array_size-1][0:Array_size-1];
logic signed [7:0] w_wire [0:Array_size-1][0:Array_size-1];

logic signed [7:0] internal_result [0:Array_size-1][0:Array_size-1];

// 제어 신호용 Wire
logic valid_wire_right [0:Array_size-1][0:Array_size-1];
logic clear_wire_right [0:Array_size-1][0:Array_size-1];

// 최종 출력 할당
assign valid_out = valid_wire_right[Array_size-1][Array_size-1];

genvar i,j;

generate
  for(i=0; i<Array_size; i++) begin : row
    for(j=0; j<Array_size; j++) begin : column
      logic signed [7:0] current_a_in; // 데이터 a_in
      if(j==0) begin // 제일 왼쪽 열이면 외부 입력 연결
        assign current_a_in = a_in_array[i];
      end else begin
        assign current_a_in = a_wire[i][j-1]; // 왼쪽 PE의 출력 연결
      end

      logic signed [7:0] current_w_in; // 데이터 w_in
      if(i==0) begin // w도 동일하게 실시
        assign current_w_in = w_in_array[j];
      end else begin
        assign current_w_in = w_wire[i-1][j];
      end

      logic current_valid_in;
      logic current_clear_in;
      if(j==0) begin // 제어 신호 선택 로직
        assign current_valid_in = valid_in;
        assign current_clear_in = acc_clear;
      end else begin
        assign current_valid_in = valid_wire_right[i][j-1];
        assign current_clear_in = clear_wire_right[i][j-1];
      end

      PE pe_list(
        .clk(clk), .reset_n(reset_n), .a_in(current_a_in), .w_in(current_w_in),
        .valid_in(current_valid_in), .acc_clear(current_clear_in), .result_out(internal_result[i][j]),
        .valid_out(), .a_out(a_wire[i][j]), .w_out(w_wire[i][j]),
        .valid_out_right(valid_wire_right[i][j]), .acc_clear_out_right(clear_wire_right[i][j])
      );
end
end
endgenerate
  always_comb begin
    for(int i=0; i<Array_size; i++) begin
      for(int j=0; j<Array_size; j++) begin
        result_out[(i*Array_size +j)*8 +:8] = internal_result[i][j];
        end
      end
    end

endmodule