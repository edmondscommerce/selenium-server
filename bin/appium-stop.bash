#!/bin/bash
APPIUM_PROCESS_GREP=appium

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