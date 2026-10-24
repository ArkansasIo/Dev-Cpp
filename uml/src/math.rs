// UML — mathematics engine (universal math functions)
pub fn is_prime(n: i64) -> bool {
    if n < 2 { return false; }
    if n % 2 == 0 { return n == 2; }
    let mut d = 3i64;
    while d * d <= n {
        if n % d == 0 { return false; }
        d += 2;
    }
    true
}

pub fn gcd(a: i64, b: i64) -> i64 {
    let (mut a, mut b) = (a.abs(), b.abs());
    while b != 0 { let t = b; b = a % b; a = t; }
    a
}

pub fn lcm(a: i64, b: i64) -> i64 {
    if a == 0 || b == 0 { 0 } else { (a / gcd(a, b)) * b }
}

pub fn factor(mut n: i64) -> Vec<i64> {
    let mut out = Vec::new();
    let mut d = 2i64;
    while d * d <= n {
        while n % d == 0 { out.push(d); n /= d; }
        d += if d == 2 { 1 } else { 2 };
    }
    if n > 1 { out.push(n); }
    out
}

pub fn factorial(n: u64) -> u64 {
    (1..=n).product()
}

pub fn fibonacci(n: u64) -> u64 {
    let (mut a, mut b) = (0u64, 1u64);
    for _ in 0..n { let t = a + b; a = b; b = t; }
    a
}

/// simple quadratic solver: a*x^2 + b*x + c = 0 -> roots (real parts; NaN when complex)
pub fn solve_quadratic(a: f64, b: f64, c: f64) -> (f64, f64) {
    let disc = b * b - 4.0 * a * c;
    if disc < 0.0 { (f64::NAN, f64::NAN) }
    else {
        let s = disc.sqrt();
        ((-b + s) / (2.0 * a), (-b - s) / (2.0 * a))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn primes() { assert!(is_prime(97)); assert!(!is_prime(1)); assert!(is_prime(2)); assert!(!is_prime(100)); }
    #[test]
    fn g() { assert_eq!(gcd(54, 24), 6); assert_eq!(lcm(4, 6), 12); }
    #[test]
    fn f() { assert_eq!(factor(144), vec![2,2,2,2,3,3]); assert_eq!(factorial(5), 120); assert_eq!(fibonacci(10), 55); }
    #[test]
    fn q() { let (r1, r2) = solve_quadratic(1.0, -5.0, 6.0); assert!((r1 - 3.0).abs() < 1e-9 || (r2 - 3.0).abs() < 1e-9); }
}
