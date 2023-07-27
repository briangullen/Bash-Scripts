#!/bin/bash

# Name: plantronicsHubUninstall.sh
# Creator: Brian Gullen for Rocket Central 2022-07-08
# Description: Removes Plantronics Hub and all components

##<-- Variables -->##

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUserHomeDir=$(dscl . -read /Users/$currentUser NFSHomeDirectory | grep NFSHomeDirectory | tail -1 | awk '{print $NF}')
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
        echo "Plantronics Hub is running. Let's stop it."
        if killall "$processName"
            then
                echo "Successfully quit Plantronics Hub."
            else
                echo "ERROR: Unable to quit Plantronics Hub."
                exit 1
        fi
    else
        echo "Plantronics Hub is not running. Moving on."
fi
}

function removeAppDir () {
if [[ -d "$appDir" ]]
    then
        echo "Found $appDir. Let's remove it."
        if rm -rf "$appDir"
            then
                echo "Successfully removed $appDirr."
            else
                echo "ERROR: Unable to remove $appDir."
                exit 1
        fi
    else
        echo "Unable to locate $appDir. Moving on."
fi
}

function removePlantronicsDir () {
if [[ -d "$plantronicsDir" ]]
    then
        echo "Found $plantronicsDir. Let's remove it."
        if rm -rf "$plantronicsDir"
            then
                echo "Successfully removed $plantronicsDir."
            else
                echo "ERROR: Unable to remove $plantronicsDir."
                exit 1
        fi
    else
        echo "Unable to locate $plantronicsDir. Moving on."
fi
}

function unloadAndRemoveDaemon () {
if [[ -e "$plantronicsDaemon" ]]
    then
        echo "Found $plantronicsDaemon. Let's unload and remove it."
        if launchctl bootout system "$plantronicsDaemon"
            then
                echo "Successfully unloaded $plantronicsDaemon."
            else
                echo "ERROR: Unable to unload $plantronicsDaemon."
        fi
        if rm -rf "$plantronicsDaemon"
            then
                echo "Successfully removed $plantronicsDaemon."
            else
                echo "ERROR: Unable to remove $plantronicsDaemon."
                exit 1
        fi
    else
        echo "Unable to locate $plantronicsDaemon. Moving on."
fi
}

function removePlantronicsUpdater () {
if [[ -e "$plantronicsUpdater" ]]
    then
        echo "Found $plantronicsUpdater. Let's remove it."
        if rm -rf "$plantronicsUpdater"
            then
                echo "Successfully removed $plantronicsUpdater."
            else
                echo "ERROR: Unable to remove $plantronicsUpdater."
                exit 1
        fi
    else
        echo "Unable to locate $plantronicsUpdater. Moving on."
fi
}

function removePlantronicsLog () {
if [[ -e "$plantronicsLog" ]]
    then
        echo "Found $plantronicsLog. Let's remove it."
        if rm -rf "$plantronicsLog"
            then
                echo "Successfully removed $plantronicsLog."
            else
                echo "ERROR: Unable to remove $plantronicsLog."
                exit 1
        fi
    else
        echo "Unable to locate $plantronicsLog. Moving on."
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
