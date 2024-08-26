#!make

include ${DC_ASSETS_RUST}/lib.mk

run: .rust-run
fmt: .rust-fmt
check: .rust-check
test: .rust-test
versions: .rust-versions
