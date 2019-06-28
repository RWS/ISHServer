# ISHServer
A PowerShell module to help automate installation of prerequisites for **SDL Tridion Docs** (SDL Knowledge Center Content Manager, LiveContent Architect, Trisoft InfoShare).

# Available ISHServer modules

## ISHServer.14

[ISHServer.14**](https://www.powershellgallery.com/packages/ISHServer.14/) is the specific module matching the prerequisite requirements of the **Tridion Docs 14** release.

## ISHServer.13

[ISHServer.13**](https://www.powershellgallery.com/packages/ISHServer.13/) is the specific module matching the prerequisite requirements of the **Knowledge Center 2018** release.

## ISHServer.12

[ISHServer.12**](https://www.powershellgallery.com/packages/ISHServer.12/) is the specific module matching the prerequisite requirements of the **Knowledge Center 2016** release.

## Prerequisite and CD sources

The module can retrieve files from the following type of sources:

- FTP
- Amazon Web Services S3 bucket
- Azure file and blob storage

For each, different type of credentials are required.

## Preparation

To test if the operating system is compatible execute first `Test-ISHServerCompliance`.
If the result is `$false` then do not proceed as the module most probably will not work.
The supported operating systems are:

- Windows Server 2012 R2
- Windows Server 2016
- Windows Server 2019
- Windows 8.1 (not tested)
- Windows 10

Because of the size of required prerequisites they are not included in the module.
This makes it your responsibility to make them available to the module.
To find out which file names are required, execute `Get-ISHPrerequisites -FileNames`.
You need to execute this on the target server because operating system information is taken into account to generate
the list of file names (OS Server version, already installed prerequisites, ...).

The complete list per Tridion Docs/Knowledge Center version:

**Tridion Docs - Content Manager 14 - ISHServer.14**

```text
htmlhelp.zip
javahelp-2_0_05.zip
NETFramework2015_4.6_MicrosoftVisualC++Redistributable_(vc_redist.x64).exe
NETFramework2017_4.7.2.xxxxx_(NDP472-KB4054530-x86-x64-AllOS-ENU).exe
ODTwithODAC122010.rsp
ODTwithODAC122010.zip
OpenJDK11-jdk_x64_windows_hotspot_11_28.zip
OpenJDK11-jre_x64_windows_hotspot_11_28.zip
V6-5-R1-Windows_X64_64E.exe
V6-5-R1-Windows_X64_64E.exe.iss
V6-5-R1-Windows_X64_64E.exe.vcredist_x64.exe
V6-5-R1-Windows_X64_64E.exe.vcredist_x86.exe
```

**Knowledge Center 2018 - Content Manager 13 - ISHServer.13**

```text
htmlhelp.zip
javahelp-2_0_05.zip
jdk-8u144-windows-x64.exe
jre-8u144-windows-x64.exe
NETFramework2015_4.6.1.xxxxx_(NDP461-KB3102436-x86-x64-AllOS-ENU).exe
NETFramework2015_4.6_MicrosoftVisualC++Redistributable_(vc_redist.x64).exe
ODTwithODAC122010.rsp
ODTwithODAC122010.zip
V6-5-R1-Windows_X64_64E.exe
V6-5-R1-Windows_X64_64E.exe.iss
V6-5-R1-Windows_X64_64E.exe.vcredist_x64.exe
V6-5-R1-Windows_X64_64E.exe.vcredist_x86.exe
```

**Knowledge Center 2016 - Content Manager 12 - ISHServer.12**

```text
htmlhelp.zip
javahelp-2_0_05.zip
jdk-8u60-windows-x64.exe
jre-8u60-windows-x64.exe
MSXML.40SP3.msi
NETFramework2013_4.5_MicrosoftVisualC++Redistributable_(vcredist_x64).exe
ODTwithODAC121012.rsp
ODTwithODAC121012.zip
V6-2-M9-Windows_X64_64E.exe
V6-2-M9-Windows_X64_64E.exe.iss
V6-2-M9-Windows_X64_64E.exe.vcredist_x64.exe
V6-2-M9-Windows_X64_64E.exe.vcredist_x86.exe
```

If you want to manually make the files available to the module then copy them to the location provided by `Get-ISHServerFolderPath`.
As an alternative, the `Get-ISHPrerequisites` cmdlet offers the option to download the files and will take care of everything.

## Installing and configuring

Once the files are available on the server, you can start the installation of the prerequisites and their configuration using the rest of the cmdlets.
The module is structured in manner that represents the steps described in the product's [documentation](http://docs.sdl.com/) (section SDL Tridion Docs).
Understanding the prerequisites and how to configure them will be helpful but it is not a requirement.
An example of how to use the sequence of the installation and configuration is available in [ISHBootstrap](https://github.com/sdl/ISHBootstrap).

## CD Management

ISHServer offers two cmdlets to download and expand the ISHCD. **Notice that it will not install a CD!**
- `Get-ISHCD` can download a CD or show the ones already downloaded and expanded.
- `Expand-ISHCD` will expand the CD.

The target path is always `C:\ISHCD\X.0.Z` where `X` is the major version and `Y` the revision, e.g.
- For `13.0.0` it's `C:\ISHCD\13.0.0`
- For `12.0.3` it's `C:\ISHCD\12.0.3`
- For `14.0.0` it's `C:\ISHCD\14.0.0`

## Maintenance

For installation and maintenance reasons, the module offers a couple of general purpose cmdlets:

- `Get-ISHServerCOMPlus` returns the status of COM+ applications. This can prove useful for troubleshooting after the product is installed.
- `Get-ISHNETInfo` returns the available .NET versions on the operating system.
- `Get-ISHOSInfo` returns details of the operating system.

# Acknowledgements

There are not automated tests for this module, but issues are generally focused on the automation of a specific action.

# Contribution

The module is developed with the PowerShell scripting language.
Current SDL's open source policies require each file to have a header.
An automation for this is offered by a copy of the module [SDLDevTools](Tools/Modules/SDLDevTools) and can be executed with the [Test-SDLHeaders.Tests.ps1](Automation/Pester/Test-SDLHeaders.Tests.ps1) Pester script.