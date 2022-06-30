#!/bin/zsh

## <-- Variables --> ##
logFolder="/Library/dmg/Logs"
logFileName="rkt-baseline_baseline.log"
logFilePath="${logFolder}/${logFileName}"

## <-- Only modify "command_output" below to update Exxtension B content --> ##

# Start spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingB -bool true

# Show placeholder value while loading
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueB -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get output value
command_output=$(failedComplianceItemCount=$(cat "${logFilePath}" | grep -i "failed" | awk '!/Result: ,/' | wc -l | xargs)
  echo "${failedComplianceItemCount//[^0-9]/}")

# Set output value
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueB -string "${command_output}"

# Stop spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingB -bool false
