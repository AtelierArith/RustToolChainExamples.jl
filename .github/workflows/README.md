# GitHub Actions Workflows

This directory contains GitHub Actions workflow files for automated testing of the project.

## Workflow Configuration

### `ci.yml`

Automatically tests the following projects:

1. **cargo_example** - Build and execution tests using RustToolChain.jl with cargo
2. **rustc_example** - Build and execution tests using RustToolChain.jl with rustc
3. **calcpi-rs** - Build and test of Rust library
4. **CalcPi.jl** - Build and test of Julia package
5. **test-integration** - Integration tests for all projects

## Test Matrix

### OS
- Ubuntu Latest
- macOS Latest
- Windows Latest

### Julia Version
- 1.10
- 1.11
- 1.12

## Job Configuration

### test-cargo-example
- Tests `cargo_example`
- Build and execute using RustToolChain.jl with cargo

### test-rustc-example
- Tests `rustc_example`
- Build and execute using RustToolChain.jl with rustc

### test-calcpi-rs
- Build and test `calcpi-rs`
- Validate generated header files

### test-calcpi-jl
- Build and test `CalcPi.jl`
- Depends on `calcpi-rs`
- Run Julia package test suite

### test-integration
- Integration tests for all projects
- End-to-end verification

## Caching

The following caches are configured:

- **Julia packages**: `~/.julia`
- **Cargo registry**: `~/.cargo/` and `target/` directories

## Local Testing

To test workflows locally:

```bash
# cargo_example
cd cargo_example
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. run.jl

# rustc_example
cd rustc_example
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. main.jl

# calcpi-rs
cd calcpi-rs
cargo build --release
cargo test --release

# CalcPi.jl
cd CalcPi.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=deps -e 'using Pkg; Pkg.instantiate()'
julia --project=deps deps/build.jl
julia --project=. -e 'using Pkg; Pkg.test("CalcPi")'
```
