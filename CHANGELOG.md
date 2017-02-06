**1.2**

**1.1**

Issues:
- GH-3: Amazon Web Services S3 bucket support.
- GH-7: Download and expand ISHCD.

In detail:
- Upgraded the SDLDevTools PowerShell module to version 0.2
- `Get-ISHPrerequisites` now supports S3 buckets as source. 
- `Set-ISHToolAntennaHouseLicense` now supports S3 buckets as source.
- `Test-RunningAsElevated` is now a private function in the module.
-  New `Get-ISHCD` cmdlet:
  - Downloads a CD from FTP or AWS S3 bucket.
  - Returns the available CDs.
-  New `Expand-ISHCD` cmdlet expands a CD into `C:\ISHCD`.

**1.0**

- Split from [ISHBootstrap](https://github.com/Sarafian/ISHBootstrap).
- Module doesn't require elevated privileges as a total. Only the necessary cmdlets. You can import and query the system without elevated privileges.