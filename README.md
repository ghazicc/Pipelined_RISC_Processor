# Pipelined RISC Processor Design
This repository contains the Verilog source code of the design of a pipelined RISC processor. Additional details regarding the ISA, implementation and verification can be explored in the provided PDF [report](PipelinedRISCProcessor.pdf).
# Table of Contents

1. [Overview](#overview)
2. [Objectives](#objectives)
3. [Team](#team)
4. [Processor Specifications](#processor-specifications)
   - [Instruction and Word Size](#instruction-and-word-size)
   - [Registers](#registers)
   - [Instruction Types](#instruction-types)
   - [Memory](#memory)
   - [ALU](#alu)
5. [Instruction Set Architecture (ISA) & Opcodes](#instruction-set-architecture-isa--opcodes)
6. [Pipeline Stages](#pipeline-stages)
7. [Acknowledgements](#acknowledgements)

## Overview
This project focuses on designing and verifying a simple pipelined RISC processor using Verilog, for educational purposes in **Computer Architecture**. The processor is built with a 5-stage pipeline and supports various instruction types and a custom Instruction Set Architecture (ISA).

## Objectives
- **Design** a 16-bit pipelined RISC processor with a 5-stage pipeline.
- **Implement** and simulate code sequences to verify the functionality of the processor.
- **Write a testbench** to test the processor’s operations.

## Processor Specifications
- **Instruction and Word Size**: 16 bits
- **Registers**: 
  - 8 general-purpose registers (R0 to R7) where R0 is hardwired to 0.
  - A 16-bit Program Counter (PC).
- **Instruction Types**:
  - R-type (Register)
  - I-type (Immediate)
  - J-type (Jump)
  - S-type (Store)
- **Memory**:
  - Byte-addressable
  - Little-endian ordering
  - Separate instruction and data memory
- **ALU**: Handles arithmetic and logical operations, including condition signals (zero, carry, overflow).

## Instruction Set Architecture (ISA) & Opcodes
The processor supports the following instructions, categorized by their type and accompanied by their opcode values:

| No. | Instruction | Format  | Meaning                                          | Opcode | Mode |
|-----|-------------|---------|--------------------------------------------------|--------|------|
| 1   | AND         | R-Type  | Reg(Rd) = Reg(Rs1) & Reg(Rs2)                    | 0000   | -    |
| 2   | ADD         | R-Type  | Reg(Rd) = Reg(Rs1) + Reg(Rs2)                    | 0001   | -    |
| 3   | SUB         | R-Type  | Reg(Rd) = Reg(Rs1) - Reg(Rs2)                    | 0010   | -    |
| 4   | ADDI        | I-Type  | Reg(Rd) = Reg(Rs1) + Imm                         | 0011   | -    |
| 5   | ANDI        | I-Type  | Reg(Rd) = Reg(Rs1) & Imm                         | 0100   | -    |
| 6   | LW          | I-Type  | Reg(Rd) = Mem[Reg(Rs1) + Imm]                    | 0105   | -    |
| 7   | LBu         | I-Type  | Load unsigned byte                               | 0110   | 0    |
| 8   | LBs         | I-Type  | Load signed byte                                 | 0110   | 1    |
| 9   | SW          | I-Type  | Mem[Reg(Rs1) + Imm] = Reg(Rd)                    | 0111   | -    |
| 10  | BGT         | I-Type  | If Reg(Rd) > Reg(Rs1), branch                    | 1000   | 0    |
| 11  | BGTZ        | I-Type  | If Reg(Rd) > 0, branch                           | 1000   | 1    |
| 12  | BLT         | I-Type  | If Reg(Rd) < Reg(Rs1), branch                    | 1001   | 0    |
| 13  | BLTZ        | I-Type  | If Reg(Rd) < 0, branch                           | 1001   | 1    |
| 14  | BEQ         | I-Type  | If Reg(Rd) == Reg(Rs1), branch                   | 1010   | 0    |
| 15  | BEQZ        | I-Type  | If Reg(Rd) == 0, branch                          | 1010   | 1    |
| 16  | BNE         | I-Type  | If Reg(Rd) != Reg(Rs1), branch                   | 1011   | 0    |
| 17  | BNEZ        | I-Type  | If Reg(Rd) != 0, branch                          | 1011   | 1    |
| 18  | JMP         | J-Type  | Unconditional jump                               | 1100   | -    |
| 19  | CALL        | J-Type  | Call a function, save PC + 4 in r15               | 1101   | -    |
| 20  | RET         | J-Type  | Return from a function, set PC to r7              | 1110   | -    |
| 21  | Sv          | S-Type  | Store immediate in memory location of Reg(rs)    | 1111   | -    |

## Pipeline Stages
The processor operates in a 5-stage pipeline:
1. **Fetch**: Retrieve instruction from memory.
2. **Decode**: Decode instruction and read registers.
3. **Execute**: Perform ALU operations.
4. **Memory Access**: Access memory (load/store).
5. **Write Back**: Write result back to register.

## Datapath
![datapath image](Datapath.jpeg)

## Team
- [Ghazi Hajj Qasem](https://github.com/ghazicc)
- [Ameer Jamal](https://github.com/Ameerjamal22)
- [Mumen Anbar](https://github.com/MumenAnbar)

## Acknowledgements
- The project statement was prepared by my instructors, **Aziz Qaroush** and **Ayman Hroub**, at **BZU**.
- [customasm](https://hlorenzi.github.io/customasm/web/?fbclid=IwAR04c2OYqIuKfF8_CsOXjz62jWVuoH2OU_qp4EW0M8mgQ3RxgvCDhePUT94) - This repository proved as a useful tool for generating machine code for assembly code.

