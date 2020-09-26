#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  pyenv_dir='./pyenv'
  conda_dir='./conda'
  default_package_name="SplinterProvision"
  default_dmg_package="${default_package_name}.dmg"
  default_zip_package="${default_package_name}.zip"

  custom_package_name="CustomName"
  custom_dmg_package="${custom_package_name}.dmg"
  custom_zip_package="${custom_package_name}.zip"
  custom_package_destination="$(mktemp -d)"

  export KEYCHAIN_PASSWORD='test-password'
  recovery_key_dir='files/certificates'
  recovery_key_name='FileVaultMaster'
  keychain_file="${recovery_key_dir}/${recovery_key_name}.keychain"
  der_cert="${recovery_key_dir}/${recovery_key_name}.der.cer"
  keychain_password_file="${recovery_key_dir}/${recovery_key_name}-keychain-password.txt"
}

function teardown {
  if [[ -f $default_dmg_package ]]; then rm "$default_dmg_package"; fi
  if [[ -f $default_zip_package ]]; then rm "$default_zip_package"; fi

  if [[ -f $custom_dmg_package ]]; then rm "$custom_dmg_package"; fi
  if [[ -f $custom_zip_package ]]; then rm "$custom_zip_package"; fi
  if [[ -d $custom_package_destination ]]; then rm -rf "$custom_package_destination"; fi

  if [[ -d $recovery_key_dir ]]; then rm -rf "$recovery_key_dir"; fi

  if [[ -d $pyenv_dir ]]; then rm -rf "$pyenv_dir"; fi
  if [[ -d $conda_dir ]]; then rm -rf "$conda_dir"; fi
}


@test './splinter --env none create <missing-argument> - expected to fail' {
  run ./splinter --env none create
  assert_output --partial '[Error]'
  assert_failure
}

@test './splinter --env none create <invalid-argument> - expected to fail' {
  run ./splinter --env none create 'invalid-argument'
  assert_output --partial 'Error'
  assert_failure
}

@test './splinter --env none create package - expected to create "SplinterProvision.dmg"' {
  run ./splinter --env none create package
  assert_output --partial 'created successfully'
  assert_file_exist "$default_dmg_package"
  assert_success
}

@test './splinter --env none create package -n CustomName - expected to create "CustomName.dmg"' {
  run ./splinter --env none create package -n "$custom_package_name"
  assert_output --partial 'created successfully'
  assert_file_exist "$custom_dmg_package"
  assert_success
}

@test './splinter --env none create package -n <missing-argument> - expected to fail' {
  run ./splinter --env none create package -n
  assert_output --partial 'Error'
  assert_failure
}

@test './splinter --env none create package -d /custom/path - expected to create "/custom/path/SplinterProvision.dmg"' {
  run ./splinter --env none create package -d "$custom_package_destination"
  assert_output --partial 'created successfully'
  assert_file_exist "${custom_package_destination}/${default_dmg_package}"
  assert_success
}

@test './splinter --env none create package -d invalid/path - expected to fail' {
  run ./splinter --env none create package -d '/invalid/path/to/nowhere'
  assert_output --partial 'Cannot find the destination directory'
  assert_failure
}

@test './splinter --env none create package -t dmg - expected to create "SplinterProvision.dmg"' {
  run ./splinter --env none create package -t dmg
  assert_output --partial 'created successfully'
  assert_file_exist "$default_dmg_package"
  assert_success
}

@test './splinter --env none create package -t zip - expected to create "SplinterProvision.zip"' {
  run ./splinter --env none create package -t zip
  assert_output --partial 'created successfully'
  assert_file_exist "$default_zip_package"
  assert_success
}

@test './splinter --env none create package -t <missing-argument> - expected to fail' {
  run ./splinter --env none create package -t
  assert_output --partial 'Error'
  assert_failure
}

@test './splinter -n CustomName -t zip -d /custom/path - expected to create "/custom/path/SplinterProvision.zip"' {
  run ./splinter --env none create package -n "$custom_package_name" -t zip -d "$custom_package_destination"
  assert_output --partial 'created successfully'
  assert_dir_exist  "$custom_package_destination"
  assert_file_exist "${custom_package_destination}/${custom_zip_package}"
  assert_success
}

@test './splinter create filevault-recovery-key - expected to create keychain, DER and password files in ./certificates' {
  run ./splinter update tools # required to install filevault-recovery-key-generator.sh
  run ./splinter create filevault-recovery-key
  assert_output --partial 'created successfully'
  assert_dir_exist  "$recovery_key_dir"
  assert_file_exist "$keychain_file"
  assert_file_exist "$der_cert"
  assert_file_exist "$keychain_password_file"
  assert_success
}
