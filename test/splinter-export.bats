#!/usr/bin/env bats
load 'test_helper.sh'


function setup {
  lists_dir='files/lists'
  preferences_dir='files/preferences'
  macprefs_dir='tools/macprefs'
  homebrew_cask_apps_list="${lists_dir}/homebrew_cask_apps.txt"
  homebrew_packages_list="${lists_dir}/homebrew_packages.txt"
  homebrew_taps_list="${lists_dir}/homebrew_taps.txt"
  mas_apps_list="${lists_dir}/mas_apps.txt"
  npm_global_packages_list="${lists_dir}/npm_global_packages.json"
  pip_packages_list="${lists_dir}/pip_packages.txt"
  ruby_gems_list="${lists_dir}/ruby_gems.txt"
}

function teardown {
  if [[ -f $homebrew_cask_apps_list ]]; then rm "$homebrew_cask_apps_list"; fi
  if [[ -f $homebrew_packages_list ]]; then rm "$homebrew_packages_list"; fi
  if [[ -f $homebrew_taps_list ]]; then rm "$homebrew_taps_list"; fi
  if [[ -f $mas_apps_list ]]; then rm "$mas_apps_list"; fi
  if [[ -f $npm_global_packages_list ]]; then rm "$npm_global_packages_list"; fi
  if [[ -f $pip_packages_list ]]; then rm "$pip_packages_list"; fi
  if [[ -f $ruby_gems_list ]]; then rm "$ruby_gems_list"; fi
  if [[ -d $preferences_dir ]]; then rm -rf "$preferences_dir"; fi
  if [[ -d $macprefs_dir ]]; then rm -rf "$macprefs_dir"; fi
}

function invalid_argument_test {
  run ./splinter export "$1" invalid-argument
  assert_output --partial 'ERROR'
  assert_output --partial 'Invalid'
  assert_failure
}

function no_argument_test {
  run ./splinter export "$1"
  assert_file_exist "$2"
  refute_output --partial 'ERROR'
  assert_success
}

function valid_argument_test {
  run ./splinter export "$1" "$2"
  assert_file_exist "$3"
  refute_output --partial 'ERROR'
  assert_success
}

@test './splinter export (no arguments) - expected to fail' {
  run ./splinter export
  assert_output --partial 'Missing option'
  assert_failure
}

@test './splinter export <invalid-argument> - expected to fail' {
  invalid_argument_test invalid-argument
}

@test './splinter export all - expected to create all lists in ./files/lists' {
  run ./splinter export all
  assert_file_exist "$homebrew_packages_list"
  assert_file_exist "$homebrew_cask_apps_list"
  assert_file_exist "$homebrew_taps_list"
  assert_file_exist "$mas_apps_list"
  assert_file_exist "$npm_global_packages_list"
  assert_file_exist "$pip_packages_list"
  assert_file_exist "$ruby_gems_list"
  assert_dir_exist  "$preferences_dir"
  assert_dir_exist  "$macprefs_dir"
  assert_success
}

@test './splinter export brew (no arguments) - expected to create taps, packages and casks lists in ./files/lists' {
  run ./splinter export brew
  assert_file_exist "$homebrew_packages_list"
  assert_file_exist "$homebrew_cask_apps_list"
  assert_file_exist "$homebrew_taps_list"
  refute_output --partial 'ERROR'
  assert_success
}

@test './splinter export brew all - expected to create taps, packages and casks lists in ./files/lists' {
  run ./splinter export 'brew' 'all'
  assert_file_exist "$homebrew_packages_list"
  assert_file_exist "$homebrew_cask_apps_list"
  assert_file_exist "$homebrew_taps_list"
  refute_output --partial 'ERROR'
  assert_success
}

@test './splinter export brew taps - expected to create ./files/lists/homebrew_taps.txt' {
  valid_argument_test 'brew' 'taps' "$homebrew_taps_list"
}

@test './splinter export brew packages - expected to create ./files/lists/homebrew_packages.txt' {
  valid_argument_test 'brew' 'packages' "$homebrew_packages_list"
}

@test './splinter export brew casks - expected to create ./files/lists/homebrew_casks.txt' {
  valid_argument_test 'brew' 'casks' "$homebrew_cask_apps_list"
}

@test './splinter export brew <invalid-argument> - expected to fail' {
  invalid_argument_test 'brew'
}

@test './splinter export ruby (no arguments) - expected to create ./files/lists/ruby_gems.txt' {
  no_argument_test 'ruby' "$ruby_gems_list"
}

@test './splinter export ruby gems - expected to create ./files/lists/ruby_gems.txt' {
  valid_argument_test 'ruby' 'gems' "$ruby_gems_list"
}

@test './splinter export ruby <invalid-argument> - expected to fail' {
  invalid_argument_test 'ruby'
}

@test './splinter export mas (no arguments) - expected to create ./files/lists/mas_apps.txt' {
  no_argument_test 'mas' "$mas_apps_list"
}

@test './splinter export mas packages - expected to create ./files/lists/mas_apps.txt' {
  valid_argument_test 'mas' 'packages' "$mas_apps_list"
}

@test './splinter export mas <invalid-argument> - expected to fail' {
  invalid_argument_test 'mas'
}

@test './splinter export npm (no arguments) - expected to create ./files/lists/npm_global_packages.txt' {
  no_argument_test 'npm' "$npm_global_packages_list"
}

@test './splinter export npm packages - expected to create ./files/lists/npm_global_packages.txt' {
  valid_argument_test 'npm' 'packages' "$npm_global_packages_list"
}

@test './splinter export npm <invalid-argument> - expected to fail' {
  invalid_argument_test 'npm'
}

@test './splinter export pip (no arguments) - expected to create ./files/lists/pip_packages.txt' {
  no_argument_test 'pip' "$pip_packages_list"
}

@test './splinter export pip packages - expected to create ./files/lists/pip_packages.txt' {
  valid_argument_test 'pip' 'packages' "$pip_packages_list"
}

@test './splinter export pip <invalid-argument> - expected to fail' {
  invalid_argument_test 'pip'
}

@test './splinter export preferences - expected to create ./files/preferences and ./tools/macprefs' {
  run ./splinter export preferences
  assert_dir_exist "$macprefs_dir"
  assert_dir_exist "$preferences_dir"
  assert_output --partial 'Installing Macprefs'
  assert_output --partial 'Running macprefs backup'
  assert_success
}
