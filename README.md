# Jamf-LAPS
With the release of Jamf Pro 10.45, a new API endpoint was added, which introduces the local administrator password solution (LAPS) via the Jamf Pro API. 

At present this feature is only available via the APIs, at some point in the future it will be added to the Jamf Pro UI.

In the interim this app will allow you too:

- Enable / Disable the service
- Set the number of seconds for the password rotation time
- Set the number of seconds for the password auto expiration time
- Retrive the password for a given Mac and LAPS username

### Requirements

- A Mac running macOS Venture (13.0)
- Jamf Pro 10.45 or higher
- Jamf Pro Account that has the following minimum permissions
  - Send Local Admin Password Command
  - Update Local Admin Password Settings
  - View Local Admin Password
  - View Local Admin Password Audit History

### PLEASE NOTE THIS IS CURRENTLY IN BETA
