# modifyStaticUserGroup
Script to modify a specified static user group in Jamf to add/remove a user

## Description
modifyStaticUserGroup modifies the specified static user group to add or remove the user. The intent is for the user to execute a policy in Self Service to add a configuration that is scoped to the static user group. An accompanying removal policy should be created and configured to run this script using the remove parameter.

## Parameters
- groupID - ID of the static group being modified in Jamf
- action - expecting "add" or "remove" as the action to take on the user in the group
- salt - for the casperAPI account
- passphrase - for the casperAPI account
