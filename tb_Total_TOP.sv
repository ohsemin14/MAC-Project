`timescale 1ns/1ps
module tb_Total_TOP();
parameter Array_size = 8;

logic clk;
logic reset_n;
logic start;

logic signed [7:0] A_mat_in[0:7][0:7];
logic signed [7:0] W_mat_in[0:7][0:7];
logic signed [7:0] Golden_mat[0:7][0:7];

logic signed [7:0] result_out[0:Array_size-1][0:Array_size-1];

logic signed [7:0] a_mem [0:63]; // 파일 I/O 임시 1D 배열 선언
logic signed [7:0] w_mem [0:63];
logic signed [7:0] g_mem [0:63];

int i,j;
int error_cnt;

Total_TOP dut(.*);

initial begin
  clk = 0;
  forever #5 clk = ~clk;
end

initial begin
  $readmemh("activation_in.txt", a_mem);
  $readmemh("weight_in.txt", w_mem);
  $readmemh("golden_out_8bit.txt", g_mem);

  for(i=0; i<8; i++)begin // 1차원 배열 데이터 -> 2차원 포트 복사
    for(j=0; j<8; j++)begin
      A_mat_in[i][j] = a_mem[i*8+j];
      W_mat_in[i][j] = w_mem[j*8+i];
      Golden_mat[i][j] = g_mem[i*8+j];
    end
  end

  reset_n = 1'b0; start = 1'b0;
  error_cnt = 0;

  #20 reset_n <= 1'b1;

  @(posedge clk);
  start <= 1'b1;

  @(posedge clk);
  start <= 1'b0;

  repeat(24) begin
    @(posedge clk);
  end

  $display("=============================");
  $display("  Cross-Validation Start  ");
  $display("=============================");

  for(int i=0; i<8; i++)begin
    for(int j=0; j<8; j++)begin
      if(result_out[i][j] !== Golden_mat[i][j]) begin
        $display("[ERROR] [%0d][%0d] : RTL Output = %h, Golden = %h", i,j,result_out[i][j],
        Golden_mat[i][j]);
        error_cnt++;
      end
  end
end

if(error_cnt==0)
  $display("\n[SUCCESS] perfectly\n");
else
  $display("\n[FAILED] Found %0d error\n", error_cnt);

$display("=============================");
#20 $finish;
end

endmodule