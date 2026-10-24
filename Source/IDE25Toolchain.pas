unit IDE25Toolchain;

interface

uses
  SysUtils, IDE25Services;

type
  TIDE25ToolchainKind = (tkGCC, tkClang, tkMSVC, tkUnknown);

  TIDE25ToolchainInfo = record
    Name: string;
    Kind: TIDE25ToolchainKind;
    CompilerPath: string;
    LinkerPath: string;
    DebuggerPath: string;
    Version: string;
    class function Empty: TIDE25ToolchainInfo; static;
  end;

  TIDE25ToolchainService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
    FToolchains: array of TIDE25ToolchainInfo;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    procedure Start;
    procedure Stop;
    procedure Discover;
    function Count: Integer;
    function GetToolchain(Index: Integer): TIDE25ToolchainInfo;
  end;

implementation

class function TIDE25ToolchainInfo.Empty: TIDE25ToolchainInfo;
begin
  Result.Name := '';
  Result.Kind := tkUnknown;
  Result.CompilerPath := '';
  Result.LinkerPath := '';
  Result.DebuggerPath := '';
  Result.Version := '';
end;

function TIDE25ToolchainService.GetName: string;
begin
  Result := 'Toolchain Service';
end;

function TIDE25ToolchainService.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25ToolchainService.Start;
begin
  FState := ssStarting;
  Discover;
  FState := ssRunning;
end;

procedure TIDE25ToolchainService.Stop;
begin
  FState := ssStopping;
  SetLength(FToolchains, 0);
  FState := ssStopped;
end;

procedure TIDE25ToolchainService.Discover;
var
  Path: string;
  Info: TIDE25ToolchainInfo;
begin
  SetLength(FToolchains, 0);
  Path := GetEnvironmentVariable('PATH');
  if Path = '' then
    Exit;

  { Discovery is deliberately conservative in the alpha build. Actual
    compiler probing can be layered on top without changing this contract. }
  Info := TIDE25ToolchainInfo.Empty;
  Info.Name := 'PATH toolchain environment';
  Info.Kind := tkUnknown;
  Info.CompilerPath := Path;
  SetLength(FToolchains, 1);
  FToolchains[0] := Info;
end;

function TIDE25ToolchainService.Count: Integer;
begin
  Result := Length(FToolchains);
end;

function TIDE25ToolchainService.GetToolchain(Index: Integer): TIDE25ToolchainInfo;
begin
  if (Index < 0) or (Index >= Length(FToolchains)) then
    Result := TIDE25ToolchainInfo.Empty
  else
    Result := FToolchains[Index];
end;

end.
