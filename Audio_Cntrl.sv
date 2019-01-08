module Audio_Cntrl(
	input clk, 
	input rst_n,
	input play_pause,
	input stop,
	input [31:0] data_in, // data sent from mem
	input [1:0] mem_busy,
	input data_rdy, // signal saying data is ready to be transmitted
	output [31:0] data_addr,
	output mem_op
);

// data to be sent to aux
wire [31:0] output_data, data_addr_reg;
reg [31:0] chunk_counter; // need a chunk counter

// if stop is asserted, should we delete the data_in?

// if data is ready and the play_pause signal is in play mode, send the data to the audio output
assign output_data = ((data_rdy === 1'b1) & (play_pause === 1'b1) & (stop === 1'b0)) ? data_in : 32'b0;

// each chunk is 32 bits so we multiply the chunk counter by 32 and send that data_addr to mem to get next chunk
assign data_addr = 32'd32 * chunk_counter;

// mem_op MEM control line:
// 0 = Audio not requesting memory
// 1 = Audio requesting read

assign mem_op = (~stop & (play_pause === 1'b1)) ? 1'b1 : 1'b0;

// 2-bit MEM busy signal:
// 00 = memory not busy
// 01 = memory doing CPU task
// 10 = memory doing SPART task
// 11 = memory doing Audio task
// if mem is busy then we can't get data from it, if it's set to 11 then we should be fine?

// if mem isn't busy and the audio has not been paused or stopped, get next 32-bit audio chunk from memory
// can we access it if mem_busy is doing an audio task??
always @(posedge clk) begin
	if(!rst_n) begin
		chunk_counter = 0;
	end 
	else if ( ((mem_busy === 2'b00) | (mem_busy === 2'b11)) && (play_pause === 1'b1) && ~stop) begin
		chunk_counter += 1'b1; // increment the counter for each data chunk being sent
	end
end



endmodule
