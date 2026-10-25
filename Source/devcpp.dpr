{
  This file is part of Embarcadero Dev-C++
  Copyright (c) 2004 Bloodshed Software

  Embarcadero Dev-C++ is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
}

program devcpp;
{$R 'icons.res' 'icons.rc'}
{$R 'DefaultFiles.res' 'DefaultFiles.rc'}

uses
  FastMM5 in 'FastMM5.pas',
  Windows,
  Forms,
  sysUtils,
  SHFolder,
  Messages,
  System.IOUtils,
  IDE25Version in 'IDE25Version.pas',
  IDE25Services in 'IDE25Services.pas',
  IDE25Toolchain in 'IDE25Toolchain.pas',
  IDE25Project in 'IDE25Project.pas',
  IDE25Build in 'IDE25Build.pas',
  IDE25Debugger in 'IDE25Debugger.pas',
  IDE25Plugin in 'IDE25Plugin.pas',
  IDE25Workspace in 'IDE25Workspace.pas',
  IDE25Language in 'IDE25Language.pas',
  IDE25Process in 'IDE25Process.pas',
  IDE25BuildService in 'IDE25BuildService.pas',
  IDE25Settings in 'IDE25Settings.pas',
  IDE25LSP in 'IDE25LSP.pas',
  IDE25Package in 'IDE25Package.pas',
  IDE25Adapter in 'IDE25Adapter.pas',
  main in 'main.pas' {MainForm},
  MultiLangSupport in 'MultiLangSupport.pas',
  Version in 'Version.pas',
  Utils in 'Utils.pas',
  Tests in 'Tests.pas',
  LangFrm in 'LangFrm.pas' {LangForm},
  Project in 'Project.pas',
  Templates in 'Templates.pas',
  NewProjectFrm in 'NewProjectFrm.pas' {NewProjectForm},
  RemoveUnitFrm in 'RemoveUnitFrm.pas' {RemoveUnitForm},
  GotoLineFrm in 'GotoLineFrm.pas' {GotoLineForm},
  PrintFrm in 'PrintFrm.pas' {PrintForm},
  AboutFrm in 'AboutFrm.pas' {AboutForm},
  Compiler in 'Compiler.pas',
  devrun in 'devrun.pas',
  ProjectOptionsFrm in 'ProjectOptionsFrm.pas' {ProjectOptionsForm},
  ToolFrm in 'ToolFrm.pas' {ToolFrom},
  ToolEditFrm in 'ToolEditFrm.pas' {ToolEditForm},
  IconFrm in 'IconFrm.pas' {IconForm},
  devcfg in 'devcfg.pas',
  DataFrm in 'DataFrm.pas' {dmMain: TDataModule},
  EditorOptFrm in 'EditorOptFrm.pas' {EditorOptForm},
  CodeInsList in 'CodeInsList.pas',
  IncrementalFrm in 'IncrementalFrm.pas' {IncrementalForm},
  FindFrm in 'FindFrm.pas' {FindForm},
  Editor in 'Editor.pas',
  EnviroFrm in 'EnviroFrm.pas' {EnviroForm},
  DebugReader in 'DebugReader.pas',
  Debugger in 'Debugger.pas',
  EditorList in 'EditorList.pas',
  CFGData in 'CFGData.pas',
  ProjectTypes in 'ProjectTypes.pas',
  Macros in 'Macros.pas',
  devExec in 'devExec.pas',
  NewTemplateFrm in 'NewTemplateFrm.pas' {NewTemplateForm},
  FunctionSearchFrm in 'FunctionSearchFrm.pas' {FunctionSearchForm},
  NewVarFrm in 'NewVarFrm.pas' {NewVarForm},
  NewFunctionFrm in 'NewFunctionFrm.pas' {NewFunctionForm},
  NewClassFrm in 'NewClassFrm.pas' {NewClassForm},
  ProfileAnalysisFrm in 'ProfileAnalysisFrm.pas' {ProfileAnalysisForm},
  FilePropertiesFrm in 'FilePropertiesFrm.pas' {FilePropertiesForm},
  AddToDoFrm in 'AddToDoFrm.pas' {AddToDoForm},
  ViewToDoFrm in 'ViewToDoFrm.pas' {ViewToDoForm},
  ImportMSVCFrm in 'ImportMSVCFrm.pas' {ImportMSVCForm},
  ImportCBFrm in 'ImportCBFrm.pas' {ImportCBForm},
  CPUFrm in 'CPUFrm.pas' {CPUForm},
  FileAssocs in 'FileAssocs.pas',
  TipOfTheDayFrm in 'TipOfTheDayFrm.pas' {TipOfTheDayForm},
  ExceptionFrm in 'ExceptionFrm.pas' {ExceptionFrm},
  WindowListFrm in 'WindowListFrm.pas' {WindowListForm},
  ParamsFrm in 'ParamsFrm.pas' {ParamsForm},
  CompOptionsFrame in 'CompOptionsFrame.pas' {CompOptionsFrame: TFrame},
  CompOptionsFrm in 'CompOptionsFrm.pas' {CompOptionsForm},
  ProcessListFrm in 'ProcessListFrm.pas' {ProcessListForm},
  PackmanExitCodesU in 'Tools\Packman\PackmanExitCodesU.pas',
  ImageTheme in 'ImageTheme.pas',
  Instances in 'Instances.pas',
  CharUtils in 'CharUtils.pas',
  ConsoleAppHostFrm in 'ConsoleAppHostFrm.pas' {ConsoleAppHost},
  Vcl.Themes,
  Vcl.Styles,
  AStyleFormatterOptionsFrm in 'AStyleFormatterOptionsFrm.pas' {AStyleFormatterOptionsForm},
  ClangFormatterOptionsFrm in 'ClangFormatterOptionsFrm.pas' {ClangFormatterOptionsForm};

