module RegisterFile128(
	input clk,
	input rst_n,
	input [4:0] addrA,
	input [4:0] addrB,
	input [4:0] write_addr,
	input write_en,
	input [127:0] write_data,
	output [127:0] A,
	output [127:0] B
);

reg [31:0] regfile[128];

assign A = regfile[addrA];
assign B = regfile[addrB];

integer i;

always @(posedge clk) begin
	if (!rst_n) begin
		for (i = 0; i < 128; i = i + 1) begin
	  		regfile[i] <= 0;
		end
	end else begin
	 	if (write_en) regfile[write_addr] <= write_data;
    end
end

endmodule
