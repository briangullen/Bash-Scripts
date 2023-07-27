#!/bin/bash

source /etc/hyperfunctional || { exit 1; }
source /etc/hyperapi || { exit 1; }

## Created by BG for Rocket Companies 2022-11-04

#############
# VARIABLES #
#############

logTag="deleteComputerRecord"
[[ -z "${4}" ]] && { echo "No salt passed in parameter 4.  This is required.  Exiting"; exit 0; } || salt="${4}"
[[ -z "${5}" ]] && { echo "No passphrase passed in parameter 5.  This is required.  Exiting"; exit 0; } || passphrase="${5}"
apiUserBase="REDACTED"
encApiPW="REDACTED"
getSerialNumber
getJamfBinLocation

#############
# FUNCTIONS #
#############

function getJamfApiUrl () {
    echo "Checking Jamf Binary for API Base URL.."
    apiUrlBase="$("$jamfBin" checkJSSConnection | head -1 | grep "availability" | awk '{print $4}' | awk -F: '{print $1,":",$2}' | tr -d " ")"
    if [[ -n "$apiUrlBase" ]]
        then
            echo "Retrieved Jamf API Base URL: $apiUrlBase. Checking reachability."
            phoneHome "${apiUrlBase#https://}" &>/dev/null
            if [[ "$siteNetwork" == "True" ]]
                then
                    echo "Jamf Server can be reached. Continuing."
                else
                    echo "ERROR: Could not reach Jamf Server. This is a breaking error."
                    exit 1
                fi
        else
            echo "ERROR: Could not determine Jamf URL. Exiting."
            exit 1
    fi
}

function getComputerID() {
    checkJamfApiTokenExpiry
    hyperLogger "removeFailedCommands" "Hey There! Let's clean up some things. Getting Computer Record ID."
    computerRecordID=$(curl -s -H "Authorization: Bearer $jamfAuthToken" "$apiUrl/JSSResource/computers/serialnumber/$serialNumber" -H "Accept: application/xml" | xpath '//computer/general/id[1]' 2>&1 | grep id | sed 's/<id>//;s/<\/id>.*//')
    
    if [[ -z "$computerRecordID" ]]
        then
            echo "ERROR: Could not find Computer Record for serial number: $serialNumber. Exiting."
            exit 1
        else
            echo "We're working with Computer Record: $computerRecordID."
    fi
}

function deleteComputerRecord() {
    checkJamfApiTokenExpiry
    echo "Attempting to remove computer record..."
    deleteStatus=$(curl -sfk -H "Authorization: Bearer $jamfAuthToken" "$apiUrl/JSSResource/computers/id/$computerRecordID" -X DELETE  --write-out "%{http_code}" -o /dev/null 2>&1)
    echo "Return status: $deleteStatus."
}

function main() {
    getJamfApiUrl
    apiInit "both" "$apiUserBase" "$encApiPW" "$apiUrlBase" "$salt" "$passphrase"
    getComputerID
    deleteComputerRecord
}


##########
# SCRIPT #
##########
main

# Don't Blink!
exit 0
