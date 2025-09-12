param (
    [string]$TaskName = "Update MPV",
    [string]$ScriptPath = "$PSScriptRoot\Update-MPV.ps1"
)

function Register-UpdateMPVTask {
    param (
        [string]$TaskName,
        [string]$ScriptPath
    )
    Write-Output "Scheduling MPV Autoupdate"

    try {
        $taskExe  = "C:\Windows\System32\conhost.exe"
        $taskArgs = "--headless powershell.exe -WindowStyle Hidden -NoProfile -NonInteractive -File `"$ScriptPath`""
        $taskAction = New-ScheduledTaskAction -Execute $taskExe -Argument $taskArgs
        $taskTrigger = New-ScheduledTaskTrigger -Daily -At 00:00
        $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable

        # Base parameters
        $params = @{
            TaskName = $taskName
            Action   = $taskAction
            Trigger  = $taskTrigger
            Settings = $taskSettings
            Force    = $true
        }

        # Detect elevation
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
                    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($IsAdmin) {
            $params["RunLevel"] = "Highest"
        }

        Register-ScheduledTask @params -ErrorAction Stop
        Write-Output "Task '$taskName' registered successfully."
    } catch {
        Write-Output "Failed to register scheduled task: $_"
    }
}

Register-UpdateMPVTask -TaskName $TaskName -ScriptPath $ScriptPath