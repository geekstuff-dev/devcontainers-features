#!make

.rust-run:
	cargo run

.rust-fmt:
	cargo fmt -v

.rust-check:
	cargo check

.rust-test:
	cargo test

.rust-versions:
	@rustc --version
	@cargo --version
