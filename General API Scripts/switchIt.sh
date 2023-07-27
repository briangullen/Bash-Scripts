#!/bin/bash
source /etc/hyperfunctional || { exit 1; }
source /etc/hyperapi || { exit 1; }

## Updated 2022-10-25: Changed to Bearer Token Auth

#############
# VARIABLES #
#############
scriptName="switchIT"

[[ -z "${4}" ]] && { echo "ERROR: No salt passed in parameter 4.  This is required.  Exiting"; exit 1; } || salt="${4}"
[[ -z "${5}" ]] && { echo "ERROR: No passphrase passed in parameter 5.  This is required.  Exiting"; exit 1; } || passphrase="${5}"
# Category name in Jamf. Use %20 for spaces (for example: DEP%20Policies)
[[ -z "${6}" ]] && { echo "ERROR: No policy category passed in parameter 6.  This is required.  Exiting"; exit 1; } || policyCat="${6}"
# Are we enabling or policy? expects 'true' or 'false'
[[ -z "${7}" ]] && { echo "ERROR: No enable status passed in parameter 7.  This is required.  Exiting"; exit 1; } || enableStatus="${7}"

apiUserBase="REDACTED"
encApiPW="REDACTED"
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

function getPolicyIDs() {
  checkJamfApiTokenExpiry
  policyIDs=$(curl -s -H "Authorization: Bearer $jamfAuthToken" "$apiUrl/JSSResource/policies/category/$policyCat" -H "Accept: application/xml" | xpath '//policy/id[1]' 2>&1 | grep id | sed 's/<id>//;s/<\/id>.*//')

  if [[ -z "${policyIDs}" ]]
    then
        echo "ERROR: Could not get any policy IDs for category: $policyCat. Cannot continue. Exiting."
        exit 1
    else
      echo "Got the policy IDs!"
  fi
}


function switchStatus() {
  
  checkJamfApiTokenExpiry
  echo "Starting to set policies enabled to $enableStatus"
  
  while read -r id
   do
    policyStatus=$(curl -sfk -H "Authorization: Bearer $jamfAuthToken" "${apiUrl}/JSSResource/policies/id/${id}" -H "accept: application/xml" -H "Content-Type: application/xml" -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?><policy>\t<general>\t\t<enabled>${enableStatus}</enabled>\t</general></policy>" -X PUT --write-out "%{http_code}" -o /dev/null 2>&1)
    echo "Switched policy with ID: $id! Return code: $policyStatus"
  done < <( echo "${policyIDs}" )
  echo "All Set!"

}

function main() {
  getJamfApiUrl
  apiInit "both" "$apiUserBase" "$encApiPW" "$apiUrlBase" "$salt" "$passphrase"
  getPolicyIDs
  switchStatus
}

##########
# SCRIPT #
##########
main


# Don't Blink
exit 0
