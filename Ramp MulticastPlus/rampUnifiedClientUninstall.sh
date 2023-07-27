#!/bin/bash

# Name: unifiedRampUninstall.sh
# Creator: Brian Gullen for Rocket Central 2022-06-21
# Description: 2022-06-21 Removes Ramp MulticastPlus Receiver and all Components
# Notes: Only works for "Unified Client" version 3.1.6 and later


## -- Variables -- ##

rampPlist="com.ramp.pkg.RampMulticastPlusReceiver"
rampLaunchD="/Library/LaunchDaemons/$rampPlist.plist"
rampDir="/Library/Application Support/RampMulticastPlusReceiver"
rampLog="/var/log/RampMulticastPlusReceiver"

## -- Functions -- ##

function removeLaunchD () {
if [[ -f "$rampLaunchD" ]]; then
    echo "Found "$rampLaunchD". Let's unload it."
        if launchctl unload -w "$rampLaunchD"; then
            echo "$rampLaunchD successfully unloaded."
        else
            echo "Unable to successfully unload $rampLaunchD"
        fi
    echo "$rampLaunchD exists. Let's remove it."
        if rm -rf "$rampLaunchD"; then
            echo "Successfully removed $rampLaunchD."
        else
            echo "Unable to remove $rampLaunchD."
        fi
else
    echo "$rampLaunchD doesn't exist. Let's move on."
fi
}

function removeRampDir () {
if [[ -d "$rampDir" ]]; then
    echo "$rampDir exists. Let's remove it."
        if rm -rf "$rampDir"; then
            echo "Successfully removed $rampDir."
        else
            echo "ERROR: Failed to remove $rampDir."
            exit 1
        fi
else
    echo "$rampDir doesn't exist. Let's move on."
fi
}

function removeRampLog () {
if [[ -d "$rampLog" ]]; then
    echo "$rampLog exists. Let's remove it."
        if rm -rf "$rampLog"; then
            echo "Successfully removed $rampLog."
        else
            echo "ERROR: Unable to remvoe $rampLog."
            exit 1
        fi
else
    echo "$rampLog does not exist. Moving on."
fi
}

function main () {
    removeLaunchD
    removeRampDir
    removeRampLog
}

## -- Script -- ##

main

exit 0
