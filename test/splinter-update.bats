#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  git_account_name="marcomc"
  git_repo_name="splinter-profiles"
  custom_profile="test"
  profiles_dir='./profiles'
  conda_dir='./conda'
  pyenv_dir='./pyenv'
  galaxy_dir='./ansible/roles'
  splinter_toolkit_galaxy_role="${galaxy_dir}/marcomc.splinter_toolkit"
  tools_dir='./tools'
  tools_script_1="${tools_dir}/export-apps-lists.sh"
  tools_script_2="${tools_dir}/filevault-recovery-key-generator.sh"
  brew_tool='/usr/local/bin/brew'
}

function teardown {
  if [[ -d ${profiles_dir}/${git_account_name}.${custom_profile} ]]; then rm -rf "${profiles_dir:?}/${git_account_name}.${custom_profile}"; fi
  if [[ -d $splinter_toolkit_galaxy_role ]]; then rm -rf "$splinter_toolkit_galaxy_role"; fi
  if [[ -f $tools_script_1 ]]; then rm "$tools_script_1"; fi
  if [[ -f $tools_script_2 ]]; then rm "$tools_script_2"; fi
}

function invalid_argument_test {
  run ./splinter update "$1" invalid-argument
  assert_output --partial 'Invalid'
  assert_failure
}

function no_argument_test {
  run ./splinter update "$1"
  assert_file_exist "$2"
  refute_output --partial 'ERROR'
  assert_success
}

function valid_argument_test {
  run ./splinter update "$1" "$2"
  assert_file_exist "$3"
  refute_output --partial 'ERROR'
  assert_success
}

@test "./splinter update <missing-argument> - expected to fail" {
  run ./splinter update
  assert_output --partial 'Missing option'
  assert_failure
}

@test "./splinter update <invalid-argument> - expected to fail" {
  invalid_argument_test invalid-argument
}

@test "./splinter update profiles (no arguments) - expected to fail" {
  run ./splinter update profiles
  assert_output --partial 'No account name was provided'
  assert_failure
}

@test "./splinter update profiles <invalid-argument> - expected to fail" {
  run ./splinter update profiles invalid-argument
  assert_output --partial 'Provided unknow parameter'
  assert_failure
}

@test "./splinter update profiles <invalid '-%' setting > - expected to fail" {
  run ./splinter update profiles -%invalid-setting
  assert_output --partial 'Invalid setting'
  assert_failure
}

@test "./splinter update profiles -a git_account_name - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -a "$git_account_name"
  assert_output --partial 'Profiles updated successfully'
  assert_dir_exist "${profiles_dir}/${git_account_name}.${custom_profile}"
  assert_success
}

@test "./splinter update profiles -a <missing-argument> - expected to fail" {
  run ./splinter update profiles -a
  assert_output --partial 'missing an argument'
  assert_failure
}

@test "./splinter update profiles -a <invalid_account> - expected to fail" {
  run ./splinter update profiles -a 'invalid_account'
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -b git_account_name.custom_profile - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -b "${git_account_name}.${custom_profile}"
  assert_output --partial 'Profiles updated successfully'
  assert_dir_exist "${profiles_dir}/${git_account_name}.${custom_profile}"
  assert_success
}

@test "./splinter update profiles -b custom_profile (no git_account_name) - expected to fail" {
  run ./splinter update profiles -b "${custom_profile}"
  assert_output --partial 'No account name was provided'
  assert_failure
}

@test "./splinter update profiles -b invalid_account.custom_profile  - expected to fail" {
  run ./splinter update profiles -b "invalid_account.${custom_profile}"
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -b git_account_name.invalid_profile - expected to fail" {
  run ./splinter update profiles -b "${git_account_name}.invalid_profile"
  assert_output --partial 'No profile'
  assert_failure
}

@test "./splinter update profiles -b <missing-argument> - expected to fail" {
  run ./splinter update profiles -b
  assert_output --partial 'missing an argument'
  assert_failure
}

@test "./splinter update profiles -a git_account_name -b <invalid_profile> - expected to fail" {
  run ./splinter update profiles -a "$git_account_name" -b 'invalid_profile'
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -r git_account_name.custom_profile - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -r "${git_account_name}.${custom_profile}"
  assert_output --partial 'Profiles updated successfully'
  assert_dir_exist "${profiles_dir}/${git_account_name}.${custom_profile}"
  assert_success
}

@test "./splinter update profiles -r custom_profile (no git_account_name) - expected to fail" {
  run ./splinter update profiles -r "${custom_profile}"
  assert_output --partial 'No account name was provided'
  assert_failure
}

@test "./splinter update profiles -r invalid_account.custom_profile - expected to fail" {
  run ./splinter update profiles -r "invalid_account.${custom_profile}"
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -r git_account_name.invalid_profile - expected to fail" {
  run ./splinter update profiles -r "${git_account_name}.invalid_profile"
  assert_output --partial 'No profile'
  assert_failure
}

@test "./splinter update profiles -r <missing-argument> - expected to fail" {
  run ./splinter update profiles -r
  assert_output --partial 'missing an argument'
  assert_failure
}

@test "./splinter update profiles -a git_account_name -r <invalid_profile> - expected to fail" {
  run ./splinter update profiles -a "$git_account_name" -r 'invalid_profile'
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -g git_repo_name - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -g "$git_repo_name"
  assert_output --partial 'No account name was provided'
  assert_failure
}

