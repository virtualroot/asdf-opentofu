#!/usr/bin/env bash

shfmt --language-dialect bash --write \
	./bin/* \
	./lib/* \
	./scripts/*
