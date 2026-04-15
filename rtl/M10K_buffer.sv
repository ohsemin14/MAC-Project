// Quartus Insert template
module M10K_buffer#(
parameter int ADDR_WIDTH = 8, // Depth : 256
parameter int BYTE_WIDTH = 8, // byte 당 8bits
parameter int BYTES = 8, 
parameter int WIDTH = BYTES * BYTE_WIDTH // 64bits
)(
input logic [ADDR_WIDTH-1:0] waddr,
input logic [ADDR_WIDTH-1:0] raddr,
input logic [BYTES-1:0] be, //byte enable
input logic [WIDTH-1:0] wdata, //64bit 입력 데이터
input logic we, clk,
output logic [WIDTH - 1:0] q
);
localparam int WORDS = 1 << ADDR_WIDTH ;

// use a multi-dimensional packed array to model individual bytes within the word
logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:WORDS-1];

always_ff@(posedge clk) begin
	if(we) begin
    if(be[0]) ram[waddr][0] <= wdata[7:0];
    if(be[1]) ram[waddr][1] <= wdata[15:8];
    if(be[2]) ram[waddr][2] <= wdata[23:16];
    if(be[3]) ram[waddr][3] <= wdata[31:24];
    if(be[4]) ram[waddr][4] <= wdata[39:32];
    if(be[5]) ram[waddr][5] <= wdata[47:40];
    if(be[6]) ram[waddr][6] <= wdata[55:48];
    if(be[7]) ram[waddr][7] <= wdata[63:56];
  end
	q <= ram[raddr]; // 읽기 동작 1클럭 지연
end

endmodule