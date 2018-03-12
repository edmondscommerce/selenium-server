#!/usr/bin/env bash
source="${BASH_SOURCE[0]}"
while [ -h "$source" ]; do # resolve $SOURCE until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$source" )" && pwd )"
cd $dir;
set -e
set -u
set -o pipefail
standardIFS="$IFS"
IFS=$'\n\t'
echo "
Checking Dependencies Installed
"
function checkInstalled(){
    checkFor="$1"
    set +e
    if ! command -v "$checkFor"
    then
        printf "\nERROR:\nCommand $checkFor not available, please install it and try again\n\n"
        exit 1
    fi
}

checkInstalled "unzip"
checkInstalled "java"

echo "
DONE Checking Dependencies
"
