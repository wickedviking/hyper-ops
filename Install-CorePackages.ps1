################################################################################
#
#   Install-HOCorePackages.ps1
#
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
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

################################################################################
#
# Update-Path
#
################################################################################
Function Update-Path {
    Process {
        Write-Host "Refeshing path..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") `
            + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

################################################################################
#
# Install-HOPackageFromRemoteScript
#
# Installs packages that have remote powershell script installers.
#
# -AppName[string]
#       Name of the program, doesn't have to match anything
# -ExecutableName[string]
#       The actual filename of the program, ex. choco.exe
# -InstallUrl[string]
#       Url of the the remost install script.
# -UpdateCommand[string]
#       Command to update the program
#
################################################################################
function Install-HOPackageFromRemoteScript {
    [CmdletBinding()]
    Param(
        [String]$AppName,
        [string]$ExecutableName,
        [String]$InstallUrl,
        [String]$UpdateCommand
    )
    Process {
        $OriginalErrorActionPreference = $ErrorActionPreference
        $executablePath = (Get-Command -Name $executableName -ErrorAction SilentlyContinue).Path

        if( $executablePath ) {
            Write-Host "$AppName installation at $executablePath, updating to latest version"
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
        Update-Path
    }
}

################################################################################
#
# Install-HOPackageFromHOPackageFromChocolatey
#
# Installs packages from chocolatey
#
# -AppName[string]
#       Name of the chocolatey package
# -ExecutableName[string]
#       The actual filename of the program, ex. choco.exe
# -InstallParams[string]
#       Optional: Any supported install params
#
################################################################################
function Install-HOPackageFromChocolatey {
    [CmdletBinding()]
    Param(
        [String]$AppName,
        [string]$ExecutableName,
        [string]$InstallParams = ""
    )
    Process {
        $OriginalErrorActionPreference = $ErrorActionPreference
        $executablePath = (Get-Command -Name $executableName -ErrorAction SilentlyContinue).Path

        if($executablePath) {
            Write-Host "$AppName installation at $executablePath, updating to latest version"
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
        Update-Path
    }
}

################################################################################
#
# Install-HOPackageFromHOPackageFromScoop
#
# Installs packages from chocolatey
#
# -AppName[string]
#       Name of the scoop package
# -ExecutableName[string]
#       The actual filename of the program, ex. scoop.exe
#
################################################################################
function Install-HOPackageFromScoop {
    [CmdletBinding()]
    Param(
        [String]$AppName,
        [string]$ExecutableName
    )
    Process {
        $OriginalErrorActionPreference = $ErrorActionPreference
        $executablePath = (Get-Command -Name $executableName -ErrorAction SilentlyContinue).Path

        if($executablePath) {
            Write-Host "$AppName installation at $executablePath, updating to latest version"
            iex "&  scoop update $AppName"
            $ErrorActionPreference = $OriginalErrorActionPreference
            if($LASTEXITCODE) {
                Write-Error "Update for $AppName was unable to execute comman via iex";
                Exit $LASTEXITCODE
            }
        } else {
            Write-Host "Installing $AppName..."
            $expression = "& scoop install $AppName "
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
        Update-Path
    }
}

#Test Exit
################################################################################
# Begin Main Script
################################################################################

#Scoop
Install-HOPackageFromRemoteScript -AppName "Scoop" `
    -InstallUrl "https://get.scoop.sh" `
    -UpdateCommand "scoop update" `
    -ExecutableName "scoop.cmd"

#Chocolatey
Install-HOPackageFromRemoteScript -AppName "Chocolatey" `
    -InstallUrl "https://chocolatey.org/install.ps1" `
    -UpdateCommand "choco upgrade chocolatey" `
    -ExecutableName "choco.exe"



#Hyper-V
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.state -eq "Enabled") {
    Write-Host "Hyper-V was already enabled..."
} else {
    Write-Host "Enabling Hyper-V..."
    Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online -NoRestart
}

Install-HOPackageFromChocolatey -AppName "docker-for-windows" -ExecutableName "docker.exe"
Install-HOPackageFromChocolatey -AppName "git" -ExecutableName "git.exe" -InstallParams "/GitAndUnixToolsOnPath"

Install-HOPackageFromChocolatey -AppName "fciv" -ExecutableName "fciv.exe"
Install-HOPackageFromScoop -AppName "vagrant" -ExecutableName "vagrant.exe"
Install-HOPackageFromScoop -AppName "packer" -ExecutableName "packer.exe"

if (-Not (Test-Path "~/.ssh/id_rsa") ) { ssh-keygen -t rsa -f "~/.ssh/id_rsa" -P """" }

Set-ExecutionPolicy -ExecutionPolicy $ExecutionPolicy -Scope CurrentUser -Force

#Restart Computer to Finalize Hyper-V
#Restart-Computer