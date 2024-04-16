# AppleTV_photo_randomizer

Maintained by [proan]{https://github.com/proan}
License: GPL-3.0-or-later

The AppleTV3 can display photos on the screen saver if those photos are shared
from another Mac using Media Sharing. However, the AppleTV will only select 100
or so photos and never update them even as new photos are added. This repo
contains a set of scripts that when installed will create a special folder for
sharing with the AppleTV and populate it with a random assortment of aliases
to pictures in the larger photo library.

These scripts leverage launchctl to run every night, by default a 1:41 am, so
that the photos available to th AppleTV are different each day.

Quicktime movie (`.mov`) files are included as they can be viewed on the AppleTV
even if they will not be shown in the screensaver.

These scripts have been tested on macOS Monterey (12.7.4).

## Installation

1. Clone this repo.
2. Locate the folder that contains all of your photos. These photos can all be
   in one folder or contained in folders or a combination.
3. From this repo, run `./install.sh /path/to/photos` to install. This will copy
   the scripts to the current user's Library and update them to point at the
   provided folder full of photos.
4. You will be prompted to allow Terminal.app, Script Editor.app, and/or python3
   to control your computer. Please agree, otherwise the scripts will fail.
5. Open _System Preferences_ -> _Sharing_ -> _Media Sharing_ and enable
   _Home Sharing_ and _Share photos with Apple TV_. Use the "Choose..." button
   to select the "Apple TV Photos" folder located in "/path/to/photos" folder
   provided to the install script.

By default, the scripts are installed into the current user's Library folder:
`~/Library/Application Scripts/local.AppleTV_photo_randomizer`. This location
can be changed by editing install.sh and changing the environment variable
`INSTALL_LOCATION`.

## Log Files

Standard output and errors are all reported into the same log file by default.
Standard output should consist of a timestamp and a number of photos processed
each time the script runs.

Default log file location is `~/Library/Logs/AppleTV_photo_randomizer/log.log`

## Uninstalling

The installation script creates an `uninstall.sh` in the installation location.
Run this script to unload the launchctl item and then remove all directories
except the location of the cloned sources.

Uninstalling does not revoke the granted permissions in _System Preferences_ ->
_Security & Privacy_ -> _Privacy_ -> _Accessibility_.

## Suggestions and Bug Reports

Bug Reports, Suggestions, and feedback can be made through Github's issue tracker.

### Partially Implemented Features

Some features that are partially implemented include narrowing the pool of
available photos to just a single subdirectory. Useful for showing highlights
of a recent trip or event. Another partially implemented feature involves
adding a list of subdirectories to exclude from the available photo pool.

## Miscellaneous Notes

The python script will refresh the aliases in the "Apple TV Photos" folder but
is not sufficient to rebuild the database that the AppleTV references. This
database lives in the "Apple TV Photo Cache" folder in the base photos folder.
For macOS versions Mojave and older, restarting iTunes is sufficient to rebuild
the database. If you'd like to enable this behavior, uncomment the
`restart_itunes()` line in the python script.

In early versions of Monterey, the database rebuild could be triggered from the
command line by using `launchctl` to restart the AMPLibraryAgent:
```
#os.system( """launchctl stop com.apple.AMPLibraryAgent""" )
#time.sleep( 10 )
#os.system( """launchctl start com.apple.AMPLibraryAgent""" )
```
However, in 12.7.4, the normal user is not permitted to restart the
AMPLibraryAgent. I have resorted to using the included AppleScript to open
System Preferenes and toggling the "Share photos with Apple TV" checkbox. I
have traced this behavior to see the important console entry for the
AMPLibraryAgent to `ampld> enablePhotoSharingWithSourceID`, but I am not sure
how to send this message from the command line or python. The name of the
service in Console is "gui/$UID/com.apple.AMPLibraryAgent".

There might be away to edit the sharing preferences plist and having that
trigger a rebuild, but I haven't been able to make that work.
```    
$> defaults read com.apple.preferences.sharing.SharingPrefsExtension

{
    homeSharingUIStatus = 1;
    legacySharingUIStatus = 1;
    mediaSharingUIStatus = 1;
}
```
Found 1 keys in domain `com.apple.amp.mediasharingd`
```
$> defaults write com.apple.amp.mediasharingd "photo-sharing-enabled" -bool true
```
