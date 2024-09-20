`include "opcodes.v"

/* 
 * description: The module controller includes the connection of three control units: main control, PC control and ALU control.
 * inputs: clk, reset, opcode, M, N, V, stall	
 * output: RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc,
 * sign_extend_imm, MEMMemRd, MEMMemWr, MEMSignExtendMemData, EXALUSrc, EXMemDataIn, 
 * WBRegWr, EXRegWr, MEMRegWr, EXMemRd, EXMemWr, DMemWr, killF
 */
module controller(input        clk, reset,
                input  [3:0] opcode,
                input        M, N, V, Z, stall,
				output  [1:0] RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc,
				output sign_extend_imm, MEMMemRd, MEMMemWr, MEMSignExtendMemData, EXALUSrc, EXMemDataIn, 
    			output WBRegWr, EXRegWr, MEMRegWr, EXMemRd, EXMemWr, DMemWr, killF
				);
	
	wire  DRegWr, DALUSrc, DMemDataIn, DMemRd, DSignExtendMemData, selectedRegWr, selectedMemWr;
	wire  EXSignExtendMemData;
	wire [1:0] DALUOp, DWBdata, EXWBdata;
	
	mainControlUnit mcu(opcode, M,
	RegSrc1, RegSrc2, RegDest, DWBdata,
	sign_extend_imm, DRegWr, DALUSrc, DMemDataIn, DMemRd, DMemWr, DSignExtendMemData);
	
	alucontrol ac(opcode, DALUOp);
	
	pccontrol pc(opcode, Z, N, V, PCSrc, killF);
	
	mux2 #(2) ctrlSignalSelector({DRegWr, DMemWr}, 2'b00, stall, {selectedRegWr, selectedMemWr});
	
	// ID/EX Buffers
	flopr #(4) EX_IDEXBuffer(clk, reset, {DALUSrc, DALUOp, DMemDataIn}, {EXALUSrc, EXALUOp, EXMemDataIn});
	flopr #(5) MEM_IDEXBuffer(clk, reset, {DMemRd, selectedMemWr, DSignExtendMemData, DWBdata}, {EXMemRd, EXMemWr, EXSignExtendMemData, EXWBdata});
	flopr #(1) WB_IDEXBuffer(clk, reset, {selectedRegWr}, {EXRegWr}); 
	
	// EX/MEM Buffers
	flopr #(5) MEM_EXMEMBuffer(clk, reset, {EXMemRd, EXMemWr, EXSignExtendMemData, EXWBdata}, {MEMMemRd, MEMMemWr, MEMSignExtendMemData, MEMWBdata});
	flopr #(1) WB_EXMEMBuffer(clk, reset, {EXRegWr}, {MEMRegWr});
	
	// MEM/WB Buffers
	flopr #(1) WB_MEMWBBuffer(clk, reset, {MEMRegWr}, {WBRegWr});
				 
endmodule

/* 
 * description: this module is responsible for generating the control units responsible for the control of MUXes and sign extenders
 * throughout the datapath and for controlling the data memory.
 * inputs: op, mode	
 * output: RegSrc1, RegSrc2, RegDest, WBdata, sign_extend_imm,
 * RegWr, ALUsrc, MemDataIn, MemRd, MemWr, Sign_Extend_Data
 */
module mainControlUnit(input  [3:0] op, input mode,
               output       [1:0] RegSrc1, RegSrc2,
               output       [1:0] RegDest, WBdata,
               output       sign_extend_imm, RegWr,
               output       ALUsrc, MemDataIn,
               output 		MemRd, MemWr, 
			   output		Sign_Extend_Data);

  reg [14:0] controls;

  assign {RegSrc1, RegSrc2, RegDest,
          sign_extend_imm, RegWr,
          ALUsrc, MemDataIn, MemRd,
		  MemWr, Sign_Extend_Data, WBdata} = controls;
 
	  
  always @(*)
	
    casez({op, mode})
      {`AND,   1'b?}: controls <= 15'b000000x10x00x00; // AND
	  {`ADD,   1'b?}: controls <= 15'b000000x10x00x00; // ADD
	  {`SUB,   1'b?}: controls <= 15'b000000x10x00x00; // SUB
	  
	  {`ADDI,  1'b?}: controls <= 15'b010101111x00x00; // ADDI
	  {`ANDI,  1'b?}: controls <= 15'b010101011x00x00; // ANDI
	  
	  {`LW,    1'b?}: controls <= 15'b010101111x10x01; // LW
	  {`LBu,   1'b0}: controls <= 15'b010101111x10010; // LBu
	  {`LBs,   1'b1}: controls <= 15'b010101111x10110; // LBs
	  {`SW,    1'b?}: controls <= 15'b0101xx101001xxx; // SW
	  
	  {`BGT,   1'b0}: controls <= 15'b0101xx100x00xxx; // BGT
	  {`BGTZ,  1'b1}: controls <= 15'b1101xx100x00xxx; // BGTZ
	  {`BLT,   1'b0}: controls <= 15'b0101xx100x00xxx; // BLT
	  {`BLTZ,  1'b1}: controls <= 15'b1101xx100x00xxx; // BLTZ
	  {`BEQ,   1'b0}: controls <= 15'b0101xx100X00xxx; // BEQ
	  {`BEQZ,  1'b1}: controls <= 15'b1101xx100X00xxx; // BEQZ
	  {`BNE,   1'b0}: controls <= 15'b0101xx100X00xxx; // BNE
	  {`BNEZ,  1'b1}: controls <= 15'b1101xx100X00xxx; // BNEZ
	  
	  {`JMP,   1'b?}: controls <= 15'bxxxxxxx0xx00xxx; // JMP
	  {`CALL,  1'b?}: controls <= 15'bxxxx10x1xx00x11; // CALL
	  {`RET,   1'b?}: controls <= 15'b10xxxxx0xx00xxx; // RET
	  
	  {`Sv,   1'b?}: controls <= 15'b1111xxx00101xxx; // Sv
	  
	  default: controls <= 15'b111111111111111; // invalid opcode
	  
      
    endcase
endmodule

/* 
 * description: this module acts as the control unit for the ALU; it generates the control signals required to select
 * the appropriate operation based on the opcode of the instruction.	
 * inputs: opcode
 * output: ALUop
 */
module alucontrol(input	[3:0] opcode,
				output reg	[1:0] ALUop);

  always @(*)
    case(opcode)
		`AND: ALUop <= 2'b01; 
     	`ADD: ALUop <= 2'b00;
		`SUB: ALUop <= 2'b10;
		`ADDI: ALUop <= 2'b00;
		`ANDI: ALUop <= 2'b01;
		`LW: ALUop <= 2'b00;
		`LBu: ALUop <= 2'b00;
		`SW: ALUop <= 2'b00;
		`BGT: ALUop <= 2'bxx;
		`BLT: ALUop <= 2'bxx;
		`BEQ: ALUop <= 2'bxx;
		`BNE: ALUop <= 2'bxx;
		`JMP: ALUop <= 2'bxx;
		`CALL: ALUop <= 2'bxx;
		`RET: ALUop <= 2'bxx;
		`Sv: ALUop <= 2'b00;
    endcase
endmodule



/* 
 * description: this module acts as the control unit for the ALU; it generates the control signals required to select
 * the appropriate operation based on the opcode of the instruction.	
 * inputs: opcode
 * output: ALUop
 */
module pccontrol(input	[3:0] IDOpcode,
	input Z, N, V,
	output [1:0] PCsrc,
	output killF);
	
	reg branchTaken, jump, rtrn;
	
	assign branchTaken = ((IDOpcode == `BGT) && ((Z == 1) || (N != V))) ||
	((IDOpcode == `BLT) && (N == V)) ||
	((IDOpcode == `BEQ) && (Z == 1)) ||
	((IDOpcode == `BNE) && (Z == 0));
	
	assign jump = (IDOpcode == `JMP) || (IDOpcode == `CALL);
	
	assign rtrn = IDOpcode == `RET;
	
	assign PCsrc = branchTaken ? 2'b01 : 
	(jump ? 2'b10 : 
	(rtrn ?	2'b11 : 2'b00));
	
	// stall if there is a branch or jump
	assign killF = (IDOpcode[3:2] == 2'b10) || (IDOpcode == `JMP) || (IDOpcode == `CALL) || (IDOpcode == `RET);
							
endmodule