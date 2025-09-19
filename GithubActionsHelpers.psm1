$RepositoryOrganization = "mpv-distributions"
$RepositoryName = "mpv-win-setup"

$headers = @{}
if ($env:GITHUB_TOKEN) {
    $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
}
$headers["User-Agent"] = "Mpv-Setup-Builder"

. "$PSScriptRoot\BuildSetupFunctions\GetDownloadUrl.ps1"

function Get-LatestVersion {
    param ([string] $BuildType)

    if ($BuildType -eq 'master') {
        return Get-LatestCommitHashFromGit
    } elseif ($BuildType -eq 'stable') {
        return Get-LatestVersionStringFromSourceForge
    } else {
        throw "Unknown BuildType: $BuildType"
    }
}

function Get-LatestBuildVersion {
    param ([string] $BuildType)

    if ($BuildType -eq 'stable') {
        try {
            $latestRelease = Invoke-RestMethod "https://api.github.com/repos/$RepositoryOrganization/$RepositoryName/releases/latest" -Headers $headers
        } catch {
            # Handle 404 "Not Found" case if no releases exist
            if ($_.Exception.Response.StatusCode.value__ -eq 404) {
                Write-Host "No releases found for $RepositoryOrganization/$RepositoryName ($BuildType). Maybe the repository doesn't exist either."
                return $null
            } else {
                throw
            }
        }
        
        return $latestRelease.tag_name
    }
    elseif ($BuildType -eq 'master') {
        $allReleases = Invoke-RestMethod "https://api.github.com/repos/$RepositoryOrganization/$RepositoryName/releases" -Headers $headers
        
        if (-not $allReleases) {
            Write-Host "No releases found for $RepositoryOrganization/$RepositoryName"
            return $null
        }
        
        $latestMasterPrerelease = ($allReleases | Where-Object { $_.prerelease -eq $true }) | Select-Object -First 1
        $commitHash = if ($latestMasterPrerelease.body -match 'MPV Commit\s*:\s*([0-9a-f]{7,40})') {
            $matches[1]
        }
        return $commitHash
    } else {
        throw "Unknown BuildType: $BuildType"
    }
}

function Get-LatestCommitHashOrTagName {
    param ([string] $BuildType)

    if ($BuildType -eq 'master') {
        # Use commit mpv hash if building for master
        return Get-LatestCommitHashFromGit
    } elseif ($BuildType -eq 'stable') {
        # Use the tag if we are building stable build
        return Get-LatestVersion -BuildType $BuildType
    } else {
        throw "Unknown BuildType: $BuildType"
    }
}

function Get-ReleaseNotesVersionString {
    param ([string] $BuildType)

    $CommitHashOrTagName = Get-LatestCommitHashOrTagName -BuildType $BuildType

    if ($BuildType -eq 'stable') {
        return "MPV Version : $CommitHashOrTagName"
    } elseif ($BuildType -eq 'master') {
        return "MPV Commit : $CommitHashOrTagName"
    } else {
        throw "Unknown BuildType: $BuildType"
    }
}

function Test-BuildRequired {
    param ([string] $BuildType)

    $LatestVersion = Get-LatestVersion -BuildType $BuildType
    $LatestBuildVersion = Get-LatestBuildVersion -BuildType $BuildType

    Write-Host "Latest Github Version : $LatestVersion, Latest Version for which setup was built : $LatestBuildVersion"

    if(-not $LatestBuildVersion) {
        # This is the first build, there are no releases
        return $true
    }

    if($LatestVersion -eq $LatestBuildVersion) {
        return $false
    } else {
        return $true
    }
}

Export-ModuleMember -Function Get-LatestVersion, Test-BuildRequired, Get-ReleaseNotesVersionString, Get-LatestCommitHashOrTagName