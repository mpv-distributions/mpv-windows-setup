. "$PSScriptRoot\Header.ps1"

function Get-LatestGithubRelease {
    param(
        [string] $githubReleaseAPIEndpoint,
        [string] $updateChannel
    )

    try {
        $releases = Invoke-RestMethod -Headers $Header -Uri $githubReleaseAPIEndpoint -ErrorAction Stop
    }
    catch {
        Stop-Update $Errors.ERR_GITHUB_RELEASE_FETCH "URL : $githubReleaseAPIEndpoint. Exception: $_"
    }

    switch ($updateChannel.ToLower()) {
        "stable" {
            $latestReleaseInfo = $releases | Where-Object { -not $_.prerelease -and -not $_.draft } | Select-Object -First 1
        }
        "master" {
            $latestReleaseInfo = $releases | Select-Object -First 1
        }
        default {
            Stop-Update $Errors.ERR_GITHUB_CHANNEL_UNKNOWN "Channel: $updateChannel"
        }
    }

    if(-not $latestReleaseInfo.tag_name) {
        Stop-Update $Errors.ERR_GITHUB_TAG_MISSING
    }

    if(-not $latestReleaseInfo.assets) {
        Stop-Update $Errors.ERR_GITHUB_ASSETS_MISSING
    }

    return $latestReleaseInfo
}

function Get-DownloadUrl {
    param(
        [pscustomobject] $latestReleaseInfo,
        [string] $installedArch
    )

    # Select the asset matching architecture
    $asset = $latestReleaseInfo.assets | Where-Object {
                ($_.name.ToLower().Contains("mpv")) -and 
                ($_.name.ToLower().Contains($installedArch.ToLower())) -and 
                ($_.name.ToLower().Contains("setup"))
            } | Select-Object -First 1

    if (-not $asset) {
        Stop-Update $Errors.ERR_GITHUB_ASSET_NOT_FOUND "Architecture : '$installedArch' Release Tag Name : $($latestReleaseInfo.tag_name)"
    }

    if(-not $asset.browser_download_url) {
        Stop-Update $Errors.ERR_GITHUB_ASSET_NO_URL "Release Tag Name : $($latestReleaseInfo.tag_name)"
    }

    if (-not $asset.digest) {
        Stop-Update $Errors.ERR_GITHUB_ASSET_NO_DIGEST "Release Tag Name : $($latestReleaseInfo.tag_name)"
    }

    $digestParts = $asset.digest -split ":", 2

    return [PSCustomObject]@{
        Url       = $asset.browser_download_url
        FileHash  = $digestParts[1]
        FileHashAlgo  = $digestParts[0]
    }
}