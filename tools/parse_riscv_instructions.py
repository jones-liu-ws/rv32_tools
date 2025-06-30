import os
import hjson
import argparse

def parse_hjson_files(data_dir, extensions_to_parse):
    """
    Parses HJSON files in the specified directory to extract RISC-V instructions
    and their details for the given extensions.

    Args:
        data_dir (str): The directory containing the HJSON files.
        extensions_to_parse (list): A list of extension names (uppercase) to parse
                                     (e.g., ["I", "M", "SYSTEM"]).

    Returns:
        dict: A dictionary where keys are extension names (e.g., "I", "M")
              and values are lists of instruction detail dictionaries.
    """
    parsed_data = {}

    for filename in os.listdir(data_dir):
        if filename.endswith(".hjson"):
            filepath = os.path.join(data_dir, filename)
            try:
                with open(filepath, 'r') as f:
                    data = hjson.load(f)

                for ext_key_in_file in data: # e.g., "RV_I", "RV_M", "RV_System"
                    if not isinstance(data[ext_key_in_file], list):
                        continue

                    normalized_ext_parts = ext_key_in_file.split('_')
                    if len(normalized_ext_parts) > 1:
                        # "I" from "RV_I", "System" from "RV_System", "Zicsr" from "RV_Zicsr"
                        simple_ext_name = normalized_ext_parts[1]
                    else:
                        # Fallback, though not expected for current files
                        simple_ext_name = ext_key_in_file

                    # Compare with target extensions (case-insensitive)
                    if simple_ext_name.upper() in extensions_to_parse:
                        # Use the simple_ext_name (maintaining original case like "System") as a key
                        # or decide on a standard like simple_ext_name.upper()
                        current_ext_key_for_dict = simple_ext_name.upper() # Standardize to upper for dict keys

                        if current_ext_key_for_dict not in parsed_data:
                            parsed_data[current_ext_key_for_dict] = []

                        for instruction_info in data[ext_key_in_file]:
                            # Store the whole instruction_info dict
                            parsed_data[current_ext_key_for_dict].append(instruction_info)
            except Exception as e:
                print(f"Error parsing {filepath}: {e}")
    return parsed_data

def print_default_instructions(instructions_data):
    """Prints the RISC-V instructions and examples (default behavior)."""
    for extension_name_upper, instructions_list in instructions_data.items():
        print(f"--- {extension_name_upper} Extension Instructions ---")
        if instructions_list:
            for instr_info in instructions_list:
                name = instr_info.get("name", "N/A")
                example = instr_info.get("example", "N/A")
                print(f"  Instruction: {name}")
                print(f"  Example:     {example}")
        else:
            print(f"  No instructions found for {extension_name_upper} in the provided files.")
        print("\\n")

def generate_verilog_defines(instructions_data):
    """Generates Verilog `define` statements for instructions."""
    print("// Verilog Instruction Defines")
    for ext_name, instructions_list in instructions_data.items():
        print(f"// --- {ext_name} Extension ---")
        for instr_info in instructions_list:
            name = instr_info.get("name", "").upper().replace('.', '_')
            fields = instr_info.get("fields", [])

            extracted_opcode = None
            is_c_instruction = name.startswith("C_")

            if is_c_instruction:
                # For C-instructions, 'encoding' field is typically the 2-bit opcode
                extracted_opcode = instr_info.get("encoding")
                # Validate or find in fields if 'encoding' is not suitable
                if not (extracted_opcode and len(extracted_opcode) == 2 and extracted_opcode.replace('0','').replace('1','') == ""):
                    for field in fields:
                        if field.get("name") == "opcode" and \
                           len(field.get("value","")) == 2 and \
                           field.get("value","").replace('0','').replace('1','') == "":
                            extracted_opcode = field.get("value")
                            break
            else: # For non-C (standard 32-bit) instructions
                # 'encoding' field might be the 7-bit opcode
                extracted_opcode = instr_info.get("encoding")
                # Validate or find in fields if 'encoding' is not suitable
                if not (extracted_opcode and len(extracted_opcode) == 7 and extracted_opcode.replace('0','').replace('1','') == ""):
                    for field in fields:
                        if field.get("name") == "opcode" and \
                           len(field.get("value","")) == 7 and \
                           field.get("value","").replace('0','').replace('1','') == "":
                            extracted_opcode = field.get("value")
                            break

            if name and extracted_opcode:
                instr_format = instr_info.get("format", "").lower()

                if is_c_instruction:
                    # Ensure the extracted_opcode for C is indeed valid 2-bit binary
                    if not (len(extracted_opcode) == 2 and extracted_opcode.replace('0','').replace('1','') == ""):
                        print(f"// Warning: Could not determine valid 2-bit opcode for C-instruction {name}. Opcode found: '{extracted_opcode}'")
                        continue # Skip this instruction if opcode is invalid
                    define_str = f"`define {name} &{{instr[1:0]==2'b{extracted_opcode}"

                    # Add other distinguishing 'functX' fields for C instructions
                    for field in fields:
                        field_name = field.get("name", "")
                        field_value = field.get("value", "")
                        field_bits = field.get("bits", "")
                        # Check if it's a funct field with a binary value
                        if field_name.startswith("funct") and field_value.replace('0','').replace('1','') == "":
                            if ":" in field_bits: # Range of bits e.g. "15:13"
                                msb, lsb = map(int, field_bits.split(':'))
                                length = msb - lsb + 1
                                define_str += f" && instr[{field_bits}]=={length}'b{field_value}"
                            elif len(field_bits) > 0: # Single bit e.g. "12" (ensure field_bits is not empty)
                                define_str += f" && instr[{field_bits}]==1'b{field_value}"
                else: # Non-C instructions
                    # Ensure the extracted_opcode for non-C is indeed valid 7-bit binary
                    if not (len(extracted_opcode) == 7 and extracted_opcode.replace('0','').replace('1','') == ""):
                        print(f"// Warning: Could not determine valid 7-bit opcode for instruction {name}. Opcode found: '{extracted_opcode}'")
                        continue # Skip this instruction if opcode is invalid
                    define_str = f"`define {name} &{{instr[6:0]==7'b{extracted_opcode}"

                    # Extract standard funct3 and funct7 for non-C instructions
                    current_funct3 = None
                    current_funct7 = None
                    for field in fields:
                        if field.get("name") == "funct3":
                            current_funct3 = field.get("value")
                        elif field.get("name") == "funct7":
                            current_funct7 = field.get("value")

                    if current_funct3:
                        if instr_format in ["r-type", "i-type", "s-type", "b-type"]: # Common formats using funct3 at std loc
                             define_str += f" && instr[14:12]==3'b{current_funct3}"

                    if current_funct7 and instr_format == "r-type": # Funct7 for R-type
                        define_str += f" && instr[31:25]==7'b{current_funct7}"

                define_str += "}" # Close the &{ ... }
                print(define_str)
            elif name: # Name was found but opcode couldn't be determined
                 print(f"// Warning: Opcode not found or invalid for instruction {name}")
        print("")

