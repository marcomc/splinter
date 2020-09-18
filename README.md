

```
  _______  _____         _____ __   _ _______ _______  ______
  |______ |_____] |        |   | \  |    |    |______ |_____/
  ______| |       |_____ __|__ |  \_|    |    |______ |    \_

         2020 (c) MarcMC - github.com/marcomc/splinter
An opinionated provisioning tool for macOS automated with Ansible
```
# Install Splinter

> It's preferable to use the `bash` installation (rather then git clone) because the installation script will execute some initial setup and cleanup

The installatio will download Splinter to `./splinter` directory and setup the first `config` file and `default` profile.

    # BASH & ZSH
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/marcomc/splinter-tools/master/install-splinter)"

    # FISH
    curl -fsSL https://raw.githubusercontent.com/marcomc/splinter-tools/master/install-splinter | /bin/bash

# Why would I use Splinter?

....

## What does Splinter do?
Spliter uses a bash script to install the minimum requirements to run Ansible within a dedicated Python environment, then run an Ansible playbook that will run the full provisioning of a macOS system

__BASH script__:
* Ask for current user password
  * will be used for sudo during the whole provisioning
* Enable passwordless sudo
* Check and fix install dir path permissions
* Install requirements
  * Conda or Pyenv and Homebrew
* Activate conda or pyenv
* Install python 3.x
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
* Install/Configure Hombrew:
  * Allow multi-user administration allowing all members of the chosen group to Read/Write (by default it is `admin` group)
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
  * Date & Time, Timezone & Formats
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
  * SetupAssistant (chose to skip some or all setup questions)
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

## Python

