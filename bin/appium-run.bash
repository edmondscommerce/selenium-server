#!/usr/bin/env bash

APPIUM_PROCESS_GREP=appium
APPIUM_PORT=4723

function installAppium {
    echo "Installing appium ..."
    eval "npm install appium"
    echo "Installing appium doctor ..."
    eval "npm install appium-doctor"
}

function installNodeJsOsx {
    echo "Installing nodejs ..."
    brew install node carthage
}

function installNodeJsLinux {
    echo "Installing nodejs ..."
    # Do something under GNU/Linux platform
    eval "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -"
    eval "sudo apt-get install -y nodejs"
}

function prepareBeforeRun {
    h=$(pgrep -f ${APPIUM_PROCESS_GREP} )
    if [[ -n $h ]]; then
        echo "Killing PID $h"
        kill $h
        while [[ -n $h ]]; do
            sleep 1
            h=$(pgrep -f ${APPIUM_PROCESS_GREP} )
        done
        echo "done"
    else
        echo "No Appium process found"
    fi
}
function prepareOsx {
    true
}

if [ "$(uname)" == "Darwin" ]; then
    command -v appium >/dev/null 2>&1 || {
        prepareOsx
        installNodeJsOsx
    }
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    command -v appium >/dev/null 2>&1 || {
    installNodeJsLinux
    }
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    echo "We dont support windows, please install nodejs manually!"
    exit 1
fi

command -v appium >/dev/null 2>&1 || {
    installAppium;
}

prepareBeforeRun
echo "Running appium ..."
#--full-reset
appium --log-timestamp --debug-log-spacing

