

/* 
 * description: The module cpu includes the connection of the datapath and controller.
 * inputs: clk, reset, dataout, instruction	
 * output: MemRd, MemWr, datain, instrAddr, dataAddr
 */
module cpu(input         clk, reset,
	input [15:0] dataout, instruction,
	output  MemRd, MemWr,
	output [15:0] datain, instrAddr, dataAddr);

  wire [3:0] opcode;
  wire M, Z, N, V, stall;
  wire [1:0] RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc;
  wire sign_extend_imm, MEMSignExtendMemData, EXALUSrc,
  WBRegWr, EXRegWr, MEMRegWr, EXMemRd, EXMemWr, killF, EXMemDataIn, DMemWr;
  
  
  controller c(clk, reset, opcode, M, N, V, Z, stall,
  RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc,
  sign_extend_imm, MemRd, MemWr, MEMSignExtendMemData, EXALUSrc, EXMemDataIn,
  WBRegWr, EXRegWr, MEMRegWr, EXMemRd, EXMemWr, DMemWr, killF);
  
  datapath dp(clk, reset, RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc,
  sign_extend_imm, MEMSignExtendMemData, EXALUSrc, EXMemDataIn,
  WBRegWr, EXRegWr, MEMRegWr, DMemWr, EXMemRd, EXMemWr, killF, Z, N, V, M, stall,
  instrAddr, instruction, datain, dataAddr, dataout, opcode);
			  
endmodule