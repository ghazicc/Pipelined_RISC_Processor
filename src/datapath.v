

 
/* 
 * description: datapath module is a connection of the functional units, buffers, register file and MUXes.
 * inputs: clk, reset, RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc,
 * sign_extend_imm, MEMSignExtendMemData, EXALUSrc, EXMemDataIn,
 * WBRegWr, EXRegWr, MEMRegWr, DMemWr, EXMemRd, EXMemWr, killF, instrF	
 * output: Z, N, V, mode, stall, instrAddrF, DataInM, ALUOutM, Opcode
 */
module datapath(input         clk, reset,
				input  [1:0] RegSrc1, RegSrc2, RegDest, MEMWBdata, EXALUOp, PCSrc,
				input sign_extend_imm, MEMSignExtendMemData, EXALUSrc, EXMemDataIn,
    			input WBRegWr, EXRegWr, MEMRegWr, DMemWr, EXMemRd, EXMemWr, killF,
                output	Z, N, V, mode, stall,
                output [15:0] instrAddrF,
                input  [15:0] instrF,
                output [15:0] DataInM, ALUOutM,
                input  [15:0] DataOut, 
                output [3:0]  Opcode);
				
				
	// wires in the fetch stage				
	wire [15:0] PCPlus2F, branchAddr, selectedInstruction;
	wire [15:0] untakenBranchPC;
	wire [15:0] PCNext;
	// wires in the decode stage
	wire [1:0] ForwardBus1, ForwardBus2;
	wire ForwardME;
	wire [2:0] RegSrc1D, RegSrc2D, RegDestD;
	wire [15:0] Bus1D, Bus2D, SubOut, instrAddrD, PCPlus2D;
	wire [15:0] ForwardedData1, ForwardedData2, extendedImmediateD, extendedImmediateS, instrD;
	
	// wires in the execute stage
	wire EXForwardME;
	wire [2:0] RegDestE;
	wire [15:0] ALUOutE, ALUIn2, SelectedDataIn, DataInE, extendedImmediateE, instrAddrE,
	Bus1E, Bus2E, PCPlus2E;
	
	// wires in the memory stage
	
	wire [15:0] PCPlus2M, extendedDataOut, WrittenDataM;
	wire [2:0] RegDestM;
	
	// wires in the writeback stage
	wire [15:0] WrittenDataW;
	wire [2:0] RegDestW;
	
	// hazard detection
	hazard    h(RegDestE, RegDestM, RegSrc1D, RegSrc2D,
	EXRegWr, MEMRegWr, EXMemRd, DMemWr,
	ForwardME,
	ForwardBus1, ForwardBus2, 
	stall);
	
	 
	
	// Fetch stage logic
	mux2 #(16) untakenBranchMUX(PCPlus2F, instrAddrF, killF, untakenBranchPC);
	mux4 PCinput(untakenBranchPC, branchAddr, {instrAddrF[15:13], instrD[11:0], 1'b0}, Bus1D, PCSrc, PCNext);
	flopenr #(16) PC(clk, reset, ~stall, PCNext, instrAddrF);	// PC register
	adder       pcadd1(instrAddrF, 16'b10, PCPlus2F);	// adder to increment PC address
	mux2 #(16) fetchedInstructionSelector(instrF, 16'b0000000000000000, killF, selectedInstruction);
	
	// IF/ID Buffers
	flopenr #(16) PCBufferF(clk, reset, ~stall, instrAddrF, instrAddrD);	// PC Buffer
	flopenr #(16) PCPlusBufferF(clk, reset, ~stall, PCPlus2F, PCPlus2D);	// PC+2 Buffer
	flopenr #(16) FetchedInstrBufferF(clk, reset, ~stall, selectedInstruction, instrD);	// Fetched Instruction Buffer
	
	// Decode stage logic
	assign Opcode = instrD[15:12];
	assign mode = instrD[11];
	mux4 #(3) regSrc1Selector(instrD[8:6], instrD[7:5], 3'b111, 3'b000, RegSrc1, RegSrc1D);			
	mux4 #(3) regSrc2Selector(instrD[5:3], instrD[10:8], instrD[10:8], instrD[11:9], RegSrc2, RegSrc2D);
	mux4 #(3) regDestSelector(instrD[11:9], instrD[10:8], 3'b111, 3'b000, RegDest, RegDestD);
	regfile rf(clk, WBRegWr, RegSrc1D, RegSrc2D, RegDestW, WrittenDataW, Bus1D, Bus2D);
	mux4 #(16) ForwardBus1Selector(Bus1D, ALUOutE, WrittenDataM, WrittenDataW, ForwardBus1, ForwardedData1);
	mux4 #(16) ForwardBus2Selector(Bus2D, ALUOutE, WrittenDataM, WrittenDataW, ForwardBus2, ForwardedData2);
	
	
	
	signext #(5) itype_extender(instrD[4:0], sign_extend_imm, extendedImmediateD);
	
	adder branchAdder(extendedImmediateD, instrAddrD, branchAddr);
	subtractor sb(ForwardedData1, ForwardedData2, Z, N, V, SubOut);
	
	
	
	// ID/EX Buffers
	flopr #(16) ImmBufferE(clk, reset, extendedImmediateD, extendedImmediateE);
	flopr #(16) PCBufferE(clk, reset, instrAddrD, instrAddrE);
	flopr #(16) Bus1BufferE(clk, reset, ForwardedData1, Bus1E);
	flopr #(16) Bus2BufferE(clk, reset, ForwardedData2, Bus2E);
	flopr #(3) RdE(clk, reset, RegDestD, RegDestE);
	flopr #(16) PCPlusBufferE(clk, reset, PCPlus2D, PCPlus2E);
	flopr #(16) ExtendedSTypeImmediate(clk, reset, {{(7){instrD[8]}} ,instrD[8:0]}, extendedImmediateS);
	flopr #(1)  ForwardMEBuffer(clk, reset, ForwardME, EXForwardME);
	
	
	// Execute Stage Logic
	mux2 #(16) ALUInputSelector(Bus2E, extendedImmediateE, EXALUSrc, ALUIn2);
	
	alu ALU(Bus1E, ALUIn2, EXALUOp, ALUOutE);
	
	
	
	
	mux2 #(16) ForwardedMemDataSelector(Bus2E, DataOut, EXForwardME, DataInE);
	mux2 #(16) DataInSelector(DataInE, extendedImmediateS, EXMemDataIn, SelectedDataIn);
	
	// EX/MEM Buffers
	
	flopr #(16) ALUOutBuffer(clk, reset, ALUOutE, ALUOutM);
	flopr #(16)	DataInBuffer(clk, reset, SelectedDataIn, DataInM);
	flopr #(16)	NextPCBuffer(clk, reset, PCPlus2E, PCPlus2M);
	flopr #(3)	RdMBuffer(clk, reset, RegDestE, RegDestM);
	
	
	// Memory Stage Logic
	
	signext #(8) MemDataExtender(DataOut[7:0], MEMSignExtendMemData, extendedDataOut);
	mux4 #(16) WBDataSelector(ALUOutM, DataOut, extendedDataOut, PCPlus2M, MEMWBdata, WrittenDataM);
	
	// MEM/WB Buffers
	
	flopr #(16) WBDataBuffer(clk, reset, WrittenDataM, WrittenDataW);
	flopr #(3) RdWBuffer(clk, reset, RegDestM, RegDestW);	  

endmodule

/* 
 * description: this module acts as the control unit for the ALU; it generates the control signals required to select
 * the appropriate operation based on the opcode of the instruction.	
 * inputs: opcode
 * output: ALUop
 */
module hazard(input [2:0] Rd2, Rd3, Rs1, Rs2, 
              input ExRegWr, MemRegWr, ExMemRd, DMemWr,
              output reg ForwardMemEx,
              output reg [1:0] ForwardBus1, ForwardBus2,
              output reg stall);

 	always @(*)
		begin
    		
			ForwardBus1 = 2'b00; ForwardBus2 = 2'b00;
			
      		if (Rs1 != 0)
		  
        		if (Rs1 == Rd2 & ExRegWr)
					ForwardBus1 = 2'b01 ;
			
        		else if (Rs1 == Rd3 & MemRegWr)
					ForwardBus1 = 2'b10 ;
			
      		if (Rs2 != 0)
		  
        		if (Rs2 == Rd2 & ExRegWr)
					ForwardBus2 = 2'b01 ;
			
        		else if (Rs2 == Rd3 & MemRegWr)
					ForwardBus2 = 2'b10 ;
	
			ForwardMemEx = ExMemRd && DMemWr && Rd2 == Rd3 ;
			stall = ExMemRd && (ForwardBus1 == 1 || ForwardBus2 == 1) && !ForwardMemEx ;  
			
		end

endmodule