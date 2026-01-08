//! C API for MonteCarloPi
//!
//! This module provides a C-compatible interface to the MonteCarloPi library,
//! enabling usage from languages like Julia, Python, and C.

use std::panic::catch_unwind;
use crate::MonteCarloPi;

/// Error codes for C API
pub const CALCPI_SUCCESS: i32 = 0;
pub const CALCPI_INVALID_ARGUMENT: i32 = -1;
pub const CALCPI_INTERNAL_ERROR: i32 = -2;

/// Opaque pointer type for C API
///
/// This wraps MonteCarloPi and hides its internal structure from C code.
#[repr(C)]
pub struct calcpi_monte_carlo_pi {
    _private: *const std::ffi::c_void,
}

impl calcpi_monte_carlo_pi {
    /// Create a new calcpi_monte_carlo_pi from MonteCarloPi
    pub(crate) fn new(inner: MonteCarloPi) -> Self {
        Self {
            _private: Box::into_raw(Box::new(inner)) as *const std::ffi::c_void,
        }
    }

    /// Get a reference to the inner MonteCarloPi
    pub(crate) fn inner(&self) -> &MonteCarloPi {
        unsafe { &*(self._private as *const MonteCarloPi) }
    }

    /// Get a mutable reference to the inner MonteCarloPi
    pub(crate) fn inner_mut(&mut self) -> &mut MonteCarloPi {
        unsafe { &mut *(self._private as *mut MonteCarloPi) }
    }
}

impl Drop for calcpi_monte_carlo_pi {
    fn drop(&mut self) {
        unsafe {
            if !self._private.is_null() {
                let _ = Box::from_raw(self._private as *mut MonteCarloPi);
            }
        }
    }
}

/// Create a new MonteCarloPi instance
///
/// # Arguments
/// * `status` - Pointer to store the status code
///
/// # Returns
/// * Pointer to the newly created calculator, or NULL if creation fails
///
/// # Safety
/// The caller must ensure `status` is a valid pointer.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_new(
    status: *mut i32,
) -> *mut calcpi_monte_carlo_pi {
    if status.is_null() {
        return std::ptr::null_mut();
    }

    let result = catch_unwind(|| {
        let inner = MonteCarloPi::new();
        let wrapper = calcpi_monte_carlo_pi::new(inner);
        Box::into_raw(Box::new(wrapper))
    });

    match result {
        Ok(ptr) => {
            unsafe {
                *status = CALCPI_SUCCESS;
            }
            ptr
        }
        Err(_) => {
            unsafe {
                *status = CALCPI_INTERNAL_ERROR;
            }
            std::ptr::null_mut()
        }
    }
}

/// Calculate Pi using Monte Carlo method
///
/// # Arguments
/// * `calc` - Calculator instance
/// * `samples` - Number of samples to generate
/// * `result` - Pointer to store the Pi estimate
/// * `status` - Pointer to store the status code
///
/// # Returns
/// * Status code (0 on success)
///
/// # Safety
/// The caller must ensure all pointers are valid.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_calculate(
    calc: *mut calcpi_monte_carlo_pi,
    samples: u64,
    result: *mut f64,
    status: *mut i32,
) -> i32 {
    if calc.is_null() || result.is_null() || status.is_null() {
        return CALCPI_INVALID_ARGUMENT;
    }

    let ret = catch_unwind(|| unsafe {
        let wrapper = &mut *calc;
        let pi_estimate = wrapper.inner_mut().calculate(samples);
        *result = pi_estimate;
        CALCPI_SUCCESS
    });

    match ret {
        Ok(code) => {
            unsafe {
                *status = code;
            }
            code
        }
        Err(_) => {
            unsafe {
                *status = CALCPI_INTERNAL_ERROR;
            }
            CALCPI_INTERNAL_ERROR
        }
    }
}

