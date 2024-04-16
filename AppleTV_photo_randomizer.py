#!/usr/bin/python3
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


import os
import time
from random import shuffle
from datetime import datetime

## Input options
# photo extensions, .mov not supported in screensaver but can be viewed through Computer --> Photos
photo_ext = ('.jpg', '.jpeg', '.png', '.heic', '.mov' )
photo_root = "/PATH/TO/PICTURES"
photo_subdir = ""
photo_pool = "Apple TV Photos"
cache_dir = "Apple TV Photo Cache"
pool_size = 250

exclude_files = ( '.DS_Store', '.metadata_never_index' )
exclude_dirs = [ cache_dir, photo_pool ]

pool_list = []


def walk_tree_build_picture_list():
    for root, dirs, files in os.walk( os.path.join(photo_root, photo_subdir), topdown=True ):  # , followlinks=True ):
        dirs[:] = [ d for d in dirs if d not in exclude_dirs ]
        photo_list = [ os.path.join( root, f ) for f in files if( os.path.splitext(f)[1].lower() in photo_ext ) ]
        # and f not in exclude_files ) ]
        #photo_list = [ f for f in photo_list if f not in exclude_files ]
        if( photo_list ):
            pool_list.extend( photo_list )
    print( f"{datetime.now()}: {len( pool_list )} photos in list." )


def select_random_subset():
    shuffle( pool_list )
    return pool_list[0:pool_size]


def link_to_photo_pool( filename ):
    dest_filename = str( abs( hash( filename ) ) ) + os.path.basename( filename )
    os.symlink( filename, os.path.join( photo_root, photo_pool, dest_filename ) )
    # include edit lists (.aae files)
    edits_filename = os.path.join( photo_root, photo_pool, os.path.splitext( filename )[1], "aae" )
    if( os.path.exists( edits_filename ) ):
        os.symlink( edits_filename, os.path.join( photo_root, photo_pool ) )


def clear_pool():
    for root, dirs, files in os.walk( os.path.join( photo_root, photo_pool ), topdown=False, followlinks=False ):
        for f in files:
            os.remove( os.path.join( root, f ) )


def clear_cache():
    cache_filename = os.path.join( photo_root, cache_dir, "Apple TV Photo Database" )
    if( os.path.exists( cache_filename ) ):
        os.remove( cache_filename )


def restart_itunes():
    os.system( """osascript -e 'tell app "iTunes" to quit'""" )
    time.sleep( 100 )
    os.system( """osascript -e 'tell app "iTunes" to activate'""" )


def rebuild_photo_database():
    os.system( """cd "INSTALL_DIR" && osascript rebuild_photo_database.applescript""")


if __name__ == "__main__":
    walk_tree_build_picture_list()
    
    new_pool = select_random_subset()
    
    # clear pool directory
    clear_pool()
    
    # create new links
    for item in new_pool:
        link_to_photo_pool( item )
 
    # clear AppleTV cache
    clear_cache()

    # restart iTunes to recreate cache (Mojave and older)
    #restart_itunes()
    
    # recreate the cache (Catalina and newer)
    rebuild_photo_database()
