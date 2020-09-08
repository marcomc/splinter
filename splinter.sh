#!/usr/bin/env bash
DEPENDENCIES="
brew
pyenv
"
PIP_DEPENDECIES="
ansible
wheel
passlib
"
DESIRED_PASSLIB_VERSION='1.7.2'
DESIRED_WHEEL_VERSION='0.35.1'
DESIRED_ANSIBLE_VERSION='2.9.11'
DESIRED_PYTHON_VERSION='3.8.5'
PYENV_ROOT="pyenv"
PIP_CONFIG_FILE="${PYENV_ROOT}/pip.conf"
ANSIBLE_DIR="ansible"
ANSIBLE_PLAYBOOK='playbook.yml'
ANSIBLE_CONFIG="${ANSIBLE_DIR}/ansible.cfg"
ANSIBLE_REQUIREMENTS="${ANSIBLE_DIR}/requirements.yml"
ANSIBLE_ROLES="${ANSIBLE_DIR}/roles"
ANSIBLE_INVENTORY="${ANSIBLE_DIR}/inventory"
ANSINLE_FORCE_ROLES_UPDATE=''

SETUP_PROFILES_DIR='./profiles'
PIP_SHOW_GREP_FILTER='Version'  # 'Name\|Version\|Location' - it's a grep filter
RED="\e[31"
GREEN="\e[32m"
YELLOW="\e[33m"
PURPLE="\e[35m"
CYAN="\e[36m"
WHITE="\e[39m"
STAFF_GUID='20'
PAUSE_SECONDS='3'

function _echo {
  case ${2} in
    a|action)
      COLOUR="${CYAN}" #green
      TAG='ACTION.'
    ;;
    w|warning)
      COLOUR="${YELLOW}"
      TAG='WARNING'
      ;;
    e|error)
      COLOUR="${RED}"
      TAG='ERROR..'
      ;;
    r|remark)
      COLOUR="${PURPLE}" #green
      TAG='#######'
    ;;
    i|info|*)
      COLOUR="${GREEN}" #green
      TAG='INFO...'
    ;;
  esac
  printf "${COLOUR}[${TAG}] ${WHITE}%s\n" "${1}"
}

function show_usage (){
  printf "usage: %s [ options ] [ profile ]\n" "${0}"
  printf "options: \n"
  printf " -f|--force, Force Asnible to update all of the Galaxy roles dependencies\n"
  printf " -h|--help, Print help\n"
  printf " -l|--list, List available profiles\n"
  printf "\n"
  printf "Create your own profiles in the '%s' directory.\n" "${SETUP_PROFILES_DIR}"
  printf "\n"
  return 0
}

function print_execution_time {
  START_SECONDS="${1}"
  END_SECONDS=$(date +%s)
  TOTAL_SECONDS=$(( END_SECONDS - START_SECONDS ))
  TOTAL_MINUTES=$(( TOTAL_SECONDS / 60 ))

  if [[ ${TOTAL_MINUTES} -gt 0 ]]; then
    TOTAL="${TOTAL_MINUTES} minutes"
  else
    TOTAL="${TOTAL_SECONDS} seconds"
  fi
  _echo "Execution time was ${TOTAL}" 'r'
}

function check_command_line_parameters {
  case ${1} in
    -h|--help)
      eval show_usage
      exit
    ;;
    -f|--force)
      _echo "Will force Asnible to update all the Galaxy roles dependencies" 'w'
      ANSINLE_FORCE_ROLES_UPDATE='--force'
      ;;
    -l|--list)
      ls -1 './profiles/'
      exit
      ;;
    -*)
      echo "Error: option '${1}' not recogonised"
      eval show_usage
      exit
      ;;
    *)
      eval define_ansible_setup_profile "${1}"
      ;;
  esac
}

