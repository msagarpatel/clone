#! /bin/bash

# Author        :   Sagar Patel
# Version       :   1.3.1
# Date          :   Apr 13, 2017
# What?         :   This little script here is used to create a bootable copy of your boot drive. This will clone the system root folder (i.e. '/') to '$DEST'. You can change '$DEST' below to whatever drive you want.

# What's New?   :   -added the file in the root of the clone called 'DATEandTIME.txt'. It contains the date and time the clone was completed.

# VARIABLES
DEST="/Volumes/SSSD0"
DISK=$(diskutil info $DEST | grep -h -m 1 'APFS Physical Store' | egrep -o 'disk[0-9]+')
EXCLUDE_FILE="$HOME/bin/clone/rsync_excludes.txt"
shutdownTimeout=1
shutdownOnCompletion=false
VERSION="CLONE WARS v1.3.1"

clear

# used to 'trap' and kill the entire script with Ctrl+C. I have no idea how it works.
# ref. 12 & 13
exiting () {
echo "Well, now that you want to exit... BYE."
kill $caffeinatePID 2> /dev/null
exit 7
}
trap exiting INT

# show the version in a ridiculous way
showVersion() {
echo
echo " ###### #      ###### #     # ######   #             #    #     ###### ###### "
echo " #      #      #    # ##    # #         #     #     #    # #    #    # #      "
echo " #      #      #    # #  #  # #####      #   # #   #    #   #   ###### ###### "
echo " #      #      #    # #    ## #           # #   # #    # ### #  # ##        # "
echo " ###### ###### ###### #     # ######       #     #    #       # #   ## ###### "
echo
echo $VERSION
echo
}

# Checking and setting the passed arguments
# ref. 14
# OLD : while [[ $# -ne 0 ]]; do
while getopts sv option; do
    case $option in

        s)
        shutdownOnCompletion=true
        echo "The system will shut down on completion of cloning."
        ;;

        v)
        showVersion
        exit 0
        ;;

        *)
        echo "==========ERROR 3=========="
        echo "You have entered an invalid option."
        exit 3
        ;;

    esac
done

# ref. 4
if [ ! -d "$DEST" ]; then
	echo "==========ERROR 1=========="
	echo "$DEST not present."
	exit 1
fi

# ref. 1, 2 & 5
if [ $(id -u) -ne 0 ]; then
	echo "==========ERROR 2=========="
	echo "Please run as root."
	exit 2
fi

if [ ! -f "$EXCLUDE_FILE" ]; then
    echo "==========ERROR 8=========="
    echo "$EXCLUDE_FILE not found."
    echo "This file tells 'rsync' what not to copy from the hard drive."
    echo "If not present, it will copy every file on the hard drive, which is not recommended."
    exit 8
fi

showVersion

# prevent system from going into idle sleep (using 'caffeinate' instead of 'pmset idle' because it is deprecated in favour of the former.)
# ref. 7
caffeinate -d & caffeinatePID=$!

# finding out the time taken for the cloning to complete.
# ref. 15
SECONDS=0

sudo rsync -vaxEHh --progress --delete --stats --itemize-changes --exclude-from="$EXCLUDE_FILE" / "$DEST"
echo
echo "==========Finished copying=========="
sudo bless -folder "$DEST"/System/Library/CoreServices
echo "==========Blessed the CoreServices=========="

# calculating and displaying time taken for cloning.
# ref. 15
duration=$SECONDS
echo
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
# store the date of the clone in file 'DATEandTIME.txt' in root.
date > "$DEST"/DATEandTIME.txt
echo "Just a bit more time"

sleep 10
diskutil eject $DISK
kill "$caffeinatePID"
echo "Completed at $(date)"

# ref. 3 & 8
if [ $shutdownOnCompletion = "true" ]; then
    sudo shutdown -h +"$shutdownTimeout" "==========Cloning Complete=========="
fi
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

# 7. Preventing idle sleep within bash script
# http://superuser.com/questions/99247/stop-a-mac-from-sleeping-while-a-bash-script-is-running-then-allow-it-to-sleep/807193#807193

# 8. Parseing multiple options in bash
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# 9. Playing music from terminal
# http://osxdaily.com/2010/12/07/command-line-mp3-player-in-mac-os-x/

# 10. Find out firmware (or OS, whatever) to see surport for script
# http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script

# 11. Debugging Bash script
# http://www.cyberciti.biz/tips/debugging-shell-script.html

# 12. Trapping and killing an entire bash script
# http://unix.stackexchange.com/questions/48425/how-to-stop-the-loop-bash-script-in-terminal

# 13. Exit traps
# http://redsymbol.net/articles/bash-exit-traps/

# 14. Using 'getopts' for extracting options from parsed arguments
# http://wiki.bash-hackers.org/howto/getopts_tutorial

# 15. Finding out time elapsed in a bash script
# http://stackoverflow.com/questions/8903239/how-to-calculate-time-difference-in-bash-script


# EXIT CODES
# 0 : No problems
# 1 : The destination volume, $DEST, was not present.
# 2 : 'clone' needs to be run as root. (ie. use 'sudo clone')
# 3 : An invalid argument was passed.
# 4 : (removed) '$CLONE_WARS' was not found. Look for it.
# 5 : (removed) Printed version number and exited.
# 6 : (removed) The script only supports OS X (Darwin)
# 7 : The script was killed while working.
# 8 : '$EXCLUDE_FILE' was not found at the set location.
