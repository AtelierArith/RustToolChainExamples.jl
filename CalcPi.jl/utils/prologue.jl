using Libdl: Libdl

function get_libcalcpi_rs()
    # First, try to find library in deps/ directory (highest priority)
    # This is where Pkg.build() copies the locally built library
    deps_dir = joinpath(dirname(@__DIR__), "deps")
    local_libcalcpi_path = joinpath(deps_dir, "libcalcpi_rs.$(Libdl.dlext)")
    if isfile(local_libcalcpi_path)
        @info "Using local libcalcpi_rs: $local_libcalcpi_path"
        return local_libcalcpi_path
    end

    # Second, try to find local build in calcpi-rs/target/release or debug
    calcpi_rs_dir = joinpath(dirname(@__DIR__), "..", "calcpi-rs")
    possible_paths = [
        joinpath(calcpi_rs_dir, "target", "release", "libcalcpi_rs.$(Libdl.dlext)"),
        joinpath(calcpi_rs_dir, "target", "debug", "libcalcpi_rs.$(Libdl.dlext)"),
    ]

    for path in possible_paths
        if isfile(path)
            @info "Using local libcalcpi_rs: $path"
            return path
        end
    end

    # If not found locally, try system library
    try
        libpath = Libdl.find_library(["libcalcpi_rs"])
        if libpath !== ""
            @info "Using system libcalcpi_rs: $libpath"
            return libpath
        end
    catch
    end

    error("Could not find libcalcpi_rs. Please build the Rust library first with: julia -e 'using Pkg; Pkg.build()'")
end

const libcalcpi_rs = get_libcalcpi_rs()
