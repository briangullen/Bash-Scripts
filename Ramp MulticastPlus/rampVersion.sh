#!/bin/zsh

# Name: rampMulticastVersion
# Creator: Created by Brian Gullen for Rocket Companies 2022-06-15
# Description: IMPORTANT: Returns the version number without dots, and inflates each integer in the number to horseFeathers digits.  Returns "0" if not installed.
# Data Type: Integer
# Inventory Display: Extension Attributes
# Note: Grabs filename of most recent Ramp Multicast log file and then searchs for version inside the log


## -- VARIABLES -- ##


appDir="/Library/Application Support/RampMulticastPlusReceiver/logs"
horseFeathers=2
awkHorseFeathers="%0${horseFeathers}d"


## -- FUNCTIONS -- ##


function CheckDirAndLog () {
    if [[ -d "$appDir" ]]
        then
            logFile=$(ls -t "$appDir" | head -n 1)
            if [[ -z "$logFile" ]]
                then
                    echo "<result>0</result>"
                    exit 0
                else
                    appVersion=$(grep "Ramp version" "$appDir"/"$logFile" | awk '{print $6}' | sed 's/v//' | xargs | cut -d"." -f1-3  2>/dev/null)
            fi
        else
            echo "<result>0</result>"
            exit 0
    fi
}


function checkVersion() {
    if [[ -z "$appVersion" ]]
        then
            echo "<result>0</result>"
        else
            intVersion=$(echo "$appVersion" |  awk -v feathers="$awkHorseFeathers" -F. '{for(i=1; i<=NF; i++) {printf(feathers,$i)}} ')
            if [[ -z "$intVersion" ]] || [[ "$intVersion" != <-> ]]
                then
                    echo "<result>Error</result>"
                else
                    echo "<result>$intVersion</result>"
            fi
    fi
}

function main () {
    CheckDirAndLog
    checkVersion
}


## -- SCRIPT -- ##


main

exit 0
