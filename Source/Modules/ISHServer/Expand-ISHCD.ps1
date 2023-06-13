<#
# Copyright (c) 2023 All Rights Reserved by the RWS Group.
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

function Expand-ISHCD
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern(".+\.[0-9]+\.0\.[0-9]+\.[0-9]+.*\.exe")]
        [string]$FileName,
        [Parameter(Mandatory=$false)]
        [switch]$Force=$false
    )
    
    begin 
    {
        . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
        Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet

        . $PSScriptRoot\Get-ISHServerFolderPath.ps1
        . $PSScriptRoot\Get-ISHCD.ps1
    }

    process
    {
        $ishCDPath="C:\IshCD"

        $localPath=Get-ISHServerFolderPath
        $cdPath=Join-Path $localPath $FileName
        if(-not (Test-Path $cdPath))
        {
            Write-Error "$FileName doesn't exist."
            return
        }
        $regEx=".+\.(?<Major>[0-9]+)\.0\.(?<Build>[0-9]+)\.(?<Revision>[0-9]+).+\.exe"
        if($FileName -notmatch $regEx)
        {
            Write-Error "$FileName has unknown format."
            return
        }

        $major=[int]$Matches["Major"]
        $build=[int]$Matches["Build"]
        $revision=[int]$Matches["Revision"]
        
        $ishVersion="$($major).0.$($revision)"
        Write-Debug "ishVersion=$ishVersion"
        $expandPath="$ishCDPath\$ishVersion"
        Write-Debug "expandPath=$expandPath"

        if($major -lt 12)
        {
            Write-Error "Only CD's with major version 12 or higher are supported."
        }
        if(Get-ISHCD -ListAvailable |Where-Object -Property Name -EQ $FileName|Where-Object -Property IsExpanded -EQ $true)
        {
            if(-not $Force)
            {
                Write-Warning "$Filename is already expanded. Skipping ..."
                return
            }
        }

        if($major -eq "12") 
        {
            #CD is compressed with WinRar
            $arguments=@("-d$expandPath","-s")
        }
        else 
        {
            #CD is compressed with 7Zip
            $arguments=@(
                "-y" 
                "-gm2" 
                "-InstallPath=`"$($expandPath.Replace('\','\\'))`"" 
            )
        }
        Write-Debug "arguments=$($arguments -join " ")"

        Write-Debug "Unzipping $cdPath in $expandPath"
        Start-Process $cdPath -ArgumentList $arguments -Wait
        Write-Verbose "Unzipped $cdPath in $expandPath"

    }

    end
    {

    }
}
