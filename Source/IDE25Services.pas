unit IDE25Services;

interface

type
  TIDE25ServiceState = (ssStopped, ssStarting, ssRunning, ssStopping, ssFailed);

  IIDE25Service = interface
    ['{A8D0B0B1-5C4A-4D9D-8D90-9A7A7A250001}']
    function GetName: string;
    function GetState: TIDE25ServiceState;
    procedure Start;
    procedure Stop;
    property Name: string read GetName;
    property State: TIDE25ServiceState read GetState;
  end;

implementation

end.
