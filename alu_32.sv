module alu_32(A, B, res, shift, op);


// 32-bit ALU for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input signed [31:0] A, B; // operands used in calculations
input [4:0] shift; // shift amount for SLL, SRA, and SRL instructions
input [3:0] op; // lower four bits of the instruction opcode
output reg signed [31:0] res; // result of the datapath

// OpCode values
localparam ADD = 4'h1;
localparam SUB = 4'h2;
localparam NOT = 4'h3;
localparam AND = 4'h4;
localparam OR = 4'h5;
localparam XOR = 4'h6;
localparam SLL = 4'h7;
localparam SRA = 4'h8;
localparam SRL = 4'h9;
localparam LD = 4'hb;
localparam ST = 4'hc;


////////////////////////////////////////////////////////////////////////////////


// Datapath assignment
always_comb begin
	res = A; // default value of res
	case (op)
		ADD: res = A + B;
		SUB: res = A - B;
		NOT: res = ~A;
		AND: res = A & B;
		OR: res = A | B;
		XOR: res = A ^ B;
		SLL: res = A << shift;
		SRA: res = A >>> shift;
		SRL: res = A >> shift;
		LD: res = A + B;
		ST: res = A + B;
	endcase
end


endmodule
