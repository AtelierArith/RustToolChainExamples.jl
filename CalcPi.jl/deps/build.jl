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
    libcalcpi_path = joinpath(DEV_DIR, "target", "release", "libcalcpi_rs.$(dlext)")
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
