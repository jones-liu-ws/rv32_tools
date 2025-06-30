riscv_instructions = {
    "I": [
        "LUI", "AUIPC", "JAL", "JALR", "BEQ", "BNE", "BLT", "BGE", "BLTU", "BGEU",
        "LB", "LH", "LW", "LBU", "LHU", "SB", "SH", "SW", "ADDI", "SLTI",
        "SLTIU", "XORI", "ORI", "ANDI", "SLLI", "SRLI", "SRAI", "ADD", "SUB",
        "SLL", "SLT", "SLTU", "XOR", "SRL", "SRA", "OR", "AND", "FENCE",
        "FENCE.I", "ECALL", "EBREAK"
    ],
    "M": [
        "MUL", "MULH", "MULHSU", "MULHU", "DIV", "DIVU", "REM", "REMU"
    ],
    "C": [
        "C.ADDI4SPN", "C.FLD", "C.LQ", "C.FLW", "C.LD", "C.FSD", "C.SQ",
        "C.FSW", "C.SD", "C.NOP", "C.ADDI", "C.JAL", "C.LI", "C.ADDI16SP",
        "C.LUI", "C.SRLI", "C.SRAI", "C.ANDI", "C.SUB", "C.XOR", "C.OR",
        "C.AND", "C.J", "C.BEQZ", "C.BNEZ", "C.SLLI", "C.FLDSP", "C.LQSP",
        "C.FLWSP", "C.LDSP", "C.JR", "C.MV", "C.EBREAK", "C.JALR", "C.ADD",
        "C.FSDSP", "C.SQSP", "C.FSWSP", "C.SDSP"
    ],
    "Zicsr": [
        "CSRRW", "CSRRS", "CSRRC", "CSRRWI", "CSRRSI", "CSRRCI"
    ],
    "System": [
        # System instructions are often part of the base 'I' extension (ECALL, EBREAK)
        # or Zicsr (CSR instructions). Privileged instructions like MRET, SRET, WFI
        # are also considered system-level but are part of the privileged architecture.
        "MRET", "SRET", "URET", "WFI",
        # SFENCE.VMA may also be considered a system instruction
        "SFENCE.VMA"
    ]
}

def print_instructions(instructions_dict):
    """Prints the RISC-V instructions categorized by extension."""
    for extension, instructions in instructions_dict.items():
        print(f"--- {extension} Extension Instructions ---")
        for instruction in instructions:
            print(instruction)
        print("\\n")

if __name__ == "__main__":
    print_instructions(riscv_instructions)
