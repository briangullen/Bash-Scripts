#!/bin/zsh

# Name: prisma_fixCert.sh
# Creator: Brian Gullen for Rocket Central 2021-12-09
# Descirption: Script to fix misnamed cert from Prisma install

## -- VARIABLES -- ##

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUserUID="$(id -u $currentUser)"
currentUserHomeDir=$(dscl . -read /Users/$currentUser NFSHomeDirectory | grep NFSHomeDirectory | tail -1 | awk '{print $NF}')
gpSystemDir="${currentUserHomeDir}/Library/Application Support/PaloAltoNetworks/GlobalProtect"
gpClientCertDir=$(find "$gpSystemDir" -iname "ClientCert*")
gpClientCertFilename=$(basename "$gpClientCertDir")
gpClientCertAbsPath="${gpSystemDir}/${gpClientCertFilename}"
gpClientCertExpectedName="ClientCert.cer"
gpClientCertExpectedAbsPath="${gpSystemDir}/${gpClientCertExpectedName}"


## -- FUNCTIONS -- ##

#unload Prisma agents
function unloadGPLaunchAgents () {
if launchctl asuser "$currentUserUID" launchctl unload -w /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
    then
        echo "GlobalProtect has been unloaded."
    else
        echo "Unable to unload GlobalProtect."
fi
}

#fixes cert name
function fixCertName () {
if [[ $gpClientCertFilename != $gpClientCertExpectedName ]]
    then
        echo "We need to update the cert name."
            if cp "$gpClientCertAbsPath" "$gpClientCertExpectedAbsPath"
                then
                    echo "Cert name has been updated." 
                else
                    echo "Unable to update cert name."
            fi
    else
        echo "Cert is already named correctly."
fi
}

#change cert permissions
function changeCertPermissions () {
if chown "$currentUser" "$gpClientCertExpectedAbsPath"
    then
        echo "Cert permissions have been updated."
    else
        echo "Unable to update cert permissions."
fi
}

#reload Prisma agents
function loadGPLaunchAgents () {
if launchctl asuser "$currentUserUID" launchctl load -w /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
    then
        echo "GlobalProtect has been reloaded."
    else
        echo "Unable to reload GlobalProtect."
fi
}

function main () {
    unloadGPLaunchAgents
    fixCertName
    changeCertPermissions
    loadGPLaunchAgents
}

## -- SCRIPT -- ##

main

exit 0
