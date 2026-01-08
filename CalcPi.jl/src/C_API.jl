module C_API

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
    # On Windows, Rust produces calcpi_rs.dll (no lib prefix)
    # On Unix, Rust produces libcalcpi_rs.so or libcalcpi_rs.dylib (with lib prefix)
    calcpi_rs_dir = joinpath(dirname(@__DIR__), "..", "calcpi-rs")
    possible_paths = [
        joinpath(calcpi_rs_dir, "target", "release", "libcalcpi_rs.$(Libdl.dlext)"),
        joinpath(calcpi_rs_dir, "target", "release", "calcpi_rs.$(Libdl.dlext)"),
        joinpath(calcpi_rs_dir, "target", "debug", "libcalcpi_rs.$(Libdl.dlext)"),
        joinpath(calcpi_rs_dir, "target", "debug", "calcpi_rs.$(Libdl.dlext)"),
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


"""
    calcpi_monte_carlo_pi

Opaque pointer type for C API

This wraps MonteCarloPi and hides its internal structure from C code.
"""
struct calcpi_monte_carlo_pi
    _private::Ptr{Cvoid}
end

"""
    calcpi_monte_carlo_pi_new(status)

Create a new MonteCarloPi instance

# Arguments * `status` - Pointer to store the status code

# Returns * Pointer to the newly created calculator, or NULL if creation fails

# Safety The caller must ensure `status` is a valid pointer.
"""
function calcpi_monte_carlo_pi_new(status)
    ccall((:calcpi_monte_carlo_pi_new, libcalcpi_rs), Ptr{calcpi_monte_carlo_pi}, (Ptr{Int32},), status)
end

"""
    calcpi_monte_carlo_pi_calculate(calc, samples, result, status)

Calculate Pi using Monte Carlo method

# Arguments * `calc` - Calculator instance * `samples` - Number of samples to generate * `result` - Pointer to store the Pi estimate * `status` - Pointer to store the status code

# Returns * Status code (0 on success)

# Safety The caller must ensure all pointers are valid.
"""
function calcpi_monte_carlo_pi_calculate(calc, samples, result, status)
    ccall((:calcpi_monte_carlo_pi_calculate, libcalcpi_rs), Int32, (Ptr{calcpi_monte_carlo_pi}, UInt64, Ptr{Cdouble}, Ptr{Int32}), calc, samples, result, status)
end

"""
    calcpi_monte_carlo_pi_estimate(calc, result, status)

Get the current Pi estimate

# Arguments * `calc` - Calculator instance * `result` - Pointer to store the Pi estimate * `status` - Pointer to store the status code

# Returns * Status code (0 on success)

# Safety The caller must ensure all pointers are valid.
"""
function calcpi_monte_carlo_pi_estimate(calc, result, status)
    ccall((:calcpi_monte_carlo_pi_estimate, libcalcpi_rs), Int32, (Ptr{calcpi_monte_carlo_pi}, Ptr{Cdouble}, Ptr{Int32}), calc, result, status)
end

"""
    calcpi_monte_carlo_pi_total_samples(calc, result, status)

Get the total number of samples

# Arguments * `calc` - Calculator instance * `result` - Pointer to store the total samples count * `status` - Pointer to store the status code

# Returns * Status code (0 on success)

# Safety The caller must ensure all pointers are valid.
"""
function calcpi_monte_carlo_pi_total_samples(calc, result, status)
    ccall((:calcpi_monte_carlo_pi_total_samples, libcalcpi_rs), Int32, (Ptr{calcpi_monte_carlo_pi}, Ptr{UInt64}, Ptr{Int32}), calc, result, status)
end

"""
    calcpi_monte_carlo_pi_inside_circle(calc, result, status)

Get the number of points inside the circle

# Arguments * `calc` - Calculator instance * `result` - Pointer to store the inside circle count * `status` - Pointer to store the status code

# Returns * Status code (0 on success)

# Safety The caller must ensure all pointers are valid.
"""
function calcpi_monte_carlo_pi_inside_circle(calc, result, status)
    ccall((:calcpi_monte_carlo_pi_inside_circle, libcalcpi_rs), Int32, (Ptr{calcpi_monte_carlo_pi}, Ptr{UInt64}, Ptr{Int32}), calc, result, status)
end

"""
    calcpi_monte_carlo_pi_reset(calc, status)

Reset all statistics

# Arguments * `calc` - Calculator instance * `status` - Pointer to store the status code

# Returns * Status code (0 on success)

# Safety The caller must ensure all pointers are valid.
"""
function calcpi_monte_carlo_pi_reset(calc, status)
    ccall((:calcpi_monte_carlo_pi_reset, libcalcpi_rs), Int32, (Ptr{calcpi_monte_carlo_pi}, Ptr{Int32}), calc, status)
end

"""
    calcpi_monte_carlo_pi_release(calc)

Release the calculator instance

# Arguments * `calc` - Calculator instance to release

# Safety The caller must ensure `calc` is a valid pointer returned from [`calcpi_monte_carlo_pi_new`](@ref) and has not been released already.
"""
function calcpi_monte_carlo_pi_release(calc)
    ccall((:calcpi_monte_carlo_pi_release, libcalcpi_rs), Cvoid, (Ptr{calcpi_monte_carlo_pi},), calc)
end

const CALCPI_SUCCESS = 0

const CALCPI_INVALID_ARGUMENT = -1

const CALCPI_INTERNAL_ERROR = -2

# exports
const PREFIXES = ["calcpi_", "CALCPI_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
