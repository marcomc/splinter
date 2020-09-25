#!/usr/bin/env bats
load 'test_helper.sh'

@test './splinter is executable' {
  assert_file_executable './splinter'
}

@test './splinter <missing-argument> - expected to fail' {
  run ./splinter
  assert_output --partial 'Error'
  assert_failure
}

@test './splinter --help - expected to print usage instructions' {
  run ./splinter --help
  assert_output --partial 'usage:'
  assert_success
}

@test './splinter --version - expected to show Splinter version' {
  run ./splinter --version
  assert_output --partial 'Splinter'
  assert_success
}

@test './splinter list profiles - expected to show list of profiles' {
  run ./splinter list profiles
  refute_output --partial 'Error'
  assert_success
}

@test './splinter list  <invalid-argument> - expected to fail' {
  run ./splinter list invalid-argument
  assert_output --partial 'Error'
  assert_failure
}
