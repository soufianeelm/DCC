# DCC Command Station for Train Platform Control
This project involves the design and development of an embedded DCC (Digital Command Control) command station for controlling a model train platform. The system was implemented using an FPGA with a VHDL-based processing unit to convert bit commands into signals compatible with the DCC protocol. A MicroBlaze soft processor was also utilized to program the hardware in C, creating an interactive API for users to send commands via a simple interface.

## Features
- VHDL Implementation: Developed a custom processing unit to handle DCC signal commands.
- Embedded API: Programmed in C using the MicroBlaze module, allowing users to interact with the system through an intuitive menu interface and issue commands.
- User Interface: On-board control via buttons and a display screen, enabling users to navigate the system and issue commands.

## Requirements
- FPGA with MicroBlaze support
- VHDL Compiler (e.g., Xilinx Vivado)
- C Compiler for MicroBlaze
- DCC-compatible train platform for testing

## Installation
1. Clone the repository:
```bash
git clone https://github.com/soufianeelm/DCC.git
```

3. Build the VHDL design for the FPGA using a compatible toolchain (e.g., Xilinx Vivado).
4. Program the MicroBlaze processor with the provided C code.

## Usage
1. Deploy the VHDL design to the FPGA.
2. Load the C program onto the MicroBlaze processor.
3. Use the on-board interface (buttons and screen) to navigate and issue DCC commands to the train platform.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
