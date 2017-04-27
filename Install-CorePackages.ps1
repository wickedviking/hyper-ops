################################################################################
#
#   Install-HOCorePackages.ps1
#
################################################################################
#
# Installs the following:
#
# scoop - Windows Package Manager (Best for latest versions)
# chocolatey - Windows Package Manager (More control, wider support)
# Hyper-V
# Git w/ Unix Tools on Command Line
# Packer - VM Image builder
# Vagrant - VM Manager
# FCIV - Checksum calculator/verifier
# Docker-For-Windows
#
################################################################################

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

################################################################################
#
# Install-HOPackageFromRemoteScript
#
# Installs packages that have remote powershell script installers.
#
# -AppPath[string]
#       Path where the program executable is typically installed
# -AppName[string]
#       Name of the program, doesn't have to match anything
# -InstallUrl[string]
#       Url of the the remost install script.
# -UpdateCommand[string]
#       Command to update the program
# -TestPaths[string]
#       Paths to test for existing installations (typically a path to standard
#       executable locations)
#
################################################################################
function Install-HOPackageFromRemoteScript {
    [CmdletBinding()]
    Param(
        [String]$AppName,
        [string]$AppPath,
        [String]$InstallUrl,
        [String]$UpdateCommand,
        [String[]]$TestPaths
    )
    Process {
        $OriginalErrorActionPreference = $ErrorActionPreference

        $pathFound = $false

        foreach ($path in $TestPaths) {
            if( (Test-Path -Path "$AppPath$path") ) { $pathFound =$true }
        }

        if($pathFound) {
            Write-Host "$AppName installation detected, updating to latest version"
            iex "& $UpdateCommand"
            $ErrorActionPreference = $OriginalErrorActionPreference
            if($LASTEXITCODE) {
                Write-Error "Update for $AppName was unable to execute comman via iex";
                Exit $LASTEXITCODE
            }
        } else {
            Write-Host "Installing $AppName..."
            iex (New-Object Net.WebClient).DownloadString($InstallUrl)
            $ErrorActionPreference = $OriginalErrorActionPreference
            if($LASTEXITCODE) {
                Write-Error "Install for $AppName was unable to execute comman via iex";
                Exit $LASTEXITCODE
            }
        }
    }
}

################################################################################
#
# Install-HOPackageFromHOPackageFromChocolatey
#
# Installs packages from chocolatey
#
# -AppPath[string]
#       Path where the program executable is typically installed by choco
# -AppName[string]
#       Name of the program
# -TestPaths[string]
#       Paths to test for existing installations (typically a path to standard
#       executable locations)
#
################################################################################
function Install-HOPackageFromChocolatey {
    [CmdletBinding()]
    Param(
        [String]$AppName,
        [string[]]$AppPaths = $AppPaths.split(" "),
        [string]$InstallParams,
        [String[]]$TestPaths
    )
    Process {
        $OriginalErrorActionPreference = $ErrorActionPreference

        $pathFound = $false

        Write-Host "AppName: $AppName"
        Write-Host "AppPaths: $AppPaths"
        Write-Host "InstallParams: $InstallParams"
        Write-Host "TestPaths: $TestPaths"


        while (-Not $pathFound) {
            foreach ($path in $TestPaths) {
                foreach( $appPath in $AppPaths) {
                    Write-Host "$appPath$path"
                    if( (Test-Path -Path "$AppPath$path") ) { $pathFound =$true }
                }
            }
        }
        if($pathFound) {
            Write-Host "$AppName installation detected, updating to latest version"
            iex "& choco upgrade -y $AppName"
            $ErrorActionPreference = $OriginalErrorActionPreference
            if($LASTEXITCODE) {
                Write-Error "Update for $AppName was unable to execute comman via iex";
                Exit $LASTEXITCODE
            }
        } else {
            Write-Host "Installing $AppName..."
            $expression = "& choco install -y $AppName "
            if ($InstallParams) {
                $expression = $expression +" -params '$InstallParams'"
            }
            iex $expression
            $ErrorActionPreference = $OriginalErrorActionPreference
            if($LASTEXITCODE) {
                Write-Error "Install for $AppName was unable to execute comman via iex";
                Exit $LASTEXITCODE
            }
        }
    }
}

#Scoop
Install-HOPackageFromChocolatey -AppName "docker-for-windows" `
    -AppPath ($env:path.split(";") | % { if($_.ToLower().Contains("docker")){return $_} }) `
    -InstallParams "/GitAndUnixToolsOnPath" `
    -TestPaths @("\bin\docker.exe","\docker.exe")
Exit
################################################################################
# Begin Main Script
################################################################################

#Scoop
Install-HOPackageFromRemoteScript -AppName "Scoop" `
    -AppPath ($env:SCOOP,"$env:USERPROFILE\scoop" | select -First 1) `
    -InstallUrl "https://get.scoop.sh" `
    -UpdateCommand "scoop update" `
    -TestPaths @("\shims\scoop.ps1","\shims\scoop.cmd")

#Chocolatey
Install-HOPackageFromRemoteScript -AppName "Chocolatey" `
    -AppPath ($env:ChocolateyInstall,"$env:ALLUSERSPROFILE\chocolatey" | select -First 1) `
    -InstallUrl "https://chocolatey.org/install.ps1" `
    -UpdateCommand "choco upgrade chocolatey" `
    -TestPaths @("\bin\choco.exe","\chocolatey\bin\choco.exe")

Write-Host "Refeshing path..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" `
+ [System.Environment]::GetEnvironmentVariable("Path","User")

#Hyper-V
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.state -eq "Enabled") {
    Write-Host "Hyper-V was already enabled..."
} else {
    Write-Host "Enabling Hyper-V..."
    Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online -NoRestart
}

#Git w/ Unix Tool on Command Line
choco install -y git -params "/GitAndUnixToolsOnPath"
scoop install packer vagrant
choco install -y fciv
choco install -y docker-for-windows

#Restart Computer to Finalize Hyper-V
#Restart-Computer