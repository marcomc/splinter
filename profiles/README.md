The `yml` configuration files contained in `profiles/default/` will always be loaded independently of the chosen profile.

According to the profile you have selected like `developer` or any other custom profile, the options redefined in new `yml` config files will override the values loaded with the default files.

That means that inside your chosen profiles you only need to create configuration files that contain the options that you want to override (without the need to copy also options that won't differ from the default values). 
