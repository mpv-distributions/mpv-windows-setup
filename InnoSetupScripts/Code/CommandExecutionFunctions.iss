#define WINGET_YTDLP_INSTALL_PARAMS "install --accept-source-agreements --accept-package-agreements --disable-interactivity --id=yt-dlp.yt-dlp"

// https://stackoverflow.com/a/31427076
procedure ExecuteAndWarn(const FileName, Params, WorkingDir, FriendlyName: string);
var
  ResultCode: Integer;
begin
  if Exec(FileName, Params, WorkingDir, SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if (ResultCode <> 0) and (not WizardSilent) then
      MsgBox(FriendlyName + ' failed with exit code ' + IntToStr(ResultCode) + '.', mbCriticalError, MB_OK);
  end
  else
    if not WizardSilent then
      MsgBox('Failed to launch ' + FileName + ': ' + SysErrorMessage(ResultCode), mbCriticalError, MB_OK);
end;

procedure WingetInstallYtdlp;
var
  Params: String;
begin
  if WizardIsTaskSelected('installytdlp') and not ProgramExistsInPath('yt-dlp.exe') then
  begin
    WizardForm.StatusLabel.Caption := 'Installing yt-dlp…';
    WizardForm.StatusLabel.Update;
    
    if IsAdmin then
      Params := '{#WINGET_YTDLP_INSTALL_PARAMS} --scope machine'
    else
      Params := '{#WINGET_YTDLP_INSTALL_PARAMS}';

    ExecuteAndWarn('winget.exe', Params, '', 'yt-dlp installation via winget');
  end;
end;