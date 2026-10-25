unit IDE25Build;

{ Compatibility shim. The canonical build service lives in IDE25BuildService,
  which runs real processes through IDE25Process. This unit previously declared
  its own TIDE25BuildService/TIDE25BuildResult, which collided with the canonical
  definitions when both units were compiled into devcpp.dpr. Any new code must
  use IDE25BuildService directly. }

interface

uses
  IDE25BuildService;

type
  TIDE25BuildResult = IDE25BuildService.TIDE25BuildResult;
  TIDE25BuildRequest = IDE25BuildService.TIDE25BuildRequest;
  TIDE25BuildService = IDE25BuildService.TIDE25BuildService;

implementation

end.
