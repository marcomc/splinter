#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
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
}

@test './splinter is executable' {
  assert_file_executable './splinter'
}
# 
# @test './splinter create <missing-argument>' {
#   run ./splinter create
#   assert_output --partial '[Error]'
# }
#
# @test './splinter create <invalid-argument>' {
#   run ./splinter create 'invalid-argument'
#   assert_output --partial 'Error'
# }
#
# @test './splinter create package' {
#   run ./splinter create package
#   assert_output --partial 'created successfully'
#   assert_file_exist "$default_dmg_package"
# }
#
# @test "./splinter create package -n CustomName" {
#   run ./splinter create package -n "$custom_package_name"
#   assert_output --partial 'created successfully'
#   assert_file_exist "$custom_dmg_package"
# }
#
# @test './splinter create package -n <missing-argument>' {
#   run ./splinter create package -n
#   assert_output --partial 'Error'
# }
#
# @test './splinter create package -d custom/path/to/directory' {
#   run ./splinter create package -d "$custom_package_destination"
#   assert_output --partial 'created successfully'
#   assert_file_exist "${custom_package_destination}/${default_dmg_package}"
# }
#
# @test './splinter create package -d invalid/path' {
#   run ./splinter create package -d '/invalid/path/to/nowhere'
#   assert_output --partial 'Cannot find the destination directory'
# }
#
# @test './splinter create package -t dmg' {
#   run ./splinter create package -t dmg
#   assert_output --partial 'created successfully'
#   assert_file_exist "$default_dmg_package"
# }

@test './splinter create package -t zip' {
  run ./splinter create package -t zip
  assert_output --partial 'created successfully'
  assert_file_exist "$default_zip_package"
}

@test './splinter create package -t <missing-argument>' {
  run ./splinter create package -t
  assert_output --partial 'Error'
}

@test './splinter -n CustomName -t zip -d path/to/custom/directory' {
  run ./splinter create package -n "$custom_package_name" -t zip -d "$custom_package_destination"
  assert_output --partial 'created successfully'
  assert_dir_exist  "$custom_package_destination"
  assert_file_exist "${custom_package_destination}/${custom_zip_package}"
}

@test './splinter create filevault-recovery-key' {
  run ./splinter update tools # required to install filevault-recovery-key-generator.sh
  run ./splinter create filevault-recovery-key
  assert_output --partial 'created successfully'
  assert_dir_exist  "$recovery_key_dir"
  assert_file_exist "$keychain_file"
  assert_file_exist "$der_cert"
  assert_file_exist "$keychain_password_file"
}
