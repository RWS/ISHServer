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
    [Parameter(Mandatory=$false,ParameterSetName="Public")]
    [Parameter(Mandatory=$false,ParameterSetName="Public+Internal")]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$true,ParameterSetName="Public+Internal")]
    [ValidateScript({$_ -ne "PSGallery"})]
    [string]$DevRepository
)
Set-StrictMode -Version latest

$moduleNamesToPublish=@()
switch ($PSCmdlet.ParameterSetName)
{
    'Public' {
        $publishDebug=$false
        $repository="PSGallery"
        $moduleNamesToPublish+="ISHServer.12"
        $moduleNamesToPublish+="ISHServer.13"
        $moduleNamesToPublish+="ISHServer.14"
        break;
    }
    'Public+Internal' {
        $publishDebug=$true
        $repository=$DevRepository
        $moduleNamesToPublish+="ISHServer.12"
        $moduleNamesToPublish+="ISHServer.13"
        $moduleNamesToPublish+="ISHServer.14"
        $moduleNamesToPublish+="ISHServer.15"
        break
    }
}

$changeLogPath="$PSScriptRoot\..\CHANGELOG.md"
$changeLog=Get-Content -Path $changeLogPath

foreach($moduleName in $moduleNamesToPublish)
{
    try
    {
        if($publishDebug)
        {
            switch ($moduleName)
            {
                'ISHServer.12' {
                    $startYear="2014"
                    break
                }
                'ISHServer.13' {
                    $startYear="2015"
                    break
                }
                'ISHServer.14' {
                    $startYear="2017"
                    break
                }
                'ISHServer.15' {
                    $startYear="2020"
                    break
                }
            }

            $date=(Get-Date).ToUniversalTime()
            $build=[string](1200 * ($date.Year -$startYear)+$date.Month*100+$date.Day)
            $build+=$date.ToString("HHmm")
        }

        $progressActivity="Publish $moduleName"
        Write-Progress -Activity $progressActivity
        if(($Repository -eq "PSGallery") -and ($moduleName -eq "ISHServer.15"))
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
        Get-ChildItem -Path $modulePath -Filter "ISHServer.*.psm1"|Where-Object -Property Name -Ne "$($moduleName).psm1"|remove-Item -Force

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
            $sourceVersion+=".$build"
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
            "https://github.com/sdl/ISHServer/blob/master/CHANGELOG.md"
        )

        $hash=@{
            "Author"="SDL plc"
            "CompanyName" = "SDL plc"
            "Copyright"="SDL plc. All rights reserved."
            "RootModule"=$psm1Name
            "Description"=""
            "ModuleVersion"=$sourceVersion
            "Path"=$psd1Path
            "LicenseUri"='https://github.com/sdl/ISHServer/blob/master/LICENSE'
            "ProjectUri"= 'https://github.com/sdl/ISHServer/'
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
            'ISHServer.14' {
                $hash.Description="Prerequisite automation module for SDL Tridion Docs 14.0.* (SDL Knowledge Center Content Manager, LiveContent Architect, Trisoft InfoShare)"
                $hash.Guid="05077a18-b95e-458c-9adc-5ad7d95aed5d"
                break
            }
            'ISHServer.15' {
                $hash.Description="Prerequisite automation module for SDL Tridion Docs 15.0.* (SDL Knowledge Center Content Manager, LiveContent Architect, Trisoft InfoShare)"
                $hash.Guid="b07bbbf8-6fd9-42d4-993a-202fe917fb3b"
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
