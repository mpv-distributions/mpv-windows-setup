# DownloadDir folder will be deleted and recreated, so don't set it to something that is used by other programs
$DownloadDirPath = Join-Path $env:TEMP "MPVUpdater"
$GithubReleaseAPIEndpoint = "https://api.github.com/repos/mpv-distributions/mpv-win-setup/releases"
$SetupParams = "/VERYSILENT /NORESTART"

# Error Handler Logger
$LogPath = Join-Path $env:LOCALAPPDATA "mpv-updater\updater.log"
$LogMaxSizeMB = 5   # in MB

# These should be same as inno script
$AppName = "MPV"
$RegistryAppKeyPath = "Software\$AppName"
$RegistryUninstallKeyPath = "Software\Microsoft\Windows\CurrentVersion\Uninstall\${AppName}_is1"
$RegistryArchitectureKeyName = "Architecture"
$RegistryUpdateChannelKeyName = "UpdateChannel"
$RegistryDisplayVersionKeyName = "DisplayVersion"
$InstallYtdlpTaskName = "installytdlp"

# Winget
$YtdlpUpgradeParams = "upgrade --id yt-dlp.yt-dlp"

# Powershell Config
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Import
. "$PSScriptRoot\Functions\ErrorHandler.ps1"
. "$PSScriptRoot\Functions\Github.ps1"
. "$PSScriptRoot\Functions\Updater.ps1"
. "$PSScriptRoot\Functions\Utils.ps1"

function Update-MPV {
    # Clean Old Download Directory
    Remove-Item -Path $DownloadDirPath -Recurse -Force -ErrorAction SilentlyContinue

    # Check Update Conditions
    Test-IsProcessRunning -processName "mpv"
    Test-InternetConnection

    # Initialize Logger
    Initialize-ErrorHandler -logPath $LogPath -maxSizeMB $LogMaxSizeMB

    # Read Registry
    $installedVersion = Get-RegistryValue "$RegistryUninstallKeyPath" $RegistryDisplayVersionKeyName
    $installedArch = Get-RegistryValue "$RegistryAppKeyPath" $RegistryArchitectureKeyName
    $updateChannel = Get-RegistryValue "$RegistryAppKeyPath" $RegistryUpdateChannelKeyName

    # Check if latest version is already installed
    $latestReleaseInfo = Get-LatestGithubRelease -githubReleaseAPIEndpoint $GithubReleaseAPIEndpoint -updateChannel $updateChannel
    Assert-LatestVersionInstalled -latestVersion $latestReleaseInfo.tag_name -installedVersion $installedVersion
    
    # Download File
    $downloadInfo = Get-DownloadUrl -latestReleaseInfo $latestReleaseInfo -installedArch $installedArch
    New-Dir -dirPath $DownloadDirPath
    $setupPath = Get-File -downloadDir $DownloadDirPath -downloadUrl $downloadInfo.Url -fileHashAlgo $downloadInfo.FileHashAlgo -fileHash $downloadInfo.FileHash

    # Update
    Test-IsProcessRunning -processName "mpv"        # Check again, what if mpv was launched during file download
    Invoke-MpvInstaller -setupPath $setupPath -setupParams $SetupParams -installedVersion $installedVersion -installedArch $installedArch

    # Remove Download Dir
    Remove-Item -Path $DownloadDirPath -Recurse -Force -ErrorAction SilentlyContinue
}

function Update-Ytdlp {
    try {
        $process = Start-Process -FilePath "winget" -ArgumentList $YtdlpUpgradeParams -Wait -PassThru -WindowStyle Hidden

        if ($process.ExitCode -eq 0) {
            Write-Host "yt-dlp upgrade successful."
        }
        elseif ($process.ExitCode -eq -1978335189) {
            Write-Host "yt-dlp is already up-to-date."
        }
        else {
            Stop-Update $script:Errors.ERR_WINGET_UPGRADE_FAIL "Package : yt-dlp, Winget Exit Code : $($process.ExitCode)"
        }
    } catch {
        Stop-Update $script:Errors.ERR_WINGET_RUN "Exception: $_"
    }
}

function Main {
    Update-MPV
    
    if (Test-InnoTaskSelected -TaskName $InstallYtdlpTaskName) {
        Update-Ytdlp
    } else {
        Write-Host "yt-dlp not installed with mpv installer."
    }
}

Main