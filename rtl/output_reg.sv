module output_reg#(
  parameter Array_size = 8
)(
  input logic clk,
  input logic reset_n,
  input logic valid_in, // valid signal for capture register
  input logic [2:0] addr_res, // 읽어갈 주소

  input logic signed [Array_size*Array_size*8-1:0] result_in,

  output logic [63:0] rdata // MUX를 거쳐 밖으로 나가는 데이터
);

logic signed [7:0] result_out_buffer [0:Array_size-1][0:Array_size-1];

always_ff @(posedge clk or negedge reset_n) begin
  if(!reset_n)begin
    result_out_buffer <= '{default:'0};
  end else if(valid_in)begin
    for(int i=0; i<Array_size; i++)begin
      for(int j=0; j<Array_size; j++)begin
        result_out_buffer[i][j] <= result_in[(i*Array_size +j)*8 +:8];
        end
    end
  end
end

always_comb begin
  rdata = '0;
  for(int i=0; i<Array_size; i++)begin
    rdata[i*8 +: 8] = result_out_buffer[addr_res][i];
  end  
end

endmodule // 4-14 시작시 참고사항
// valid_in 고칠 필요 없음. capture_pulse mac_controller부분에서 해놨으니까 이제 Total_TOP에서 고쳐야함.