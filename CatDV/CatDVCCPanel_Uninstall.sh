#!/bin/zsh

# Uninstalls CatDVCCPanel for Adobe Creative Cloud via upia (Unified Plugin Install Agent)


## <-Variables-> ##
upiaDir="/Library/Application Support/Adobe/Adobe Desktop Common/RemoteComponents/UPI/UnifiedPluginInstallerAgent/UnifiedPluginInstallerAgent.app/Contents/MacOS/UnifiedPluginInstallerAgent"

## <-Functions-> ##
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

function removeCatDVCCPanel () {
    echo "Attempting to remove CatDVCCPanel Plugin."
    "$upiaDir" --remove CatDVCCPanel
    removalStatus="$?"
    if [[ "$removalStatus" -eq 0 ]]
        then
            echo "Success: CatDVCCPanel plugin has been removed."
        else
            echo "Error: Failed to remove CatDVCCPanel plugin."
            exit 1
    fi
}

function main () {
    verifyPluginInstaller
    removeCatDVCCPanel
}

## <-Script-> ##
main

exit 0
