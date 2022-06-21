#!/bin/bash

# Name: unifiedRampUninstall.sh
# Creator: Brian Gullen for Rocket Central 2022-06-21
# Description: 2022-06-21 Removes Ramp MulticastPlus Receiver and all Components
# Notes: Only works for "Unified Client" version 3.1.6 and later

source /etc/hyperfunctional || { exit 1; }


## -- Variables -- ##

logTag="removeRampClient"
rampPlist="com.ramp.pkg.RampMulticastPlusReceiver"
rampLaunchD="/Library/LaunchDaemons/$rampPlist.plist"
rampDir="/Library/Application Support/RampMulticastPlusReceiver"
rampLog="/var/log/RampMulticastPlusReceiver"

## -- Functions -- ##

function removeLaunchD () {
if [[ -f "$rampLaunchD" ]]; then
    hyperLogger "$logTag" "Found "$rampLaunchD". Let's unload it."
        if launchctl unload -w "$rampLaunchD"; then
            hyperLogger "$logTag" "$rampLaunchD successfully unloaded."
        else
            hyperLogger "$logTag" "Unable to successfully unload $rampLaunchD"
        fi
    hyperLogger "$logTag" "$rampLaunchD exists. Let's remove it."
        if rm -rf "$rampLaunchD"; then
            hyperLogger "$logTag" "Successfully removed $rampLaunchD."
        else
            hyperLogger "$logTag" "Unable to remove $rampLaunchD."
        fi
else
    hyperLogger "$logTag" "$rampLaunchD doesn't exist. Let's move on."
fi
}

function removeRampDir () {
if [[ -d "$rampDir" ]]; then
    hyperLogger "$logTag" "$rampDir exists. Let's remove it."
        if rm -rf "$rampDir"; then
            hyperLogger "$logTag" "Successfully removed $rampDir."
        else
            hyperLogger "$logTag" "ERROR: Failed to remove $rampDir."
            exit 1
        fi
else
    hyperLogger "$logTag" "$rampDir doesn't exist. Let's move on."
fi
}

function removeRampLog () {
if [[ -d "$rampLog" ]]; then
    hyperLogger "$logTag" "$rampLog exists. Let's remove it."
        if rm -rf "$rampLog"; then
            hyperLogger "$logTag" "Successfully removed $rampLog."
        else
            hyperLogger "$logTag" "ERROR: Unable to remvoe $rampLog."
            exit 1
        fi
else
    hyperLogger "$logTag" "$rampLog does not exist. Moving on."
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
