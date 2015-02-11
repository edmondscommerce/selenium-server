#!/bin/bash
SELENIUM_PID=$(pgrep -f selenium-server)
if [[ "" == "$SELENIUM_PID" ]]
then
    echo "No Selenium process found"
else
    echo "Killing PID $SELENIUM_PID"
    kill $SELENIUM_PID
    echo "done"
fi