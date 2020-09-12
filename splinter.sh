#!/usr/bin/env bash
version="0.2-beta"
release_date="20200912"

ansible_dir="ansible"
ansible_config="${ansible_dir}/ansible.cfg"
ansible_inventory="${ansible_dir}/inventory"
ansible_playbook='playbook.yml'
ansible_requirements="${ansible_dir}/requirements.yml"
ansible_roles="${ansible_dir}/roles"
ansible_force_roles_update=''

conda_dir="pyenv"
conda_package_name="splinter-conda.tar.gz"
conda_package_version="v0.1"
conda_package_path="files/${conda_package_name}"
conda_package_url="https://github.com/marcomc/splinter-conda/releases/download/${conda_package_version}/${conda_package_name}"

tools_dependencies=""

desired_ansible_version='2.9.13'
desired_passlib_version='1.7.2'
desired_python_version='3.8.5'
desired_wheel_version='0.35.1'

homebrew_installer_url='https://raw.githubusercontent.com/Homebrew/install/master/install.sh'

pause_seconds='3'

pip_config_file="pip.conf"
pip_dependecies="
ansible
wheel
passlib
"
pip_show_grep_filter='Version'  # 'Name\|Version\|Location' - it's a grep filter

pyenv_root="pyenv"
python_provider="conda"

setup_profiles_dir='./profiles'
staff_guid='20'

update_script="tools/update_splinter.sh"

start_time=$(date +%s)

function _echo {
  purple="\e[35m"
  red="\e[31m"
  green="\e[32m"
  cyan="\e[36m"
  white="\e[39m"
  yellow="\e[33m"
  message_type=""

  case ${2} in
    a|action)
      cyan="${cyan}" #green
      tag='ACTION.'
    ;;
    w|warning)
      cyan="${yellow}"
      tag='WARNING'
      ;;
    e|error)
      cyan="${red}"
      tag='ERROR..'
      ;;
    r|remark)
      cyan="${purple}" #green
      tag='#######'
    ;;
    i|info|*)
      message_type="info"
      cyan="${green}" #green
      tag='INFO...'
    ;;
  esac
  if [ "${verbose}" == "yes" ] || [ "${message_type}" != "info" ];then
    printf "${cyan}[${tag}] ${white}%s\n" "${1}"
  fi
}

function show_version {
  echo "Splinter ${version} ${release_date}"
}

function show_usage (){
  printf "usage: %s [option] action [object] [settings]\n" "${0}"
  printf "options: \n"
  printf "       -e|--env conda|pyenv, List available profiles\n"
  printf "       --help, Print help\n"
  printf "       --version, Print Splinter version and release date\n"
  printf "actions: \n"
  printf "       list, List available profiles\n"
  printf "       provision [settings], Provision the host\n"
  printf "       update <object>, Update the object\n"
  printf "\n"
  printf "obejcts: \n"
  printf "       deps|dependencies, update all the dependency tools (PIP, Ansible Galaxy role)\n"
  printf "       self|auto|splinter, Update Splinter itself (to be run withing the Spliter directory)\n"
  printf "\n"
  printf "settings: \n"
  printf "       -c file, Specify a custom configuration file\n"
  printf "       -b base_profile_name, Specify the the BASE profile to be used (default: 'default')\n"
  printf "       -r role_profile_name, Specify the the ROLE profile to be used\n"
  printf "       -u username, New user username (all lowercase, without spaces)\n"
  printf "       -f 'Full Name', New user full name (quoted if has blank spaces)\n"
  printf "       -p 'clear text password', New user's password in cleartext (quoted if has blank spaces)\n"
  printf "       -h Computer-Name, Computer host name, no blank spaces allowed\n"

  printf "       -v, Produce verbose output\n"
  printf "\n"
  printf "Create your own profiles in the '%s' directory.\n" "${setup_profiles_dir}"
  printf "\n"
  return 0
}

function print_execution_time {
  start_seconds="${1}"
  end_seconds=$(date +%s)
  total_seconds=$(( end_seconds - start_seconds ))
  total_minutes=$(( total_seconds / 60 ))

  if [[ ${total_minutes} -gt 0 ]]; then
    total="${total_minutes} minutes"
  else
    total="${total_seconds} seconds"
  fi
  _echo "Execution time was ${total}" 'r'
}

function update_splinter {
  if [ ! -f ${update_script} ]; then
    _echo "Looks like you are not inside the Splinter directory: $(pwd)" 'e'
    _echo "You need to run the self-update command witing the Splinter directory"
    exit 1
  fi
  _echo "Self updating with '${update_script}'" 'a'
  /bin/bash -c "${update_script}"
}

