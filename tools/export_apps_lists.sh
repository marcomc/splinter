#!/usr/bin/env bash
#
# TODO
# - Allow parameters to chose the Mackup storage engine/directory
#
#

EXPORT_HOMEBREW_PACKAGES=true
EXPORT_HOMEBREW_CASK=true
EXPORT_MAS_APPS=true
EXPORT_NPM_GLOBAL_PACKAGES=true
EXPORT_PIP_PACKAGES=false
MACKUP_BACKUP=false
MACPREFS_BACKUP=false

DESTINATION_DIR="../files"
HOMEBREW_TAPS_LIST_FILE="${DESTINATION_DIR}/homebrew_taps.txt"
HOMEBREW_PACKAGES_LIST_FILE="${DESTINATION_DIR}/homebrew_packages.txt"
HOMEBREW_CASK_APPS_LIST_FILE="${DESTINATION_DIR}/homebrew_cask_apps.txt"
MAS_APPS_LIST_FILE="${DESTINATION_DIR}/mas_apps.txt"
NPM_GLOBAL_PACKAGES_LIST_FILE="${DESTINATION_DIR}/npm_global_packages.json"
PIP_PACKAGES_LIST_FILE="${DESTINATION_DIR}/pip_packages.txt"
MACPREFS_BACKUP_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Macprefs"

if "${EXPORT_HOMEBREW_PACKAGES}" or "${EXPORT_HOMEBREW_CASK}"; then
  printf "Exporting Homebrew Taps list to %s..." "${HOMEBREW_TAPS_LIST_FILE}"
  brew tap-info --installed | grep -v -e '^$' | grep -v 'From\|files' | cut -d: -f1 > "${HOMEBREW_TAPS_LIST_FILE}"
  printf " done!\n"
fi

if "${EXPORT_HOMEBREW_PACKAGES}"; then
  printf "Exporting Homebrew Packages list to %s..." "${HOMEBREW_PACKAGES_LIST_FILE}"
  brew list | grep '^[0-9]' -v > "${HOMEBREW_PACKAGES_LIST_FILE}"
  printf " done!\n"
fi

if "${EXPORT_HOMEBREW_CASK}"; then
  printf "Exporting Homebrew Cask apps list to %s..." ${HOMEBREW_CASK_APPS_LIST_FILE}
  brew cask list | grep '^[0-9]' -v > "${HOMEBREW_CASK_APPS_LIST_FILE}"
  printf " done!\n"
fi

if "${EXPORT_MAS_APPS}"; then
  printf "Exporting MacAppStore apps list to %s..." "${MAS_APPS_LIST_FILE}"
  mas list | sed 's/ /,/' > "${MAS_APPS_LIST_FILE}"
  # returns list like:
  # ID,Name (version)
  # 402415186,GarageBuy (3.4)
  # ...
  printf " done!\n"
fi
if "${EXPORT_NPM_GLOBAL_PACKAGES}"; then
  printf "Exporting NPM Global packages list to %s..." ${NPM_GLOBAL_PACKAGES_LIST_FILE}
  npm list -g --depth=0 --json > "${NPM_GLOBAL_PACKAGES_LIST_FILE}"
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

if "${EXPORT_PIP_PACKAGES}"; then
  printf "Exporting PIP packages list to %s..." "${PIP_PACKAGES_LIST_FILE}"
  pip list -o --format freeze  2> /dev/null | sed 's/==/,/'  > "${PIP_PACKAGES_LIST_FILE}"
  # returns list like:
  # package==version
  # ...
  # printf " done!\n"
fi

if "${MACKUP_BACKUP}"; then
  if command -v mackup; then
    printf "Backing up dotfiles with mackup to %s..." "${PIP_PACKAGES_LIST_FILE}"
    mackup backup -f
    # use the configuration in ~/.mackup.cfg
    printf " done!\n"
  fi
fi

if "${MACPREFS_BACKUP}"; then
  if command -v macprefs; then
    #  Any preferences Mackup backs up won't be backed up by Macprefs
    printf "Backing up System Preferences with macprefs to %s..." "${MACPREFS_BACKUP_DIR}"
    sudo MACPREFS_BACKUP_DIR="${MACPREFS_BACKUP_DIR}" macprefs backup
    # use the env value of MACPREFS_BACKUP_DIR as a backup dir
    printf " done!\n"
  fi
fi
