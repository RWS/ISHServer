# ISHServer
A PowerShell module to help automate installation of prerequisites for **Knowledge Center Content Manager**.

# ISHServer.12 

[ISHServer.12**](https://www.powershellgallery.com/packages/ISHServer.12/) is the specific module matching the prerequisite requirements of the **Knowledge Center 2016** release. 

The module requires elevated privileges for most of its cmdlets. 

## Preparation 

To test if the operating system is compatible execute first `Test-ISHServerCompliance`. 
If the result is `$false` then do not proceed as the module most probably will not work.
The supported operating systems are:

- Windows Server 2012 R2.
- Windows Server 2016.
- Windows 8.1 (not tested).
- Windows 10.

Because of the size of **Knowledge Center Content Manager** prerequisites they are not included in the module. 
This makes it your responsibility to make them available to the module. 
To find out which file names are required, execute `Get-ISHPrerequisites -FileNames` and the result should be 

```text
MSXML.40SP3.msi
jdk-8u60-windows-x64.exe
jre-8u60-windows-x64.exe
javahelp-2_0_05.zip
htmlhelp.zip
V6-2-M9-Windows_X64_64E.exe
V6-2-M9-Windows_X64_64E.exe.iss
V6-2-M9-Windows_X64_64E.exe.vcredist_x64.exe
V6-2-M9-Windows_X64_64E.exe.vcredist_x86.exe
ODTwithODAC121012.zip
ODTwithODAC121012.rsp
NETFramework2013_4.5_MicrosoftVisualC++Redistributable_(vcredist_x64).exe
```

If you want to manually make the files available to the module then copy them to the location provided by `Get-ISHServerFolderPath`. 
As an alternative, the `Get-ISHPrerequisites` cmdlet offers the option to download the files from a known location and will take care of everything. 
Current options are:

- FTP. Just provide the ftp hostname, a relative folder path containing the above files and the credentials. e.g. `Get-ISHPrerequisites -Credential $Credential -FTPFolder $folderPath -FTPHost $host`.

## Installing and configuring

Once the files are available on the server, you can start the installation of the prerequisites and their configuration using the rest of the cmdlets.
The module is structured in manner that represents the steps described in the product's [documentation](http://docs.sdl.com/LiveContent/web/pub.xql?action=home&pub=SDL%20Knowledge%20Center%20full%20documentation-v2.1.2&lang=en-US). 
Understanding the prerequisites and how to configure them will be helpful but it is not a requirement.
An example of how to use the sequence the installation and configuration is available in [ISHBootstrap](https://github.com/Sarafian/ISHBootstrap).

## Maintenance

For installation and maintenance reasons, the module offers a couple of general purpose cmdlets:

- `Get-ISHCOMPlus` returns the status of COM+ applications. This can prove useful for troubleshooting after the product is installed.
- `Get-ISHNETInfo` returns the available .NET versions on the operating system.
- `Get-ISHOSInfo` returns details of the operating system. 

# ISHServer.13

**ISHServer.13** is the module for the next major release **Knowledge Center Content Manager** and **it's not published** in the PowerShell gallery. 
The goal is to reuse as much as possible the scripts developed for **ISHServer.12** but here are a couple of things to keep in mind:

- When a prerequisite is dropped, then the relative cmdlets will be also dropped. 
- When a prerequisite version is changed, then the cmdlet's implementation will be adjusted to match the correct version of the prerequisite.

Current differences of **ISHServer.13** with **ISHServer.12**:

- **MSDTC** is removed form the prerequisites list, therefore the `Initialize-ISHMSDTCSettings` and `Initialize-ISHMSDTCTransactionTimeout` cmdlets are removed.
- **MSXML** is removed form the prerequisites list, therefore the `Install-ISHToolMSXML4` cmdlet is removed.
- **Microsoft .NET Framework 4.6.1** is required instead of **Microsoft .NET Framework 4.5**.
- **Visual C++ Redistributable for Visual Studio 2015** is required instead of **Visual C++ Redistributable for Visual Studio 2013**.

# Acknowledgements

There are not automated tests for this module, but issues are generally focused on the automation of a specific action. 

# Contribution

The module is developed with the PowerShell scripting language. 
Current SDL's open source policies require each file to have a header. 
An automation for this is offered by a copy of the module [SDLDevTools](Tools/Modules/SDLDevTools) and can be executed with the [Test-SDLHeaders.Tests.ps1](Automation/Pester/Test-SDLHeaders.Tests.ps1) Pester script.