module alu_128(A, B, res, op);


// 128-bit ALU for the 554 CPU, including decryption hardware


////////////////////////////////////////////////////////////////////////////////


// I/O
input signed [127:0] A, B; // operands used in calculations
input [4:0] op; // lower five bits of the instruction opcode
output reg signed [127:0] res; // result of the datapath

// Internal Sigs
reg signed [7:0] word[4][4]; // the operand of AES dec in matrix form for ease of computing
reg signed [7:0] temp[4][4]; // temp matrix for the matrix multiplication
integer i, j, k; // count for loops
reg [7:0] temp1, temp2, temp3, temp4, temp5; // temporary variables for shifting

// OpCode values
localparam DEC = 5'h13;
localparam DECF = 5'h14;
localparam XORE = 5'h15;

// LUT for the Byte Substitution step using the Inverse Rjinael S-box
const reg [7:0] sub[16][16] = '{ '{8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38, 8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb},
				'{8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87, 8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb},
				'{8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d, 8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e},
				'{8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2, 8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25},
				'{8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16, 8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92},
				'{8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda, 8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84},
				'{8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a, 8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06},
				'{8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02, 8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b},
				'{8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea, 8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73},
				'{8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85, 8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e},
				'{8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89, 8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b},
				'{8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20, 8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4},
				'{8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31, 8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f},
				'{8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d, 8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef},
				'{8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0, 8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61},
				'{8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26, 8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d}  };

// LUT for the Mix Column step using the inverse of a polynomial over GF(2^8)
const reg signed [7:0] mult[4][4] = '{ '{8'h0e, 8'h0b, 8'h0d, 8'h09},
				      '{8'h09, 8'h0e, 8'h0b, 8'h0d}, 
				      '{8'h0d, 8'h09, 8'h0e, 8'h0b}, 
				      '{8'h0b, 8'h0d, 8'h09, 8'h0e}  };


////////////////////////////////////////////////////////////////////////////////


