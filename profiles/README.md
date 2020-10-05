__You can create a set of custom profiles for Splinter and upload them to GitHub on a private or public repository.__

You can use these profiles to:
* share a standardise set of settings for your Macs across your organisation

or if you are a home user to:
* keep different profiles for different Macs: your own, your partner, your kids
* to reuse in time your favourite sets of configurations
  * when your a configuring a new Mac
  * when you want to restore your current Mac

# Custom Profiles Repository content

A custom profiles repository can contains __some or all of the below content__

* a `base` profile that can be your unique profile or the common foundation for your role profiles
* one or more `role` profiles that represent a person, a person role or a computer role
* supporting `files` :
  * FileVault2  encryption `certificates` (the public cert)
  * an export of your personal `prefereces` (created via `./splinter export preferences`)
  * the `lists` of your desidered packages and apps
  * the `pictures` for your desktop and profiles

        # example of a private `splinter-profiles` repository

        ├── files
        │   ├── certificates
        │   │   └── FileVaultMaster.der.cer
        │   │
        │   ├── preferences (backup of your dotfiles and preferences)
        │   │   ├── Accounts
        │   │   ├── StartupItems
        │   │   ├── app_store_preferences
        │   │   ├── dotfiles
        │   │   ├── preferences
        │   │   ├── shared_file_lists
        │   │   ├── ssh
        │   │   └── system_preferences
        │   │
        │   ├── lists
        │   │   ├── homebrew_cask_apps.txt
        │   │   ├── homebrew_packages.txt
        │   │   ├── homebrew_taps.txt
        │   │   ├── mas_apps.txt
        │   │   └── npm_global_packages.json
        │   │
        │   ├── desktop_pictures
        │   │   └── my-wallpaper.jpg
        │   │
        │   └── profile_pictures
        │       └── company-logo.png
        │
        ├── base (base profile to use across all your provisionings)
        │   ├── current_user.yml
        │   ├── dotfiles.yml
        │   ├── extra_packages.yml
        │   ├── filevault.yml
        │   ├── homebrew.yml
        │   ├── mac_app_store.yml
        │   ├── macos_apps.yml
        │   ├── modules.yml
        │   ├── new_user.yml
        │   ├── post_provision.yml
        │   ├── sophos_endpoint.yml
        │   ├── ssh_config.yml
        │   └── system_preferences.yml
        │
        └── developer (role profile to be used for specific provisionings)
            ├── dotfiles.yml
            ├── extra_packages.yml
            ├── filevault.yml
            ├── general.yml
            ├── homebrew.yml
            ├── modules.yml
            ├── new_user.yml
            ├── non_mas_apps.yml
            ├── ssh_config.yml
            └── system_preferences.yml

# Custom profiles and repository naming

A custom profile can be named anything.

Also a custom profiles repository can be named anything you like. But you will make thing easier if you name your repository `splinter-profiles`.

> Splinter will by default will look for a repository named `splinter-profiles`

Let's assume that:
* you have named your repository `splinter-profiles` in your
* your GitHub account name `my-account`
* you have created a base profile called `my-base-profile`
* you have created a role profile called `my-work-profile`
* you have uploaded a few supporting files in `files`

your repository will look like this:

    https://github.com/my-account/splinter-profiles
        ├── files
        │   ├── lists
        │   │   └── ...
        │   └── profile_pictures
        │       └── ...
        ├── my-base-profile
        │   └── ...
        └── my-work-profile
            └── ...

If you want to name your custom profiles repository with a custom name when you are about to download it you will have to specify the Github repository name in the `splinter.cfg` file or in the command line `-g <git-repo-name>`

      # example
      # repo name: `https://github.com/my-account/custom-profiles-repo`

      ./splinter provision -a my-account -g custom-profiles-repo -r my-work-profile

# Using custom profiles

When you want to use your profiles on a new provisioning you have two options:
* Download you custom-profile when building a provisioning package
* Fetch the custom profile on-the-fly during the provisioning

When a profile has been downloaded by Splinter it will be stored in the Splinter project's `profiles` directory:
* the supporting `files` will be merged with the content of `./profiles/files` in your project dir
* the profiles will be saved in `./splinter/profiles` and named as `<account-name>.<profile-name>`

according to our example your profiles will look like this:

    ./profiles/
      ├── my-account.my-base-profile
      │   └── ...
      └── my-account.my-work-profile
          └── ...s

> this facilitate the use of profiles coming from difference GitHub accounts and avoid name conflicts

## Download you custom-profile

You can download:
* the full set of your profiles from a GitHub repository: will also download all the supporting files

    ./splinter update profiles

* only one specific profile: will not download the supporting files

      # explicit form
      ./splinter update profiles -a my-account -r my-work-profile

      # compact form
      ./splinter update profiles -r my-account.my-work-profile


## Fetch the custom profile on-the-fly

Custom profile can be downloaded on-the-fly when provisioning.

> You can specify at the same what `base` ( -b ) and what `role` ( -r ) profiles you whant to use

      # explicit form
      ./splinter provision -a my-account -b my-base-profile -r my-work-profile

      # compact form
      ./splinter provision -b my-account.my-base-profile -r my-account.my-work-profile
