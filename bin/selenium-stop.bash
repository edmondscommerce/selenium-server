#!/bin/bash
SELENIUM_PROCESS_GREP=selenium-server-standalone

h=$(pgrep -f ${SELENIUM_PROCESS_GREP} )
if [[ -n $h ]]; then
    echo "Killing PID $h"
    kill $h
    while [[ -n $h ]]; do
        sleep 1
        h=$(pgrep -f ${SELENIUM_PROCESS_GREP} )
    done
    echo "done"
else
    echo "No Selenium process found"
fi