{$R *.res}

var
  AppData, INIFileName, ExeFolder: String;
begin
  if (ParamCount > 1) and ParamStr(1).Equals('INTERNAL_DEL') then
  begin
    AllocConsole;
    try
      WriteLn('Start deleting...');
      for var i := 2 to ParamCount do
        if TFile.Exists(ParamStr(i)) then
        begin
          Write('Deleting: ' + ParamStr(i));
          try
            TFile.Delete(ParamStr(i));
            WriteLn(' Ok');
          except
            on E: exception do
              WriteLn(' fail: ' + E.Message);
          end;
        end
        else
          WriteLn('File not found: ' + ParamStr(i));
    finally
      WriteLn('Deleting complete...');
      FreeConsole;
    end;
    Exit;
  end;

{$IFDEF FASTMM_DEBUG_MODE}
  FastMM_LogToFileEvents := FastMM_LogToFileEvents + [mmetUnexpectedMemoryLeakDetail, mmetUnexpectedMemoryLeakSummary];
  FastMM_MessageBoxEvents := FastMM_MessageBoxEvents + [mmetUnexpectedMemoryLeakSummary];
  if FastMM_LoadDebugSupportLibrary then
    FastMM_EnterDebugMode
  else
  begin
    MessageBox(0, FastMM_DebugSupportLibraryNotAvailableError, FastMM_DebugSupportLibraryNotAvailableError_Caption, MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_DEFAULT_DESKTOP_ONLY);
    Halt(217);
  end;
{$ENDIF}

  devData.IsPortable := TPath.GetFileNameWithoutExtension(ParamStr(0)).EndsWith('portable', True)
                        or FindCmdLineSwitch('portable', True)
                        or FindCmdLineSwitch('-portable', True);

  INIFileName := ChangeFileExt(ExtractFileName(Application.ExeName), INI_EXT);
  ExeFolder := ExtractFilePath(Application.ExeName);

  if (ParamCount >= 2) and SameStr(ParamStr(1), '-c') then begin
    if not DirectoryExists(ParamStr(2)) then
      CreateDir(ParamStr(2));
    if ParamStr(2)[2] <> ':' then
      devData.INIFileName := ExeFolder + IncludeTrailingBackslash(ParamStr(2)) + INIFileName
    else
      devData.INIFileName := IncludeTrailingBackslash(ParamStr(2)) + INIFileName;
  end else begin
    AppData := IncludeTrailingBackslash(TPath.GetHomePath);
    const DevCppDir = 'Embarcadero\Dev-Cpp\';
    if (not devData.IsPortable) and ((AppData <> '') and (DirectoryExists(AppData + DevCppDir) or ForceDirectories(AppData + DevCppDir))) then
      devData.INIFileName := TPath.Combine(TPath.Combine(AppData,DevCppDir),INIFileName)
    else begin
      devData.INIFileName := ExeFolder + 'config\' + INIFileName;
      TDirectory.CreateDirectory(TPath.GetDirectoryName(devData.INIFileName));
    end;
  end;

  devData.ReadSelf;
  CreateOptions;

  Application.Initialize;
  Application.Title := IDE25_PRODUCT_NAME + ' ' + IDE25_VERSION;
  Application.CreateForm(TMainForm, MainForm);
  Application.MainFormOnTaskBar := True;
  Application.Run;
end.
