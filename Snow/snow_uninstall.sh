#!/bin/bash

# Name: snow_uninstal.sh
# Creator: Brian Gullen for Rocket Central 2022-04-7
# Description: Uninstall script for Snow Inventory Agent

## -- VARIABLES -- ##

install_dir="/opt/snow"
snowagent_plist="/Library/LaunchDaemons/com.snowsoftware.Inventory.plist"
xmetering_plist="/Library/LaunchDaemons/com.snowsoftware.Metering.plist"
cloudmetering_plist="/Library/LaunchDaemons/com.snowsoftware.Cloudmetering.plist"

## -- FUNCTIONS -- ##

# Stop daemons and remove plists
function snowAgentPlist () {
if [ -f "$snowagent_plist" ]; then
	echo "Found $snowagent_plist. Stopping daemon and removing..."
	if launchctl unload "$snowagent_plist"; then
		echo "Successfully stopped $snowagent_plist."
	else
		echo "Unable to stop $snowagent_plist."
	fi
		if rm -f "$snowagent_plist"; then
			echo "Successfully removed $snowagent_plist."
		else
			echo "ERROR: failed to remove $snowagent_plist."
			exit 1
		fi
else
	echo "Unable to locate $snowagent_plist. Moving on."
fi	
}

function xmeteringPlist () {
if [ -f "$xmetering_plist" ]; then
	echo "Found $xmetering_plist. Stopping daemon and removing..."
	if launchctl unload "$xmetering_plist"; then
		echo "Successfully stopped $xmetering_plist."
	else
		echo "Unable to stop $xmetering_plist."
	fi
		if rm -f "$xmetering_plist"; then
			echo "Successfully removed $xmetering_plist."
		else
			echo "ERROR: failed to remove $xmetering_plist."
			exit 1
		fi
else
	echo "Unable to locate $xmetering_plist. Moving on."
fi
}

function cloudMeteringPlist () {
if [ -f "$cloudmetering_plist" ]; then
	echo "Found $cloudmetering_plist. Stopping daemon and removing..."
	if launchctl unload "$cloudmetering_plist"; then
		echo "Successfully stopped $cloudmetering_plist."
	else
		echo "Unable to stop $cloudmetering_plist."
	fi
		if rm -f "$cloudmetering_plist"; then
			echo "Successfully removed $cloudmetering_plist."
		else
			echo "ERROR: failed to remove $cloudmetering_plist."
			exit 1
		fi
else
	echo "Unable to locate $cloudmetering_plist. Moving on."
fi
}

# Remove install directory
function directoryCleanup () {
if [ -d "$install_dir" ]; then
	echo "Found $install_dir. Let's remove it."
	if rm -rf "$install_dir"; then
		echo "Successfully removed $install_dir."
	else
		echo "ERROR: failed to remove $install_dir"
		exit 1
	fi
else
	echo "ERROR: $install_dir does not exist. Unable to remove Snow agent."
	exit 1
fi	
}

function main () {
	snowAgentPlist
	xmeteringPlist
	cloudMeteringPlist
	directoryCleanup
}

## -- SCRIPT -- ##

main

exit 0
