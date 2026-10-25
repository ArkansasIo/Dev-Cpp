unit IDE25LSP;

interface

uses
  SysUtils, Classes, IDE25Services;

type
  TIDE25Position = record
    Line: Integer;
    Character: Integer;
  end;

  TIDE25Diagnostic = record
    FileName: string;
    Line: Integer;
    Character: Integer;
    MessageText: string;
    Severity: Integer;
  end;

  TIDE25LanguageService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    procedure Start;
    procedure Stop;
    function SupportsFile(const FileName: string): Boolean;
    function CreatePosition(ALine, ACharacter: Integer): TIDE25Position;
  end;

implementation

function TIDE25LanguageService.GetName: string;
begin
  Result := 'Language Service';
end;

function TIDE25LanguageService.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25LanguageService.Start;
begin
  FState := ssRunning;
end;

procedure TIDE25LanguageService.Stop;
begin
  FState := ssStopped;
end;

function TIDE25LanguageService.SupportsFile(const FileName: string): Boolean;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(FileName));
  Result := Ext = '.c';
  Result := Result or (Ext = '.cc');
  Result := Result or (Ext = '.cpp');
  Result := Result or (Ext = '.cxx');
  Result := Result or (Ext = '.h');
  Result := Result or (Ext = '.hpp');
  Result := Result or (Ext = '.hxx');
end;

function TIDE25LanguageService.CreatePosition(ALine, ACharacter: Integer): TIDE25Position;
begin
  Result.Line := ALine;
  Result.Character := ACharacter;
end;

end.
