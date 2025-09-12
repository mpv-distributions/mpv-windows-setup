$fallback7z = Join-Path $script:UtilsFolder "7zr.exe"

function Get-7z {
    $7z_command = Get-Command -CommandType Application -ErrorAction Ignore 7z.exe | Select-Object -Last 1
    if ($7z_command) {
        return $7z_command.Source
    }
    if (Test-Path $fallback7z) {
        return $fallback7z
    }
    return $null
}

function Check-7z {
    if (-not (Get-7z))
    {
        New-Item -ItemType Directory -Force (Split-Path $fallback7z) | Out-Null
        Write-Host "Downloading 7zr.exe"
        Invoke-WebRequest -Uri "https://www.7-zip.org/a/7zr.exe" -UserAgent $useragent -OutFile $fallback7z
    }
}

function Get-Iscc {
    $possiblePaths = @(
        "C:\Program Files (x86)\Inno Setup 6\iscc.exe",
        "C:\Program Files\Inno Setup 6\iscc.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    # Last resort: try PATH
    $iscc = Get-Command iscc.exe -ErrorAction SilentlyContinue
    if ($iscc) {
        return $iscc.Source
    }

    throw "Inno Setup Compiler (iscc.exe) not found."
}