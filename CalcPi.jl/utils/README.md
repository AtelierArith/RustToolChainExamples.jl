# CalcPi.jl C-API Auto-generation Tool

This directory contains tools for automatically generating Julia bindings from C header files.

## Overview

Based on the mechanism from `SparseIR.jl/utils`, this tool automatically generates Julia's `C_API.jl` from `calcpi.h`.

## File Structure

- `generate_C_API.jl` - Main generation script
- `generator.toml` - Clang.jl configuration file
- `prologue.jl` - Prologue for generated code (library loading process)
- `Project.toml` - Dependencies (Clang.jl)

## Usage

### 1. Building the Rust Library

First, build the Rust library to generate the header file:

```bash
cd CalcPi.jl/deps/calcpi-rs
cargo build --release
```

This generates `CalcPi.jl/deps/calcpi-rs/include/calcpi.h`.

### 2. Generating Julia Bindings

Run the generation script:

```bash
cd CalcPi.jl/utils
julia generate_C_API.jl
```

By default, it looks for `../deps/calcpi-rs`. To specify a different path:

```bash
julia generate_C_API.jl --calcpi-rs-dir /path/to/calcpi-rs
```

### 3. Generated Files

`CalcPi.jl/src/C_API.jl` is generated. This file contains:

- Type definitions (e.g., `calcpi_monte_carlo_pi`)
- Constant definitions (e.g., `CALCPI_SUCCESS`)
- C function wrappers (e.g., `calcpi_monte_carlo_pi_new`)

## Generation Script Behavior

1. **Command-line argument parsing**: Path can be specified with `--calcpi-rs-dir`
2. **Directory validation**: Checks for the existence of `deps/calcpi-rs/include/calcpi.h`
3. **Parsing with Clang.jl**: Parses the C header
4. **Julia code generation**: Generates `C_API.jl`
5. **Prologue insertion**: Adds the contents of `prologue.jl` at the beginning

## Configuration Customization

### generator.toml

```toml
[general]
prologue_file_path = "./prologue.jl"
library_name = "libcalcpi_rs"
output_file_path = "./../src/C_API.jl"
module_name = "C_API"
export_symbol_prefixes = ["calcpi_", "CALCPI_"]
extract_c_comment_style = "doxygen"
```

### prologue.jl

Defines the library loading process. It prioritizes local builds and falls back to system libraries if not found.

## Troubleshooting

### Error: calcpi.h not found

Build the Rust library:

```bash
cd CalcPi.jl/deps/calcpi-rs && cargo build --release
```

### Error: CEnum not found

If `CEnum` is not used in the generated `C_API.jl`, remove the `using CEnum` line.

### Modifying Generated Code

Since the generated code is auto-generated, do not edit it directly. Instead:

1. Modify the C header and regenerate
2. Modify `prologue.jl` and regenerate
3. Change the settings in `generator.toml` and regenerate

## References

- `SparseIR.jl/utils/generate_C_API.jl` - Reference implementation
- [Clang.jl Documentation](https://github.com/JuliaInterop/Clang.jl)
