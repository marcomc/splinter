#!/usr/bin/env bash

set -u

splinter_dir="splinter"
splinter_zip="${splinter_dir}.zip"
splinter_archive="https://github.com/marcomc/splinter/archive/master.zip"
default_profile="default"
default_profile_example="default-example"
config_file="config.yml"
config_file_example="config-example.yml"

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

if [ -d "${splinter_dir}" ];then
  echo "Removing existing directory '${splinter_dir}' if empty"
  execute "rmdir" "${splinter_dir}"
  # abort "$(printf "Failed directory %s already exists!" "$(shell_join "${splinter_dir}")")"
fi

temp_dir=$(mktemp -d)

echo "Downloading Splinter in to '${temp_dir}/${splinter_zip}'..."
execute "curl" "-fsSL" "${splinter_archive}" "-o" "${temp_dir}/${splinter_zip}"

echo "Decompressing Splinter archive in to '${temp_dir}'..."
execute "unzip" "-qq" "${temp_dir}/${splinter_zip}" "-d" "${temp_dir}"
ls "${temp_dir}"

echo "Moving Splinter files to '${splinter_dir}'..."
execute "mkdir" "-p" "${splinter_dir}"
execute "mv" "${temp_dir}"/*/* "${splinter_dir}"

echo "Creating config file 'config.yml'..."
execute "cp" "-a" "${splinter_dir}/${config_file_example}" "${splinter_dir}/${config_file}"

echo "Creating profile 'default'..."
execute "cp" "-a" "${splinter_dir}/profiles/${default_profile_example}" "${splinter_dir}/profiles/${default_profile}"

echo "Removing temporary files..."
execute "rm" "-rf" "${temp_dir}"

echo "Installation successful!"

if [[ "$(uname)" = "Darwin" ]] && [[ -d "${splinter_dir}" ]]; then
  execute "open" "${splinter_dir}"
fi
