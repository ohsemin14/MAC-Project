`timescale 1ns/1ps
module tb_Total_TOP_v2();
parameter Array_size = 8;

logic clk;
logic reset_n;
logic start;

logic [63:0] adata;
logic [2:0] addr_a;
logic we_a;

logic [63:0] wdata;
logic [2:0] addr_w;
logic we_w;

logic [2:0] addr_res;
logic [63:0] rdata;
logic mac_done;

logic [63:0] a_mem [0:Array_size-1];
logic [63:0] w_mem [0:Array_size-1];
logic [63:0] g_mem [0:Array_size-1];

Total_TOP #(
  .Array_size(Array_size)
) dut (.*);

initial begin
  clk = 1'b0;
  forever #5 clk = ~clk;
end

integer pass_cnt, fail_cnt;

initial begin
  $dumpfile("MAC_Power.vcd");
  $dumpvars(0, tb_Total_TOP_v2.dut);

  $readmemh("activation_in_v2.txt", a_mem);
  $readmemh("weight_in_v2.txt", w_mem);
  $readmemh("golden_out_8bit_v2.txt", g_mem);

  reset_n = 1'b0;
  start = 1'b0;
  adata = 64'h0;
  addr_a = 3'h0;
  we_a = 1'b0;
  wdata = 64'h0;
  addr_w = 3'h0;
  we_w = 1'b0;
  addr_res = 3'h0;
  pass_cnt = 0;
  fail_cnt = 0;

repeat(2) @(posedge clk);
@(negedge clk);
reset_n = 1'b1;

// A행렬
$display("[%0t ns] A maxtrix M10K write start", $time);
for(int i=0; i<Array_size; i++)begin
  @(negedge clk)
  we_a = 1'b1;
  addr_a = i[2:0];
  adata = a_mem[i];
end
@(negedge clk)
we_a = 1'b0;
$display("[%0t ns] A maxtrix M10K write complete", $time);

$display("=============================");

// W행렬
$display("[%0t ns] W maxtrix M10K write start", $time);
for(int i=0; i<Array_size; i++)begin
  @(negedge clk)
  we_w = 1'b1;
  addr_w = i[2:0];
  wdata = w_mem[i];
end
@(negedge clk)
we_w = 1'b0;
$display("[%0t ns] W maxtrix M10K write complete", $time);

$display("=============================");

repeat(2) @(negedge clk); // 안정화 위해 대기

$display("[%0t ns] start signal", $time);
@(negedge clk); start=1'b1;
@(negedge clk); start=1'b0;

$display("[%0t ns] wait for operation", $time);
wait(dut.u_controller.capture_pulse == 1'b1);
@(negedge clk);
$display("[%0t ns] complete, result read start", $time);

for(int i=0; i<Array_size; i++)begin
  @(negedge clk)
  addr_res = i[2:0];
  
  @(posedge clk);
  #1;

  if(rdata === g_mem[i])begin
    $display("[PASS] Row %0d: rdata = %016h", i, rdata);
    pass_cnt++;
  end else begin
    $display("[FAIL] ROW %0d: got %016h | expected %016h", i, rdata, g_mem[i]);
    fail_cnt++;
  end
end
$display("=============================");
$display("[final result : %0d / %0d PASS]", pass_cnt, Array_size);
if(fail_cnt ==0)begin
  $display("ALL PASS, SUCCESS");
end else begin
  $display("%d FAIL",fail_cnt);
$display("=============================");
end
$finish;
end
endmodule