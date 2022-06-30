#!/bin/zsh

## <-- Only modify "command_output" below to update Extension A content --> ##

# Start spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool true

# Show placeholder value while loading
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "KeyPlaceholder"

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
