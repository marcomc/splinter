#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  base_profile_example="./profiles/base-example"
  base_profile="./profiles/base"
  example_splinter_config="example-splinter.cfg"
}

function teardown {
  if [[ -d $base_profile ]]; then rm -rf "$base_profile"; fi
  for user in newuser utonto; do
    if [[ -d /Users/$user ]]; then
      sudo /usr/bin/dscl . -delete "/Users/$user"
      sudo rm -rf "/Users/$user"
    fi
  done
}

@test './splinter provision (no base profile)' {
  run ./splinter provision
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter -v provision (verbos, no base profile)' {
  run ./splinter -v provision
  assert_output --partial '[INFO....]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'failed=0'
  assert_success
}

@test './splinter -q provision (quite, no base profile)' {
  run ./splinter -q provision
  refute_output --partial '[SPLINTER]'
  refute_output --partial '[ACTION..]'
  refute_output --partial '[INFO....]'
  refute_output --partial 'Running Ansible provisioning'
  assert_output --partial 'failed=0'
  assert_output --partial 'PLAY'
  assert_success
}

@test './splinter provision (with base profile)' {
  if [[ -d $base_profile_example ]]; then
    cp -a "$base_profile_example" "$base_profile"
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

@test './splinter provision <invalid-argument> - expected to fail' {
  run ./splinter provision 'invalid-argument'
  assert_output --partial 'Provided unknow parameter'
  assert_failure
}

@test "./splinter provision -c example-config.cfg - expected to create the user 'newuser'" {
  if [[ -d $base_profile_example ]]; then
    cp -a "$base_profile_example" "$base_profile"
  fi
  run ./splinter provision -c "$example_splinter_config"
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'Creating user "newuser"'
  assert_output --partial 'failed=0'
  assert_success
}

@test "splinter provision -c ./splinter/example-config.cfg - running from outside the project folder expected to create the user 'newuser'" {
  PATH=$(pwd):"$PATH"
  if [[ -d $base_profile_example ]]; then
    cp -a "$base_profile_example" "$base_profile"
  fi
  cd ..
  run splinter provision -c "./splinter/$example_splinter_config"
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'Creating user "newuser"'
  assert_output --partial 'failed=0'
  assert_success
}

@test "./splinter provision -u utonto -f 'U Tonto' -p <missing-argument> - expected to fail" {
  run ./splinter provision -u utonto -f 'U\ tonto' -p
  assert_output --partial 'missing an argument'
  assert_failure
}

@test "./splinter provision -u utonto -f 'U\ Tonto' -p password -t utonto -h Computer-Name - expected to create the user 'utonto'" {
  if [[ -d $base_profile_example ]]; then
    cp -a "$base_profile_example" "$base_profile"
  fi
  run ./splinter provision -u utonto -f 'U\ tonto' -p 'password' -t utonto -h Computer-Name
  assert_output --partial '[SPLINTER]'
  assert_output --partial '[ACTION..]'
  assert_output --partial 'Running Ansible provisioning'
  assert_output --partial 'PLAY'
  assert_output --partial 'Creating user "utonto"'
  assert_output --partial 'failed=0'
  assert_success
}
