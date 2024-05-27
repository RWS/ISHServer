<#
# Copyright (c) 2024 All Rights Reserved by the RWS Group.
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


function Set-ISHUserAdministrator
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$OSUser
    )
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet
    }

    process
    {
        # http://docs.sdl.com/LiveContent/content/en-US/SDL%20Knowledge%20Center%20full%20documentation-v2/GUID-4D619D1F-CA8C-4E43-BA0C-8CEB456AC263

        # Add the osuser to the administrators group
        Write-Debug "Adding $OSUser to Administrators"

        if(Get-Module "Microsoft.PowerShell.LocalAccounts" -ListAvailable)
        {
            # https://technet.microsoft.com/en-us/library/mt651690.aspx
            if(-not (Get-LocalGroupMember -Name Administrators |Where-Object -Property Name -EQ $OSUser))
            {
                Add-LocalGroupMember -Group "Administrators" -Member $OSUser
            }
            Write-Verbose "Added $OSUser to Administrators"
        }
        else
        {
            Write-Warning "Using net.exe commands because Microsoft.PowerShell.LocalAccounts module is not available"
            if((& net localgroup Administrators) -notcontains $OSUser)
            {
                $netCmdArgs=@(
                    "localgroup"
                    "Administrators"
                    $OSUser
                    "/add"
                )
                & net $netCmdArgs
            }
            Write-Verbose "Added $OSUser to Administrators"
        }

    }

    end
    {

    }
}
