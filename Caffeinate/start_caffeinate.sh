#!/bin/zsh

# Name: start_caffeinate.sh
# Creator: Brian Gullen for Rocket Central 2021-10-19
# Descirption: Script to caffeinate mac for set time with variable inputs

source /etc/hyperfunctional || { exit 1; }

##Notes:
#### Executes caffeinate job based on parameter inputs in Jamf
#### Creates LaunchD to stop caffeinate process at specified time
#### Creates LaunchD to watch for clean up signal once caffeinate has been stopped.


## -- INPUTS -- ##


## $4: Display. OPTIONAL. Creates assertion to prevent display from sleeping (-d).
# Expects true or false. Defaults to false.
## $5: System. OPTIONAL. Creates assertion to prevent system from idle sleeping (-i).
# Expects true or false. Defaults to false.
## $6: Disk. OPTIONAL. Creates assertion to prevent disk from idle sleeping (-m).
# Expects true or false. Defaults to false.
## $7: User. OPTIONAL. Creates assertion to declare user is active. Turns on display if off. (-u).
# Expects true or false. Defaults to false.
## $8: LaunchD Hour. REQUIRED. Determines which hour of day LaunchD will load.
# Expects integer. Hour to run 0-23.
## $9: LaunchD Minute. REQUIRED. Determines which minute of day LaunchD will load.
# Expects integer. Minutes to run 00-59.


#Check to see if a value was passed in parameters $4 through $9 and, if so, assigns them
[[ -z "${4}" ]] && { echo "ERROR: Nothing set in \$4. Optional: Prevent Display from sleeping.  Defaulting to false."; displayAssertion="false"; } || displayAssertion="${4}"
[[ -z "${5}" ]] && { echo "ERROR: Nothing set in \$5. Optional: Prevent System from sleeping.  Defaulting to false."; systemAssertion="false"; } || systemAssertion="${5}"
[[ -z "${6}" ]] && { echo "ERROR: Nothing set in \$6. Optional: Prevent Disk from sleeping.  Defaulting to false."; diskAssertion="false"; } || diskAssertion="${6}"
[[ -z "${7}" ]] && { echo "ERROR: Nothing set in \$7. Optional: Declares user is Active.  Turns on display. Defaulting to false."; userAssertion="false"; } || userAssertion="${7}"
[[ -z "${8}" ]] && { echo "ERROR: Nothing set in \$8. REQUIRED: Declares hour for LaunchD load."; exit 1; } || launchdHour="${8}"
[[ -z "${9}" ]] && { echo "ERROR: Nothing set in \$9. REQUIRED: Declares minute for LaunchD load."; exit 1; } || launchdMin="${9}"


## -- VARIABLES -- ##


getCurrentUserUID
dmgFolder="/Library/dmg"
receiptName=".caffeinatePID"
receiptPath="$dmgFolder/$receiptName"
stopCaffeinateId="com.rockcentraldetroit.stopCaffeinate"
stopCaffeinateLaunchdPath="/Library/LaunchDaemons/$stopCaffeinateId.plist"
watchCaffeinateId="com.rockcentraldetroit.watchCaffeinate"
watchCaffeinateLaunchdPath="/Library/LaunchDaemons/$watchCaffeinateId.plist"
watcherPath="/Library/dmg/.launchDWatcher"

read -r -d '' stopCaffeinateLaunchd << HEREDOC
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$stopCaffeinateId</string>
    <key>ProgramArguments</key>
<array>
    <string>/usr/local/bin/jamf</string>
    <string>policy</string>
    <string>-event</string>
    <string>macOSKillCaffeinate</string>
</array>
    <key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>$launchdHour</integer>
    <key>Minute</key>
    <integer>$launchdMin</integer>
</dict>
    <key>RunAtLoad</key>
    <false/>
    <key>StandardErrorPath</key>
    <string>/Library/dmg/Logs/com.rockcentral.stopCaffeinate.err</string>
    <key>StandardOutPath</key>
    <string>/Library/dmg/Logs/com.rockcentral.stopCaffeinate.out</string>
</dict>
</plist>
HEREDOC

