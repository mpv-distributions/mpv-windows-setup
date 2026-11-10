function Get-MpvVersion {
    if ($script:Architectures -contains "x86_64") {
        $arch = "x86_64"
    } else {
        throw "x86_64 architecture is not available."
    }
    
    $mpvPath = Join-Path $script:DownloadFolder $arch "mpv.exe"

    try {
        # Use 'strings' to scrape the text out of the binary without executing it. Mpv fails to execute due to missing dlls.
        $stringsPath = Join-Path $env:TEMP "strings64.exe"
        if (-not (Test-Path $stringsPath)) {
            Write-Host "Downloading Sysinternals strings64.exe..."
            Invoke-WebRequest -Uri "https://live.sysinternals.com/strings64.exe" -OutFile $stringsPath
        }
        
        Write-Host "Using external tool at: $stringsPath"

        # Execute Sysinternals strings (-AcceptEula and -nobanner are required for silent server runs)
        $match = & $stringsPath -AcceptEula -nobanner $mpvPath | Select-String -Pattern 'mpv\s+v([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9]+-g[0-9a-f]{7,40})?)' | Select-Object -First 1
        
        if ($match) {
            $mpvVersion = $match.Matches[0].Groups[1].Value
            Write-Host "Successfully extracted MPV Version: $mpvVersion"
            return $mpvVersion
        } else {
            throw "Failed to find version string in binary using Sysinternals strings."
        }
    } catch {
        throw "Failed to extract mpv version info: $_"
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
