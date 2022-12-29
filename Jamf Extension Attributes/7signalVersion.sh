#!/bin/zsh

# Name: 7signal MobileEye Version
# Description: IMPORTANT: Returns the version number without dots, and inflates each integer in the number to horseFeathers digits.  Returns "0" if not installed.
# Data Type: Integer
# Inventory Display: Extension Attributes
# Note: The only place I can find acurate versions numbers is in the jar manifest. This EA is parsing a bit different than the other sh EAs. DM

implementationVersion="$(unzip -p /Library/Application\ Support/7signal/mobileeyeagent.jar META-INF/MANIFEST.MF | grep -i Implementation-Version | awk '{print $2}')"
horseFeathers=2
awkHorseFeathers="%0${horseFeathers}d"

if [[ -z "$implementationVersion" ]]
then
    echo "<result>0</result>"
else
    intVersion=$(echo -n "$implementationVersion" |  awk -v feathers="$awkHorseFeathers" -F. '{for(i=1; i<=NF; i++) {printf(feathers,$i)}}')
    if [[ -z "$intVersion" ]] || [[ "$intVersion" != <-> ]]
    then
        echo "<result>ERROR</result>"
    else
        echo "<result>$intVersion</result>"
    fi
fi
