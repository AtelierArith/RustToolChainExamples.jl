@testset "Basic MonteCarloPi Tests" begin
    @testset "Creation and Release" begin
        calc = CalcPi.MonteCarloPi()
        @test calc isa CalcPi.MonteCarloPi
        @test CalcPi.total_samples(calc) == 0
        @test CalcPi.inside_circle(calc) == 0
        CalcPi.release(calc)
    end

    @testset "Calculate" begin
        calc = CalcPi.MonteCarloPi()
        try
            samples = UInt64(10000)
            result = CalcPi.calculate(calc, samples)

            @test result isa Float64
            @test 2.0 < result < 4.0  # Pi should be between 2 and 4
            @test CalcPi.total_samples(calc) == samples
            @test CalcPi.inside_circle(calc) > 0
            @test CalcPi.inside_circle(calc) <= samples
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Estimate" begin
        calc = CalcPi.MonteCarloPi()
        try
            # Initially, estimate should be 0 or NaN (no samples)
            # After calculation, should return a valid estimate
            CalcPi.calculate(calc, UInt64(1000))
            estimate = CalcPi.estimate(calc)

            @test estimate isa Float64
            @test 2.0 < estimate < 4.0
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Total Samples" begin
        calc = CalcPi.MonteCarloPi()
        try
            @test CalcPi.total_samples(calc) == 0

            CalcPi.calculate(calc, UInt64(5000))
            @test CalcPi.total_samples(calc) == 5000

            CalcPi.calculate(calc, UInt64(3000))
            @test CalcPi.total_samples(calc) == 8000
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Inside Circle" begin
        calc = CalcPi.MonteCarloPi()
        try
            @test CalcPi.inside_circle(calc) == 0

            CalcPi.calculate(calc, UInt64(10000))
            inside = CalcPi.inside_circle(calc)

            @test inside > 0
            @test inside <= CalcPi.total_samples(calc)
            # Approximately π/4 of points should be inside
            ratio = inside / CalcPi.total_samples(calc)
            @test 0.6 < ratio < 0.9  # Allow some variance
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Reset" begin
        calc = CalcPi.MonteCarloPi()
        try
            CalcPi.calculate(calc, UInt64(10000))
            @test CalcPi.total_samples(calc) > 0
            @test CalcPi.inside_circle(calc) > 0

            CalcPi.reset(calc)

            @test CalcPi.total_samples(calc) == 0
            @test CalcPi.inside_circle(calc) == 0
        finally
            CalcPi.release(calc)
        end
    end

    @testset "calc_pi Helper Function" begin
        result = CalcPi.calc_pi(UInt64(10000))

        @test result isa Float64
        @test 2.0 < result < 4.0

        # Multiple calls should give different results (random)
        result2 = CalcPi.calc_pi(UInt64(10000))
        # Results should be close but not necessarily identical
        @test abs(result - result2) < 1.0
    end

    @testset "Convergence" begin
        calc = CalcPi.MonteCarloPi()
        try
            # More samples should give better estimate
            CalcPi.calculate(calc, UInt64(1000))
            estimate1 = CalcPi.estimate(calc)

            CalcPi.calculate(calc, UInt64(100000))
            estimate2 = CalcPi.estimate(calc)

            # Both should be reasonable
            @test 2.5 < estimate1 < 3.5
            @test 2.5 < estimate2 < 3.5

            # estimate2 should be closer to π (3.14159...)
            error1 = abs(estimate1 - π)
            error2 = abs(estimate2 - π)
            @test error2 < error1 || error2 < 0.1  # Allow some variance
        finally
            CalcPi.release(calc)
        end
    end
end
