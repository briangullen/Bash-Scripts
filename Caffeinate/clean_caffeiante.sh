#!/bin/zsh

# Name: clean_caffeinate.sh
# Creator: Brian Gullen for Rocket Central 2021-10-19
# Descirption: Script to clean up launchds from caffeinate job

## -- VARIABLES -- ##


stopCaffeinateId="com.rockcentraldetroit.stopCaffeinate"
stopCaffeinateLaunchdPath="/Library/LaunchDaemons/$stopCaffeinateId.plist"
watcherReceipt=".caffeinateCleanup"
watcherPath="/Library/dmg/.launchDWatcher"
watcherReceiptPath="$watcherPath/$watcherReceipt"


## -- FUNCTIONS -- ##


#Checks for watcher receipt and removes
function removeWatcherReceipt () {
if [[ -e "$watcherReceiptPath" ]]
    then
        echo "Found receipt at "$watcherReceiptPath". Removing"
        if rm -f "$watcherReceiptPath"
            then
                echo "Receipt removed successfully."
            else
                echo "Receipt could not be removed."
        fi
    else
        echo "Receipt does not exist. That's Weird. Let's move on."
fi
}

#Checks for stop caffeinate LaunchD and unloads
function unloadStopCaffeinate () {
if [[ -e $stopCaffeinateLaunchdPath ]]
    then
        echo "Found launchD $stopCaffeinateLaunchdPath. Unloading."
        if launchctl unload -w $stopCaffeinateLaunchdPath
             then
                echo "LaunchD has been unloaded."
             else
                echo "LaunchD could not be unloaded."
        fi
    else
        echo "stopCaffeinateLaunchdPath not found. That's Weird. Let's move on."
fi
}

#Checks and removes caffeinate LaunchD
function removeStopCaffeinate () {
    if [[ -e $stopCaffeinateLaunchdPath ]]
    then
        echo "LaunchD found at $watcherReceiptPath. Removing"
        if rm -f $stopCaffeinateLaunchdPath
            then
                echo "LaunchD has been removed."
            else
                echo "LaunchD could not be removed."
        fi
    else
        echo "$stopCaffeinateLaunchdPath does not exist. That's Weird. Let's move on."
fi
}

function main () {
    removeWatcherReceipt
    unloadStopCaffeinate
    removeStopCaffeinate
}


## -- SCRIPT -- ##


main

exit 0
