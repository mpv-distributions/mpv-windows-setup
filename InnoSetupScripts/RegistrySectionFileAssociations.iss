; Register the friendly application name for mpv under the Applications key.
; This ensures that "mpv" will show up with a readable name in "Open with" dialogs and other Windows shell integration features.
Root: HKA; Subkey: "Software\Classes\Applications\{#MPV_EXE}"; ValueName: "FriendlyAppName"; ValueType: string; ValueData: "{#APP_NAME}"; Flags: uninsdeletekey

; Set the default verb for mpv to "play". This makes "Play" the default action when a user double-clicks an associated file.
Root: HKA; Subkey: "Software\Classes\Applications\{#MPV_EXE}\shell"; ValueType: string; ValueData: "play"; Flags: uninsdeletekey

; Hide the built-in "open" verb from the context menu. mpv treats "open" and "play" as the same, so showing both would be redundant. 
; Adding "LegacyDisable" makes "open" unavailable to users in right-click menus.
Root: HKA; Subkey: "Software\Classes\Applications\{#MPV_EXE}\shell\open"; ValueName: "LegacyDisable"; ValueType: none; Flags: uninsdeletekey

; Define the command for the "open" verb (even though it's hidden). This is still needed internally by Windows shell APIs for compatibility.
Root: HKA; Subkey: "Software\Classes\Applications\{#MPV_EXE}\shell\open\command"; ValueType: string; ValueData: """{app}\{#MPV_EXE}"" -- ""%1"""; Flags: uninsdeletekey

; Define the label text for the "play" verb that appears in the right-click menu. The "&" makes "P" a keyboard shortcut (Alt+P) when navigating context menus.
Root: HKA; Subkey: "Software\Classes\Applications\{#MPV_EXE}\shell\play"; ValueType: string; ValueData: "&Play"; Flags: uninsdeletekey

; Define the actual command for the "play" verb.
; When a user selects "Play" from the context menu, Windows executes this command,
Root: HKA; Subkey: "Software\Classes\Applications\{#MPV_EXE}\shell\play\command"; ValueType: string; ValueData: """{app}\{#MPV_EXE}"" -- ""%1"""; Flags: uninsdeletekey

; Add mpv to "Open with" list for video and audio files
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\video\OpenWithList\{#MPV_EXE}"; ValueType: string; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\audio\OpenWithList\{#MPV_EXE}"; ValueType: string; ValueData: ""; Flags: uninsdeletekey


; DVD AutoPlay handler
; ProgID for DVD
Root: HKA; Subkey: "Software\Classes\io.mpv.dvd\shell\play"; ValueType: string; ValueData: "&Play"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\io.mpv.dvd\shell\play\command"; ValueType: string; ValueData: """{app}\{#MPV_EXE}"" dvd:// --dvd-device=""%L"""; Flags: uninsdeletekey

; Handler registration
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayDVDMovieOnArrival"; ValueName: "Action"; ValueType: string; ValueData: "Play DVD movie"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayDVDMovieOnArrival"; ValueName: "DefaultIcon"; ValueType: string; ValueData: "{app}\{#MPV_EXE},0"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayDVDMovieOnArrival"; ValueName: "InvokeProgID"; ValueType: string; ValueData: "io.mpv.dvd"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayDVDMovieOnArrival"; ValueName: "InvokeVerb"; ValueType: string; ValueData: "play"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayDVDMovieOnArrival"; ValueName: "Provider"; ValueType: string; ValueData: "{#APP_NAME}"; Flags: uninsdeletekey

; Attach handler to event
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\PlayDVDMovieOnArrival"; ValueName: "MpvPlayDVDMovieOnArrival"; ValueType: string; ValueData: ""; Flags: uninsdeletekey


; Blu-ray AutoPlay handler
; ProgID for Blu-ray
Root: HKA; Subkey: "Software\Classes\io.mpv.bluray\shell\play"; ValueType: string; ValueData: "&Play"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\io.mpv.bluray\shell\play\command"; ValueType: string; ValueData: """{app}\{#MPV_EXE}"" bd:// --bluray-device=""%L"""; Flags: uninsdeletekey

; Handler registration
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayBluRayOnArrival"; ValueName: "Action"; ValueType: string; ValueData: "Play Blu-ray movie"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayBluRayOnArrival"; ValueName: "DefaultIcon"; ValueType: string; ValueData: "{app}\{#MPV_EXE},0"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayBluRayOnArrival"; ValueName: "InvokeProgID"; ValueType: string; ValueData: "io.mpv.bluray"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayBluRayOnArrival"; ValueName: "InvokeVerb"; ValueType: string; ValueData: "play"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\MpvPlayBluRayOnArrival"; ValueName: "Provider"; ValueType: string; ValueData: "{#APP_NAME}"; Flags: uninsdeletekey

; Attach handler to event
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\PlayBluRayOnArrival"; ValueName: "MpvPlayBluRayOnArrival"; ValueType: string; ValueData: ""; Flags: uninsdeletekey

; Capabilities key for Default Programs
Root: HKA; Subkey: "SOFTWARE\Clients\Media\{#APP_NAME}\Capabilities"; ValueType: string; ValueName: "ApplicationName"; ValueData: "{#APP_NAME}"; Flags: uninsdeletevalue
Root: HKA; Subkey: "SOFTWARE\Clients\Media\{#APP_NAME}\Capabilities"; ValueType: string; ValueName: "ApplicationDescription"; ValueData: "{#APP_NAME} Media Player"; Flags: uninsdeletevalue

; Register mpv in Default Programs
Root: HKA; Subkey: "SOFTWARE\RegisteredApplications"; ValueType: string; ValueName: "{#APP_NAME}"; ValueData: "SOFTWARE\Clients\Media\{#APP_NAME}\Capabilities"; Flags: uninsdeletevalue