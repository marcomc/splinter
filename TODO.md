# TO DO
* [x] brew cleanup
* [x] pyenv rehash
* [x] set hostname
* [x] set Computer Name
* [x] set Bonjourname
* [x] dotfiles: default System Configs
* [x] fork ansible-role-osx-defaults to add more configurations options taken from other repos
* [x] enable Dark Mode
* [x] Trackpad settings
* [x] Complete SetApp installation
* [x] Turn on Firewall
* [x] complete Sophos Antivirus installation and login
* [x] Require password immediately after sleep/screen-saver
* [x] Adjust key repeat and delay till repeat in keyboard settings
* [x] install non-mas applications
* [x] Longin settings
* [x] modify homebrew permissions to allow all admin members to use homebrew
* [x] create an newuser (admin) account using a cleartext password
* [x] customise User's profile picture
* [X] force password reset at the first login
* [x] create a check to verify if the Ansible working directory is inside a protected directory, if so suggest to move the project dir in a public dir, or to change the directory permissions
* [x] User Dock's layout
* [x] incorporate the Dock customisation into osx-defaults
* [x] make the ansible script to run the applications installations as the target user
* [x] HOMEBREW_AUTO_UPDATE_SECS='300' # Tells brew not to run autoupdate if it was run less than 5 minutes ago 5 minutes add this to bash zsh or fish config
* [x] Cron
  * [x] daily homebrew update and upgrade
* [x] add /usr/local/bin /usr/local/sbin to the path
* [x] add template for ~/.ssh/config file with frontdoor proxy
* [x] transform `new-user` task in a Galaxy Role: marcomc.macos-create-user
* [x] allow different preferences profiles for different ypes of users (employees)
* [x] add 'version = int' and 'mod-count = int' to osx-defaults
* [x] defaults write com.apple.AppleMultitouchTrackpad ActuateDetents
* [x] defaults write com.apple.SetupAssistant
* [x] replace `ansible_user_id` with `ansible_user_id` in all the used roles
* [x] Silent Clicking
* [x] Force Click and haptic feedback
* [x] prevent mac to ask user setup at first login
* [x] allow to chose which is the default profile that work as a base?
* [x] add a timer to the script to count how long from the beginning to the end of the process
* [x] add Terminal to Developers Tools Privacy Policy
* [x] have homebrew to retry cask installation (done with a patch to homebrew role)
* [x] user custom Desktop picture
* [x] modify user icon for current user
* [x] move all tasks to  ansible-role-mac-setup-ansible or something like that so that the application lives alone with any ansible code except the the main.yml
* [x] define a new name for the application
* [x] create xxxx-extra-packages
* [x] rename main.yml in something more effective
* [x] move pyenv with ansible setup inside the project folder so that it can be deployed pre-downloaded
* [x] add to gitignore
  * [x] !roles
  * [x] configs.yml
  * [x] !env
  * [x] !files
  * [x] !profiles
* [x] BUG: splinter.sh script, when using the option force the <profile> parameter is ignored
* [x] write README for custom envs and config file handling
* [x] recover the definition of non_mas_apps from old installations
* [*] see how to use `miniconda` to distribute python
* [*] update usage functionx  
* [x] BUG: Desktop picture is not being copied and installed in the target user account
* [x] BUG: some process is overriding `com.apple.AppleMultitouchTrackpad` `Clicking` and `Dragging` setting at first login, turing it to int and to False. maybe we need to apply that setting to another plist file?
* [x] write function to update tools from repository `splinter update tools`
* [x] write function to import tools from repository during the first installation (maybe launching `splinter update tools` after the installation)
* [x] remove the dsimport file for the profile picture
* [x] add support for profiles from git repos
  profile_name: <githubuser>.<profilename> ( github.com/<githubuser>/splinter-profiles/<profilename>/)
  bash dowloads it '<githubuser>-.<profilename>' (if not already existing)
* [x] splinter list profiles doesn't work
* [x] move splinter configurations to splinter.cfg
  * [x] configfile type: ini
  * [x] look for the config file in the current directory
  * [x] replace config-example.yml from `install` script with `splinter-example.conf`
  * [x] move all the parameters from config.yml to splinter.cfg
  * [x] load all the values as environment variables, if they are not set by the cli yet
  * [x] splinter will take care of loading these basic settings and not Ansible anymore
  * [x] this will allow to to remove `vars_files` from playbook.yml:
