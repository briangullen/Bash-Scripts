#!/bin/zsh

# Name: Find My Mac Status
# Description: Determines status of Find My Mac (FMM), Enabled or Disabled.
# Data Type: String
# Inventory Display: Extension Attributes
# Note: Tested and works on both Intel and M1

fmmToken=$(/usr/sbin/nvram -x -p | /usr/bin/grep fmm-mobileme-token-FMM) 

if [[ -z "$fmmToken" ]]
    then 
        echo "<result>Disabled</result>" 
    else 
        echo "<result>Enabled</result>" 
fi

exit 0
