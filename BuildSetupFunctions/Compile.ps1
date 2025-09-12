function Compile-InnoSetup {
    Write-Host "Compiling Inno Setup for all architectures..."

    foreach ($arch in $script:Architectures) {
        Write-Host "Building setup for $arch"

        $cmdArgs = @(
            "/Q",
            "/DAPP_VERSION=$($script:MpvAssets.Version)",
            "/DARCHITECTURE=$arch",
            "/DUPDATE_CHANNEL=$($script:BuildType)",
            "/O$($script:ArtifactFolder)",
            $script:InnoSetupScript
        )

        $process = Start-Process -FilePath $script:iscc_command -ArgumentList $cmdArgs -NoNewWindow -Wait -PassThru

        if ($process.ExitCode -ne 0) {
            throw "Inno Setup compilation failed for architecture: $arch"
        }
    }

    Write-Host "Setup compiled successfully."
}