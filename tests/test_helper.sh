#!/bin/bash
# Load a library from the `${BATS_TEST_DIRNAME}/test_helper' directory.
#   $1 - name of library to load
load_lib() {
  local name="$1"
  load "test_helper/${name}/load"
}

# load a library with only its name, instead of having to type the entire installation path.

load_lib bats-support
load_lib bats-assert
load_lib bats-file
