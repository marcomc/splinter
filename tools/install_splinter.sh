#!/usr/bin/env bash

set -u

SPLINTER_DIR="splinter"
SPLINTER_ZIP="${SPLINTER_DIR}.zip"
SPLINTER_ARCHIVE="https://github.com/marcomc/splinter/archive/master.zip"
DEFAULT_PROFILE="default"
DEFAULT_PROFILE_EXAMPLE="default-example"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

abort() {
  printf "%s\n" "$1"
  exit 1
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

if [ -d "${SPLINTER_DIR}" ];then
  echo "Removing existing directory '${SPLINTER_DIR}' if empty"
  execute "rmdir" "${SPLINTER_DIR}"
  # abort "$(printf "Failed directory %s already exists!" "$(shell_join "${SPLINTER_DIR}")")"
fi

TEMP_DIR=$(mktemp -d)

echo "Downloading Splinter in to '${TEMP_DIR}/${SPLINTER_ZIP}'..."
execute "curl" "-fsSL" "${SPLINTER_ARCHIVE}" "-o" "${TEMP_DIR}/${SPLINTER_ZIP}"

echo "Decompressing Splinter archive in to '${TEMP_DIR}'..."
execute "unzip" "-qq" "${TEMP_DIR}/${SPLINTER_ZIP}" "-d" "${TEMP_DIR}"
ls "${TEMP_DIR}"

echo "Moving Splinter files to '${SPLINTER_DIR}'..."
execute "mkdir" "-p" "${SPLINTER_DIR}"
execute "mv" "${TEMP_DIR}"/*/* "${SPLINTER_DIR}"

echo "Create default profile..."
execute "cp" "-a" "${SPLINTER_DIR}/profiles/${DEFAULT_PROFILE_EXAMPLE}" "${SPLINTER_DIR}/profiles/${DEFAULT_PROFILE}"
execute "mv" "${TEMP_DIR}"/*/* "${SPLINTER_DIR}"

echo "Removing temporary files..."
execute "rm" "-rf" "${TEMP_DIR}"

echo "Installation successful!"

if [[ "$(uname)" = "Darwin" ]] && [[ -d "${SPLINTER_DIR}" ]]; then
  execute "open" "${SPLINTER_DIR}"
fi
