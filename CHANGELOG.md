**1.1**

- Upgraded the SDLDevTools PowerShell module to version 0.2
- `Get-ISHPrerequisites` now supports S3 buckets as source.
- `Set-ISHToolAntennaHouseLicense` now supports S3 buckets as source.
- `Test-RunningAsElevated` is now a private function in the module.

**1.0**

- Split from [ISHBootstrap](https://github.com/Sarafian/ISHBootstrap).
- Module doesn't require elevated privileges as a total. Only the necessary cmdlets. You can import and query the system without elevated privileges.