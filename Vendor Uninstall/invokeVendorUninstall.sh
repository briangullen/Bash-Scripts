#!/bin/zsh

## Notes:
#### Executes the vendor's bundled uninstall script
#### from the filesystem location provided as input.

## Inputs:
#### $4 - vendor uninstall script path 

####################################
## Variables #######################
####################################
scriptName="runVendorUninstaller"
[[ "${4}" == "" ]] && { echo "ERROR: Nothing set in \$4. REQUIRED: path to script to run. Exiting."; exit 1; } || scriptPath="${4}"


####################################
## Script  #########################
####################################
echo "Executing the uninstall script: ${scriptPath}..."
eval "${scriptPath}"
exitStatus="$?"
echo "Script exited with status: ${exitStatus}" 
exit $exitStatus
