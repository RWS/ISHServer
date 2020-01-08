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

function Install-ISHToolOracleODACv19
{
    [CmdletBinding()]
    Param()
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet

		. $PSScriptRoot\Get-ISHServerFolderPath.ps1
    }

    process
    {
        # https://docs.sdl.com/LiveContent/content/en-US/SDL%20Tridion%20Docs-v2.1.1/GUID-DD65E7B5-204B-48D7-91F9-CBDCB0730B80
        $baseFileName=Get-Variable -Name "ISHServer:Oracle19" -ValueOnly
        $fileName="$baseFileName.zip"
        $filePath=Join-Path (Get-ISHServerFolderPath) $fileName
        $targetPath=Join-Path $env:TEMP "$baseFileName"
        $oracleHomePath="C:\Oracle\product\19.0.0\ODAC"
        if(Test-Path $targetPath)
        {
            Write-Warning "$fileName is already available in $targetPath"
        }
        else
        {
            Write-Debug "Creating $targetPath"
            New-Item $targetPath -ItemType Directory |Out-Null
            Write-Debug "Unzipping $filePath to $targetPath"
            [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')|Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($filePath, $targetPath)|Out-Null
            Write-Verbose "Unzipped $filePath"
        }

        # Install the ODAC components for the Oracle Provider for OLEDB
        $cmd32Path="$Env:SystemRoot\SysWOW64\cmd.exe"
        $setupPath=Join-Path $targetPath "install.bat"
        $arguments=@(
            "/c"
            "$setupPath"
            "oledb"
            "$oracleHomePath"
            "ODAC"
        )

        Write-Debug "Installing using $setupPath from $cmd32Path"
        Start-Process $cmd32Path -ArgumentList $arguments -WorkingDirectory $targetPath -Wait -Verb RunAs
        Write-Verbose "Installed using $setupPath from $cmd32Path"

        [Environment]::SetEnvironmentVariable("Path", "$oracleHomePath;$oracleHomePath\bin;" + $env:Path, "Machine")
        [Environment]::SetEnvironmentVariable("TNS_ADMIN", "$oracleHomePath\network\admin", "Machine")
    }
    end
    {

    }
}
