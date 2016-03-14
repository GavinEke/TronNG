# Changelog

## v3.0.0.0

* Removed Test-Administrator as "#Requires -RunAsAdministrator" is at the start of the script
* Changed the way the log is performed to help with people who already use PowerShell Transcript
* Incuded the ability to skip any step by using case sensative -SkipStep{number} Eg. `.\TronNG.ps1 -SkipStep1 -SkipStep 2` will skip the Update and Virus Scan Steps
