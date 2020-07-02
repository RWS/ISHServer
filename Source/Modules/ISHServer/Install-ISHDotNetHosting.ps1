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

function Install-ISHDotNetHosting
{
    [CmdletBinding()]
    Param()
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet

		. $PSScriptRoot\Get-ISHServerFolderPath.ps1
    }

    process
    {
        $fileName=Get-Variable -Name "ISHServer:DotNetHosting" -ValueOnly
        $filePath=Join-Path (Get-ISHServerFolderPath) $fileName
        $logFile=Join-Path $env:TEMP "$FileName.log"
        $arguments=@(
            "/install"
            "/norestart"
            "/quiet"
            "/log"
            "$logFile"
        )
        Write-Debug "Installing $filePath"
        Start-Process $filePath -ArgumentList $arguments -Wait -Verb RunAs
        Write-Verbose "Installed using $fileName"
    }
    end
    {

    }
}
