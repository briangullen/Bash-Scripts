#!/bin/zsh

# Installs CatDVCCPanel for Adobe Creative Cloud via upia (Unified Plugin Install Agent)
# Uses pre-cached package from Jamf located in /Users/Shared for installation

## <-Variables-> ##
[[ -z "$4" ]] && { echo "ERROR: No input in \$4. Expecting: catDVCCpkg." exit 1; } || catDVCCpkg="$4"
cachedDir="/Users/Shared"
catDVCCcachedPkg="$cachedDir/$catDVCCpkg"
upiaDir="/Library/Application Support/Adobe/Adobe Desktop Common/RemoteComponents/UPI/UnifiedPluginInstallerAgent/UnifiedPluginInstallerAgent.app/Contents/MacOS/UnifiedPluginInstallerAgent"

## <-Functions-> ##
function verifyCachedPlugin () {
    echo "Checking for $catDVCCcachedPkg before moving on."
    if [[ -e "$catDVCCcachedPkg" ]]
        then
            echo "Success: Found $catDVCCcachedPkg. We can continue."
        else
            echo "Error: Unable to find $catDVCCcachedPkg. Exiting."
            exit 1
    fi
}

function verifyPluginInstaller () {
    echo "Checking for upia (Unified Plugin Installer) before moving on."
    if [[ -e "$upiaDir" ]]
        then
            echo "Success: Found Unified Plugin Installer. We can continue."
        else
            echo "Error: Unified Plugin installer does not appear installed. Exiting."
            exit 1
    fi
}

function installPlugin () {
    echo "Attempting to install CatDVCCPanel plugin via the Adobe unified plugin installer."
    "$upiaDir" --install "$catDVCCcachedPkg"
    installStatus="$?"
    if [[ "$installStatus" -eq 0 ]]
        then
            echo "Success: CatDVPanel plugin was successful."
        else
            echo "Error: Failed to install CatDVPanel plugin."
            exit 1
    fi
}

function cleanupPlugin () {
    echo "Chekcing for cached CatDVCCPanel plugin to clean up."
    if [[ -e "$catDVCCcachedPkg" ]]
        then
            echo "Found $catDVCCcachedPkg. Removing."
            if rm -rf "$catDVCCcachedPkg"
                then
                    echo "Success: $catDVCCcachedPkg has been removed."
                else
                    echo "Error: Unable to remove $catDVCCcachedPkg."
                    exit 1
            fi
        else
            echo "$catDVCCcachedPkg does not exist. Moving on."
    fi
}

function main () {
    verifyCachedPlugin
    verifyPluginInstaller
    installPlugin
}

## <-Script-> ##
trap cleanupPlugin EXIT
main

exit 0
