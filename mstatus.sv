module mstatus
(
input logic clk,
input logic rst,
output logic [31:0] mstat
);

//Variables
logic UIE; 			//User Interrupt Enable
logic SIE;		   //Supervisor Interrupt Enable
logic MIE; 	   	//Machine Interrupt Enable
logic UPIE;		   //User Previous Interrupt Enable
logic SPIE;			//Supervisor Previous Interrupt Enable
logic MPIE;		   //Machine Previous Interrupt Enabler
logic SPP;			//Supervisor Previous Privilege
logic [2:0] MPP;	//Machine Previous Privilege
logic [2:0] FS;	//Floating Point State
logic [2:0] XS;	//User Mode Extension State
logic MPRIV;		//Modify Privilege (access memory as MPP)
logic SUM;			//Permit Supervisor User Memory Access
logic MXR;			//Make Executable Readable
logic TVM;			//Trap Virtual memory
logic TW;			//Timeout Wait (traps S-Mode wfi)
logic TSR;			//Trap SRET
logic SD;			//State Dirty (FS and XS summary bit)

//variable Assignments
assign TW = 1'b0;

//Mstatus Register Assignments
assign mstat[31] = SD;
assign mstat[30:23] = '0;	//Reserved Bits
assign mstat[22] = TSR;
assign mstat[21] = TW;
assign mstat[20] = TVM;
assign mstat[19] = MXR;
assign mstat[18] = SUM;
assign mstat[17] = MPRIV;
assign mstat[16:15] = XS;
assign mstat[14:13] = FS;
assign mstat[12:11] = MPP;
assign mstat[10:9] = '0;	//Reserved Bits
assign mstat[8] = SPP;
assign mstat[7] = MPIE;
assign mstat[6] = '0;		//Reserved Bit
assign mstat[5] = SPIE;
assign mstat[4] = UPIE;
assign mstat[3] = MIE;
assign mstat[2] = '0;		//Reserved Bit
assign mstat[1] = SIE;
assign mstat[0] = UIE;


endmodule 