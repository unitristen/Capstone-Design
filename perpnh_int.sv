module perph_int(send_data, received_data, stop_data, received_ak, stop_ak, audio_rdy, flag_val, flag_mode);


// Peripheral interface for the 554 CPU


////////////////////////////////////////////////////////////////////////////////


// I/O
input received_data; // signal from SPART saying new data has been received
input stop_data; // signal from SPART saying to stop playback
output send_data; // signal to SPART saying that data is ready to be sent to the host PC
output received_ak, stop_ak; // signals to SPART saying respective input flags have been ready
output audio_rdy; // signal to AUDIO saying song data is ready to be played
output reg [31:0] flag_val; // value of flag read to be stored in a 32-bit register
input [2:0] flag_mode; // signal from the Control module saying which combination of flags to read/set

// Flag Mode Values
localparam IDLE = 3'h0; // Nothing happens with the peripherals
localparam RECEIVED = 3'h1; // The received_data flag is captured and the received_ak flag is set
localparam SEND = 3'h2; // The send_data flag is set
localparam STOP = 3'h3; // The stoop_data flag is captured and the stop_ak flag is set
localparam AUDIO = 3'h4; // The audio_rdy flag is set


////////////////////////////////////////////////////////////////////////////////


// received_ak flag
assign received_ak = (flag_mode == RECEIVED);

// send_data flag
assign send_data = (flag_mode == SEND);

// stop_ak flag
assign stop_ak = (flag_mode == STOP);

// audio_rdy flag
assign audio_rdy = (flag_mode == AUDIO);

// flag_val
always_comb begin
	flag_val = 32'h00000000;
	case (flag_mode)
		RECEIVED:
			if (received_data == 1'b1)
				flag_val = 32'h00000001;
		STOP:
			if (stop_data == 1'b1)
				flag_val = 32'h00000001;
	endcase
end

endmodule
