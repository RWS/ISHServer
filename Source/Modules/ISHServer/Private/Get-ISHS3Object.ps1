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

function Get-ISHS3Object
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$BucketName,
        [Parameter(Mandatory=$true)]
        [string[]]$Key,
        [Parameter(Mandatory=$true)]
        [string]$LocalFolder,
        [Parameter(Mandatory=$false)]
        [string]$AccessKey,
        [Parameter(Mandatory=$false)]
        [string]$ProfileName,
        [Parameter(Mandatory=$false)]
        [string]$ProfileLocation,
        [Parameter(Mandatory=$false)]
        [string]$Region,
        [Parameter(Mandatory=$false)]
        [string]$SecretKey,
        [Parameter(Mandatory=$false)]
        [string]$SessionToken,
        [Parameter(Mandatory=$false)]
        [switch]$Force=$false
    )
    
    begin 
    {
        Import-Module AWSPowerShell -ErrorAction Stop
        $hash=@{
            BucketName=$BucketName
        }
        # Filling in the base splat hash to be used with Copy-S3Object
        if($AccessKey){
            $hash.AccessKey=$AccessKey
        }
        if($ProfileName){
            $hash.ProfileName=$ProfileName
        }
        if($ProfileLocation){
            $hash.ProfileLocation=$ProfileLocation
        }
        if($Region){
            $hash.Region=$Region
        }
        if($SecretKey){
            $hash.SecretKey=$SecretKey
        }
        if($SessionToken){
            $hash.SessionToken=$SessionToken
        }
    }

    process
    {
        $Key | ForEach-Object {
            Write-Debug "key=$_"
            $localFile=Join-Path $LocalFolder ($_.Substring($_.LastIndexOf('/')+1))
            Write-Debug "localFile=$localFile"
            if(-not (Test-Path $localFile) -or $Force)
            {
                Copy-S3Object -Key $_ -LocalFile $localFile @hash
                Write-Verbose "Downloaded $_ to $localFile"
            }
            else
            {
                Write-Warning "Skipped $_ already exists at $localFile"
                Get-Item -Path $localFile
            }
        }
    }

    end
    {

    }
}
