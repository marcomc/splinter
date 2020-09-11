#!/usr/bin/env bash
START_TIME=$(date +%s)
TOOLS_DEPENDENCIES="
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
DESIRED_ANSIBLE_VERSION='2.9.13'
DESIRED_PYTHON_VERSION='3.8.5'
PYTHON_PROVIDER="conda"
PYENV_ROOT="pyenv"
CONDA_DIR="conda"
CONDA_PACKAGE_NAME="splinter-conda.tar.gz"
CONDA_PACKAGE_VERSION="v0.1"
CONDA_PACKAGE_URL="https://github.com/marcomc/splinter-conda/releases/download/${CONDA_PACKAGE_VERSION}/${CONDA_PACKAGE_NAME}"
CONDA_PACKAGE_PATH="files/${CONDA_PACKAGE_NAME}"
PIP_CONFIG_FILE="pip.conf"
ANSIBLE_DIR="ansible"
ANSIBLE_PLAYBOOK='playbook.yml'
ANSIBLE_CONFIG="${ANSIBLE_DIR}/ansible.cfg"
ANSIBLE_REQUIREMENTS="${ANSIBLE_DIR}/requirements.yml"
ANSIBLE_ROLES="${ANSIBLE_DIR}/roles"
ANSIBLE_INVENTORY="${ANSIBLE_DIR}/inventory"
ANSINLE_FORCE_ROLES_UPDATE=''

SETUP_PROFILES_DIR='./profiles'
PIP_SHOW_GREP_FILTER='Version'  # 'Name\|Version\|Location' - it's a grep filter
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
PURPLE="\e[35m"
CYAN="\e[36m"
WHITE="\e[39m"
STAFF_GUID='20'
PAUSE_SECONDS='3'

function _echo {
  MESSAGE_TYPE=""
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
      MESSAGE_TYPE="info"
      COLOUR="${GREEN}" #green
      TAG='INFO...'
    ;;
  esac
  if [ "${VERBOSE}" == "yes" ] || [ "${MESSAGE_TYPE}" != "info" ];then
    printf "${COLOUR}[${TAG}] ${WHITE}%s\n" "${1}"
  fi
}

