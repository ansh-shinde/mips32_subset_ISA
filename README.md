# 32-bit Pipelined MIPS Processor (Verilog HDL)

## Overview

A 32-bit five-stage pipelined MIPS processor implemented in Verilog HDL. The processor supports a subset of the MIPS instruction set architecture (ISA) and demonstrates the fundamental concepts of pipelined CPU design.

The design employs a dual-phase clocking methodology to simplify pipeline implementation and reduce structural hazards.

---

## Features

* 32-bit MIPS Architecture
* Five-Stage Instruction Pipeline
* Two-Phase Clocking Scheme
* Register-Register ALU Operations
* Register-Immediate ALU Operations
* Load and Store Instructions
* Conditional Branch Instructions
* Unified Instruction and Data Memory
* General Purpose Register File (32 × 32)
* Functional Verification using Multiple Test Programs

---

## Pipeline Stages

### 1. Instruction Fetch (IF)

* Fetches instructions from memory.
* Updates the Program Counter (PC).
* Handles branch target redirection.

### 2. Instruction Decode (ID)

* Decodes fetched instruction.
* Reads operands from register file.
* Sign-extends immediate values.
* Determines instruction type.

### 3. Execute (EX)

* Performs arithmetic and logical operations.
* Calculates effective addresses.
* Evaluates branch conditions.

### 4. Memory Access (MEM)

* Reads data from memory for load instructions.
* Writes data to memory for store instructions.

### 5. Write Back (WB)

* Writes ALU or memory results back into the register file.

---

## Clocking Scheme

The processor uses two non-overlapping clocks:

| Clock  | Pipeline Stages |
| ------ | --------------- |
| `clk1` | IF, EX          |
| `clk2` | ID, MEM, WB     |

This clocking methodology simplifies pipeline implementation and prevents resource conflicts.

---

## Supported Instructions

### Register-Register Instructions

| Instruction | Operation      |
| ----------- | -------------- |
| ADD         | Addition       |
| SUB         | Subtraction    |
| MUL         | Multiplication |
| AND         | Bitwise AND    |
| OR          | Bitwise OR     |
| SLT         | Set Less Than  |

### Register-Immediate Instructions

| Instruction | Operation               |
| ----------- | ----------------------- |
| ADDI        | Add Immediate           |
| SUBI        | Subtract Immediate      |
| SLTI        | Set Less Than Immediate |

### Memory Instructions

| Instruction | Operation  |
| ----------- | ---------- |
| LW          | Load Word  |
| SW          | Store Word |

### Branch Instructions

| Instruction | Operation                   |
| ----------- | --------------------------- |
| BEQZ        | Branch if Equal to Zero     |
| BNEQZ       | Branch if Not Equal to Zero |

### Processor Control

| Instruction | Operation      |
| ----------- | -------------- |
| HLT         | Halt Processor |

---

## Architecture

```text
                     +----------------+
                     | Instruction /  |
                     | Data Memory    |
                     +--------+-------+
                              |
                              v
+------+    +---------+   +--------+   +---------+   +---------+
|  PC  | -> | IF/ID   |-> | ID/EX | ->| EX/MEM  | ->| MEM/WB  |
+------+    +---------+   +--------+   +---------+   +---------+
                              |
                              v
                    +----------------+
                    | Register File  |
                    |   (32 x 32)    |
                    +----------------+
                              |
                              v
                    +----------------+
                    | ALU            |
                    +----------------+
```

---

## Processor Components

### Register File

* 32 General Purpose Registers
* 32-bit Wide Registers
* Register R0 is hardwired to zero

### Memory

* Unified instruction and data memory
* 1024 × 32-bit memory locations

---

## Test Programs

### Example 1: Arithmetic Operations

Program verifies:

* Immediate instructions
* Register-register arithmetic
* Data dependency handling

Operations performed:

```text
R1 = 10
R2 = 20
R3 = 25

R4 = R1 + R2
R5 = R4 + R3
```

Expected Result:

```text
R4 = 30
R5 = 55
```

---

### Example 2: Memory Operations

Program verifies:

* Load Word (LW)
* Store Word (SW)
* Register-immediate operations

Operations performed:

```text
Load data from memory
Perform arithmetic
Store result back to memory
```

Expected Result:

```text
Mem[120] = 85
Mem[121] = 130
```

---

### Example 3: Factorial Program

Program computes:

```text
factorial(7)
```

Algorithm:

```text
result = result * N
N = N - 1
repeat until N == 0
```

Expected Result:

```text
Mem[198] = 5040
```

---

## Project Structure

```text
.
├── mips.v
├── mips_test1.v
├── mips_test2.v
├── mips_test3.v
├── mips.vcd
└── README.md
```

---

## Simulation

### Compile

```bash
iverilog -g2012 -o mips.out *.v
```

### Run

```bash
vvp mips.out
```

### View Waveforms

```bash
gtkwave mips.vcd
```

---

## Verification

The processor was verified using dedicated testbenches covering:

* Arithmetic instructions
* Immediate instructions
* Memory operations
* Branch operations
* Pipeline execution
* Factorial computation
* Register file functionality

---

## Key Concepts Demonstrated

* Computer Architecture
* MIPS Instruction Set Architecture
* Five-Stage Pipelining
* Datapath Design
* Control Unit Design
* Register File Design
* ALU Design
* Memory Interface Design
* Branch Handling
* RTL Design using Verilog HDL
* Functional Verification

---

## Tools Used

* Verilog HDL
* Icarus Verilog
* GTKWave

---

## Future Improvements

* Hazard Detection Unit
* Forwarding Unit
* Pipeline Stall Logic
* Exception Handling
* Cache Memory Integration
* Branch Prediction
* Full MIPS ISA Support

---

## Author

**Ansh Shinde**
