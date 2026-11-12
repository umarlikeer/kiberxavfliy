use std::env;

fn main() {
    let target = env::var("TARGET").unwrap();
    if target.contains("apple-ios") {
        println!("cargo:rustc-cfg=ios");
    }
    println!("cargo:rerun-if-changed=src/");
}
