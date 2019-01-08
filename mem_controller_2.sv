module mem_controller_2( clk,rst_n,
			cpu_in,
			spart_in,
			audio_in,
			data_out,
			cpu_addr,
			audio_addr,
			cpu_op,
			spart_wr,
			audio_rd,
			busy,
			readdata,
			readdatavalid,
			waitrequest,
			address,
			byteenable_n,
			chipselect,
			writedata,
			read_n,
			write_n
			);
//===========================constants=================================
localparam SPART_BASE = 25'd0;
localparam FREE = 2'b00;
localparam BUSY_SPART = 2'b10;
localparam BUSY_CPU = 2'b01;
localparam BUSY_AUDIO = 2'b11;
localparam READ = 2'b01;
localparam WRITE = 2'b10;
//===========================Inout=================================

input clk, rst_n;
input [31:0] cpu_in;
input [15:0] spart_in;
input [31:0] audio_in;
input [31:0] cpu_addr;
input [31:0] audio_addr;
input [1:0] cpu_op;
input spart_wr; //spart write
input audio_rd; //audio read
input [15:0] readdata; //sdram input
input readdatavalid; //sdram input
input waitrequest; //sdram input

output [31:0] data_out;
output [1:0] busy;
output [24:0] address; //sdram output
output byteenable_n; //sdram output
output chipselect; //sdram output
output [15:0] writedata; //sdram output
output read_n, write_n; //sdram output 

//===========================regs & wires =================================
reg [1:0] busy_out, busy_in;
reg [1:0] op_out, op_in; //holds current operation READ=01 WRITE=10
reg [25:0] spart_addr_count, spart_addr_increment; //holds current operation READ=01 WRITE=10
reg [15:0] SDRAM_writedata_out, SDRAM_writedata_in; //holds the writedata for SDRAM
reg [25:0] SDRAM_addr_out, SDRAM_addr_in; //address sent to SDRAM
//===========================FSM LOGIC=================================

typedef enum  logic [2:0] {
  IDLE   = 3'b000,
  SPART_WR = 3'b001,
  WAIT = 3'b101,
  CPU_OP_LOW   = 3'b010,
  CPU_OP_HIGH  = 3'b110,
  AUDIO_OP_LOW     = 3'b011,
  AUDIO_OP_HIGH     = 3'b111
} state_t;
state_t curr_state, next_state;

// Sequential state transition
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) begin
    	curr_state <= IDLE; // default assignment
	busy_out <= FREE;
	spart_addr_count = 25'd0;
	SDRAM_writedata_out <= 16'd0; 
	SDRAM_addr_out <= 25'd0;
	op_out <= FREE;
  end
  else begin
    	curr_state <= next_state;
	busy_out <= busy_in;
	SDRAM_writedata_out <= SDRAM_writedata_in;
	SDRAM_addr_out <= SDRAM_addr_in;
	op_out <= op_in; 

	if(spart_addr_increment)
		spart_addr_count <= spart_addr_count +1;
	else
		spart_addr_count <= spart_addr_count;
  end

//combinational next state logic
always_comb begin
	case(curr_state)
		IDLE: begin
			if(!waitrequest && spart_wr) begin
				next_state = SPART_WR;
				busy_in = BUSY_SPART;
				op_in = WRITE;
				spart_addr_increment = 1'b0;
				SDRAM_writedata_in = spart_in;
				SDRAM_addr_in = SPART_BASE + spart_addr_count;
			end else begin
				next_state = IDLE;
				busy_in = FREE;
				op_in = FREE;
				spart_addr_increment = 1'b0;
				SDRAM_writedata_in = SDRAM_writedata_out;
				SDRAM_addr_in = SDRAM_addr_out;
			end
		end
		SPART_WR: begin
			
			next_state = WAIT;
			busy_in = BUSY_SPART;
			op_in = FREE;
			spart_addr_increment = 1'b1;
			SDRAM_writedata_in = SDRAM_writedata_out;
			SDRAM_addr_in = SDRAM_addr_out;
		end
		WAIT: begin
			if(waitrequest) begin
				next_state = WAIT;
				busy_in = BUSY_SPART;
				op_in = FREE;
				spart_addr_increment = 1'b0;
				SDRAM_writedata_in = SDRAM_writedata_out;
				SDRAM_addr_in = SDRAM_addr_out;
			end else begin
				next_state = IDLE;
				busy_in = FREE;
				op_in = FREE;
				spart_addr_increment = 1'b0;
				SDRAM_writedata_in = SDRAM_writedata_out;
				SDRAM_addr_in = SDRAM_addr_out;
			end 
		end
	endcase
end


//===========================OUTPUT LOGIC=================================
assign data_out = readdatavalid ? {16'hFFFF, readdata} : 32'hFFFFFFFF; //TODO: CHANGE LATER
assign busy = busy_out;
assign address = SDRAM_addr_out;
assign byteenable_n = 2'b00; //hardcoded to never mask anything
assign chipselect = 1; //always on
assign writedata = SDRAM_writedata_out;

assign read_n = ~op_out[0];
assign write_n = ~op_out[1]; //sdram output

endmodule