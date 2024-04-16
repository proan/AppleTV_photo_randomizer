#!/bin/bash
#
# Copyright © 2024 Philip Roan
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


if [[ "$#" -ne 1 ]]; then
    echo "Wrong number of arguments."
    echo "If your path contains spaces, wrap it in quotation marks."
    echo "Usage: ./install.sh /path/to/photos"
    exit 1
fi
PHOTO_LOCATION=$1
if [[ ! -d "$PHOTO_LOCATION" ]]; then
  echo "$PHOTO_LOCATION does not exist. Ensure that the folder entered exists on this system."
  exit 2
fi
mkdir -p "$PHOTO_LOCATION/Apple TV Photos"

# Set preferred installation location. Should be r/w for the current user
INSTALL_LOCATION="$HOME/Library/Application Scripts/local.AppleTV_photo_randomizer"

# Copy files
mkdir -p "$INSTALL_LOCATION"
cp ./uninstall.sh "$INSTALL_LOCATION"
cp ./rebuild_photo_database.applescript "$INSTALL_LOCATION"
cp ./AppleTV_photo_randomizer.py "$INSTALL_LOCATION"

# Replace temporary text with the actual installation directory and user id
sed -i '' "s|/PATH/TO/PICTURES|$PHOTO_LOCATION|g" "$INSTALL_LOCATION"/AppleTV_photo_randomizer.py
sed -i '' "s|INSTALL_DIR|$INSTALL_LOCATION|g" "$INSTALL_LOCATION"/*
sed -i '' "s|CURRENT_USER|$HOME|g" "$INSTALL_LOCATION"/uninstall.sh
sed -i '' "s|UID|$UID|g" "$INSTALL_LOCATION"/uninstall.sh

# Allow Python file to be executable
chmod 755 "$INSTALL_LOCATION"/AppleTV_photo_randomizer.py

# Make log file directory. At this time all output and errors are in the same file
mkdir ~/Library/Logs/AppleTV_photo_randomizer

# Create the new LaunchAgent to run nightly, and point it to the installed script
cp ./local.AppleTV_photo_randomizer.plist $HOME/Library/LaunchAgents
sed -i '' "s|INSTALL_DIR|$INSTALL_LOCATION|g" $HOME/Library/LaunchAgents/local.appleTV_photo_randomizer.plist
sed -i '' "s|CURRENT_USER|$HOME|g" $HOME/Library/LaunchAgents/local.appleTV_photo_randomizer.plist


# Launch the agent in the current user's space
launchctl bootstrap gui/"$UID" $HOME/Library/LaunchAgents/local.AppleTV_photo_randomizer.plist
launchctl start local.AppleTV_photo_randomizer
