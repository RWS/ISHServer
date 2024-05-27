<#
# Copyright (c) 2024 All Rights Reserved by the RWS Group.
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

function Get-ISHAzureFileObject
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ShareName,
        [Parameter(Mandatory=$true)]
        [string[]]$Path,
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
        $Path | ForEach-Object {
            $localFile=Join-Path $LocalFolder ($_.Substring($_.LastIndexOf('/')+1))
            Write-Debug "path=$_"
            Write-Debug "localFile=$localFile"
            if(-not (Test-Path $localFile) -or $Force)
            {
                Get-AzureStorageFileContent -ShareName $ShareName -Path $_ -Destination $localFile -Force -Context $Context | Out-Null
                Write-Verbose "Downloaded $_ to $localFile"
            }
            else 
            {
                Write-Warning "Skipped $_ already exists at $localFile"
            }
            Get-Item -Path $localFile
        }
    }

    end
    {

    }
}
