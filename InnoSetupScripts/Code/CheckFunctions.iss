// https://stackoverflow.com/a/9962206
function NeedsAddPath(Param: string) : boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKA, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  { look for the path with leading and trailing semicolon }
  { Pos() returns 0 if not found }
  Result := (Pos(';' + UpperCase(Param) + ';', ';' + UpperCase(OrigPath) + ';') = 0) and (Pos(';' + UpperCase(Param) + '\;', ';' + UpperCase(OrigPath) + ';') = 0); 
end;

function ProgramExistsInPath(const FileName: string): Boolean;
var
  ResultCode: Integer;
begin
  if Exec(FileName, '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Result := (ResultCode = 0)
  else
    Result := False;
end;