Python is provided by default via a custom [Conda package](https://github.com/marcomc/splinter-conda) or alternatively via on-the-fly Pyenv installation.

Having Python running within pre-configured project's specific environments means that the target system won't be polluted with any python package that might be undesired by the user.

To choose which python environment to run:

      ./plinter.sh --env [conda|pyenv] install .....

> `Conda` makes the provisioning dependencies installation much faster because comes in a preconfigured package `already loaded with Ansible` and doesn't require any Pip package installation.

## Provisioning
### Usage

    usage: ./splinter [option] action [object] [settings]

    options:
           -e|--env conda|pyenv     List available profiles
           --help                   Print help\
           --version                Print Splinter version and release date

    actions:
           list profiles            List available profiles
           provision [settings]     Provision the host\
           update <object>          Update the object

    obejcts:
           conda                    Reinstall the most recent Miniconda Python environment available for splinter
           pyenv                    Reinstall Pyenv Python environment
           galaxy|galaxy-roles      Force update all the Ansible Galaxy roles
           tools                    Update the splinter tools
           deps|dependencies        Update all the dependencies (Python envs and  Ansible Galaxy role)
           self|auto|splinter       Update Splinter itself (but not the tools or dependencies)
           profiles [settings]      Update the profiles from a online git repo (for now only github is supported)

    settings:
           [ provision ]
           -c file                  Specify a custom configuration file
           -u username              New user username (all lowercase  without spaces)
           -f 'Full Name'           New user full name (quoted if has blank spaces)
           -p 'cleartext password'  New user's password in cleartext (quoted if has blank spaces)
           -t username              Target user username, if different than the new user (can be used to provision the current account)
           -h Computer-Name         Computer host name, __no blank spaces allowed__
           -q                       Suppress all non-Ansible output (except errors and warnings), __is overriden with '-v'__
           -v                       Produce verbose output

           [ provision, update profiles ]
           -a account_name          Specify the the Github account name for the custom `splinter-profiles` repo
           -g git-repo-name         Specify the the Github repository name for the custom `splinter-profiles` repo
           -b profile_name          Specify the the BASE profile to be used (default: 'default')
           -r profile_name          Specify the the ROLE profile to be used


    Create your own profiles in the './profiles' directory.

### Pre-provisioning: manual steps

__On the old machine:__
1. preconfigure Splinter:
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

### Configuration

The required configuration settings are:

    verbose:                     yes
    base_profile:                "my-base-profile"
    role_profile:                "my-role-profile"
    create_new_user:             no
    new_user_username:           "newuser"
    new_user_fullname:           "New User"
    new_user_password_cleartext: "password"
    target_user_id:              "newuser"
    computer_name:               "My-New-Mac"

See the [content of config.yml](config.yml) for a detailed description of the parameters.

Splinter supports 3 levels of configurations listed here from least to most important:

1. `config.yml` - __optional__:


2. `<custom_config>.yml` - __optional__:

    you can have as many custom config YAML file with different sets of settings in case you need different kind of setup.

    To load your custom config file run:

            splinter provision -c <custom_config>.yml

    This will __completely override__ the values in `config.yml` (if present).

3. command line parameters:

   You can pass the above values as command line parameters to `splinter`

        splinter provision -v -u newuser -p password -f "New User" -b my-base-profile -r my-role-profile -h My-New-Mac -c <custom_config>.yml

   you can specify only some of those parameters and they will override any value contained in `config.yml` or `<custom_config>.yml`

   > when using the command line options `create_new_user` is assumed as `yes` if a `username` is provided

#### Profiles
Splinter supports 3 levels of profile listed here from least to most important:

1. `marcomc.splinter-toolkit default values`:
   This is a collection of sensible default values

2. `profiles/default`:
   This is a set of default values that you can _customise and rename as you prefer_.

   __The `default` profile is generally used as the `base` profile__

   If you are handling many different profiles i.e. `finance`, `developer`, `devops`, `fe-developer`, `marketing` you can have a base default set with the common company defaults to apply to all new machines.

3. `profiles/<role-profile>`:

    i.e. `finance`, `developer`, `devops`, `fe-developer`, `marketing`

    These are specific role profile where you can define only the settings that you want to customise for each role of machine or employee that will override some or all of the settings specified in your `base` profile.

### Provision

__On the new machine:__
1. Open the Terminal app (located in `/Applications/Utilities/`)

2. go to `splinter` directory, supposedly at `~/Downloads/splinter`

3. run `splinter`:

    ./splinter [options] provision [object] [settings]

4. Splinter will request you to enter the current user account (to be used as `sudo` password throughout the whole process).

5. the rest of the provisioning can be unattended but a few applications might require some system privacy authorisation, for instance `vagrant` and if you do not allow that in time and the installation fail you can re-run the `brew` installation command or re-run `splinter`

__During the deployment a few applications will request authorisation to run run so do not leave the computer completely unattended.__

### Post deployment manual steps

#### Authorise "Virtualbox" kext if you installed it via homebrew or macos_apps list

1. Go to System Preferences -> Security & Privacy -> General

2. Click the `Allow` button next to the request of authorisation for "Oracole America, Inc." software

3. re-run VirtualBox installation, this time it should succeed without errors

    > brew cask reinstall virtualbox

#### Fix "Sophos" installation

Follow Sophos guide to add all the required components to `System Preferences -> Security & Privacy -> Privacy`

If no Sophos guided steps window appear then:

1. Go to System Preferences -> Security & Privacy -> General

2. Click the `Allow` button next to the request of authorisation for "Oracole America, Inc." software

## License

MIT

## Copyright

Marco Massari Calderone <marco@marcomc.com>
The logo `MarcoMC_Apple_Sketch_Round` is a property and copyright of Marco Massari Calderone.

## Credits

### Inspiration

geerlingguy's [Mac Development Ansible Playbook](https://github.com/geerlingguy/mac-dev-playbook)

### Images
The Image [splinter_desktop.jpg](files/desktop_pictures/splinter_desktop.jpg) is an image by [Maaark](https://pixabay.com/users/Maaark-3329882/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=1693434) from [Pixabay](https://pixabay.com/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=1693434)
