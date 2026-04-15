module skewing_file #(
  parameter Array_size = 8
)(
  input logic clk,
  input logic reset_n,
  input logic [63:0] a_q,
  input logic [63:0] w_q,
  input logic data_en, // mac_controller 연결

  output logic signed[7:0] a_array_out [0:Array_size-1],
  output logic signed[7:0] w_array_out [0:Array_size-1]
  );

  logic signed [7:0] a_delay_reg [0:Array_size-1][0:Array_size-1];
  logic signed [7:0] w_delay_reg [0:Array_size-1][0:Array_size-1];

  always_ff @(posedge clk or negedge reset_n) begin
  if(!reset_n)begin
    a_delay_reg <= '{default:'0};
    w_delay_reg <= '{default:'0};
  end else begin
    for(int i =0; i<Array_size; i++)begin
      a_delay_reg[i][0] <= data_en ? $signed(a_q[i*8+:8]) : 8'sd0; // zero-padding
      w_delay_reg[i][0] <= data_en ? $signed(w_q[i*8+:8]) : 8'sd0;

      for(int j=1; j<Array_size; j++)begin
        a_delay_reg[i][j] <= a_delay_reg[i][j-1];
        w_delay_reg[i][j] <= w_delay_reg[i][j-1];
      end
    end
  end
end

always_comb begin
  for(int i=0; i<Array_size; i++)begin
    a_array_out[i] = a_delay_reg[i][i];
    w_array_out[i] = w_delay_reg[i][i];
  end
end

endmodule