// GF(2^8) multiplication functions used in the MixColumns step
function [7:0] galois2;
	input [7:0] operand;
	begin 
		if (operand[7]) galois2 = ((operand << 1) ^ 8'h1b);
		else galois2 = (operand << 1);
	end
endfunction
function [7:0] galois4;
	input [7:0] operand;
	galois4 = galois2(galois2(operand));
endfunction
function [7:0] galois8;
	input [7:0] operand;
	galois8 = galois2(galois4(operand));
endfunction
function [7:0] galois9;
	input [7:0] operand;
	galois9 = galois8(operand) ^ operand;
endfunction
function [7:0] galois11;
	input [7:0] operand;
	galois11 = galois8(operand) ^ galois2(operand) ^ operand;
endfunction
function [7:0] galois13;
	input [7:0] operand;
	galois13 = galois8(operand) ^ galois4(operand) ^ operand;
endfunction
function [7:0] galois14;
	input [7:0] operand;
	galois14 = (galois8(operand) ^ galois4(operand)) ^ galois2(operand);
endfunction


////////////////////////////////////////////////////////////////////////////////


// Datapath assignment
always_comb begin

	// default values
	for (i = 0; i < 4; i = i + 1) begin
		for (j = 0; j < 4; j = j + 1) begin
			word[i][j] = 8'h00;
			temp[i][j] = 8'h00;
		end
	end
	k = 0;
	res = A; 
	temp1 = 8'h00;
	temp2 = 8'h00;
	temp3 = 8'h00;
	temp4 = 8'h00;
	temp5 = 8'h00;

	// asssigning res
	case (op)
		XORE: res = A ^ B;
		DECF: begin // First step in decryption

			// AddRoundKey = XOR key
			res = A ^ B;

			// Put word into matrix form for ease of computing
			word[0][0] = res[127:120];
			word[1][0] = res[119:112];
			word[2][0] = res[111:104];
			word[3][0] = res[103:96];
			word[0][1] = res[95:88];
			word[1][1] = res[87:80];
			word[2][1] = res[79:72];
			word[3][1] = res[71:64];
			word[0][2] = res[63:56];
			word[1][2] = res[55:48];
			word[2][2] = res[47:40];
			word[3][2] = res[39:32];
			word[0][3] = res[31:24];
			word[1][3] = res[23:16];
			word[2][3] = res[15:8];
			word[3][3] = res[7:0];

			//  ShiftRows = Shift rows of input as follows for the 16-byte input matrix 0,1,2,...,15 (from left to right)
			//
			//  0  4  8 12      0  4  8 12    shift 0
			//  1  5  9 13  =   5  9 13  1    shift 1
			//  2  6 10 14  =  10 14  2  6    shift 2
			//  3  7 11 15     15  3  7 11    shift 3
			word[0][0] = word[0][0];
			temp1 = word[1][0];
			word[1][0] = word[1][3];
			temp2 = word[2][0];
			word[2][0] = word[2][2];
			temp3 = word[3][0];
			word[3][0] = word[3][1];
			word[0][1] = word[0][1];
			temp4 = word[1][1];
			word[1][1] = temp1;
			temp1 = word[2][1];
			word[2][1] = word[2][3];
			word[3][1] = word[3][2];
			word[0][2] = word[0][2];
			temp5 = word[1][2];
			word[1][2] = temp4;
			word[2][2] = temp2;
			word[3][2] = word[3][3];
			word[0][3] = word[0][3];
			word[1][3] = temp5;
			word[2][3] = temp1;
			word[3][3] = temp3;

			// SubBytes = switch out each byte for its value in the LUT
			for (j = 0; j < 4; j = j + 1)
				for (i = 0; i < 4; i = i + 1)
					word[i][j] = sub[word[i][j][7:4]][word[i][j][3:0]];

			// Assign res from the matrix
			res = {word[0][0], word[1][0], word[2][0], word[3][0], word[0][1], word[1][1], word[2][1], word[3][1], word[0][2], word[1][2], word[2][2], word[3][2], word[0][3], word[1][3], word[2][3], word[3][3]};
				
		end
		DEC: begin // steps 2-10 in decryption

			// AddRoundKey = XOR key
			res = A ^ B;

			// Put word into matrix form for ease of computing
			word[0][0] = res[127:120];
			word[1][0] = res[119:112];
			word[2][0] = res[111:104];
			word[3][0] = res[103:96];
			word[0][1] = res[95:88];
			word[1][1] = res[87:80];
			word[2][1] = res[79:72];
			word[3][1] = res[71:64];
			word[0][2] = res[63:56];
			word[1][2] = res[55:48];
			word[2][2] = res[47:40];
			word[3][2] = res[39:32];
			word[0][3] = res[31:24];
			word[1][3] = res[23:16];
			word[2][3] = res[15:8];
			word[3][3] = res[7:0];

			// MixColumns = multiply the word matrix by the MixColumns matrix
			for (i = 0; i < 4; i = i + 1)
				for (j = 0; j < 4; j = j + 1)
					for (k = 0; k < 4; k = k + 1) begin
						if (mult[i][k] == 8'h09) temp[i][j] = temp[i][j] ^ galois9(word[k][j]);
						else if (mult[i][k] == 8'h0b) temp[i][j] = temp[i][j] ^ galois11(word[k][j]);
						else if (mult[i][k] == 8'h0d) temp[i][j] = temp[i][j] ^ galois13(word[k][j]);
						else if (mult[i][k] == 8'h0e) temp[i][j] = temp[i][j] ^ galois14(word[k][j]);
					end
			word = temp;

			//  ShiftRows = Shift rows of input as follows for the 16-byte input matrix 0,1,2,...,15 (from left to right)
			//
			//  0  4  8 12      0  4  8 12    shift 0
			//  1  5  9 13  =  13  1  5  9    shift r1
			//  2  6 10 14  =  10 14  2  6    shift r2
			//  3  7 11 15      7 11 15  3    shift r3
			word[0][0] = word[0][0];
			temp1 = word[1][0];
			word[1][0] = word[1][3];
			temp2 = word[2][0];
			word[2][0] = word[2][2];
			temp3 = word[3][0];
			word[3][0] = word[3][1];
			word[0][1] = word[0][1];
			temp4 = word[1][1];
			word[1][1] = temp1;
			temp1 = word[2][1];
			word[2][1] = word[2][3];
			word[3][1] = word[3][2];
			word[0][2] = word[0][2];
			temp5 = word[1][2];
			word[1][2] = temp4;
			word[2][2] = temp2;
			word[3][2] = word[3][3];
			word[0][3] = word[0][3];
			word[1][3] = temp5;
			word[2][3] = temp1;
			word[3][3] = temp3;

			// SubBytes = switch out each byte for its value in the LUT
			for (j = 0; j < 4; j = j + 1)
				for (i = 0; i < 4; i = i + 1)
					word[i][j] = sub[word[i][j][7:4]][word[i][j][3:0]];

			// Assign res from the matrix
			res = {word[0][0], word[1][0], word[2][0], word[3][0], word[0][1], word[1][1], word[2][1], word[3][1], word[0][2], word[1][2], word[2][2], word[3][2], word[0][3], word[1][3], word[2][3], word[3][3]};
				
		end
	endcase
end

endmodule
