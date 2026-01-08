__precompile__(false)

module CalcPi

include("C_API.jl")
using .C_API

# Re-export C_API symbols
export CALCPI_SUCCESS, CALCPI_INVALID_ARGUMENT, CALCPI_INTERNAL_ERROR
export calcpi_monte_carlo_pi, calcpi_monte_carlo_pi_new, calcpi_monte_carlo_pi_release
export calcpi_monte_carlo_pi_calculate, calcpi_monte_carlo_pi_estimate
export calcpi_monte_carlo_pi_total_samples, calcpi_monte_carlo_pi_inside_circle
export calcpi_monte_carlo_pi_reset

# High-level API wrapper
"""
    MonteCarloPi

High-level API wrapper for a calculator that computes π using the Monte Carlo method.
"""
mutable struct MonteCarloPi
    ptr::Ptr{calcpi_monte_carlo_pi}

    function MonteCarloPi()
        status = Ref{Int32}(0)
        ptr = calcpi_monte_carlo_pi_new(status)

        if ptr == C_NULL || status[] != CALCPI_SUCCESS
            error("Failed to create MonteCarloPi: status = $(status[])")
        end

        instance = new(ptr)
        finalizer(release, instance)
        return instance
    end
end

"""
    release(calc::MonteCarloPi)

Releases the calculator's resources. Usually called automatically, but can be called explicitly.
"""
function release(calc::MonteCarloPi)
    if calc.ptr != C_NULL
        calcpi_monte_carlo_pi_release(calc.ptr)
        calc.ptr = C_NULL
    end
end

"""
    calculate(calc::MonteCarloPi, samples::UInt64) -> Float64

Generates the specified number of samples and estimates π.
"""
function calculate(calc::MonteCarloPi, samples::UInt64)
    if calc.ptr == C_NULL
        error("MonteCarloPi has been released")
    end

    result = Ref{Float64}(0.0)
    status = Ref{Int32}(0)

    ret = calcpi_monte_carlo_pi_calculate(calc.ptr, samples, result, status)

    if ret != CALCPI_SUCCESS || status[] != CALCPI_SUCCESS
        error("Failed to calculate: status = $(status[])")
    end

    return result[]
end

"""
    estimate(calc::MonteCarloPi) -> Float64

Gets the π estimate from the current samples.
"""
function estimate(calc::MonteCarloPi)
    if calc.ptr == C_NULL
        error("MonteCarloPi has been released")
    end

    result = Ref{Float64}(0.0)
    status = Ref{Int32}(0)

    ret = calcpi_monte_carlo_pi_estimate(calc.ptr, result, status)

    if ret != CALCPI_SUCCESS || status[] != CALCPI_SUCCESS
        error("Failed to estimate: status = $(status[])")
    end

    return result[]
end

"""
    total_samples(calc::MonteCarloPi) -> UInt64

Gets the total number of samples.
"""
function total_samples(calc::MonteCarloPi)
    if calc.ptr == C_NULL
        error("MonteCarloPi has been released")
    end

    result = Ref{UInt64}(0)
    status = Ref{Int32}(0)

    ret = calcpi_monte_carlo_pi_total_samples(calc.ptr, result, status)

    if ret != CALCPI_SUCCESS || status[] != CALCPI_SUCCESS
        error("Failed to get total_samples: status = $(status[])")
    end

    return result[]
end

"""
    inside_circle(calc::MonteCarloPi) -> UInt64

Gets the number of points inside the circle.
"""
function inside_circle(calc::MonteCarloPi)
    if calc.ptr == C_NULL
        error("MonteCarloPi has been released")
    end

    result = Ref{UInt64}(0)
    status = Ref{Int32}(0)

    ret = calcpi_monte_carlo_pi_inside_circle(calc.ptr, result, status)

    if ret != CALCPI_SUCCESS || status[] != CALCPI_SUCCESS
        error("Failed to get inside_circle: status = $(status[])")
    end

    return result[]
end

"""
    reset(calc::MonteCarloPi)

Resets the statistics.
"""
function reset(calc::MonteCarloPi)
    if calc.ptr == C_NULL
        error("MonteCarloPi has been released")
    end

    status = Ref{Int32}(0)

    ret = calcpi_monte_carlo_pi_reset(calc.ptr, status)

    if ret != CALCPI_SUCCESS || status[] != CALCPI_SUCCESS
        error("Failed to reset: status = $(status[])")
    end
end

"""
    calc_pi(samples::UInt64) -> Float64

Simple π calculation function. Internally creates, uses, and releases a MonteCarloPi instance.
"""
function calc_pi(samples::UInt64)
    calc = MonteCarloPi()
    try
        return calculate(calc, samples)
    finally
        release(calc)
    end
end

# Export high-level API
export MonteCarloPi, calculate, estimate, total_samples, inside_circle, reset, calc_pi, release

end # module CalcPi
