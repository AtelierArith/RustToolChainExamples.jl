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
    println("  --output-dir PATH       Specify the output directory for C_API.jl")
    println("  --help, -h              Show this help message")
    println()
    println("Examples:")
    println("  julia generate_C_API.jl --calcpi-rs-dir /path/to/calcpi-rs")
    println("  julia generate_C_API.jl --output-dir /path/to/output")
    println()
    println("Default: Uses ../deps/calcpi-rs relative to this script")
    println("         Output goes to ../src/C_API.jl relative to this script")
end

function parse_args(args)
    calcpi_rs_dir = nothing
    output_dir = nothing
    i = 1
    while i <= length(args)
        arg = args[i]
        if arg == "--help" || arg == "-h"
            print_help()
            exit(0)
        elseif arg == "--calcpi-rs-dir"
            if i + 1 <= length(args)
                calcpi_rs_dir = args[i + 1]
                i += 2
            else
                println("Error: --calcpi-rs-dir requires a path argument")
                exit(1)
            end
        elseif arg == "--output-dir"
            if i + 1 <= length(args)
                output_dir = args[i + 1]
                i += 2
            else
                println("Error: --output-dir requires a path argument")
                exit(1)
            end
        else
            i += 1
        end
    end
    return calcpi_rs_dir, output_dir
end

function main()
    calcpi_rs_dir, output_dir = parse_args(ARGS)

    # Get calcpi-rs directory from command line or use default
    if calcpi_rs_dir === nothing
        # Default path (calcpi-rs is now in CalcPi.jl/deps/calcpi-rs)
        calcpi_rs_dir = normpath(joinpath(@__DIR__, "../deps/calcpi-rs"))
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

    # Override output path if specified
    if output_dir !== nothing
        output_dir = normpath(abspath(output_dir))
        if !isdir(output_dir)
            mkpath(output_dir)
        end
        if !haskey(options, "general")
            options["general"] = Dict{String,Any}()
        end
        options["general"]["output_file_path"] = joinpath(output_dir, "C_API.jl")
        println("Output directory: $output_dir")
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
end

main()
