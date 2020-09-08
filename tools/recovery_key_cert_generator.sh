#!/bin/bash

case "${1}" in
  '--help' )
    printf "Usage: %s [ KeychainName ]\n" "${0}"
    exit
  ;;
  '')
    KEYCHAIN_NAME="FileVaultMaster"
    ;;
  *)
    KEYCHAIN_NAME="${1}"
  ;;
esac

OUTPUT_DIR="${HOMEz}/Desktop"
KEYCHAIN_FILE="${OUTPUT_DIR}/${KEYCHAIN_NAME}.keychain"
KEYCHAIN_SECRET_OUTPUT="${OUTPUT_DIR}/${KEYCHAIN_NAME}_keychain_password.txt"
DER_CERT="${OUTPUT_DIR}/${KEYCHAIN_NAME}.der.cer"
KEYCHAIN_PASSWORD=""
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[39m"

function from_keychain_to_cert {
  eval ask_for_private_key_secret

  printf ">> %bCreate %s keychain%b\n" "${CYAN}" "${KEYCHAIN_FILE}" "${WHITE}"
  security create-filevaultmaster-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_FILE}"

  printf ">> %bExport DER certificate %s from %s keychain%b\n" "${CYAN}" "${DER_CERT}" "${KEYCHAIN_FILE}" "${WHITE}"
  security export -k "${KEYCHAIN_FILE}" -t certs -o "${DER_CERT}"
}

function ask_for_private_key_secret {
  if [ -z "${KEYCHAIN_PASSWORD}" ]; then
        printf ">> %bRequest the secret used to encript %b%s%b\n" "${CYAN}" "${YELLOW}" "${KEYCHAIN_FILE}" "${WHITE}"
        read -r -p ">> Insert your chosen secret: " -s KEYCHAIN_PASSWORD
        printf "\n"
        export KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD}"
        printf ">> %bKeychain password saved in %s%b\n" "${RED}" "${KEYCHAIN_SECRET_OUTPUT}" "${WHITE}"
        echo "${KEYCHAIN_PASSWORD}" > "${KEYCHAIN_SECRET_OUTPUT}"
        chmod 0600 "${KEYCHAIN_SECRET_OUTPUT}"
        printf ">> %bStore the keychain password in a safe place (i.e. Bitwarden, LastPass or 1Password)%b\n" "${YELLOW}" "${WHITE}"
        printf ">> %bthen delete the file %s%b\n" "${YELLOW}" "${KEYCHAIN_SECRET_OUTPUT}" "${WHITE}"
  else
        printf ">> %b'KEYCHAIN_PASSWORD' is already set%b\n" "${RED}" "${WHITE}"
  fi
}

if [ -f "${KEYCHAIN_FILE}" ];then
  printf ">> %b%s keychain file already exists!%b\n" "${YELLOW}" "${KEYCHAIN_FILE}" "${WHITE}"
  exit
else
  eval from_keychain_to_cert
  printf ">> %bOpen %s keychain for review\n%b" "${CYAN}" "${KEYCHAIN_NAME}" "${WHITE}"
  open "${KEYCHAIN_FILE}"
fi
open "${OUTPUT_DIR}"
