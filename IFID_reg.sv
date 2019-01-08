module IFID_reg(clk, rst_n, stall, instruction_in, instruction_out);


// IF/ID pipeline register for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input [31:0] instruction_in; // instruction from the IF stage
input clk, rst_n, stall;
output reg [31:0] instruction_out; // instruction for the ID stage


////////////////////////////////////////////////////////////////////////////////


// Register
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) instruction_out <= 32'h00000000;
	else if (stall) instruction_out <= instruction_out;
	else instruction_out <= instruction_in;
end


endmodule
