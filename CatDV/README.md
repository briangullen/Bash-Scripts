
## Overview
Place to house all scripts related to CatDV and CatDVPanel for Adobe Creative Cloud

## CatDVCCPanel_Install
Installs CatDVCCPanel for Adobe Creative Cloud apps. Adobe Creative Cloud app and a CatDV eligible app must be installed prior to execution of the script for success.

### Usage
Add to a Jamf policy with enter the appropriate package name into parameter 4. By default the script will search /Users/Shared for the CatDVCCPanel package name. The package must be part of this policy or cached prior to policy execution for the installation to succeed.

## CatDVCCPanel_Uninstall
Removes CatDVCCPaenl from all eligible Adobe Creative Cloud apps.

#### Usage
The script should be added to a Jamf policy and run on the desired device. The uninstall will remove the panel from ALL eligible apps and is not selective.

