module ALU_control
	(input logic [31:0] IR,
	 output logic [31:0] imm);
	
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;

	assign opcode = IR[6:0];
	assign funct3 = IR[15:13];
	assign funct7 = IR[31:25];

	always_comb begin
		priority case (1'b1)
			(opcode == 7'b0110111) : imm = {IR[31:12],12'd0}; //LUI
			(opcode == 7'b0010111) : imm = {IR[31:12],12'd0}; //AUIPC
			(opcode == 7'b1101111) : imm = IR[31] ? {11'h7ff,IR[31],IR[20:13],IR[21],IR[30:22],1'b0} : {11'd0,IR[31],IR[20:13],IR[21],IR[30:22],1'b0}; //JAL
			(opcode == 7'b1100111) : imm = {20'd0,IR[31:20]}; //JALR
			(opcode == 7'b1100011) & (funct3 == 3'b000) : imm = IR[31] ? {19'h7ffff,IR[31],IR[8],IR[30:25],IR[12:9],1'b0} : {19'd0,IR[31],IR[8],IR[30:25],IR[12:9],1'b0}; //BEQ
			(opcode == 7'b1100011) & (funct3 == 3'b001) : imm = IR[31] ? {19'h7ffff,IR[31],IR[8],IR[30:25],IR[12:9],1'b0} : {19'd0,IR[31],IR[8],IR[30:25],IR[12:9],1'b0}; //BNE
			(opcode == 7'b1100011) & (funct3 == 3'b100) : imm = IR[31] ? {19'h7ffff,IR[31],IR[8],IR[30:25],IR[12:9],1'b0} : {19'd0,IR[31],IR[8],IR[30:25],IR[12:9],1'b0};//BLT
			(opcode == 7'b1100011) & (funct3 == 3'b101) : imm = IR[31] ? {19'h7ffff,IR[31],IR[8],IR[30:25],IR[12:9],1'b0} : {19'd0,IR[31],IR[8],IR[30:25],IR[12:9],1'b0};//BGE
			(opcode == 7'b1100011) & (funct3 == 3'b110) : imm = IR[31] ? {19'h7ffff,IR[31],IR[8],IR[30:25],IR[12:9],1'b0} : {19'd0,IR[31],IR[8],IR[30:25],IR[12:9],1'b0};//BLTU
			(opcode == 7'b1100011) & (funct3 == 3'b111) : imm = IR[31] ? {19'h7ffff,IR[31],IR[8],IR[30:25],IR[12:9],1'b0} : {19'd0,IR[31],IR[8],IR[30:25],IR[12:9],1'b0};//BGEU
			(opcode == 7'b0000011) & (funct3 == 3'b000) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //LB
			(opcode == 7'b0000011) & (funct3 == 3'b001) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //LH
			(opcode == 7'b0000011) & (funct3 == 3'b010) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //LW
			(opcode == 7'b0000011) & (funct3 == 3'b100) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //LBU
			(opcode == 7'b0000011) & (funct3 == 3'b101) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //LHU
			(opcode == 7'b0100011) & (funct3 == 3'b000) : imm = IR[31] ? {20'hfffff,IR[31:25],IR[12:8]} : {20'd0,IR[31:25],IR[12:8]}; //SB
			(opcode == 7'b0100011) & (funct3 == 3'b001) : imm = IR[31] ? {20'hfffff,IR[31:25],IR[12:8]} : {20'd0,IR[31:25],IR[12:8]}; //SH
			(opcode == 7'b0100011) & (funct3 == 3'b010) : imm = IR[31] ? {20'hfffff,IR[31:25],IR[12:8]} : {20'd0,IR[31:25],IR[12:8]}; //SW
			(opcode == 7'b0010011) & (funct3 == 3'b000) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //ADDI
			(opcode == 7'b0010011) & (funct3 == 3'b010) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //SLTI
			(opcode == 7'b0010011) & (funct3 == 3'b011) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //SLTIU
			(opcode == 7'b0010011) & (funct3 == 3'b100) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //XORI
			(opcode == 7'b0010011) & (funct3 == 3'b110) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //ORI
			(opcode == 7'b0010011) & (funct3 == 3'b111) : imm = IR[31] ? {20'hfffff,IR[31:20]} : {20'd0,IR[31:20]}; //ANDI
			(opcode == 7'b0010011) & (funct3 == 3'b001) & (funct7 == 7'b0000000) : imm = IR[24:20]; //SLLI
			(opcode == 7'b0010011) & (funct3 == 3'b101) & (funct7 == 7'b0000000) : imm = IR[24:20]; //SRLI
			(opcode == 7'b0010011) & (funct3 == 3'b101) & (funct7 == 7'b0100000) : imm = IR[24:20]; //SRAI
			(opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0000000) : imm = '0; //ADD
			(opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0100000) : imm = '0; //SUB
			(opcode == 7'b0110011) & (funct3 == 3'b001) & (funct7 == 7'b0000000) : imm = '0; //SLL
			(opcode == 7'b0110011) & (funct3 == 3'b010) & (funct7 == 7'b0000000) : imm = '0; //SLT
			(opcode == 7'b0110011) & (funct3 == 3'b011) & (funct7 == 7'b0000000) : imm = '0; //SLTU
			(opcode == 7'b0110011) & (funct3 == 3'b100) & (funct7 == 7'b0000000) : imm = '0; //XOR
			(opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0000000) : imm = '0; //SRL
			(opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0100000) : imm = '0; //SRA
			(opcode == 7'b0110011) & (funct3 == 3'b110) & (funct7 == 7'b0000000) : imm = '0; //OR
			(opcode == 7'b0110011) & (funct3 == 3'b111) & (funct7 == 7'b0000000) : imm = '0; //AND
			(opcode == 7'b0001111) & (funct3 == 3'b000) : imm = '0; //FENCE
			(opcode == 7'b0001111) & (funct3 == 3'b001) : imm = '0; //FENCE.I
			default: imm = '0;
		endcase
	end

endmodule
