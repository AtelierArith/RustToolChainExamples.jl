using Pkg
using Libdl: dlext
using RustToolChain: cargo

const DEV_DIR::String = joinpath(dirname(dirname(@__DIR__)), "calcpi-rs")

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

    cd(joinpath(dirname(@__DIR__), "utils")) do
        run(`$(Base.julia_cmd()) --project generate_C_API.jl`)
    end

    # Remove CEnum import if not needed (post-processing)
    c_api_path = joinpath(dirname(@__DIR__), "src", "C_API.jl")
    if isfile(c_api_path)
        content = read(c_api_path, String)
        # Remove CEnum import if present
        content = replace(content, r"using CEnum: CEnum, @cenum\n\n" => "")
        write(c_api_path, content)
    end
end
