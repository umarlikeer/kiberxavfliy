//! Kriptografik funksiyalar

use sha2::{Digest, Sha256};
use md5;
use base64::{Engine as _, engine::general_purpose};
use rand::{thread_rng, Rng};

pub fn sha256_hash(input: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(input.as_bytes());
    format!("{:x}", hasher.finalize())
}

pub fn md5_hash(input: &str) -> String {
    format!("{:x}", md5::compute(input.as_bytes()))
}

pub fn base64_encode(input: &str) -> String {
    general_purpose::STANDARD.encode(input.as_bytes())
}

pub fn base64_decode(input: &str) -> Option<String> {
    match general_purpose::STANDARD.decode(input.as_bytes()) {
        Ok(bytes) => String::from_utf8(bytes).ok(),
        Err(_) => None,
    }
}

pub fn generate_password(length: usize, include_special: bool) -> String {
    let length = length.clamp(8, 128);
    let mut rng = thread_rng();
    let lowercase = "abcdefghijklmnopqrstuvwxyz";
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    let digits = "0123456789";
    let special = "!@#$%^&*()_+-=[]{}|;:,.<>?";

    let mut chars: Vec<char> = Vec::new();
    chars.push(lowercase.chars().nth(rng.gen_range(0..lowercase.len())).unwrap());
    chars.push(uppercase.chars().nth(rng.gen_range(0..uppercase.len())).unwrap());
    chars.push(digits.chars().nth(rng.gen_range(0..digits.len())).unwrap());
    if include_special {
        chars.push(special.chars().nth(rng.gen_range(0..special.len())).unwrap());
    }

    let all_chars = if include_special {
        format!("{}{}{}{}", lowercase, uppercase, digits, special)
    } else {
        format!("{}{}{}", lowercase, uppercase, digits)
    };

    for _ in 0..(length - chars.len()) {
        chars.push(all_chars.chars().nth(rng.gen_range(0..all_chars.len())).unwrap());
    }

    for i in (1..chars.len()).rev() {
        let j = rng.gen_range(0..=i);
        chars.swap(i, j);
    }

    chars.into_iter().collect()
}

pub fn constant_time_compare(a: &str, b: &str) -> bool {
    if a.len() != b.len() { return false; }
    let mut result = 0u8;
    for (x, y) in a.bytes().zip(b.bytes()) {
        result |= x ^ y;
    }
    result == 0
}
