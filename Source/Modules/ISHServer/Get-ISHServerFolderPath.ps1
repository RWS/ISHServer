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

function Get-ISHServerFolderPath
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$UNC=$false
    )

    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet
    }

    process
    {
        $programDataPath=Join-Path $env:ProgramData ($MyInvocation.MyCommand.Module.Name)
        if(-not (Test-Path $programDataPath))
        {
            New-Item $programDataPath -ItemType Directory |Out-Null
        }
        if($UNC)
        {
            return "\\"+$env:COMPUTERNAME+"\"+$programDataPath.Replace($env:SystemDrive,$env:SystemDrive.Replace(":","$"))
        }
        else
        {
            return $programDataPath
        }
    }

    end
    {

    }
}
