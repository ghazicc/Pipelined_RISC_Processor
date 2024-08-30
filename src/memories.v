

/* 
 * description: this module acts as the data memory that stores the data loaded from CPU, specifically the register file.
 * inputs: clk, MemRd, MemWr, address, DataIn	
 * output: Dataout
 */
module dmem(
			input clk, MemRd, MemWr,
			input [15:0] address,
			input [15:0] DataIn,
            	output reg [15:0] Dataout );

	reg  [7:0] RAM[31:0];


	always @(negedge clk) 
    	
		if (MemWr)
			begin
      			RAM[address] <= DataIn[7:0] ;
	  			RAM[address + 1] <= DataIn[15:8] ;
			end
	
	always @(posedge MemRd)
		
		if (MemRd)
			Dataout <= {RAM[address+1], RAM[address]} ; 
			
endmodule


/* 
 * description: this module acts as the instruction memory that stores the instruction sequence
 * to be executed on the processor	
 * inputs: PC
 * output: instruction
 */
module imem(input  [15:0] PC,
            output reg [15:0] instruction );

	reg  [7:0] RAM[63:0] ;

 	initial
    		begin
      		$readmemh("memfile.dat",RAM) ;
    		end
	
	always@(*)
 	 	instruction <= {RAM[PC+1], RAM[PC]};
  
endmodule