use std::env;

fn main() {
    let target = env::var("TARGET").unwrap();
    if target.contains("apple-ios") {
        println!("cargo:rustc-cfg=ios");
    }
    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=src/ffi.rs");
    println!("cargo:rerun-if-changed=src/network.rs");
    println!("cargo:rerun-if-changed=src/crypto.rs");
    println!("cargo:rerun-if-changed=src/password.rs");
    println!("cargo:rerun-if-changed=src/ssl.rs");
}
