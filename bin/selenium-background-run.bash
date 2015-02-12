#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '' > nohup.out
nohup $DIR/selenium-run.bash "$@" &
sleep 1

cat nohup.out
echo "

Selenium Running"