#!/bin/zsh

# Name: Teams Audio Driver Version
# Description: IMPORTANT: Returns the version number without dots, and inflates each integer in the number to horseFeathers digits.  Returns "0" if not installed.
# Data Type: Integer
# Inventory Display: Extension Attributes
# Note: Works the same as the py version only using the appPlist location

#############
# VARIABLES #
#############

# Edit me #
appPlist="/Library/Audio/Plug-ins/HAL/MSTeamsAudioDevice.driver/Contents/Info.plist"
horseFeathers=2
plistKey="CFBundleShortVersionString"

# Don't edit me #
appVersion=$(defaults read "$appPlist" "$plistKey" 2>/dev/null)
awkHorseFeathers="%0${horseFeathers}d"

#############
# FUNCTIONS #
#############

function checkVersion() {

    if [[ -z "$appVersion" ]]
        then
            echo "<result>0</result>"
        else
            intVersion=$(echo "$appVersion" |  awk -v feathers="$awkHorseFeathers" -F. '{for(i=1; i<=NF; i++) {printf(feathers,$i)}}')
            if [[ -z "$intVersion" ]] || [[ "$intVersion" != <-> ]]
                then
                    echo "<result>Error</result>"
                else
                    echo "<result>$intVersion</result>"
            fi
    fi
}

##########
# SCRIPT #
##########

checkVersion

exit 0
