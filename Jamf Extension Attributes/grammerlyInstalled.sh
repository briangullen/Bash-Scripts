#!/bin/bash

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUserHomeDir=$(dscl . -read /Users/$currentUser NFSHomeDirectory | grep NFSHomeDirectory | tail -1 | awk '{print $NF}')

grammarlyDir="$currentUserHomeDir/Applications/Grammarly Desktop.app"

if [[ -d "$grammarlyDir" ]]; then
    echo "<result>Present</result>"
else
    echo "<result>Absent</result>"
fi

exit 0
