function Prepare-PackageFolders {
    $filesToDelete = @(
        "installer",
        "updater.bat"
    )

    foreach ($arch in $script:Architectures) {
        $mpvArchPath = Join-Path $script:DownloadFolder $arch

        foreach ($file in $filesToDelete) {
            Remove-Item -Path (Join-Path $mpvArchPath $file) -Recurse -Force -ErrorAction SilentlyContinue
        }

        Copy-Item -Path (Join-Path $script:PayloadsFolder "*") -Destination $mpvArchPath -Recurse
    }   
}