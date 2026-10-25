unit IDE25BuildService;

interface

uses
  SysUtils, IDE25Services, IDE25Process;

type
  TIDE25BuildRequest = record
    Compiler: string;
    Arguments: string;
    WorkingDirectory: string;
    class function Empty: TIDE25BuildRequest; static;
  end;

  TIDE25BuildResult = record
    Success: Boolean;
    ExitCode: Cardinal;
    OutputText: string;
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
    function Build(const Request: TIDE25BuildRequest): TIDE25BuildResult;
  end;

implementation

class function TIDE25BuildRequest.Empty: TIDE25BuildRequest;
begin
  Result.Compiler := '';
  Result.Arguments := '';
  Result.WorkingDirectory := '';
end;

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
  FState := ssRunning;
end;

procedure TIDE25BuildService.Stop;
begin
  FState := ssStopped;
end;

function TIDE25BuildService.Build(const Request: TIDE25BuildRequest): TIDE25BuildResult;
var
  P: TIDE25ProcessResult;
begin
  Result.Success := False;
  Result.ExitCode := Cardinal(-1);
  Result.OutputText := '';
  Result.ErrorText := '';
  if Request.Compiler = '' then
  begin
    Result.ErrorText := 'No compiler executable was specified.';
    Exit;
  end;
  P := IDE25RunProcess(Request.Compiler, Request.Arguments, Request.WorkingDirectory);
  Result.Success := P.Success;
  Result.ExitCode := P.ExitCode;
  Result.OutputText := P.OutputText;
  Result.ErrorText := P.ErrorText;
end;

end.
