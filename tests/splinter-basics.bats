#!/usr/bin/env bats
load 'test_helper.sh'

@test './splinter is executable' {
  assert_file_executable './splinter'
}

@test './splinter <missing-argument>' {
  ./splinter
  assert_output --partial 'Error'
  assert_failure
}

@test './splinter --help' {
  run ./splinter --help
  assert_output --partial 'usage:'
  assert_success
}

@test './splinter --version' {
  run ./splinter --version
  assert_output --partial 'Splinter'
  assert_success
}

@test 'list profiles' {
  run list profiles
  refute_output --partial 'Error'
  assert_success
}

@test 'list  <invalid-argument>' {
  run list invalid-argument
  assert_output --partial 'Error'
  assert_failure
}
