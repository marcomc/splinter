# Splinter - Ansible Automated macOS Provisioning

![Splinter Logo](files/splinter_logo.png)

# What does Splinter do?

Spliter uses a bash script to install the minimum requirements to run Ansible within a dedicated  Pyenv Python environment, then run an Ansible playbook that will run the full provisioning of a macOS system

__BASH script__:
* Ask for current user password
  * will be used for sudo during the whole provisioning
* Enable passwordless sudo
* Check and fix install dir path permissions
* Install requirements
  * brew
  * pyenv
* Activate pyenv
* Install pyenv python 3.x in /tmp/pyenv directory
* Upgrade pip to the latest version
* install pip dependencies
  * ansible
  * wheel
  * passlib
* update ansible galaxy roles
* run ansible playbook
* restore path permissions
* disable passwordless sudo

__Ansible playbook__:
* Allow passwordless sudo if it is not already active
* Disables Apps Quarantine for the time of the provisioning only
* Install GNU tar via Homebrew
* Update the current user Profile Picture
* Set the ComputerName & LocalHostName
* Install Sophos Antivirus Endpoint (if an installer url or zip file are provided)
* Create the a new employee's Account (`target_user_id`)
* Configure ssh for the new user:
  * creates its RSA SSH key pair
  * setup the ssh_config
    * define some default parameters
    * optionally add a SSH proxy server definition
* Activate FileVault2
  * for both current and target users
* Configure Hombrew:
  * Allow multi-user admonistration allowing all members of the chosen group to Read/Write (by default it is `admin` group)
  * Enable Autoupdates
    * define a threshold to consider cached database still fresh
    * setup a LaunchAgent to refresh the cached database periodically
  * Install desired taps
  * Install desired packages
  * Install desired Cask applications
* Install __global__ (system wide) packages:
  * Install desired NPM packages
  * Install desired PIP packages
  * Install desired Composer packages
  * Install desired Ruby gems
* Configure macOS system-wide settings:
  * Application Firewall
  * Date and Time: Timezone and Formats
  * Display(s)
  * Energy Saver
  * Login Window
* Configure macOS user's settings (for targe_user_id)
  * Activity Monitor
  * App Store
  * Dashboard
  * Desktop and Screen Saver
  * Disk Image handling
  * Finder
  * Hot-Corners
  * Keyboard
  * Language and Region
  * Mission Control
  * Safari
  * SetupAssistant
  * Spotlight
  * Trackpad
* Restore dotfiles (3 distinct methods):
  * via a private dotfile repository
  * via Macprefs backup
  * via Mackup sync tool
* Install applications from the Mac App Store (MAS apps)
* Install applications from direct links (non MAS apps)
* Install SetApp applications store (from which you can install additional apps)
* Run custom post-provision tasks

__You can can chose which of the above modules to run customising the the modules.yml file in your profiles__

## Pre-Deployment manual steps

__On the old machine:__
1. pre-configure Splinter:
  * define your `profiles`.
  * personalise `config.yml`.

__On the new machine:__
2.  Login in the new machine as the company admin account, the first account you create in the machine, *not the new employee user account* (that will be created by this script).

3. Add the `Terminal` application (located in `/Applications/Utilities/`) to the "Full Disk Access" policy.

4. Connect to WiFi network.

5. Transfer a copy of the `splinter` directory to the new machine:
  * option 1: transfer the directory using `Share->AirDrop` (you need to make the new machine discoverable by `everyone`).
  * option 2: transfer with a USB stick.
  * option 3: you can create a writable Disk Image and transfer it to the new machine.

## Setup
__On the new machine:__
1. Open the Terminal app (located in `/Applications/Utilities/`)

2. go to `splinter` directory, supposedly at `~/Downloads/splinter`

3. run `splinter`:

    sh splinter.sh

4. Splinter will request you to enter the current user account (to be used as `sudo` password throughout the whole process).

5. the rest of the provisioning can be unattended but a few applications might require some system privacy authorisation, for instance `vagrant` and if you do not allow that in time and the installation fail you can re-run the `brew` installation command or re-run `splinter`

__During the deployment a few applications will request authorisation to run run so do not leave the computer completely unattended.__



# Post deployment manual steps

## Authorise "Virtualbox" kext if you installed it via homebrew or macos_apps list

1. Go to System Preferences -> Security & Privacy -> General

2. Click the `Allow` button next to the request of authorisation for "Oracole America, Inc." software

3. re-run VirtualBox installation, this time it should succeed without errors

    > brew cask reinstall virtualbox

## Fix "Sophos" installation

Follow Sophos guide to add all the required components to `System Preferences -> Security & Privacy -> Privacy`

If no Sophos guided steps window appear then:

1. Go to System Preferences -> Security & Privacy -> General

2. Click the `Allow` button next to the request of authorisation for "Oracole America, Inc." software



# License

MIT

# Copyright

Marco Massari Calderone <marco@marcomc.com>
The logo `MarcoMC_Apple_Sketch_Round` is a property and copyright of Marco Massari Calderone.