function check_install_path_permissions {
  CURRENT_PATH=$(pwd -P)
  THIRD_LEVEL_DIR=$(echo "${CURRENT_PATH}" | cut -d'/' -f-4)
  DIR_STATS=$(stat -f '%N %g %p' "${THIRD_LEVEL_DIR}")
  read -ra DIR_STATS <<< "${DIR_STATS}"
  DIR_NAME="${DIR_STATS[0]}"
  DIR_GROUP_ID="${DIR_STATS[1]}"
  DIR_PEMISSIONS="${DIR_STATS[2]:(-3)}"
  DIR_GROUP_PEMISSIONS="${DIR_STATS[2]:(-2):1}"

  if [[ "${CURRENT_PATH}" == "${HOME}"* ]]; then
    _echo 'You are running this script within your home directory' 'w'
    _echo 'Ansible might fail if your home directories are protected' 'w'
    _echo "(not allowing group memebers to 'read' AND 'exec' them)" 'w'
    _echo "Checking the permissions on the containing dir" 'a'
    _echo "DIR_NAME: ${DIR_NAME}"
    _echo "DIR_GROUP_ID: ${DIR_GROUP_ID}"
    _echo "DIR_PEMISSIONS: ${DIR_PEMISSIONS}"
    if [[ "${STAFF_GUID}" != "${DIR_GROUP_ID}" ]]; then
      _echo "The '${DIR_NAME}' group is not 'staff(${STAFF_GUID})'" 'w'
    elif [[ "${DIR_GROUP_PEMISSIONS}" -lt "5" || "${DIR_GROUP_PEMISSIONS}" -eq "6" ]]; then
      _echo "'${DIR_NAME}' does NOT allow the 'staff' group to 'read' AND 'exec'" 'w'
      _echo "(this might lead to issues during the execution of some Ansible tasks)" 'w'
      _echo "Will add POSIX 'g+rx' permissions to ${THIRD_LEVEL_DIR}" 'a'
      chmod g+rx "${THIRD_LEVEL_DIR}"
    fi
    _echo "Pausing for ${PAUSE_SECONDS} seconds for you to read the above message..." 'a'
    printf ">>>>>>>>> "
    for ((i=1; i<=PAUSE_SECONDS; i++)); do
      # running the countdown before resuming operations
      printf "..%s" "${i}"
      sleep 1
    done
    printf "\n" # add newline after the countdown
  fi
}

function define_ansible_setup_profile {
  if [ -z "${1}" ]; then
    # if the paramater is empty just keep going
    # ansible will only load default configs
    _echo "No profile name has been provides. Will use the values set in Ansible."
  elif [ -d "${SETUP_PROFILES_DIR}/${1}" ]; then
    export ANSIBLE_SETUP_PROFILE="${1}"
    _echo "Running setup for the profile '${ANSIBLE_SETUP_PROFILE}'" 'a'
  else
    echo "Error: the profile '${SETUP_PROFILES_DIR}/${1}' does not exist"
    exit
  fi
}

function enable_passwordless_sudo {
  SUDO_STDIN=''
  if sudo -n true 2>/dev/null; then
    _echo "Passwordless sudo is seems to be already available"
  else
    if [ -n "${ANSIBLE_BECOME_PASS}" ]; then
      SUDO_STDIN='--stdin'
    fi
    # Enable passwordless sudo for the macbuild run
    _echo "Enabling passwordless sudo for the macbuild run" 'a'
    echo "${ANSIBLE_BECOME_PASS}" | sudo "${SUDO_STDIN}" sed -i -e "s/^%admin (.*)ALL.*/%admin ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers >/dev/null 2>&1
  fi
}

function disable_passwordless_sudo {
  if sudo -n true 2>/dev/null; then
    # Enable passwordless sudo for the macbuild run
    _echo "Disabling passwordless sudo after the macbuild run" 'a'
    sudo sed -i -e "s/^%admin (.*)ALL.*/%admin ALL=(ALL) ALL/" /etc/sudoers
  else
    _echo "Passwordless sudo is disabled"
  fi
}

function install_pip_dependencies {
  for PIP_DEPENDECY in ${PIP_DEPENDECIES}; do
    if ! pip show "${PIP_DEPENDECY}" >/dev/null 2>&1; then
      _echo "${PIP_DEPENDECY} not installed" w
      eval "install_pip_${PIP_DEPENDECY}"
    else
      DEP_VERSION=$(pip show "${PIP_DEPENDECY}" | grep "${PIP_SHOW_GREP_FILTER}")
      _echo "${PIP_DEPENDECY} ${DEP_VERSION} is installed "
      # pip show "${PIP_DEPENDECY}" | grep "${PIP_SHOW_GREP_FILTER}"
    fi
  done
}

function install_dependencies {
  for COMMAND in ${DEPENDENCIES}; do
    if ! command -v "${COMMAND}" >/dev/null 2>&1; then
      _echo "${COMMAND} not installed" w
      eval "install_${COMMAND}"
    else
      DEP_VERSION=$(command -v "${COMMAND}")
      _echo "${COMMAND} ${DEP_VERSION} is installed"
      # command -v "${COMMAND}"
    fi
  done
}

function give_terminal_control_access {
  _echo "allow Terminal to control the computer" 'a'
  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
    "INSERT or REPLACE INTO access(service,client,client_type,allowed,prompt_count) VALUES('kTCCServiceAccessibility','com.apple.Terminal',0,1,1);"
}

function install_brew {
  # install homebrew
  _echo "Installing Homebrew" 'a'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" < /dev/null
}

