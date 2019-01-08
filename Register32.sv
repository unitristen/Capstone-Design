module RegisterFile32(
	input clk,
	input rst_n,
	input [4:0] addrA,
	input [4:0] addrB,
	input [4:0] addrC,
	input [4:0] addrD,
	input [4:0] write_addr1,
	input [4:0] write_addr2,
	input [4:0] write_addr3,
	input [4:0] write_addr4,
	input [1:0] write_en1,
	input [1:0] write_en2,
	input [1:0] write_en3,
	input [1:0] write_en4,
	input [31:0] write_data1,
	input [31:0] write_data2,
	input [31:0] write_data3,
	input [31:0] write_data4,
	output [31:0] A,
	output [31:0] B,
	output [31:0] C,
	output [31:0] D
);

reg [31:0] regfile[32];

assign A = regfile[addrA];
assign B = regfile[addrB];
assign C = regfile[addrC];
assign D = regfile[addrD];

integer i;

always @(posedge clk) begin
	if (!rst_n) begin
		for (i = 0; i < 32; i = i + 1) begin
	  		regfile[i] <= 0;
		end
	end else begin
	 	if (write_en1) regfile[write_addr1] <= write_data1;
		if (write_en2) regfile[write_addr2] <= write_data2;
		if (write_en3) regfile[write_addr3] <= write_data3;
		if (write_en4) regfile[write_addr4] <= write_data4;
    end
end

endmodule
