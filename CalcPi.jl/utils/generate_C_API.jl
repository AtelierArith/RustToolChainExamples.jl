using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Clang.Generators
using Clang.LibClang.Clang_jll

# Function to print help message
function print_help()
    println("Usage: julia generate_C_API.jl [OPTIONS]")
    println()
    println("Options:")
    println("  --calcpi-rs-dir PATH    Specify the calcpi-rs directory path")
    println("  --help, -h              Show this help message")
    println()
    println("Examples:")
    println("  julia generate_C_API.jl --calcpi-rs-dir /path/to/calcpi-rs")
    println()
    println("Default: Uses ../../calcpi-rs relative to this script")
end

# Parse command line arguments
calcpi_rs_dir = nothing
for (i, arg) in enumerate(ARGS)
    if arg == "--help" || arg == "-h"
        print_help()
        exit(0)
    elseif arg == "--calcpi-rs-dir"
        if i + 1 <= length(ARGS)
            global calcpi_rs_dir
            calcpi_rs_dir = ARGS[i + 1]
        else
            println("Error: --calcpi-rs-dir requires a path argument")
            exit(1)
        end
    end
end

# Get calcpi-rs directory from command line or use default
if calcpi_rs_dir === nothing
    # Default path
    calcpi_rs_dir = normpath(joinpath(@__DIR__, "../../calcpi-rs"))
else
    # Convert to absolute path
    calcpi_rs_dir = normpath(abspath(calcpi_rs_dir))
end

# Check if the directory exists
if !isdir(calcpi_rs_dir)
    println("Error: calcpi-rs directory not found: $calcpi_rs_dir")
    println("Please specify the correct path using --calcpi-rs-dir")
    exit(1)
end

include_dir = joinpath(calcpi_rs_dir, "include")

# Check if include directory exists
if !isdir(include_dir)
    println("Error: include directory not found: $include_dir")
    println("Please ensure the calcpi-rs directory contains an 'include' subdirectory")
    println("Build the Rust library first with: cd calcpi-rs && cargo build --release")
    exit(1)
end

println("Using calcpi-rs directory: $calcpi_rs_dir")
println("Using include directory: $include_dir")

# wrapper generator options
generator_toml = joinpath(@__DIR__, "generator.toml")
if isfile(generator_toml)
    options = load_options(generator_toml)
else
    println("Warning: generator.toml not found, using default options")
    options = Dict{String,Any}()
end

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

# Find header files
header_file = joinpath(include_dir, "calcpi.h")
if !isfile(header_file)
    println("Error: calcpi.h not found: $header_file")
    println("Please build the Rust library first with: cd calcpi-rs && cargo build --release")
    exit(1)
end

headers = [header_file]

println("Found header file: $header_file")

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)

println("Successfully generated C_API.jl")
