#!/bin/bash
#set -x

MAJOR_VERSION=2.53
VERSION=${MAJOR_VERSION}.0
JAR_FILE=selenium-server-standalone-${VERSION}.jar


CHROMEDRIVER_VERSION=`curl http://chromedriver.storage.googleapis.com/LATEST_RELEASE`
CHROMEDRIVER_FILE=chromedriver-${CHROMEDRIVER_VERSION}
CURRENT_CHROMEDRIVER_VERSION_FILE=current_chromedriver_version.txt

FIREFOXDRIVER_VERSION=0.15.0
FIREFOXDRIVER_FILE=geckodriver

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd $DIR/../binaries/
if [[ $? != 0 ]]
then
    echo "Failed cd-ing into the the binaries folder, aborting"
    exit 1
fi

# Making sure that the chrome driver is up to date
if [ -f ${CURRENT_CHROMEDRIVER_VERSION_FILE} ]
then
    CURRENT_CHROMEDRIVER_VERSION=`cat ${CURRENT_CHROMEDRIVER_VERSION_FILE}`
else
    CURRENT_CHROMEDRIVER_VERSION=false
fi

echo ${CHROMEDRIVER_VERSION} > ${CURRENT_CHROMEDRIVER_VERSION_FILE}

if [[ ${CURRENT_CHROMEDRIVER_VERSION} != ${CHROMEDRIVER_VERSION} && -f ${CHROMEDRIVER_FILE} ]]
then
    rm -f ${CHROMEDRIVER_FILE}
    rm -f chromedriver_linux64.zip
fi

## Host File bug sanity check
grep -P '127.0.0.1\s*localhost' /etc/hosts > /dev/null
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

if [ ! -f $FIREFOXDRIVER_FILE ] && [[ "$@" =~ .*firefox.* ]]
then
    if [ $(echo "$MAJOR_VERSION < 3.3" | bc -l) == 1 ]
    then
        echo "WARNING: the latest geckodriver requires selenium 3.3 and above";
        exit 1
    fi

    echo "Firefoxdirver file not found - trying to wget the file"

    DOWNLOAD_URL="https://github.com/mozilla/geckodriver/releases/download/v${FIREFOXDRIVER_VERSION}/geckodriver-v${FIREFOXDRIVER_VERSION}-linux64.tar.gz"
    echo $DOWNLOAD_URL
    wget $DOWNLOAD_URL
    if [[ $? != 0 ]]
    then
        echo "Failed downloading, please grab it manually"
        exit 1
    fi
    if [ -f $FIREFOXDRIVER_FILE ]
    then
        rm $FIREFOXDRIVER_FILE
    fi
    tar -xzvf geckodriver-v${FIREFOXDRIVER_VERSION}-linux64.tar.gz
    mv geckodriver $FIREFOXDRIVER_FILE
fi

echo "Starting Selenium"

echo "Killing if already running:"
source $DIR/selenium-stop.bash


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
