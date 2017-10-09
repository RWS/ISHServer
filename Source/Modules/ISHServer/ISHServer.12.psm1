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

Set-Variable -Name "ISHServer:JDK" -Value "jdk-8u60-windows-x64.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:JRE" -Value "jre-8u60-windows-x64.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:JavaHelp" -Value "javahelp-2_0_05.zip" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:HtmlHelp" -Value "htmlhelp.zip" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:AntennaHouse" -Value "V6-2-M9-Windows_X64_64E.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:AntennaHouseInstallPath" -Value "Antenna House\AHFormatterV62\" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:Oracle" -Value "ODTwithODAC121012" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:MicrosoftVisualCPlusPlusRedistributable" -Value "NETFramework2013_4.5_MicrosoftVisualC++Redistributable_(vcredist_x64).exe" -Scope "Script" -Option Constant
#Set-Variable -Name "ISHServer:NETFramework" -Value "jre-8u60-windows-x64.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:VisualBasicRuntime" -Value "vbrun60sp6.exe" -Scope "Script" -Option Constant
Set-Variable -Name "ISHServer:MSXML" -Value "MSXML.40SP3.msi" -Scope "Script" -Option Constant

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
    "Set-ISHFirewallMSDTC"
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
    "Initialize-ISHMSDTCSettings"
    "Initialize-ISHMSDTCTransactionTimeout"
    #endregion

    #region Install
    "Install-ISHToolMSXML4"
    "Install-ISHToolDotNET"
    "Install-ISHToolVisualCPP"
    "Install-ISHToolJAVA"
    "Install-ISHToolJavaHelp"
    "Install-ISHToolHtmlHelp"
    "Install-ISHToolAntennaHouse"
    "Install-ISHToolOracleODAC"
    "Install-ISHWindowsFeature"
    "Install-ISHWindowsFeatureIISWinAuth"
    "Install-ISHVisualBasicRuntime"
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
