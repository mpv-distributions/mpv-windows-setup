#include "FileTypes.iss"

// Install Section

const
  ClassesRootKey = 'SOFTWARE\Classes';
  CapabilitiesKey = 'SOFTWARE\Clients\Media\MPV\Capabilities';
  SupportedTypesKey = 'SOFTWARE\Clients\Media\MPV\Capabilities\SupportedTypes';
  FileAssociationsKey = 'SOFTWARE\Clients\Media\MPV\Capabilities\FileAssociations';

procedure AddVerbs(const ProgIdKey: string);
begin
  RegWriteStringValue(HKA, ProgIdKey + '\shell', '', 'play');
  RegWriteStringValue(HKA, ProgIdKey + '\shell\open', 'LegacyDisable', '');
  RegWriteStringValue(HKA, ProgIdKey + '\shell\open\command', '', Format('"%s" %s -- "%%L"', [MpvPath, MpvArgs]));
  RegWriteStringValue(HKA, ProgIdKey + '\shell\play', '', '&Play');
  RegWriteStringValue(HKA, ProgIdKey + '\shell\play\command', '', Format('"%s" %s -- "%%L"', [MpvPath, MpvArgs]));
end;

procedure AddProgId(const ProgId, FriendlyName: string);
var
  ProgIdKey: string;
begin
  ProgIdKey := ClassesRootKey + '\' + ProgId;
  RegWriteStringValue(HKA, ProgIdKey, '', FriendlyName);
  RegWriteDWordValue(HKA, ProgIdKey, 'EditFlags', 65536);
  RegWriteStringValue(HKA, ProgIdKey, 'FriendlyTypeName', FriendlyName);
  RegWriteStringValue(HKA, ProgIdKey + '\DefaultIcon', '', IconPath);
  AddVerbs(ProgIdKey);
end;

procedure UpdateExtension(const Ext, ProgId, MimeType, PerceivedType: string);
var
  ExtKey: string;
begin
  ExtKey := ClassesRootKey + '\' + Ext;
  if MimeType <> '' then RegWriteStringValue(HKA, ExtKey, 'Content Type', MimeType);
  if PerceivedType <> '' then RegWriteStringValue(HKA, ExtKey, 'PerceivedType', PerceivedType);
  RegWriteStringValue(HKA, ExtKey + '\OpenWithProgIds', ProgId, '');
  RegWriteStringValue(HKA, SupportedTypesKey, Ext, '');
  RegWriteStringValue(HKA, FileAssociationsKey, Ext, ProgId);
end;

procedure AddType(const FT: TFileType);
var
  ProgId: string;
  Ext: string;
  First: Boolean;
  I: Integer;
begin
  First := True;
  for I := 0 to GetArrayLength(FT.Extensions)-1 do
  begin
    Ext := FT.Extensions[I];
    if First then
    begin
      ProgId := 'io.mpv' + Ext;
      AddProgId(ProgId, FT.FriendlyName);
      First := False;
    end;
    UpdateExtension(Ext, ProgId, FT.MimeType, FT.PerceivedType);
  end;
end;

procedure AddAllFileTypes;
var
  I: Integer;
begin  
  InitializeFileTypes;
  
  for I := 0 to High(FileTypes) do
    AddType(FileTypes[I]);
end;

procedure AddFileAssociations;
begin  
  MpvPath := ExpandConstant('{app}\mpv.exe');
  MpvArgs := '';
  IconPath := MpvPath;
  
  WizardForm.StatusLabel.Caption := 'Registering File Associations...';
  WizardForm.StatusLabel.Update;
  
  AddAllFileTypes
end;

// Uninstall Section
procedure DeleteOpenWithProgIds;
var
  SubKeys, ValueNames: TArrayOfString;
  OpenWithKey, ValueName: string;
  I, J: Integer;
begin
  // Delete all OpenWithProgIds referencing ProgIds that start with io.mpv
  if RegGetSubkeyNames(HKA, ClassesRootKey, SubKeys) then
    for I := 0 to GetArrayLength(SubKeys) - 1 do
    begin
      OpenWithKey := ClassesRootKey + '\' + SubKeys[I] + '\OpenWithProgIds';
      if RegGetValueNames(HKA, OpenWithKey, ValueNames) then
        for J := 0 to GetArrayLength(ValueNames) - 1 do
        begin
          ValueName := ValueNames[J];
          if Copy(ValueName, 1, 6) = 'io.mpv' then
            RegDeleteValue(HKA, OpenWithKey, ValueName);
        end;
    end;
end;

procedure DeleteProgIds;
var
  SubKeys: TArrayOfString;
  KeyName: string;
  I: Integer;
begin
  // Delete all ProgIDs starting with io.mpv
  if RegGetSubkeyNames(HKA, ClassesRootKey, SubKeys) then
    for I := GetArrayLength(SubKeys) - 1 downto 0 do
    begin
      KeyName := SubKeys[I];
      if Copy(KeyName, 1, 6) = 'io.mpv' then
        RegDeleteKeyIncludingSubkeys(HKA, ClassesRootKey + '\' + KeyName);
    end;
end;

procedure RemoveFileAssociations;
begin  
  // Delete only io.mpv* values in OpenWithProgIds under all extensions
  DeleteOpenWithProgIds;
  
  // Delete all io.mpv* ProgID keys
  DeleteProgIds;
end;