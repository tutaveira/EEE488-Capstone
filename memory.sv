module memory
  #( 
     parameter int bW,
     parameter int eC,
     parameter int aW=$clog2(eC) 
     )
   (
    input  logic [aW-1:0] readAddr,
    input  logic [aW-1:0] writeAddr,
    input  logic [bW-1:0] writeData,
    input  logic          writeEn,
    output logic [bW-1:0] readData,
    input  logic          clk
    );

   logic [bW-1:0] 	  mem[eC-1:0];

   assign readData = mem[readAddr];

   always @(posedge clk)
     if( writeEn )
       mem[writeAddr] <= writeData ; // probably should be non-blocking
   
endmodule 