function check_command_line_parameters {
  verbose='no'
  # Parse options to the `install` command
  case "${1}" in
    -e|--env )
      python_provider="${2}"
      shift 2
      ;;
    --help )
      eval show_usage
      exit 0
      ;;
    --version )
      eval show_version
      exit 0
      ;;
    -*)
      echo "[Error] Invalid option: ${1}" 1>&2
      eval show_usage
      exit 1
      ;;
  esac

  action="${1}";
  _echo "ACTION: ${action}"
  case "$action" in
    list )
      action_option=$2; # fetch the action's option
      # Process package options
      _echo "OPTION: ${action_option}"
      case ${action_option} in
        profiles )
          find "${setup_profiles_dir}"  -maxdepth 1 -mindepth 1 -type directory
          exit 0
          ;;
        '')
          echo "[Error] Missing option for action '${action}'" 1>&2
          eval show_usage
          exit 1
          ;;
        *)
          echo "[Error] Incorrect option '${action_option}' for action '${action}'" 1>&2
          eval show_usage
          exit 1
          ;;
      esac
      ;;
    # Parse options to the install sub command
    update)
      action_option="${2}";# fetch the action's option
      # Process package options
      verbose='yes' # `update` will always be verbose
      case ${action_option} in
        deps|dependencies )
          _echo "Will force Asnible to update all the Galaxy roles dependencies" 'w'
          ansible_force_roles_update='--force'
          eval install_dependencies
          exit 0
          ;;
        self|auto|splinter)
          _echo "Will Self Update" 'w' 1>&2
          eval update_splinter
          exit 0
          ;;
        '')
          echo "[Error] Missing option for action '${action}'" 1>&2
          eval show_usage
          exit 1
          ;;
        *)
          echo "[Error] Incorrect option '${action_option}' for action '${action}'" 1>&2
          eval show_usage
          exit 1
          ;;
      esac
      _echo "OPTION: ${action_option}"
      ;;
    provision )
      shift
      while getopts ":c:b:f:h:p:r:u:v" action_option; do
        case "${action_option}" in
          c)
            export CUSTOM_CONFIG_FILE="${OPTARG}"
            _echo "CUSTOM_CONFIG_FILE: ${CUSTOM_CONFIG_FILE}"
            ;;
          b)
            if ansible_profile_is_available "${OPTARG}" 2>/dev/null ; then
              export SPLINTER_BASE_PROFILE="${OPTARG}"
              _echo "SPLINTER_BASE_PROFILE: ${SPLINTER_BASE_PROFILE}"
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
              export SPLINTER_ROLE_PROFILE="${OPTARG}"
              _echo "SPLINTER_ROLE_PROFILE: ${SPLINTER_ROLE_PROFILE}"
            fi
            ;;
          u)
            export NEW_USER_USERNAME="${OPTARG}"
            _echo "NEW_USER_USERNAME: ${NEW_USER_USERNAME}"
            ;;
          v)
            verbose='yes'
            ;;
          \?)
            echo "[Error] Action '${action}': Invalid setting '-${OPTARG}'" 1>&2
            eval show_usage
            exit 1
            ;;
          :)
            echo "[Error] Action '${action}': setting '-${OPTARG}' is missing an argument" 1>&2
            eval show_usage
            exit 1
            ;;
        esac
      done

      shift $(( OPTIND - 1 ))
      if [[ -n "${*}" ]];then
        # if it is NOT empty it means it interrupted before evaluating all the parameters
        # becaue it encountered a unexpected param or arg
        echo "[Error] Provided unknow parameter: ${1}" 1>&2
        eval show_usage
        exit 1
      fi


      export VERBOSE="${verbose}"
      _echo "VERBOSE: ${VERBOSE}"
      eval main
      ;;
    '')
      echo "[Error] Missing action" 1>&2
      eval show_usage
      exit 1
      ;;
    *)
      echo "[Error] Invalid action '$action'" 1>&2
      eval show_usage
      exit 1
      ;;
  esac
}

