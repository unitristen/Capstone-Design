module ID_stage(
	clk, 
	rst_n, 
	instruction,
	write_addr1, 
	write_addr2, 
	write_addr3, 
	write_addr4, 
	write_en1_32, 
	write_en2_32,
	write_en3_32,
	write_en4_32,
	write_en_128, 
	write_data_1_32, 
	write_data_2_32, 
	write_data_3_32, 
	write_data_4_32, 
	write_data_128,
	A_32, 
	B_32, 
	C_32, 
	D_32, 
	A_128, 
	B_128, 
	sign_extended,
	stall,
	flush,
	pc_mode,
	write_32_src,
	write_128_src,
	forward_mode,
	mem_op,
	check_flag
	write_en1_32_hzrd, 
	write_en2_32_hzrd,
	write_en3_32_hzrd,
	write_en4_32_hzrd,
	write_en_128_hzrd,
);

input clk, rst_n;

input [31:0] instruction;

input [4:0] write_addr1, write_addr2, write_addr3, write_addr4;
input [31:0] write_data_1, write_data_2, write_data_3, write_data_4; // data to be written into specified register
input write_en1_32, write_en2_32, write_en3_32, write_en4_32, write_en_128; // enable signals for register writes passed from WB

output [31:0] A_32, B_32, C_32, D_32;
output [127:0] A_128, B_128;
output [31:0] sign_extended;
output stall, flush;
output [1:0] ID_write_32_src, ID_write_128_src;
output [2:0] ID_forward_mode;
output [1:0] ID_mem_op, ID_check_flag, ID_pc_mode;
output write_en1_32_hzrd, write_en2_32_hzrd, write_en3_32_hzrd, write_en4_32_hzrd, write_en_128_hzrd;

wire hzrd_stall, hzrd_flush; // stall and flush outputs of the Hazard_Control module, assigned to ID_stage outputs
wire [1:0] write_32_src;
wire [1:0] write_128_src;
wire [2:0] forward_mode;
wire [1:0] mem_op, check_flag, pc_mode;
wire 15:0] immediate; // assign the lower 16 bits to the immediate wire for sign extension
wire [4:0] addrA, addrB, addrC, addrD; // addresses are set based on the instruction opcode
wire [5:0] opcode; // easy way of comparing opcode to potential values

assign stall = hzrd_stall;
assign flush = hzrd_flush;
assign ID_write_32_src = write_32_src;
assign ID_write_128_src = write_128_src;
assign ID_forward_mode = forward_mode;
assign ID_mem_op = mem_op;
assign ID_check_flag = check_flag;
assign ID_pc_mode = pc_mode;

assign opcode = instruction[31:26];
// NEED TO CONFIRM THESE
// addrA represents the Rs register
assign addrA = (opcode === 6'b001110) ? instruction[25:21] : instruction[20:16];
// addrB represents the Rt register 
assign addrB = instruction[15:11];
// special case for OTF and FTO logic
assign addrC = 	((opcode === 6'b010001) | (opcode === 6'b010010)) ? instruction[10:6];
// special case for OTF and FTO logic
assign addrD = 	((opcode === 6'b010001) | (opcode === 6'b010010)) ? instruction[5:1];

					//0010_10 LI, special case where immediate is 19-4
assign immediate = 	(opcode === 6'b001010) ? instruction[19:4] : 
					// for the shift operations we pass in a 6 bit value to shift (MIGHT NOT BE PROPERLY DESIGNED)
					((opcode === 6'b000111) | (opcode === 6'b001000) | (opcode === 6'b001001)) ? instruction[15:11] :
					// standard immediate logic
					instruction[15:0];

Control_Hazard Cntrl_Hzrd(
				.mem_busy(), // need to add this
				.instruction(instruction),
				.ID_EX_Rd(), // need to add this from pipeline register
				.EX_MEM_Rd(), // need to add this from pipeline register
				.MEM_WB_Rd(), // need to add this from pipeline register
				.stall(hzrd_stall),
				.flush(hzrd_flush),
				.pc_mode(pc_mode),
				.write_32_en1(write_en1_32_hzrd),
				.write_32_en2(write_en2_32_hzrd),
				.write_32_en3(write_en3_32_hzrd),
				.write_32_en4(write_en4_32_hzrd),
				.write_128_en(write_en1_128_hzrd),
				.write_32_src(write_32_src),
				.write_128_src(write_128_src),
				.forward_mode(forward_mode),
				.mem_op(mem_op),
				.check_flag(check_flag)
);

Register32 reg32(	
			.clk(clk),
			.rst_n(rst_n),
			.addrA(addrA),
			.addrB(addrB),
			.addrC(addrC),
			.addrD(addrD),
			.write_addr1(write_addr1), 
			.write_addr2(write_addr2),
			.write_addr3(write_addr3),
			.write_addr4(write_addr4),  
			.write_en1(write_en1_32),
			.write_en2(write_en2_32),
			.write_en3(write_en3_32),		
			.write_en4(write_en4_32),
			.write_data1(write_data_1), 
			.write_data2(write_data_2),
			.write_data3(write_data_3),
			.write_data4(write_data_4),
			.A(A_32), 
			.B(B_32),
			.C(C_32),
			.D(D_32)
);

Register128 reg128(	
			.clk(clk),
			.rst_n(rst_n),
			.addrA(addr_A), 
			.addrB(addr_B),
			.write_addr(write_addr1),
			.write_en(write_en_128),
			.write_data(write_data_1),
			.A(A_128),
			.B(B_128)
);

// extend the 16th bit to bits 32-17
assign sign_extended = {{16{immediate[15]}}, immediate};

endmodule
