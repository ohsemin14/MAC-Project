module MAC_Controller#(
parameter int Array_size = 8,
parameter int Matrix_K = 8
)(
  input logic clk,
  input logic reset_n, 
  input logic start, // 시작신호

  output logic valid_out,
  output logic capture_pulse,
  output logic acc_clear_out,
  output logic data_en, // 유효 데이터인지 0으로 덮을지 알려주는 enable 신호 -> skewing이랑 연결

  output logic [2:0] mac_addr_out //M10K 메모리 읽기 주소 출력
);

localparam int MAX_Cycles = (Array_size*2) + Matrix_K;

typedef enum logic[1:0] { // 3-state
  IDLE = 2'b00,
  RUN = 2'b01,
  DONE = 2'b10
} state_t;

state_t current_state, next_state; // 현재, 다음상태를 담을 변수선언

logic [7:0] cycle_cnt; // 사이클 지연 신호.
logic [2:0] mac_addr_cnt; // 주소 카운트
logic internal_data_en;

always_ff @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    current_state <= IDLE;
    cycle_cnt <= '0;
    mac_addr_cnt <= '0;
    internal_data_en <= 1'b0;
  end else begin
    current_state <= next_state; // 매 클럭마다 다음상태로 업데이트

    if(current_state == RUN) begin // 카운터 로직
      cycle_cnt <= cycle_cnt + 1'b1;
      if(mac_addr_cnt < Array_size-1) begin
        mac_addr_cnt <= mac_addr_cnt + 1'b1; // 8행 데이터까지만 읽기.
      end 

      if(cycle_cnt < Array_size) begin
        internal_data_en <= 1'b1;
      end else begin
        internal_data_en <= 1'b0;
      end

    end else begin
      cycle_cnt <= '0;
      mac_addr_cnt <= '0;
      internal_data_en <= 1'b0;
    end
  end
end

// 메모리에서 오는데 클럭이 1지연되므로, 1클럭 delay해서 출력.
always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
      data_en <= 1'b0;
    end else begin
      data_en <= internal_data_en;
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
    mac_addr_out <= '0;
    capture_pulse <= 1'b0;
    end else begin
    valid_out <= 1'b0;
    acc_clear_out <= 1'b0;
    capture_pulse <= 1'b0;
    mac_addr_out <= mac_addr_cnt;

    if(current_state == RUN)begin
      valid_out <= 1'b1;
    end else if(current_state == DONE)begin
      capture_pulse <= 1'b1; // DONE이 되는 순간 캡쳐 신호 출력 -> output_reg에 전달.
    acc_clear_out <= 1'b1; // 누산기 초기화
    end
  end
end
endmodule