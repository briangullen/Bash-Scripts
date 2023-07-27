#!/bin/zsh

# Name: slack_token.sh
# Creator: Brian Gullen for Rocket Central 2022-03-11
# Descirption: The script will place a sign-in token for configuring Slack default instance

## -- VARIABLES -- ##

## $4: preferredToken. REQUIRED. Sets slackToken variable for Slack signin.
[[ -z "${4}" ]] && { echo "ERROR: Nothing set in \$4. REQUIRED: Sets Slack signin token."; exit 1; } || preferredToken="${4}"

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUserGID="$(dscl . -read /Users/$currentUser PrimaryGroupID | awk '{print $2}')"
tokenPath="/Users/$currentUser/Downloads/Signin.slacktoken"
tokenOwner=$(ls -l "$tokenPath" | awk '{print $3}')

read -r -d '' slackSignInFile <<-EOF
{"default_signin_team":"$preferredToken"}
EOF

## -- FUNCTIONS -- ##

function getJsonValue() {
    [[ -z "$1" ]] && { echo "getJsonValue()" "ERROR: No input in \$1."; return 1; } || { local jsonData; jsonData="$1"; }
    [[ -z "$2" ]] && { echo "getJsonValue()" "ERROR: No input in \$2."; return 1; } || { local jsonKey; jsonKey="$2"; }
    local result
    
    result=$(JSON="$jsonData" osascript -l 'JavaScript' -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' -e "JSON.parse(env).$jsonKey")
    [[ -z "$result" ]] && { return 1; } || { echo "$result"; return 0; }
}

#Checks for presence and contents of Slack sign-in token. Writes or replaces based on findings.
function checkAndCreate () {
if [ ! -e "$tokenPath" ]
    then
        echo "Slack sign-in token does not exist. Let's create it."
        if echo "$slackSignInFile" > "$tokenPath"
            then
                echo "Successfully set Slack sign-in token."
            else
                echo "ERROR: Unable to set Slack sign-in token. Exiting."
                exit 1
        fi
 	else
        echo "Slack sign-in token already exists. Let's make sure it is correct."
        tokenContents=$(cat "$tokenPath")
        currentToken=$(getJsonValue "$tokenContents" "default_signin_team")
        if [[ "$currentToken" == "$preferredToken" ]]
            then
                echo "$preferredToken already set as sign-in token."
            else
                echo "$preferredToken is not set as sign-in token. Let's fix that"
                if echo "$slackSignInFile" > "$tokenPath"
                    then
                        echo "Successfully set Slack sign-in token."
                    else
                        echo "ERROR: Unable to set Slack sign-in token. Exiting."
                        exit 1
                fi
        fi
fi    
}

#Checks and updates ownership of Slack sign-in token
function getOwnership () {
if [[ "$tokenOwner" == "$currentUser" ]]
    then
        echo "$currentUser already set as file owner."
    else
        echo "$currentUser is not file owner. Let's change that."
        if chown "${currentUser}:${currentUserGID}" "$tokenPath"
            then
                echo "$currentUser is now set as owner."
            else
                echo "ERROR: Unable to set $currentUser as owner."
                exit 1
        fi
fi
}

function main () {
    checkAndCreate
    getOwnership
}

## -- SCRIPT -- ##

main

exit 0
