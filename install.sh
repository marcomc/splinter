#!/usr/bin/env bash

set -u

SPLINTER_DIR="splinter"
SPLINTER_REPO="https://github.com/marcomc/splinter"

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
  abort "$(printf "Failed directory %s already exists!" "$(shell_join "${SPLINTER_DIR}")")"
fi

echo "Downloading Splinter in to '${SPLINTER_DIR}'..."
# we do it in four steps to avoid merge errors when reinstalling
execute "git" "clone" "-q" "${SPLINTER_REPO}" || exit 1
# remove .git dir
cd "${SPLINTER_DIR}" || exit
rm -rf '.git' || exit
echo "Installation successful!"

if [[ "$(uname)" = "Darwin" ]]; then
  open "${SPLINTER_DIR}"
fi