/// Get the current Pi estimate
///
/// # Arguments
/// * `calc` - Calculator instance
/// * `result` - Pointer to store the Pi estimate
/// * `status` - Pointer to store the status code
///
/// # Returns
/// * Status code (0 on success)
///
/// # Safety
/// The caller must ensure all pointers are valid.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_estimate(
    calc: *const calcpi_monte_carlo_pi,
    result: *mut f64,
    status: *mut i32,
) -> i32 {
    if calc.is_null() || result.is_null() || status.is_null() {
        return CALCPI_INVALID_ARGUMENT;
    }

    let ret = catch_unwind(|| unsafe {
        let wrapper = &*calc;
        *result = wrapper.inner().estimate();
        CALCPI_SUCCESS
    });

    match ret {
        Ok(code) => {
            unsafe {
                *status = code;
            }
            code
        }
        Err(_) => {
            unsafe {
                *status = CALCPI_INTERNAL_ERROR;
            }
            CALCPI_INTERNAL_ERROR
        }
    }
}

/// Get the total number of samples
///
/// # Arguments
/// * `calc` - Calculator instance
/// * `result` - Pointer to store the total samples count
/// * `status` - Pointer to store the status code
///
/// # Returns
/// * Status code (0 on success)
///
/// # Safety
/// The caller must ensure all pointers are valid.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_total_samples(
    calc: *const calcpi_monte_carlo_pi,
    result: *mut u64,
    status: *mut i32,
) -> i32 {
    if calc.is_null() || result.is_null() || status.is_null() {
        return CALCPI_INVALID_ARGUMENT;
    }

    let ret = catch_unwind(|| unsafe {
        let wrapper = &*calc;
        *result = wrapper.inner().total_samples();
        CALCPI_SUCCESS
    });

    match ret {
        Ok(code) => {
            unsafe {
                *status = code;
            }
            code
        }
        Err(_) => {
            unsafe {
                *status = CALCPI_INTERNAL_ERROR;
            }
            CALCPI_INTERNAL_ERROR
        }
    }
}

/// Get the number of points inside the circle
///
/// # Arguments
/// * `calc` - Calculator instance
/// * `result` - Pointer to store the inside circle count
/// * `status` - Pointer to store the status code
///
/// # Returns
/// * Status code (0 on success)
///
/// # Safety
/// The caller must ensure all pointers are valid.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_inside_circle(
    calc: *const calcpi_monte_carlo_pi,
    result: *mut u64,
    status: *mut i32,
) -> i32 {
    if calc.is_null() || result.is_null() || status.is_null() {
        return CALCPI_INVALID_ARGUMENT;
    }

    let ret = catch_unwind(|| unsafe {
        let wrapper = &*calc;
        *result = wrapper.inner().inside_circle();
        CALCPI_SUCCESS
    });

    match ret {
        Ok(code) => {
            unsafe {
                *status = code;
            }
            code
        }
        Err(_) => {
            unsafe {
                *status = CALCPI_INTERNAL_ERROR;
            }
            CALCPI_INTERNAL_ERROR
        }
    }
}

/// Reset all statistics
///
/// # Arguments
/// * `calc` - Calculator instance
/// * `status` - Pointer to store the status code
///
/// # Returns
/// * Status code (0 on success)
///
/// # Safety
/// The caller must ensure all pointers are valid.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_reset(
    calc: *mut calcpi_monte_carlo_pi,
    status: *mut i32,
) -> i32 {
    if calc.is_null() || status.is_null() {
        return CALCPI_INVALID_ARGUMENT;
    }

    let ret = catch_unwind(|| unsafe {
        let wrapper = &mut *calc;
        wrapper.inner_mut().reset();
        CALCPI_SUCCESS
    });

    match ret {
        Ok(code) => {
            unsafe {
                *status = code;
            }
            code
        }
        Err(_) => {
            unsafe {
                *status = CALCPI_INTERNAL_ERROR;
            }
            CALCPI_INTERNAL_ERROR
        }
    }
}

