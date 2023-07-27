#!/bin/bash

# Name: prisma_uninstall.sh
# Creator: Brian Gullen for Rocket Central 2022-01-5
# Descirption: Script to fix misnamed cert from Prisma install

## -- VARIABLES -- ##

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUserUID="$(id -u $currentUser)"
logTag="gpPreFlightRemoval"
globalProtectDir="/Applications/GlobalProtect.app"
scriptDir="/private/tmp/removeGlobalProtect.scpt"


cat << HEREDOC >> /private/tmp/removeGlobalProtect.scpt
tell application "Finder"
  set sourceFolder to POSIX file "/Applications/GlobalProtect.app"
  delete sourceFolder  # move to trash
end tell
HEREDOC


## -- FUNCTIONS -- ##

#puts Apple script in place
function addAppleScript () {
if [[ -e "$scriptDir" ]]; then
    echo "Removal Script is in place."
else
    echo "Removal script was not created."
fi
}

#unload Prisma agents
function unloadGPAgents () {
launchctl asuser "$currentUserUID" launchctl unload -w /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
if [[ $? -eq 0 ]]; then
    echo "GlobalProtect agents have been unloaded."
else
    echo "Failed to unload GlobalProtect agents."
fi 
}

#prompt for removal
function promptGlobalProtectRemoval () {
echo "Running initial prompt for user to continue."
osascript /private/tmp/removeGlobalProtect.scpt
if [[ $? -eq 0 ]]; then
    echo "User should have been prompted to continue."
fi
}

#confirms removal
function confirmGlobalProtectRemoval () {
sleep 10
echo "Waiting for 10 seconds."
if [[ -d "$globalProtectDir" ]]; then
    echo "GlobalProtect has not been removed yet. Waiting an additional 20 seconds."
    sleep 20
    if [[ -d "$globalProtectDir" ]]; then
    echo "GlobalProtect is still present. Prompting removal via script."
    osascript /private/tmp/removeGlobalProtect.scpt
    else
    echo "GlobalProtect has been removed. We can continue uninstall."
    fi
else echo "GlobalProtect has been removed. We can continue."
fi
}

#remove Apple script
function removeAppleScript () {
rm -f "$scriptDir"
if [[ $? -eq 0 ]]; then
    echo "AppleScript has been removed."
else
    echo "Unable to remove AppleScript."
fi
}

function main () {
    addAppleScript
    unloadGPAgents
    promptGlobalProtectRemoval
    confirmGlobalProtectRemoval
    removeAppleScript
}

## -- SCRIPT -- ##

main

exit 0



