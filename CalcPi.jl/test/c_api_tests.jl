@testset "C-API Tests" begin
    using CalcPi.C_API

    @testset "Constants" begin
        @test CALCPI_SUCCESS == 0
        @test CALCPI_INVALID_ARGUMENT == -1
        @test CALCPI_INTERNAL_ERROR == -2
    end

    @testset "Direct C-API Calls" begin
        @testset "calcpi_monte_carlo_pi_new" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            @test ptr != C_NULL
            @test status[] == CALCPI_SUCCESS

            if ptr != C_NULL
                calcpi_monte_carlo_pi_release(ptr)
            end
        end

        @testset "calcpi_monte_carlo_pi_calculate" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            if ptr != C_NULL
                try
                    result = Ref{Float64}(0.0)
                    status_out = Ref{Int32}(0)

                    ret = calcpi_monte_carlo_pi_calculate(ptr, UInt64(10000), result, status_out)

                    @test ret == CALCPI_SUCCESS
                    @test status_out[] == CALCPI_SUCCESS
                    @test result[] isa Float64
                    @test 2.0 < result[] < 4.0
                finally
                    calcpi_monte_carlo_pi_release(ptr)
                end
            end
        end

        @testset "calcpi_monte_carlo_pi_estimate" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            if ptr != C_NULL
                try
                    # First calculate some samples
                    result_calc = Ref{Float64}(0.0)
                    status_calc = Ref{Int32}(0)
                    calcpi_monte_carlo_pi_calculate(ptr, UInt64(10000), result_calc, status_calc)

                    # Then get estimate
                    result_est = Ref{Float64}(0.0)
                    status_est = Ref{Int32}(0)
                    ret = calcpi_monte_carlo_pi_estimate(ptr, result_est, status_est)

                    @test ret == CALCPI_SUCCESS
                    @test status_est[] == CALCPI_SUCCESS
                    @test result_est[] isa Float64
                    @test 2.0 < result_est[] < 4.0
                finally
                    calcpi_monte_carlo_pi_release(ptr)
                end
            end
        end

        @testset "calcpi_monte_carlo_pi_total_samples" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            if ptr != C_NULL
                try
                    # Initially should be 0
                    result = Ref{UInt64}(0)
                    status_out = Ref{Int32}(0)
                    ret = calcpi_monte_carlo_pi_total_samples(ptr, result, status_out)

                    @test ret == CALCPI_SUCCESS
                    @test status_out[] == CALCPI_SUCCESS
                    @test result[] == 0

                    # After calculation
                    result_calc = Ref{Float64}(0.0)
                    status_calc = Ref{Int32}(0)
                    calcpi_monte_carlo_pi_calculate(ptr, UInt64(5000), result_calc, status_calc)

                    ret = calcpi_monte_carlo_pi_total_samples(ptr, result, status_out)
                    @test ret == CALCPI_SUCCESS
                    @test result[] == 5000
                finally
                    calcpi_monte_carlo_pi_release(ptr)
                end
            end
        end

        @testset "calcpi_monte_carlo_pi_inside_circle" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            if ptr != C_NULL
                try
                    # Initially should be 0
                    result = Ref{UInt64}(0)
                    status_out = Ref{Int32}(0)
                    ret = calcpi_monte_carlo_pi_inside_circle(ptr, result, status_out)

                    @test ret == CALCPI_SUCCESS
                    @test status_out[] == CALCPI_SUCCESS
                    @test result[] == 0

                    # After calculation
                    result_calc = Ref{Float64}(0.0)
                    status_calc = Ref{Int32}(0)
                    calcpi_monte_carlo_pi_calculate(ptr, UInt64(10000), result_calc, status_calc)

                    ret = calcpi_monte_carlo_pi_inside_circle(ptr, result, status_out)
                    @test ret == CALCPI_SUCCESS
                    @test result[] > 0
                    @test result[] <= 10000
                finally
                    calcpi_monte_carlo_pi_release(ptr)
                end
            end
        end

        @testset "calcpi_monte_carlo_pi_reset" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            if ptr != C_NULL
                try
                    # Calculate some samples
                    result_calc = Ref{Float64}(0.0)
                    status_calc = Ref{Int32}(0)
                    calcpi_monte_carlo_pi_calculate(ptr, UInt64(10000), result_calc, status_calc)

                    # Verify samples exist
                    result_samples = Ref{UInt64}(0)
                    status_samples = Ref{Int32}(0)
                    calcpi_monte_carlo_pi_total_samples(ptr, result_samples, status_samples)
                    @test result_samples[] == 10000

                    # Reset
                    status_reset = Ref{Int32}(0)
                    ret = calcpi_monte_carlo_pi_reset(ptr, status_reset)

                    @test ret == CALCPI_SUCCESS
                    @test status_reset[] == CALCPI_SUCCESS

                    # Verify reset
                    calcpi_monte_carlo_pi_total_samples(ptr, result_samples, status_samples)
                    @test result_samples[] == 0
                finally
                    calcpi_monte_carlo_pi_release(ptr)
                end
            end
        end

        @testset "calcpi_monte_carlo_pi_release" begin
            status = Ref{Int32}(0)
            ptr = calcpi_monte_carlo_pi_new(status)

            @test ptr != C_NULL

            # Release should not throw
            calcpi_monte_carlo_pi_release(ptr)
        end
    end
end
