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

$sourcePath=Resolve-Path "$PSScriptRoot\..\.."

Import-Module "$sourcePath\Tools\Modules\SDLDevTools\0.1\SDLDevTools.psm1" -Force

# Must convert to array of hash to drive the It -Testcases parameter
$filesToValidate=@()
Get-ChildItem -Path $sourcePath -Recurse -File -Exclude ".git" |Select-Object Name,FullName|ForEach-Object {
    $hash=@{
        Name=$_.Name
        FullName=$_.FullName
    }
    $filesToValidate+=$hash
}

Describe "Verify open source headers" {
    It "Test-SDLOpenSourceHeader <Name>" -TestCases $filesToValidate {
        param ($Name,$FullName)
        Test-SDLOpenSourceHeader -FilePath $FullName
    }
}
