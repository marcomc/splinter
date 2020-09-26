#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  export ANSIBLE_BECOME_PASS="password"
}

# function teardown {
#   if [[ -f $splinter_conda_package ]]; then rm -rf "$splinter_conda_package"; fi
# }

@test './splinter provision -v (no arguments)' {
  run ./splinter provision -v
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'failed=0'
  assert_success
}

#
# provision -v
# provision -c file
# provision -u username -f 'Full Name' -p 'cleartext password' -t username -h Computer-Name
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
