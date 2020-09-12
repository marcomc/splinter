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

* [ ] add support for profiles from git repos
* [ ] allow extra packages to be installed as target_user_id or for the current user

# When Provisioning the current user (and not a target user)
* [x] dotfiles: export personal System Configs
* [x] dotfiles: import personal System Configs (mackup?)
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

- name: add login item
  command: "loginitems -a '{{ item }}'"
  changed_when: false
  with_items: "{{ login_items }}"

* [ ] iCloud login
* [ ] Cron
  * [ ] setup periodic export of app/pkg lists and mackup exports
* [ ] App settings (with mackup?)
* [ ] add ShareMouse config to Mackup
* [ ] add ShareMouse config to Macprefs
* [ ] Internet login
* [ ] Gmail account(s)
* [ ] User Login items
* [ ] TimeMachine Settings
  * [ ] allow to specify which source to use for mackup

# Future
* [ ] user custom keyboards shortcuts, only my private set if macprefs doesn't restore them
* [ ] see if it is possible to prevent Xcode to request confirmation
* [ ] Add `update` action to the splinter.sh script that will download updated version of:
  * [ ] make backup and then update all the list below
  * [ ] requirements.yml
  * [ ] ansible.cfg
  * [ ] playbook.yml
  * [ ] README.md
  * [ ] CHANGELOG.md
  * [ ] splinter.sh
  * [ ] TODO.md
  * [ ] tools/
* [ ] convert mac-app-install into ansible-brew like repo
  * [ ] leave the option to define your own application configuration
  * [ ] add the option to have a common database of app with their info
  * [ ] have the user to simply specify the name and version of the app
    * if no version is specified will skip if the app is already installed
    * if 'upgrade' option is provided will install only if the version on the database is newer
    * if a version is specified it will install it if the version is available in the database
