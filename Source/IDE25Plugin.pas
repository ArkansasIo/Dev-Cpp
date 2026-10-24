unit IDE25Plugin;

interface

uses
  Classes, SysUtils, IDE25Services;

type
  IIDE25Plugin = interface
    ['{A8D0B0B1-5C4A-4D9D-8D90-9A7A7A250002}']
    function GetName: string;
    function GetVersion: string;
    procedure Initialize;
    procedure Finalize;
  end;

  TIDE25PluginManager = class(TInterfacedObject, IIDE25Service)
  private
    FState: TIDE25ServiceState;
    FPlugins: TInterfaceList;
  protected
    function GetName: string;
    function GetState: TIDE25ServiceState;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    function RegisterPlugin(const APlugin: IIDE25Plugin): Boolean;
    function Count: Integer;
    function Plugin(Index: Integer): IIDE25Plugin;
  end;

implementation

constructor TIDE25PluginManager.Create;
begin
  inherited Create;
  FPlugins := TInterfaceList.Create;
end;

destructor TIDE25PluginManager.Destroy;
begin
  FPlugins.Free;
  inherited Destroy;
end;

function TIDE25PluginManager.GetName: string;
begin
  Result := 'Plugin Manager';
end;

function TIDE25PluginManager.GetState: TIDE25ServiceState;
begin
  Result := FState;
end;

procedure TIDE25PluginManager.Start;
begin
  FState := ssStarting;
  FState := ssRunning;
end;

procedure TIDE25PluginManager.Stop;
begin
  FState := ssStopping;
  FPlugins.Clear;
  FState := ssStopped;
end;

function TIDE25PluginManager.RegisterPlugin(const APlugin: IIDE25Plugin): Boolean;
begin
  Result := Assigned(APlugin);
  if not Result then
    Exit;
  if FPlugins.IndexOf(APlugin) >= 0 then
    Exit(False);
  FPlugins.Add(APlugin);
  APlugin.Initialize;
end;

function TIDE25PluginManager.Count: Integer;
begin
  Result := FPlugins.Count;
end;

function TIDE25PluginManager.Plugin(Index: Integer): IIDE25Plugin;
begin
  if (Index < 0) or (Index >= FPlugins.Count) then
    Result := nil
  else
    Result := FPlugins[Index] as IIDE25Plugin;
end;

end.