function show_usage (){
  printf "usage: %s [option] action [object] [settings]\n" "${0}"
  printf "options: \n"
  printf "       -e|--env conda|pyenv, List available profiles\n"
  printf "       -h|--help, Print help\n"
  printf "actions: \n"
  printf "       list, List available profiles\n"
  printf "       provision [settings], Provision the host\n"
  printf "       update <object>, Update the object\n"
  printf "\n"
  printf "obejcts: \n"
  printf "       deps|dependencies, update all the dependency tools (PIP, Ansible Galaxy role)\n"
  printf "       self|auto, Update Splinter itself (not yet implemented!)\n"
  printf "\n"
  printf "settings: \n"
  printf "       -c file, Specify a custom configuration file\n"
  printf "       -b base_profile_name, Specify the the BASE profile to be used (default: 'default')\n"
  printf "       -r role_profile_name, Specify the the ROLE profile to be used\n"
  printf "       -u username, New user username (all lowercase, without spaces)\n"
  printf "       -f 'Full Name', New user full name (quoted if has blank spaces)\n"
  printf "       -p 'clear text password', New user's password in cleartext (quoted if has blank spaces)\n"
  printf "       -h 'Computer Name', Computer host name (quoted if has blank spaces)\n"

  printf "       -v, Produce verbose output\n"
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
  VERBOSE='no'
  NEW_USER_USERNAME=""  # Default to empty package
  NEW_USER_PASSWORD_CLEARTEXT="password"  # Default to empty target
  NEW_USER_FULL_NAME="New User"
  COMPUTER_HOST_NAME=""
  ANSIBLE_BASE_PROFILE=""
  ANSIBLE_SETUP_PROFILE=""
  # Parse options to the `install` command
  case "${1}" in
    -e|--env )
      PYTHON_PROVIDER="${2}"
      export PYTHON_PROVIDER="${PYTHON_PROVIDER}"
      _echo "PYTHON_PROVIDER: ${PYTHON_PROVIDER}"
      shift 2
      ;;
    -h|--help )
      eval show_usage
      exit 0
      ;;
    -*)
      _echo "Invalid option: ${1}" 'e' 1>&2
      eval show_usage
      exit 1
      ;;
  esac

  ACTION="${1}";
  _echo "ACTION: ${ACTION}"
  case "$ACTION" in
    list )
      ACTION_OPTION=$2; # fetch the action's option
      # Process package options
      _echo "OPTION: ${ACTION_OPTION}"
      case ${ACTION_OPTION} in
        profiles )
          find "${SETUP_PROFILES_DIR}"  -maxdepth 1 -mindepth 1 -type directory
          exit 0
          ;;
        '')
          _echo "Missing option for action '${ACTION}'" 'e' 1>&2
          eval show_usage
          exit 1
          ;;
        *)
          _echo "Incorrect option '${ACTION_OPTION}' for action '${ACTION}'" 'e' 1>&2
          eval show_usage
          exit 1
          ;;
      esac
      ;;
    # Parse options to the install sub command
    update)
      ACTION_OPTION="${2}";# fetch the action's option
      # Process package options
      export VERBOSE='yes' # `update` will always be verbose
      _echo "OPTION: ${ACTION_OPTION}"
      case ${ACTION_OPTION} in
        deps|dependencies )
          _echo "Will force Asnible to update all the Galaxy roles dependencies" 'w'
          ANSINLE_FORCE_ROLES_UPDATE='--force'
          eval install_dependencies
          exit 0
          ;;
        self)
          _echo "Option not yet implemented for action '${ACTION}'" 'e' 1>&2
          eval show_usage
          exit 1
          ;;
        '')
          _echo "Missing option for action '${ACTION}'" 'e' 1>&2
          eval show_usage
          exit 1
          ;;
        *)
          _echo "Incorrect option '${ACTION_OPTION}' for action '${ACTION}'" 'e' 1>&2
          eval show_usage
          exit 1
          ;;
      esac
      ;;
    provision )
      shift
      while getopts ":c:b:f:h:p:r:u:v" ACTION_OPTION; do
        case "${ACTION_OPTION}" in
          c)
            export CUSTOM_CONFIG_FILE="${OPTARG}"
            _echo "CUSTOM_CONFIG_FILE: ${CUSTOM_CONFIG_FILE}"
            ;;
          b)
            if ansible_profile_is_available "${OPTARG}" 2>/dev/null ; then
              export ANSIBLE_BASE_PROFILE="${OPTARG}"
              _echo "ANSIBLE_BASE_PROFILE: ${ANSIBLE_BASE_PROFILE}"
            fi
            ;;
          f)
            export NEW_USER_FULL_NAME="${OPTARG}"
            _echo "NEW_USER_FULL_NAME: '${NEW_USER_FULL_NAME}'"
            ;;
          h)
            export COMPUTER_HOST_NAME="${OPTARG}"
            _echo "COMPUTER_HOST_NAME: ${COMPUTER_HOST_NAME}"
            ;;
          p)
            export NEW_USER_PASSWORD_CLEARTEXT="${OPTARG}"
            _echo "NEW_USER_PASSWORD_CLEARTEXT: ${NEW_USER_PASSWORD_CLEARTEXT}"
            ;;
          r)
            if ansible_profile_is_available "${OPTARG}" 2>/dev/null; then
              export ANSIBLE_SETUP_PROFILE="${OPTARG}"
              _echo "ANSIBLE_SETUP_PROFILE: ${ANSIBLE_SETUP_PROFILE}"
            fi
            ;;
          u)
            export NEW_USER_USERNAME="${OPTARG}"
            _echo "NEW_USER_USERNAME: ${NEW_USER_USERNAME}"
            ;;
          v)
            export VERBOSE='yes'
            _echo "VERBOSE: ${VERBOSE}"
            ;;
          \?)
             _echo "Action '${ACTION}': Invalid option '-${OPTARG}'" 'e' 1>&2
             eval show_usage
             exit 1
             ;;
          :)
            _echo "Action '${ACTION}': option '-${OPTARG}' is missing an argument" 'e' 1>&2
            eval show_usage
            exit 1
            ;;
        esac
      done

      shift $(( OPTIND - 1 ))
      if [[ -n "${*}" ]];then
        # if it is NOT empty it means it interrupted before evaluating all the parameters
        # becaue it encountered a unexpected param or arg
        _echo "Provided unknow parameter: ${1}" 'e'
        eval show_usage
        exit 1
      fi
      eval main
      ;;
    '')
      _echo "Missing action" 'e' 1>&2
      eval show_usage
      exit 1
      ;;
    *)
      _echo "Invalid action '$ACTION'" 'e' 1>&2
      eval show_usage
      exit 1
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
      _echo "Adding POSIX 'g+rx' permissions to ${THIRD_LEVEL_DIR}" 'a'
      chmod g+rx "${THIRD_LEVEL_DIR}"
      export ORIGINAL_DIR_PEMISSIONS="${DIR_PEMISSIONS}"
      export THIRD_LEVEL_DIR="${THIRD_LEVEL_DIR}"
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

function restore_path_permissions {
  if [ -n "${ORIGINAL_DIR_PEMISSIONS}" ] && [ -n "${THIRD_LEVEL_DIR}" ]; then
    _echo "Restoring original permissions '${ORIGINAL_DIR_PEMISSIONS}' to the directory '${THIRD_LEVEL_DIR}'" 'a'
    chmod "${ORIGINAL_DIR_PEMISSIONS}" "${THIRD_LEVEL_DIR}"
  fi
}

