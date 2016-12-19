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
    [Parameter(Mandatory=$true,ParameterSetName="Release")]
    [Parameter(Mandatory=$true,ParameterSetName="Debug")]
    [ValidateSet("ISHServer.12","ISHServer.13")]
    [string]$ModuleName,
    [Parameter(Mandatory=$false,ParameterSetName="Release")]
    [Parameter(Mandatory=$false,ParameterSetName="Debug")]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$true,ParameterSetName="Debug")]
    [ValidateScript({$_ -ne "PSGallery"})]
    [string]$Repository
)


if((& "$PSScriptRoot\Test-All.ps1") -ne 0)
{
    Write-Warning "Tests failed. Stopping..."
    return
}


switch ($PSCmdlet.ParameterSetName)
{
    'Debug' {
        $publishDebug=$true
        break        
    }
    'Release' {
        $publishDebug=$false
        $Repository="PSGallery"
    }
}

$progressActivity="Publish $moduleName"

try
{
    if(($Repository -eq "PSGallery") -and ($ModuleName -eq "ISHServer.13"))
    {
        throw "Not allowed to publish $ModuleName to $Repository"
    }
    $tempWorkFolderPath=Join-Path $env:TEMP "$ModuleName-Publish"
    if(Test-Path $tempWorkFolderPath)
    {
        Remove-Item -Path $tempWorkFolderPath -Recurse -Force
    }
    New-Item -Path $tempWorkFolderPath -ItemType Directory|Out-Null
    Write-Verbose "Temporary working folder $tempWorkFolderPath is ready"

    $modulePath=Join-Path $tempWorkFolderPath $ModuleName
    New-Item -Path $modulePath -ItemType Directory|Out-Null
    Write-Verbose "Temporary working folder $modulePath is ready"

    Copy-Item -Path "$PSScriptRoot\..\Source\Modules\ISHServer\*.*" -Destination $modulePath -Recurse
    switch ($ModuleName)
    {
        'ISHServer.12' {
            Remove-Item -Path "$modulePath\ISHServer.13.psm1" -Force
        }
        'ISHServer.13' {
            Remove-Item -Path "$modulePath\ISHServer.12.psm1" -Force
        }
    }
    $psm1Path=Join-Path $modulePath "$ModuleName.psm1"

    $sourcePsm1Content=Get-Content -Path $psm1Path -Raw
    $versionRegEx="\.VERSION (?<Major>([0-9]+))\.(?<Minor>([0-9]+))"
    if($sourcePsm1Content -notmatch $versionRegEx)
    {
        Write-Error "$psm1Path doesn't contain script info .VERSION"
        return -1
    }
    $sourceMajor=[int]$Matches["Major"]
    $sourceMinor=[int]$Matches["Minor"]
    $sourceVersion="$sourceMajor.$sourceMinor"
    if($publishDebug)
    {
        $revision=0
        $date=(Get-Date).ToUniversalTime()
        $build=[string](1200 * ($date.Year -2015)+$date.Month*100+$date.Day)
        $build+=$date.ToString("HHmm")
        $sourceVersion+=".$build.$revision"    
        Write-Warning "Increased module version with build number $sourceVersion"
    }
    Write-Debug "sourceMajor=$sourceMajor"
    Write-Debug "sourceMinor=$sourceMinor"
    Write-Debug "sourceVersion=$sourceVersion"

    #region query
    if(-not $publishDebug)
    {
        Write-Debug "Querying $ModuleName in Repository $Repository"
        Write-Progress -Activity $progressActivity -Status "Querying..."
        $repositoryModule=Find-Module -Name $ModuleName -Repository $Repository -ErrorAction SilentlyContinue
        Write-Verbose "Queried $ModuleName in Repository $Repository"
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
            Write-Verbose "Module is not yet published to the $Repository repository"
            $shouldTryPublish=$true
        }
    }
    else
    {
        $shouldTryPublish=$true
    }
    #endregion

    if($shouldTryPublish)
    {
        #region manifest
        Write-Debug "Generating manifest"
    
        Import-Module $psm1Path -Force 
        $exportedNames=Get-Command -Module $ModuleName | Select-Object -ExcludeProperty Name

        $psm1Name=$ModuleName+".psm1"
        $psd1Path=Join-Path $modulePath "$ModuleName.psd1"
        $guid="c1e7cbac-9e47-4906-8281-5f16471d7ccd"
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
            "ReleaseNotes"= 'https://github.com/Sarafian/ISHServer/blob/master/CHANGELOG.md'
            "CmdletsToExport" = $exportedNames
            "FunctionsToExport" = $exportedNames
        }
        switch ($ModuleName)
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
