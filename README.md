# Simple 32-bit Processor

A basic implementation of a 32-bit processor architecture designed for educational purposes. This project showcases the fundamental concepts behind CPU design, including instruction execution, data flow, and control logic.

## Overview

This processor is built to execute a simplified instruction set, supporting core operations such as arithmetic, logic, branching, and memory access. It is ideal for learning and teaching computer architecture concepts.

## Features

- 32-bit instruction and data width
- Simple ALU supporting basic arithmetic and logical operations
- General-purpose register file
- Control unit for instruction decoding and execution control
- Program counter and branching mechanism
- Instruction memory and data memory modules

## Architecture Components

- **ALU (Arithmetic Logic Unit)**: Performs basic arithmetic and logic operations.
- **Register File**: Stores temporary data and intermediate results.
- **Control Unit**: Decodes instructions and generates control signals.
- **Memory Interface**: Separate instruction and data memory units.
- **Program Counter (PC)**: Keeps track of the current instruction address.

## Instruction Set (Example)

| Mnemonic | Operation         | Description                    |
|----------|------------------|--------------------------------|
| ADD      | R-type           | Add two registers              |
| SUB      | R-type           | Subtract two registers         |
| AND      | R-type           | Bitwise AND                    |
| OR       | R-type           | Bitwise OR                     |
| MV       | I-type           | MOve value to a register       |


## Tools & Technologies

- Hardware Description Language Verilog
- Simulation Environment Vivado

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Simple-32bit-Processor.git
