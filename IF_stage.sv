module IF_stage(clk, rst_n, pc_mode, reg_in, imm_in, instruction);


// IF pipeline stage for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input [31:0] reg_in, imm_in; // input values from registers or immediates
input [1:0] pc_mode; // control signal for the pc (dictates how it is updated)
		     // STALL = 00: pc <- pc
		     // NORMAL = 01: pc <- pc + 1
		     // REGISTER = 10: pc <- reg_in
		     // IMMEDIATE = 11: pc <- imm_in
input clk, rst_n;
output [31:0] instruction; // instruction read from the instruction memory ROM

// Internal Sigs
wire [31:0] pc; // current pc value

////////////////////////////////////////////////////////////////////////////////


// Instantiated Modules
instruction_mem instructionMem(pc, instruction);
pc PC(clk, rst_n, pc_mode, reg_in, imm_in, pc);


endmodule
