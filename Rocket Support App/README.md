# Rocket Support App

### Overview
This is built off the macOS Support App developed by Root3. It's configurable to display different colors, app icons, information and extension data. This was modified during a Hack Week project as a POC.
More info can be found on the [Support App Github](https://github.com/root3nl/SupportApp)

#### Jamf Deployment
The deployment consists of a configuration profile based on a JSON schema as well as a deployment policy that installs the support app package and utilizes a deployment script to place app contents required for customizing the app appearance and functionality (images, extension scripts).

#### Deployment Script
This script places the required assets that give the app its look and functionality. The script places 3 extension scripts and 2 images inside the directory `/Library/dmg/SupportApp`. This directory should be modified for the deployment directory used in your environment.

#### Configuration Schema
This is a JSON schema that controls the appearance and functionality of the support app. It should be placed into a configuration profile that is deployed prior to the support app.

#### Extension Scripts
These are sample scripts that can be used to populate extension A and extension B of the support app. The scripts use `defaults write` to modify a plist file that then populates data output to the support app.
