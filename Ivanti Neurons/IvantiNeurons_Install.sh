#!/bin/bash

## Post Install script for Ivanti Neurons
# Moves & mounts cached DMG
# Installs package and activates Neurons

## Variables ##
[[ -z "$4" ]] && { echo "ERROR: No input in \$4. Expecting: neuronsDMG name." exit 1; } || neuronsDMG="$4"
[[ -z "$5" ]] && { echo "ERROR: No input in \$5. Expecting: enrollmentKey." exit 1; } || enrollmentKey="$5"

jamfCache="/Library/Application Support/JAMF/Waiting Room"
jamfXmlCache="${jamfCache}/${neuronsDMG}.cache.xml"
dmgCacheDir="${jamfCache}/${neuronsDMG}"
cacheTmp="/private/tmp"
neuronsTmpDMG="${cacheTmp}/${neuronsDMG}"
neuronsAgentDir="/usr/local/com.ivanti.cloud.agent/IvantiAgent/bin/stagentctl"


## Functions ##

# Check that Jamf cached Ivanti Neurons
function checkCache () {
    if [[ -e "$dmgCacheDir" ]]
        then
            echo "Ivanti Neurons has been cached by Jamf. We can proceed."
        else
            echo "ERROR: Cannot find cached Ivanti Neurons DMG. Exiting."
            exit 1
    fi
}

# Move Cached Neurons DMG to tmp
function moveNeurons () {
    if mv "$dmgCacheDir" "$cacheTmp"
        then
            echo "Ivanti Neurons has been moved to tmp directory. Attempting to Mount DMG."
        else
            echo "ERROR: Unable to move Ivanti Neurons to tmp directory."
    fi
}

# Mount Neurons DMG and install
function installNeurons () {
    if /usr/bin/hdiutil attach /private/tmp/$neuronsDMG -mountpoint /tmp/cloudinstall -nobrowse
        then
            echo "SUCCESS: Neurons DMG has been mounted. Proceeding with install."
                if /usr/sbin/installer -pkg /private/tmp/cloudinstall/Ivanti\ Neurons\ Agent.pkg -target /
                    then
                        echo "SUCCESS: Neurons PKG is installed"
                    else
                        echo "ERROR: Neurons PKG failed to install"
                        exit 1
                fi
        else
            echo "ERROR: Unable to mount Neurons DMG. Exiting"
            exit 1
    fi   
}

# Activates the Ivanti Neurons Agent
function activateNeurons () {
    echo "Checking for installed Neurons Agent."
    if [[ -e "$neuronsAgentDir" ]]
        then
            echo "Neurons Agent found. Proceeding with activation."
            if /usr/local/com.ivanti.cloud.agent/IvantiAgent/bin/stagentctl register --baseurl https://agentreg.ivanticloud.com --enrollmentkey ${enrollmentKey}
                then
                    echo "SUCCESS: Ivanti Neurons is activated."
                else
                    echo "ERROR: Ivanti Neurons failed to activate."
                    exit 1
            fi
        else
            echo "ERROR: Could not find Neurons Agent. Unable to activate. Exiting."
            exit 1
    fi
}

# Unmount DMG and remove
function cleanup () {
    echo "Cleaning up tmp items from install"
    echo "Unmounting DMG."
    /usr/bin/hdiutil detach /tmp/cloudinstall
    if [[ -e "$neuronsTmpDMG" ]]
        then
            echo "$neuronsTmpDMG exists. Removing."
            rm -rf "$neuronsTmpDMG"
    fi
        if [[ -e "$jamfXmlCache" ]]
        then
            echo "$jamfXmlCache exists. Removing."
            rm -rf "$jamfXmlCache"
    fi
}

function main () {
    checkCache
    moveNeurons
    installNeurons
    activateNeurons
}

## Script ##

trap cleanup EXIT
main

exit 0
