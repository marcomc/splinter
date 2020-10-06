# Version: 0.5.1-beta
* remove unnecessary use of 'eval'
* rename tests/ to test/

# Version: 0.5-beta
* brew cleanup
* pyenv rehash
* set hostname
* set Computer Name
* set Bonjourname
* dotfiles: default System Configs
* fork ansible-role-osx-defaults to add more configurations options taken from other repos
* enable Dark Mode
* Trackpad settings
* Complete SetApp installation
* Turn on Firewall
* complete Sophos Antivirus installation and login
* Require password immediately after sleep/screen-saver
* Adjust key repeat and delay till repeat in keyboard settings
* install non-mas applications
* Longin settings
* modify homebrew permissions to allow all admin members to use homebrew
* create an newuser (admin) account using a cleartext password
* customise User's profile picture
* force password reset at the first login
* create a check to verify if the Ansible working directory is inside a protected directory, if so suggest to move the project dir in a public dir, or to change the directory permissions
* User Dock's layout
* incorporate the Dock customisation into osx-defaults
* make the ansible script to run the applications installations as the target user
* HOMEBREW_AUTO_UPDATE_SECS='300' # Tells brew not to run autoupdate if it was run less than 5 minutes ago 5 minutes add this to bash zsh or fish config
* Cron
  * daily homebrew update and upgrade
* add /usr/local/bin /usr/local/sbin to the path
* add template for ~/.ssh/config file with frontdoor proxy
* transform `new-user` task in a Galaxy Role: marcomc.macos-create-user
* allow different preferences profiles for different ypes of users (employees)
* add 'version = int' and 'mod-count = int' to osx-defaults
* defaults write com.apple.AppleMultitouchTrackpad ActuateDetents
* defaults write com.apple.SetupAssistant
* replace `ansible_user_id` with `ansible_user_id` in all the used roles
* Silent Clicking
* Force Click and haptic feedback
* prevent mac to ask user setup at first login
* allow to chose which is the default profile that work as a base?
* add a timer to the script to count how long from the beginning to the end of the process
* add Terminal to Developers Tools Privacy Policy
* have homebrew to retry cask installation (done with a patch to homebrew role)
* user custom Desktop picture
* modify user icon for current user
* move all tasks to  ansible-role-mac-setup-ansible or something like that so that the application lives alone with any ansible code except the the main.yml
* define a new name for the application
* create xxxx-extra-packages
* rename main.yml in something more effective
* move pyenv with ansible setup inside the project folder so that it can be deployed pre-downloaded
* add to gitignore
  * !roles
  * configs.yml
  * !env
  * !files
  * !profiles
* BUG: splinter.sh script, when using the option force the <profile> parameter is ignored
* write README for custom envs and config file handling
* recover the definition of non_mas_apps from old installations
* see how to use `miniconda` to distribute python
* update usage functionx  
* BUG: Desktop picture is not being copied and installed in the target user account
* BUG: some process is overriding `com.apple.AppleMultitouchTrackpad` `Clicking` and `Dragging` setting at first login, turing it to int and to False. maybe we need to apply that setting to another plist file?
* write function to update tools from repository `splinter update tools`
* write function to import tools from repository during the first installation (maybe launching `splinter update tools` after the installation)
* remove the dsimport file for the profile picture
* add support for profiles from git repos
  profile_name: <githubuser>.<profilename> ( github.com/<githubuser>/splinter-profiles/<profilename>/)
  bash dowloads it '<githubuser>-.<profilename>' (if not already existing)
* splinter list profiles doesn't work
* move splinter configurations to splinter.cfg
  * configfile type: ini
  * look for the config file in the current directory
  * replace config-example.yml from `install` script with `splinter-example.conf`
  * move all the parameters from config.yml to splinter.cfg
  * load all the values as environment variables, if they are not set by the cli yet
  * splinter will take care of loading these basic settings and not Ansible anymore
  * this will allow to to remove `vars_files` from playbook.yml:
* BUG: when the config file is placed out of the config dir or the current directory is not the config dir ansible is not picking up the `ansible.cfg` file it would be good to specify the path to the `cfg` file via an Ansible ENV
* BUG: [ACTION..] Disabling passwordless sudo after the provisioning is not actually fixing the sudoers
* add a `create package` action that will download the profiles and dependencies and create a DMG file to be deployed for an offline deployment
  * dmg
  * zip
* write "Use cases"
* allow extra packages to be installed as target_user_id or for the current user
* add command to export extra packages lists
* add support for filevault-recovery-key-generator
* write unit tests
  * BATS
  * TravisCI
  * add matrix to execute one provisioning in two distinct systems 10.14 & 10.15
* macprefs:
  * find how ansible patch works:
    - maybe there is no need for a condition
    - or just make the condition to work properly
  * verify restore errors
* Write step-by-step guides for each use case

##### When Provisioning the current user (not a new user)
* dotfiles: export personal System Configs
* zsh
* bash
* fish
* vimrc
* User's Library preferences
* System's Library preferences (?)
* install ZIP applications
  * https://central.github.com/deployments/desktop/desktop/latest/darwin
  * https://iconset.io/download#/mac.zip
  * install Paragon NTFS for Mac
  * install Paragon extFS for Mac
* iCloud login - must be done manually!
* setup Macprefs backup
  * recurring backup
  * restore during provisioning
* User Login items: are restored with Macprefs
* add ShareMouse config to Macprefs
* Internet login
  * Gmail account(s): done via Macpref's
* make conda to work: has issues linking libtinfo
* see if it is possible to prevent Xcode to request confirmation
* Add `update` action to the splinter.sh script that will download updated version of:
  * make backup and then update all the list below
  * requirements.yml
  * ansible.cfg
  * playbook.yml
  * README.md
  * CHANGELOG.md
  * splinter.sh
  * TODO.md
  * tools/
