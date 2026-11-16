# 16-bit Basic CPU Design in Verilog

A small step towards understanding how processors actually work!

This project is my attempt at designing a basic 16-bit CPU from scratch using Verilog HDL. Instead of just implementing an ALU and stopping there, I wanted to understand how different parts of a processor communicate with each other and how instructions are actually executed.

So, I built a simple CPU with its own datapath, control unit, registers, ALU, shared bus and memory.

The idea was to get a better understanding of what happens inside a processor when it fetches an instruction, decodes it, processes data and stores the result.

## What does this CPU do?

The processor uses a 16-bit instruction and data architecture with a shared memory space for both instructions and data.

It follows a basic **Fetch – Decode – Execute** approach, controlled by a finite-state machine inside the control unit.

Some of the operations supported by the processor include:

- Arithmetic operations (Addition, Subtraction, Increment and Decrement).
- Logical operations (AND, OR, XOR, NAND, NOR, XNOR and NOT).
- Logical Shift Left and Logical Shift Right.
- LOAD and STORE operations.
- HALT instruction to stop processor execution.

The processor has 4096 memory locations, with each location storing 16 bits. This gives a total memory capacity of **8 KB**.

## Architecture

The processor is divided into a few major functional blocks. Each block handles a specific task, and together they form the complete CPU.

### 1. Control Unit

The control unit is responsible for coordinating the entire processor.

It decodes the opcode from the instruction register and generates the necessary control signals to operate the datapath.

It uses a timing-based finite-state machine (T0–T7) to execute instructions over multiple clock cycles.

### 2. Datapath

The datapath handles the actual movement and processing of data.

It connects the registers, ALU, memory and internal bus. Depending on the control signals, data is transferred between different components.

### 3. ALU (Arithmetic Logic Unit)

The ALU is a 16-bit combinational unit responsible for performing arithmetic and logical operations.

It supports 13 operations:

| Opcode | Operation |
|---|---|
| 0000 | ADD |
| 0001 | SUB |
| 0010 | AND |
| 0011 | OR |
| 0100 | XOR |
| 0101 | NAND |
| 0110 | NOR |
| 0111 | XNOR |
| 1000 | NOT |
| 1001 | INC |
| 1010 | DEC |
| 1011 | SHL |
| 1100 | SHR |

It also generates zero, carry and overflow indicators.

### 4. Registers

The processor uses dedicated registers to temporarily store data during instruction execution.

| Register | Purpose |
|---|---|
| PC (Program Counter) | Holds the address of the next instruction |
| AR (Address Register) | Holds the memory address being accessed |
| DR (Data Register) | Temporarily stores data read from memory |
| IR (Instruction Register) | Holds the current instruction |
| ACC (Accumulator) | Stores ALU results and intermediate data |

### 5. Shared Internal Bus

One interesting part of this design is the use of a common 16-bit internal bus.

Instead of connecting every register directly to every other register, a multiplexer selects which component can place its data onto the bus.

This makes data transfer between different CPU components easier to manage.

### 6. Memory

The CPU uses a 4096 × 16-bit memory.

Both instructions and data are stored in the same memory, following a Von Neumann-style organization.

The memory is initialized with a sample program and its operands.

## Instruction Set

The processor supports 16 different opcode values.

| Opcode | Instruction | Description |
|---|---|---|
| 0000 | ADD | Addition |
| 0001 | SUB | Subtraction |
| 0010 | AND | Bitwise AND |
| 0011 | OR | Bitwise OR |
| 0100 | XOR | Bitwise XOR |
| 0101 | NAND | Bitwise NAND |
| 0110 | NOR | Bitwise NOR |
| 0111 | XNOR | Bitwise XNOR |
| 1000 | NOT | Complement accumulator |
| 1001 | INC | Increment accumulator |
| 1010 | DEC | Decrement accumulator |
| 1011 | SHL | Logical shift left |
| 1100 | SHR | Logical shift right |
| 1101 | LOAD | Load data into accumulator |
| 1110 | STORE | Store accumulator data in memory |
| 1111 | HALT | Stop execution |

The instruction format is:

| Bits | Description |
|---|---|
| [15:12] | Opcode (4 bits) |
| [11:0] | Address / Operand field (12 bits) |

This gives the processor support for 16 different instructions and a 12-bit address field.

## Hardware Implementation

The project is designed to run on an FPGA.

The top module interfaces with the FPGA board and provides:

- 100 MHz external clock input.
- Reset switch.
- Push-button controlled CPU clock.
- 16 onboard LEDs.
- Two four-digit seven-segment display interfaces.

The push-button input is synchronized and debounced before being used to control the CPU clock.

The seven-segment displays show the accumulator value and current instruction, making it easier to observe what is happening inside the processor during execution.

The LEDs are connected to the internal 16-bit bus, allowing the data moving through the processor to be observed directly.

## Repository Structure

```text
16-bit-CPU/
│
├── src/
│   └── top.v
│
├── constraints/
│   └── top.xdc
│
└── README.md
```

*The source file contains the different Verilog modules used to build the processor.*

## Tools & Technologies

- **HDL:** Verilog
- **FPGA Development:** Xilinx Vivado
- **Hardware:** Xilinx FPGA development board
- **Design Approach:** Modular RTL Design
- **Architecture:** 16-bit CPU
- **Memory:** 4096 × 16-bit

## What I Learned

This project helped me understand processor design at a much deeper level.

Some of the things I explored while working on it:

- How a CPU fetches and executes instructions.
- How a control unit generates timing and control signals.
- How registers communicate through a shared internal bus.
- How an ALU interacts with the accumulator and data register.
- How memory read and write operations work.
- How to divide a processor into independent RTL modules.
- How to connect internal processor signals to physical FPGA peripherals.

One of the most interesting parts was figuring out how to coordinate all these individual modules so that the processor could execute an instruction correctly, one clock cycle at a time.

## Future Improvements

This is a basic processor design, but there is a lot more I would like to explore.

Some improvements I have in mind:

- Implement conditional branching and jump instructions.
- Add status flag registers.
- Improve the instruction set.
- Develop a proper assembler for the CPU.
- Add support for loading custom programs into memory.
- Explore pipelining and improve instruction execution.
- Eventually experiment with a more advanced 32-bit processor architecture.

## Final Thoughts

I started this project because I wanted to understand what actually happens inside a processor rather than just learning its architecture theoretically.

Building the individual modules was one thing, but making them work together as a complete system was a completely different experience.

This is a basic CPU, but it has given me a starting point to explore computer architecture, RTL design and eventually more advanced processor architectures.

**There's something really interesting about building a processor from individual logic blocks and watching it execute instructions that you designed yourself.**

More experiments and improvements coming!
