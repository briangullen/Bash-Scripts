#!/bin/bash

## Name: restart7signalAgent.sh
## Creator: Brian Gullen for Rocket Companies 2022-12-28
## Restarts the 7signal MobileEye Agent
## Used after install to ensure agent is running and reports to console

## VARIABLES ##
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUserUID="$(id -u $currentUser)"
agentDir="/Library/LaunchAgents"
agentName="com.sevensignal.mobileeyeagent"
mobileEyeAgent="${agentDir}/${agentName}.plist"


## FUNCTIONS ##
function checkAndUnload () {
    if [[ -e "$mobileEyeAgent" ]]
        then
            echo "Found 7signal agent. Attempting to unload..."
            launchctl asuser "$currentUserUID" launchctl unload "$mobileEyeAgent"
            exitStatus="$?"
            if [[ "$exitStatus" -eq 0 ]]
                then
                    echo "SUCCESS: 7signal agent has been unloaded."
                else
                    echo "ERROR: Unable to unload 7signal agent. Exiting..."
                    exit 1
            fi
        else
            echo "ERROR: 7signal agent not found. This is a blocking error. Exiting..."
            exit 1
    fi
}

function checkAndReload () {
    if [[ -e "$mobileEyeAgent" ]]
        then
            echo "Found 7signal agent. Attempting to reload..."
            launchctl asuser "$currentUserUID" launchctl load "$mobileEyeAgent"
            exitStatus="$?"
            if [[ "$exitStatus" -eq 0 ]]
                then
                    echo "SUCCESS: 7signal agent has been reloaded."
                else
                    echo "ERROR: Unable to ureload 7signal agent. Exiting..."
                    exit 1
            fi
        else
            echo "ERROR: 7signal agent not found. This is a blocking error. Exiting..."
            exit 1
    fi
}

function main () {
    checkAndUnload
    checkAndReload
}

## Script ##

main

exit 0
