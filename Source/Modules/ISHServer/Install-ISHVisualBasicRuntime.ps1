<#
# Copyright (c) 2025 All Rights Reserved by the RWS Group.
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

function Install-ISHVisualBasicRuntime
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
        if($osInfo.IsCore)
        {
            # Workaround for Windows Server 2016/2019 core
            # https://social.technet.microsoft.com/Forums/windowsserver/en-US/9b0f8911-07f4-420f-9e48-d31915f91528/msvbvm60dll-missing-in-core?forum=winservercore
            Write-Warning "This is a workaround for making the Visual Basic runtime available on $($osInfo.Caption) Core"

            $fileName=Get-Variable -Name "ISHServer:VisualBasicRuntime" -ValueOnly
            $filePath=Join-Path (Get-ISHServerFolderPath) $fileName
            $arguments=@(
                "/Q"
            )

            Write-Debug "Installing $fileName"
            Start-Process $filePath -ArgumentList $arguments -Wait -Verb RunAs
            Write-Verbose "Installed $fileName"
        }
    }

    end
    {

    }
}