function check_install_path_permissions {
  current_path=$(pwd -P)
  third_level_dir=$(echo "${current_path}" | cut -d'/' -f-4)
  dir_stats=$(stat -f '%N %g %p' "${third_level_dir}")
  read -ra DIR_STATS <<< "${dir_stats}"
  dir_name="${DIR_STATS[0]}"
  dir_group_id="${DIR_STATS[1]}"
  dir_pemissions="${DIR_STATS[2]:(-3)}"
  dir_group_pemissions="${DIR_STATS[2]:(-2):1}"

  if [[ "${current_path}" == "${HOME}"* ]]; then
    _echo 'You are running this script within your home directory' 'w'
    _echo 'Ansible might fail if your home directories are protected' 'w'
    _echo "(not allowing group memebers to 'read' AND 'exec' them)" 'w'
    _echo "Checking the permissions on the containing dir" 'a'
    _echo "DIR_NAME: ${dir_name}"
    _echo "dir_group_id: ${dir_group_id}"
    _echo "DIR_PEMISSIONS: ${dir_pemissions}"
    if [[ "${staff_guid}" != "${dir_group_id}" ]]; then
      _echo "The '${dir_name}' group is not 'staff(${staff_guid})'" 'w'
    elif [[ "${dir_group_pemissions}" -lt "5" || "${dir_group_pemissions}" -eq "6" ]]; then
      _echo "'${dir_name}' does NOT allow the 'staff' group to 'read' AND 'exec'" 'w'
      _echo "(this might lead to issues during the execution of some Ansible tasks)" 'w'
      _echo "Adding POSIX 'g+rx' permissions to ${third_level_dir}" 'a'
      chmod g+rx "${third_level_dir}"
      export ORIGINAL_DIR_PEMISSIONS="${dir_pemissions}"
      export THIRD_LEVEL_DIR="${third_level_dir}"
    fi
    _echo "Pausing for ${pause_seconds} seconds for you to read the above message..." 'a'
    printf ">>>>>>>>> "
    for ((i=1; i<=pause_seconds; i++)); do
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
  elif [ ! -d "${setup_profiles_dir}/${1}" ]; then
    _echo "The profile '${setup_profiles_dir}/${1}' does not exist" 'e'
    exit 1
  fi
}

function enable_passwordless_sudo {
  sudo_stdin=''
  if sudo -n true 2>/dev/null; then
    _echo "Passwordless sudo is seems to be already available"
  else
    if [ -n "${ANSIBLE_BECOME_PASS}" ]; then
      sudo_stdin='--stdin'
    fi
    # Enable passwordless sudo for the macbuild run
    _echo "Enabling passwordless sudo for the macbuild run" 'a'
    echo "${ANSIBLE_BECOME_PASS}" | sudo "${sudo_stdin}" sed -i -e "s/^%admin (.*)ALL.*/%admin ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers >/dev/null 2>&1
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
  for pip_dependecy in ${pip_dependecies}; do
    if ! pip show "${pip_dependecy}" >/dev/null 2>&1; then
      _echo "${pip_dependecy} not installed" w
      eval "install_pip_${pip_dependecy}"
    else
      dep_version=$(pip show "${pip_dependecy}" | grep "${pip_show_grep_filter}")
      _echo "${pip_dependecy} ${dep_version} is installed "
    fi
  done
}

function install_tools_dependencies {
  for tool in ${tools_dependencies}; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
      _echo "${tool} not installed" w
      eval "install_${tool}"
    else
      tool_version=$(command -v "${tool}")
      _echo "${tool} ${tool_version} is installed"
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
  if ! command -v "brew" >/dev/null 2>&1; then
    _echo "Installing Homebrew" 'a'
    /bin/bash -c "$(curl -fsSL ${homebrew_installer_url})" < /dev/null
  else
    tool_version=$(command -v "brew")
    _echo "Homebrew ${tool_version} is installed"
  fi

}

function install_conda {
  if [ ! -d "${conda_dir}/bin" ];then
    if [ ! -f "${conda_package_path}" ];then
      _echo "Downloading Miniconda package to '${conda_package_path}'" 'a'
      curl -fsSL "${conda_package_url}" -o "${conda_package_path}"
    fi
    _echo "Unpacking Miniconda package to '${conda_dir}' directory" 'a'
    mkdir -p ${conda_dir}
    tar -xzf "${conda_package_path}" -C ${conda_dir}
  else
    _echo "Miniconda package is already installed in '${conda_dir}' directory" 'i'
  fi
}

function activate_conda {
  _echo "USING PROJECT'S OWN MINICONDA PYTHON VERSION" 'r'

  conda_root="$(pwd)/${conda_dir}"
  # Fix issues with SSL Certificates
  cert_path=$(python -m certifi)
  python_root="${conda_root}"
  python_version=$(python --version)

  export _CONDA_ROOT="${conda_root}"
  export CONDA_PREFIX="${_CONDA_ROOT}"
  export PATH="${_CONDA_ROOT}/bin:$PATH"
  export SSL_CERT_FILE=${cert_path}
  export REQUESTS_CA_BUNDLE=${cert_path}

  _echo "${python_version} is installed"
}

