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

function Set-ISHToolAntennaHouseLicense
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [string]$FTPHost,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true,ParameterSetName="From FTP")]
        [ValidatePattern(".*AHFormatter\.lic")]
        [string]$FTPPath,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [string]$BucketName,
        [Parameter(Mandatory=$true,ParameterSetName="From AWS S3")]
        [ValidatePattern(".*AHFormatter\.lic")]
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
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$ContainerName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [ValidatePattern(".*AHFormatter\.lic")]
        [string]$Path,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$StorageAccountName,
        [Parameter(Mandatory=$true,ParameterSetName="From Azure FileStorage")]
        [Parameter(Mandatory=$true,ParameterSetName="From Azure BlobStorage")]
        [string]$StorageAccountKey,
        [Parameter(Mandatory=$true,ParameterSetName="Content")]
        $Content
    )
    
    begin 
    {
		. $PSScriptRoot\Private\Test-RunningAsElevated.ps1
		Test-RunningAsElevated -StopCallerPSCmdlet $PSCmdlet

		. $PSScriptRoot\Get-ISHServerFolderPath.ps1
    }

    process
    {
        $antennaHouseLicenseFileName="AHFormatter.lic"
        $antennaHouseFolderPath=Join-Path $env:ProgramFiles "Antenna House\AHFormatterV62\"
        $antennaHouseLicensePath=Join-Path $antennaHouseFolderPath $antennaHouseLicenseFileName
        if(Test-Path $antennaHouseLicensePath)
        {
            $stamp=Get-Date -Format "yyyyMMdd"
            $newFileName="$stamp.ISHServer.$antennaHouseLicenseFileName.bak"
            $backupPath=Join-Path (Get-ISHServerFolderPath) $newFileName
            if(Test-Path (Join-Path $antennaHouseFolderPath $newFileName))
            {
                $stamp=Get-Date -Format "yyyyMMdd-hhmmss"
                $newFileName="$stamp.ISHServer.$antennaHouseLicenseFileName.bak"
                $backupPath=Join-Path (Get-ISHServerFolderPath) $newFileName
            }
            Copy-Item -Path $antennaHouseLicensePath -Destination $backupPath
            Write-Warning "License $antennaHouseLicensePath already exists. Backup available as $newFileName"
        }

        switch ($PSCmdlet.ParameterSetName)
        {
            'From FTP' {
                Get-ISHFTPItem -FTPHost $FTPHost -Credential $Credential -Path $FTPPath -LocalPath $antennaHouseFolderPath -Force | Out-Null
                break        
            }
            'From AWS S3' {
                . $PSScriptRoot\Private\Get-ISHS3Object.ps1        
                $hash=@{
                    BucketName=$BucketName
                    LocalFolder=$antennaHouseFolderPath
                    AccessKey=$AccessKey
                    ProfileName=$ProfileName
                    ProfileLocation=$ProfileLocation
                    Region=$Region
                    SecretKey=$SecretKey
                    SessionToken=$SessionToken
                }

                Get-ISHS3Object -Key $Key @hash -Force | Out-Null
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

                Get-ISHAzureFileObject -Path $Path @hash -Force | Out-Null
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

                Get-ISHAzureBlobObject -BlobName $Path @hash -Force | Out-Null
                break        
            }
            'Content' {
                Write-Debug "Writing License $antennaHouseLicensePath"
                if($PSVersionTable.PSVersion.Major -ge 5)
                {
                    Set-Content -Path $antennaHouseLicensePath -Value $Content -NoNewline -Force -Encoding Default
                }
                else
                {
                    [System.IO.File]::WriteAllText($antennaHouseLicensePath,$Content,[System.Text.Encoding]::Default)
                }
                Write-Verbose "License copied $antennaHouseLicensePath"
            }
        }
    }

    end
    {

    }
}
