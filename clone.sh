#! /bin/bash

# Author        :   Sagar Patel
# Version       :   1.1
# What?         :   This little script here is used to create a bootable copy of your boot drive. This will clone the system root folder (i.e. '/') to '$DEST'. You can change '$DEST' below to whatever drive you want.

# What's New?   :   -Adding the ability to have shutdown after cloning optional by passing arguments (i.e. '-s')
#                   -Adding the 'caffeinate' thing here rather than the '.profile' file.
#                   -Play "CLONE WARS.m4a". (It won't play if not present. Also, it's optional with '-m'.)
#                   -Now checking if the OS is OS X.
#                   -Check version with '-v'.
#                   -Adding a introductory 'Star Wars' music with title.
#                   -You can now kill the entire script with 'Ctrl+C'.

# VARIABLES
DEST="/Volumes/SSSD0/"
CLONE_WARS="/Users/sagarpatel/bin/CLONE WARS.m4a"
EXCLUDE_FILE="/Users/sagarpatel/bin/rsync_excludes.txt"
shutdownTimeout=1
shutdownOnCompletion=true
playMusic=true

clear

# Checking and setting the passed arguments
while [[ $# -ne 0 ]]; do
    case $1 in

        -m)
        playMusic=false
        echo "Okay, no music. You're such an bore-snore."
        ;;

        -s)
        shutdownOnCompletion=false
        echo "The system will not shut down on completion of cloning."
        ;;

        -v)
        echo "CLONE WARS v1.1"
        exit 5
        ;;

        *)
        echo "==========ERROR 3=========="
        echo "$1 is an invalid argument."
        exit 3
        ;;

    esac
    shift
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

if [ ! -f "$CLONE_WARS" ]; then
    playMusic=false
    echo "==========ERROR 4=========="
    echo "$CLONE_WARS not found, but that's cool we won't play it..."
fi

# ref. 10
# check to see of the OS is OS X (Darwin), as the script only supports OS X
if [ $(uname) != "Darwin" ]; then
    echo "==========ERROR 6=========="
    echo "This script only supports OS X (Darwin)."
    exit 6
fi

# used to 'trap' and kill the entire script with Ctrl+C. I have no idea how it works.
# ref. 12 & 13
exiting () {
    echo "Well, now that you want to exit... BYE."
    kill $afplayPID 2> /dev/null
    kill $caffeinatePID 2> /dev/null
#
#
# OVER HERE! UP THERE! the send stuff to /dev/null
#
#
    exit 7
}
trap exiting INT

# play the 'CLONE WARS' music
if [ $playMusic = "true" ]; then
    for i in {1..3}; do echo -n ". "; sleep 0.5; done
    afplay "$CLONE_WARS" & afplayPID=$!
    echo
    echo " ###### #      ###### #     # ######   #             #    #     ###### ###### "
    echo " #      #      #    # ##    # #         #     #     #    # #    #    # ##     "
    echo " #      #      #    # #  #  # #####      #   # #   #    #   #   ###### ###### "
    echo " #      #      #    # #    ## #           # #   # #    # ### #  # ##       ## "
    echo " ###### ###### ###### #     # ######       #     #    #       # #   ## ###### "
    echo
    echo "CLONE WARS v1.1"
    echo
fi

# prevent system from going into idle sleep (using 'caffeinate' instead of 'pmset idle' because it is deprecated in favour of the former.)
# ref. 7
caffeinate -i & caffeinatePID=$!

# hey, I removed '-i' after sudo (and before 'rsync') for debugging.
# UPDATE : It works good, seems like it'll be okay without '-i'.
sudo rsync -vaxE --progress --delete --exclude-from="$EXCLUDE_FILE" / "$DEST"
echo "==========Finished copying=========="
echo "==========Blessing the CoreServices...=========="
sudo bless -folder "$DEST"/System/Library/CoreServices && echo "==========Blessed the CoreServices.=========="
diskutil eject "$DEST"
kill "$caffeinatePID"

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

# EXIT/ERROR CODES
# 0 : Cloned Successfully
# 1 : The destination volume, $DEST, was not present. (Note: $DEST is the destination volume)
# 2 : 'clone' needs to be run as root. (ie. use 'sudo clone')
# 3 : An invalid argument was passed.
# 4 : '$CLONE_WARS' was not found. Look for it.
# 5 : Printed version number and exited.
# 6 : The script only supports OS X (Darwin)
# 7 : The script was killed while working.