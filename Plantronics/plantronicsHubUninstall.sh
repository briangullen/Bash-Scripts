#!/bin/bash

# Name: plantronicsHubUninstall.sh
# Creator: Brian Gullen for Rocket Central 2022-07-08
# Description: Removes Plantronics Hub and all components

source /etc/hyperfunctional || { exit 1; }

##<-- Variables -->##

logName="removePlantronics"
getCurrentUser
getCurrentUserHomeDir
processName="Plantronics Hub"
appDir="/Applications/Plantronics Hub.app"
plantronicsDir="$currentUserHomeDir/Library/Application Support/Plantronics"
plantronicsDaemon="/Library/LaunchDaemons/com.PlantronicsUpdateService.plist"
plantronicsUpdater="/usr/local/libexec/SpokesUpdateService"
plantronicsLog="/var/log/PltDaemon.log"



##<-- Functions -->##

function checkAndKill () {
if pgrep "$processName"
    then
        hyperLogger "$logName" "Plantronics Hub is running. Let's stop it."
        if killall "$processName"
            then
                hyperLogger "$logName" "Successfully quit Plantronics Hub."
            else
                hyperLogger "$logName" "ERROR: Unable to quit Plantronics Hub."
                exit 1
        fi
    else
        hyperLogger "$logName" "Plantronics Hub is not running. Moving on."
fi
}

function removeAppDir () {
if [[ -d "$appDir" ]]
    then
        hyperLogger "$logName" "Found $appDir. Let's remove it."
        if rm -rf "$appDir"
            then
                hyperLogger "$logName" "Successfully removed $appDirr."
            else
                hyperLogger "$logName" "ERROR: Unable to remove $appDir."
                exit 1
        fi
    else
        hyperLogger "$logName" "Unable to locate $appDir. Moving on."
fi
}

function removePlantronicsDir () {
if [[ -d "$plantronicsDir" ]]
    then
        hyperLogger "$logName" "Found $plantronicsDir. Let's remove it."
        if rm -rf "$plantronicsDir"
            then
                hyperLogger "$logName" "Successfully removed $plantronicsDir."
            else
                hyperLogger "$logName" "ERROR: Unable to remove $plantronicsDir."
                exit 1
        fi
    else
        hyperLogger "$logName" "Unable to locate $plantronicsDir. Moving on."
fi
}

function unloadAndRemoveDaemon () {
if [[ -e "$plantronicsDaemon" ]]
    then
        hyperLogger "$logName" "Found $plantronicsDaemon. Let's unload and remove it."
        if launchctl bootout system "$plantronicsDaemon"
            then
                hyperLogger "$logName" "Successfully unloaded $plantronicsDaemon."
            else
                hyperLogger "$logName" "ERROR: Unable to unload $plantronicsDaemon."
        fi
        if rm -rf "$plantronicsDaemon"
            then
                hyperLogger "$logName" "Successfully removed $plantronicsDaemon."
            else
                hyperLogger "$logName" "ERROR: Unable to remove $plantronicsDaemon."
                exit 1
        fi
    else
        hyperLogger "$logName" "Unable to locate $plantronicsDaemon. Moving on."
fi
}

function removePlantronicsUpdater () {
if [[ -e "$plantronicsUpdater" ]]
    then
        hyperLogger "$logName" "Found $plantronicsUpdater. Let's remove it."
        if rm -rf "$plantronicsUpdater"
            then
                hyperLogger "$logName" "Successfully removed $plantronicsUpdater."
            else
                hyperLogger "$logName" "ERROR: Unable to remove $plantronicsUpdater."
                exit 1
        fi
    else
        hyperLogger "$logName" "Unable to locate $plantronicsUpdater. Moving on."
fi
}

function removePlantronicsLog () {
if [[ -e "$plantronicsLog" ]]
    then
        hyperLogger "$logName" "Found $plantronicsLog. Let's remove it."
        if rm -rf "$plantronicsLog"
            then
                hyperLogger "$logName" "Successfully removed $plantronicsLog."
            else
                hyperLogger "$logName" "ERROR: Unable to remove $plantronicsLog."
                exit 1
        fi
    else
        hyperLogger "$logName" "Unable to locate $plantronicsLog. Moving on."
fi
}

function main () {
    checkAndKill
    removeAppDir
    removePlantronicsDir
    unloadAndRemoveDaemon
    removePlantronicsUpdater
    removePlantronicsLog
}

##<-- Script -->##

main

exit 0
