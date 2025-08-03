[Setup]
AppName=PreHarness
AppVersion=1.0.0
DefaultDirName={commonpf}\PreHarness
DefaultGroupName=PreHarness
OutputDir=dist-installer
OutputBaseFilename=PreHarnessInstaller
Compression=lzma
SolidCompression=yes

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Files]
; Flutterアプリのバイナリ群（Releaseフォルダ内）
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion
; VC++ ランタイム
Source: "installer\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; Check: NeedsVC
Filename: "{app}\preharness.exe"; Description: "PreHarness を起動"; Flags: nowait postinstall skipifsilent

[Code]
function NeedsVC(): Boolean;
begin
  // 適当なDLLが存在するかどうかで VC++ ランタイムの有無を判定
  Result := not FileExists(ExpandConstant('{sys}\vcruntime140.dll'));
end;
