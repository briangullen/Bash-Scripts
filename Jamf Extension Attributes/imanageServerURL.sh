#!/bin/bash

# Name: iManage Server
# Description: 20220223 EA to determine iManage server URL


source /etc/hyperfunctional || { exit 1; }
getCurrentUser
getCurrentUserHomeDir
plist="$currentUserHomeDir/Library/Application Support/iManage/Configuration/com.imanage.configuration.plist"



if [[ -e $plist ]]
    then
    serverSetting=$( defaults read "$currentUserHomeDir/Library/Application Support/iManage/Configuration/com.imanage.configuration.plist" ServerURL )
        echo "<result>$serverSetting</result>"
    else
        echo "<result>Absent</result>"
fi

exit 0
