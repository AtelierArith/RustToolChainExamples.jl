# cargo_example

An example of building and running a Rust project using Cargo from Julia.

## Overview

This sample demonstrates how to build and run a Cargo-managed Rust project from Julia.

## Project Structure

```
cargo_example/
├── Cargo.toml    # Rust project configuration
├── Project.toml  # Julia project configuration
├── run.jl        # Execution script
└── src/
    └── main.rs   # Rust main code
```

## Usage

### Running

```bash
julia run.jl
```

Or from the Julia REPL:

```julia
include("run.jl")
```

## How It Works

1. Uses the `cargo()` function from `RustToolChain.jl` to get the Cargo command
2. Builds the Rust project with `cargo build --release`
3. Executes the built binary

## Dependencies

- `RustToolChain.jl` - Rust toolchain management

## Related Projects

- `rustc_example/` - Example using rustc directly
- `calcpi-rs/` - Example of a more complex library project
