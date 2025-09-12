<#
.SYNOPSIS
    Build script for MPV installer.

.DESCRIPTION
    Builds either master or stable version of the installer for all architectures.

.PARAMETER BuildType
    Mandatory. Either master or stable. 
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("master", "stable")]
    [string]$BuildType
)

# Config Variables
$ErrorActionPreference = "Stop"
$FormatEnumerationLimit = -1
$ProgressPreference = "SilentlyContinue"

$script:Architectures = @("i686", "x86_64", "x86_64-v3", "aarch64")

# Constants
$script:Headers = @{}
if ($env:GITHUB_TOKEN) {
    $script:Headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
}
$script:Headers["User-Agent"] = "Mpv-Setup-Builder"

# Runtime Variables
$script:BuildType = $BuildType
$script:RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:PayloadsFolder  = Join-Path $RepoRoot "Payloads"
$script:DownloadFolder  = Join-Path $RepoRoot "downloads"
$script:ArtifactFolder  = Join-Path $RepoRoot "artifacts"
$script:UtilsFolder  = Join-Path $RepoRoot "utils"
$script:InnoSetupScript = Join-Path $PSScriptRoot "InnoSetupScripts" "Setup.iss"

$script:7z_command = $null
$script:iscc_command = $null
$script:MpvAssets = $null

# Imports
. "$PSScriptRoot\BuildSetupFunctions\Utils.ps1"
. "$PSScriptRoot\BuildSetupFunctions\GetDownloadUrl.ps1"
. "$PSScriptRoot\BuildSetupFunctions\DownloadAndExtractFiles.ps1"
. "$PSScriptRoot\BuildSetupFunctions\PreparePackageFolders.ps1"
. "$PSScriptRoot\BuildSetupFunctions\Compile.ps1"

function Init {
    Write-Host "Initializing packaging environment..."

    # Create folders
    $folders = @($script:DownloadFolder, $script:ArtifactFolder, $script:UtilsFolder)
    foreach ($folder in $folders) {
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
    }

    Check-7z
    $script:7z_command = Get-7z
    $script:iscc_command = Get-Iscc
}

function Main {
    Init
    Get-DownloadUrl
    DownloadExtract-Files
    Prepare-PackageFolders
    Compile-InnoSetup
}

Main
