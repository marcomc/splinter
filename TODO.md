# TO DO
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
* [ ] ad support for 'erase-reinstall': https://github.com/grahampugh/erase-install
* [ ] name: add login item
  command: "loginitems -a '{{ item }}'"
  changed_when: false
  with_items: "{{ login_items }}"

# KNOWN ISSUES
* [ ] BUG: after setting the taptoClick even if the checkbox is marked properly tapping is not working (tapBehavior), maybe there is some service to restart (but I don't think so), probably there is some other flag somewhere to set
