import os
import hjson

def parse_instructions(data_dir, extensions_to_parse):
    """
    Parses HJSON files in the specified directory to extract RISC-V instructions
    and their examples for the given extensions.

    Args:
        data_dir (str): The directory containing the HJSON files.
        extensions_to_parse (list): A list of extension prefixes to parse
                                     (e.g., ["RV_I", "RV_M"]).

    Returns:
        dict: A dictionary where keys are extension names (e.g., "I", "M")
              and values are lists of tuples (instruction_name, example_code).
    """
    parsed_instructions = {}

    for filename in os.listdir(data_dir):
        if filename.endswith(".hjson"):
            filepath = os.path.join(data_dir, filename)
            try:
                with open(filepath, 'r') as f:
                    data = hjson.load(f)

                for ext_key in data:
                    # Normalize the extension key from the file (e.g., "RV_I" -> "I")
                    # and the target extensions (e.g., "I" -> "RV_I" for lookup)
                    normalized_ext_key_parts = ext_key.split('_')
                    if len(normalized_ext_key_parts) > 1:
                        # "I" from "RV_I", "System" from "RV_System"
                        simple_ext_name_from_file = normalized_ext_key_parts[1]
                    else:
                        # Should not happen with current file structure like "RV_I"
                        simple_ext_name_from_file = ext_key

                    # Convert both to uppercase for case-insensitive comparison
                    target_extensions_upper = [ext.upper() for ext in extensions_to_parse]

                    if simple_ext_name_from_file.upper() in target_extensions_upper:
                        # Use the original casing from the file for the dictionary key, for consistency
                        # or decide on a standard (e.g. simple_ext_name_from_file.upper())
                        dict_key = simple_ext_name_from_file
                        if dict_key not in parsed_instructions:
                            parsed_instructions[dict_key] = []

                        if isinstance(data[ext_key], list):
                            for instruction_info in data[ext_key]:
                                name = instruction_info.get("name")
                                example = instruction_info.get("example")
                                if name and example:
                                    parsed_instructions[dict_key].append((name, example))
            except Exception as e:
                print(f"Error parsing {filepath}: {e}")
    return parsed_instructions

def print_parsed_instructions(instructions_dict):
    """Prints the parsed RISC-V instructions and examples."""
    for extension, instructions in instructions_dict.items():
        print(f"--- {extension.upper()} Extension Instructions ---")
        if instructions:
            for name, example in instructions:
                print(f"  Instruction: {name}")
                print(f"  Example:     {example}")
        else:
            print("  No instructions found for this extension in the provided files.")
        print("\\n")

if __name__ == "__main__":
    data_directory = "data"
    # Define which extensions we want to parse based on user request
    # User requested: I, M, C, System, Zicsr
    # Corresponding HJSON keys are expected to be RV_I, RV_M, RV_C, RV_SYSTEM, RV_ZICSR
    target_extensions = ["I", "M", "C", "SYSTEM", "ZICSR"]

    extracted_data = parse_instructions(data_directory, target_extensions)
    print_parsed_instructions(extracted_data)
