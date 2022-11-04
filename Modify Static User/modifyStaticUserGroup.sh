#!/usr/bin/env bash

scriptName="modifyStaticUserGroup"
# modifyStaticUserGroup modifies the specified static user group to add or remove the user.
# The intent is for the user to execute a policy in Self Service to add a configuration
# that is scoped to the static user group. An accompanying removal policy should be
# created and configured to run this script using the remove parameter.
# Modified 2022-10-27 to use Bearer Token Auth

source /etc/hyperfunctional || { exit 1; }
source /etc/hyperapi || { exit 1; }

##############
# PARAMETERS #
##############
[[ "$4" == "" ]] && { hyperLogger "$scriptName" 'ERROR: Nothing set in $4. Expecting: GroupID.  This is required.  Exiting.' "$scriptName"; exit 1; } || groupID="$4"
[[ "$5" == "" ]] && { hyperLogger "$scriptName" 'ERROR: Nothing set in $5. Expecting: Action.  This is required.  Exiting.' "$scriptName"; exit 1; } || action="$5"
[[ "$6" == "" ]] && { hyperLogger "$scriptName" 'ERROR: Nothing set in $6. Expecting: SALT.  This is required.  Exiting.' "$scriptName"; exit 1; } || salt="$6"
[[ "$7" == "" ]] && { hyperLogger "$scriptName" 'ERROR: Nothing set in $7. Expecting: PASSPHRASE.  This is required.  Exiting.' "$scriptName"; exit 1; } || passphrase="$7"

#############
# VARIABLES #
#############
apiUserBase="REDACTED"
encApiPW="REDACTED"
maxRetry="5"

#############
# FUNCTIONS #
#############
# setAction
function setAction() {
  if [[ "$action" == "add" ]]; then
    modifyAction="addition"
  elif [[ "$action" == "remove" ]]; then
    modifyAction="deletion"
  else
    hyperLogger "$scriptName" "ERROR: Invalid action specified." "$scriptName"
    exit 1
  fi
}

# get Jamf API Url base
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

# modifyUserGroup
function modifyUserGroup() {
  checkJamfApiTokenExpiry
  modifyXML='<user_group><user_'"$modifyAction"'s><user><username>'"$currentUser"'</username></user></user_'"$modifyAction"'s></user_group>'
  modifyXMLFile="/private/tmp/$(uuidgen).xml"
  echo "$modifyXML" > "$modifyXMLFile"

  hyperLogger "$scriptName" "Updating group $groupID with $modifyAction of $currentUser." "$scriptName"
  modifyStatus=$(curl -sfk -H "Authorization: Bearer $jamfAuthToken" -X PUT "$apiUrl/JSSResource/usergroups/id/$groupID" -H "Accept: application/xml" -H "Content-Type: application/xml" -T "$modifyXMLFile" --write-out "%{http_code}" -o /dev/null)

  case "$modifyStatus" in
    20*)
      hyperLogger "$scriptName" "Action: $modifyAction Success!" "$scriptName"
      doOver="false"
      ;;
    *)
      hyperLogger "$scriptName" "Action: $modifyAction Fail!" "$scriptName"
      hyperLogger "$scriptName" "HTTP Code: $modifyStatus" "$scriptName"
      if [[ "$modifyStatus" == "409" ]]
        then
          doOver="true"
        else
          errorExit "$modifyStatus" "$modifyAction"
      fi
      ;;
  esac
}

function errorExit() {
  status="$1"
  type="$2"
  hyperLogger "$scriptName" "Process failed during: $type." "$scriptName"
  hyperLogger "$scriptName" "HTTP Status code: $status" "$scriptName"
  exit 1
}

function cleanUp() {
  if [[ "$doOver" == "true" ]]; then
    if [[ -z "$modifyRetry" ]]; then
      modifyRetry="1"
    else
      if [[ "$modifyRetry" -le "$maxRetry" ]]; then
        hyperLogger "$scriptName" "Retrying to modify group, attempt# $modifyRetry." "$scriptName"
        ((modifyRetry++))
      else
        hyperLogger "$scriptName" "Reached max amount of retry attempts." "$scriptName"
        errorExit "$modifyStatus" "$modifyAction"
      fi
    fi
    hyperLogger "$scriptName" "409 Error found when modifying group in Jamf. Retrying..." "$scriptName"
    main
  fi

  if [[ -e "$modifyXMLFile" ]]; then
    rm -f "$modifyXMLFile"
    success="$?"
    if [[ "$success" ]]; then
      hyperLogger "$scriptName" "Removed $modifyXMLFile." "$scriptName"
    fi
  fi
}

function main() {
  getCurrentUser
  userInspector
  setAction
  getJamfBinLocation
  getJamfApiUrl
  apiInit "both" "$apiUserBase" "$encApiPW" "$apiUrlBase" "$salt" "$passphrase"
  modifyUserGroup
  cleanUp
}

##########
# SCRIPT #
##########
hyperLogger "$scriptName" "Initializing script." "$scriptName"
main
hyperLogger "$scriptName" "Script execution completed." "$scriptName"

exit 0
