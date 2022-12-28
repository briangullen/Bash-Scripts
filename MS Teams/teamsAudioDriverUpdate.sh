#!/bin/bash

source /etc/hyperfunctional || { exit 1; }

## Name: teamsAudioDriverUpdate.sh
## Creator: Brian Gullen for Rocket Companies 2022-12-28
## Teams Audio Driver Update
## Checks currently installed version of Microsoft Teams Audio Driver
## Updates audio driver if outdated

## VARIABLES ##
scriptName="teamsAudioDriverUpdate"
localDriverPlist="/Library/Audio/Plug-ins/HAL/MSTeamsAudioDevice.driver/Contents/Info.plist"
updateDriverPkg="/Applications/Microsoft Teams.app/Contents/SharedSupport/MSTeamsAudioDevice.pkg"
uuidForThisExec="$(uuidgen)"
driverTmpDir="/tmp/$uuidForThisExec"
plistKey="CFBundleShortVersionString"
horseFeathers=2
awkHorseFeathers="%0${horseFeathers}d"

## FUNCTIONS ##
# Determines current version of audio driver
function checkCurrentVersion () {
    if [[ -e "$localDriverPlist" ]]
        then
            hyperLogger "$scriptName" "Local audio driver exists. Grabbing current version..."
            currentDriverVersion=$(defaults read "$localDriverPlist" "$plistKey" 2>/dev/null)
            currentDriverVersionInt=$(echo "$currentDriverVersion" |  awk -v feathers="$awkHorseFeathers" -F. '{for(i=1; i<=NF; i++) {printf(feathers,$i)}}')
            hyperLogger "$scriptName" "Current Teams audio driver is version $currentDriverVersionInt"
        else
            hyperLogger "$scriptName" "ERROR: No receipt for current driver exists. Unable to determine current version. Exiting..."
            exit 1
    fi
}

# Determines if audio driver upgrade exists and unpacks contents to temp directory
function verifyAndUnpack () {
    if [[ -e "$updateDriverPkg" ]]
        then
            hyperLogger "$scriptName" "Update driver exists. Unpacking contents..."
            if pkgutil --expand "$updateDriverPkg" "$driverTmpDir"
                then
                    hyperLogger "$scriptName" "SUCCESS: Audio driver package contents unpacked to $driverTmpDir"
                else
                    hyperLogger "$scriptName" "ERROR: Unable to unpack audio driver package contents. Exiting..."
                    exit 1
            fi
        else
            hyperLogger "$scriptName" "ERROR: No update driver exists. Unable to determine upgrade version. Exiting..."
            exit 1
    fi
}

# Checks package contents to determine udpate version of Teams audio driver
function checkUpdateVersion () {
    if [[ -d "$driverTmpDir" ]]
        then
            hyperLogger "$scriptName" "Temp directory exists. Determining driver update version."
            updateDriverVersion=$(xmllint "$driverTmpDir"/PackageInfo | grep -i CFBundleShortVersionString | awk '{print $4}' | awk -F '"' '{print $2}')
            updateDriverVersionInt=$(echo "$updateDriverVersion" |  awk -v feathers="$awkHorseFeathers" -F. '{for(i=1; i<=NF; i++) {printf(feathers,$i)}}')
            hyperLogger "$scriptName" "Teams audio driver update is version $updateDriverVersionInt"
            cleanTmpDir
        else
            hyperLogger "$scriptName" "ERROR: Temp directory does not exists. Unable to determine update version. Exiting..."
            exit 1
    fi
}

# Compares audio driver versions and updates if necessary
function compareAndUpdate () {
    if [[ "$currentDriverVersionInt" -lt "$updateDriverVersionInt" ]]
        then
            hyperLogger "$scriptName" "Current audio driver is out of date. Updating..."
            if installer -pkg "$updateDriverPkg" -target / &>/dev/null
                then
                    hyperLogger "$scriptName" "Verifying audio driver update status..."
                    newDriverVersion=$(defaults read "$localDriverPlist" "$plistKey" 2>/dev/null)
                    newDriverVersionInt=$(echo "$newDriverVersion" |  awk -v feathers="$awkHorseFeathers" -F. '{for(i=1; i<=NF; i++) {printf(feathers,$i)}}')
                    if [[ "$newDriverVersionInt" -ge "$updateDriverVersionInt" ]]
                        then
                            hyperLogger "$scriptName" "SUCCESS: Updated driver installed."
                        else
                            hyperLogger "$scriptName" "ERROR: Audio driver update failed. Exiting..."
                            exit 1
                    fi
                else
                    hyperLogger "$scriptName" "ERROR: Failed to install new driver."
                    exit 1
            fi
    elif [[ "$currentDriverVersionInt" -ge "$updateDriverVersionInt" ]]
        then
            hyperLogger "$scriptName" "Current audio driver is up to date. No need to proceed. Exiting..."
            exit 0
    else
        hyperLogger "$scriptName" "ERROR: Unable to determine if update is necessary. Exiting..."
        exit 1
    fi
}

# Cleans up temp directory
function cleanTmpDir () {
    if [[ -d "$driverTmpDir" ]]
        then
            hyperLogger "$scriptName" "Found temp directory. Cleaning up..."
            if rm -rf "$driverTmpDir"
                then
                    hyperLogger "$scriptName" "SUCCESS: $driverTmpDir has been removed."
                else
                    hyperLogger "$scriptName" "ERROR: Unable to remove $driverTmpDir. Investigate further..."
            fi
        else
            hyperLogger "$scriptName" "Temp directory does not exists. That's unexpected. Moving on..."
    fi
}

function main () {
    checkCurrentVersion
    verifyAndUnpack
    checkUpdateVersion
    compareAndUpdate
}


## SCRIPT ##
main

exit 0
