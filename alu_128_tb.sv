module alu_128_tb();


// 128-bit ALU for the 554 CPU, including decryption hardware


////////////////////////////////////////////////////////////////////////////////


// I/O
reg signed [127:0] A, B; // operands used in calculations
reg [4:0] op; // lower five bits of the instruction opcode
reg clk, rst_n;
wire signed [127:0] res; // result of the datapath
wire signed [7:0] word[4][4]; // the operand of AES dec in matrix form for ease of computing

// OpCode values
localparam DEC = 5'h13;
localparam DECF = 5'h14;
localparam XORE = 5'h15;

// storage for intermediate steps
always_ff @(posedge clk, negedge rst_n) begin
	//if (!rst_n) A <= 128'h29C3505F571420F6402299B31A02D73A;
	if (!rst_n) A <= 128'hE2D1AE4680BFF46B8C787E0C2C6045A2;
	else A <= res;
end

// DUT
alu_128 DUT(A, B, res, op, word);


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
	op = DECF;
	B = 128'h28FDDEF86DA4244ACCC0A4FE3B316F26;
	#5;
	op = DEC;
	B = 128'hBFE2BF904559FAB2A16480B4F7F1CBD8;
	#10;
	B = 128'h8E51EF21FABB4522E43D7A0656954B6C;
	#10;
	B = 128'hCC96ED1674EAAA031E863F24B2A8316A;
	#10;
	B = 128'hBD3DC287B87C47156A6C9527AC2E0E4E;
	#10;
	B = 128'hB1293B3305418592D210D232C6429B69;
	#10;
	B = 128'hA11202C9B468BEA1D75157A01452495B;
	#10;
	B = 128'hD2600DE7157ABC686339E901C3031EFB;
	#10;
	B = 128'h56082007C71AB18F76435569A03AF7FA;
	#10;
	B = 128'hE232FCF191129188B159E4E6D679A293;
	#10;
	op = XORE;
	B = 128'h5468617473206D79204B756E67204675;
	#10;
	$stop();
end


endmodule
