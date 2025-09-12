AppVersion={#APP_VERSION}
OutputDir={#OUTPUT_DIR}
OutputBaseFilename="mpv-setup-{#ARCHITECTURE}"

#if ARCHITECTURE == "x86_64"
  ArchitecturesAllowed=x64compatible and not arm64
  ArchitecturesInstallIn64BitMode=x64compatible
#elif ARCHITECTURE == "x86_64-v3"
  ArchitecturesAllowed=x64compatible and not arm64
  ArchitecturesInstallIn64BitMode=x64compatible
#elif ARCHITECTURE == "aarch64"
  ArchitecturesAllowed=arm64 and not x64compatible
  ArchitecturesInstallIn64BitMode=x64compatible
#elif ARCHITECTURE == "i686"
  ArchitecturesAllowed=x86compatible and not x64compatible
#endif

AppName={#APP_NAME}
AppPublisher={#APP_PUBLISHER}
AppPublisherURL={#APP_PUBLISHER_URL}
DefaultGroupName={#APP_NAME}
UninstallDisplayName={#APP_NAME}
UninstallDisplayIcon={app}\{#MPV_EXE}
DefaultDirName={autopf}\{#APP_NAME}

WizardStyle=modern
PrivilegesRequiredOverridesAllowed=dialog
ChangesAssociations=yes
ChangesEnvironment=yes
AllowCancelDuringInstall=no 
Compression=lzma2
SolidCompression=yes