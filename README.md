# Pipelined RISC Processor Design

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

## Verification & Testing
To verify the design:
1. Write test programs in the ISA.
2. Simulate the design using waveform diagrams.
3. Validate results using testbench.

## Acknowledgements
The project statement was prepared by my instructors **Aziz Qaroush** and **Ayman Hroub** at **BZU**.

