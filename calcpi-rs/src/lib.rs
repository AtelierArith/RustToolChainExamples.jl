use rand::Rng;

pub mod c_api;

pub use c_api::*;

/// Struct for calculating the value of Pi using the Monte Carlo method
pub struct MonteCarloPi {
    /// Number of trials performed
    total_samples: u64,
    /// Number of points that fell inside the unit circle
    inside_circle: u64,
    /// Random number generator
    rng: rand::rngs::ThreadRng,
}

impl MonteCarloPi {
    /// Creates a new MonteCarloPi instance
    pub fn new() -> Self {
        Self {
            total_samples: 0,
            inside_circle: 0,
            rng: rand::thread_rng(),
        }
    }

    /// Generates the specified number of samples and estimates Pi
    ///
    /// # Arguments
    /// * `samples` - Number of samples to generate
    pub fn calculate(&mut self, samples: u64) -> f64 {
        for _ in 0..samples {
            // Generate a random point (x, y) within the range [0, 1)
            let x: f64 = self.rng.gen_range(0.0..1.0);
            let y: f64 = self.rng.gen_range(0.0..1.0);

            // Check if the point lies within the unit circle
            let distance_squared = x * x + y * y;
            if distance_squared <= 1.0 {
                self.inside_circle += 1;
            }
            self.total_samples += 1;
        }

        self.estimate()
    }

    /// Estimates the value of Pi from the current samples
    pub fn estimate(&self) -> f64 {
        if self.total_samples == 0 {
            return 0.0;
        }
        // Pi ≈ 4 × (points inside circle) / (total points)
        4.0 * (self.inside_circle as f64) / (self.total_samples as f64)
    }

    /// Returns the total number of samples taken
    pub fn total_samples(&self) -> u64 {
        self.total_samples
    }

    /// Returns the number of points inside the circle
    pub fn inside_circle(&self) -> u64 {
        self.inside_circle
    }

    /// Resets all statistics
    pub fn reset(&mut self) {
        self.total_samples = 0;
        self.inside_circle = 0;
    }
}

impl Default for MonteCarloPi {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_instance() {
        let calculator = MonteCarloPi::new();
        assert_eq!(calculator.total_samples(), 0);
        assert_eq!(calculator.inside_circle(), 0);
        assert_eq!(calculator.estimate(), 0.0);
    }

    #[test]
    fn test_default() {
        let calculator = MonteCarloPi::default();
        assert_eq!(calculator.total_samples(), 0);
        assert_eq!(calculator.inside_circle(), 0);
    }

    #[test]
    fn test_estimate_with_zero_samples() {
        let calculator = MonteCarloPi::new();
        assert_eq!(calculator.estimate(), 0.0);
    }

    #[test]
    fn test_reset() {
        let mut calculator = MonteCarloPi::new();
        calculator.calculate(1000);
        assert!(calculator.total_samples() > 0);

        calculator.reset();
        assert_eq!(calculator.total_samples(), 0);
        assert_eq!(calculator.inside_circle(), 0);
        assert_eq!(calculator.estimate(), 0.0);
    }

    #[test]
    fn test_calculate_updates_counters() {
        let mut calculator = MonteCarloPi::new();
        let samples = 1000;
        calculator.calculate(samples);

        assert_eq!(calculator.total_samples(), samples);
        assert!(calculator.inside_circle() > 0);
        assert!(calculator.inside_circle() <= samples);
    }

    #[test]
    fn test_pi_estimate_in_reasonable_range() {
        let mut calculator = MonteCarloPi::new();
        // Use enough samples for an approximate result (Monte Carlo is not exact)
        let pi_estimate = calculator.calculate(100_000);

        // Pi is about 3.14, so the estimate should be between 2.5 and 3.5
        assert!(pi_estimate >= 2.5);
        assert!(pi_estimate <= 3.5);
    }

    #[test]
    fn test_accumulative_calculation() {
        let mut calculator = MonteCarloPi::new();

        calculator.calculate(1000);
        let first_total = calculator.total_samples();

        let second_estimate = calculator.calculate(1000);
        let second_total = calculator.total_samples();

        // Confirm that calculation is cumulative
        assert_eq!(second_total, first_total + 1000);
        // The estimate after the second call is based on the accumulated samples
        assert!(second_estimate > 0.0);
    }

    #[test]
    fn test_inside_circle_ratio() {
        let mut calculator = MonteCarloPi::new();
        calculator.calculate(10_000);

        let ratio = calculator.inside_circle() as f64 / calculator.total_samples() as f64;
        // Theoretical ratio is ~π/4 ≈ 0.785, so it should be between 0.7 and 0.85
        assert!(ratio >= 0.7);
        assert!(ratio <= 0.85);
    }

    #[test]
    fn test_large_sample_count() {
        let mut calculator = MonteCarloPi::new();
        let samples = 1_000_000;
        let pi_estimate = calculator.calculate(samples);

        // With a large number of samples, the result should be more accurate
        let error = (pi_estimate - std::f64::consts::PI).abs();
        // With 1 million samples, error should be less than 0.01
        assert!(error < 0.01, "Error is too large: {}", error);
    }
}
