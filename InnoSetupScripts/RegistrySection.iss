#include "RegistrySectionFileAssociations.iss"

; Enable Long File Paths
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\FileSystem"; ValueType: dword; ValueName: "LongPathsEnabled"; ValueData: 1; Flags: createvalueifdoesntexist ; Check: IsAdmin

; Add to path
Root: HKA; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Check: NeedsAddPath(ExpandConstant('{app}')); Tasks: addtopath

; Write the architecture (defined at compile time)
Root: HKA; Subkey: "Software\{#APP_NAME}"; ValueType: string; ValueName: "Architecture"; ValueData: "{#ARCHITECTURE}"; Flags: uninsdeletevalue

; Write the update channel
Root: HKA; Subkey: "Software\{#APP_NAME}"; ValueType: string; ValueName: "UpdateChannel"; ValueData: "{#UPDATE_CHANNEL}"; Flags: uninsdeletevalue createvalueifdoesntexist

; Register mpv.exe so Windows can find it by name (ShellExecute, Run, etc.)
Root: HKA; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MPV_EXE}"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MPV_EXE}"; Flags: uninsdeletekey
Root: HKA; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MPV_EXE}"; ValueType: dword; ValueName: "UseUrl"; ValueData: "1"; Flags: uninsdeletekey