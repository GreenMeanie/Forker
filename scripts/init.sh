#!/bin/bash

# get base dir regardless of execution location
SOURCE="${BASH_SOURCE[0]}"
sourceBase=$(dirname ${SOURCE})/../
basedir=$(pwd -P)
cd ${basedir:-$sourceBase}

function getForkUrl {
    forkUrl=$(cd "$basedir/Forks/$1" && git remote get-url --push origin)
    echo ${forkUrl}
}

function cleanupPatches {
    cd "$1"
    for patch in *.patch; do
        gitver=$(tail -n 2 $patch | grep -ve "^$" | tail -n 1)
        diffs=$(git diff --staged $patch | grep -E "^(\+|\-)" | grep -Ev "(From [a-z0-9]{32,}|\-\-\- a|\+\+\+ b|.index|Date\: )")
        testver=$(echo "$diffs" | tail -n 2 | grep -ve "^$" | tail -n 1 | grep "$gitver")

        if [ "x$testver" != "x" ]; then
            diffs=$(echo "$diffs" | tail -n +3)
        fi

        if [ "x$diffs" == "x" ] ; then
            git reset HEAD ${patch} >/dev/null
            git checkout -- ${patch} >/dev/null
        fi
    done
}

function push {
    pushUrl=$(getForkUrl "$1")
    echo "Pushing - $1 to $pushUrl"
    (cd "$basedir/Forks/$1" && git push -f)
}