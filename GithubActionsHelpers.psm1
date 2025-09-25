$RepositoryOrganization = "mpv-distributions"
$RepositoryName = "mpv-windows-setup"

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

function Get-CommitHashFromGithubTag($tag) {
    if ($tag -match '-g([0-9a-f]{7,40})$') {
        # Sinchiro's build uses 7 characters for commit hash
        return $matches[1].Substring(0, 7)
    } else {
        throw "No commit hash found in tag: $tag"
    }
}

function Get-LatestBuildVersion {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('stable','master')]
        [string] $BuildType
    )

    try {
        switch ($BuildType) {
            'stable' {
                $latestRelease = Invoke-RestMethod "https://api.github.com/repos/$RepositoryOrganization/$RepositoryName/releases/latest" -Headers $headers
                return $latestRelease.tag_name
            }
            'master' {
                $allReleases = Invoke-RestMethod "https://api.github.com/repos/$RepositoryOrganization/$RepositoryName/releases" -Headers $headers

                if (-not $allReleases) {
                    Write-Host "No releases found for $RepositoryOrganization/$RepositoryName"
                    return $null
                }

                $latestMasterPrerelease = $allReleases |
                    Where-Object { $_.prerelease -eq $true } |
                    Sort-Object -Property published_at -Descending |
                    Select-Object -First 1

                if (-not $latestMasterPrerelease) {
                    Write-Host "No prereleases found for $RepositoryOrganization/$RepositoryName"
                    return $null
                }

                return Get-CommitHashFromGithubTag $latestMasterPrerelease.tag_name
            }
            default {
                throw "Invalid build type : $BuildType"
            }
        }
    } catch {
        # Handle 404 "Not Found" case if no releases exist
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            Write-Host "No releases found for $RepositoryOrganization/$RepositoryName ($BuildType)."
            return $null
        } else {
            throw
        }
    }
}

function Test-BuildRequired {
    param ([string] $BuildType)

    $LatestVersion = Get-LatestVersion -BuildType $BuildType
    $LatestBuildVersion = Get-LatestBuildVersion -BuildType $BuildType

    Write-Host "Latest MPV Version : $LatestVersion, Latest Setup Version : $LatestBuildVersion"

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

Export-ModuleMember -Function Test-BuildRequired