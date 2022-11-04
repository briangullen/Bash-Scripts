#!/bin/zsh

## Notes:
#### Executes the vendor's bundled uninstall script
#### from the filesystem location provided as input.

## Inputs:
#### $4 - vendor uninstall script path 

source /etc/hyperfunctional || { exit 1; }

####################################
## Variables #######################
####################################
scriptName="runVendorUninstaller"
[[ "${4}" == "" ]] && { hyperLogger "$scriptName" "ERROR: Nothing set in \$4. REQUIRED: path to script to run. Exiting."; exit 1; } || scriptPath="${4}"


####################################
## Script  #########################
####################################
hyperLogger "$scriptName" "Executing the uninstall script: ${scriptPath}..."
eval "${scriptPath}"
exitStatus="$?"
hyperLogger "$scriptName" "Script exited with status: ${exitStatus}" 
exit $exitStatus
