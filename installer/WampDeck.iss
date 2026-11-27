; WampDeck installer (Inno Setup 6).
;
; Build:
;   "C:\Users\Sarfaraz\AppData\Local\Programs\Inno Setup 6\ISCC.exe" installer\WampDeck.iss
;
; Output:
;   dist\WampDeck-Setup.exe
;
; The installer ships the portable stack and then runs scripts\setup.ps1 to
; regenerate every config for the real install path and initialize MySQL.

#define AppName "WampDeck"
#define AppVersion "2.0.0"
#define AppPublisher "Oryx India"
#define AppExe "WampDeck.exe"

[Setup]
AppId={{8B52E02F-37B6-4039-A50A-CF7E116C0605}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName=C:\WampDeck
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
AllowNoIcons=yes
UsePreviousAppDir=yes
DirExistsWarning=no
OutputDir=dist
OutputBaseFilename=WampDeck-Setup
SetupIconFile=assets\wampdeck.ico
UninstallDisplayIcon={app}\{#AppExe}
Compression=lzma2/fast
SolidCompression=yes
LZMAUseSeparateProcess=yes
WizardStyle=modern
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=commandline
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
; Do not let Restart Manager try to close the stack. It cannot stop the PHP
; supervisor, so php-cgi is respawned mid-copy and every replacement fails
; with "DeleteFile failed; code 5". PrepareToInstall stops the stack itself.
CloseApplications=no
RestartApplications=no
VersionInfoVersion=2.0.0.4
VersionInfoDescription=WampDeck Setup
VersionInfoProductName={#AppName}
VersionInfoProductVersion=2.0.0.4
SourceDir=..
SetupLogging=yes

; Code signing is opt-in: build with
;   ISCC.exe /DSIGN /Swampdeck="<signtool command with $f>" installer\WampDeck.iss
; or use scripts\sign-installer.ps1. Without /DSIGN the build is unsigned.
#ifdef SIGN
SignTool=wampdeck
SignedUninstaller=yes
#endif

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
; Everything except user/runtime data and generated, path-specific configs.
; setup.ps1 writes the configs again for the final install directory.
;
; Every exclude starts with a backslash so it is anchored to the source root.
; Without the anchor Inno matches the pattern against the end of the path and
; would also strip nested folders such as node_modules\npm\...\dist, which
; breaks npm, corepack, PEAR and node-gyp.
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "\.git\*,\\.gitignore,\backup\*,\data\*,\logs\*,\tmp\*,\dist\*,\installer\*,\www\blog\*,\www\edupro\*,\bin\apache\include\*,\bin\apache\manual\*,\bin\apache\logs\*,\bin\nginx\logs\*,\bin\mysql\my.ini,\bin\php\8.2.12\php.ini,\bin\php\8.3.30\php.ini,\bin\cmder\config\clink_history,\bin\cmder\config\clink.log,\bin\cmder\config\user-ConEmu.xml,\etc\stack.json,\etc\extensions.json,\etc\my.ini,\etc\nginx.conf,\etc\redis.conf,\etc\php-runtime.json,\etc\ssl\*,\etc\apache\httpd.conf,\etc\apache\mod_fcgid.conf,\etc\apache\mod_php.conf,\etc\apache\sites-enabled\*"

; Extracted to {tmp} and run from PrepareToInstall; not copied into {app}.
Source: "installer\stop-running.ps1"; DestDir: "{tmp}"; Flags: dontcopy

[Dirs]
; The installer runs elevated; grant the normal user write access so the
; installed stack can create data, logs, tmp and regenerated configs.
Name: "{app}"; Permissions: users-modify
Name: "{app}\logs"; Permissions: users-modify
Name: "{app}\tmp"; Permissions: users-modify
Name: "{app}\www"; Permissions: users-modify
Name: "{app}\data"; Permissions: users-modify
Name: "{app}\backup"; Permissions: users-modify

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
; -Hosts makes setup sync the managed hosts block while Setup is still
; elevated, so .test names work on the first run without a separate UAC prompt.
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\setup.ps1"" -Hosts"; WorkingDir: "{app}"; StatusMsg: "Preparing WampDeck (configs, MySQL and hosts)..."; Flags: runhidden waituntilterminated
; Launch through Explorer instead of directly. Setup runs elevated, and
; runasoriginaluser proved unreliable on Windows 11 (the panel still came up
; elevated, so nginx/MySQL inherited admin rights and a later normal launch
; could not stop them). Explorer hands the request to the medium-integrity
; shell and starts the launcher there. The launcher also drops elevation
; itself as a second line of defence.
Filename: "powershell.exe"; Parameters: "-Sta -NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\first-run-language.ps1"""; WorkingDir: "{app}"; Description: "Choose your language"; Flags: waituntilterminated
Filename: "{win}\explorer.exe"; Parameters: """{app}\{#AppExe}"""; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Disposable runtime folders. Databases (data) and projects (www) are kept.
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\tmp"

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  Helper: String;
begin
  Result := '';
  Helper := ExpandConstant('{tmp}\stop-running.ps1');
  ExtractTemporaryFile('stop-running.ps1');

  if not Exec('powershell.exe',
              '-NoProfile -ExecutionPolicy Bypass -File "' + Helper + '" -Root "' + ExpandConstant('{app}') + '"',
              '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    Result := 'WampDeck could not run its shutdown helper. Quit WampDeck and run Setup again.';
  end
  else if ResultCode = 2 then
  begin
    Result := 'WampDeck could not stop MySQL. Quit WampDeck from the tray, then run Setup again.';
  end
  else if ResultCode <> 0 then
  begin
    Result := 'WampDeck could not stop its running services (exit code ' + IntToStr(ResultCode) + ').' + #13#10 +
              'Quit WampDeck from the tray, then run Setup again.';
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    { recursesubdirs also creates empty copies of excluded folders; drop them. }
    RemoveDir(ExpandConstant('{app}\installer'));
    RemoveDir(ExpandConstant('{app}\dist'));
    RemoveDir(ExpandConstant('{app}\backup'));
    RemoveDir(ExpandConstant('{app}\.git'));
    RemoveDir(ExpandConstant('{app}\bin\apache\include'));
    RemoveDir(ExpandConstant('{app}\bin\apache\manual'));
  end;
  if CurStep = ssDone then
  begin
    if not FileExists(ExpandConstant('{app}\etc\nginx.conf')) then
      MsgBox('The WampDeck files were installed, but the first-time setup did not finish.' + #13#10 + #13#10 +
             'Open a terminal in ' + ExpandConstant('{app}') + ' and run:' + #13#10 +
             'powershell -ExecutionPolicy Bypass -File scripts\setup.ps1',
             mbError, MB_OK);
  end;
end;
