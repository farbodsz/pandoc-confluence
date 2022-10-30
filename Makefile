.PHONY: build install test example

build:
	stack build

install:
	stack install

test:
	. ./tests/run_tests.sh

example:
	. ./examples/run_example.sh
