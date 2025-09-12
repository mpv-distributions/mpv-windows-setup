function DownloadExtract-Files {
    $downloadFolder = $script:downloadFolder
    $mpvAssets = $script:MpvAssets

    foreach ($arch in $script:Architectures) {
        $mpvExtractPath = Join-Path $downloadFolder $arch

        if (-not $mpvAssets.MpvAssets.ContainsKey($arch)) {
            throw "No MPV URL found for architecture: $arch"
        }
        $mpvObj = $mpvAssets.MpvAssets[$arch]
        $mpvFile = Join-Path $downloadFolder $mpvObj.Filename
        Download-FileWithHash -Url $mpvObj.Url -FilePath $mpvFile -ExpectedHash $mpvObj.Hash -HashAlgo $mpvObj.HashAlgo
        Extract-File -FilePath $mpvFile -DestinationFolder $mpvExtractPath
        Remove-Item -Path $mpvFile -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "All downloads completed."
}

function Download-FileWithHash {
    param (
        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$ExpectedHash,

        [Parameter(Mandatory)]
        [string]$HashAlgo
    )

    Write-Host "Downloading file $Url..."
    Invoke-WebRequest -Headers $script:Headers -Uri $Url -OutFile $FilePath -UseBasicParsing

    $fileHash = Get-FileHash -Path $FilePath -Algorithm $HashAlgo
    if ($fileHash.Hash -ieq $ExpectedHash) {
        Write-Host "Hash verified: $FilePath"
    } else {
        throw "Hash mismatch for $FilePath! Expected: $ExpectedHash, Got: $($fileHash.Hash)"
    }
}

function Extract-File {
    param (
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$DestinationFolder
    )

    Write-Host "Extract File is Running"

    if (-not (Test-Path $FilePath)) {
        throw "File does not exist: $FilePath"
    }

    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
    }

    Write-Host "Extracting $FilePath to $DestinationFolder"

    Invoke-Expression "& `"$script:7z_command`" x `"$FilePath`" -o`"$DestinationFolder`" -y -bd"
    if ($LASTEXITCODE -ne 0) {
        throw "7-Zip extraction failed with exit code $LASTEXITCODE for file $FilePath"
    } else {
        Write-Host "Extraction completed successfully"
    }
}