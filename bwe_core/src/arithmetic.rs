//! Modular arithmetic engine for BWE
//! No subtraction or division. All operations in modular rings (2^n).

pub struct ModRing {
    pub modulus: u64,
}

impl ModRing {
    pub fn new(bits: u32) -> Self {
        Self { modulus: 1 << bits }
    }
    pub fn add(&self, a: u64, b: u64) -> u64 {
        (a + b) % self.modulus
    }
    pub fn neg(&self, b: u64) -> u64 {
        (self.modulus - b) % self.modulus
    }
    pub fn sub(&self, a: u64, b: u64) -> u64 {
        self.add(a, self.neg(b))
    }
    pub fn mul(&self, a: u64, b: u64) -> u64 {
        (a * b) % self.modulus
    }
    pub fn inv(&self, b: u64) -> Option<u64> {
        // Modular inverse using extended Euclidean algorithm
        let mut t = 0i64;
        let mut new_t = 1i64;
        let mut r = self.modulus as i64;
        let mut new_r = b as i64;
        while new_r != 0 {
            let quotient = r / new_r;
            let temp_t = t - quotient * new_t;
            t = new_t;
            new_t = temp_t;
            let temp_r = r - quotient * new_r;
            r = new_r;
            new_r = temp_r;
        }
        if r > 1 { return None; }
        if t < 0 { t += self.modulus as i64; }
        Some(t as u64)
    }
    pub fn div(&self, a: u64, b: u64) -> Option<u64> {
        self.inv(b).map(|inv_b| self.mul(a, inv_b))
    }
}
