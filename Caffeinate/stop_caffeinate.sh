#!/bin/zsh

# Name: stop_caffeinate.sh
# Creator: Brian Gullen for Rocket Central 2021-10-19
# Descirption: Script to kill caffeinate job

source /etc/hyperfunctional || { exit 1; }


## -- VARIABLES -- ##


stopCaffeinateId="com.rockcentraldetroit.stopCaffeinate"
stopCaffeinateLaunchdPath="/Library/LaunchDaemons/$stopCaffeinateId.plist"
caffeinatePIDs=$(ps aux | grep -w "caffeinate" | grep -v grep | grep -v jamf | grep -v Safari | grep -v Firefox | awk '/[0-9]/ {print $2}')
dmgFolder="/Library/dmg"
caffeinateReceipt=".caffeinatePID"
caffeinateReceiptPath="$dmgFolder/$caffeinateReceipt"
watcherReceipt=".caffeinateCleanup"
watcherPath="/Library/dmg/.launchDWatcher"
watcherReceiptPath="$watcherPath/$watcherReceipt"


## -- FUNCTIONS -- ##


#read receipt
function readCaffeinateReceipt () {
if [[ -e "$caffeinateReceiptPath" ]]
    then
        echo "Receipt found at "$caffeinateReceiptPath". Reading receipt PID."
        receiptPID=$(< "$caffeinateReceiptPath")
        echo "Receipt PID is $receiptPID"
    else
        echo "No caffeinate PID exists in receipt. That's odd. Let's proceed."
fi 
}

#remove receipt if present
function removeCaffeinateReceipt () {
if [[ -e "$caffeinateReceiptPath" ]]
    then
        echo "Done with receipt at "$caffeinateReceiptPath". Removing"
        if rm -f "$caffeinateReceiptPath"
            then echo "Receipt has been removed."
            else echo "Receipt could not be removed."
        fi
    else
        echo "Receipt does not exist. That's Weird. Let's move on."
fi
}

#check & kill caffeinate
function terminateCaffeinate () {
while read -r LINE
    do
    echo "Found PID $LINE"
    allThePids+=("$LINE")
    done < <( echo "$caffeinatePIDs" )
for pid in "${allThePids[@]}"
    do
        echo "Checking PID $pid"
        if [[ "$pid" -eq "$receiptPID" ]]
            then
                echo "Found PID that matches receipt. Killing process."
                kill -9 "$pid"
            else
                echo "These PIDs don't match. Moving on."
        fi
    done
}

#Creates receipt path and writes caffeinate PID
function createWatcherReceipt () {
if [[ ! -e "$watcherReceiptPath" ]]
    then
        echo "Watcher receipt not found. Creating receipt at "$watcherReceiptPath"."
        if touch "$watcherReceiptPath"
            then echo "Receipt created successfully."
            else echo "Receipt was not created."
        fi
    else
        echo "Receipt file already exists. That's odd. Time to go."
        exit 1
fi
}


main () {
    readCaffeinateReceipt
    removeCaffeinateReceipt
    terminateCaffeinate
    createWatcherReceipt
}


## -- SCRIPT -- ##


main

exit 0
