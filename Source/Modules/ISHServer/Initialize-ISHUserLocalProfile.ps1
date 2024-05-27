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

#requires -Module PoshPrivilege

function Initialize-ISHUserLocalProfile
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
        $OSUserCredentials=Get-ISHNormalizedCredential -Credentials $OSUserCredentials
        $osUserName=$OSUserCredentials.UserName
        $osUserPassword=$OsUserCredentials.GetNetworkCredential().Password
        Write-Verbose "Normalized Credentials"
        Write-Debug "osUserName=$osUserName"

        $arguments=@(
            "-Command"
            "' { } '"
        )
        $powerShellPath=& C:\Windows\System32\where.exe powershell

        Write-Debug "powerShellPath=$powerShellPath"
        
        # Check if execution is within a remoting session
        if(Test-Path -Path Variable:\PSSenderInfo)
        {
            $useScheduledTask=$true
        }
        # Check if execution is invoked by the Windows SYSTEM user. Typically for AWS CodeDeploy and UserData execution
        elseif($env:USERNAME -eq "NT AUTHORITY\SYSTEM")
        {
            $useScheduledTask=$true
        }
        # Check if execution is invoked by the Windows SYSTEM user. Typically for AWS CodeDeploy and UserData execution
        elseif($env:USERNAME -eq "$($env:computername)`$")
        {
            $useScheduledTask=$true
        }
        else
        {
            $useScheduledTask=$false
        }
        Write-Debug "useScheduledTask=$useScheduledTask"

        # When the script is executing within a remoting session or from the Windows System user, we need to create and destroy a scheduled task that will force the user's profile initialization.
        if($useScheduledTask)
        {
            Write-Verbose "Using a scheduled task to initialize $osUserName"
            
            Write-Debug "Added SeBatchLogonRight privilege to $osUserName"
            Add-Privilege -AccountName $osUserName -Privilege SeBatchLogonRight
            Write-Verbose "Added SeBatchLogonRight privilege to $osUserName"

            $taskName="Initialize $osUserName user profile"
            $argumentList=$arguments -join ' '
            $command="Start-Process -FilePath powershell -LoadUserProfile -Wait -ArgumentList ""$argumentList"""
            $action = New-ScheduledTaskAction -Execute $powerShellPath -Argument "-Command '& { $command }'"
            Write-Debug "taskName=$taskName"
            Write-Debug "command=$command"
            Write-Debug "argumentList=$argumentList"
            Write-Debug "Register and starting Scheduled Task $taskName"
            $task = Register-ScheduledTask -TaskName $taskName -Action $action -User $osUserName -Password $osUserPassword
            Write-Verbose "Scheduled Task $taskName registered"

            Start-ScheduledTask -InputObject $task
            Write-Verbose "Scheduled Task $taskName started"

            $state=($task|Get-ScheduledTask).State
            Write-Debug "Scheduled Task $taskName state is $state."
            while($state -eq "Ready")
            {
                Start-Sleep -Milliseconds 500
                Write-Debug "Waiting for Scheduled Task $taskName"

                $state=($task|Get-ScheduledTask).State
                Write-Debug "Scheduled Task $taskName state is $state."
            }
            Write-Verbose "Scheduled Task $taskName removed"

            Write-Debug "Removing Scheduled Task $taskName"
            $task|Unregister-ScheduledTask -Confirm:$false
            Write-Verbose "Scheduled Task $taskName removed"
            
            Write-Debug "Removing SeBatchLogonRight privilege from $osUserName"
            Remove-Privilege -AccountName $osUserName -Privilege SeBatchLogonRight
            Write-Verbose "Removed SeBatchLogonRight privilege from $osUserName"
        }
        else
        {
            Write-Verbose "Using a normal process to initialize $osUserName"
            Write-Debug "Starting process"
            Start-Process -FilePath $powerShellPath -ArgumentList $arguments -Credential $OsUserCredentials -LoadUserProfile -NoNewWindow  -Wait
            Write-Verbose "Finished process"
        }
    }

    end
    {

    }
}
