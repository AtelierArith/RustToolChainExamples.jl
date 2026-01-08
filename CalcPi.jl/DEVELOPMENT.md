# CalcPi.jl Development Guide

This document explains how to develop `CalcPi.jl`.

## Directory Structure

```
CalcPi.jl/
├── deps/
│   ├── build.jl          # Build script executed by Pkg.build()
│   ├── Project.toml      # Dependencies for the build script
│   ├── README.md         # Description of deps/
│   └── libcalcpi_rs.*    # Built library (auto-generated)
├── utils/
│   ├── generate_C_API.jl # C-API binding generation script
│   ├── generator.toml    # Clang.jl configuration
│   ├── prologue.jl       # Prologue for generated code
│   └── Project.toml      # Clang.jl dependencies
└── src/
    ├── C_API.jl          # Auto-generated C-API bindings
    └── CalcPi.jl         # High-level API wrapper
```

## Development Workflow

### 1. Modifying Rust Code

When you modify the Rust code in `calcpi-rs`:

```bash
cd CalcPi.jl/deps/calcpi-rs
# Edit Rust code
```

### 2. Rebuilding the Julia Package

```bash
cd CalcPi.jl
julia --project=. deps/build.jl
```

Alternatively, use `Pkg.build()`:

```julia
using Pkg
Pkg.build("CalcPi")
```

This will:
- Build the Rust library (`cargo build --release`)
- Copy `deps/libcalcpi_rs.dylib` (or `.so`/`.dll`)
- Regenerate `src/C_API.jl`

### 3. Testing

```julia
using CalcPi
calc = CalcPi.MonteCarloPi()
result = CalcPi.calculate(calc, UInt64(1000000))
println("π ≈ $result")
CalcPi.release(calc)
```

## Library Loading Priority

The `prologue.jl` (included in `C_API.jl`) searches for the library in the following order:

1. **`deps/libcalcpi_rs.*`** (highest priority)
   - Local build copied by `Pkg.build()`
   - Used during development

2. **`deps/calcpi-rs/target/release/libcalcpi_rs.*`**
   - Directly built library
   - Fallback when not in `deps/`

3. **System library**
   - `Libdl.find_library(["libcalcpi_rs"])`
   - Searched from system paths

## Troubleshooting

### Error: CEnum not found

If the generated `C_API.jl` contains `using CEnum`, it will be removed by post-processing in `build.jl`. To remove it manually:

```julia
# Remove the following line from src/C_API.jl
using CEnum: CEnum, @cenum
```

### Error: libcalcpi_rs not found

If the library is not found:

```bash
# 1. Build the Rust library
cd CalcPi.jl/deps/calcpi-rs
cargo build --release

# 2. Rebuild the Julia package
cd ../..
julia --project=. deps/build.jl
```

### Clean Build

To rebuild from a completely clean state:

```bash
# 1. Clear deps/
rm -rf CalcPi.jl/deps/libcalcpi_rs.*

# 2. Clean build the Rust project
cd CalcPi.jl/deps/calcpi-rs
cargo clean
cargo build --release

# 3. Rebuild the Julia package
cd ../..
julia --project=. deps/build.jl
```

## Auto-generation Mechanism

### C-API Binding Generation

`utils/generate_C_API.jl` automatically generates Julia bindings from `calcpi.h`:

1. Parse C header with Clang.jl
2. Generate Julia code
3. Insert `prologue.jl` at the beginning
4. Output to `src/C_API.jl`

### Build Script

`deps/build.jl` performs the following:

1. Detect `deps/calcpi-rs` directory
2. Build Rust library
3. Copy library to `deps/`
4. Generate C-API bindings
5. Post-processing (e.g., remove `CEnum`)

## References

- `SparseIR.jl/deps/` - Reference implementation
- `SparseIR.jl/utils/` - Reference implementation for C-API generation
