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


# If you want to remove the AppleTV_photo_randomizer LaunchAgent,
# run this script from a terminal window: `$ ./uninstall.sh`

# Stop and remove the LaunchAgent
launchctl bootout gui/UID/local.AppleTV_photo_randomizer

# Uninstall all files and logs
rm "CURRENT_USER"/Library/LaunchAgents/local.AppleTV_photo_randomizer.plist
rm -rf -- "CURRENT_USER"/Library/Logs/AppleTV_photo_randomizer/

if [[ "$PWD" -ef "INSTALL_DIR" ]]; then cd ..; fi
rm -rf -- "INSTALL_DIR"
