// RISC_V.sv
module RISC_V
  #( bW = 16, aW = 13 )
	( 
	 output logic [aW-1:0] memAddr,
	 output logic [bW-1:0] readData,					// Fix BW parameters!!!
	 output logic [bW-1:0] writeData,
	 output logic writeEn, ohalt, oretire,
	 input  logic bclk, bclk2, KEY0, rst, SSM,      
	 output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	
	///////// DRAM /////////
	input  logic [bW-1:0] DRAM_DQ_W,
	output logic [bW-1:0] DRAM_DQ_R,
	output logic [aW-1:0] DRAM_ADDR,
	output logic [1:0]    DRAM_BA,
	output logic DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N
	);
	
	// Reset is active low, keep SW0 at 1 to run the cpu, KEY0 is initially at 1 and goes to 0 when pressed 

	// Creating a clock that is twice as slow as the board's clock to counteract the ROM delay. The clock becomes KEY0 when in single step mode (SW1).
	logic clk, slowclk;
   assign clk = SSM ? !KEY0 && rst : slowclk;
   flipflop #(1) f0( .d(!slowclk), .q(slowclk), .clk(bclk), .rst(rst), .en(1'b1) );

	// Including the signal declaration file (sig_declare.inc) here. Execute the cpu_perl_script for generation
	parameter bw=6,aw=6,uw=25+1,ua=5+1; 
	logic MARen,PCen,IRen,ACCen,Ren,Zen,T0en,Len,MEMen,BPRen,PGen,PTEen,PCout,Aout,Bout,Zout,MEMout,Lout,PTEout,aluinc,store,id2uip,gofetch,retire,halt,write;
	assign {MARen,PCen,IRen,ACCen,Ren,Zen,T0en,Len,MEMen,BPRen,PGen,PTEen,PCout,Aout,Bout,Zout,MEMout,Lout,PTEout,aluinc,store,id2uip,gofetch,retire,halt,write} = sig;
	logic [uw-1:0] sig;
	
	// Data path buses declaration statements
	logic [bW-1:0] MEM, MAR, IR, PC, ACC, ALU, Z, DBus;	
	assign writeData = DBus;		// = ACC?
	assign MEM = readData;

	// Mirco instruction pointer (UIP) and other sequencing engine buses
	logic [ua-1:0] UIP, ID, nextUIP;

	// Paging Buses
	logic PG;
	logic [bW-1:0] BPR, PTE;

	// The signals halt, retire and writeEn are outputs from this module but are specified from the microcode as follows 
	assign ohalt   = halt;
	assign oretire = retire;
	assign writeEn = MEMen;

	// Instantiation of the microstore (US) and instruction decoder (ID) modules
	id #(ua) my_id( .IR (IR) , .Uip(ID)  );
	ustore   my_us( .Uip(UIP), .sig(sig) );

	// Sequencing Engine hardware:
	// This section includes the instantiation of the micro instruction pointer register (UIP) along with a MUX (between the ID and UIP) that drives nextUIP
	flipflop #(ua) myUIP( .d(nextUIP), .q(UIP), .clk(clk), .en(!halt), .rst(rst) );

	always_comb begin
		unique case (1'b1)
			id2uip  : nextUIP = ID;
			gofetch : nextUIP = '0;
			halt    : nextUIP = UIP;
			default : nextUIP = UIP + 1'b1;
		endcase
	end

	// Data Path Hardware:
	// Invoking the MAR, PC, IR, Z and ACC as registers for the data path. There is also a MUX that drives the bus based upon the out values from "sig"  
	
	flipflop #(bW) myMAR( .d(DBus), .q(MAR), .clk(clk), .en(MARen) , .rst(rst) );
	flipflop #(bW) myPC ( .d(DBus), .q(PC) , .clk(clk), .en(PCen)  , .rst(rst) );
	flipflop #(bW) myIR ( .d(DBus), .q(IR) , .clk(clk), .en(IRen)  , .rst(rst) );
	flipflop #(bW) myZ  ( .d(ALU) , .q(Z)  , .clk(clk), .en(aluinc), .rst(rst) );

	//memory #( .bW(bW), .eC(4) ) 
	//myACC   ( .writeAddr(IR[1:0]), .readAddr(IR[1:0]), .writeData(DBus), .readData(ACC), .writeEn(ACCen), .clk(clk) ); 

	always_comb begin
		unique case (1'b1)
			MEMout : DBus = MEM;
			PCout  : DBus = PC;
			Zout   : DBus = Z;
			Aout   : DBus = ACC;
			default: DBus = '0;
		endcase
	end

//=======================================================
// SDRAM Controller
//=======================================================

	logic          read;
	logic          clk_test;
	assign Sdram_Control.DQ = read ? DRAM_DQ_R : DRAM_DQ_W;

//	SDRAM frame buffer
	Sdram_Control	u1(	
		//	HOST Side
		.REF_CLK(bclk),
		.RESET_N(test_software_reset_n),
		//	FIFO Write Side 
		.WR_DATA(writeData),
		.WR(write),
		.WR_ADDR(0),
		.WR_MAX_ADDR(25'h1ffffff),		//	
		.WR_LENGTH(9'h80),
		.WR_LOAD(!test_global_reset_n ),
		.WR_CLK(clk_test),
		//	FIFO Read Side 
		.RD_DATA(readData),
		.RD(read),
		.RD_ADDR(0),			//	Read odd field and bypess blanking
		.RD_MAX_ADDR(25'h1ffffff),
		.RD_LENGTH(9'h80),
		.RD_LOAD(!test_global_reset_n ),
		.RD_CLK(clk_test),
		//	SDRAM Side
		.SA(DRAM_ADDR),
		.BA(DRAM_BA),
		.CS_N(DRAM_CS_N),
		.CKE(DRAM_CKE),
		.RAS_N(DRAM_RAS_N),
		.CAS_N(DRAM_CAS_N),
		.WE_N(DRAM_WE_N),
				//.DQ(),
		.DQM({DRAM_UDQM,DRAM_LDQM}),
		.SDR_CLK(DRAM_CLK)	
		);
							
	logic  test_software_reset_n;
	logic  test_global_reset_n;
	logic  test_start_n;

	logic  sdram_test_pass;
	logic  sdram_test_fail;
	logic  sdram_test_complete;
	
/*	
	pll_test u0(
		.refclk(bclk2),   //  refclk.clk
		.rst(1'b0),      //   reset.reset
		.outclk_0(clk_test), // outclk0.clk
		.outclk_1()  // outclk1.clk
		);	
	
	RW_Test u2(
		.iCLK(clk_test),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),
		.write(write),
		.writedata(writeData),
		.read(read),
		.readdata(readData),
		.drv_status_pass(sdram_test_pass),
		.drv_status_fail(sdram_test_fail),
		.drv_status_test_complete(sdram_test_complete)
		);
	
*/	
	
	// Paging Hardware:
	flipflop #(bW) myPTE( .d(DBus),  .q(PTE), .clk(clk), .en(PTEen), .rst(rst) );
	flipflop #(bW) myBPR( .d(DBus),  .q(BPR), .clk(clk), .en(BPRen), .rst(rst) );
	flipflop #(1)  myPG ( .d(IR[0]), .q(PG) , .clk(clk), .en(PGen) , .rst(rst) );	

	always_comb begin 
		priority case (1'b1)
			!PG  	: memAddr = { 2'd0, MAR }; 
			PTEen   : memAddr = { BPR, MAR[5:4] };
			PTEout  : memAddr = { PTE[5:2], MAR[3:0] };
			default : memAddr = { 2'd0, MAR };
		endcase
	end

	// The ALU:
	always_comb begin
		unique case (1'b1)
			aluinc:  ALU = DBus + 1'b1;
			default: ALU = '0;
		endcase
	end
	
	// Creating the hex display
	hexdisplay h0( .hdigit(4'd0), .en(1'b0), .HEX( HEX0 ) );
	hexdisplay h1( .hdigit(4'd0), .en(1'b0), .HEX( HEX1 ) );
	hexdisplay h2( .hdigit(4'd0), .en(1'b0), .HEX( HEX2 ) );
	hexdisplay h3( .hdigit(4'd0), .en(1'b0), .HEX( HEX3 ) );
	hexdisplay h4( .hdigit(4'd0), .en(1'b0), .HEX( HEX4 ) );
	hexdisplay h5( .hdigit(4'd0), .en(1'b0), .HEX( HEX5 ) );
	
endmodule
