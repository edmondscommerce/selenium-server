# selenium-server

This is a simple package to easily run Selenium with Chrome driver.

It does not contain the binaries, instead it will download them on first run.

It has only been run and tested on Linux.

To install it simply add 

`"tajawal/selenium-server": "dev-master"`

To your composer.json file and then run composer update


## Running

`bin/selenium-run.bash` To run Selenium in a terminal. You can stop the Selenium process as required by hitting [ctrl]+[c]

## Running in the background

`bin/selenium-background-run.bash`

This will run the process in the background using nohup

## Stopping the background process

`bin/selenium-stop.bash`

This will find a Selenium process that is running in the background and kill it


## Firefox / Chrome

This process uses Chrome by default.

If you want to use it with Firefox, you need to append the `firefox` flag, eg

`bin/selenium-run.bash firefox`

Or

`bin/selenium-background-run.bash firefox`