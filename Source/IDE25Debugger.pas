unit IDE25Debugger;

interface

uses
  SysUtils, IDE25Services;

type
  TIDE25Breakpoint = record
    FileName: string;
    Line: Integer;
    Enabled: Boolean;
  end;

  TIDE25DebuggerService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
    FAttached: Boolean;
    FBreakpoints: array of TIDE25Breakpoint;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    procedure Start;
    procedure Stop;
    function Attach(const AExecutable: string): Boolean;
    procedure Detach;
    function AddBreakpoint(const AFileName: string; ALine: Integer): Integer;
    function BreakpointCount: Integer;
  end;

implementation

function TIDE25DebuggerService.GetName: string;
begin
  Result := 'Debugger Service';
end;

function TIDE25DebuggerService.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25DebuggerService.Start;
begin
  FState := ssStarting;
  FState := ssRunning;
end;

procedure TIDE25DebuggerService.Stop;
begin
  FState := ssStopping;
  Detach;
  FState := ssStopped;
end;

function TIDE25DebuggerService.Attach(const AExecutable: string): Boolean;
begin
  Result := FileExists(AExecutable);
  FAttached := Result;
end;

procedure TIDE25DebuggerService.Detach;
begin
  FAttached := False;
  SetLength(FBreakpoints, 0);
end;

function TIDE25DebuggerService.AddBreakpoint(const AFileName: string; ALine: Integer): Integer;
var
  B: TIDE25Breakpoint;
begin
  if (AFileName = '') or (ALine < 1) then
    Exit(-1);
  B.FileName := AFileName;
  B.Line := ALine;
  B.Enabled := True;
  SetLength(FBreakpoints, Length(FBreakpoints) + 1);
  FBreakpoints[High(FBreakpoints)] := B;
  Result := High(FBreakpoints);
end;

function TIDE25DebuggerService.BreakpointCount: Integer;
begin
  Result := Length(FBreakpoints);
end;

end.
