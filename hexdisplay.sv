module hexdisplay
	( input logic [3:0] hdigit,
	  output logic [6:0] HEX	);
	
	always_comb begin
		unique case (hdigit)
		
		4'd0  : HEX = 7'b1000000; //0
		4'd1  : HEX = 7'b1111001; //1
		4'd2  : HEX = 7'b0100100; //2
		4'd3  : HEX = 7'b0110000; //3
		4'd4  : HEX = 7'b0011001; //4
		4'd5  : HEX = 7'b0010010; //5
		4'd6  : HEX = 7'b0000010; //6
		4'd7  : HEX = 7'b1111000; //7
		4'd8  : HEX = 7'b0000000; //8
		4'd9  : HEX = 7'b0010000; //9
		4'd10 : HEX = 7'b0001000; //A
		4'd11 : HEX = 7'b0000011; //B
		4'd12 : HEX = 7'b1000110; //C
		4'd13 : HEX = 7'b0100001; //D
		4'd14 : HEX = 7'b0000110; //E
		4'd15 : HEX = 7'b0001110; //F
		
		endcase
	end
	
endmodule
