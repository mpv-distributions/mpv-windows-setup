function Get-MpvVersion {
    if ($script:Architectures -contains "x86_64") {
        $arch = "x86_64"
    } else {
        throw "x86_64 architecture is not available."
    }
    
    $mpvPath = Join-Path $script:DownloadFolder $arch "mpv.com"

    try {
        $versionOutput = & $mpvPath --version 2>&1
        $exitCode = $LASTEXITCODE
        
        Write-Host "Exit Code: $exitCode"
        Write-Host "Raw Output: $versionOutput"

        $firstLine = $versionOutput | Select-Object -First 1
        if ($firstLine -match 'mpv\s+v([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9]+-g[0-9a-f]{7,40})?)') {
            $mpvVersion = $matches[1]
            return $mpvVersion
        } else {
            throw "Failed to parse MPV version. Exit code: $exitCode. Output: $versionOutput"
        }
    } catch {
        throw "Failed to get mpv version info: $_"
    }
}

function Compile-InnoSetup {
    Write-Host "Compiling Inno Setup for all architectures..."
    $mpvVersion = Get-MpvVersion
    Write-Host "MPV Version : $mpvVersion"

    foreach ($arch in $script:Architectures) {
        Write-Host "Building setup for $arch"

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
