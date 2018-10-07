#!/bin/bash
# get base dir regardless of execution location
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCE=$([[ "$SOURCE" = /* ]] && echo "$SOURCE" || echo "$PWD/${SOURCE#./}")
basedir=$(dirname "$SOURCE")
. $basedir/scripts/init.sh

case "$1" in
    "rb" | "rbp" | "rebuild")
    (
        "$basedir"/scripts/rebuildPatches.sh "$2" || exit 1
    );;
    "p" | "patch" | "apply")
    (
        "$basedir"/scripts/apply.sh "$2" || exit 1
    );;
    "setup")
    (
        "$basedir"/scripts/setup.sh || exit 1
    );;
    "alias")
    (
        if [[ -f ~/.bashrc ]]; then
            NAME="forker"
            if [[ ! -z "${2+x}" ]]; then
                NAME="$2"
            fi
            (grep "alias $NAME=" ~/.bashrc > /dev/null) && (sed -i "s|alias $NAME=.*|alias $NAME='. $SOURCE'g" ~/.bashrc) || (echo "alias $NAME='. $SOURCE'" >> ~/.bashrc)
            alias "$NAME=. $SOURCE"
            echo "You can not just type '$NAME' at any time to access the forker tool."
        fi
    )
esac