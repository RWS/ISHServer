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


function Set-ISHUserLocal
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [pscredential]$OSUserCredentials
    )
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet
    }

    process
    {
        $osUserName=$OSUserCredentials.UserName
        $osUserPassword=$OsUserCredentials.GetNetworkCredential().Password
        $localUserNameToAdd=$osUserName.Substring($osUserName.IndexOf('\')+1)

        Write-Verbose "Normalized Credentials"
        Write-Debug "osUserName=$osUserName"
        
        if($OsUserCredentials.UserName.StartsWith("$($env:computername)\"))
        {
            $overwriteLocalUser=$true
        }
        elseif($OsUserCredentials.UserName.StartsWith(".\"))
        {
            $overwriteLocalUser=$true
        }
        elseif($OsUserCredentials.UserName.indexOf("\") -lt 0)
        {
            $overwriteLocalUser=$true
        }
        else
        {
            $overwriteLocalUser=$false
        }

        Write-Debug "overwriteLocalUser=$overwriteLocalUser"

        if($overwriteLocalUser)
        {
            $localUserName=$osUserName.Substring($osUserName.IndexOf('\')+1)
            Write-Debug "localUserNameToAdd=$localUserName"

            if(Get-Module Microsoft.PowerShell.LocalAccounts -ListAvailable)
            {
                if(Get-LocalUser -Name $localUserName -ErrorAction SilentlyContinue)
                {
                    Set-LocalUser -Name $localUserName -Password $OsUserCredentials.Password -AccountNeverExpires
                    Write-Verbose "Updated $localUserName"
                }
                else
                {
                    New-LocalUser -Name $localUserName -Password $OsUserCredentials.Password -AccountNeverExpires -PasswordNeverExpires
                    Write-Verbose "Created $localUserName"
                }
            }
            else
            {
                Write-Warning "Using net.exe commands because Microsoft.PowerShell.LocalAccounts module is not available"

                Write-Debug "Querying local users for $localUserName"
                $netUserOutput=& net user
                $lineHasUsers=$false
                $existingUsers=@()
                for($i=0;$i -lt $netUserOutput.Count;$i++)
                {
                    if($netUserOutput[$i] -eq "The command completed successfully.")
                    {
                        $lineHasUsers=$false
                    }
                    if($lineHasUsers)
                    {
                        $existingUsers+=$netUserOutput[$i].Split(' ')|Where-Object {$_ -ne ""}
                    }
                    if($netUserOutput[$i].StartsWith("---------"))
                    {
                        $lineHasUsers=$true
                    }
                }

                if($existingUsers -contains $localUserName)
                {
                    & NET USER $localUserName $osUserPassword
                    Write-Verbose "Updated $localUserName"
                }
                else
                {
                    &  NET USER $localUserName $osUserPassword /ADD
                    $user = [adsi]"WinNT://$env:computername/$localUserName"
                    $user.UserFlags.value = $user.UserFlags.value -bor 0x10000
                    $user.CommitChanges()    
                    
                    Write-Verbose "Created $localUserName"
                }

            }
        }
    
        # Grant Log on as Service to the osuser
        Write-Debug "Granting ServiceLogonRight to $OSUser"
        Grant-ISHUserLogOnAsService -User $osUserName
        Write-Verbose "Granted ServiceLogonRight to $OSUser"
    }

    end
    {

    }
}
