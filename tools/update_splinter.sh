#!/usr/bin/env bash

set -u

splinter_zip="splinter.zip"
splinter_archive="https://github.com/marcomc/splinter/archive/master.zip"
splinter_script="splinter"

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

temp_dir=$(mktemp -d)
current_dir=${PWD##*/}

case $current_dir in
  splinter)
    splinter_dir="."
  ;;
  *)
    splinter_dir=".."
  ;;
esac

if [ ! -f "${splinter_dir}/${splinter_script}" ];then
  abort "$(printf "It looks like Splinter '%s' is not part of a splinter installation!" "$(shell_join "${PWD}")")"
fi

echo "Downloading Splinter in to '${temp_dir}/${splinter_zip}'..."
execute "curl" "-fsSL" "${splinter_archive}" "-o" "${temp_dir}/${splinter_zip}"

echo "Decompressing Splinter archive in to '${temp_dir}'..."
execute "unzip" "-qq" "${temp_dir}/${splinter_zip}" "-d" "${temp_dir}"
ls "${temp_dir}"

echo "Updating Splinter files to '${splinter_dir}'..."
execute "rsync" "-rlWuv" "${temp_dir}"/*/* "${splinter_dir}"

echo "Removing temporary files..."
execute "rm" "-rf" "${temp_dir}"

echo "Update successful!"
