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

function setup() {
    echo "Enter the Project's name"
    read projectName

    echo "Enter the Upstream URL"
    read upstreamURL

    echo "Enter the Fork URL"
    read forkURL

    git clone ${upstreamURL} "Upstreams/$projectName"
    cp -r "Upstreams/$projectName" "Forks/$projectName"
    (cd "Forks/$projectName" && git remote add upstream "../../Upstreams/$projectName" && git remote set-url origin ${forkURL})

    commit="$( cd $basedir/Upstreams/$1 && git log -1 --pretty=%H )"
    echo "{'upstream': '$projectName', 'commit': '${commit}'" >> "Upstreams/upstreams.forker"
}

setup