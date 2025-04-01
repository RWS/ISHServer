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

function Test-RunningAsElevated
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (        
        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $StopCallerPSCmdlet=$null
    )

    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    $isAdmin=$prp.IsInRole($adm)
    
    if($StopCallerPSCmdlet)
    {
        if(-not $isAdmin)
        {
            $exception = New-Object System.InvalidOperationException "The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by  using the Run as Administrator option, and then try running the script again."
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, "InvalidOperationException", ([System.Management.Automation.ErrorCategory]::PermissionDenied),$null
            $StopCallerPSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
    else
    {
        $isAdmin
    }
}