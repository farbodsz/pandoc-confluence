.PHONY: build install test

build:
	stack build

install:
	stack install

test:
	. ./tests/run_tests.sh
