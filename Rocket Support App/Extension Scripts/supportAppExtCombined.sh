#!/bin/zsh

# ---------------------    Modifies Extension A   ----------------------

## <-- Only modify "command_output" below to update Exxtension A content --> ##

# Start spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool true

# Show placeholder value while loading - This needs to be excluded for "OnAppear Config"
#defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get output value
command_output=$(defaultRouteIface="$(route -n get default | grep interface | awk '{print $2}')"
  currentIP="$(ifconfig "$defaultRouteIface" | grep "inet " | awk '{print $2}')"
  echo "$currentIP")

# Set output value
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "${command_output}"

# Stop spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool false


# ---------------------    Modifies Extension B   ----------------------

## <-- Variables --> ##
logFolder="/Library/dmg/Logs"
logFileName="rkt-baseline_baseline.log"
logFilePath="${logFolder}/${logFileName}"

## <-- Only modify "command_output" below to update Exxtension B content --> ##

# Start spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingB -bool true

# Show placeholder value while loading - This needs to be excluded for "OnAppear Config"
#defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueB -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get output value
command_output=$(failedComplianceItemCount=$(cat "${logFilePath}" | grep -i "failed" | awk '!/Result: ,/' | wc -l | xargs)
  echo "${failedComplianceItemCount//[^0-9]/}")

# Set output value
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueB -string "${command_output}"

# Stop spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingB -bool false
