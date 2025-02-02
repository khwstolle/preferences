#!/bin/sh
#
# Simple script to run a git command in directories relative to the working directory
#
# Usage: git-subdirs.sh <command> [@] [<directory> ...]
#
# Example: git-subdirs.sh status dir1 dir2
# Example: git-subdirs.sh pull dir1 dir2
# Example: git-subdirs.sh commit -m "Message" @ dir1 dir2
#
# The '@' symbol is used to separate the command from the directories.
# If no directories are provided, the command is ran on all subdirectories that are git repositories.
# If directories are provided, the command is ran on those directories only.
#
set -e

# Get the command and the directories
command=$1

# Append to the command until the '@' symbol is found or the end of the arguments
while [ $# -gt 0 ]; do
    shift
    if [ "$1" = "@" ]; then
        # If @ is found, then subsequent arguments are directories
        shift
        if [ $# -eq 0 ]; then
            dirs=$(find . -maxdepth 1 -type d -exec test -e '{}/.git' ';' -print)
        else
            dirs=$@
        fi
        break
    else
        # If the argument is not '@', then append it to the command
        command="$command $1"
    fi
done


# Run the command in each directory
set +e
for dir in $dirs; do
    echo "+ cd $dir && git $command"
    (cd $dir && git $command)
done
