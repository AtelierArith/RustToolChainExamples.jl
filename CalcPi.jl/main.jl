using CalcPi

# Example entry point

function main()
    num_samples = 10_000_000
    println("Estimating π using $num_samples samples…")
    pi_estimate = calc_pi(UInt64(num_samples))
    println("Estimated π value: $pi_estimate")
end

main()