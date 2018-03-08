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
Downloading Binaries for Selenium
"

majorVersion=2.53
version=${majorVersion}.0
jarFile=selenium-server-standalone-${version}.jar


chromedriverVersion=`curl http://chromedriver.storage.googleapis.com/LATEST_RELEASE`
chromedriverFile=chromedriver-${chromedriverVersion}
currentChromedriverVersionFile=current_chromedriver_version.txt

firefoxdriverVersion=0.15.0
firefoxdriverFile=geckodriver

cd $dir/../binaries/
if [[ $? != 0 ]]
then
    echo "Failed cd-ing into the the binaries folder, aborting"
    exit 1
fi

# Making sure that the chrome driver is up to date
if [ -f ${currentChromedriverVersionFile} ]
then
    currentChromedriverVersion=`cat ${currentChromedriverVersionFile}`
else
    currentChromedriverVersion=false
fi

echo ${chromedriverVersion} > ${currentChromedriverVersionFile}

if [[ ${currentChromedriverVersion} != ${chromedriverVersion} && -f ${chromedriverFile} ]]
then
    rm -f ${chromedriverFile}
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

if [ ! -f $jarFile ]
then
    echo "Selenium JAR file not found - trying to wget the file"
    downloadUrl="http://selenium-release.storage.googleapis.com/${majorVersion}/selenium-server-standalone-${version}.jar"
    echo $downloadUrl
    set +e
    wget $downloadUrl
    if [[ $? != 0 ]]
    then
        echo "Failed downloading, please grab it manually"
        exit 1
    fi
    set -e
fi

if [ ! -f $chromedriverFile ]
then
    echo "Chromedriver file not found - trying to wget the file"
    downloadUrl="http://chromedriver.storage.googleapis.com/${chromedriverVersion}/chromedriver_linux64.zip"
    echo $downloadUrl
    set +e
    wget $downloadUrl
    if [[ $? != 0 ]]
    then
        echo "Failed downloading, please grab it manually"
        exit 1
    fi
    set -e
    if [ -f chromedriver ]
    then
        rm chromedriver
    fi
    unzip chromedriver_linux64.zip
    mv chromedriver $chromedriverFile
fi

if [ ! -f $firefoxdriverFile ] && [[ "$@" =~ .*firefox.* ]]
then
    if [ $(echo "$majorVersion < 3.3" | bc -l) == 1 ]
    then
        echo "WARNING: the latest geckodriver requires selenium 3.3 and above";
        exit 1
    fi

    echo "Firefoxdirver file not found - trying to wget the file"

    downloadUrl="https://github.com/mozilla/geckodriver/releases/download/v${firefoxdriverVersion}/geckodriver-v${firefoxdriverVersion}-linux64.tar.gz"
    echo $downloadUrl
    set +e
    wget $downloadUrl
    if [[ $? != 0 ]]
    then
        echo "Failed downloading, please grab it manually"
        exit 1
    fi
    set -e
    tar -xzvf geckodriver-v${firefoxdriverVersion}-linux64.tar.gz
    mv geckodriver $firefoxdriverFile
fi

echo "
DONE Downloading Binaries for Selenium
"
