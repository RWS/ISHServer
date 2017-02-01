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

function Get-ISHCD
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [string]$FTPHost,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [ValidatePattern(".+\.[0-9]+\.0\.[0-9]+\.[0-9]+.*\.exe")]
        [string]$FTPPath,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [string]$BucketName,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [ValidatePattern(".+\.[0-9]+\.0\.[0-9]+\.[0-9]+.*\.exe")]
        [string]$Key,
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [string]$AccessKey,
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [string]$ProfileName,
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [string]$ProfileLocation,
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [string]$Region,
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [string]$SecretKey,
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [string]$SessionToken,
        [Parameter(Mandatory=$false,ParameterSetName="From FTP")]
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [switch]$Expand=$false,
        [Parameter(Mandatory=$true,ParameterSetName="No Download")]
        [switch]$ListAvailable
    )
    
    begin 
    {
        if($PSCmdlet.ParameterSetName -ne "No Download")
        {
            . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
            Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet
        }

        . $PSScriptRoot\Get-ISHServerFolderPath.ps1
    }

    process
    {
        $localPath=Get-ISHServerFolderPath
        switch ($PSCmdlet.ParameterSetName)
        {
            'From FTP' {
                . $PSScriptRoot\Private\Get-ISHFTPItem.ps1

                $newItem=Get-ISHFTPItem -FTPHost $FTPHost -Credential $Credential -Path $FTPPath -LocalPath $localPath
                if($Expand)
                {
                    . $PSScriptRoot\Expand-ISHCD.ps1
                    Expand-ISHCD -FileName $newItem.Name
                }
                break        
            }
            'From AWS S3' {
                . $PSScriptRoot\Private\Get-ISHS3Object.ps1
                $hash=@{
                    BucketName=$BucketName
                    LocalFolder=$localPath
                    AccessKey=$AccessKey
                    ProfileName=$ProfileName
                    ProfileLocation=$ProfileLocation
                    Region=$Region
                    SecretKey=$SecretKey
                    SessionToken=$SessionToken
                }

                $newItem=Get-ISHS3Object -Key $Key @hash
                if($Expand)
                {
                    . $PSScriptRoot\Expand-ISHCD.ps1
                    Expand-ISHCD -FileName $newItem.Name
                }
                break        
            }
            'No Download' {
                $regEx=".+\.(?<Major>[0-9]+)\.0\.(?<Build>[0-9]+)\.(?<Revision>[0-9]+)(\.Test)*.+\.exe"
                $availableItems=@()
                $ishCDPath="C:\IshCD"
                Get-ChildItem -Path $localPath -File |Where-Object -Property Name -Match $regEx|ForEach-Object {
                    $hash=[ordered]@{
                        Name=$_.Name
                        Major=[int]$Matches["Major"]
                        Minor=0
                        Build=[int]$Matches["Build"]
                        Revision=[int]$Matches["Revision"]
                        IsExpanded=$false
                    }

                    $ishVersion="$($hash.Major).0.$($hash.Revision)"
                    Write-Debug "ishVersion=$ishVersion"
                    $expandPath="$ishCDPath\$ishVersion"
                    Write-Debug "expandPath=$expandPath"
                    $testPath=Join-Path -Path $expandPath -ChildPath ($_.Name.Replace(".exe",""))
                    $hash.IsExpanded=(Test-Path $testPath -PathType Container) -or (Test-Path $testPath.Replace(".Test","") -PathType Container)

                    $availableItems+=New-Object -TypeName PSObject -Property $hash
                }
                if($PSVersionTable.PSVersion.Major -ge 5)
                {
                    $childItems=Get-ChildItem -Path $ishCDPath -Recurse -Directory -Depth 1
                }
                else
                {
                    $childItems=Get-ChildItem -Path $ishCDPath -Recurse -Directory
                }
                $childItems |Where-Object -Property Name -Match ($regEx.Replace("\.exe","")) | ForEach-Object {
                    $directoryName=$_.Name
                    if($availableItems |Where-Object {
                        ($_.Name.Replace(".exe","") -eq $directoryName) -or ($_.Name.Replace(".exe","").Replace(".Test","") -eq $directoryName)
                    })
                    {
                        return
                    }
                    $hash=[ordered]@{
                        Name=$_.Name
                        Major=[int]$Matches["Major"]
                        Minor=0
                        Build=[int]$Matches["Build"]
                        Revision=[int]$Matches["Revision"]
                        IsExpanded=$true
                    }
                    $availableItems+=New-Object -TypeName PSObject -Property $hash
                }
                $availableItems
                break
            }
        }
    }

    end
    {

    }
}
