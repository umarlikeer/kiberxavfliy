#!/bin/bash
set -e

LIB_NAME="libkiberxavfliy_core"
CORE_DIR="rust-core"
IOS_DIR="ios/KiberXavfliy/Libraries"

echo "=== XCFramework yaratish ==="
cd "${CORE_DIR}"

cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target x86_64-apple-ios

mkdir -p "../${IOS_DIR}"
rm -rf "../${IOS_DIR}/${LIB_NAME}.xcframework"

xcodebuild -create-xcframework \
    -library "target/aarch64-apple-ios/release/${LIB_NAME}.a" \
    -headers "include" \
    -library "target/aarch64-apple-ios-sim/release/${LIB_NAME}.a" \
    -headers "include" \
    -library "target/x86_64-apple-ios/release/${LIB_NAME}.a" \
    -headers "include" \
    -output "../${IOS_DIR}/${LIB_NAME}.xcframework"

echo "=== XCFramework tayyor: ${IOS_DIR}/${LIB_NAME}.xcframework ==="