function ansible_profile_is_available {
  if [ -z "${1}" ]; then
    # if the paramater is empty just keep going
    # ansible will only load default configs
    _echo "No profile name has been provides. Will use the values set in Ansible."
    exit 1
  elif [ ! -d "${SETUP_PROFILES_DIR}/${1}" ]; then
    _echo "The profile '${SETUP_PROFILES_DIR}/${1}' does not exist" 'e'
    exit 1
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

function install_tools_dependencies {
  for TOOL in ${TOOLS_DEPENDENCIES}; do
    if ! command -v "${TOOL}" >/dev/null 2>&1; then
      _echo "${TOOL} not installed" w
      eval "install_${TOOL}"
    else
      TOOL_VERSION=$(command -v "${TOOL}")
      _echo "${TOOL} ${TOOL_VERSION} is installed"
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

function install_conda {
  if [ ! -d "${CONDA_DIR}/bin" ];then
    if [ ! -f "${CONDA_PACKAGE_PATH}" ];then
      _echo "Downloading Miniconda package to '${CONDA_PACKAGE_PATH}'" 'a'
      curl -fsSL "$CONDA_PACKAGE_URL" -o "${CONDA_PACKAGE_PATH}"
    fi
    _echo "Unpacking Miniconda package to '${CONDA_DIR}' directory" 'a'
    mkdir -p $CONDA_DIR
    tar -xzf "${CONDA_PACKAGE_PATH}" -C $CONDA_DIR
  else
    _echo "Miniconda package is already installed in '${CONDA_DIR}' directory" 'i'
  fi
}

function activate_conda {
  _echo "USING PROJECT'S OWN MINICONDA PYTHON VERSION" 'r'

  _CONDA_ROOT="$(pwd)/$CONDA_DIR"
  export _CONDA_ROOT="$_CONDA_ROOT"

  PYTHON_ROOT="${_CONDA_ROOT}"

  export PATH="${_CONDA_ROOT}/bin:$PATH"
  _echo "PIP_CONFIG_FILE: ${PIP_CONFIG_FILE}"

  # Fix issues with SSL Certificates
  CERT_PATH=$(python -m certifi)
  export SSL_CERT_FILE=${CERT_PATH}
  export REQUESTS_CA_BUNDLE=${CERT_PATH}

  PYTHON_VERSION=$(python --version)
  _echo "${PYTHON_VERSION} is installed"
}

function activate_pyenv {
  _echo "USING PROJECT'S OWN PYENV PYTHON VERSION" 'r'

  ln -fs shims ${PYENV_ROOT}/bin

  export PATH="${PYENV_ROOT}/bin:${PATH}"
  export PYENV_ROOT="${PYENV_ROOT}"
  PYTHON_ROOT="${PYENV_ROOT}"

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
    _echo "Rehashing Pyenv shims ${DESIRED_PYTHON_VERSION}" 'a'
    pyenv rehash
  else
    _echo "Pyenv Python ${DESIRED_PYTHON_VERSION} is already installed"
  fi
}

function upgrade_pip {
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

function install_ansible_galaxy_roles {

  if [ "${VERBOSE}" == "yes" ];then
    DEV_OUTPUT="/dev/stdout"
  else
    DEV_OUTPUT="/dev/null"
  fi
  _echo "Installing Ansible Galaxy roles" 'a'
  ansible-galaxy install -r ${ANSIBLE_REQUIREMENTS} -p ${ANSIBLE_ROLES} ${ANSINLE_FORCE_ROLES_UPDATE} 1> "${DEV_OUTPUT}"
}

function run_ansible_playbook {
  _echo "Running Ansible provisioning"'a'
  export ANSIBLE_CONFIG="${ANSIBLE_CONFIG}"
  _echo "ANSIBLE_CONFIG: ${ANSIBLE_CONFIG}"
  export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES}"
  export ANSIBLE_BECOME_PASS="${ANSIBLE_BECOME_PASS}"
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

function setup_python {
  if [ "${PYTHON_PROVIDER}" == "pyenv" ];then
    eval install_tools_dependencies
    eval activate_pyenv
    eval install_pyenv_python
  elif [ "${PYTHON_PROVIDER}" == "conda" ];then
    eval install_conda
    eval activate_conda
  else
    _echo "Unknow python provider '${PYTHON_PROVIDER}'" 'e'
    exit 1
  fi
  export PYTHON_ROOT="${PYTHON_ROOT}"
  _echo "PYTHON_ROOT: ${PYTHON_ROOT}"
}

function install_dependencies {
  eval setup_python
  eval upgrade_pip
  eval install_pip_dependencies
  eval install_ansible_galaxy_roles
  eval print_execution_time "${START_TIME}"
}

function main {
  _echo "Starting time $( date )" 'r'
  eval ask_for_ansible_sudo_password
  eval enable_passwordless_sudo
  eval check_install_path_permissions
  eval install_dependencies
  eval run_ansible_playbook
  eval restore_path_permissions
  eval disable_passwordless_sudo
  _echo "Ending time $( date )" 'r'
  eval print_execution_time "${START_TIME}"
}

check_command_line_parameters "${@}"
