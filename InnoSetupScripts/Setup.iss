; Mandatory to set from compile command

#ifndef APP_VERSION
#define APP_VERSION "2025.10.05"
#endif

#ifndef ARCHITECTURE
#define ARCHITECTURE "x86_64-v3"
#endif

#ifndef UPDATE_CHANNEL
#define UPDATE_CHANNEL "master"
#endif

#ifndef OUTPUT_DIR
#define OUTPUT_DIR "..\artifacts"
#endif

#ifndef SRC_DIR
#define SRC_DIR "..\downloads\" + ARCHITECTURE
#endif

; Constants
#define APP_NAME "MPV";
#define MPV_EXE "mpv.exe";
#define APP_PUBLISHER "mpv.io";
#define APP_PUBLISHER_URL "https://mpv.io";

; Scheduled Task
#define REGISTER_UPDATE_TASK_SCRIPT "{app}\updater\Register-UpdateMPVTask.ps1"
#define UPDATE_TASK_SCRIPT "{app}\updater\Update-MPV.ps1"
#define MPV_UPDATE_TASK_NAME "Update " + APP_NAME

[Setup]
#include "SetupSection.iss"

[Messages]
FinishedHeadingLabel=Installation Complete

[Files]
Source: "{#SRC_DIR}\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\{#APP_NAME}"; Filename: "{app}\{#MPV_EXE}"
Name: "{group}\Uninstall {#APP_NAME}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#APP_NAME}"; Tasks: desktopicon; Filename: "{app}\{#MPV_EXE}"

[Tasks]
Name: desktopicon; Description: "Create &Desktop Icon"
Name: autoupdate; Description: "Enable Automatic &Updates"
Name: addtopath; Description: "Add to &Path"
Name: installytdlp; Description: "Install &yt-dlp (Requires Winget)"

[Run]
Filename: "powershell.exe"; Tasks: autoupdate;  StatusMsg: "Scheduling Auto Update..."; Flags: runhidden; \
  Parameters: "-ExecutionPolicy Bypass -NoProfile -File ""{#REGISTER_UPDATE_TASK_SCRIPT}"" -TaskName ""{#MPV_UPDATE_TASK_NAME}"" -ScriptPath ""{#UPDATE_TASK_SCRIPT}"""
  
[UninstallRun]
Filename: "schtasks.exe"; Flags: runhidden; RunOnceId: UninstallUpdateTask; Parameters: "/Delete /TN ""{#MPV_UPDATE_TASK_NAME}"" /F"

[Registry]
#include "RegistrySection.iss"

[Code]
#include "Code\CheckFunctions.iss"
#include "Code\CommandExecutionFunctions.iss"
#include "Code\FileAssociationFunctions.iss"
#include "Code\SetupHooks.iss"

