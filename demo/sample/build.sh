#!/usr/bin/env bash

brew install binaryen || echo "binaryen is already installed"

javac Main.java && native-image   --tool:svm-wasm Main 