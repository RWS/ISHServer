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

function Get-ISHPrerequisites
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [string]$FTPHost,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [string]$FTPFolder,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [string]$BucketName,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [string]$FolderKey,
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
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$ContainerName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$FolderPath,
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
        [switch]$Force=$false,
        [Parameter(Mandatory=$true,ParameterSetName="No Download")]
        [switch]$FileNames
    )
    
    begin 
    {
        if($PSCmdlet.ParameterSetName -ne "No Download")
        {
            . $PSScriptRoot\Private\Test-RunningAsElevated.ps1
            Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet
        }

        . $PSScriptRoot\Get-ISHServerFolderPath.ps1
        . $PSScriptRoot\Get-ISHOSInfo.ps1

        if(-not ($FTPFolder.EndsWith("/")))
        {
            $FTPFolder+="/"
        }
        if(-not ($FolderKey.EndsWith("/")))
        {
            $FolderKey+="/"
        }
        if(-not ($FolderPath.EndsWith("/")))
        {
            $FolderPath+="/"
        }
    }

    process
    {
        $filesToDownload=@(
            #Common for 12, 13 and 14
            Get-Variable -Name "ISHServer:JavaHelp" -ValueOnly
            Get-Variable -Name "ISHServer:HtmlHelp" -ValueOnly
            "$(Get-Variable -Name "ISHServer:AntennaHouse" -ValueOnly)"
            "$(Get-Variable -Name "ISHServer:AntennaHouse" -ValueOnly).iss"
            "$(Get-Variable -Name "ISHServer:AntennaHouse" -ValueOnly).vcredist_x64.exe"
            "$(Get-Variable -Name "ISHServer:AntennaHouse" -ValueOnly).vcredist_x86.exe"
            "$(Get-Variable -Name "ISHServer:Oracle" -ValueOnly).zip"
            "$(Get-Variable -Name "ISHServer:Oracle" -ValueOnly).rsp"

            Get-Variable -Name "ISHServer:MicrosoftVisualCPlusPlusRedistributable" -ValueOnly
        )

        #Only for 12 and 13
        if($PSCmdlet.MyInvocation.MyCommand.Module.Name -eq "ISHServer.12" -or $PSCmdlet.MyInvocation.MyCommand.Module.Name -eq "ISHServer.13")
        {
            $filesToDownload+=Get-Variable -Name "ISHServer:JDK" -ValueOnly
            $filesToDownload+=Get-Variable -Name "ISHServer:JRE" -ValueOnly
        }

        #Only for 12
        if($PSCmdlet.MyInvocation.MyCommand.Module.Name -eq "ISHServer.12")
        {
            $filesToDownload+=Get-Variable -Name "ISHServer:MSXML" -ValueOnly
        }
        
        #Only for 14
        if($PSCmdlet.MyInvocation.MyCommand.Module.Name -eq "ISHServer.14")
        {
            $filesToDownload+=Get-Variable -Name "ISHServer:AdoptOpenJDK" -ValueOnly
            $filesToDownload+=Get-Variable -Name "ISHServer:AdoptOpenJRE" -ValueOnly
            $filesToDownload+=Get-Variable -Name "ISHServer:MSOLEDBSQL" -ValueOnly
            $filesToDownload+="$(Get-Variable -Name "ISHServer:Oracle19" -ValueOnly).zip"
        }

        #Dependend on Operating System Information (OS Server vesion, already installed prerequisites)
        $osInfo=Get-ISHOSInfo

        #Only for 13 and 14
        if(($PSCmdlet.MyInvocation.MyCommand.Module.Name -eq "ISHServer.13") -or ($PSCmdlet.MyInvocation.MyCommand.Module.Name -eq "ISHServer.14"))
        {
            [Version]$NETFrameworkRequiredVersion=Get-Variable -Name "ISHServer:NETFrameworkRequiredVersion" -ValueOnly
            if($osInfo.FullNetFrameworkVersion -lt $NETFrameworkRequiredVersion)
            {
                $filesToDownload+=Get-Variable -Name "ISHServer:NETFramework" -ValueOnly
            }
        }

        if($osInfo.IsCore)
        {
            $filesToDownload+=Get-Variable -Name "ISHServer:VisualBasicRuntime" -ValueOnly
        }

        if($PSCmdlet.ParameterSetName -ne "No Download")
        {
            $localPath=Get-ISHServerFolderPath
        }

        switch ($PSCmdlet.ParameterSetName)
        {
            'From FTP' {
                . $PSScriptRoot\Private\Get-ISHFTPItem.ps1

                $paths=@()
                $filesToDownload | ForEach-Object {
                    $paths+="$FTPFolder$_"
                }
                Get-ISHFTPItem -FTPHost $FTPHost -Credential $Credential -Path $paths -LocalPath $localPath -Force:$Force | Out-Null
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
                $keys=@()
                $filesToDownload | ForEach-Object {
                    $keys+="$FolderKey$_"
                }
                Get-ISHS3Object -Key $keys @hash -Force:$Force | Out-Null
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
                $paths=@()
                $filesToDownload | ForEach-Object {
                    $paths+="$FolderPath$_"
                }
                Get-ISHAzureFileObject -Path $paths @hash -Force:$Force | Out-Null
                break        
            }
            'From Azure BlobStorage' {
                . $PSScriptRoot\Private\Get-ISHAzureBlobObject.ps1
        
                $localPath=Get-ISHServerFolderPath
                $hash=@{
                    ContainerName=$ContainerName
                    LocalFolder=$localPath
                    StorageAccountName=$StorageAccountName
                    StorageAccountKey=$StorageAccountKey
                }
                $blobs=@()
                $filesToDownload | ForEach-Object {
                    $blobs+="$FolderPath$_"
                }
                Get-ISHAzureBlobObject -BlobName $blobs @hash -Force:$Force | Out-Null
                break        
            }
            'No Download' {
                if($FileNames)
                {
                    $filesToDownload | Sort-Object
                }
                break
            }
        }
    }

    end
    {

    }
}
