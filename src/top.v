/*
 * Pipelined RISC Processor

 * Team:
 * Ghazi Haj Qassem		1210778
 * Ameer Rabie			1211226
 * Mumen Anbar			1212297
 
 */

`include "opcodes.v"

`timescale 1ns / 1ns

/* 
 * description: This module is a testbench that checks whether the actual value written on memory matches the expected value.
 */
module testbench();

  reg         clk;
  reg         reset;
  reg [1:0] 	ctr;

  wire [15:0] datain, dataAddr;
  wire MemWr;

  // instantiate device to be tested
  top dut(clk, reset, datain, dataAddr, MemWr);
  
  // initialize test
  initial
    begin
      reset <= 1; # 1; reset <= 0;
	  ctr <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 1; clk <= 0; # 1;
    end

  // check results
  always@(negedge clk)
    begin
      if(MemWr) begin
		
        if(((dataAddr != 0 | datain != 5) & ctr == 0) |
		  ((dataAddr != 2 | datain != 5) & ctr == 1) |
		  ((dataAddr != 4 | datain != 15) & ctr == 2) |
		  ((dataAddr != 6 | datain != 16'b1111111111110001) & ctr == 3)) begin
          $display("Simulation failed. Values: address=%x, data=%x, ctr=%d, time=%d", dataAddr, datain, ctr, $time);
        end else begin
		  $display("write passed. address=%x, data=%x, ctr=%d, time=%d", dataAddr, datain, ctr, $time);
	  	end
		  
		if(ctr == 3) begin
			$display("simulation passed!");
			$stop;
		end
			
	  	ctr = ctr + 1;
      end
    end
endmodule

/* 
 * description: The module top includes the connection of CPU and both instruction memory and data memory.
 * inputs: clk, reset	
 * output: datain, dataAddr, MemWr
 */
module top(input         clk, reset,
		output [15:0] datain, dataAddr,  
		output MemWr);

  wire [15:0] dataout, instruction, instrAddr;
  wire MemRd;
  
  // instantiate processor and memories
  cpu cpu(clk, reset,
  dataout, instruction,
  MemRd, MemWr,
  datain, instrAddr, dataAddr);
  
  imem imem(instrAddr, instruction);
  
  /*
 	 		input clk, MemRd, MemWr,
			input [15:0] address,
			input [15:0] DataIn,
            output [15:0] Dataout 
  */
  dmem dmem(clk, MemRd, MemWr, dataAddr, datain, dataout);

endmodule