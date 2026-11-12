//! FFI - Swift bilan bog'lanish

use crate::{c_str_to_string, string_to_c_ptr, crypto, network, password, ssl};
use std::os::raw::{c_char, c_int, c_double};
use serde_json;

#[no_mangle]
pub extern "C" fn kx_scan_network(
    base_ip: *const c_char, start_port: c_int, end_port: c_int, timeout_ms: c_int,
) -> *mut c_char {
    let base = unsafe { c_str_to_string(base_ip).unwrap_or_else(|| "192.168.1".to_string()) };
    let result = network::scan_ip_range(&base, start_port as u16, end_port as u16, timeout_ms as u64);
    match serde_json::to_string(&result) {
        Ok(json) => string_to_c_ptr(json),
        Err(_) => string_to_c_ptr(r#"{"error":"JSON serialization failed"}"#.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn kx_scan_ports(
    host: *const c_char, start_port: c_int, end_port: c_int, timeout_ms: c_int,
) -> *mut c_char {
    let hostname = unsafe { c_str_to_string(host).unwrap_or_else(|| "127.0.0.1".to_string()) };
    let result = network::scan_ports(&hostname, start_port as u16, end_port as u16, timeout_ms as u64);
    match serde_json::to_string(&result) {
        Ok(json) => string_to_c_ptr(json),
        Err(_) => string_to_c_ptr(r#"{"error":"JSON serialization failed"}"#.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn kx_check_ssl(host: *const c_char, port: c_int) -> *mut c_char {
    let hostname = unsafe { c_str_to_string(host).unwrap_or_default() };
    if hostname.is_empty() {
        return string_to_c_ptr(r#"{"error":"Empty hostname"}"#.to_string());
    }
    let result = ssl::check_certificate(&hostname, port as u16);
    match serde_json::to_string(&result) {
        Ok(json) => string_to_c_ptr(json),
        Err(_) => string_to_c_ptr(r#"{"error":"JSON serialization failed"}"#.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn kx_analyze_password(password: *const c_char) -> c_double {
    let pwd = unsafe { c_str_to_string(password).unwrap_or_default() };
    password::analyze_strength(&pwd) as c_double
}

#[no_mangle]
pub extern "C" fn kx_password_details(password: *const c_char) -> *mut c_char {
    let pwd = unsafe { c_str_to_string(password).unwrap_or_default() };
    let details = password::get_details(&pwd);
    match serde_json::to_string(&details) {
        Ok(json) => string_to_c_ptr(json),
        Err(_) => string_to_c_ptr(r#"{"error":"JSON serialization failed"}"#.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn kx_sha256(input: *const c_char) -> *mut c_char {
    let text = unsafe { c_str_to_string(input).unwrap_or_default() };
    string_to_c_ptr(crypto::sha256_hash(&text))
}

#[no_mangle]
pub extern "C" fn kx_md5(input: *const c_char) -> *mut c_char {
    let text = unsafe { c_str_to_string(input).unwrap_or_default() };
    string_to_c_ptr(crypto::md5_hash(&text))
}

#[no_mangle]
pub extern "C" fn kx_base64_encode(input: *const c_char) -> *mut c_char {
    let text = unsafe { c_str_to_string(input).unwrap_or_default() };
    string_to_c_ptr(crypto::base64_encode(&text))
}

#[no_mangle]
pub extern "C" fn kx_base64_decode(input: *const c_char) -> *mut c_char {
    let text = unsafe { c_str_to_string(input).unwrap_or_default() };
    match crypto::base64_decode(&text) {
        Some(decoded) => string_to_c_ptr(decoded),
        None => string_to_c_ptr(r#"{"error":"Invalid base64"}"#.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn kx_generate_password(length: c_int, include_special: c_int) -> *mut c_char {
    let pwd = crypto::generate_password(length as usize, include_special != 0);
    string_to_c_ptr(pwd)
}

#[no_mangle]
pub extern "C" fn kx_security_tips() -> *mut c_char {
    let tips = network::get_security_tips();
    match serde_json::to_string(&tips) {
        Ok(json) => string_to_c_ptr(json),
        Err(_) => string_to_c_ptr(r#"[]"#.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn kx_ip_info(ip: *const c_char) -> *mut c_char {
    let ip_str = unsafe { c_str_to_string(ip).unwrap_or_default() };
    let info = network::get_ip_info(&ip_str);
    match serde_json::to_string(&info) {
        Ok(json) => string_to_c_ptr(json),
        Err(_) => string_to_c_ptr(r#"{"error":"JSON serialization failed"}"#.to_string()),
    }
}
