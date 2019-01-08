module IF_tb();


// IF pipeline stage for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
reg [31:0] reg_in, imm_in;
reg [1:0] pc_mode;
reg clk, rst_n;
wire [31:0] instruction;

// Mode values
localparam STALL = 2'b00; // (pc <- pc)
localparam NORMAL = 2'b01; // (pc <- pc + 1)
localparam REGISTER = 2'b10; // (pc <- reg_in)
localparam IMMEDIATE = 2'b11; // (pc <- imm_in)

// DUT
IF_stage DUT(clk, rst_n, pc_mode, reg_in, imm_in, instruction);


////////////////////////////////////////////////////////////////////////////////


// clk and rst
initial begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end
initial begin
	rst_n = 1'b0;
	#1 rst_n = 1'b1;
end

// Tests
initial begin
	#1;
	reg_in = 32'h00000004;
	imm_in = 32'h00000006;
	pc_mode = NORMAL;
	$monitor("IM: %h", instruction);
	#100; // wait for 10 instructions
	pc_mode = IMMEDIATE;
	#10; // read the immediate
	pc_mode = STALL;
	#50; // stall 5 cycles
	pc_mode = REGISTER;
	#10; // read the register
	pc_mode = NORMAL;
	#59; // get back to 10
	$stop();
end

endmodule
