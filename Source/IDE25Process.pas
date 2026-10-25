unit IDE25Process;

interface

uses
  Windows, SysUtils, Classes, StrUtils;

type
  TIDE25ProcessResult = record
    ExitCode: Cardinal;
    OutputText: string;
    ErrorText: string;
    Success: Boolean;
  end;

function IDE25RunProcess(const Executable, Arguments, WorkingDirectory: string): TIDE25ProcessResult;

implementation

function IDE25RunProcess(const Executable, Arguments, WorkingDirectory: string): TIDE25ProcessResult;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  ReadPipe, WritePipe: THandle;
  Buffer: array[0..4095] of Byte;
  ReadCount: Cardinal;
  CmdLine: string;
  ExitCode: Cardinal;
  Stream: TMemoryStream;
begin
  Result.ExitCode := Cardinal(-1);
  Result.OutputText := '';
  Result.ErrorText := '';
  Result.Success := False;
  ZeroMemory(@SA, SizeOf(SA));
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := True;
  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  ZeroMemory(@PI, SizeOf(PI));
  ReadPipe := 0;
  WritePipe := 0;
  Stream := TMemoryStream.Create;
  try
    if not CreatePipe(ReadPipe, WritePipe, @SA, 0) then
      Exit;
    SetHandleInformation(ReadPipe, HANDLE_FLAG_INHERIT, 0);
    SI.hStdOutput := WritePipe;
    SI.hStdError := WritePipe;
    CmdLine := '"' + Executable + '"' + IfThen(Arguments <> '', ' ' + Arguments, '');
    UniqueString(CmdLine);
    if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW,
      nil, PChar(WorkingDirectory), SI, PI) then
      Exit;
    CloseHandle(WritePipe);
    WritePipe := 0;
    repeat
      if PeekNamedPipe(ReadPipe, nil, 0, nil, @ReadCount, nil) and (ReadCount > 0) then
      begin
        if ReadFile(ReadPipe, Buffer, SizeOf(Buffer), ReadCount, nil) and (ReadCount > 0) then
          Stream.WriteBuffer(Buffer, ReadCount);
      end
      else
        Sleep(10);
      GetExitCodeProcess(PI.hProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE) and (ReadCount = 0);
    GetExitCodeProcess(PI.hProcess, Result.ExitCode);
    if Stream.Size > 0 then
    begin
      SetLength(Result.OutputText, Stream.Size);
      Stream.Position := 0;
      Stream.ReadBuffer(Pointer(Result.OutputText)^, Stream.Size);
    end;
    Result.Success := Result.ExitCode = 0;
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  finally
    if WritePipe <> 0 then CloseHandle(WritePipe);
    if ReadPipe <> 0 then CloseHandle(ReadPipe);
    Stream.Free;
  end;
end;

end.
