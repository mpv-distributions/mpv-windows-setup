$script:Errors = Import-PowerShellDataFile -Path "$PSScriptRoot\ErrorCodes.psd1"
$LogPath = Join-Path $env:LOCALAPPDATA "mpv-updater\updater.log"
$MaxSizeMB = 5   # in MB

function Initialize-ErrorHandler {
    param(
        [Parameter(Mandatory)]
        [string]$logPath,

        [Parameter(Mandatory)]
        [int]$maxSizeMB
    )

    # Load error codes once
    $LogPath   = $logPath
    $MaxSizeMB = $maxSizeMB

    # Create log dir if it doesn't exist
    $logDir = Split-Path $LogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
}

function Stop-Update {
    param(
        [Parameter(Position = 0)]
        [Hashtable] $ErrorObj,

        [Parameter(Position = 1)]
        [string] $ExtraMessage
    )

    # Don't log some errors
    if ($ErrorObj.ContainsKey("Log") -and -not $ErrorObj.Log) {
        exit $ErrorObj.Code
    }

    Write-Log "$($ErrorObj.Message) ErrorCode : $($ErrorObj.Code)"

    if ($ExtraMessage) {
        Write-Log $ExtraMessage
    }

    exit $ErrorObj.Code
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "ERROR"
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    if (Test-Path $LogPath) {
        $sizeMB = (Get-Item $LogPath).Length / 1MB
        if ($sizeMB -ge $MaxSizeMB) {
            # overwrite instead of append
            Set-Content -Path $LogPath -Value "[$timestamp] [INFO] Log truncated (exceeded $MaxSizeMB MB)"
        }
    }

    $line = "[$timestamp] [$Level] $Message"

    Add-Content -Path $LogPath -Value $line
    Write-Host $line
}