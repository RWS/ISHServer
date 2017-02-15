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

function Get-ISHAzureBlobObject
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ContainerName,
        [Parameter(Mandatory=$true)]
        [string[]]$BlobName,
        [Parameter(Mandatory=$true)]
        [string]$LocalFolder,
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        [Parameter(Mandatory=$false)]
        [switch]$Force=$false
    )
    
    begin 
    {
        Import-Module Azure.Storage -ErrorAction Stop

        # Create a Context using StorageAccountName and StorageAccountKey
        $Context=New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    }

    process
    {
        $BlobName | ForEach-Object {
            $localFile=Join-Path $LocalFolder ($_.Substring($_.LastIndexOf('/')+1))
            Write-Debug "path=$_"
            Write-Debug "localFile=$localFile"
            if(-not (Test-Path $localFile) -or $Force)
            {
                Get-AzureStorageBlobContent -Container $ContainerName -Blob $_ -Destination $localFile -Force -Context $Context | Out-Null
                Write-Verbose "Downloaded $_ to $localFile"
            }
            else 
            {
                Write-Verbose "Skipped $_ already exists at $localFile"
            }
            Get-Item -Path $localFile
        }
    }

    end
    {

    }
}
