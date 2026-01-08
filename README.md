# RustToolChainExamples.jl

This repository is a collection of sample projects demonstrating how to call Rust code from Julia.

## Project Structure

### Main Projects

- **`calcpi-rs/`** - Rust library implementing π calculation using the Monte Carlo method
- **`CalcPi.jl/`** - Julia package for calling `calcpi-rs` from Julia

### Sample Projects

- **`cargo_example/`** - Example of a Rust project using Cargo
- **`rustc_example/`** - Example of a Rust project using rustc directly

## Setup

### Prerequisites

- Julia 1.10 or later
- Rust toolchain (rustc, cargo)
- [RustToolChain.jl](https://github.com/AtelierArith/RustToolChain.jl) package

### Installation

```julia
using Pkg
Pkg.add("RustToolChain")
```

## Usage

Please refer to the README of each sample project.

## License

For license information about this project, please refer to the README in each subdirectory.
