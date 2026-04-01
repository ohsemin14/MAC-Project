// 단일 PE 설계
module PE (
  input logic clk,
  input logic reset_n,

  input logic signed [7:0] a_in, // 입력 (음수 포함)
  input logic signed [7:0] w_in, // 가중치 (음수 포함)

  input logic valid_in, // 유효 신호 in
  input logic acc_clear, // 누산기 초기화 제어 신호

  output logic signed [7:0] result_out, // 포화/스케일링 완료 최종 결과
  output logic valid_out, // 유효 신호 출력

  output logic valid_out_right, // 오른쪽 출력 신호 포트
  output logic acc_clear_out_right, // 누산 클리어 신호

  output logic signed [7:0] a_out, // 오른쪽 PE에 보낼 데이터
  output logic signed [7:0] w_out // 아래쪽 PE에 보낼 데이터
);

logic signed [15:0] a_w_mul; // 입력x가중치 잠깐 담을 곳
logic signed [31:0] acc_register; // 32bit 누산기 선언
logic signed [31:0] scaled_acc; // 시프트된 결과

assign a_w_mul = a_in * w_in; //combination
assign scaled_acc = acc_register >>> 8; // 산술 시프트 적용

always_ff @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    acc_register <= '0;
    a_out <= '0;
    w_out <= '0;
    valid_out_right <= 1'b0;
    acc_clear_out_right <= 1'b0;
  end else begin
    // 데이터 및 제어 신호 파이프라인 (제어 신호가 같이 넘어가니 무조건 전달)
    valid_out_right <= valid_in; // valid_in신호를 오른쪽으로 통과시키기
    a_out <= a_in;
    w_out <= w_in;
    acc_clear_out_right <= acc_clear;

    // 누산기 제어 로직
    if(acc_clear == 1'b1) begin // acc_clear가 1이면 acc_register = 0으로 초기화
      acc_register <= '0;
    end else if (valid_in == 1'b1) begin // 유효 신호 1 이면 누산 시작
      acc_register <= acc_register + a_w_mul;
    end
  end
end

always_comb begin
  if(scaled_acc > 127) begin
    result_out = 8'sd127;
  end else if(scaled_acc < -128) begin
    result_out = -8'sd128; // 음수 표현
  end else begin
    result_out = scaled_acc[7:0]; // 정상 범위 = 하위 8비트 가져오기.
  end
end

assign valid_out = acc_clear; // clear 신호가 들어오면 유효신호 출력

endmodule