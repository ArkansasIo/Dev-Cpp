unit IDE25Adapter;

interface

uses
  SysUtils;

type
  TIDE25AdapterKind = (akToolchain, akLanguage, akDebugger, akFormatter, akPackage);

  TIDE25AdapterInfo = record
    Name: string;
    Kind: TIDE25AdapterKind;
    Executable: string;
    Version: string;
  end;

function IDE25AdapterKindName(Kind: TIDE25AdapterKind): string;

implementation

function IDE25AdapterKindName(Kind: TIDE25AdapterKind): string;
begin
  case Kind of
    akToolchain: Result := 'toolchain';
    akLanguage: Result := 'language';
    akDebugger: Result := 'debugger';
    akFormatter: Result := 'formatter';
    akPackage: Result := 'package';
  else
    Result := 'unknown';
  end;
end;

end.