/// Release the calculator instance
///
/// # Arguments
/// * `calc` - Calculator instance to release
///
/// # Safety
/// The caller must ensure `calc` is a valid pointer returned from `calcpi_monte_carlo_pi_new`
/// and has not been released already.
#[no_mangle]
pub extern "C" fn calcpi_monte_carlo_pi_release(calc: *mut calcpi_monte_carlo_pi) {
    if !calc.is_null() {
        unsafe {
            let _ = Box::from_raw(calc);
            // Drop implementation will automatically free the inner MonteCarloPi
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_c_api_new() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(&mut status);
        assert_eq!(status, CALCPI_SUCCESS);
        assert!(!calc.is_null());

        unsafe {
            calcpi_monte_carlo_pi_release(calc);
        }
    }

    #[test]
    fn test_c_api_calculate() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(&mut status);
        assert_eq!(status, CALCPI_SUCCESS);
        assert!(!calc.is_null());

        let mut result = 0.0;
        let ret = calcpi_monte_carlo_pi_calculate(calc, 10000, &mut result, &mut status);
        assert_eq!(ret, CALCPI_SUCCESS);
        assert_eq!(status, CALCPI_SUCCESS);
        assert!(result > 2.5 && result < 3.5);

        unsafe {
            calcpi_monte_carlo_pi_release(calc);
        }
    }

    #[test]
    fn test_c_api_estimate() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(&mut status);
        assert_eq!(status, CALCPI_SUCCESS);

        // First calculate some samples
        let mut _result = 0.0;
        calcpi_monte_carlo_pi_calculate(calc, 1000, &mut _result, &mut status);

        // Then estimate
        let mut estimate = 0.0;
        let ret = calcpi_monte_carlo_pi_estimate(calc, &mut estimate, &mut status);
        assert_eq!(ret, CALCPI_SUCCESS);
        assert_eq!(status, CALCPI_SUCCESS);
        assert!(estimate > 0.0);

        unsafe {
            calcpi_monte_carlo_pi_release(calc);
        }
    }

    #[test]
    fn test_c_api_total_samples() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(&mut status);
        assert_eq!(status, CALCPI_SUCCESS);

        let mut _result = 0.0;
        calcpi_monte_carlo_pi_calculate(calc, 5000, &mut _result, &mut status);

        let mut total = 0u64;
        let ret = calcpi_monte_carlo_pi_total_samples(calc, &mut total, &mut status);
        assert_eq!(ret, CALCPI_SUCCESS);
        assert_eq!(status, CALCPI_SUCCESS);
        assert_eq!(total, 5000);

        unsafe {
            calcpi_monte_carlo_pi_release(calc);
        }
    }

    #[test]
    fn test_c_api_inside_circle() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(&mut status);
        assert_eq!(status, CALCPI_SUCCESS);

        let mut _result = 0.0;
        calcpi_monte_carlo_pi_calculate(calc, 10000, &mut _result, &mut status);

        let mut inside = 0u64;
        let ret = calcpi_monte_carlo_pi_inside_circle(calc, &mut inside, &mut status);
        assert_eq!(ret, CALCPI_SUCCESS);
        assert_eq!(status, CALCPI_SUCCESS);
        assert!(inside > 0 && inside <= 10000);

        unsafe {
            calcpi_monte_carlo_pi_release(calc);
        }
    }

    #[test]
    fn test_c_api_reset() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(&mut status);
        assert_eq!(status, CALCPI_SUCCESS);

        let mut _result = 0.0;
        calcpi_monte_carlo_pi_calculate(calc, 1000, &mut _result, &mut status);

        let mut total = 0u64;
        calcpi_monte_carlo_pi_total_samples(calc, &mut total, &mut status);
        assert_eq!(total, 1000);

        let ret = calcpi_monte_carlo_pi_reset(calc, &mut status);
        assert_eq!(ret, CALCPI_SUCCESS);
        assert_eq!(status, CALCPI_SUCCESS);

        calcpi_monte_carlo_pi_total_samples(calc, &mut total, &mut status);
        assert_eq!(total, 0);

        unsafe {
            calcpi_monte_carlo_pi_release(calc);
        }
    }

    #[test]
    fn test_null_pointer_handling() {
        let mut status = 0;
        let calc = calcpi_monte_carlo_pi_new(std::ptr::null_mut());
        assert!(calc.is_null());

        let mut result = 0.0;
        let ret = calcpi_monte_carlo_pi_calculate(
            std::ptr::null_mut(),
            1000,
            &mut result,
            &mut status,
        );
        assert_eq!(ret, CALCPI_INVALID_ARGUMENT);
    }
}
