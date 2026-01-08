# CalcPi.jl

A Julia package for calling a Rust-implemented Monte Carlo π calculation library (`calcpi-rs`) from Julia.

## Overview

`CalcPi.jl` provides Julia bindings to the `calcpi-rs` library. You can calculate the value of π using the Monte Carlo method.

## Installation

```julia
using Pkg
Pkg.develop(path="path/to/CalcPi.jl")
```

## Building

Building the package will automatically compile the Rust library and generate C API bindings:

```julia
using Pkg
Pkg.build("CalcPi")
```

## Usage

```julia
using CalcPi

# Create a MonteCarloPi instance
calc = CalcPi.MonteCarloPi()

# Calculate π with 1 million samples
result = CalcPi.calculate(calc, UInt64(1_000_000))
println("π ≈ $result")

# Release resources
CalcPi.release(calc)
```

## Project Structure

```
CalcPi.jl/
├── deps/
│   ├── build.jl          # Build script
│   └── libcalcpi_rs.*    # Built library (auto-generated)
├── src/
│   ├── CalcPi.jl         # High-level API
│   └── C_API.jl           # C API bindings (auto-generated)
├── test/                  # Test files
└── utils/                 # C API generation utilities
```

## Development

For development guide, see `DEVELOPMENT.md`.

## Testing

```julia
using Pkg
Pkg.test("CalcPi")
```

## Dependencies

- `CEnum.jl` - C enum support
- `RustToolChain.jl` - Rust toolchain management (build-time only)

## License

For license information about this project, please refer to the README in the root directory.
