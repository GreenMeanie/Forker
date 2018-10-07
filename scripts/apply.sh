#!/bin/bash
# get base dir regardless of execution location
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
. $(dirname ${SOURCE})/init.sh

PS1="$"

function resetProject {
    cd "$basedir"
    rm -r "$basedir/Forks/$1"
    cp -r "$basedir/Upstreams/$1" "$basedir/Forks/$1"

    forkUrl=$(./init.sh getForkUrl "$1")
    cd "$basedir/Forks/$1" && git remote set-url origin ${forkUrl}
}

function applyPatches() {
    echo "Applying Patches..."

    cd "${basedir}/Forks/$1"
    git fetch --all
    git branch -f upstream HEAD > /dev/null

    echo "Resetting $1 to Upstream..."
    git checkout master 2>/dev/null || git checkout -b master
    git fetch upstream > /dev/null 2>&1
    git reset --hard upstream/master

    echo "  Applying patches to $1..."
    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/patches/$1/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $1."
        echo "  Please review the above details and finish the apply,"
        echo "  then save the changes with 'forker rebuild $1'"
        exit 1
    else
        echo "  Patches cleanly applied to $1"
    fi
}

applyPatches "$1"