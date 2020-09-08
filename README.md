# Splinter - Ansible Automated macOS Provisioning

![Splinter Logo](files/splinter_logo.png)

## Pre-Deployment manual steps

Add `Terminal` application to the "Full Disk Access" policy
Make sure that the directory where you are running the script from has "Read Write Exec" permissions for the group 'staff'. The setup script will anyway

## Setup

sh setup.sh
enter the current user password
wait for Command Line Tools for Xcode installation to begin and confirm the operation

During the deployment a few applications will request authorisation to run run so do not leave the computer completely unattended.

# Post deployment manual steps

## Authorise "Virtualbox" kext if you installed it via homebrew or macos_apps list
1. Go to System Preferences -> Security & Privacy -> General
2. Click the `Allow` button next to the request of authorisation for "Oracole America, Inc." software
3. re-run VirtualBox installation, this time it should succeed without errors

    > brew cask reinstall virtualbox

## Add "Sophos" to privacy policies
Follow Sophos guide to add all the required components to `System Preferences -> Security & Privacy -> Privacy`



# License

MIT

# Copyright

Marco Massari Calderone <marco@marcomc.com>
The logo `MarcoMC_Apple_Sketch_Round` is a property and copyright of Marco Massari Calderone.
