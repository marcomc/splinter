#!/usr/bin/env bash
#
# TODO
# - Allow parameters to chose the Mackup storage engine/directory
#
#

export_homebrew_packages=true
export_homebrew_cask=true
export_mas_apps=true
export_npm_global_packages=true
export_pip_packages=false
mackup_backup=false
macprefs_backup=false

destination_dir="../files"
homebrew_taps_list_file="${destination_dir}/homebrew_taps.txt"
homebrew_packages_list_file="${destination_dir}/homebrew_packages.txt"
homebrew_cask_apps_list_file="${destination_dir}/homebrew_cask_apps.txt"
mas_apps_list_file="${destination_dir}/mas_apps.txt"
npm_global_packages_list_file="${destination_dir}/npm_global_packages.json"
pip_packages_list_file="${destination_dir}/pip_packages.txt"
macprefs_backup_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Macprefs"

if "${export_homebrew_packages}" or "${export_homebrew_cask}"; then
  printf "Exporting Homebrew Taps list to %s..." "${homebrew_taps_list_file}"
  brew tap-info --installed | grep -v -e '^$' | grep -v 'From\|files' | cut -d: -f1 > "${homebrew_taps_list_file}"
  printf " done!\n"
fi

if "${export_homebrew_packages}"; then
  printf "Exporting Homebrew Packages list to %s..." "${homebrew_packages_list_file}"
  brew list | grep '^[0-9]' -v > "${homebrew_packages_list_file}"
  printf " done!\n"
fi

if "${export_homebrew_cask}"; then
  printf "Exporting Homebrew Cask apps list to %s..." ${homebrew_cask_apps_list_file}
  brew cask list | grep '^[0-9]' -v > "${homebrew_cask_apps_list_file}"
  printf " done!\n"
fi

if "${export_mas_apps}"; then
  printf "Exporting MacAppStore apps list to %s..." "${mas_apps_list_file}"
  mas list | sed 's/ /,/' > "${mas_apps_list_file}"
  # returns list like:
  # ID,Name (version)
  # 402415186,GarageBuy (3.4)
  # ...
  printf " done!\n"
fi
if "${export_npm_global_packages}"; then
  printf "Exporting NPM Global packages list to %s..." ${npm_global_packages_list_file}
  npm list -g --depth=0 --json > "${npm_global_packages_list_file}"
  # returns list like:
  # {
  #   "dependencies": {
  #     "gulp": {
  #       "version": "4.0.2",
  #       "from": "gulp@latest",
  #       "resolved": "https://registry.npmjs.org/gulp/-/gulp-4.0.2.tgz"
  #     },
  #     ""yarn"": {
  #       ...
  #     }
  #   }
  # }
  printf " done!\n"
fi

if "${export_pip_packages}"; then
  printf "Exporting PIP packages list to %s..." "${pip_packages_list_file}"
  pip list -o --format freeze  2> /dev/null | sed 's/==/,/'  > "${pip_packages_list_file}"
  # returns list like:
  # package==version
  # ...
  # printf " done!\n"
fi

if "${mackup_backup}"; then
  if command -v mackup; then
    printf "Backing up dotfiles with mackup to %s..." "${pip_packages_list_file}"
    mackup backup -f
    # use the configuration in ~/.mackup.cfg
    printf " done!\n"
  fi
fi

if "${macprefs_backup}"; then
  if command -v macprefs; then
    #  Any preferences Mackup backs up won't be backed up by Macprefs
    printf "Backing up System Preferences with macprefs to %s..." "${macprefs_backup_dir}"
    sudo macprefs_backup_dir="${macprefs_backup_dir}" macprefs backup
    # use the env value of macprefs_backup_dir as a backup dir
    printf " done!\n"
  fi
fi
