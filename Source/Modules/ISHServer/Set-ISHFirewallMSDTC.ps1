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

function Set-ISHFirewallMSDTC
{
    [CmdletBinding()]
    Param()
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet
    }

    process
    {
        $ruleNameTCP="ISH - MSDTC - TCP"
        # http://docs.sdl.com/LiveContent/content/en-US/SDL%20Knowledge%20Center%20full%20documentation-v2/GUID-D7592291-94D3-4BBF-9034-1988F4405040
	
        Get-NetFirewallRule -DisplayName $ruleNameTCP -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    
        New-NetFirewallRule -DisplayName $ruleNameTCP -Direction Inbound -Action Allow -LocalPort @("135","5000-6000") -Protocol TCP |Out-Null
        New-NetFirewallRule -DisplayName $ruleNameTCP -Direction Outbound -Action Allow -LocalPort @("135","5000-6000") -Protocol TCP |Out-Null
	    Write-Verbose "$ruleNameTCP firewall rule set"
    }

    end
    {

    }
}
