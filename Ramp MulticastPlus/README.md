## Overview
This is an uninstall script for the Ramp MulticastPlus application. Designed for fleet-wide use on all macOS workstations.

### Ramp Uninstall
Add to a Jamf policy with appropriate scoping. No additional parameters or settings are needed to execute. The script will stop all involved LaunchDaemons, remove them and remove the Ramp MulticastPlus application.

### Ramp Unified Client Uninstall
Add to a Jamf policy with appropriate scoping. No additional parameters or settings are needed to execute. The script will stop all involved LaunchDaemons, remove them and remove the Ramp MulticastPlus application. This is intended for the "Unified" Client of Ramp MulticastPlus Reciever (version 3.1.6 or later).

### Ramp Version
Used as an extension attribute to find the current version installed of Ramp MulticastPlusReciever. This only works with version 3.1.6 and above with Ramp's move to the unified reciever. This EA combs the Ramp logs searching for version as the current installer does not supply a plist identifier.
