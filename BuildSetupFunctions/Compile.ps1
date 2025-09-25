function Get-MpvVersion {
    $arch = $script:Architectures | Where-Object { $_ -ne "aarch64" } | Select-Object -First 1
    $mpvPath = Join-Path $script:DownloadFolder $arch "mpv.com"

    try {
        $versionOutput = & $mpvPath --version 2>&1

        $firstLine = $versionOutput | Select-Object -First 1
        if ($firstLine -match 'mpv\s+v([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9]+-g[0-9a-f]{7,40})?)') {
            $mpvVersion = $matches[1]
            return $mpvVersion
        } else {
            throw "Failed to parse MPV version from: $firstLine"
        }
    } catch {
        throw "Failed to get mpv version info. Failed to run mpv at path '$mpvPath': $_"
    }
}

function Compile-InnoSetup {
    Write-Host "Compiling Inno Setup for all architectures..."

    foreach ($arch in $script:Architectures) {
        Write-Host "Building setup for $arch"
        $mpvVersion = Get-MpvVersion
        Write-Host "MPV Version : $mpvVersion"

        $cmdArgs = @(
            "/Q",
            "/DAPP_VERSION=`"$mpvVersion`"",
            "/DARCHITECTURE=$arch",
            "/DUPDATE_CHANNEL=$($script:BuildType)",
            "/O`"$($script:ArtifactFolder)`"",
            "`"$($script:InnoSetupScript)`""
        )

        $process = Start-Process -FilePath $script:iscc_command -ArgumentList $cmdArgs -NoNewWindow -Wait -PassThru

        if ($process.ExitCode -ne 0) {
            throw "Inno Setup compilation failed for architecture: $arch"
        }
    }

    Write-Host "Setup compiled successfully."
}