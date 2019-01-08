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

function Install-ISHToolDotNET 
{
    [CmdletBinding()]
    Param()
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet

		. $PSScriptRoot\Get-ISHServerFolderPath.ps1
        . $PSScriptRoot\Get-ISHOSInfo.ps1
    }

    process
    {
        $osInfo=Get-ISHOSInfo
        [Version]$NETFrameworkRequiredVersion=Get-Variable -Name "ISHServer:NETFrameworkRequiredVersion" -ValueOnly
        if($osInfo.FullNetFrameworkVersion -ge $NETFrameworkRequiredVersion)
        {
            Write-Verbose "Required .NET framework version $($NETFrameworkRequiredVersion) is installed ($($osInfo.FullNetFrameworkVersion) - $($osInfo.Caption))."
        }
        else
        {
            $fileName=Get-Variable -Name "ISHServer:NETFramework" -ValueOnly
            $filePath=Join-Path (Get-ISHServerFolderPath) $fileName
            $logFile=Join-Path $env:TEMP "$FileName.htm"
            $arguments=@(
                "/q"
                "/norestart"
                "/log"
                "$logFile"
            )

            Write-Debug "Installing $filePath"
            Start-Process $filePath -ArgumentList $arguments -Wait -Verb RunAs
            Write-Verbose "Installed $fileName"
            Write-Warning "You must restart the server before you proceed."
        }
    }
    end
    {

    }
}