@test "./splinter update profiles -a git_account_name -g git_repo_name - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -a "$git_account_name" -g "$git_repo_name"
  assert_output --partial 'Profiles updated successfully'
  assert_dir_exist "${profiles_dir}/${git_account_name}.${custom_profile}"
  assert_success
}

@test "./splinter update profiles -g <missing-argument> - expected to fail" {
  run ./splinter update profiles -g
  assert_output --partial 'missing an argument'
  assert_failure
}

@test "./splinter update profiles -g <invalid_git_repo_name> - expected to fail" {
  run ./splinter update profiles -g 'invalid_git_repo_name'
  assert_output --partial 'No account name was provided'
  assert_failure
}

@test "./splinter update profiles -a git_account_name -g <invalid_git_repo_name> - expected to fail" {
  run ./splinter update profiles -a "$git_account_name" -g 'invalid_git_repo_name'
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -a git_account_name -g git_repo_name -b <invalid_profile> - expected to fail" {
  run ./splinter update profiles -a "$git_account_name" -g "$git_repo_name" -b "invalid_profile"
  assert_output --partial 'Downloading custom profiles'
  assert_failure
}

@test "./splinter update profiles -a git_account_name -g git_repo_name -b custom_profile - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -a "$git_account_name" -g "$git_repo_name" -b "$custom_profile"
  assert_output --partial 'Profiles updated successfully'
  assert_dir_exist "${profiles_dir}/${git_account_name}.${custom_profile}"
  assert_success
}

@test "./splinter update profiles -a git_account_name -g git_repo_name -r custom_profile - expected to create 'git_account_name.custom_profile'" {
  run ./splinter update profiles -a "$git_account_name" -g "$git_repo_name" -r "$custom_profile"
  assert_output --partial 'Profiles updated successfully'
  assert_dir_exist "${profiles_dir}/${git_account_name}.${custom_profile}"
  assert_success
}

@test "./splinter update conda - expected to create/update ./conda directory" {
  run ./splinter update conda
  assert_output --partial 'Downloading Miniconda'
  assert_output --partial 'Upgrading PIP'
  assert_dir_exist "$conda_dir"
  assert_success
}

@test "./splinter update conda <invalid-argument> - expected to fail" {
  invalid_argument_test 'conda'
}

@test "./splinter update pyenv - expected to create/update ./pyenv directory" {
  run ./splinter update pyenv
  assert_output --partial 'Installing Pyenv Python'
  assert_output --partial 'Upgrading PIP'
  assert_dir_exist "$pyenv_dir"
  assert_success
}

@test "./splinter update pyenv <invalid-argument> - expected to fail" {
  invalid_argument_test 'pyenv'
}

@test "./splinter update galaxy - expected to create/update './ansile/roles/marcomc.splinter_toolkit' directory" {
  run ./splinter update galaxy
  assert_output --partial 'Installing Ansible Galaxy roles'
  assert_output --partial 'extracting marcomc.splinter_toolkit'
  assert_dir_exist "$splinter_toolkit_galaxy_role"
  assert_success
}

@test "./splinter update galaxy <invalid-argument> - expected to fail" {
  invalid_argument_test 'galaxy'
}

@test "./splinter update tools - expected to create/update './tools/*.sh' scripts" {
  run ./splinter update tools
  assert_output --partial 'Tools updated successfully'
  assert_file_exist "$tools_script_1"
  assert_file_exist "$tools_script_2"
  assert_success
}

@test "./splinter update tools <invalid-argument> - expected to fail" {
  invalid_argument_test 'tools'
}

@test "./splinter update deps - expected to update all tools with 'conda'" {
  run ./splinter update deps
  assert_output --partial 'Downloading Miniconda'
  assert_output --partial 'Upgrading PIP'
  assert_output --partial 'Installing Ansible Galaxy roles'
  assert_file_exist "$brew_tool"
  assert_dir_exist "$conda_dir"
  assert_dir_exist "$splinter_toolkit_galaxy_role"
  assert_success
}

@test "./splinter -e pyenv update deps - expected to update all tools with 'pyenv'" {
  run ./splinter -e pyenv update deps
  assert_output --partial 'Installing Pyenv Python'
  assert_output --partial 'Upgrading PIP'
  assert_output --partial 'Installing Ansible Galaxy roles'
  assert_file_exist "$brew_tool"
  assert_dir_exist "$pyenv_dir"
  assert_dir_exist "$splinter_toolkit_galaxy_role"
  assert_success
}

@test "./splinter update deps <invalid-argument> - expected to fail" {
  invalid_argument_test 'deps'
}

@test "./splinter update self - install the latest version of splinter" {
  run ./splinter update self
  assert_output --partial 'Updating Splinter'
  assert_output --partial 'Downloading Splinter'
  assert_output --partial 'Decompressing Splinter'
  assert_output --partial 'Installing Splinter files'
  assert_output --partial 'Update successful'
  assert_file_exist "splinter"
  assert_dir_exist "$tools_dir"
  assert_dir_exist "$profiles_dir"
  assert_dir_exist "$galaxy_dir"
  assert_success
}

@test "./splinter update self <invalid-argument> - expected to fail" {
  invalid_argument_test 'deps'
}
