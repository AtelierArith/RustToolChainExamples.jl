# rustc_example

An example of compiling Rust code using rustc directly and running it from Julia.

## Overview

This sample demonstrates how to compile and run Rust code using rustc directly without Cargo. Suitable for simple single-file Rust programs.

## Project Structure

```
rustc_example/
├── main.rs      # Rust source code
├── main.jl      # Julia execution script
└── Project.toml # Julia project configuration
```

## Usage

### Running

```bash
julia main.jl
```

Or from the Julia REPL:

```julia
include("main.jl")
```

## How It Works

1. Uses the `rustc()` function from `RustToolChain.jl` to get the rustc command
2. Compiles the Rust code with `rustc main.rs` (generates an executable named `main`)
3. Executes the compiled binary (`./main`)

## Differences from Cargo

- **rustc**: Suitable for compiling single files. No dependency management.
- **Cargo**: Includes project management, dependency management, and build system.

## Dependencies

- `RustToolChain.jl` - Rust toolchain management

## Related Projects

- `cargo_example/` - Example using Cargo
- `calcpi-rs/` - Example of a more complex library project