function activate_pyenv {
  _echo "USING PROJECT'S OWN PYENV PYTHON VERSION" 'r'
  export PYENV_ROOT="${pyenv_root}"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  export PYENV_VERSION="${desired_python_version}"
  python_root="${pyenv_root}"
  _echo "PYENV_ROOT: ${PYENV_ROOT}"
  _echo "PYTHON_VERSION: $(pyenv version)"
}

function update_brew {
  _echo "Updating Homebrew" 'a'
  brew update
}

function install_pyenv {
  if ! command -v "pyenv" >/dev/null 2>&1; then
    _echo "Installing Pyenv" 'a'
    # install pyenv with homebrew
    eval update_brew
    brew install pyenv
  else
    tool_version=$(command -v "pyenv")
    _echo "Pyenv ${tool_version} is installed"
  fi
}

function install_pip_ansible {
  _echo "PIP - Installing Ansible ${desired_ansible_version}" 'a'
  pip install "ansible==${desired_ansible_version}"
  # pip show ansible | grep "${pip_show_grep_filter}"
}

function install_pip_wheel {
  _echo "PIP - Installing Wheel ${desired_wheel_version}" 'a'
  pip install "wheel==${desired_wheel_version}"
  # pip show "wheel"  | grep "${pip_show_grep_filter}"
}

function install_pip_passlib {
  _echo "PIP - Installing passlib ${desired_passlib_version}" 'a'
  pip install "passlib==${desired_passlib_version}"
  # pip show "passlib" | grep "${pip_show_grep_filter}"
}

function install_pyenv_python {
  if ! pyenv versions | grep "${desired_python_version}" >/dev/null 2>&1; then
    # •	install python3 with pyenv
    _echo "Installing Pyenv Python ${desired_python_version}" 'a'
    pyenv install "${desired_python_version}"
    ln -fs shims ${pyenv_root}/bin
    _echo "Rehashing Pyenv shims ${desired_python_version}" 'a'
    pyenv rehash
  else
    _echo "Pyenv Python ${desired_python_version} is already installed"
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

  if [ "${verbose}" == "yes" ];then
    dev_output="/dev/stdout"
  else
    dev_output="/dev/null"
  fi
  _echo "Installing Ansible Galaxy roles" 'a'
  ansible-galaxy install -r ${ansible_requirements} -p ${ansible_roles} ${ansible_force_roles_update} 1> "${dev_output}"
}

function run_ansible_playbook {
  _echo "Running Ansible provisioning"'a'
  export ANSIBLE_CONFIG="${ansible_config}"
  _echo "ANSIBLE_CONFIG: ${ANSIBLE_CONFIG}"
  export ANSIBLE_ROLES_PATH="${ansible_roles}"
  ansible-playbook ${ansible_playbook} -i ${ansible_inventory}
}

function ask_for_ansible_sudo_password {
  # temporarely store the password in cleartext in the environment
  # so it can be used by Ansible throughout the whole execution
  if [ -z "${ANSIBLE_BECOME_PASS}" ]; then
        _echo "Requesting the admin password to be used for 'sudo' throughout the deployment process" 'a'
        read -r -p ">>>>>>>>> Insert the current user password: " -s ansible_become_pass
        export ANSIBLE_BECOME_PASS="${ansible_become_pass}"
        printf "\n"
  else
        _echo "'ANSIBLE_BECOME_PASS' is already set"
  fi
}

function setup_python {
  export PIP_CONFIG_FILE="${pip_config_file}"
  _echo "PIP_CONFIG_FILE: ${PIP_CONFIG_FILE}"
  if [ "${python_provider}" == "pyenv" ];then
    eval install_pyenv
    eval activate_pyenv
    eval install_pyenv_python
  elif [ "${python_provider}" == "conda" ];then
    eval install_conda
    eval activate_conda
  else
    _echo "Unknow python provider '${python_provider}'" 'e'
    exit 1
  fi
  export PYTHON_PROVIDER="${python_provider}"
  _echo "PYTHON_PROVIDER: ${PYTHON_PROVIDER}"
  export PYTHON_ROOT="${python_root}"
  _echo "PYTHON_ROOT: ${PYTHON_ROOT}"
}

function install_dependencies {
  eval install_brew
  eval setup_python
  eval upgrade_pip
  eval install_pip_dependencies
  eval install_ansible_galaxy_roles
  eval print_execution_time "${start_time}"
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
  eval print_execution_time "${start_time}"
}

check_command_line_parameters "${@}"
