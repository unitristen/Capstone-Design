module EX_stage(A_32, B_32, res_32, A_128, B_128, res_128, res_32_m, res_32_wb, res_128_m, res_128_wb, shift, op, forward_mode);


// EX pipeline stage for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input signed [127:0] A_128, B_128; // operands from the 128-bit registers
input [127:0] res_128_m, res_128_wb; // results from further pipelining stages for the forwarding unit
input signed [32:0] A_32, B_32; // operands from the 32-bit registers
input [32:0] res_32_m, res_32_wb; // results from further pipelining stages for the forwarding unit
input [5:0] op; // opcode of the current instruction
input [4:0] shift; // shift amount for SLL, SRA, and SRL instructions
input [2:0] forward_mode; // signal from the control unit telling the forwarder what to present to the ALUs
			  // BIT 0 - Pipeline Stage: 0 = M, 1 = WB
			  // BIT 1 - Operand: 0 = A, 1 = B
			  // BIT 2 - Forwarding Used: 0 = Yes, 1 = No
output signed [127:0] res_128; // output from the 128-bit ALU
output signed [31:0] res_32; // output from the 32-bit ALU

// Internal Sigs
wire [127:0] out_128; // 128-bit output of the forwarding unit
wire [31:0] out_32; // 32-bit output of the forwarding unit
wire signed [31:0] Af_32, Bf_32; // final inputs to the 32-bit ALU with forwarded values taken into account


////////////////////////////////////////////////////////////////////////////////


// Instantiated Modules
forwarder forward(forward_mode[0], res_32_m, res_32_wb, res_128_m, res_128_wb, out_32, out_128);
alu_128 alu128(Af_128, Bf_32, res_128, op[3:0]);
alu_32 alu32(Af_32, Bf_32, res_32, shift, op[4:0]);

// MUXes for determining ALU inputs
assign Af_32 = forward_mode[2] ? A_32 : 
		forward_mode[1] ? A_32 :
		out_32;
assign Bf_32 = forward_mode[2] ? B_32 : 
		forward_mode[1] ? out_32 :
		B_32;
assign Af_128 = forward_mode[2] ? A_128 : 
		forward_mode[1] ? A_128 :
		out_128;
assign Bf_128 = forward_mode[2] ? B_128 : 
		forward_mode[1] ? out_128 :
		B_128;


endmodule
