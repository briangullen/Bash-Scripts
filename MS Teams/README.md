## Overview
This is a location to house all scripts related to Microsoft Teams.

### Teams Audio Driver Update
This script is designed to run on a set interval on devices. It checks for the current installed version of the audio driver and compares it to the driver available in the Teams app bundle. If the version in the app bundle is newer, the script invokes the audio package and installs the newer version of the audio driver. If the version is the same or higher the script exits.