function activate_pyenv {
  _echo "USING PROJECT'S OWN PYENV PYTHON VERSION" 'r'
  export PATH="${PYENV_ROOT}/shims:${PATH}"
  # _echo "PATH: ${PATH}"
  export PYENV_ROOT="${PYENV_ROOT}"
  _echo "PYENV_ROOT: ${PYENV_ROOT}"
  export PIP_CONFIG_FILE="${PIP_CONFIG_FILE}"
  _echo "PIP_CONFIG_FILE: ${PIP_CONFIG_FILE}"
  export PYENV_VERSION="${DESIRED_PYTHON_VERSION}"
  _echo "PYTHON_VERSION: $(pyenv version)"
}

function update_brew {
  _echo "Updating Homebrew" 'a'
  brew update
}

function install_pyenv {
  _echo "Installing Pyenv" 'a'
  # install pyenv with homebrew
  eval update_brew
  brew install pyenv
}

function install_pip_ansible {
  _echo "PIP - Installing Ansible ${DESIRED_ANSIBLE_VERSION}" 'a'
  pip install "ansible==${DESIRED_ANSIBLE_VERSION}"
  # pip show ansible | grep "${PIP_SHOW_GREP_FILTER}"
}

function install_pip_wheel {
  _echo "PIP - Installing Wheel ${DESIRED_WHEEL_VERSION}" 'a'
  pip install "wheel==${DESIRED_WHEEL_VERSION}"
  # pip show "wheel"  | grep "${PIP_SHOW_GREP_FILTER}"
}

function install_pip_passlib {
  _echo "PIP - Installing passlib ${DESIRED_PASSLIB_VERSION}" 'a'
  pip install "passlib==${DESIRED_PASSLIB_VERSION}"
  # pip show "passlib" | grep "${PIP_SHOW_GREP_FILTER}"
}

function install_pyenv_python {
  if ! pyenv versions | grep "${DESIRED_PYTHON_VERSION}" >/dev/null 2>&1; then
    # •	install python3 with pyenv
    _echo "Installing Pyenv Python ${DESIRED_PYTHON_VERSION}" 'a'
    pyenv install "${DESIRED_PYTHON_VERSION}"
    _echo "Fixing Pyenv shims ${DESIRED_PYTHON_VERSION}" 'a'
    pyenv rehash
  else
    _echo "Pyenv Python ${DESIRED_PYTHON_VERSION} is already installed"
  fi
}

function upgrade_pip {
  _echo "PYENV_ROOT: ${PYENV_ROOT}"
  _echo "Upgrading PIP to the latest version" 'a'
  pip install --upgrade pip
}

function install_ansible {
  if ! command -v 'ansible' >/dev/null 2>&1; then
    _echo "Ansible not installed" w
    eval install_pip_ansible
  else
    _echo "Ansible is already installed"
    ansible --version
  fi
}

function update_ansible_galaxy_roles {
  _echo "Updating Ansible Galaxy Roles" 'a'
  ansible-galaxy install -r ${ANSIBLE_REQUIREMENTS} -p ${ANSIBLE_ROLES} ${ANSINLE_FORCE_ROLES_UPDATE}
}

function run_ansible_playbook {
  export ANSIBLE_CONFIG="${ANSIBLE_CONFIG}"
  export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES}"
  export ANSIBLE_BECOME_PASS="${ANSIBLE_BECOME_PASS}"
  export PYENV_NAME="$PYENV_NAME"
  ansible-playbook ${ANSIBLE_PLAYBOOK} -i ${ANSIBLE_INVENTORY}
}

function ask_for_ansible_sudo_password {
  # temporarely store the password in cleartext in the environment
  # so it can be used by Ansible throughout the whole execution
  if [ -z "${ANSIBLE_BECOME_PASS}" ]; then
        _echo "Requesting the admin password to be used for 'sudo' throughout the deployment process" 'a'
        read -r -p ">>>>>>>>> Insert the current user password: " -s ANSIBLE_BECOME_PASS
        printf "\n"
  else
        _echo "'ANSIBLE_BECOME_PASS' is already set"
  fi
}

function main {
  START=$(date +%s)
  _echo "Starting time $( date )" 'r'
  eval ask_for_ansible_sudo_password
  eval enable_passwordless_sudo
  eval check_install_path_permissions
  eval print_execution_time "${START}"

  eval install_dependencies
  eval activate_pyenv
  eval install_pyenv_python
  eval upgrade_pip
  eval install_pip_dependencies
  eval update_ansible_galaxy_roles
  eval print_execution_time "${START}"

  eval run_ansible_playbook
  eval disable_passwordless_sudo
  _echo "Ending time $( date )" 'r'
  eval print_execution_time "${START}"
}

eval check_command_line_parameters "${@}"
eval main
