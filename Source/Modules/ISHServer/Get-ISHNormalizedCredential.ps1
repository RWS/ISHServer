<#
# Copyright (c) 2021 All Rights Reserved by the RWS Group.
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

function Get-ISHNormalizedCredential
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [pscredential]$Credentials
    )
    
    begin 
    {
    }

    process
    {

        if($Credentials.UserName.StartsWith(".\"))
        {
            Write-Warning "Credentials normalization.Replaced .\ with $env:COMPUTERNAME"
            New-Object System.Management.Automation.PSCredential($Credentials.UserName.Replace(".",$env:COMPUTERNAME),$Credentials.Password)
        }
        elseif($Credentials.UserName.indexOf("\") -lt 0)
        {
            Write-Warning "Credentials normalization.Prefixed with $env:COMPUTERNAME"
            New-Object System.Management.Automation.PSCredential("$env:COMPUTERNAME\$($Credentials.UserName)",$Credentials.Password)
        }
        else
        {
            $Credentials
        }
    }

    end
    {

    }
}