read -r -d '' watchCaffeinateLaunchd << HEREDOC
<?xml version=“1.0” encoding=“UTF-8”?>
<!DOCTYPE plist PUBLIC “-//Apple//DTD PLIST 1.0//EN” “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
<plist version=“1.0”>
<dict>
        <key>Label</key>
        <string>$watchCaffeinateId</string>
        <key>ProgramArguments</key>
        <array>
                <string>/usr/local/bin/jamf</string>
                <string>policy</string>
                <string>-event</string>
                <string>macOSCaffeinateCleanUp</string>
        </array>
        <key>QueueDirectories</key>
        <array>
                <string>$watcherPath</string>
        </array>
        <key>StandardErrorPath</key>
            <string>/Library/dmg/Logs/com.rockcentral.cleanCaffeinate.err</string>
        <key>StandardOutPath</key>
            <string>/Library/dmg/Logs/com.rockcentral.cleanCaffeinate.out</string>
</dict>
</plist>
HEREDOC

## -- FUNCTIONS -- ##

#Gathers variables for caffeinate
function determineOptions () {
caffeinateKeys=""

if [[ "$displayAssertion" == "true" ]]
    then
        echo "Display will not be prevented from sleeping."
        caffeinateKeys+="d"
    else
        echo "Display is not being prevented from sleeping."
fi

if [[ "$systemAssertion" == "true" ]]
    then
        echo "System will be prevented from sleeping."
        caffeinateKeys+="i"
    else
        echo "System is not being prevented from sleeping."
fi

if [[ "$diskAssertion" == "true" ]]
    then
        echo "Disk will be prevented from sleeping."
        caffeinateKeys+="m"
    else
        echo "Disk is not being prevented from sleeping."
fi


if [[ "$userAssertion" == "true" ]]
    then
        echo "User will be declared active. Display will wake if off."
        caffeinateKeys+="u"
    else
        echo "User is not declared as active."
fi
}

#kicks off caffeinate
function caffeinateGo () {
    hyperLogger $logTag "Keeping Mac awake with caffeinate -"$caffeinateKeys""
    caffeinate -"$caffeinateKeys" &
}

#Creates receipt path and writes caffeinate PID
function createReceipt () {
if [[ ! -e "$receiptPath" ]]
    then
        hyperLogger $logTag "Receipt file not found. Creating "$receiptPath" and writing receipt."
        touch "$receiptPath"
        echo "$!" > "$receiptPath"
        hyperLogger $logTag "Writing caffeinate PID "$!" to receipt."
    else
        hyperLogger $logTag "Receipt file already exists. Overwriting Receipt."
        echo "$!" > "$receiptPath"
fi
}

#Creates caffeinate watcher directory
function createWatcherDir () {
if [[ ! -d "$watcherPath" ]]
    then
        hyperLogger $logTag "Watcher Directory not Found. Creating "$watcherPath"."
        mkdir "$watcherPath"
    else
        hyperLogger $logTag "Watcher Directory already exists. Moving On."
fi
}

#Creates Launchd to execute kill script
function createCaffeinateLaunchd () {
if [[ -e "$stopCaffeinateLaunchdPath" ]]
    then
        hyperLogger $logTag ""$stopCaffeinateLaunchdPath" already exists. Loading existing launchd."
        launchctl load -w "$stopCaffeinateLaunchdPath"
    else
        hyperLogger $logTag "Kill Caffeinate Launchd was not found. Writing launchd for time $launchdHour:$launchdMin to $stopCaffeinateLaunchdPath and loading."
        echo "$stopCaffeinateLaunchd" > "$stopCaffeinateLaunchdPath"
        launchctl load -w "$stopCaffeinateLaunchdPath"
fi
}

#Creates Launchd to execute kill script
function createWatcherLaunchd () {
if [[ -e "$watchCaffeinateLaunchdPath" ]]
    then
        hyperLogger $logTag ""$watchCaffeinateLaunchdPath" already exists. Loading existing launchd."
        launchctl load -w "$watchCaffeinateLaunchdPath"
    else
        hyperLogger $logTag "Watcher Launchd was not found. Writing launchd to "$watchCaffeinateLaunchdPath" and loading."
        echo "$watchCaffeinateLaunchd" > "$watchCaffeinateLaunchdPath"
        launchctl load -w "$watchCaffeinateLaunchdPath"
fi
}

function main () {
    determineOptions
    caffeinateGo
    createReceipt
    createWatcherDir
    createCaffeinateLaunchd
    createWatcherLaunchd
}

## -- SCRIPT -- ##

main

exit 0

#Go Go Caffeinate
