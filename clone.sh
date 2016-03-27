#! /bin/bash

# Author    :   Sagar Patel
# Version   :   1.0
# What?     :   This little script here is used to create a bootable copy of your boot drive. This will clone the root folder (i.e. '/') to '$DEST'. You can change '$DEST' below to whatever drive you want.

# VARIABLES
DEST="/Volumes/SSSD0"
shutdownTimeout=1

# ref. 4
if [ ! -d "$DEST" ]
then
	echo "==========ERROR 1=========="
	echo "$DEST not present."
	exit 1
fi

# ref. 1, 2 & 5
if [ $(id -u) -ne 0 ]
then
	echo "==========ERROR 2=========="
	echo "Please run as root."
	exit 2
fi


sudo -i rsync -vaxE --progress --delete --exclude-from=$HOME/rsync_excludes.txt / "$DEST" &&
echo "==========Blessing the CoreServices...==========" &&
sudo bless -folder "$DEST"/System/Library/CoreServices &&
diskutil eject /Volumes/SSSD0/

# ref. 3
sudo shutdown -h +"$shutdownTimeout" "==========Cloning Complete=========="
exit 0


# SOURCES
# http://serverfault.com/questions/269996/optimal-backup-to-swappable-hard-drive-with-rsync-on-osx
# https://bombich.com/kb/ccc4/some-files-and-folders-are-automatically-excluded-from-backup-task

# 1. For if conditions
# http://stackoverflow.com/questions/18928260/if-command-with-user-input-osx-terminal

# 2. For checking if current user is root
# http://stackoverflow.com/questions/6362428/how-do-i-determine-if-a-shell-script-is-running-with-root-permissions

# 3. Shutting down computer
# http://apple.stackexchange.com/questions/103571/using-the-terminal-command-to-shutdown-restart-and-sleep-my-mac

# 4. Checking if directory exists
# http://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script

# 5. If condition operators
# https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/test.1.html

# 6. Creating Aliases in Terminal
# http://computers.tutsplus.com/tutorials/speed-up-your-terminal-workflow-with-command-aliases-and-profile--mac-30515

# EXIT CODES
# 0 : Cloned Successfully
# 1 : The destination volume, $DEST, was not present. (Note: $DEST is the destination volume)
# 2 : 'clone' needs to be run as root. (ie. use 'sudo clone')
