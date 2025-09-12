function Assert-LatestVersionInstalled {
    param(
        [string] $latestVersion,
        [string] $installedVersion
    )

    if ($installedVersion -eq $latestVersion) {
        Write-Host "Latest $AppName version ($latestVersion) is already installed. Exiting updater."
        Stop-Update $Errors.EXIT_SUCCESS
    }
}

function Invoke-MpvInstaller {
    param (
        [string] $setupPath,
        [string] $setupParams,
        [string] $installedVersion,
        [string] $installedArch
    )

    try {
        Write-Host "Starting MPV update"
        $process = Start-Process -FilePath $setupPath -ArgumentList $SetupParams -Wait -PassThru

        if ($process.ExitCode -ne 0) {
            Stop-Update $Errors.ERR_INSTALLER_EXIT_CODE "Setup Exit Code : $($process.ExitCode) Installed MPV Version : $installedVersion Arch : $installedArch Setup File : $setupPath"
        }
        else {
            Write-Host "MPV updated successfully."
        }
    }
    catch {
        Stop-Update $Errors.ERR_INSTALLER_CANNOT_EXECUTE "Exception : $_"
    }
}