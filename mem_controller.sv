module mem_controller( clk,rst_n,
			cpu_in,
			spart_in,
			audio_in,
			data_out,
			cpu_addr,
			spart_addr,
			audio_addr,
			cpu_op,
			spart_op,
			audio_op,
			busy,
			readdata,
			readdatavalid,
			waitrequest,
			address,
			byteenable_n,
			chipselect,
			writedata,
			read_n,
			write_n);
//===========================Inout=================================

input clk, rst_n;
input [31:0] cpu_in;
input [31:0] spart_in;
input [31:0] audio_in;
input [31:0] cpu_addr;
input [31:0] spart_addr;
input [31:0] audio_addr;
input [1:0] cpu_op;
input [1:0] spart_op;
input audio_op;
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
reg [31:0] data_reg_out, data_reg_in; //holds the input from SDRAM
reg [1:0] op_out, op_in; //holds current operation

//===========================FSM LOGIC=================================

typedef enum  logic [2:0] {
  IDLE   = 3'b000,
  SPART_OP_LOW = 3'b001,
  SPART_OP_HIGH = 3'b101,
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
	busy_out <= 2'b0;
	data_reg_out <= 32'd0;//defaults as undriven
	op_out <= 2'b00;
  end
  else begin
    curr_state <= next_state;
	busy_out <= busy_in;
	data_reg_out <= data_reg_in;
	op_out <= op_in;
  end

//combinational next state logic
always_comb begin
	case(curr_state)

		//check the op inputs, assigns the next state based on the spart -> cpu
		// -> audio priority, and assigns busy_in
		IDLE: begin
		
			busy_in = busy_out;
			op_in = op_out;
			data_reg_in = data_reg_out;

			if(spart_op == 2'b01 || spart_op == 2'b10) begin
				next_state = SPART_OP_LOW;
				busy_in = 2'b10;
				op_in = spart_op;
			end
			else if(spart_op == 2'b00 && (cpu_op == 2'b10 || cpu_op==2'b01)) begin
				next_state = CPU_OP_LOW;
				busy_in = 2'b01;
				op_in = cpu_op;
			end
			else if(spart_op == 2'b00 && cpu_op == 2'b00 && audio_op == 1'b1)begin
				next_state = AUDIO_OP_LOW;
				busy_in = 2'b11;
				op_in = {1'b0, audio_op};
			end
			else begin
				next_state = IDLE;
				busy_in = 2'b00;
				op_in = 2'b0;
			end
		end

		//must send/receive lower half and change states
		SPART_OP_LOW: begin

			busy_in = busy_out;
			op_in = 2'b00;
			data_reg_in = data_reg_out;

			if(waitrequest) begin
				next_state = SPART_OP_LOW;
			end else begin
				next_state = SPART_OP_HIGH;
				op_in = spart_op;

			end
			
			if(readdatavalid) begin
				data_reg_in[15:0] = readdata;
			end else begin
				data_reg_in[15:0] = data_reg_out[15:0];
			end			

		end
		//must send/receive upper half, reset busy, move to idle
		SPART_OP_HIGH: begin
		
			busy_in = busy_out;
			op_in = 2'b00;
			data_reg_in = data_reg_out;

			if(waitrequest) begin
				next_state = SPART_OP_HIGH;
				busy_in = busy_out;
			//	op_in = op_out;
			end else begin
				next_state = IDLE;
				busy_in = 2'b00;
				op_in = 2'b0;
			end
			
			if(readdatavalid) begin
				data_reg_in[31:16] = readdata;
			end else begin
				data_reg_in[31:16] = data_reg_out[31:16];
			end			

		end

		//must send/receive lower half and change states
		CPU_OP_LOW: begin
		
			busy_in = busy_out;
			op_in = op_out;
			data_reg_in = data_reg_out;

			if(waitrequest) begin
				next_state = CPU_OP_LOW;
			end else begin
				next_state = CPU_OP_HIGH;
			end

			if(readdatavalid) begin
				data_reg_in[15:0] = readdata;
			end else begin
				data_reg_in[15:0] = data_reg_out[15:0];
			end
			
		end
		//must send/receive upper half, reset busy, move to idle
		CPU_OP_HIGH: begin
		
			busy_in = busy_out;
			op_in = op_out;
			data_reg_in = data_reg_out;
			
			if(waitrequest) begin
				next_state = CPU_OP_HIGH;
				busy_in = busy_out;
				op_in = op_out;
			end else begin
				next_state = IDLE;
				busy_in = 2'b00;
				op_in = 2'b0;
			end
			
			if(readdatavalid) begin
				data_reg_in[31:16] = readdata;
			end else begin
				data_reg_in[31:16] = data_reg_out[31:16];
			end

		end
		//must send/receive lower half and change states
		AUDIO_OP_LOW: begin
		
			busy_in = busy_out;
			op_in = op_out;
			data_reg_in = data_reg_out;

			if(waitrequest) begin
				next_state = AUDIO_OP_LOW;
			end else begin
				next_state = AUDIO_OP_HIGH;
			end
			
			if(readdatavalid) begin
				data_reg_in[15:0] = readdata;
			end else begin
				data_reg_in[15:0] = data_reg_out[15:0];
			end
		end
		//must send/receive upper half, reset busy, move to idle
		AUDIO_OP_HIGH: begin
		
			busy_in = busy_out;
			op_in = op_out;
			data_reg_in = data_reg_out;
			
			if(waitrequest) begin
				next_state = AUDIO_OP_HIGH;
				busy_in = busy_out;
				op_in = op_out;
			end else begin
				next_state = IDLE;
				busy_in = 2'b00;
				op_in = 2'b0;
			end
			
			if(readdatavalid) begin
				data_reg_in[31:16] = readdata;
			end else begin
				data_reg_in[31:16] = data_reg_out[31:16];
			end
		end
	endcase

end


//===========================OUTPUT LOGIC=================================
assign  data_out = data_reg_out;

assign busy = busy_out;

//if we are sending the lower 2 bytes, then we take the given address
//else, we increment the address for the upper 2 bytes
assign address = (curr_state == SPART_OP_LOW ) ? spart_addr[24:0] : //sdram address
						(curr_state == SPART_OP_HIGH ) ? spart_addr[24:0] + 1 :
						(curr_state == CPU_OP_LOW) ? cpu_addr[24:0] :
						(curr_state == CPU_OP_HIGH) ? cpu_addr[24:0] + 1 :
						(curr_state == AUDIO_OP_LOW) ? audio_addr[24:0] :
						(curr_state == AUDIO_OP_HIGH) ? audio_addr[24:0] + 1 :
						24'd0;

assign byteenable_n = 2'b11; //hardcoded to never mask anything
assign chipselect = 1; //always on
assign writedata = (curr_state == SPART_OP_LOW ) ? spart_in[15:0] : //data to write on sdram
						(curr_state == SPART_OP_HIGH ) ? spart_in[31:16] :
						(curr_state == CPU_OP_LOW) ? cpu_in[15:0] :
						(curr_state == CPU_OP_HIGH) ? cpu_in[31:16] :
						(curr_state == AUDIO_OP_LOW) ? audio_in[15:0] :
						(curr_state == AUDIO_OP_HIGH) ? audio_in[31:16] :
						24'dx;
assign read_n = !(curr_state != IDLE && op_out == 2'b01);
assign write_n = !(curr_state != IDLE && op_out == 2'b10); //sdram output

endmodule