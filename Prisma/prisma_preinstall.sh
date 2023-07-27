#!/bin/zsh

# Name: prisma_preinstalll.sh
# Creator: Brian Gullen for Rocket Central 2021-12-09
# Descirption: Script to set Prisma settings

## -- VARIABLES --##

plistDir="/Library/Preferences"
plistName="com.paloaltonetworks.GlobalProtect.settings.plist"
plistFullDir="$plistDir/$plistName"

read -r -d '' plistComplete << HEREDOC
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Palo Alto Networks</key>
    <dict>
        <key>GlobalProtect</key>
        <dict>
            <key>PanGPS</key>
            <dict/>
            <key>PanSetup</key>
            <dict>
                <key>Portal</key>
                <string>companyURL.gpcloudservice.com</string>
            </dict>
            <key>Settings</key>
            <dict>
                <key>default-browser</key>
                <string>yes</string>
                <key>ext-key-usage-oid-for-client-cert</key>
				<string>1.3.6.1.4.1.23435.509.1</string>
            </dict>
        </dict>
    </dict>
</dict>
</plist>
HEREDOC

#removes Prisma plist
function checkPlist () {
if [[ -e "$plistFullDir" ]]; then
    echo "Plist already exists. Removing before we proceed."
    rm -f "$plistFullDir"
    if [[ $? -eq 0 ]]; then
        echo "Removed has been removed. Let's move on."
    fi
else
    echo "Plist does not exist. We can proceed."
fi
}

#Creates new plist
function createPlist () {
echo "$plistComplete" > "$plistFullDir"
if [[ $? -eq 0 ]]; then
    echo "New plist has been created."
else
    echo "Unable to create new plist."
fi
}

#change plist owner
function changeOwner () {
chown root:wheel /Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist
if [[ $? -eq 0 ]]; then
    echo "Updated owner for plist."
else
    echo "Unable to update plist owner."
fi
}

#change plist permissions
function changePermissions () {
chmod 644 /Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist
if [[ $? -eq 0 ]]; then
    echo "Updated permissions for plist."
else
    echo "Unable to update plist permissions."
fi
}

function main () {
    checkPlist
    createPlist
    changeOwner
    changePermissions
}

## -- SCRIPT -- ##

main

exit 0
