$GitReleaseInfoURL = "https://api.github.com/repos/shinchiro/mpv-winbuild-cmake/releases/latest"
$SourceForgeReleaseInfoURL = "https://sourceforge.net/projects/mpv-player-windows/rss?path=/release"

# Cache variables to avoid unnecessary API Calls
$script:CachedGitReleaseInfo = $null
$script:CachedSourceForgeReleaseInfo = $null

function Get-DownloadUrl {
    if ($script:BuildType -eq 'master') {
        $script:MpvAssets = Get-DownloadUrlFromGit
    }
    elseif ($script:BuildType -eq 'stable') {
        $script:MpvAssets = Get-DownloadUrlFromSourceForge
    }
    else {
        throw "Unknown BuildType: $script:BuildType"
    }
}

function Get-SourceForgeReleaseInfo {
    if (-not $script:CachedSourceForgeReleaseInfo) {
        Write-Host "Fetching release info from SourceForge..."
        [xml]$script:CachedSourceForgeReleaseInfo = Invoke-WebRequest -UserAgent $script:UserAgent -Uri $SourceForgeReleaseInfoURL
    }
}

function Get-LatestVersionStringFromSourceForge {
    Get-SourceForgeReleaseInfo

    $firstMpvItem = $script:CachedSourceForgeReleaseInfo.rss.channel.item |
        Where-Object { $_.link -match "mpv-[0-9]+\.[0-9]+\.[0-9]+.*\.7z" } |
        Select-Object -First 1

    if ($firstMpvItem.link -match "mpv-(?<Version>[0-9]+\.[0-9]+\.[0-9]+)") {
        return $Matches.Version
    } else {
        throw "Could not parse SourceForge version from item link: $($firstMpvItem.link)"
    }
}

function Get-DownloadUrlFromSourceForge {
    Get-SourceForgeReleaseInfo
    $releaseInfo = $script:CachedSourceForgeReleaseInfo
    $version = Get-LatestVersionStringFromSourceForge

    # Namespace manager for 'media'
    $nsmgr = New-Object System.Xml.XmlNamespaceManager($releaseInfo.NameTable)
    $nsmgr.AddNamespace("media", "http://video.search.yahoo.com/mrss/")

    $items = $releaseInfo.rss.channel.item | Where-Object { $_.link -match "mpv-$version-(?<Arch>[^/]+)\.7z" }

    if (-not $items) {
        throw "No SourceForge assets found for version $version"
    }

    # Prepare mpv asset table
    $mpvAssets = @{}

    foreach ($arch in $script:Architectures) {
        $regex = "mpv-$version-$arch\.7z"

        $item = $releaseInfo.rss.channel.item | Where-Object { $_.link -match $regex } | Select-Object -First 1

        if (-not $item) {
            throw "No SourceForge asset found for version $version and arch $arch"
        }

        $filename = "mpv-$version-$arch.7z"
        $finalUrl = "https://download.sourceforge.net/mpv-player-windows/$filename"

        $hashNode = $item.SelectSingleNode("media:content/media:hash", $nsmgr)
        $hashAlgo  = $hashNode.algo
        $hashValue = $hashNode.InnerText

        $mpvAssets[$arch] = [PSCustomObject]@{
            Url      = $finalUrl
            Hash     = $hashValue
            HashAlgo = $hashAlgo
            Filename = $filename
        }
    }

    return [PSCustomObject]@{
        Version   = $version
        MpvAssets = $mpvAssets
    }
}

function Get-GitReleaseInfo {
    if (-not $script:CachedGitReleaseInfo) {
        Write-Host "Fetching release info from GitHub..."
        $script:CachedGitReleaseInfo = Invoke-RestMethod -Uri $GitReleaseInfoURL -Headers $script:Headers
    }
}

function Get-LatestVersionStringFromGit {
    Get-GitReleaseInfo

    $tag = $script:CachedGitReleaseInfo.tag_name
    if (-not $tag) {
        throw "No tag_name found in GitHub release info"
    }

    $date = [datetime]::ParseExact($tag, "yyyyMMdd", $null)
    return $date.ToString("yyyy.MM.dd")
}

function Get-LatestCommitHashFromGit {
    Get-GitReleaseInfo

    $asset = $script:CachedGitReleaseInfo.assets
                | Where-Object {  $_.name -like "*mpv-*" -and $_.name -notlike "*dev*" -and $_.name -notlike "*gcc*" } 
                | Select-Object -First 1

    if (-not $asset) {
        throw "No suitable asset found in release $script:CachedGitReleaseInfo.tag_name"
    }

    if ($asset.name -match "-git-([0-9a-fA-F]+)\.7z$") {
        return $matches[1]
    }
    else {
        throw "Could not extract commit hash from asset name: $($asset.name)"
    }
}

function Get-DownloadUrlFromGit {
    Get-GitReleaseInfo
    $releaseInfo = $script:CachedGitReleaseInfo

    # Determine version from first mpv asset
    $version = Get-LatestCommitHashFromGit

    # Prepare mpv asset table
    $mpvAssets = @{}

    foreach ($arch in $script:Architectures) {
        # Find the asset matching this architecture
        $asset = $releaseInfo.assets |
                    Where-Object { 
                        $_.name -like "*mpv-$arch*" -and $_.name -notlike "*dev*" -and $_.name -notlike "*gcc*" 
                    } | Select-Object -First 1

        if (-not $asset) {
            throw "No Github asset found for architecture: $arch"
        }

        # Extract hash info
        $hashAlgo, $hashValue = $asset.digest -split ":", 2

        $url = $asset.browser_download_url
        $filename = "mpv-$version-$arch.7z"

        $mpvAssets[$arch] = [PSCustomObject]@{
            Url      = $url
            Hash     = $hashValue
            HashAlgo = $hashAlgo
            Filename = $filename
        }
    }

    return [PSCustomObject]@{
        Version    = $version
        MpvAssets    = $mpvAssets
    }
}