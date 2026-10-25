unit IDE25Workspace;

interface

uses
  Classes, SysUtils, IDE25Services;

type
  TIDE25WorkspaceService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
    FRoot: string;
    FProjects: TStringList;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    function Open(const ARoot: string): Boolean;
    function AddProject(const AProjectFile: string): Boolean;
    function ProjectCount: Integer;
    function Project(Index: Integer): string;
    property Root: string read FRoot;
  end;

implementation

constructor TIDE25WorkspaceService.Create;
begin
  inherited Create;
  FProjects := TStringList.Create;
  FProjects.Sorted := True;
  FProjects.Duplicates := dupIgnore;
end;

destructor TIDE25WorkspaceService.Destroy;
begin
  FProjects.Free;
  inherited Destroy;
end;

function TIDE25WorkspaceService.GetName: string;
begin
  Result := 'Workspace Service';
end;

function TIDE25WorkspaceService.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25WorkspaceService.Start;
begin
  FState := ssStarting;
  FState := ssRunning;
end;

procedure TIDE25WorkspaceService.Stop;
begin
  FState := ssStopping;
  FRoot := '';
  FProjects.Clear;
  FState := ssStopped;
end;

function TIDE25WorkspaceService.Open(const ARoot: string): Boolean;
begin
  Result := DirectoryExists(ARoot);
  if not Result then
    Exit;
  FRoot := ExpandFileName(ARoot);
  FProjects.Clear;
end;

function TIDE25WorkspaceService.AddProject(const AProjectFile: string): Boolean;
var
  FullName: string;
  I: Integer;
begin
  Result := FileExists(AProjectFile);
  if not Result then
    Exit;
  FullName := ExpandFileName(AProjectFile);
  I := FProjects.Add(FullName);
  Result := I >= 0;
end;

function TIDE25WorkspaceService.ProjectCount: Integer;
begin
  Result := FProjects.Count;
end;

function TIDE25WorkspaceService.Project(Index: Integer): string;
begin
  if (Index < 0) or (Index >= FProjects.Count) then
    Result := ''
  else
    Result := FProjects[Index];
end;

end.
