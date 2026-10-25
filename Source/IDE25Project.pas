unit IDE25Project;

interface

uses
  Classes, SysUtils, IDE25Services;

type
  TIDE25ProjectFile = record
    FileName: string;
    FileType: string;
  end;

  TIDE25ProjectService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
    FProjectFile: string;
    FFiles: array of TIDE25ProjectFile;
    procedure ClearFiles;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    procedure Start;
    procedure Stop;
    function OpenProject(const AFileName: string): Boolean;
    function AddFile(const AFileName: string): Boolean;
    function FileCount: Integer;
    function GetFile(Index: Integer): TIDE25ProjectFile;
    property ProjectFile: string read FProjectFile;
  end;

implementation

function TIDE25ProjectService.GetName: string;
begin
  Result := 'Project Service';
end;

function TIDE25ProjectService.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25ProjectService.Start;
begin
  FState := ssStarting;
  FState := ssRunning;
end;

procedure TIDE25ProjectService.Stop;
begin
  FState := ssStopping;
  FProjectFile := '';
  ClearFiles;
  FState := ssStopped;
end;

procedure TIDE25ProjectService.ClearFiles;
begin
  SetLength(FFiles, 0);
end;

function TIDE25ProjectService.OpenProject(const AFileName: string): Boolean;
begin
  Result := FileExists(AFileName);
  if not Result then
    Exit;
  FProjectFile := ExpandFileName(AFileName);
  ClearFiles;
end;

function TIDE25ProjectService.AddFile(const AFileName: string): Boolean;
var
  Item: TIDE25ProjectFile;
  I: Integer;
begin
  Result := FileExists(AFileName);
  if not Result then
    Exit;

  for I := 0 to High(FFiles) do
    if SameText(FFiles[I].FileName, AFileName) then
      Exit(True);

  Item.FileName := ExpandFileName(AFileName);
  Item.FileType := LowerCase(ExtractFileExt(AFileName));
  SetLength(FFiles, Length(FFiles) + 1);
  FFiles[High(FFiles)] := Item;
  Result := True;
end;

function TIDE25ProjectService.FileCount: Integer;
begin
  Result := Length(FFiles);
end;

function TIDE25ProjectService.GetFile(Index: Integer): TIDE25ProjectFile;
begin
  if (Index < 0) or (Index >= Length(FFiles)) then
  begin
    Result.FileName := '';
    Result.FileType := '';
  end
  else
    Result := FFiles[Index];
end;

end.