def generate_immediate_decode(instructions_data):
    """Generates Verilog immediate decoding logic."""
    print("// Verilog Immediate Decoding (Illustrative - requires detailed bit mapping)")
    for ext_name, instructions_list in instructions_data.items():
        print(f"// --- {ext_name} Extension Immediates ---")
        for instr_info in instructions_list:
            name = instr_info.get("name", "unknown")
            format_type = instr_info.get("format", "").lower()
            example = instr_info.get("example", "") # Keep for context if needed

            # Based on user-provided format:
            # lui    : imm = {instr[31:12],12'b0}; // Corrected based on typical Verilog
            # auipc  : imm = {instr[31:12],12'b0}; // Corrected
            # jal    : imm = {{11{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // 21-bit signed
            # jalr   : imm = {{20{instr[31]}}, instr[31:20]}; // 12-bit signed
            # beq/bne: imm = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // 13-bit signed

            imm_decode_str = f"// {name} ({format_type}): "

            if name == "lui" or name == "auipc": # U-type
                imm_decode_str += f"{name.ljust(12)}: imm = {{instr[31:12], 12'b0}};"
            elif name == "jal": # J-type
                # Corrected JAL immediate: imm[20|10:1|11|19:12] + sign extension
                # instr[31] (imm[20]), instr[19:12] (imm[19:12]), instr[20] (imm[11]), instr[30:21] (imm[10:1]), 1'b0
                imm_decode_str += f"{name.ljust(12)}: imm = {{{{{{11{{instr[31]}}}}, instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}};"
            elif name == "jalr": # I-type (load/addi/jalr)
                imm_decode_str += f"{name.ljust(12)}: imm = {{{{{{20{{instr[31]}}}}, instr[31:20]}};"
            elif format_type == "i-type": # General I-type (addi, slti, lb, lh, lw, etc.)
                 imm_decode_str += f"{name.ljust(12)}: imm = {{{{{{20{{instr[31]}}}}, instr[31:20]}};"
            elif format_type == "b-type": # (beq, bne, blt, etc.)
                # Corrected B-type: imm[12|10:5] , imm[4:1|11] + sign extension
                # instr[31](imm[12]), instr[7](imm[11]), instr[30:25](imm[10:5]), instr[11:8](imm[4:1]), 1'b0
                imm_decode_str += f"{name.ljust(12)}: imm = {{{{{{19{{instr[31]}}}}, instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}};"
            elif format_type == "s-type": # (sb, sh, sw)
                # S-type: imm[11:5], imm[4:0]
                # instr[31:25] (imm[11:5]), instr[11:7] (imm[4:0])
                imm_decode_str += f"{name.ljust(12)}: imm = {{{{{{20{{instr[31]}}}}, instr[31:25]}}, instr[11:7]}};"
            else:
                imm_decode_str += f"{name.ljust(12)}: // Immediate format not explicitly defined for this type or instruction in example."

            print(imm_decode_str)
        print("")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse RISC-V instruction HJSON files and generate various outputs.")
    parser.add_argument("-v", "--verilog", action="store_true",
                        help="Generate Verilog `define` statements for instructions.")
    parser.add_argument("-i", "--imm", action="store_true",
                        help="Generate Verilog immediate decoding logic.")
    # Can add more arguments here, e.g., for specific extensions
    # parser.add_argument("--extensions", nargs='+', default=["I", "M", "C", "SYSTEM", "ZICSR"],
    #                     help="Specify which extensions to process (e.g., I M C). Default all.")

    args = parser.parse_args()

    data_directory = "data"
    # For now, always parse all supported extensions.
    # Could be tied to an --extensions argument later.
    target_extensions_upper = ["I", "M", "C", "SYSTEM", "ZICSR"]

    # The parse_hjson_files function now expects uppercase extension names
    all_instructions_data = parse_hjson_files(data_directory, target_extensions_upper)

    if not any(vars(args).values()): # Check if any arguments were passed
        # Default behavior: print instructions and examples
        print_default_instructions(all_instructions_data)
    else:
        if args.verilog:
            generate_verilog_defines(all_instructions_data)
        if args.imm:
            generate_immediate_decode(all_instructions_data)

    # Example of how to access specific instruction details if needed elsewhere:
    # if "I" in all_instructions_data:
    #     for instr in all_instructions_data["I"]:
    #         if instr['name'] == 'addi':
    #             print(f"ADDI details: {instr}")
