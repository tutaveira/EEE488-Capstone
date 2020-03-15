module riscv_cpu
#( Wwid=32, aW=32  )
(
  output logic [aW-1:0]     memAddr,
  input  logic [Wwid-1:0]  readData,
  output logic [Wwid-1:0] writeData,
  output logic              writeEn,
  output logic                ohalt,
  output logic              oretire,
  input  logic 		        clk,
  input  logic 		        rst
);

  //
  // include the signal declaration file (sig_declare.inc) here
  // (be sure to LOOK at that file, it is important!)
  // if you do not have a signal declare file, then execute the perl script
  // mkurom.  (i.e. ./mkurom)   This perl script will create sig_declare,
  // id.sv, and ustore.sv as specified by your microcode file.
  //
  `include "sig_declare.inc";


  //
  // declare buses for your MAR, PC, IR, Z, and other data path stuff
  //
        parameter bW=Wwid;
        logic [bW-1:0] MAR, PC, IR, DBus, Z, MEM, A, B, T0, ALU, imm, L, nxt_L;
	logic [4:0] rs1, rs2, rd;

  // declare your UIP, and other sequencing engine stuff
        logic [ua-1:0] UIP;
        logic [ua-1:0] uip_fromIR;

 // halt and retire are outputs from this module, BUT, they
 // are specified from the microcode.  Take care of that here.
 //
  assign ohalt     = halt;
  assign oretire   = retire;


// 
//  microstore and your instruction decoder (ID) 
// 
ID__  #(ua)   my_id     ( .IR (IR  ), .Uip(uip_fromIR    ) );
US__          my_ustore ( .Uip( UIP   ), .sig( sig   ) );


//
// Sequencing engine hardware:
//
// invoke your micro instruction pointer register (UIP) here
// its width is ua bits
// Then add the rest of the microcode sequencing engine 
//
//

	logic [ua-1:0] next_UIP;

	always_comb begin
		priority case (1'b1)
			gofetch : next_UIP = 0;
			id2uip : next_UIP = uip_fromIR;
			default: next_UIP = UIP + 1'b1;
		endcase
	end

	dff #(ua) UIPreg(.d(next_UIP), .en(1'b1), .rst(rst), .clk(clk), .q(UIP)); 

	assign memAddr = MAR;
	assign MEM = readData;
	assign writeEn = write;
	assign writeData = DBus;

//
// Data Path hardware:
//
//
// invoke your MAR, PC, IR and the rest of the data path 
// There should be a bunch of registers.  There should be a MUX
// that drives the bus.  You should connect up to the signals in
// the port list that go to memory
//
	dff #(bW) MARreg(.d(DBus), .en(MARen), .rst(rst), .clk(clk), .q(MAR));
	dff #(bW) PCreg(.d(DBus), .en(PCen), .rst(rst), .clk(clk), .q(PC));
	dff #(bW) IRreg(.d(DBus), .en(IRen), .rst(rst), .clk(clk), .q(IR)); 
	dff #(bW) Zreg(.d(ALU), .en(Zen), .rst(rst), .clk(clk), .q(Z));

	//temporary register to feed ALU
	dff #(bW) T0reg(.d(DBus), .en(T0en), .rst(rst), .clk(clk), .q(T0));

	ALU_control my_ALU_controller(.IR(IR), .imm(imm));
	ALU my_ALU(.IR(IR), .T0(T0), .DBus(DBus), .imm(imm), .PC(PC), .aluinc(aluinc), .ALU(ALU));

	//for load instructions
	always_comb begin
		priority case (1'b1)
			(IR[6:0] == 7'b0000011) & (IR[14:12] == 3'b000) : nxt_L = DBus[7] ? {24'hffffff,DBus[7:0]} : {24'd0,DBus[7:0]}; //LB 	
			(IR[6:0] == 7'b0000011) & (IR[14:12] == 3'b001) : nxt_L = DBus[15] ? {16'hffff,DBus[15:0]} : {16'd0,DBus[15:0]}; //LH
			(IR[6:0] == 7'b0000011) & (IR[14:12] == 3'b010) : nxt_L = DBus; //LW
			(IR[6:0] == 7'b0000011) & (IR[14:12] == 3'b100) : nxt_L = {DBus[7:0],24'd0}; //LBU
			(IR[6:0] == 7'b0000011) & (IR[14:12] == 3'b101) : nxt_L = {DBus[15:12],16'd0}; //LHU
			default: nxt_L = '0;
		endcase
	end


	dff #(bW) Lreg(.d(nxt_L), .en(Len), .rst(rst), .clk(clk), .q(L));

	assign rs1 = IR[19:15];
	assign rs2 = IR[24:20];
	assign rd = IR[11:7];

	//A is the contants of register rs1, B is the contents of register rs2, D is the data to be loaded into the registers
	registers my_registers(.rs2(rs2), .rs1(rs1), .rd(rd), .D(DBus), .Ren(Ren), .rst(rst), .clk(clk), .A(A), .B(B));

	//MUX that drives the data bus
	always_comb begin
		priority case (1'b1)
			PCout : DBus = PC;
			Zout : DBus = Z;
			Aout : DBus = A;
			Bout : DBus = B;
			MEMout : DBus = MEM;
			store : DBus = rd;
			Lout: DBus = L;
			default : DBus = 0;
		endcase
	end

endmodule
