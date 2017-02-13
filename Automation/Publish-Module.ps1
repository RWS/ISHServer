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

param(
    [Parameter(Mandatory=$false,ParameterSetName="KC2016")]
    [Parameter(Mandatory=$false,ParameterSetName="KC2016+Dev")]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$true,ParameterSetName="KC2016+Dev")]
    [ValidateScript({$_ -ne "PSGallery"})]
    [string]$DevRepository #,
    <#
    [Parameter(Mandatory=$true,ParameterSetName="KC2016")]
    [Parameter(Mandatory=$false,ParameterSetName="KC2016+Dev")]
    [switch]$ISH12=$false,
    [Parameter(Mandatory=$false,ParameterSetName="KC2016+Dev")]
    [switch]$ISH13=$false
    #>
)
Set-StrictMode -Version latest

$moduleNamesToPublish=@()
switch ($PSCmdlet.ParameterSetName)
{
    'KC2016' {
        $publishDebug=$false
        $repository="PSGallery"
        $moduleNamesToPublish+="ISHServer.12"
        break;
    }
    'KC2016+Dev' {
        $publishDebug=$true
        $repository=$DevRepository
        $moduleNamesToPublish+="ISHServer.12"
        $moduleNamesToPublish+="ISHServer.13"
        break        
    }
}

if((& "$PSScriptRoot\Test-All.ps1") -ne 0)
{
    Write-Warning "Tests failed. Stopping..."
    return
}
$changeLogPath="$PSScriptRoot\..\CHANGELOG.md"
$changeLog=Get-Content -Path $changeLogPath
if($publishDebug)
{
    $revision=0
    $date=(Get-Date).ToUniversalTime()
    $build=[string](1200 * ($date.Year -2015)+$date.Month*100+$date.Day)
    $build+=$date.ToString("HHmm")
}



