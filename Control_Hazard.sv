//mem_busy
//00 = memory not busy
//01 = memory doing CPU task
//10 = memory doing SPART task
//11 = memory doing Audio task

//Opcode [31:26]
//Instruction Description
//0000_01 ADD
//0000_10 SUB
//0000_11 NOT
//Inverts a register
//0001_00 AND
//ANDs two registers
//0001_01 OR
//ORs two registers
//0001_10 XOR
//XORs two registers
//0001_11 SLL
//Logical Left shifts a register
//0010_00 SRA
//Arithmetic Right shifts a register
//0010_01 SRL
//Logical Left shifts a register
//0010_10 LI
//Loads a register with an immediate
//0010_11 LD
//Loads a value from memory to a register
//0011_00 ST
//Stores a value from a register to memory
//0011_01 JI
//PC jumps to an immediate
//0011_10 JR
//PC jumps to a register value
//0011_11 BEQ
//Branch if equal (NZ = x1)
//0100_00 BNE
//Branch if not equal (NZ = x0)
//0100_01 FTO
//Write one 128-bit register to four 32-bit registers
//0100_10 OTF
//Write four 32-bit registers to on 128-bit register
//0100_11 DEC
//Does one step of AES decryption on a 128-bit register
//0101_00 DECF
//Does the final step of AES decryption on a 128-bit register
//0101_01 XORE
//Bitwise XOR operation on two 128-bit registers
//0101_10 FLC
//Checks flags from the SPART
//0101_11 FLS
//Sets flag to the SPART or Audio

module Control_Hazard(
		input [1:0] mem_busy,
		input [31:0] instruction,
		input [4:0] ID_EX_Rd,
		input [4:0] EX_MEM_Rd,
		input [4:0] MEM_WB_Rd,
		output stall,
		output flush,
		output [1:0] pc_mode,
		output write_32_en1,
		output write_32_en2,
		output write_32_en3,
		output write_32_en4,
		output write_128_en,
		output [1:0] write_32_src, // do this need to be input from WB stage?
		output [1:0] write_128_src, // do this need to be input from WB stage?
		output [2:0] forward_mode,
		output [1:0] mem_op,
		output [1:0] check_flag,
		output [31:0] pc_jump
);
// write_32_src is passed from WB stage and needs to signify what signal to be written, depends on stuff like audio/spart interface
// OTF and other signals so we need to figure out what number will correlate to what execution
// same with write_128_src but this will only really depend on FTO signal

// something is passed from WB stage over the the register files and then to the control hazard module. figure this out (ID_EX_mr?)

wire [5:0] opcode = instruction[31:26];

// if we have a branch instruction or a mem_stall signal, we should stall
assign stall =  ((opcode === 6'b001111) | (opcode === 6'b010000) | (mem_stall)) ? 1'b1 :
	       		1'b0;

assign flush = //if branch is taken (determine based on zero flag computed in the ALU stage, this is why we stall once)

assign audio_rdy = 

assign pc_mode = 

assign forward_mode = 

// all operators that make use of the 128-bit register
assign write_128_en = ((opcode === 6'b010010) | (opcode === 6'b010011) | (opcode === 6'b010100) | (opcode === 6'b010101)) ? 1'b1 : 1'b0;

// all operators that make use of the 32-bit register
assign write_32_en1 = ((opcode === 6'b010001) | (opcode === 6'b000001) | (opcode === 6'b000010) | (opcode === 6'b000011) | (opcode === 6'b000100)
					  | (opcode === 6'b000101) | (opcode === 6'b000110) | (opcode === 6'b000111) | (opcode === 6'b001000) | (opcode === 6'b001001)
					  | (opcode === 6'b001010) | (opcode === 6'b001011)) ? 1'b1 : 1'b0;

// only the OTF operator will enable the 2-4 32-bit register write enables
assign write_32_en2 = (opcode === 6'b010001) ? 1'b1 : 1'b0;
assign write_32_en3 = (opcode === 6'b010001) ? 1'b1 : 1'b0;
assign write_32_en4 = (opcode === 6'b010001) ? 1'b1 : 1'b0;

//assign check_flag = 