$Header = @{
    "User-Agent" = "MPV-Updater"
    "Accept"     = "application/vnd.github+json"
}

if($env:GithubToken) {
    $Header["Authorization"] = "Bearer $env:GithubToken"
}