#!/bin/bash
# get base dir regardless of execution location
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
. $(dirname $SOURCE)/init.sh

PS1="$"

function savePatches {
    echo "Rebuilding patch files from current fork state..."
    cd "$basedir/Forks/$1"

    mkdir -p "$basedir/patches/$1"
    if [ -d ".git/rebase-apply" ]; then
        # in the middle of a rebase, be smarter
        echo "REBASE DETECTED - PARTIAL SAVE"
        last=$(cat ".git/rebase-apply/last")
        next=$(cat ".git/rebase-apply/next")
        declare -a files=("$basedir/patches/$1"*.patch)
        for i in $(seq -f "%04g" 1 1 $last)
        do
            if [ $i -lt $next ]; then
                rm "${files[`expr $i -1`]}"
            fi
        done
    else
        rm "$basedir/patches/$1/"*.patch
    fi

    git format-patch --quiet -N -o "$basedir/patches/$1" upstream/master
    cd "$basedir"
    cleanupPatches "$basedir/patches/$1/"
    echo "  Patches saved for $1"
}

savePatches "$1"

push "$1"