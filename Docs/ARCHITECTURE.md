# IDE 2.5.0 Alpha Architecture

## Purpose
Define the modernization boundary for the Pascal/VCL IDE while preserving the existing Dev-C++ project, compiler, editor, debugger, formatter, language and package-management subsystems.

## Layers

```text
UI / VCL
  -> IDE Services
     -> Project System
     -> Editor Services
     -> Toolchain Services
     -> Debugger Services
     -> Language Services
     -> Package Services
     -> Plugin Services
  -> Platform / Windows APIs
```

## Core services

- `ProjectService`: projects, workspaces, files and build profiles.
- `ToolchainService`: GCC, Clang, MSVC, Make, Ninja and CMake discovery.
- `BuildService`: configure, build, rebuild, clean and cancellation.
- `LanguageService`: syntax, diagnostics, completion, symbols and LSP adapters.
- `DebugService`: GDB/LLDB process control, breakpoints, watches and stack inspection.
- `EditorService`: buffers, documents, encoding, undo/redo and multi-view state.
- `PluginService`: lifecycle, capabilities, commands, menus and settings.

## Compatibility

The existing `Source/devcpp.dpr` remains the legacy application entry point. New services should be introduced incrementally rather than replacing the current application in one change.

## Design rules

1. No credentials or API keys in source control.
2. UI code must not directly own compiler-process lifecycle.
3. Long-running operations must be cancellable and report structured status.
4. External tools must be discovered rather than assumed to exist at fixed paths.
5. New functionality must have a test seam even when the initial implementation is a thin adapter.
