module instruction_mem(pc, instruction);


// Instruction ROM for the 554 CPU
// CHANGE LINE 16 AND 36 EXPAND MEMORY


////////////////////////////////////////////////////////////////////////////////


// I/O
input [31:0] pc; // pc value with instruction address
output [31:0] instruction; // instruction read from the memory array

// Memory Size
localparam SIZE = 2048; // this is the number of memory locations available

// Memory Array
reg [31:0] mem [SIZE]; // SIZEx32 memory for instructions

// Loop Variable
integer i;


////////////////////////////////////////////////////////////////////////////////


// ROM initialization
initial begin
	for(i = 0; i < SIZE; i = i + 1) // default to 0
		mem[i] = 0;
	$readmemb("program.txt", mem); // fill ROM from file
end

// Memory output
assign instruction = mem[pc[10:0]]; // only need root2(SIZE) bits to access the whole ROM


endmodule
