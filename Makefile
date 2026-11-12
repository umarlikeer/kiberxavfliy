.PHONY: all rust ios test clean fmt lint setup help

CARGO := cargo
LIB_NAME := libkiberxavfliy_core

all: rust ios

rust:
	cd rust-core && $(CARGO) build --release --target aarch64-apple-ios

ios:
	@echo "iOS build faqat macOS da ishlaydi"

test:
	cd rust-core && $(CARGO) test

clean:
	cd rust-core && $(CARGO) clean

fmt:
	cd rust-core && $(CARGO) fmt

lint:
	cd rust-core && $(CARGO) clippy --all-targets --all-features -- -D warnings

setup:
	rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
	$(CARGO) install cargo-lipo

help:
	@echo "KiberXavfliy Makefile:"
	@echo "  make rust   - Rust build"
	@echo "  make ios    - iOS build (macOS)"
	@echo "  make test   - Testlar"
	@echo "  make clean  - Tozalash"
	@echo "  make fmt    - Format"
	@echo "  make lint   - Clippy"
	@echo "  make setup  - Sozlamalar"
