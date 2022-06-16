## Overview
This script can be used with Jamf policies to verify and set network order on workstations

### Usage
Used as a script in Jamf policies to set network order. Provide either wifi or ethernet in Parameter 4 to determine which mode to run the script. The script is designed to re-arrange the network order to the parameter provided and then drops a receipt in a specified location to be referenced later. The receipt was incorporated to be used with additional scripts or Jamf EA if you want your entire fleet to prefer wired or wireless networks.
