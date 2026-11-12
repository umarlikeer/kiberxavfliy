//! Parol kuchini tahlil qilish

use serde::{Deserialize, Serialize};
use std::collections::HashSet;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PasswordDetails {
    pub score: f64,
    pub length: usize,
    pub has_lowercase: bool,
    pub has_uppercase: bool,
    pub has_digits: bool,
    pub has_special: bool,
    pub unique_chars: usize,
    pub repeated_chars: usize,
    pub sequential_chars: usize,
    pub strength_label: String,
    pub time_to_crack: String,
    pub suggestions: Vec<String>,
}

const COMMON_PASSWORDS: &[&str] = &[
    "123456", "password", "12345678", "qwerty", "123456789",
    "12345", "1234", "111111", "1234567", "dragon",
    "master", "monkey", "letmein", "shadow", "sunshine",
    "princess", "admin", "welcome", "football", "charlie",
];

pub fn analyze_strength(password: &str) -> f64 {
    if password.is_empty() { return 0.0; }
    if COMMON_PASSWORDS.contains(&password.to_lowercase().as_str()) { return 5.0; }

    let mut score = 0.0;
    let len = password.len();
    score += (len as f64) * 4.0;

    let has_lower = password.chars().any(|c| c.is_ascii_lowercase());
    let has_upper = password.chars().any(|c| c.is_ascii_uppercase());
    let has_digit = password.chars().any(|c| c.is_ascii_digit());
    let has_special = password.chars().any(|c| !c.is_alphanumeric());

    if has_lower { score += 10.0; }
    if has_upper { score += 10.0; }
    if has_digit { score += 10.0; }
    if has_special { score += 15.0; }

    let unique: HashSet<char> = password.chars().collect();
    let uniqueness_ratio = unique.len() as f64 / len as f64;
    score += uniqueness_ratio * 15.0;

    let sequential = count_sequential(password);
    score -= (sequential as f64) * 3.0;

    score.clamp(0.0, 100.0)
}

pub fn get_details(password: &str) -> PasswordDetails {
    let len = password.len();
    let has_lowercase = password.chars().any(|c| c.is_ascii_lowercase());
    let has_uppercase = password.chars().any(|c| c.is_ascii_uppercase());
    let has_digits = password.chars().any(|c| c.is_ascii_digit());
    let has_special = password.chars().any(|c| !c.is_alphanumeric());

    let unique: HashSet<char> = password.chars().collect();
    let unique_chars = unique.len();
    let repeated_chars = len - unique_chars;
    let sequential_chars = count_sequential(password);

    let score = analyze_strength(password);

    PasswordDetails {
        score, length: len, has_lowercase, has_uppercase, has_digits, has_special,
        unique_chars, repeated_chars, sequential_chars,
        strength_label: get_strength_label(score),
        time_to_crack: estimate_crack_time(score, len),
        suggestions: generate_suggestions(password, score, has_lowercase, has_uppercase, has_digits, has_special),
    }
}

fn get_strength_label(score: f64) -> String {
    match score {
        s if s < 20.0 => "Juda zaif".to_string(),
        s if s < 40.0 => "Zaif".to_string(),
        s if s < 60.0 => "O'rtacha".to_string(),
        s if s < 80.0 => "Kuchli".to_string(),
        _ => "Juda kuchli".to_string(),
    }
}

fn estimate_crack_time(score: f64, length: usize) -> String {
    match score {
        s if s < 10.0 => "Soniyalar".to_string(),
        s if s < 20.0 => "Daqiqalar".to_string(),
        s if s < 40.0 => "Soatlar".to_string(),
        s if s < 60.0 => "Kunlar".to_string(),
        s if s < 80.0 => "Yillar".to_string(),
        _ => format!("{} yil+", 10usize.pow((length / 4) as u32)),
    }
}

fn count_sequential(password: &str) -> usize {
    let chars: Vec<char> = password.chars().collect();
    let mut count = 0;
    for window in chars.windows(3) {
        let a = window[0] as u8;
        let b = window[1] as u8;
        let c = window[2] as u8;
        if (b == a + 1 && c == b + 1) || (b == a - 1 && c == b - 1) {
            count += 1;
        }
        if is_keyboard_sequential(window[0], window[1], window[2]) {
            count += 1;
        }
    }
    count
}

fn is_keyboard_sequential(a: char, b: char, c: char) -> bool {
    let rows = ["qwertyuiop", "asdfghjkl", "zxcvbnm"];
    for row in &rows {
        let chars: Vec<char> = row.chars().collect();
        for window in chars.windows(3) {
            if (window[0] == a && window[1] == b && window[2] == c) ||
               (window[0] == c && window[1] == b && window[2] == a) {
                return true;
            }
        }
    }
    false
}

fn generate_suggestions(password: &str, score: f64, has_lower: bool, has_upper: bool, has_digit: bool, has_special: bool) -> Vec<String> {
    let mut suggestions = Vec::new();
    if password.len() < 12 {
        suggestions.push("Parol uzunligini kamida 12 ta belgiga oshiring".to_string());
    }
    if !has_lower { suggestions.push("Kichik harflar qo'shing".to_string()); }
    if !has_upper { suggestions.push("Katta harflar qo'shing".to_string()); }
    if !has_digit { suggestions.push("Raqamlar qo'shing".to_string()); }
    if !has_special { suggestions.push("Maxsus belgilar qo'shing (!@#$%)".to_string()); }
    if COMMON_PASSWORDS.contains(&password.to_lowercase().as_str()) {
        suggestions.push("Bu parol juda mashhur, boshqa parol tanlang".to_string());
    }
    if score < 60.0 && suggestions.is_empty() {
        suggestions.push("Parolni yanada murakkabroq qiling".to_string());
    }
    suggestions
}
