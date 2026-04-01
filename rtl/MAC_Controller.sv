module MAC_Controller#(
parameter int Array_size = 8,
parameter int Matrix_K = 8
)(
  input logic clk,
  input logic reset_n, 
  input logic start, // 시작신호

// 외부에서 전체 행렬 8x8 받아오는 2차원 포트 2개
  input logic signed [7:0] A_mat_in [0:Array_size-1][0:Matrix_K-1],
  input logic signed [7:0] W_mat_in [0:Array_size-1][0:Matrix_K-1],

  output logic valid_out,
  output logic acc_clear_out,
  output logic signed [7:0] a_out[0:Array_size-1],
  output logic signed [7:0] w_out[0:Array_size-1]
);

localparam int MAX_Cycles = (Array_size*2) + Matrix_K;

typedef enum logic[1:0] { // 3-state
  IDLE = 2'b00,
  RUN = 2'b01,
  DONE = 2'b10
} state_t;

state_t current_state, next_state; // 현재, 다음상태를 담을 변수선언

logic [7:0] cycle_cnt; // 사이클 지연 신호.

always_ff @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    current_state <= IDLE;
    cycle_cnt <= '0;
  end else begin
    current_state <= next_state; // 매 클럭마다 다음상태로 업데이트

    if(current_state == RUN) begin // 카운터 로직
      cycle_cnt <= cycle_cnt + 1'b1;
    end else begin
      cycle_cnt <= '0;
    end
  end
end

always_comb begin
  next_state = current_state; // latch 방지
  case (current_state) // case문으로 간단하게 현재 상태에 따른 다음 상태 결정
    IDLE : begin
      if(start == 1'b1) begin
        next_state = RUN;
      end
    end

    RUN : begin
      if(cycle_cnt>=MAX_Cycles) begin
        next_state = DONE;
      end
    end

    DONE : begin
      next_state = IDLE;
    end
    default: next_state = IDLE;
  endcase
end

always_ff @(posedge clk or negedge reset_n)begin
  if(!reset_n)begin
    valid_out <= 1'b0;
    acc_clear_out <= 1'b0;
    for(int i=0; i<Array_size; i++)begin
      a_out[i] <= 8'sd0;
      w_out[i] <= 8'sd0;
    end
  end else begin
    valid_out <= 1'b0;
    acc_clear_out <= 1'b0;
    if(current_state == RUN)begin
      valid_out <= 1'b1;
    for(int i=0; i<Array_size; i++)begin
      if(cycle_cnt>=i && cycle_cnt < i+Matrix_K)begin
        a_out[i] <= A_mat_in[i][cycle_cnt-i]; // cycle-i 번째 데이터 주입
        w_out[i] <= W_mat_in[i][cycle_cnt-i];
      end else begin
        a_out[i] <= 8'sd0;
        w_out[i] <= 8'sd0; 
      end
    end
  end else if(current_state == DONE)begin
    acc_clear_out <= 1'b1; // 누산기 초기화
  end
end
end
endmodule