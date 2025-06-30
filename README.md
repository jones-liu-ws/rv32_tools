# rv32_tools

A comprehensive toolkit for RISC-V RV32IMC_ZICSR development, including utilities for disassembly, simulation, and test program generation.

The design materials are sourced from HJSON files located in the `./data` directory. This directory contains HJSON files that define instruction sets for various RISC-V extensions, including I, M, C, System, and Zicsr.

A template for the HJSON files can be found in `template.hjson`. The format is illustrated below:

```
{
   "name": "RISCV Instructions",
   "description": "A collection of RISC-V instructions with their encodings and descriptions.",
   "RV32I": [  // Extension name
        {
            "name": "lb", // Instruction name
            "description": "Load byte",
            "encoding": "0000011",
            "format": "I-type",
            "fields": [  // Instruction encoding bitmap
                {
                    "bits": "6:0",
                    "name": "opcode",
                    "value": "0000011"
                },
                {
                    "bits": "11:7",
                    "name": "rd",
                    "value": "destination register"
                },
                {
                    "bits": "14:12",
                    "name": "funct3",
                    "value": "000 (load byte)"
                },
                {
                    "bits": "19:15",
                    "name": "rs1",
                    "value": "base register"
                },
                {
                    "bits": "31:20",
                    "name": "imm",
                    "value": "immediate value (offset)"
                }
            ]
        },
        {  // Additional instructions
            "name": "sb", 
            "description": "Store byte",
            "encoding": "0100011",
            "format": "S-type",
            "fields": [
                ...