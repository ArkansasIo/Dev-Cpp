unit IDE25Settings;

interface

uses
  SysUtils, Classes, IniFiles;

type
  TIDE25Settings = class
  private
    FFileName: string;
    FIni: TMemIniFile;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    function ReadString(const Section, Key, Default: string): string;
    procedure WriteString(const Section, Key, Value: string);
    function ReadBool(const Section, Key: string; Default: Boolean): Boolean;
    procedure WriteBool(const Section, Key: string; Value: Boolean);
    property FileName: string read FFileName;
  end;

implementation

constructor TIDE25Settings.Create(const FileName: string);
begin
  inherited Create;
  FFileName := FileName;
  FIni := TMemIniFile.Create(FileName);
end;

destructor TIDE25Settings.Destroy;
begin
  FIni.Free;
  inherited;
end;

procedure TIDE25Settings.Load;
begin
  FIni.Clear;
  if FileExists(FFileName) then
    FIni.LoadFromFile(FFileName);
end;

procedure TIDE25Settings.Save;
begin
  ForceDirectories(ExtractFilePath(FFileName));
  FIni.UpdateFile;
end;

function TIDE25Settings.ReadString(const Section, Key, Default: string): string;
begin
  Result := FIni.ReadString(Section, Key, Default);
end;

procedure TIDE25Settings.WriteString(const Section, Key, Value: string);
begin
  FIni.WriteString(Section, Key, Value);
end;

function TIDE25Settings.ReadBool(const Section, Key: string; Default: Boolean): Boolean;
begin
  Result := FIni.ReadBool(Section, Key, Default);
end;

procedure TIDE25Settings.WriteBool(const Section, Key: string; Value: Boolean);
begin
  FIni.WriteBool(Section, Key, Value);
end;

end.
