using Pkg
using Libdl: dlext
using RustToolChain: cargo

const DEV_DIR::String = joinpath(@__DIR__, "calcpi-rs")

# Check if the calcpi-rs directory exists locally; if not, do nothing.
# If it exists, build the Rust project and copy libcalcpi_rs.<ext> to deps/.
if isdir(DEV_DIR)
    cd(DEV_DIR) do
        run(`$(cargo()) build --release`)
    end
    # On Windows, Rust produces calcpi_rs.dll (no lib prefix)
    # On Unix, Rust produces libcalcpi_rs.so or libcalcpi_rs.dylib (with lib prefix)
    release_dir = joinpath(DEV_DIR, "target", "release")
    libcalcpi_path = joinpath(release_dir, "libcalcpi_rs.$(dlext)")
    if !isfile(libcalcpi_path)
        # Try without lib prefix (Windows)
        libcalcpi_path = joinpath(release_dir, "calcpi_rs.$(dlext)")
    end
    if !isfile(libcalcpi_path)
        error("Could not find built library. Expected libcalcpi_rs.$(dlext) or calcpi_rs.$(dlext) in $release_dir")
    end
    # Always copy to libcalcpi_rs.<ext> in deps/ for consistency
    cp(libcalcpi_path, joinpath(@__DIR__, "libcalcpi_rs.$(dlext)"); force=true)

    # Generate C_API.jl in a temporary directory first, then copy to the appropriate location
    # This handles the case where the package is installed and src/ is read-only
    package_dir = dirname(@__DIR__)
    src_dir = joinpath(package_dir, "src")
    temp_output_dir = mktempdir()

    cd(joinpath(package_dir, "utils")) do
        run(`$(Base.julia_cmd()) --project generate_C_API.jl --output-dir $temp_output_dir`)
    end

    # Copy generated file to src/ if writable
    temp_c_api_path = joinpath(temp_output_dir, "C_API.jl")
    if isfile(temp_c_api_path)
        c_api_path = joinpath(src_dir, "C_API.jl")
        # Check if src/ is writable by testing write access
        try
            content = read(temp_c_api_path, String)
            # Remove CEnum import if not needed (post-processing)
            content = replace(content, r"using CEnum: CEnum, @cenum\n\n" => "")
            # Try to write to src/
            open(c_api_path, "w") do f
                write(f, content)
            end
            println("Generated C_API.jl in src/")
        catch e
            # If src/ is read-only (e.g., installed package), skip writing
            # The existing C_API.jl in the package should be used
            println("Warning: Cannot write to src/ (package may be installed). Using existing C_API.jl.")
        end
        rm(temp_output_dir; recursive=true)
    else
        error("Failed to generate C_API.jl")
    end
end