* [x] BUG: when the config file is placed out of the config dir or the current directory is not the config dir ansible is not picking up the `ansible.cfg` file it would be good to specify the path to the `cfg` file via an Ansible ENV
* [x] BUG: [ACTION..] Disabling passwordless sudo after the provisioning is not actually fixing the sudoers
* [x] add a `create package` action that will download the profiles and dependencies and create a DMG file to be deployed for an offline deployment
  * [x] dmg
  * [x] zip
* [x] write "Use cases"
* [x] allow extra packages to be installed as target_user_id or for the current user
* [x] add command to export extra packages lists
* [x] add support for filevault-recovery-key-generator
* [x] write unit tests
  * [x] BATS
  * [x] TravisCI
  * [x] add matrix to execute one provisioning in two distinct systems 10.14 & 10.15
* [x] macprefs:
  * [x] find how ansible patch works:
    - maybe there is no need for a condition
    - or just make the condition to work properly
  * [x] verify restore errors

* [ ] Write step-by-step guides for each use case


# When Provisioning the current user (and not a target user)
* [x] dotfiles: export personal System Configs
* [x] zsh
* [x] bash
* [x] fish
* [x] vimrc
* [x] User's Library preferences
* [x] System's Library preferences (?)
* [x] install ZIP applications
  * [x] https://central.github.com/deployments/desktop/desktop/latest/darwin
  * [x] https://iconset.io/download#/mac.zip
  * [x] install Paragon NTFS for Mac
  * [x] install Paragon extFS for Mac
* [x] iCloud login - must be done manually!
* [x] setup Macprefs backup
  * [*] recurring backup
  * [*] restore during provisioning
* [x] User Login items: are restored with Macprefs
* [x] add ShareMouse config to Macprefs
* [X] Internet login
  * [X] Gmail account(s): done via Macpref's

# Future
* [x] make conda to work: has issues linking libtinfo
* [x] see if it is possible to prevent Xcode to request confirmation
* [x] Add `update` action to the splinter.sh script that will download updated version of:
  * [x] make backup and then update all the list below
  * [x] requirements.yml
  * [x] ansible.cfg
  * [x] playbook.yml
  * [x] README.md
  * [x] CHANGELOG.md
  * [x] splinter.sh
  * [x] TODO.md
  * [x] tools/

* [ ] add splinter and splinter-tools to homebrew

* [ ] replace `-e none` with `-e local` to user local version of python
  * [ ] verify that local version of python is 3.x
  * [ ] will install ansible in the local python
  * [ ] will not include any python component in the `Splinter package`
  * [ ] modify BATS unit tests that use `-e none` to use `-e local`

* [ ] add support for Atom packages https://github.com/gantsign/ansible-role-atom-packages
  * [ ] export lists tool
  * [ ] splinter-extra-packages
* [ ] replace the task "Set background image" with a proper task (in splinter_toolkit) to install the background image for the current user
* [ ] create a webpage that will allow to modify with a GUI a profile and to download it locally
* [ ] distribute compiled version (made with `shc`) ??
* [ ] filevault2 role: if FV is already enabled, check if the newuser is already added to Filevault, if not, add it
* [ ] user custom keyboards shortcuts, only my private set if macprefs doesn't restore them
* [ ] convert mac-app-install into ansible-brew like repo
  * [ ] leave the option to define your own application configuration
  * [ ] add the option to have a common database of app with their info
  * [ ] have the user to simply specify the name and version of the app
    * if no version is specified will skip if the app is already installed
    * if 'upgrade' option is provided will install only if the version on the database is newer
    * if a version is specified it will install it if the version is available in the database
* [ ] source the tools script as libraries instead of calling them as commands
* [ ] port to ansible 2.10.1

* [ ] name: add login item
  command: "loginitems -a '{{ item }}'"
  changed_when: false
  with_items: "{{ login_items }}"
# BUGS
* [ ] BUG: after setting the taptoClick even if the checkbox is marked properly tapping is not working (tapBehavior), maybe there is some service to restart (but I don't think so), probably there is some other flag somewhere to set
