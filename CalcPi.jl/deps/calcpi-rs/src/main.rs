use calcpi_rs::MonteCarloPi;

fn main() {
    let mut calculator = MonteCarloPi::new();

    // Calculate with 1,000,000 samples
    let samples = 1_000_000;
    let pi_estimate = calculator.calculate(samples);

    println!("Calculation of Pi using Monte Carlo method");
    println!("Number of trials: {}", calculator.total_samples());
    println!("Points inside circle: {}", calculator.inside_circle());
    println!("Estimated value: {:.10}", pi_estimate);
    println!("Actual π: {:.10}", std::f64::consts::PI);
    println!("Error: {:.10}", (pi_estimate - std::f64::consts::PI).abs());
}
