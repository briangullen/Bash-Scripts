#!/bin/bash
source /etc/hyperfunctional || { exit 1; }
source /etc/hyperapi || { exit 1; }

## Created by BG for Rocket Companies 2022-11-04


#############
# VARIABLES #
#############

scriptName="clearFailedCommands"

[[ -z "$4" ]] && { hyperLogger "$scriptName" "ERROR: No input in \$4. Expecting: salt." exit 1; } || salt="$4"
[[ -z "$5" ]] && { hyperLogger "$scriptName" "ERROR: No input in \$5. Expecting: passphrase." exit 1; } || passphrase="$5"
apiUserBase="REDACTED"
encApiPW="REDACTED"
getSerialNumber
getJamfBinLocation

#############
# FUNCTIONS #
#############


function getJamfApiUrl () {
    hyperLogger "$scriptName" "Checking Jamf Binary for API Base URL.."
    apiUrlBase="$("$jamfBin" checkJSSConnection | head -1 | grep "availability" | awk '{print $4}' | awk -F: '{print $1,":",$2}' | tr -d " ")"
    if [[ -n "$apiUrlBase" ]]
        then
            hyperLogger "$scriptName" "Retrieved Jamf API Base URL: $apiUrlBase. Checking reachability."
            phoneHome "${apiUrlBase#https://}" &>/dev/null
            if [[ "$siteNetwork" == "True" ]]
                then
                    hyperLogger "$scriptName" "Jamf Server can be reached. Continuing."
                else
                    hyperLogger "$scriptName" "ERROR: Could not reach Jamf Server. This is a breaking error."
                    exit 1
                fi
        else
            hyperLogger "$scriptName" "ERROR: Could not determine Jamf URL. Exiting."
            exit 1
    fi
}

function getComputerID() {
    checkJamfApiTokenExpiry
    hyperLogger "removeFailedCommands" "Hey There! Let's clean up some things. Getting Computer Record ID for $serialNumber."
    computerRecordID=$(curl -s -H "Authorization: Bearer $jamfAuthToken" "$apiUrl/JSSResource/computers/serialnumber/$serialNumber" -H "Accept: application/xml" | xpath '//computer/general/id[1]' 2>&1 | grep id | sed 's/<id>//;s/<\/id>.*//')
    if [[ -z "$computerRecordID" ]]
        then
            hyperLogger "$scriptName" "ERROR: Could not find Computer Record for serial number: $serialNumber. Exiting."
            exit 1
        else
            hyperLogger "$scriptName" "We're working with Computer Record: $computerRecordID."
    fi
}

function clearFailedCommands() {
    checkJamfApiTokenExpiry
    clearCommandStatus=$(curl -sfk -H "Authorization: Bearer $jamfAuthToken" "$apiUrl/JSSResource/commandflush/computers/id/$computerRecordID/status/Failed" -X DELETE -H "accept: application/xml"  --write-out "%{http_code}" -o /dev/null 2>&1)
    hyperLogger "removeFailedCommands" "I sent the API command to remove the Failed Commands for Computer Record: $computerRecordID. The return status is: $clearCommandStatus."
}

function doBlankPush() {
    checkJamfApiTokenExpiry
    blankPushStatus=$(curl -sfk -H "Authorization: Bearer $jamfAuthToken" "$apiUrl/JSSResource/computercommands/command/BlankPush/id/$computerRecordID" -X POST -H "accept: application/xml"  --write-out "%{http_code}" -o /dev/null 2>&1)
    hyperLogger "removeFailedCommands" "I sent the API command send a Blank Push Computer Record: $computerRecordID. The return status is: $blankPushStatus."
}


function main() {
    getJamfApiUrl
    apiInit "both" "$apiUserBase" "$encApiPW" "$apiUrlBase" "$salt" "$passphrase"
    getComputerID
    clearFailedCommands
    doBlankPush
}

##########
# SCRIPT #
##########
main

# Don't Blink
exit 0
