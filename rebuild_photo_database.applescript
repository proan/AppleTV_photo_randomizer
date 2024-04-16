#!/usr/bin/osascript
#
# Copyright (c) 2024 Philip Roan
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


tell application "System Preferences"
	activate
    # It can take a while for the System Preferences to load, espcially if waking from sleep
	repeat until application "System Preferences" is running
		delay 0.25
	end repeat
	reveal pane id "com.apple.preferences.sharing"
    # Similar to above, delay until the Sharing pane is shown
	repeat until name of window 1 is "Sharing"
		delay 0.25
	end repeat
end tell
tell application "System Events" to tell process "System Preferences"
	set working_area to group 1 of window "Sharing"
	
	# Find the "Media Sharing" options in the Sharing pane.
	# If the name changes or a different list of options is desired, dump all
	# visible items with `entire contents of group 1 of window "Sharing"`
	repeat with r in rows of table 1 of scroll area 1 of working_area
		if (value of static text of r as text) starts with "Media" then
			select r # Show all the Media Sharing options
			exit repeat
		end if
	end repeat
	
	# Media Sharing options should now be available for selecting
	# Use a variable to point to the photo sharing checkbox
	set x to checkbox "Share photos with Apple TV" of working_area
    set database_rebuild_triggered to false
    # If photo sharing with Apple TV is active, rebuild the database
    if value of x is 1 then
		click x
		delay 1
		click x
        set database_rebuild_triggered to true
	end if
	
    # Close System Preferences and post a notification to indicate this script has been executed
	tell application "System Preferences" to quit
    if database_rebuild_triggered then
        display notification "Triggered database rebuild" with title "Apple TV Photo Randomizer"
    end if
end tell
