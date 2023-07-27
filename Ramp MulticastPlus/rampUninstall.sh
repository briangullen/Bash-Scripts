#!/bin/bash

# Name: rampUninstall.sh
# Creator: Brian Gullen for Rocket Central 2022-06-15
# Description: Removes Ramp MulticastPlus application and all components

## -- Variables -- ##

rampDir="/Applications/Ramp Multicast.app"
rampDaemon="/Library/LaunchDaemons/com.ramp.pkg.RampMulticast.plist"
rampCleanup="/Library/LaunchDaemons/com.ramp.pkg.RampMulticast.cleanup.plist"
rampLogs="/var/log/RampMulticastPlusReceiver"
rampAppSupport="/Library/Application Support/Ramp"

## -- Functions -- ##

#Checks if Ramp exists and exits if Ramp is not installed
function checkRampDir () {
if [ -d "$rampDir" ]
    then
        echo "Ramp Multicast is installed. We can proceed."
    else
        echo "Ramp Multicast is not installed. No need to proceed. Exiting..."
        exit 0
fi
}

#Unloads and removes Ramp LaunchDaemon
function unloadRampDaemon () {
if [ -f "$rampDaemon" ]; then
	hyperLogger	"$scriptTag" "Found $rampDaemon. Stopping daemon and removing..."
	if launchctl unload "$rampDaemon"; then
		echo "Successfully stopped $rampDaemon."
	else
		echo "Unable to stop $rampDaemon."
	fi
		if rm -f "$rampDaemon"; then
			echo "Successfully removed $rampDaemon."
		else
			echo "ERROR: failed to remove $rampDaemon."
			exit 1
		fi
else
	echo "Unable to locate $rampDaemon. Moving on."
fi
}

#Unloads and removes Ramp Cleanup Daemon
function unloadRampCleanUp () {
if [ -f "$rampCleanup" ]; then
	hyperLogger	"$scriptTag" "Found $rampCleanup. Stopping daemon and removing..."
	if launchctl unload "$rampCleanup"; then
		echo "Successfully stopped $rampCleanup."
	else
		echo "Unable to stop $rampCleanup."
	fi
		if rm -f "$rampCleanup"; then
			echo "Successfully removed $rampCleanup."
		else
			echo "ERROR: failed to remove $rampCleanup."
			exit 1
		fi
else
    echo "Unable to locate $rampCleanup. Moving on."
fi
}

#Checks for Ramp log directory and removes if found
function cleanRampLogs () {
if [ -d "$rampLogs" ]; then
	hyperLogger	"$scriptTag" "Found $rampLogs. Let's try to remove them."
    if rm -rf "$rampLogs"; then
        echo "Successfully removed Ramp multicast log directory."
    else
        echo "ERROR: Unable to remove Ramp log directory"
        exit 1
    fi
else
    echo "$rampLogs does not exist. That's unexpected. Let's move on."
fi
}

#Checks for Ramp application support directory and removes if found
function cleanRampAppSupport () {
if [ -d "$rampAppSupport" ]; then
	hyperLogger	"$scriptTag" "Found $rampAppSupport. Let's try to remove them."
    if rm -rf "$rampAppSupport"; then
        echo "Successfully removed $rampAppSupport"
    else
        echo "ERROR: Unable to remove $rampAppSupport"
        exit 1
    fi
else
    echo "$rampAppSupport does not exist. That's unexpected. Let's move on."
fi
}

#Removes Ramp app bundle from Applications
function cleanRampDir () {
if rm -rf "$rampDir"; then
    echo "Successfully removed $rampDir."
else
    echo "ERROR: Unable to remove $rampDir."
    exit 1
fi
}

function main () {
    checkRampDir
    unloadRampDaemon
    unloadRampCleanUp
    cleanRampLogs
    cleanRampAppSupport
    cleanRampDir
}

## -- Script -- ##

main

exit 0
