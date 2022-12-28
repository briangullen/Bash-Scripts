#!/bin/bash

source /etc/hyperfunctional || { exit 1; }

## Restarts the 7signal MobileEye Agent
## Used after install to ensure agent is running and reports to console

## VARIABLES ##
scriptName="restart7signal"
getCurrentUser
getCurrentUserUID
agentDir="/Library/LaunchAgents"
agentName="com.sevensignal.mobileeyeagent"
mobileEyeAgent="${agentDir}/${agentName}.plist"


## FUNCTIONS ##
function checkAndUnload () {
    if [[ -e "$mobileEyeAgent" ]]
        then
            hyperLogger "$scriptName" "Found 7signal agent. Attempting to unload..."
            launchctl asuser "$currentUserUID" launchctl unload "$mobileEyeAgent"
            exitStatus="$?"
            if [[ "$exitStatus" -eq 0 ]]
                then
                    hyperLogger "$scriptName" "SUCCESS: 7signal agent has been unloaded."
                else
                    hyperLogger "$scriptName" "ERROR: Unable to unload 7signal agent. Exiting..."
                    exit 1
            fi
        else
            hyperLogger "$scriptName" "ERROR: 7signal agent not found. This is a blocking error. Exiting..."
            exit 1
    fi
}

function checkAndReload () {
    if [[ -e "$mobileEyeAgent" ]]
        then
            hyperLogger "$scriptName" "Found 7signal agent. Attempting to reload..."
            launchctl asuser "$currentUserUID" launchctl load "$mobileEyeAgent"
            exitStatus="$?"
            if [[ "$exitStatus" -eq 0 ]]
                then
                    hyperLogger "$scriptName" "SUCCESS: 7signal agent has been reloaded."
                else
                    hyperLogger "$scriptName" "ERROR: Unable to ureload 7signal agent. Exiting..."
                    exit 1
            fi
        else
            hyperLogger "$scriptName" "ERROR: 7signal agent not found. This is a blocking error. Exiting..."
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
