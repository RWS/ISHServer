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

. $PSScriptRoot\Get-ISHServerFolderPath.ps1

function Install-ISHToolEclipseTemurinOpenJDK
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
        $fileName=Get-Variable -Name "ISHServer:EclipseTemurinOpenJDK" -ValueOnly
        $filePath=Join-Path (Get-ISHServerFolderPath) $fileName
        $targetPath="C:\EclipseAdoptiumOpenJDK"
        if(Test-Path $targetPath)
        {
            Write-Warning "$targetPath already exists"
        }
        else
        {
            Write-Debug "Creating $targetPath"
            New-Item $targetPath -ItemType Directory |Out-Null
        }
        Write-Debug "Unzipping $filePath to $targetPath"
        [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')|Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($filePath, $targetPath)|Out-Null
        Write-Verbose "Installed $filePath"
    }
    end
    {

    }
}
