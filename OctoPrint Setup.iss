; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "OctoPrint"
#ifndef OctoPrintVersion
  #define OctoPrintVersion "unknown"
#endif
#define MyAppVersion OctoPrintVersion
#define MyAppPublisher "OctoPrint"
#define MyAppURL "https://www.octoprint.org/"
#define MyAppExeName "octoprint.exe" 
#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"  

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{333BC575-A27C-4E6C-BE2B-59E5AEE715F3}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName=C:\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=False
OutputDir=Output
OutputBaseFilename=OctoPrint Setup {#MyAppVersion}
SetupIconFile=OctoPrint.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableReadyPage=True
UninstallDisplayIcon={app}\OctoPrint.ico    
WizardImageFile=WizModernImage-OctoPrint*.bmp
WizardSmallImageFile=WizModernSmallImage-OctoPrint*.bmp
DisableWelcomePage=False
DisableDirPage=False
Uninstallable=WizardIsComponentSelected('initial_instance')

[Run]
Filename: "{app}\OctoPrintService{code:GetOctoPrintPort}.exe"; Parameters: "install"; WorkingDir: "{app}"; Flags: runhidden shellexec postinstall waituntilidle; Description: "Install Service"; StatusMsg: "Installing Service for port {code:GetOctoPrintPort}"
Filename: "{app}\OctoPrintService{code:GetOctoPrintPort}.exe"; Parameters: "start"; WorkingDir: "{app}"; Flags: runhidden shellexec postinstall waituntilidle; Description: "Start Service"; StatusMsg: "Starting Service on port {code:GetOctoPrintPort}"

[UninstallRun]
;Filename: "{app}\OctoPrintService{code: GetOctoPrintPort}.exe"; Parameters: "stop --no-elevate --no-wait --force"; WorkingDir: "{app}"; Flags: runhidden
;Filename: "{app}\OctoPrintService{code: GetOctoPrintPort}.exe"; Parameters: "uninstall --no-elevate"; WorkingDir: "{app}"; Flags: runhidden

[UninstallDelete]
;Type: filesandordirs; Name: "{app}\*"

[Registry]
Root: "HKLM"; Subkey: "Software\{#MyAppName}\Instances"; ValueType: string; ValueName: "{code:GetOctoPrintPort}"; ValueData: "{code:GetServiceWrapperPath}"; Flags: uninsdeletekeyifempty

[Components]
Name: "initial_instance"; Description: "First Time Install"; Flags: exclusive
Name: "add_instance"; Description: "Add New Instance"; Flags: exclusive

[ThirdParty]
UseRelativePaths=True

[Code]
function InitializeSetup: Boolean; 
begin 
  Dependency_AddVC2013;
  Result := True;          
end;

var
  InputQueryWizardPage: TInputQueryWizardPage;
  DataDirPage: TInputDirWizardPage;
  ComponentSelectPage: TWizardPage;
  WrapperPath: String;
  OctoPrintPort: String;
  OctoPrintBasedir: String;

function GetServiceWrapperPath(Param: string): String;
begin
  Result := WrapperPath;
end;

function GetOctoPrintPort(Param: string): String;
begin
  Result := OctoPrintPort;
end; 

function GetOctoPrintBasedir(Param: string): String;
begin
  Result := OctoPrintBasedir;
end;

procedure InitializeWizard;
begin
// Custom Component Select Page
  ComponentSelectPage := CreateCustomPage(wpWelcome, 'OctoPrint Setup', 'What type of installation?');
  WizardForm.ComponentsList.Parent := ComponentSelectPage.Surface;

// OctoPrint Port Dialog Page     
  InputQueryWizardPage := CreateInputQueryPage(ComponentSelectPage.ID, 'OctoPrint Setup', 'What port should OctoPrint use?', 'Enter the port that OctoPrint will listen on for web connections, then click Next.');
  InputQueryWizardPage.Add('Port:', False);
  InputQueryWizardPage.Values[0] := GetPreviousData('OctoPrintPort', '5000');
  
// OctoPrint Basedir Selection Page  
  DataDirPage := CreateInputDirPage(wpSelectDir,
    'OctoPrint Setup', 'Where should OctoPrint data files be installed?',
    'Select the folder in which OctoPrint will store uploads, configs, and other data files, then click Next.',
    False, '');
  DataDirPage.Add('Basedir Path:');
  DataDirPage.Values[0] := GetPreviousData('DataDir', WizardDirValue() + '\basedir');

// Initialize contstants
  OctoPrintPort := InputQueryWizardPage.Values[0];  
  WrapperPath := WizardDirValue() + '\OctoPrintService' + OctoPrintPort + '.exe';
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;

  if PageID = wpSelectComponents then
  begin
    Result := True;
  end;

  if (PageID = wpSelectDir) and WizardIsComponentSelected('add_instance') then
  begin
    Result := True;
  end;
end;


function NextButtonClick(CurPageID: Integer): Boolean;
begin   
  if CurPageID = InputQueryWizardPage.ID then 
  begin
    OctoPrintPort := InputQueryWizardPage.Values[0];
    WrapperPath := WizardDirValue() + '\OctoPrintService' + OctoPrintPort + '.exe';
  end;
  if (CurPageID = wpSelectDir) or ((CurPageID = InputQueryWizardPage.ID) and IsComponentSelected('add_instance')) then 
  begin
    DataDirPage.Values[0] := WizardDirValue() + '\basedir\' + OctoPrintPort;
    WrapperPath := WizardDirValue() + '\OctoPrintService' + OctoPrintPort + '.exe';
    OctoPrintBasedir := DataDirPage.Values[0];
  end;
  if CurPageID = DataDirPage.ID then
  begin
    OctoPrintBasedir := DataDirPage.Values[0];
  end;
  Result := True;
end;

procedure rename_config();
var
  UnicodeStr: string;
  ANSIStr: AnsiString;
begin
  if LoadStringFromFile(ExpandConstant(CurrentFilename), ANSIStr) then
  begin
    UnicodeStr := String(ANSIStr);
    if StringChangeEx(UnicodeStr, '####APPDIR####', WrapperPath, True) > 0 then
      if DirExists(ExpandConstant(OctoPrintBasedir)) = False then
        ForceDirectories(ExpandConstant(OctoPrintBasedir));
      SaveStringToFile(ExpandConstant(OctoPrintBasedir + '\config.yaml'), AnsiString(UnicodeStr), False);
  end;
end; 

procedure rename_service_wrapper();
var
  FolderPath: string;
begin
  FolderPath := ExpandConstant('{app}\Service Control\' + OctoPrintPort);
  FileCopy(ExpandConstant(CurrentFilename), WrapperPath, False); 
  ForceDirectories(FolderPath);
  CreateShellLink(FolderPath + '\Install OctoPrint Service.lnk', 'Install the OctoPrint service on port ' + OctoPrintPort, ExpandConstant(WrapperPath), 'install', ExpandConstant('{app}'), ExpandConstant('{app}\OctoPrint.ico'), 0, SW_SHOWNORMAL);  
  CreateShellLink(FolderPath + '\Restart OctoPrint Service.lnk', 'Restart the OctoPrint service on port ' + OctoPrintPort, ExpandConstant(WrapperPath), 'restart!', ExpandConstant('{app}'), ExpandConstant('{app}\OctoPrint.ico'), 0, SW_SHOWNORMAL);       
  CreateShellLink(FolderPath + '\Start OctoPrint Service.lnk', 'Start the OctoPrint service on port ' + OctoPrintPort, ExpandConstant(WrapperPath), 'start', ExpandConstant('{app}'), ExpandConstant('{app}\OctoPrint.ico'), 0, SW_SHOWNORMAL);      
  CreateShellLink(FolderPath + '\Stop OctoPrint Service.lnk', 'Stop the OctoPrint service on port ' + OctoPrintPort, ExpandConstant(WrapperPath), 'stop', ExpandConstant('{app}'), ExpandConstant('{app}\OctoPrint.ico'), 0, SW_SHOWNORMAL);       
  CreateShellLink(FolderPath + '\Uninstall OctoPrint Service.lnk', 'Uninstall the OctoPrint service on port ' + OctoPrintPort, ExpandConstant(WrapperPath), 'uninstall', ExpandConstant('{app}'), ExpandConstant('{app}\OctoPrint.ico'), 0, SW_SHOWNORMAL);
end;

procedure update_service_config(); 
var
  UnicodeStr: string;
  ANSIStr: AnsiString;
begin
  if LoadStringFromFile(ExpandConstant('{app}\OctoPrintService.xml'), ANSIStr) then
  begin
    UnicodeStr := String(ANSIStr);
    StringChangeEx(UnicodeStr, '####EXEPATH####', ExpandConstant('{app}\WPy64-31040\python-3.10.4.amd64\Scripts\octoprint.exe'), True) 
    StringChangeEx(UnicodeStr, '####BASEDIR####', DataDirPage.Values[0], True) 
    StringChangeEx(UnicodeStr, '####PORT####', InputQueryWizardPage.Values[0], True)
    SaveStringToFile(ExpandConstant('{app}\OctoPrintService' + OctoPrintPort + '.xml'), AnsiString(UnicodeStr), False);
  end;
end;

function GetOctoPrintInstances(): TArrayOfString;
var
  Names: TArrayOfString;
  I: Integer;
  S: String;
begin
  if RegGetValueNames(HKEY_CURRENT_USER, 'Control Panel\Mouse', Names) then
  begin
    S := '';
    for I := 0 to GetArrayLength(Names)-1 do
      S := S + Names[I] + #13#10;
    MsgBox('List of values:'#13#10#13#10 + S, mbInformation, MB_OK);
  end else
  begin
    // add any code to handle failure here
  end;
  Result := Names
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  { Store the settings so we can restore them next time }
  SetPreviousData(PreviousDataKey, 'DataDir', DataDirPage.Values[0]);  
  SetPreviousData(PreviousDataKey, 'OctoPrintPort', InputQueryWizardPage.Values[0]);
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "WPy64-31040\*"; DestDir: "{app}\WPy64-31040"; Flags: recursesubdirs createallsubdirs ignoreversion onlyifdoesntexist; Components: initial_instance
Source: "OctoPrint.ico"; DestDir: "{app}"; Components: initial_instance
Source: "OctoPrintService.exe"; DestDir: "{app}"; Components: initial_instance add_instance; AfterInstall: rename_service_wrapper
Source: "OctoPrintService.xml"; DestDir: "{app}"; Flags: ignoreversion; Components: initial_instance add_instance; AfterInstall: update_service_config
Source: "config.yaml"; DestDir: "{app}"; Flags: ignoreversion; Components: initial_instance add_instance; AfterInstall: rename_config

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,OctoPrint Website}"; Filename: "{#MyAppURL}"
Name: "{group}\OctoPrint Service Control"; Filename: "{app}\Service Control"; WorkingDir: "{app}\Service Control"
