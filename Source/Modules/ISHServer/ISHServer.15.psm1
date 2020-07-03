<#
# Copyright (c) 2014 All Rights Reserved by the SDL Group.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#>

Set-Variable -Name "ISHServer:JDK" -Value "jdk-8u144-windows-x64.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:JRE" -Value "jre-8u144-windows-x64.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:AdoptOpenJDK" -Value "OpenJDK11-jdk_x64_windows_hotspot_11_28.zip" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:AdoptOpenJRE" -Value "OpenJDK11-jre_x64_windows_hotspot_11_28.zip" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:JavaHelp" -Value "javahelp-2_0_05.zip" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:HtmlHelp" -Value "htmlhelp.zip" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:AntennaHouse" -Value "V6-5-R1-Windows_X64_64E.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:AntennaHouseInstallPath" -Value "Antenna House\AHFormatterV65\" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:Oracle19" -Value "ODAC193Xcopy_32bit" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:MicrosoftVisualCPlusPlusRedistributable" -Value "NETFramework2015_4.6_MicrosoftVisualC++Redistributable_(vc_redist.x64).exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:NETFrameworkRequiredVersion" -Value "4.7.2" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:NETFramework" -Value "NETFramework2017_4.7.2.xxxxx_(NDP472-KB4054530-x86-x64-AllOS-ENU).exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:VisualBasicRuntime" -Value "vbrun60sp6.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:MSOLEDBSQLRequiredVersion" -Value "18.2.1.0" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:MSOLEDBSQL" -Value "msoledbsql_18.3.0.0_x64.msi" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:DotNetHosting" -Value "dotnet-hosting-3.1.5-win.exe"  -Scope "Script" -Option Constant
#Set-Variable -Name "ISHServer:MSXML" -Value "MSXML.40SP3.msi" -Scope "Script" -Option Constant

$exportNames=@(
    #region Helpers
    "Get-ISHOSInfo"
    "Get-ISHNETInfo"
    "Test-ISHServerCompliance"
    "Get-ISHServerFolderPath"
    "Grant-ISHUserLogOnAsService"
    "Get-ISHServerCOMPlus"
    "Get-ISHNormalizedCredential"
    #endregion

    #region Ports
    "Set-ISHFirewallHTTPS"
    "Set-ISHFirewallNETBIOS"
    "Set-ISHFirewallOracle"
    "Set-ISHFirewallHTTPS"
    "Set-ISHFirewallSMTP"
    "Set-ISHFirewallSQLServer"
    #endregion


    #region Global
    "Get-ISHServerFolderPath"
    "Get-ISHPrerequisites"
    "Initialize-ISHLocale"
    "Initialize-ISHIIS"
    "Initialize-ISHUserLocalProfile"
    "Set-ISHUserLocal"
    "Set-ISHUserAdministrator"
    "Initialize-ISHRegistry"
    #endregion

    #region Install
    "Install-ISHToolDotNET"
    "Install-ISHToolVisualCPP"
    "Install-ISHToolJAVA"
    "Install-ISHToolAdoptOpenJDK"
    "Install-ISHToolAdoptOpenJRE"
    "Install-ISHToolJavaHelp"
    "Install-ISHToolHtmlHelp"
    "Install-ISHToolAntennaHouse"
    "Install-ISHToolOracleODAC"
    "Install-ISHToolOracleODACv19"
    "Install-ISHWindowsFeature"
    "Install-ISHWindowsFeatureIISWinAuth"
    "Install-ISHVisualBasicRuntime"
    "Install-ISHToolMSOLEDBSQL"
    "Install-ISHDotNetHosting"
    #endregion

    #region Regional settings
    "Initialize-ISHRegional"
    "Initialize-ISHRegionalDefault"
    #endregion

    #region License
    "Set-ISHToolAntennaHouseLicense"
    #endregion

	#region CD
    "Expand-ISHCD"
    "Get-ISHCD"
	#endregion
)

$privateNames=@(
    "Get-ISHFTPItem"
    "Get-ISHS3Object"
    "Get-ISHAzureFileObject"
    "Get-ISHAzureBlobObject"
    "Test-RunningAsElevated"
)

$privateNames | ForEach-Object {. $PSScriptRoot\Private\$_.ps1 }
$exportNames | ForEach-Object {. $PSScriptRoot\$_.ps1 }

$exportedMemberNames=$exportNames -replace "\.ISH[0-9]+",""
Export-ModuleMember $exportedMemberNames
