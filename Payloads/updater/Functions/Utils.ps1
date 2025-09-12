. "$PSScriptRoot\Header.ps1"

# Registry Utils
function Get-RegistryBasePath {
    if (Test-Admin) { return "HKLM" } else { return "HKCU" }
}

function Get-RegistryValue {
    param(
        [string] $RegistryPath,
        [string] $KeyName
    )

    $RegistryBasePath = Get-RegistryBasePath

    try {
        $Keys = Get-ItemProperty -Path "${RegistryBasePath}:\$RegistryPath" -Name $KeyName -ErrorAction Stop
    }
    catch {
        Stop-Update $Errors.ERR_REGISTRY_READ_PATH "Registry Path: $RegistryPath Exception: $_"
    }

    if ($Keys.$KeyName) {
        return $Keys.$KeyName
    }
    else {
        Stop-Update $Errors.ERR_REGISTRY_READ_KEY "Registry Path: $RegistryPath Registry key '$KeyName'."
    }
}

# File Utils
function New-Dir {
    param(
        [string] $dirPath
    )

    try {
        if (-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath -ErrorAction Stop | Out-Null
        }
    }
    catch {
        Stop-Update $Errors.ERR_CREATE_DIR "Path : $dirPath Exception : $_"
    }
}

function Get-File {
    param (
        [string] $downloadUrl,
        [string] $downloadDir,
        [string] $fileHashAlgo,
        [string] $fileHash,
        [int] $maxRetries = 3,
        [int] $delaySeconds = 5
    )

    $fileName = Split-Path $downloadUrl -Leaf
    $filePath = Join-Path $downloadDir $fileName

    $attempt = 0
    $downloaded = $false

    while (-not $downloaded -and $attempt -lt $maxRetries) {
        $attempt++
        Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
        try {
            Write-Host "Downloading $fileName (Attempt $attempt of $maxRetries)..."
            Invoke-WebRequest -Headers $Header -Uri $downloadUrl -OutFile $filePath -UseBasicParsing -ErrorAction Stop
            $downloaded = $true
        }
        catch {
            Write-Warning "Download attempt $attempt failed: $_"
            if ($attempt -lt $maxRetries) {
                Write-Host "Retrying in $delaySeconds seconds..."
                Start-Sleep -Seconds $delaySeconds
            }
            else {
                Stop-Update $Errors.ERR_DOWNLOAD_FAILED "Url : $downloadUrl Exception : $_"
            }
        }
    }

    try {
        $computedHash = Get-FileHash -Path $filePath -Algorithm $fileHashAlgo
        if ($computedHash.Hash -ne $fileHash) {
            Remove-Item -Path $filePath -Force
            Stop-Update $Errors.ERR_DOWNLOAD_HASH_MISMATCH "File : $downloadUrl Hash Algo : $fileHashAlgo Expected Hash : $fileHash Computed : $computedHash.Hash"
        }
    }
    catch {
        Remove-Item -Path $filePath -Force
        Stop-Update $Errors.ERR_DOWNLOAD_HASH_CALC "File : $filePath Exception : $_"
    }

    Write-Host "File downloaded successfully to $filePath"
    return $filePath
}

# Misc Utils
function Test-IsProcessRunning {
    param (
        [string] $processName
    )

    if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
        Stop-Update $Errors.ERR_PROCESS_RUNNING "Process Name : $processName"
    }
}

function Test-InternetConnection {
    try {
        Invoke-WebRequest -Uri "http://www.msftconnecttest.com/connecttest.txt" -UseBasicParsing -ErrorAction Stop | Out-Null
    }
    catch {
        Stop-Update $Errors.ERR_NO_INTERNET $_
    }
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-InnoTaskSelected {
    param(
        [string]$TaskName
    )
    $registryInnoSelectedTasksKeyName = "Inno Setup: Selected Tasks"

    $tasksValue = Get-RegistryValue "$RegistryUninstallKeyPath" $registryInnoSelectedTasksKeyName
    if ($tasksValue) {
        if ($tasksValue -like "*$TaskName*") {
            return $true
        }
    }

    return $false
}