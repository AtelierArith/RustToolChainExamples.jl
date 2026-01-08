@testset "Integration Tests" begin
    @testset "Multiple Instances" begin
        calc1 = CalcPi.MonteCarloPi()
        calc2 = CalcPi.MonteCarloPi()

        try
            CalcPi.calculate(calc1, UInt64(10000))
            CalcPi.calculate(calc2, UInt64(5000))

            @test CalcPi.total_samples(calc1) == 10000
            @test CalcPi.total_samples(calc2) == 5000

            # Both should give reasonable estimates
            est1 = CalcPi.estimate(calc1)
            est2 = CalcPi.estimate(calc2)

            @test 2.0 < est1 < 4.0
            @test 2.0 < est2 < 4.0
        finally
            CalcPi.release(calc1)
            CalcPi.release(calc2)
        end
    end

    @testset "Accumulative Calculation" begin
        calc = CalcPi.MonteCarloPi()
        try
            # Calculate in multiple steps
            CalcPi.calculate(calc, UInt64(10000))
            samples1 = CalcPi.total_samples(calc)
            est1 = CalcPi.estimate(calc)

            CalcPi.calculate(calc, UInt64(20000))
            samples2 = CalcPi.total_samples(calc)
            est2 = CalcPi.estimate(calc)

            @test samples2 == 30000
            @test samples1 == 10000

            # Estimates should be reasonable
            @test 2.0 < est1 < 4.0
            @test 2.0 < est2 < 4.0
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Reset and Recalculate" begin
        calc = CalcPi.MonteCarloPi()
        try
            CalcPi.calculate(calc, UInt64(10000))
            est1 = CalcPi.estimate(calc)

            CalcPi.reset(calc)
            @test CalcPi.total_samples(calc) == 0

            CalcPi.calculate(calc, UInt64(10000))
            est2 = CalcPi.estimate(calc)

            # Both estimates should be reasonable
            @test 2.0 < est1 < 4.0
            @test 2.0 < est2 < 4.0
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Large Sample Count" begin
        calc = CalcPi.MonteCarloPi()
        try
            # Test with large number of samples
            CalcPi.calculate(calc, UInt64(1000000))

            est = CalcPi.estimate(calc)
            samples = CalcPi.total_samples(calc)
            inside = CalcPi.inside_circle(calc)

            @test samples == 1000000
            @test inside > 0
            @test inside <= samples

            # With many samples, estimate should be close to π
            @test abs(est - π) < 0.1
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Pi Estimation Accuracy" begin
        calc = CalcPi.MonteCarloPi()
        try
            # Use many samples for better accuracy
            CalcPi.calculate(calc, UInt64(1000000))
            est = CalcPi.estimate(calc)

            # Should be within reasonable range of π
            @test abs(est - π) < 0.1

            # Ratio of inside/total should be approximately π/4
            ratio = CalcPi.inside_circle(calc) / CalcPi.total_samples(calc)
            expected_ratio = π / 4
            @test abs(ratio - expected_ratio) < 0.05
        finally
            CalcPi.release(calc)
        end
    end

    @testset "Memory Management" begin
        # Create and release multiple instances
        for i in 1:10
            calc = CalcPi.MonteCarloPi()
            CalcPi.calculate(calc, UInt64(1000))
            CalcPi.release(calc)
        end

        # Should not crash
        @test true
    end

    @testset "Finalizer Test" begin
        # Test that finalizer works correctly
        function create_and_drop()
            calc = CalcPi.MonteCarloPi()
            CalcPi.calculate(calc, UInt64(1000))
            return nothing  # calc goes out of scope, finalizer should be called
        end

        create_and_drop()
        # Force garbage collection
        GC.gc()

        # Should not crash
        @test true
    end
end
