unit IDE25Build;

interface

uses
  Classes, SysUtils, IDE25Services;

type
  TIDE25BuildResult = record
    Success: Boolean;
    ExitCode: Integer;
    Output: string;
    ErrorText: string;
  end;

  TIDE25BuildService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    procedure Start;
    procedure Stop;
    function Build(const ACommandLine, AWorkingDirectory: string): TIDE25BuildResult;
  end;

implementation

function TIDE25BuildService.GetName: string;
begin
  Result := 'Build Service';
end;

function TIDE25BuildService.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25BuildService.Start;
begin
  FState := ssStarting;
  FState := ssRunning;
end;

procedure TIDE25BuildService.Stop;
begin
  FState := ssStopping;
  FState := ssStopped;
end;

function TIDE25BuildService.Build(const ACommandLine, AWorkingDirectory: string): TIDE25BuildResult;
begin
  Result.Success := False;
  Result.ExitCode := -1;
  Result.Output := '';
  Result.ErrorText := '';

  if Trim(ACommandLine) = '' then
  begin
    Result.ErrorText := 'Build command is empty.';
    Exit;
  end;

  { The alpha service intentionally exposes the execution contract without
    embedding a shell implementation. The existing IDE build pipeline remains
    authoritative until process execution is migrated behind this service. }
  Result.ErrorText := 'Process execution adapter is not enabled in Alpha 1.';
end;

end.
