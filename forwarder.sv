module forwarder(mode, res_32_m, res_32_wb, res_128_m, res_128_wb, out_32, out_128);


// Forwarding unit to decide whch values to send to the ALU from farther pipeline stages


////////////////////////////////////////////////////////////////////////////////


// I/O
input [127:0] res_128_m, res_128_wb; // 128-bit values from stages farther down the pipeline
input [31:0] res_32_m, res_32_wb; // 32-bit values from stages farther down the pipeline
input mode; // which value should be forwarded. 0 = M, 1 = WB
output [31:0] out_32;
output [127:0] out_128;


////////////////////////////////////////////////////////////////////////////////


// Output assignment. 0 = M, 1 = WB
assign out_32 = mode ? res_32_wb : res_32_m;
assign out_128 = mode ? res_128_wb : res_128_m;


endmodule
