unit IDE25Language;

interface

uses
  SysUtils, IDE25Services;

type
  TIDE25Language = (ilUnknown, ilC, ilCpp);

  TIDE25LanguageService = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    procedure Start;
    procedure Stop;
    function Detect(const AFileName: string): TIDE25Language;
    function LanguageName(ALanguage: TIDE25Language): string;
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
  FState := ssStarting;
  FState := ssRunning;
end;

procedure TIDE25LanguageService.Stop;
begin
  FState := ssStopping;
  FState := ssStopped;
end;

function TIDE25LanguageService.Detect(const AFileName: string): TIDE25Language;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  if Ext = '.c' then
    Result := ilC
  else if (Ext = '.cc') or (Ext = '.cpp') or (Ext = '.cxx') or
          (Ext = '.hpp') or (Ext = '.hh') or (Ext = '.hxx') then
    Result := ilCpp
  else
    Result := ilUnknown;
end;

function TIDE25LanguageService.LanguageName(ALanguage: TIDE25Language): string;
begin
  case ALanguage of
    ilC: Result := 'C';
    ilCpp: Result := 'C++';
  else
    Result := 'Unknown';
  end;
end;

end.
