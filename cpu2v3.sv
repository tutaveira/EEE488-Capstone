// cpu2v3.sv
module cpu2v3
  #( Wwid = 6, aW = 6 )
	( 
	 output logic [aW-1:0]   memAddr,
	 input  logic [Wwid-1:0] readData,
	 output logic [Wwid-1:0] writeData,
	 output logic writeEn, ohalt, oretire,
	 input  logic bclk, KEY0, rst, SW1,      
	 output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
	);
	
	// Reset is active low, keep SW0 at 1 to run the cpu
	// KEY0 is typically at 1 and goes to 0 when pressed 

	// Creating a clock that is twice as slow as the board's clock to counteract the ROM delay
	logic clk, slowclk;
   assign clk = SW1 ? !KEY0 && rst : slowclk;	// clock becomes KEY0 when in single step mode

   flipflop #(1) f0( .d(!slowclk), .q(slowclk), .clk(bclk), .rst(rst), .en(1'b1) );

	// Including the signal declaration file (sig_declare.inc) here. Execute the perl scrupt mkurom (./mkurom) for generation
	parameter bw=6,aw=6,uw=18+1,ua=5+1; 
	logic MARen, PCen, IRen, ACCen, Zen, MEMen, BPRen, PGen, PTEen, PCout, ACCout, Zout, MEMout, PTEout, aluinc, id2uip, gofetch, retire, halt;
	logic [uw-1:0] sig;
	assign {MARen,PCen,IRen,ACCen,Zen,MEMen,BPRen,PGen,PTEen,PCout,ACCout,Zout,MEMout,PTEout,aluinc,id2uip,gofetch,retire,halt} = sig;

	// Data path buses declaration statements
	parameter bW = Wwid;
	logic [bW-1:0] MEM, MAR, IR, PC, ACC, ALU, Z, DBus;	
	assign writeData = DBus;
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
	ID__ #(ua) my_id ( .IR (IR) , .Uip(ID)  );
	US__   my_ustore ( .Uip(UIP), .sig(sig) );

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

	memory #( .bW(bW), .eC(4) ) 
	myACC   ( .writeAddr(IR[1:0]), .readAddr(IR[1:0]), .writeData(DBus), .readData(ACC), .writeEn(ACCen), .clk(clk) ); 

	always_comb begin
		unique case (1'b1)
			MEMout : DBus = MEM;
			PCout  : DBus = PC;
			Zout   : DBus = Z;
			ACCout : DBus = ACC;
			default: DBus = '0;
		endcase
	end

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
	
	// creating the actual hex display
	logic [3:0] din, next_d;
	
	flipflop #(4) dff0( .d(din), .q(next_d), .clk(clk), .en(1'b1), .rst(rst) );

	always_ff @ (posedge KEY0) begin
		unique case (din)
			4'hf : next_d = 4'h0;
			default: next_d = din++;
		endcase
	end
		
	hexdisplay h0( .hdigit( din ), .HEX( HEX0 ) );
	hexdisplay h1( .hdigit( din ), .HEX( HEX1 ) );
	hexdisplay h2( .hdigit( din ), .HEX( HEX2 ) );
	hexdisplay h3( .hdigit( din ), .HEX( HEX3 ) );
	hexdisplay h4( .hdigit( din ), .HEX( HEX4 ) );
	hexdisplay h5( .hdigit( din ), .HEX( HEX5 ) );
	
endmodule
