#!/bin/bash

source /etc/hyperfunctional || { exit 1; }

## <-- Variables --> ##
scriptLog="supportAppMagic"
supportAppDir="/Library/dmg/SupportApp"
extNameA="supportAppExtA.sh"
extNameB="supportAppExtB.sh"
extNameCombined="supportAppExtCombined.sh"
baseImgUrl="https://accesshelper.jamf.foc.zone/assets"
rcAppIconUrl="$baseImgUrl/logos/rcLogoSmall.png"
rcAppIcon="$supportAppDir/rcLogoSmall.png"
rcMenuBarIconUrl="$baseImgUrl/logos/rocketO16x16.png"
rcMenuBarIcon="$supportAppDir/rocketO16x16.png"

read -r -d '' contentsExtA <<- 'EOF'
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
EOF

read -r -d '' contentsExtB <<- 'EOF'
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
EOF

read -r -d '' contentsExtCombined <<- 'EOF'
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
EOF

## <-- Functions --> ##

function checkDirectory () {
if [[ ! -d "$supportAppDir" ]]
    then
        hyperLogger "$scriptLog" "$supportAppDir does not exist. Let's create it."
            if mkdir -p "$supportAppDir"
                then
                    hyperLogger "$scriptLog" "Successfully created $supportAppDir."
                else
                    hyperLogger "$scriptLog" "ERROR: Failed to create $supportAppDir."
                    exit 1
            fi
    else
        hyperLogger "$scriptLog" "$supportAppDir already exists. Moving on."
fi
}

function createExtA () {
if ! echo "$contentsExtA" > "$supportAppDir/$extNameA"
    then
        hyperLogger "$scriptLog" "ERROR: Installing $extNameA into $supportAppDir failed"
    else
        hyperLogger "$scriptLog" "Successfully installed $extNameA into $supportAppDir"
fi

if ! chmod +x "$supportAppDir/$extNameA"
    then
        hyperLogger "$scriptLog" "ERROR: Unable to make $extNameA executable"
    else
        hyperLogger "$scriptLog" "$extNameA is now executable"
fi  
}

function createExtB () {
if ! echo "$contentsExtB" > "$supportAppDir/$extNameB"
    then
        hyperLogger "$scriptLog" "ERROR: Installing $extNameB into $supportAppDir failed"
    else
        hyperLogger "$scriptLog" "Successfully installed $extNameB into $supportAppDir"
fi

if ! chmod +x "$supportAppDir/$extNameB"
    then
        hyperLogger "$scriptLog" "ERROR: Unable to make $extNameB executable"
    else
        hyperLogger "$scriptLog" "$extNameB is now executable"
fi  
}

function createExtCombined () {
if ! echo "$contentsExtCombined" > "$supportAppDir/$extNameCombined"
    then
        hyperLogger "$scriptLog" "ERROR: Installing $extNameCombined into $supportAppDir failed"
    else
        hyperLogger "$scriptLog" "Successfully installed $extNameCombined into $supportAppDir"
fi

if ! chmod +x "$supportAppDir/$extNameCombined"
    then
        hyperLogger "$scriptLog" "ERROR: Unable to make $extNameCombined executable"
    else
        hyperLogger "$scriptLog" "$extNameCombined is now executable"
fi  
}

function installAppIcon () {
if curl -s "$rcAppIconUrl" > $rcAppIcon
    then
        hyperLogger "$scriptLog" "Successfully downloaded App icon."
    else
        hyperLogger "$scriptLog" "ERROR: Unable to download App icon."
fi
}

function installMenuBarIcon () {
if curl -s "$rcMenuBarIconUrl" > $rcMenuBarIcon
    then
        hyperLogger "$scriptLog" "Successfully downloaded Menu Bar icon."
    else
        hyperLogger "$scriptLog" "ERROR: Unable to download App icon."
fi
}

function main () {
    checkDirectory
    createExtA
    createExtB
    createExtCombined
    installAppIcon
    installMenuBarIcon
}

## <-- Script --> ##

main

exit 0
