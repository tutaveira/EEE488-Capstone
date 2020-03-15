module ALU
	(input logic [31:0] IR,
	 input logic [31:0] T0,
	 input logic [31:0] DBus,
	 input logic [31:0] PC,
	 input logic [31:0] imm,
	 input logic aluinc,
	 output logic [31:0] ALU);

	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;

	assign opcode = IR[6:0];
	assign funct3 = IR[15:13];
	assign funct7 = IR[31:25];

	//for JALR
	logic [31:0] jalr;
	assign jalr = imm + DBus;

	always_comb begin
                priority case (1'b1)
			aluinc: ALU = DBus + 1'b1;
                        (opcode == 7'b0110111) : ALU = imm; //LUI
                        (opcode == 7'b0010111) : ALU = imm + DBus; //AUIPC
                        (opcode == 7'b1101111) : ALU = imm + DBus; //JAL
                        (opcode == 7'b1100111) : ALU = {jalr[31:1],1'b0}; //JALR
                        (opcode == 7'b1100011) & (funct3 == 3'b000) : ALU = (DBus == T0) ? (imm + PC) : PC; //BEQ
                        (opcode == 7'b1100011) & (funct3 == 3'b001) : ALU = (DBus != T0) ? (imm + PC) : PC; //BNE
                        (opcode == 7'b1100011) & (funct3 == 3'b100) : ALU = (DBus < T0) ? (imm + PC) : PC; //BLT
                        (opcode == 7'b1100011) & (funct3 == 3'b101) : ALU = (DBus >= T0) ? (imm + PC) : PC; //BGE
                        (opcode == 7'b1100011) & (funct3 == 3'b110) : ALU = ((DBus**2) < (T0**2)) ? (imm + PC) : PC; //BLTU
                        (opcode == 7'b1100011) & (funct3 == 3'b111) : ALU = ((DBus**2) >= (T0**2)) ? (imm + PC) : PC; //BGEU
                        (opcode == 7'b0000011) & (funct3 == 3'b000) : ALU = imm + DBus; //LB
                        (opcode == 7'b0000011) & (funct3 == 3'b001) : ALU = imm + DBus; //LH
                        (opcode == 7'b0000011) & (funct3 == 3'b010) : ALU = imm + DBus; //LW
                        (opcode == 7'b0000011) & (funct3 == 3'b100) : ALU = imm + DBus; //LBU
                        (opcode == 7'b0000011) & (funct3 == 3'b101) : ALU = imm + DBus; //LHU
                        (opcode == 7'b0100011) & (funct3 == 3'b000) : ALU = {24'd0,T0[7:0]}; //SB
                        (opcode == 7'b0100011) & (funct3 == 3'b001) : ALU = {16'd0,T0[15:0]}; //SH
                        (opcode == 7'b0100011) & (funct3 == 3'b010) : ALU = T0; //SW
                        (opcode == 7'b0010011) & (funct3 == 3'b000) : ALU = imm + DBus; //ADDI
                        (opcode == 7'b0010011) & (funct3 == 3'b010) : ALU = (DBus < imm) ? 32'd1 : 32'd0; //SLTI
                        (opcode == 7'b0010011) & (funct3 == 3'b011) : ALU = ((DBus**2) < (imm**2)) ? 32'd1 : 32'd0; //SLTIU
                        (opcode == 7'b0010011) & (funct3 == 3'b100) : ALU = imm ^ DBus; //XORI
                        (opcode == 7'b0010011) & (funct3 == 3'b110) : ALU = imm | DBus; //ORI
                        (opcode == 7'b0010011) & (funct3 == 3'b111) : ALU = imm & DBus; //ANDI
                        (opcode == 7'b0010011) & (funct3 == 3'b001) & (funct7 == 7'b0000000) : ALU = DBus << imm; //SLLI
                        (opcode == 7'b0010011) & (funct3 == 3'b101) & (funct7 == 7'b0000000) : ALU = DBus >> imm; //SRLI
                        (opcode == 7'b0010011) & (funct3 == 3'b101) & (funct7 == 7'b0100000) : ALU = DBus >>> imm; //SRAI
                        (opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0000000) : ALU = DBus + T0; //ADD
                        (opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0100000) : ALU = DBus - T0;//SUB
                        (opcode == 7'b0110011) & (funct3 == 3'b001) & (funct7 == 7'b0000000) : ALU = DBus << T0; //SLL
                        (opcode == 7'b0110011) & (funct3 == 3'b010) & (funct7 == 7'b0000000) : ALU = (DBus < T0) ? 32'd1 : 32'd0; //SLT
                        (opcode == 7'b0110011) & (funct3 == 3'b011) & (funct7 == 7'b0000000) : ALU = ((DBus**2) < (T0**2)) ? 32'd1 : 32'd0; //SLTU
                        (opcode == 7'b0110011) & (funct3 == 3'b100) & (funct7 == 7'b0000000) : ALU = DBus ^ T0; //XOR
                        (opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0000000) : ALU = DBus >> T0; //SRL
                        (opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0100000) : ALU = DBus >>> T0; //SRA
                        (opcode == 7'b0110011) & (funct3 == 3'b110) & (funct7 == 7'b0000000) : ALU = DBus | T0; //OR
                        (opcode == 7'b0110011) & (funct3 == 3'b111) & (funct7 == 7'b0000000) : ALU = DBus & T0; //AND
                        (opcode == 7'b0001111) & (funct3 == 3'b000) : ALU = '0; //FENCE
                        (opcode == 7'b0001111) & (funct3 == 3'b001) : ALU = '0; //FENCE.I
			default: ALU = '0;
		endcase
	end

endmodule 
