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
    "Get-ISHPrerequisites.ISH13"
    "Initialize-ISHLocale"
    "Initialize-ISHIIS"
    "Initialize-ISHUserLocalProfile"
    "Set-ISHUserLocal"
    "Set-ISHUserAdministrator"
    "Initialize-ISHRegistry"
    #endregion

    #region Install
    "Install-ISHToolDotNET.ISH13"
    "Install-ISHToolVisualCPP.ISH13"
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
