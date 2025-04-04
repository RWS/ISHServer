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

Function Get-SDLOpenSourceHeader {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Raw","CSharp","PowerShell")]
        [string]$Format
    )

    $header= @"
Copyright (c) 2025 All Rights Reserved by the RWS Group.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"@  
    $output=$null
    switch ($Format)
    {
        'Raw' {
            $output=$header
        }
        'CSharp' {
            $output=@("/*")
            $output+=$header -split [System.Environment]::NewLine |ForEach-Object {
                    if([string]::IsNullOrEmpty($_.ToString())) {
#                    if([string]::IsNullOrEmpty($_.ToString().Trim())) {
                        " *"
                    }
                    else {
                        " * $_"
                    }
                }
            $output+=(" */")
            $output+=""
        }
        'PowerShell' {
            $output=@("<#")
            $output+=$header -split [System.Environment]::NewLine |ForEach-Object {"# $_"}
            $output+=("#>")
            $output+=""
        }
    }
    $output
}
