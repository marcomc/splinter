#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  export ANSIBLE_BECOME_PASS="password"
}

# function teardown {
#   if [[ -f $splinter_conda_package ]]; then rm -rf "$splinter_conda_package"; fi
# }

@test './splinter -v provision (no arguments)' {
  run ./splinter -v provision
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'failed=0'
  assert_success
}

# splinter -q provision
# splinter -v provision
# splinter -n conda provision
# splinter -n pyenv provision
# splinter -n none provision
# splinter provision <invalid-argumet>
# splinter provision -c file
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
