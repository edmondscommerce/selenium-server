#!/usr/bin/env bash
DIR=$(dirname $(readlink -f "$0"))
cd $DIR

source ./download-binaries.bash

echo '' > nohup.out
echo "
Starting Selenium in the Background
"
nohup $DIR/selenium-run.bash "$@" &

sleep 2

cat nohup.out

echo "
Selenium Running
"
