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
===========================================
$(hostname) $0 $@
===========================================
"
# Error Handling
backTraceExit () {
    local err=$?
    set +o xtrace
    local code="${1:-1}"
    printf "\n\nError in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}'\n\n exited with status: \n\n$err\n\n"
    # Print out the stack trace described by $function_stack
    if [ ${#FUNCNAME[@]} -gt 2 ]
    then
        echo "Call tree:"
        for ((i=1;i<${#FUNCNAME[@]}-1;i++))
        do
            echo " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
        done
    fi
    echo "Exiting with status ${code}"
    exit "${code}"
}
trap 'backTraceExit' ERR
set -o errtrace
missingPackages=false
for package in unzip java
do
    if [[ "" == "$(which $package)" ]]
    then
        echo "Package $package is missing";
        missingPackages=true;
    fi
done

if [[ "false" != "$missingPackages" ]]
then
    echo "Packages are missing, please install them"
    exit 1
fi

jarFile=${1:-'false'}

if [[ "false" == "$jarFile" ]]
then
    source ./download-binaries.bash
fi

echo "Now Starting Selenium"

echo "Killing if already running:"
bash $dir/selenium-stop.bash


if [[ "$@" =~ .*firefox.* ]]
then
    echo "starting firefox selenium"
    java -jar $jarFile
else
    echo "starting chrome selenium"
    java -jar $jarFile -Dwebdriver.chrome.driver=${chromedriverFile}
fi
