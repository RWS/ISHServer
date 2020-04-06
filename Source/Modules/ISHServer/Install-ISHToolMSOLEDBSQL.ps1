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

function Install-ISHToolMSOLEDBSQL {
    [CmdletBinding()]
    Param()
    
    begin {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet

        . $PSScriptRoot\Get-ISHServerFolderPath.ps1
    }

    process {
        [Version]$MSOLEDBSQLRequiredVersion = Get-Variable -Name "ISHServer:MSOLEDBSQLRequiredVersion" -ValueOnly
        
        [Version]$MSOLEDBSQLInstalledVersion = "0.0.0"
        $MSOLEDBSQLInstalled = (New-Object system.data.oledb.oledbenumerator).GetElements() | Where-Object { ($_.SOURCES_NAME -like '*MSOLEDBSQL*') -and ($_.SOURCES_NAME -notlike "*Enumerator") }
        if ($MSOLEDBSQLInstalled) {
            # Get installed version of MSOLEDBSQL
            $MSOLEDBSQLRegistryPath = "HKLM:\Software\Microsoft\Microsoft OLE DB Driver for SQL Server"
            if (Test-Path $MSOLEDBSQLRegistryPath) {
                [Version]$MSOLEDBSQLInstalledVersion = (Get-ItemProperty "$MSOLEDBSQLRegistryPath\*").Version
            }
        }
        
        if ($MSOLEDBSQLInstalledVersion -ge $MSOLEDBSQLRequiredVersion) {
            Write-Verbose "The installed version of MSOLEDBSQL ($($MSOLEDBSQLInstalledVersion)) is higher than or equal to the minimal required version ($($MSOLEDBSQLRequiredVersion))."
        }
        else {
            $fileName = Get-Variable -Name "ISHServer:MSOLEDBSQL" -ValueOnly
            $filePath = Join-Path (Get-ISHServerFolderPath) $fileName
            $logFile = Join-Path $env:TEMP "$FileName.log"
            $arguments = @(
                "/package"
                $filePath
                "/qn"
                "/norestart"
                "/lv"
                "$logFile"
                "IACCEPTMSOLEDBSQLLICENSETERMS=YES"
            )

            Write-Debug "Installing $filePath"
            Start-Process "msiexec" -ArgumentList $arguments -Wait -Verb RunAs
            Write-Verbose "Installed $fileName"
            Write-Warning "You must restart the server before you proceed."
        }
    }
    end {

    }
}
