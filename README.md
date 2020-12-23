[![Build Status](https://api.travis-ci.com/marcomc/splinter.png)](https://www.travis-ci.com/github/marcomc/splinter/builds)
```
  _______  _____         _____ __   _ _______ _______  ______
  |______ |_____] |        |   | \  |    |    |______ |_____/
  ______| |       |_____ __|__ |  \_|    |    |______ |    \_

         2020 (c) MarcoMC - github.com/marcomc/splinter
An opinionated provisioning tool for macOS automated with Ansible
```
# How to Provision a Mac with Ansible

* [Install Splinter](#install-splinter)
* [Use cases with step-by-step instructions](#use-cases-with-step-by-step-instructions)
* [Profiles](#profiles)
* [Usage](#usage)
* [License & Copyright](#license-copyright)
* [Credits](#credits)
* [Official documentation](https://github.com/marcomc/splinter/wiki)

# Install Splinter

> It's preferable to use the `bash` installation (rather then git clone) because the installation script will execute some initial setup and cleanup

The installatio will download Splinter to `./splinter` directory and setup the first `config` file and `default` profile.

    # BASH & ZSH
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/marcomc/splinter-tools/master/install-splinter)"

    # FISH
    curl -fsSL https://raw.githubusercontent.com/marcomc/splinter-tools/master/install-splinter | /bin/bash

# What does Splinter do?
Splinter uses a bash script to install the minimum requirements to run Ansible within a dedicated Python environment, then run an Ansible playbook that will run the full provisioning of a macOS system

__You can customise your provisioning activating toggling modules and modifying attributes via the use of [profiles](#profiles).__

# Use cases (with step-by-step instructions)

1. [Provision a Mac for a new employee](https://github.com/marcomc/splinter/wiki/Provision-a-Mac-for-a-new-employee)
2. [Build a backup Mac](https://github.com/marcomc/splinter/wiki/Build-a-backup-Mac)
3. [Migrate to a new Mac](https://github.com/marcomc/splinter/wiki/Migrate-to-a-new-Mac)
4. [Rebuild a Mac to a clean state](https://github.com/marcomc/splinter/wiki/Rebuild-a-Mac-to-a-clean-state)
5. [Restore your Mac favourite settings and software](https://github.com/marcomc/splinter/wiki/Restore-your-Mac-favourite-settings-and-software)
6. [Create an additional account for your kids or partner](https://github.com/marcomc/splinter/wiki/Create-an-additional-account-for-your-kids-or-partner)

# Profiles

Splinter supports 3 levels of profile listed here from least to most important:

1. `marcomc.splinter_toolkit default values`:
   This is a collection of sensible default values

2. `profiles/base`:
   This is a set of default values that you can _customise and rename as you prefer_.

   > If you are handling many different profiles i.e. `finance`, `developer`, `devops`, `fe-developer`, `marketing` you can have a base default set with the common company defaults to apply to all new machines.

3. `profiles/<role-profile>`:

    These are specific role profiles where you can define only the settings that you want to customise for each role of machine or employee that will override some or all of the settings specified in your `base` profile.

    > i.e. `finance`, `developer`, `devops`, `fe-developer`, `marketing`

Review the instruction about how to [create a custom profiles repository](https://github.com/marcomc/splinter/wiki/Create-a-custom-profiles-repository) and store it in GitHub.

# Usage

    usage: ./splinter [option] action [object] [settings]


    options:
           -e|--env conda|pyenv|none  Chose the Python environemnt
           -v|--verbose               Produce verbose output
           -q|--quiet                 Suppress all non-Ansible output (except errors and warnings)
           --help                     Print help
           --version                  Print Splinter version and release date

    actions:
           create <object> [settings]
           list profiles              List available profiles
           provision [settings]       Provision the host
           update <object>            Update the <object>
           export <object> [settings] Export list of <object> packages

    objects:
           [ create ]
           package [settings]         Create distributable package of your splinter project
           filevault-recovery-key     Create a FileVaultMaster recovery key in both Keychain and DER formats

           [ export ]
           preferences                    Export system preferences and user's dorfiles using Macprefs
           brew [taps|packages|casks|all] Export list of brew taps, packages and casks
           ruby [gems]                    Export list of user installed Ruby gems
           mas [packages]                 Export list of installed apps from MacAppStore
           npm [packages]                 Export list of NPM packages
           pip [packages]                 Export list of user installed Python packages from Pip
           all                            Export all the above

           [ update ]
           conda                      Reinstall the most recent Miniconda Python environment available for splinter
           pyenv                      Reinstall Pyenv Python environment
           galaxy|galaxy-roles        Force update all the Ansible Galaxy roles
           tools                      Update the splinter tools
           deps|dependencies          Update all the dependencies (Python envs and  Ansible Galaxy role)
           self|auto|splinter         Update Splinter itself (but not the tools or dependencies)
           profiles [settings]        Update the profiles from a online git repo (for now only github is supported)

    settings:
           [ provision ]
           -c file                    Specify a custom configuration file
           -u username                New user username (all lowercase  without spaces)
           -f 'Full Name'             New user full name (quoted if has blank spaces)
           -p 'cleartext password'    New user's password in cleartext (quoted if has blank spaces)
           -t username                Target user username, if different than the new user (can be used to provision the current account)
           -h Computer-Name           Computer host name no blank spaces allowed

           [ provision, update profiles ]
           -a account_name            Specify the the Github account name for the custom `splinter-profiles` repo
           -g git-repo-name           Specify the the Github repository name for the custom `splinter-profiles` repo
           -b profile_name            Specify the the BASE profile to be used (default: 'base')
           -r profile_name            Specify the the ROLE profile to be used

           [ create package ]
           -n Package-Name            The name of the package (without extension)
           -d path/to/directory       The destination directory where to place the package
           -t dmg|zip                 The type of package

    Create your own profiles in the './profiles' directory.

# Dependencies

[![Build Status](https://travis-ci.com/marcomc/splinter-tools.svg?branch=master)](https://travis-ci.com/marcomc/splinter-tools) - [splinter-tools](https://github.com/marcomc/splinter-tools) - Additional tools for Splinter provisioning

[![Build Status](https://travis-ci.com/marcomc/splinter-conda.svg?branch=master)](https://travis-ci.com/marcomc/splinter-conda) - [splinter-conda](https://github.com/marcomc/splinter-conda) - Miniconda pre-packed for Splinter provisioning (provides working Ansible)

## Ansible Galaxy

- ctorgalson.macos_hostname
- elliotweiser.osx-command-line-tools
- geerlingguy.dotfiles
- geerlingguy.homebrew
- geerlingguy.mas
- juju4.macos_apps_install
- lafarer.osx-defaults

- [marcomc.homebrew_autoupdate](https://github.com/marcomc/ansible-role-homebrew-autoupdate) [![Build Status](https://travis-ci.com/marcomc/ansible-role-homebrew-autoupdate.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-homebrew-autoupdate)

- [marcomc.homebrew_multi_user](https://github.com/marcomc/ansible-role-homebrew-multi-user) [![Build Status](https://travis-ci.com/marcomc/ansible-role-homebrew-multi-user.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-homebrew-multi-user)

- [marcomc.macos_filevault2](https://github.com/marcomc/ansible-role-macos-filevault2) [![Build Status](https://travis-ci.com/marcomc/ansible-role-macos-filevault2.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-macos-filevault2)

- [marcomc.macos_macprefs](https://github.com/marcomc/ansible-role-macos-macprefs) [![Build Status](https://travis-ci.com/marcomc/ansible-role-macos-macprefs.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-macos-macprefs)

- [marcomc.macos_new_user](https://github.com/marcomc/ansible-role-macos-new-user) [![Build Status](https://travis-ci.com/marcomc/ansible-role-macos-new-user.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-macos-new-user)

- [marcomc.macos_setapp](https://github.com/marcomc/ansible-role-macos-setapp) [![Build Status](https://travis-ci.com/marcomc/ansible-role-macos-setapp.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-macos-setapp)

- [marcomc.macos_sophos_endpoint](https://github.com/marcomc/ansible-role-macos-sophos-endpoint) [![Build Status](https://travis-ci.com/marcomc/ansible-role-macos-sophos-endpoint.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-macos-sophos-endpoint)

- [marcomc.splinter_extra_packages](https://github.com/marcomc/ansible-role-splinter-extra-packages) [![Build Status](https://travis-ci.com/marcomc/ansible-role-splinter-extra-packages.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-splinter-extra-packages)

- [marcomc.splinter_toolkit](https://github.com/marcomc/ansible-role-splinter-toolkit) [![Build Status](https://travis-ci.com/marcomc/ansible-role-splinter-toolkit.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-splinter-toolkit)

- [marcomc.user_ssh_config](https://github.com/marcomc/ansible-role-user-ssh-config) [![Build Status](https://travis-ci.com/marcomc/ansible-role-user-ssh-config.svg?branch=master)](https://travis-ci.com/marcomc/ansible-role-user-ssh-config)

# License & Copyright

License: [GPLv2](LICENSE.md)

2020 (c) Marco Massari Calderone <marco@marcomc.com>
The logo [MarcoMC_Apple_Sketch_Round](files/profile_pictures/MarcoMC_Apple_Sketch_Round.png) is a property and copyright of Marco Massari Calderone.

# Credits

## Inspiration

geerlingguy's [Mac Development Ansible Playbook](https://github.com/geerlingguy/mac-dev-playbook)

## Images
The Image [splinter_desktop.jpg](files/desktop_pictures/splinter_desktop.jpg) is an image by [Maaark](https://pixabay.com/users/Maaark-3329882/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=1693434) from [Pixabay](https://pixabay.com/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=1693434)
