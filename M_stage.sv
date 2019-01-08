module M_stage(clk, rst_n, data_in, sdram_in, data_addr, sdram_addr, mem_busy, mem_mode, data_out, sdram_out, mem_op, mem_stall,
	send_data, received_data, stop_data, received_ak, stop_ak, audio_rdy, flag_val, flag_mode);


// M pipeline stage for the 554 CPU


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

input received_data; // signal from SPART saying new data has been received
input stop_data; // signal from SPART saying to stop playback
output send_data; // signal to SPART saying that data is ready to be sent to the host PC
output received_ak, stop_ak; // signals to SPART saying respective input flags have been ready
output audio_rdy; // signal to AUDIO saying song data is ready to be played
output reg [31:0] flag_val; // value of flag read to be stored in a 32-bit register
input [2:0] flag_mode; // signal from the Control module saying which combination of flags to read/set


////////////////////////////////////////////////////////////////////////////////


// Instantiated Modules
perph_int PERPHINT(send_data, received_data, stop_data, received_ak, stop_ak, audio_rdy, flag_val, flag_mode);
mem_int MEMINT(clk, rst_n, data_in, sdram_in, data_addr, sdram_addr, mem_busy, mem_mode, data_out, sdram_out);


endmodule
