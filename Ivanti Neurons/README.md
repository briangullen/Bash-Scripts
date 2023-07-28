## Overview
This is a location to house all scripts related to Ivanti Neurons

### Ivanti Neurons Install
This script will install and activate Ivanti Neurons in Jamf Pro. It requires the package to be cached in the default Jamf location and will move to tmp, install and activate Ivanti Neurons and then cleanup the cached package.

### Usage
Add the script to a policy in Jamf Pro and execute after caching package to default Jamf Waiting Room location.
- Required Inputs:
  - $4 - Name of cached Ivanti Neurons pkg
  - $5 - Activation key for Ivanti Neurons
