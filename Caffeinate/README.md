## Overview
This is a multi-part script deigned to be used in conjunciton with multiple Jamf policy executions. The workflow uses Launchds to trigger cascading policies to terminate the caffeinate policy and cleanup the workflow on workstations

## Start Caffeinate
This script kicks off the initial workflow and has required parameters that must be entered into Jamf. The workflow allows the following modifiers for caffeinate: -d, -i, -m and -u. Set paramteres 8 & 9 which to determine when the kill script initiates and terminates the caffeinate process.

## Stop Caffeinate
Second script in the policy chain. This script kills the original caffeinate process and initiates the cleanup. The script has safeguards based on caffeinate PID and will not terminate a user initiated caffeinate session.

## Clean Caffeinate
This is built off a watch launchD that initiates once a receipt is placed by the *stop caffeinate* script. The script unloads and removes the launchds created by the *start caffeinate* script
