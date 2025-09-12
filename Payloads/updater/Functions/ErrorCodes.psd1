@{
    # Success
    EXIT_SUCCESS                            = @{ Code = 0;  Message = "Success"; Log = $false }

    # Updater Pre Checks
    ERR_PROCESS_RUNNING                     = @{ Code = 1;  Message = "Process is currently running."; Log = $false }
    ERR_NO_INTERNET                         = @{ Code = 2;  Message = "No internet connection."; Log = $false }

    # Registry
    ERR_REGISTRY_READ_PATH                  = @{ Code = 10; Message = "Registry: Failed to read registry." }
    ERR_REGISTRY_READ_KEY                   = @{ Code = 11; Message = "Registry: Failed to read registry key." }

    # GitHub release
    ERR_GITHUB_RELEASE_FETCH                = @{ Code = 20; Message = "GitHub: Failed to fetch release information." }
    ERR_GITHUB_RELEASES_MISSING             = @{ Code = 21; Message = "GitHub: Releases is empty." }
    ERR_GITHUB_TAG_MISSING                  = @{ Code = 22; Message = "GitHub: Latest release has no tag name." }
    ERR_GITHUB_CHANNEL_UNKNOWN              = @{ Code = 23; Message = "GitHub: Unknown update channel specified." }
    ERR_GITHUB_ASSETS_MISSING               = @{ Code = 24; Message = "GitHub: Release is missing Assets." }
    ERR_GITHUB_ASSET_NOT_FOUND              = @{ Code = 25; Message = "GitHub: No matching release asset found." }
    ERR_GITHUB_ASSET_NO_URL                 = @{ Code = 26; Message = "GitHub: Release asset missing download URL." }
    ERR_GITHUB_ASSET_NO_DIGEST              = @{ Code = 27; Message = "GitHub: Release asset missing digest/hash." }

    ERR_DOWNLOAD_FAILED                     = @{ Code = 30; Message = "Downloader: Download failed after multiple retries." }
    ERR_DOWNLOAD_HASH_CALC                  = @{ Code = 31; Message = "Downloader: Failed to compute file hash." }
    ERR_DOWNLOAD_HASH_MISMATCH              = @{ Code = 32; Message = "Downloader: File hash mismatch." }
    ERR_DOWNLOAD_DIR_CREATE                 = @{ Code = 33; Message = "Downloader: Failed to create download directory." }

    ERR_INSTALLER_EXIT_CODE                 = @{ Code = 40; Message = "Installer returned a non-zero exit code." }
    ERR_INSTALLER_CANNOT_EXECUTE            = @{ Code = 41; Message = "Failed to run installer." }

    ERR_WINGET_RUN                          = @{ Code = 42; Message = "Failed to run winget." }
    ERR_WINGET_UPGRADE_FAIL                 = @{ Code = 43; Message = "Failed to upgrade package using winget." }
}