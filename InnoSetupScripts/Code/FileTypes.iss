type
  TFileType = record
    MimeType: string;
    PerceivedType: string;
    FriendlyName: string;
    Extensions: array of string;
  end;

var
  FileTypes: array of TFileType;
  MpvPath: string;
  MpvArgs: string;
  IconPath: string;

function NewFileType(const AMime, APerceived, AFriendly: string;
  const AExt: array of string): TFileType;
var
  I: Integer;
begin
  Result.MimeType      := AMime;
  Result.PerceivedType := APerceived;
  Result.FriendlyName  := AFriendly;

  SetLength(Result.Extensions, Length(AExt));
  for I := 0 to High(AExt) do
    Result.Extensions[I] := AExt[I];
end;

procedure InitializeFileTypes;
begin
  SetLength(FileTypes, 84);  // Adjust if more formats are added

  // DVD/Blu-ray audio formats
  FileTypes[0] := NewFileType('audio/ac3', 'audio', 'AC-3 Audio', ['.ac3', '.a52']);
  FileTypes[1] := NewFileType('audio/eac3', 'audio', 'E-AC-3 Audio', ['.eac3']);
  FileTypes[2] := NewFileType('audio/vnd.dolby.mlp', 'audio', 'MLP Audio', ['.mlp']);
  FileTypes[3] := NewFileType('audio/vnd.dts', 'audio', 'DTS Audio', ['.dts']);
  FileTypes[4] := NewFileType('audio/vnd.dts.hd', 'audio', 'DTS-HD Audio', ['.dts-hd', '.dtshd']);
  FileTypes[5] := NewFileType('', 'audio', 'TrueHD Audio', ['.true-hd', '.thd', '.truehd', '.thd+ac3']);
  FileTypes[6] := NewFileType('', 'audio', 'True Audio', ['.tta']);

  // Uncompressed formats
  FileTypes[7]  := NewFileType('', 'audio', 'PCM Audio', ['.pcm']);
  FileTypes[8]  := NewFileType('audio/wav', 'audio', 'Wave Audio', ['.wav']);
  FileTypes[9]  := NewFileType('audio/aiff', 'audio', 'AIFF Audio', ['.aiff', '.aif', '.aifc']);
  FileTypes[10] := NewFileType('audio/amr', 'audio', 'AMR Audio', ['.amr']);
  FileTypes[11] := NewFileType('audio/amr-wb', 'audio', 'AMR-WB Audio', ['.awb']);
  FileTypes[12] := NewFileType('audio/basic', 'audio', 'AU Audio', ['.au', '.snd']);
  FileTypes[13] := NewFileType('', 'audio', 'Linear PCM Audio', ['.lpcm']);
  FileTypes[14] := NewFileType('', 'video', 'Raw YUV Video', ['.yuv']);
  FileTypes[15] := NewFileType('', 'video', 'YUV4MPEG2 Video', ['.y4m']);
  
  // Free lossless formats
  FileTypes[16] := NewFileType('audio/x-ape', 'audio', 'Monkey''s Audio', ['.ape']);
  FileTypes[17] := NewFileType('audio/x-wavpack', 'audio', 'WavPack Audio', ['.wv']);
  FileTypes[18] := NewFileType('audio/x-shorten', 'audio', 'Shorten Audio', ['.shn']);

  // MPEG formats
  FileTypes[19] := NewFileType('video/vnd.dlna.mpeg-tts', 'video', 'MPEG-2 Transport Stream', ['.m2ts', '.m2t', '.mts', '.mtv', '.ts', '.tsv', '.tsa', '.tts', '.trp']);
  FileTypes[20] := NewFileType('audio/vnd.dlna.adts', 'audio', 'ADTS Audio', ['.adts', '.adt']);
  FileTypes[21] := NewFileType('audio/mpeg', 'audio', 'MPEG Audio', ['.mpa', '.m1a', '.m2a', '.mp1', '.mp2']);
  FileTypes[22] := NewFileType('audio/mpeg', 'audio', 'MP3 Audio', ['.mp3']);
  FileTypes[23] := NewFileType('video/mpeg', 'video', 'MPEG Video', ['.mpeg', '.mpg', '.mpe', '.mpeg2', '.m1v', '.m2v', '.mp2v', '.mpv', '.mpv2', '.mod', '.tod']);
  FileTypes[24] := NewFileType('video/dvd', 'video', 'Video Object', ['.vob', '.vro']);
  FileTypes[25] := NewFileType('', 'video', 'Enhanced VOB', ['.evob', '.evo']);
  FileTypes[26] := NewFileType('video/mp4', 'video', 'MPEG-4 Video', ['.mpeg4', '.m4v', '.mp4', '.mp4v', '.mpg4']);
  FileTypes[27] := NewFileType('audio/mp4', 'audio', 'MPEG-4 Audio', ['.m4a']);
  FileTypes[28] := NewFileType('audio/aac', 'audio', 'Raw AAC Audio', ['.aac']);
  FileTypes[29] := NewFileType('', 'video', 'Raw H.264/AVC Video', ['.h264', '.avc', '.x264', '.264']);
  FileTypes[30] := NewFileType('', 'video', 'Raw H.265/HEVC Video', ['.hevc', '.h265', '.x265', '.265']);
  
  // Xiph formats
  FileTypes[31] := NewFileType('audio/flac', 'audio', 'FLAC Audio', ['.flac']);
  FileTypes[32] := NewFileType('audio/ogg', 'audio', 'Ogg Audio', ['.oga', '.ogg']);
  FileTypes[33] := NewFileType('audio/ogg', 'audio', 'Opus Audio', ['.opus']);
  FileTypes[34] := NewFileType('audio/ogg', 'audio', 'Speex Audio', ['.spx']);
  FileTypes[35] := NewFileType('video/ogg', 'video', 'Ogg Video', ['.ogv', '.ogm']);
  FileTypes[36] := NewFileType('application/ogg', 'video', 'Ogg Video', ['.ogx']);

  // Matroska formats
  FileTypes[37] := NewFileType('video/x-matroska', 'video', 'Matroska Video', ['.mkv']);
  FileTypes[38] := NewFileType('video/x-matroska', 'video', 'Matroska 3D Video', ['.mk3d']);
  FileTypes[39] := NewFileType('audio/x-matroska', 'audio', 'Matroska Audio', ['.mka']);
  FileTypes[40] := NewFileType('video/webm', 'video', 'WebM Video', ['.webm']);
  FileTypes[41] := NewFileType('audio/webm', 'audio', 'WebM Audio', ['.weba']);
  
  // Misc formats
  FileTypes[42] := NewFileType('video/avi', 'video', 'Video Clip', ['.avi', '.vfw']);
  FileTypes[43] := NewFileType('', 'video', 'DivX Video', ['.divx']);
  FileTypes[44] := NewFileType('', 'video', '3ivx Video', ['.3iv']);
  FileTypes[45] := NewFileType('', 'video', 'XVID Video', ['.xvid']);
  FileTypes[46] := NewFileType('', 'video', 'NUT Video', ['.nut']);
  FileTypes[47] := NewFileType('video/flc', 'video', 'FLIC Video', ['.flic', '.fli', '.flc']);
  FileTypes[48] := NewFileType('', 'video', 'Nullsoft Streaming Video', ['.nsv']);
  FileTypes[49] := NewFileType('application/gxf', 'video', 'General Exchange Format', ['.gxf']);
  FileTypes[50] := NewFileType('application/mxf', 'video', 'Material Exchange Format', ['.mxf']);
  
  // Windows Media formats
  FileTypes[51] := NewFileType('audio/x-ms-wma', 'audio', 'Windows Media Audio', ['.wma']);
  FileTypes[52] := NewFileType('video/x-ms-wm', 'video', 'Windows Media Video', ['.wm']);
  FileTypes[53] := NewFileType('video/x-ms-wmv', 'video', 'Windows Media Video', ['.wmv']);
  FileTypes[54] := NewFileType('video/x-ms-asf', 'video', 'Windows Media Video', ['.asf']);
  FileTypes[55] := NewFileType('', 'video', 'Microsoft Recorded TV Show', ['.dvr-ms', '.dvr']);
  FileTypes[56] := NewFileType('', 'video', 'Windows Recorded TV Show', ['.wtv']);
  
  // DV formats
  FileTypes[57] := NewFileType('', 'video', 'DV Video', ['.dv', '.hdv']);
  
  // Flash Video formats
  FileTypes[58] := NewFileType('video/x-flv', 'video', 'Flash Video', ['.flv']);
  FileTypes[59] := NewFileType('video/mp4', 'video', 'Flash Video', ['.f4v']);
  FileTypes[60] := NewFileType('audio/mp4', 'audio', 'Flash Audio', ['.f4a']);
  
  // QuickTime formats
  FileTypes[61] := NewFileType('video/quicktime', 'video', 'QuickTime Video', ['.qt', '.mov']);
  FileTypes[62] := NewFileType('video/quicktime', 'video', 'QuickTime HD Video', ['.hdmov']);
  
  // Real Media formats
  FileTypes[63] := NewFileType('application/vnd.rn-realmedia', 'video', 'Real Media Video', ['.rm']);
  FileTypes[64] := NewFileType('application/vnd.rn-realmedia-vbr', 'video', 'Real Media Video', ['.rmvb']);
  FileTypes[65] := NewFileType('audio/vnd.rn-realaudio', 'audio', 'Real Media Audio', ['.ra', '.ram']);
  
  // 3GPP formats
  FileTypes[66] := NewFileType('audio/3gpp', 'audio', '3GPP Audio', ['.3ga']);
  FileTypes[67] := NewFileType('audio/3gpp2', 'audio', '3GPP Audio', ['.3ga2']);
  FileTypes[68] := NewFileType('video/3gpp', 'video', '3GPP Video', ['.3gpp', '.3gp']);
  FileTypes[69] := NewFileType('video/3gpp2', 'video', '3GPP Video', ['.3gp2', '.3g2']);
  
  // Video game formats
  FileTypes[70] := NewFileType('', 'audio', 'AY Audio', ['.ay']);
  FileTypes[71] := NewFileType('', 'audio', 'GBS Audio', ['.gbs']);
  FileTypes[72] := NewFileType('', 'audio', 'GYM Audio', ['.gym']);
  FileTypes[73] := NewFileType('', 'audio', 'HES Audio', ['.hes']);
  FileTypes[74] := NewFileType('', 'audio', 'KSS Audio', ['.kss']);
  FileTypes[75] := NewFileType('', 'audio', 'NSF Audio', ['.nsf']);
  FileTypes[76] := NewFileType('', 'audio', 'NSFE Audio', ['.nsfe']);
  FileTypes[77] := NewFileType('', 'audio', 'SAP Audio', ['.sap']);
  FileTypes[78] := NewFileType('', 'audio', 'SPC Audio', ['.spc']);
  FileTypes[79] := NewFileType('', 'audio', 'VGM Audio', ['.vgm']);
  FileTypes[80] := NewFileType('', 'audio', 'VGZ Audio', ['.vgz']);
  
  // Playlist formats
  FileTypes[81] := NewFileType('audio/x-mpegurl', 'audio', 'M3U Playlist', ['.m3u', '.m3u8']);
  FileTypes[82] := NewFileType('audio/x-scpls', 'audio', 'PLS Playlist', ['.pls']);
  FileTypes[83] := NewFileType('', 'audio', 'CUE Sheet', ['.cue']);
end;