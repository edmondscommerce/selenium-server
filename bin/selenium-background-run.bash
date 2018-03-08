#!/usr/bin/env bash
source="${BASH_SOURCE[0]}"
while [ -h "$source" ]; do # resolve $SOURCE until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$source" )" && pwd )"
cd $dir;

source ./download-binaries.bash

echo '' > nohup.out
echo "
Starting Selenium in the Background
"
nohup $dir/selenium-run.bash "$@" &

sleep 2

cat nohup.out

echo "
Selenium Running
"
