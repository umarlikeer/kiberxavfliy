//! KiberXavfliy Core Security Engine

pub mod network;
pub mod crypto;
pub mod ffi;
pub mod password;
pub mod ssl;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

unsafe fn c_str_to_string(ptr: *const c_char) -> Option<String> {
    if ptr.is_null() { return None; }
    CStr::from_ptr(ptr).to_str().ok().map(|s| s.to_string())
}

fn string_to_c_ptr(s: String) -> *mut c_char {
    match CString::new(s) {
        Ok(cstring) => cstring.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn kx_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe { let _ = CString::from_raw(ptr); }
    }
}

#[no_mangle]
pub extern "C" fn kx_version() -> *mut c_char {
    string_to_c_ptr(env!("CARGO_PKG_VERSION").to_string())
}
