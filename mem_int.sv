module mem_int(clk, rst_n, data_in, sdram_in, data_addr, sdram_addr, mem_busy, mem_mode, data_out, sdram_out, mem_op, mem_stall);


// Memory interface for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input clk, rst_n;
input [31:0] data_in; // data from CPU for M stage
input [31:0] sdram_out; // data from SDRAM for M stage
input [31:0] data_addr; // address for the SDRAM to be read from/written to from the CPU
input [1:0] mem_busy; // busy line from memory with the following values
		      // 00 = memory not busy
		      // 01 = memory doing CPU task
		      // 10 = memory doing SPART task
		      // 11 = memory doing Audio task
input [1:0] mem_mode; // signal from the Control module that tels the FSM what to request from the SDRAM controller with the following values
		      // 00 = memory not requested
		      // 01 = memory read requested
		      // 10 = memory write requested
output reg mem_stall; // signal to tell control module to wait for memory
output [31:0] data_out; // data from the M stage for the CPU
output [31:0] sdram_in; // data from the M stage for the SDRAM
output [31:0] sdram_addr; // address for the SDRAM to be read from/written to from the M stage
output reg [1:0] mem_op; // signal to SDRAM controller with what the CPU is requesting with the following values
			 // 00 = CPU not requesting memory
			 // 01 = CPU requesting read
			 // 10 = CPU requesting write

// FSM states
typedef enum reg [1:0] {IDLE, WAIT_READ, WAIT_WRITE, WAIT_FINISH} state_t;
state_t state, next_state;


////////////////////////////////////////////////////////////////////////////////


// SDRAM connections
assign sdram_addr = data_addr;
assign sdram_in = data_in;
assign data_out = sdram_out;

// State Flops
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= next_state;
end

// FSM outputs/next state
always_comb begin
	// Default values
	mem_op = 2'b00;
	mem_stall = 1'b0;
	next_state = IDLE;
	// State behavior
	case (state)
		IDLE: begin
			if (mem_mode == 2'b01) begin
				next_state = WAIT_READ;
				mem_stall = 1'b1;
				mem_op = 2'b01;
			end
			else if (mem_mode == 2'b10) begin
				next_state = WAIT_WRITE;
				mem_stall = 1'b1;
				mem_op = 2'b10;
			end
		end
		WAIT_READ: begin
			mem_stall = 1'b1;
			mem_op = 2'b01;
			if (mem_busy == 2'b01)
				next_state = WAIT_FINISH;
		end
		WAIT_WRITE: begin
			mem_stall = 1'b1;
			mem_op = 2'b10;
			if (mem_busy == 2'b01)
				next_state = WAIT_FINISH;
		end
		WAIT_FINISH: begin
			mem_stall = 1'b1;
			if (mem_busy == 2'b00) begin
				mem_stall = 1'b0;
				next_state = IDLE;
			end
		end
	endcase
end

endmodule
