.PHONY: build install test doctest test-all example

build:
	stack build

install:
	stack install

doctest:
	stack test

test:
	. ./tests/run_tests.sh

test-all: doctest test

example:
	. ./examples/run_example.sh
