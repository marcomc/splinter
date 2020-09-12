#!/bin/bash

case "${1}" in
  '--help' )
    printf "Usage: %s [ KeychainName ]\n" "${0}"
    exit
  ;;
  '')
    keychain_name="FileVaultMaster"
    ;;
  *)
    keychain_name="${1}"
  ;;
esac

output_dir="${HOME}/Desktop"
keychain_file="${output_dir}/${keychain_name}.keychain"
keychain_secret_output="${output_dir}/${keychain_name}_keychain_password.txt"
der_cert="${output_dir}/${keychain_name}.der.cer"
keychain_password=""
red="\e[31m"
yellow="\e[33m"
cyan="\e[36m"
white="\e[39m"

function from_keychain_to_cert {
  eval ask_for_private_key_secret

  printf ">> %bCreate %s keychain%b\n" "${cyan}" "${keychain_file}" "${white}"
  security create-filevaultmaster-keychain -p "${KEYCHAIN_PASSWORD}" "${keychain_file}"

  printf ">> %bExport DER certificate %s from %s keychain%b\n" "${cyan}" "${der_cert}" "${keychain_file}" "${white}"
  security export -k "${keychain_file}" -t certs -o "${der_cert}"
}

function ask_for_private_key_secret {
  if [ -z "${KEYCHAIN_PASSWORD}" ]; then
        printf ">> %bRequest the secret used to encript %b%s%b\n" "${cyan}" "${yellow}" "${keychain_file}" "${white}"
        read -r -p ">> Insert your chosen secret: " -s keychain_password
        printf "\n"
        export KEYCHAIN_PASSWORD="${keychain_password}"
        printf ">> %bKeychain password saved in %s%b\n" "${red}" "${keychain_secret_output}" "${white}"
        echo "${KEYCHAIN_PASSWORD}" > "${keychain_secret_output}"
        chmod 0600 "${keychain_secret_output}"
        printf ">> %bStore the keychain password in a safe place (i.e. Bitwarden, LastPass or 1Password)%b\n" "${yellow}" "${white}"
        printf ">> %bthen delete the file %s%b\n" "${yellow}" "${keychain_secret_output}" "${white}"
  else
        printf ">> %b'KEYCHAIN_PASSWORD' is already set%b\n" "${red}" "${white}"
  fi
}

if [ -f "${keychain_file}" ];then
  printf ">> %b%s keychain file already exists!%b\n" "${yellow}" "${keychain_file}" "${white}"
  exit
else
  eval from_keychain_to_cert
  printf ">> %bOpen %s keychain for review\n%b" "${cyan}" "${keychain_name}" "${white}"
  open "${keychain_file}"
fi
open "${output_dir}"
