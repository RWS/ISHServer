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

function Get-ISHCD
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [string]$FTPHost,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [ValidatePattern(".+\.[0-9]+\.[0-9]\.[0-9]+\.[0-9]+.*\.exe")]
        [string]$FTPPath,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [string]$BucketName,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [ValidatePattern(".+\.[0-9]+\.[0-9]\.[0-9]+\.[0-9]+.*\.exe")]
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
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [string]$ShareName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [ValidatePattern(".+\.[0-9]+\.[0-9]\.[0-9]+\.[0-9]+.*\.exe")]
        [string]$Path,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$ContainerName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [ValidatePattern(".+\.[0-9]+\.[0-9]\.[0-9]+\.[0-9]+.*\.exe")]
        [string]$BlobName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$StorageAccountName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$StorageAccountKey,
        [Parameter(Mandatory=$false,ParameterSetName="From FTP")]
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [Parameter(Mandatory=$false,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$false,ParameterSetName="From Azure BlobStorage")]
        [switch]$Expand=$false,
        [Parameter(Mandatory=$false,ParameterSetName="From FTP")]
        [Parameter(Mandatory=$false,ParameterSetName="From AWS S3")]
        [Parameter(Mandatory=$false,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$false,ParameterSetName="From Azure BlobStorage")]
        [switch]$Force=$false,
        [Parameter(Mandatory=$true,ParameterSetName="List")]
        [switch]$ListAvailable
    )
    
    begin 
    {
        if($PSCmdlet.ParameterSetName -ne "List")
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

                $newItem=Get-ISHFTPItem -FTPHost $FTPHost -Credential $Credential -Path $FTPPath -LocalPath $localPath -Force:$Force
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

                $newItem=Get-ISHS3Object -Key $Key @hash -Force:$Force
                if($Expand)
                {
                    . $PSScriptRoot\Expand-ISHCD.ps1
                    Expand-ISHCD -FileName $newItem.Name
                }
                break        
            }
            'From Azure FileStorage' {
                . $PSScriptRoot\Private\Get-ISHAzureFileObject.ps1
                $hash=@{
                    ShareName=$ShareName
                    LocalFolder=$localPath
                    StorageAccountName=$StorageAccountName
                    StorageAccountKey=$StorageAccountKey
                }

                $newItem=Get-ISHAzureFileObject -Path $Path @hash -Force:$Force
                if($Expand)
                {
                    . $PSScriptRoot\Expand-ISHCD.ps1
                    Expand-ISHCD -FileName $newItem.Name
                }
                break
            }
            'From Azure BlobStorage' {
                . $PSScriptRoot\Private\Get-ISHAzureBlobObject.ps1
                $hash=@{
                    ContainerName=$ContainerName
                    LocalFolder=$localPath
                    StorageAccountName=$StorageAccountName
                    StorageAccountKey=$StorageAccountKey
                }

                $newItem=Get-ISHAzureBlobObject -BlobName $BlobName @hash -Force:$Force
                if($Expand)
                {
                    . $PSScriptRoot\Expand-ISHCD.ps1
                    Expand-ISHCD -FileName $newItem.Name
                }
                break        
            }
            'List' {
                function RemoveSDLSegments([string]$path)
                {
                    return $path.Replace(".Test","").Replace(".Prod","")
                }
                $regEx=".+\.(?<Major>[0-9]+)\.(?<Minor>[0-9]+)\.(?<Build>[0-9]+)\.(?<Revision>[0-9]+)(\.Test)*(\.Prod)*.+\.exe"
                $availableItems=@()
                $ishCDPath="C:\IshCD"
                Get-ChildItem -Path $localPath -File |Where-Object -Property Name -Match $regEx|ForEach-Object {
                    $hash=[ordered]@{
                        Name=$_.Name
                        Major=[int]$Matches["Major"]
                        Minor=[int]$Matches["Minor"]
                        Build=[int]$Matches["Build"]
                        Revision=[int]$Matches["Revision"]
                        IsExpanded=$false
                        ExpandedPath=$null
                    }

                    $ishVersion="$($hash.Major).$($hash.Minor).$($hash.Revision)"
                    Write-Debug "ishVersion=$ishVersion"
                    $expandPath="$ishCDPath\$ishVersion"
                    Write-Debug "expandPath=$expandPath"
                    $testPath=Join-Path -Path $expandPath -ChildPath ($_.Name.Replace(".exe",""))
                    $testPath=RemoveSDLSegments($testPath)
                    $hash.IsExpanded=Test-Path $testPath -PathType Container
                    if($hash.IsExpanded)
                    {
                        $hash.ExpandedPath=$testPath
                    }
                    $availableItems+=New-Object -TypeName PSObject -Property $hash
                }
                if(Test-Path -Path $ishCDPath -PathType Container)
                {
                    if($PSVersionTable.PSVersion.Major -ge 5)
                    {
                        $childItems=Get-ChildItem -Path $ishCDPath -Recurse -Directory -Depth 1
                    }
                    else
                    {
                        $childItems=Get-ChildItem -Path $ishCDPath -Recurse -Directory
                    }
                }
                else
                {
                    $childItems=$null
                }
                $childItems |Where-Object -Property Name -Match ($regEx.Replace("\.exe","")) | ForEach-Object {
                    $directoryName=$_.Name
                    if($availableItems |Where-Object {
                        ((RemoveSDLSegments($_.Name).Replace(".exe","")) -eq $directoryName)
                    })
                    {
                        return
                    }
                    $hash=[ordered]@{
                        Name=$_.Name
                        Major=[int]$Matches["Major"]
                        Minor=[int]$Matches["Minor"]
                        Build=[int]$Matches["Build"]
                        Revision=[int]$Matches["Revision"]
                        IsExpanded=$true
                        ExpandedPath=$_.FullName
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
