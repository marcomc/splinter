#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  export ANSIBLE_BECOME_PASS="password"
  default_profile_example="./profiles/default-example"
  default_profile="./profiles/default"
  example_splinter_config="example-splinter.cfg"
}

function teardown {
  if [[ -d $default_profile ]]; then rm -rf "$default_profile"; fi
}

@test './splinter provision (no default profile)' {
  run ./splinter provision
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter -v provision (verbos, no default profile)' {
  run ./splinter -v provision
  assert_output --partial '[INFO....]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter -q provision (quite, no default profile)' {
  run ./splinter provision
  refute_output --partial '[SPLINTER]'
  refute_output --partial '[ACTION..]'
  refute_output --partial '[INFO....]'
  refute_output --partial 'Running Ansible provisioning'
  assert_output --partial 'failed=0'
  assert_output --partial 'PLAY'
  assert_success
}

@test './splinter provision (with default profile)' {
  if [[ -d $default_profile_example ]]; then
    cp -a "$default_profile_example" "$default_profile"
  fi
  run ./splinter provision
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter -e conda provision' {
  run ./splinter -e conda provision
  assert_output --partial 'MINICONDA PYTHON'
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter -e pyenv provision' {
  run ./splinter -e pyenv provision
  assert_output --partial 'PYENV PYTHON'
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter provision <invalid-argument>' {
  run ./splinter provision 'invalid-argument'
  assert_output --partial 'Provided unknow parameter'
  assert_failure
}

@test './splinter provision -c example-config.cfg' {
  if [[ -d $default_profile_example ]]; then
    cp -a "$default_profile_example" "$default_profile"
  fi
  run ./splinter provision -c "$example_splinter_config"
  assert_output --partial 'PYENV PYTHON'
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'Creating user "newuser"'
  assert_output --partial 'failed=0'
  assert_success
}

# splinter provision -u username -f 'Full Name' -p 'cleartext password' -t username -h Computer-Name
#
#
# VERBOSE
# ANSIBLE_BECOME_PASS
# SPLINTER_BASE_PROFILE
# SPLINTER_ROLE_PROFILE
# NEW_USER_USERNAME
# NEW_USER_FULL_NAME
# NEW_USER_PASSWORD_CLEARTEXT
# CREATE_NEW_USER
# COMPUTER_HOST_NAME
# TARGET_USER_ID
# SPLINTER_PROJECT_DIR
