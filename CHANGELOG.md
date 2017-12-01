**1.6**

Issues:
- GH-32: Set-ISHUserLocal throws error "net.exe : The user name could not be found." when the password has character "
- GH-31: Set-ISHUserLocal cannot work with passwords longer than 14 characters
- GH-34: Rename Get-ISHCOMPlus to Get-ISHServerCOMPlus
- GH-42: Make ContentManager2018 the primary artifact

In detail:
- Renamed `Get-ISHCOMPlus` to `Get-ISHServerCOMPlus`

Remarks:
- Moved links from https://github.com/Sarafian to https://github.com/sdl .

**1.5**

Issues:
- GH-27: Improve management of OSUser.
- GH-12: Avoid downloading when the file is already available.

In detail:
- `Initialize-ISHUser` is **deleted** and split into `Set-ISHUserLocal`, `Set-ISHUserAdministrator`, `Initialize-ISHUserLocalProfile` and `Initialize-ISHRegistry`.
	- `Set-ISHUserLocal` adds the osuser when necessary to the local user registry. When the user exists, it will update the password.
	- `Set-ISHUserAdministrator` sets the osuser as the local administrator.
	- `Initialize-ISHUserLocalProfile` forces the osuser to fully initialize, including the user profile directory.
	- `Initialize-ISHRegistry` disables registry unload.
- `Get-ISHNormalizedCredential` normalizes the credentials so they are good with all cmdlets. This is required before using any cmdlet that accepts credentials for the osuser.
- `Get-ISHPrerequisites` will skip downloading files that are already downloaded. Use the `-Force` parameter to force the download regardless.

**1.4**

Issues:
- GH-23: New dependency to [PoshPrivilege](https://www.powershellgallery.com/packages/PoshPrivilege/) for `Grant-ISHUserLogOnAsService`.

**1.3**

Issues:

- GH-20: Install-ISHWindowsFeature failes withing a Docker container

**1.2**

Issues:
- GH-13: Initialize-ISHRegional should not require elevated permissions.
- GH-15: Azure file and blob storage support. 
- GH-17: Initialize-ISHRegional sets incorrect registry key for 'Long Time' format.

In detail:
- `Initialize-ISHRegional` doesn't check for elevated permissions.
- `Get-ISHPrerequisites` now supports Azure file and blob storage as source.
- `Set-ISHToolAntennaHouseLicense` now supports Azure file and blob storage as source.
- `Get-ISHCD` now supports Azure file and blob storage as source.

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
