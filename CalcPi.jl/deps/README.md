# deps

The `build.jl` script provides developer-focused support for building the Rust backend required by `CalcPi.jl`. It assumes that the Rust crate `calcpi-rs` is located in the same parent directory as the `CalcPi.jl` package.

After making changes to the Rust code, it is assumed that you will rebuild the Julia package as follows:

```
$ cd path/to/CalcPi.jl
$ ls
src/ utils/ deps/ ...
$ julia -e 'using Pkg; Pkg.build()'
```

This process will update `src/C_API.jl` and copy the `libcalcpi_rs.dylib` (or the appropriate shared library) to the `deps/` directory. During runtime, the dynamic library `deps/libcalcpi_rs.[dylib|so|dll]` will be linked if it exists.

## How it works

1. **Detects local Rust crate**: Checks if `../calcpi-rs` directory exists
2. **Builds Rust library**: Uses `RustToolChain.jl` to run `cargo build --release` in the Rust crate directory
3. **Copies library**: Copies the built library to `deps/libcalcpi_rs.<ext>`
4. **Generates C-API bindings**: Runs `utils/generate_C_API.jl` to regenerate `src/C_API.jl`

## Dependencies

The build script requires `RustToolChain.jl` which is automatically installed when you run `Pkg.build()`. This ensures that the correct Rust toolchain is used for building, even if `cargo` is not in the system PATH.

## Library Loading Priority

The `prologue.jl` script (used in generated `C_API.jl`) checks for libraries in this order:

1. `deps/libcalcpi_rs.<ext>` (local build - highest priority)
2. System library path (if available)
3. Error if not found

This allows you to use a locally built version during development while falling back to system libraries in production.
