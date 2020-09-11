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

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

echo "Downloading Splinter in to '${SPLINTER_DIR}'..."
(
  # we do it in four steps to avoid merge errors when reinstalling
  execute "git" "clone" "-q" "${SPLINTER_REPO}"

  # remove .git dir
  cd "${SPLINTER_DIR}" || exit
  rm -rf '.git' || exit
)

echo "Installation successful!"

if [[ "$(uname)" = "Darwin" ]]; then
  open "${SPLINTER_DIR}"
fi
