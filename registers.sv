module registers
	(input logic [4:0] rs2,
	 input logic [4:0] rs1,
	 input logic [4:0] rd,
	 input logic [31:0] D,
	 input logic Ren,
	 input logic rst,
	 input logic clk,
	 output logic [31:0] A,
	 output logic [31:0] B);

	logic [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31;

	assign R0 = 32'd0;
	
	dff #(32) R1reg(.d(D), .en((rd == 5'd1) & Ren), .rst(rst), .clk(clk), .q(R1));
	dff #(32) R2reg(.d(D), .en((rd == 5'd2) & Ren), .rst(rst), .clk(clk), .q(R2));
	dff #(32) R3reg(.d(D), .en((rd == 5'd3) & Ren), .rst(rst), .clk(clk), .q(R3));
	dff #(32) R4reg(.d(D), .en((rd == 5'd4) & Ren), .rst(rst), .clk(clk), .q(R4));
	dff #(32) R5reg(.d(D), .en((rd == 5'd5) & Ren), .rst(rst), .clk(clk), .q(R5));
	dff #(32) R6reg(.d(D), .en((rd == 5'd6) & Ren), .rst(rst), .clk(clk), .q(R6));
	dff #(32) R7reg(.d(D), .en((rd == 5'd7) & Ren), .rst(rst), .clk(clk), .q(R7));
	dff #(32) R8reg(.d(D), .en((rd == 5'd8) & Ren), .rst(rst), .clk(clk), .q(R8));
	dff #(32) R9reg(.d(D), .en((rd == 5'd9) & Ren), .rst(rst), .clk(clk), .q(R9));
	dff #(32) R10reg(.d(D), .en((rd == 5'd10) & Ren), .rst(rst), .clk(clk), .q(R10));
	dff #(32) R11reg(.d(D), .en((rd == 5'd11) & Ren), .rst(rst), .clk(clk), .q(R11));
	dff #(32) R12reg(.d(D), .en((rd == 5'd12) & Ren), .rst(rst), .clk(clk), .q(R12));
	dff #(32) R13reg(.d(D), .en((rd == 5'd13) & Ren), .rst(rst), .clk(clk), .q(R13));
	dff #(32) R14reg(.d(D), .en((rd == 5'd14) & Ren), .rst(rst), .clk(clk), .q(R14));
	dff #(32) R15reg(.d(D), .en((rd == 5'd15) & Ren), .rst(rst), .clk(clk), .q(R15));
	dff #(32) R16reg(.d(D), .en((rd == 5'd16) & Ren), .rst(rst), .clk(clk), .q(R16));
	dff #(32) R17reg(.d(D), .en((rd == 5'd17) & Ren), .rst(rst), .clk(clk), .q(R17));
	dff #(32) R18reg(.d(D), .en((rd == 5'd18) & Ren), .rst(rst), .clk(clk), .q(R18));
	dff #(32) R19reg(.d(D), .en((rd == 5'd19) & Ren), .rst(rst), .clk(clk), .q(R19));
	dff #(32) R20reg(.d(D), .en((rd == 5'd20) & Ren), .rst(rst), .clk(clk), .q(R20));
	dff #(32) R21reg(.d(D), .en((rd == 5'd21) & Ren), .rst(rst), .clk(clk), .q(R21));
	dff #(32) R22reg(.d(D), .en((rd == 5'd22) & Ren), .rst(rst), .clk(clk), .q(R22));
	dff #(32) R23reg(.d(D), .en((rd == 5'd23) & Ren), .rst(rst), .clk(clk), .q(R23));
	dff #(32) R24reg(.d(D), .en((rd == 5'd24) & Ren), .rst(rst), .clk(clk), .q(R24));
	dff #(32) R25reg(.d(D), .en((rd == 5'd25) & Ren), .rst(rst), .clk(clk), .q(R25));
	dff #(32) R26reg(.d(D), .en((rd == 5'd26) & Ren), .rst(rst), .clk(clk), .q(R26));
	dff #(32) R27reg(.d(D), .en((rd == 5'd27) & Ren), .rst(rst), .clk(clk), .q(R27));
	dff #(32) R28reg(.d(D), .en((rd == 5'd28) & Ren), .rst(rst), .clk(clk), .q(R28));
	dff #(32) R29reg(.d(D), .en((rd == 5'd29) & Ren), .rst(rst), .clk(clk), .q(R29));
	dff #(32) R30reg(.d(D), .en((rd == 5'd30) & Ren), .rst(rst), .clk(clk), .q(R30));
	dff #(32) R31reg(.d(D), .en((rd == 5'd31) & Ren), .rst(rst), .clk(clk), .q(R31));

	always_comb begin
		unique case (rs1)
			5'd0 : A = R0;
			5'd1 : A = R1;
			5'd2 : A = R2;
			5'd3 : A = R3;
			5'd4 : A = R4;
			5'd5 : A = R5;
			5'd6 : A = R6;
			5'd7 : A = R7;
			5'd8 : A = R8;
			5'd9 : A = R9;
			5'd10 : A = R10;
			5'd11 : A = R11;
			5'd12 : A = R12;
			5'd13 : A = R13;
			5'd14 : A = R14;
			5'd15 : A = R15;
			5'd16 : A = R16;
			5'd17 : A = R17;
			5'd18 : A = R18;
			5'd19 : A = R19;
			5'd20 : A = R20;
			5'd21 : A = R21;
			5'd22 : A = R22;
			5'd23 : A = R23;
			5'd24 : A = R24;
			5'd25 : A = R25;
			5'd26 : A = R26;
			5'd27 : A = R27;
			5'd28 : A = R28;
			5'd29 : A = R29;
			5'd30 : A = R30;
			5'd31 : A = R31;
			default: A = R0;
		endcase
	end

	always_comb begin
                unique case (rs2)
                        5'd0 : B = R0;
                        5'd1 : B = R1;
                        5'd2 : B = R2;
                        5'd3 : B = R3;
                        5'd4 : B = R4;
                        5'd5 : B = R5;
                        5'd6 : B = R6;
                        5'd7 : B = R7;
                        5'd8 : B = R8;
			5'd9 : B = R9;
                        5'd10 : B = R10;
                        5'd11 : B = R11;
                        5'd12 : B = R12;
                        5'd13 : B = R13;
                        5'd14 : B = R14;
                        5'd15 : B = R15;
                        5'd16 : B = R16;
                        5'd17 : B = R17;
                        5'd18 : B = R18;
                        5'd19 : B = R19;
                        5'd20 : B = R20;
                        5'd21 : B = R21;
                        5'd22 : B = R22;
                        5'd23 : B = R23;
                        5'd24 : B = R24;
                        5'd25 : B = R25;
                        5'd26 : B = R26;
                        5'd27 : B = R27;
                        5'd28 : B = R28;
                        5'd29 : B = R29;
                        5'd30 : B = R30;
                        5'd31 : B = R31;
                        default: B = R0;
                endcase
        end

endmodule
