module pc(clk, rst_n, pc_mode, reg_in, imm_in, pc);


// PC for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input [31:0] reg_in, imm_in; // input values from registers or immediates
input [1:0] pc_mode; // control signal for the pc (dictates how it is updated)
input clk, rst_n;
output reg [31:0] pc; // current value of the pc

// Mode values
localparam STALL = 2'b00; // (pc <- pc)
localparam NORMAL = 2'b01; // (pc <- pc + 1)
localparam REGISTER = 2'b10; // (pc <- reg_in)
localparam IMMEDIATE = 2'b11; // (pc <- imm_in)


////////////////////////////////////////////////////////////////////////////////


// PC Register
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) pc <= 32'h00000000; // asynch reset
	else begin
		case (pc_mode) // assigning register inputs according to the above local param descriptions
			STALL: pc <= pc;
			NORMAL: pc <= pc + 32'h00000001;
			REGISTER: pc <= reg_in;
			IMMEDIATE: pc <= imm_in;
		endcase
	end
end

endmodule
