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

function Get-ISHFTPItem
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FTPHost,
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true)]
        [string[]]$Path,
        [Parameter(Mandatory=$true)]
        [string]$LocalPath,
        [Parameter(Mandatory=$false)]
        [switch]$Force=$false
    )
    
    begin 
    {
        Import-Module PSFTP -ErrorAction Stop
        Set-FTPConnection -Server $FTPHost -Credentials $Credential -UseBinary -KeepAlive -UsePassive | Out-Null
    }

    process
    {
        $Path | ForEach-Object {
            Write-Debug "Path=$_"
            $localFile=Join-Path $LocalPath ($_.Substring($_.LastIndexOf('/')+1))
            Write-Debug "localFile=$localFile"
            if(-not (Test-Path $localFile) -or $Force)
            {
                Get-FTPItem -Path $_ -LocalPath $LocalPath -Overwrite
                Write-Verbose "Downloaded $_ to $LocalPath"
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