foreach($moduleName in $moduleNamesToPublish)
{
    try
    {
        $progressActivity="Publish $moduleName"
        Write-Progress -Activity $progressActivity
        if(($Repository -eq "PSGallery") -and ($moduleName -eq "ISHServer.13"))
        {
            throw "Not allowed to publish $moduleName to $repository"
        }
        $tempWorkFolderPath=Join-Path $env:TEMP "$moduleName-Publish"
        if(Test-Path $tempWorkFolderPath)
        {
            Remove-Item -Path $tempWorkFolderPath -Recurse -Force
        }
        New-Item -Path $tempWorkFolderPath -ItemType Directory|Out-Null
        Write-Verbose "Temporary working folder $tempWorkFolderPath is ready"

        $modulePath=Join-Path $tempWorkFolderPath $moduleName
        New-Item -Path $modulePath -ItemType Directory|Out-Null
        Write-Verbose "Temporary working folder $modulePath is ready"

        Copy-Item -Path "$PSScriptRoot\..\Source\Modules\ISHServer\*" -Destination $modulePath -Recurse
        switch ($moduleName)
        {
            'ISHServer.12' {
                Remove-Item -Path "$modulePath\ISHServer.13.psm1" -Force
            }
            'ISHServer.13' {
                Remove-Item -Path "$modulePath\ISHServer.12.psm1" -Force
            }
        }
        $psm1Path=Join-Path $modulePath "$moduleName.psm1"
        $metadataPath=Join-Path $modulePath "metadata.ps1"
        $metadataContent=Get-Content -Path $metadataPath -Raw
        $versionRegEx="\.VERSION (?<Major>([0-9]+))\.(?<Minor>([0-9]+))"
        if($metadataContent -notmatch $versionRegEx)
        {
            Write-Error "$metadataPath doesn't contain script info .VERSION"
            return -1
        }
        $sourceMajor=[int]$Matches["Major"]
        $sourceMinor=[int]$Matches["Minor"]
        $sourceVersion="$sourceMajor.$sourceMinor"
        if($publishDebug)
        {
            $sourceVersion+=".$build.$revision"    
            Write-Verbose "Increased $moduleName version with build number $sourceVersion"
        }
        Write-Debug "sourceMajor=$sourceMajor"
        Write-Debug "sourceMinor=$sourceMinor"
        Write-Debug "sourceVersion=$sourceVersion"

        #region query
        if(-not $publishDebug)
        {
            Write-Debug "Querying $moduleName in Repository $repository"
            Write-Progress -Activity $progressActivity -Status "Querying..."
            $repositoryModule=Find-Module -Name $moduleName -Repository $repository -ErrorAction SilentlyContinue
            Write-Verbose "Queried $moduleName in Repository $repository"
            $shouldTryPublish=$false

            if((-not $publishDebug) -and $repositoryModule)
            {
                $publishedVersion=$repositoryModule.Version
                $publishedMajor=$publishedVersion.Major
                $publishedMinor=$publishedVersion.Minor

                Write-Verbose "Found existing published module with version $publishedVersion"

                if(($sourceMajor -ne $publishedMajor) -or ($sourceMinor -ne $publishedMinor))
                {
                    Write-Verbose "Source version $sourceMajor.$sourceMinor is different that published version $publishedVersion"
                    $shouldTryPublish=$true
                }
                else
                {
                    Write-Warning "Source version $sourceMajor.$sourceMinor is the same as with the already published. Will skip publishing"
                }
            }
            else
            {
                Write-Verbose "Module is not yet published to the $repository repository"
                $shouldTryPublish=$true
            }
        }
        else
        {
            $shouldTryPublish=$true
        }
        #endregion

        #region manifest
        Write-Debug "Generating manifest"
    
        Import-Module $psm1Path -Force 
        $exportedNames=Get-Command -Module $moduleName | Select-Object -ExcludeProperty Name
        $psm1Name=$moduleName+".psm1"
        $psd1Path=Join-Path $modulePath "$moduleName.psd1"
        $guid="c1e7cbac-9e47-4906-8281-5f16471d7ccd"
        
        $possition = "None"
        $releaseNotes=foreach ($line in $changeLog) {
            if ($line.StartsWith("**")){
                if($possition -eq "None"){
                    $possition="This Version"
                }
                else
                {
                    $possition="Next Version"
                }
                continue
            }
            If($possition -eq "This Version"){
                if($line)
                {
                    $line
                }
            }
        }
        $releaseNotes+=@(
            ""
            "https://github.com/Sarafian/ISHServer/blob/master/CHANGELOG.md"
        )

        $hash=@{
            "Author"="SDL plc"
            "CompanyName" = "SDL plc"
            "Copyright"="SDL plc. All rights reserved."
            "RootModule"=$psm1Name
            "Description"="Prerequisite automation module for SDL Knowledge Center Content Manager 12.0.* (LiveContent Architect, Trisoft InfoShare)"
            "ModuleVersion"=$sourceVersion
            "Path"=$psd1Path
            "LicenseUri"='https://github.com/Sarafian/ISHServer/blob/master/LICENSE'
            "ProjectUri"= 'https://github.com/Sarafian/ISHServer/'
            "ReleaseNotes"= $releaseNotes -join [System.Environment]::NewLine
            "CmdletsToExport" = $exportedNames
            "FunctionsToExport" = $exportedNames
        }
        switch ($moduleName)
        {
            'ISHServer.12' {
                $hash.Description="Prerequisite automation module for SDL Knowledge Center 2016 Content Manager 12.0.* (LiveContent Architect, Trisoft InfoShare)"
                $hash.Guid="469894fc-530e-47dd-9158-ed5148815712"
                break
            }
            'ISHServer.13' {
                $hash.Description="Prerequisite automation module for SDL Knowledge Center Content Manager 13.0.* (LiveContent Architect, Trisoft InfoShare)"
                $hash.Guid="c73125ea-0914-4a1c-958b-05eccd6c2c29"
                break
            }
        }

        New-ModuleManifest  @hash 

        Write-Verbose "Generated manifest"
        #endregion

        if($shouldTryPublish)
        {
            #region publish
            Write-Debug "Publishing $moduleName"
            Write-Progress -Activity $progressActivity -Status "Publishing..."
            if($NuGetApiKey)
            {
                Publish-Module -Repository $repository -Path $modulePath -NuGetApiKey $NuGetApiKey -Confirm:$false
            }
            else
            {
                Publish-Module -Repository $repository -Path $modulePath -NuGetApiKey "MockKey" -WhatIf -Confirm:$false
            }
            Write-Verbose "Published $moduleName"
            #endregion
        }
    }
    finally
    {
        Write-Progress -Activity $progressActivity -Completed
    }
}
