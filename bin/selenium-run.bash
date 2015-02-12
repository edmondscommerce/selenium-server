#!/bin/bash
DIR="$( cd -p "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../binaries/
MAJOR_VERSION=2.44
VERSION=${MAJOR_VERSION}.0
JAR_FILE=selenium-server-standalone-${VERSION}.jar

CHROMEDRIVER_VERSION=2.14
CHROMEDRIVER_FILE=chromedriver-${CHROMEDRIVER_VERSION}

## Host File bug sanity check
grep '127.0.0.1 localhost' /etc/hosts > /dev/null
if [[ $? != 0 ]]
then
    echo "

    WARNING

    Selenium won't work unless your hosts file localhost aliases start explictly with:

    127.0.0.1 localhost ...other aliases here

    Please edit your hosts file and try again

    See:
    https://code.google.com/p/selenium/issues/detail?id=3280

Your hosts line is:
    "
    grep '127.0.0.1' /etc/hosts
    echo;
    exit 1
fi

if [ ! -f $JAR_FILE ]
then
    echo "Selenium JAR file not found - trying to wget the file"
    DOWNLOAD_URL="http://selenium-release.storage.googleapis.com/${MAJOR_VERSION}/selenium-server-standalone-${VERSION}.jar"
    echo $DOWNLOAD_URL
    wget $DOWNLOAD_URL
    if [[ $? != 0 ]]
    then
        echo "Failed downloading, please grab it manually"
        exit 1
    fi
fi

if [ ! -f $CHROMEDRIVER_FILE ]
then
    echo "Chromedriver file not found - trying to wget the file"
    DOWNLOAD_URL="http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
    echo $DOWNLOAD_URL
    wget $DOWNLOAD_URL
    if [[ $? != 0 ]]
    then
        echo "Failed downloading, please grab it manually"
        exit 1
    fi
    if [ -f chromedriver ]
    then
        rm chromedriver
    fi
    unzip chromedriver_linux64.zip
    mv chromedriver $CHROMEDRIVER_FILE
fi

echo "Starting Selenium"

echo "Checking if already running:"
h=$(pgrep -f selenium-server)
if [[ -n $h ]]; then
    echo "found running instance, killing that now"
    kill $h
    while [[ -n $h ]]; do
        sleep 1
        h=$(pgrep -f selenium-server)
    done
fi
echo "done"


if [[ "$@" =~ .*firefox.* ]]
then
    echo "starting firefox selenium
    "
    java -jar $JAR_FILE
else
    echo "starting chrome selenium
    "
    java -jar $JAR_FILE -Dwebdriver.chrome.driver=${CHROMEDRIVER_FILE}
fi
