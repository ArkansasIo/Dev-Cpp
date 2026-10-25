unit IDE25Package;

interface

uses
  SysUtils, Classes;

type
  TIDE25Package = class
  private
    FName: string;
    FVersion: string;
    FFileName: string;
  public
    constructor Create(const AName, AVersion, AFileName: string);
    property Name: string read FName;
    property Version: string read FVersion;
    property FileName: string read FFileName;
  end;

  TIDE25PackageManager = class
  private
    FPackages: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(APackage: TIDE25Package);
    procedure Clear;
    function Count: Integer;
    function Get(Index: Integer): TIDE25Package;
  end;

implementation

constructor TIDE25Package.Create(const AName, AVersion, AFileName: string);
begin
  inherited Create;
  FName := AName;
  FVersion := AVersion;
  FFileName := AFileName;
end;

constructor TIDE25PackageManager.Create;
begin
  inherited Create;
  FPackages := TList.Create;
end;

destructor TIDE25PackageManager.Destroy;
begin
  Clear;
  FPackages.Free;
  inherited;
end;

procedure TIDE25PackageManager.Add(APackage: TIDE25Package);
begin
  if Assigned(APackage) then
    FPackages.Add(APackage);
end;

procedure TIDE25PackageManager.Clear;
var
  I: Integer;
begin
  for I := FPackages.Count - 1 downto 0 do
    TObject(FPackages[I]).Free;
  FPackages.Clear;
end;

function TIDE25PackageManager.Count: Integer;
begin
  Result := FPackages.Count;
end;

function TIDE25PackageManager.Get(Index: Integer): TIDE25Package;
begin
  if (Index >= 0) and (Index < FPackages.Count) then
    Result := TIDE25Package(FPackages[Index])
  else
    Result := nil;
end;

end.
