module sampleConvertSimple(clk, rst_n, in, out, ready);

input clk, rst_n;
input [31:0] in;
output ready; 
output [31:0] out;

/* we are converting from 8khz to 48khz;
   method 1: for every 6 samples (48/8), output one real
   sample and fill the rest with zeros:

  our format will be as follows
	iteration	ready	output
	0		1	0
	1		0	input_flop
	2		0	0
	3		0	0
	4		0	0
	5		0	0

 */

reg [2:0] counter;
reg [31:0] input_flop;
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		counter <= 3'b000;
		input_flop <=32'd0;
	else begin
		if(counter == 3'b101)
			counter <= 3'b000;
		else
			counter <= counter + 1'b1;

		if(counter == 3'b000)
			input_flop <= input;
		else
			input_flop <= input_flop;
	end
end

assign ready = (counter == 3'b000) ? 1'b1 : 1'b0; 
assign out = (counter == 3'b001) ? input_flop : 32'd0;


endmodule