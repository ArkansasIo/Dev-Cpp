# IDE 2.5.0 Alpha Build Guide

## Current project

The application is a Delphi/VCL project rooted at `Source/devcpp.dpr`. The repository also contains DevKit PowerShell tooling and bundled formatter/compiler support.

## Required toolchain

- Embarcadero Delphi/RAD Studio compatible with the VCL units used by the project.
- Git.
- Windows SDK/runtime appropriate for the selected Delphi target.
- GCC/MinGW for projects compiled by the IDE.
- Optional Clang/LLVM and GDB/LLDB installations for additional toolchains.

## Build sequence

1. Clone the repository.
2. Open `Source/devcpp.dpr` in the supported Delphi IDE.
3. Restore/configure third-party dependencies used by the source tree.
4. Select Win32 or Win64 according to the target configuration.
5. Build the application.
6. Run the existing IDE tests through the application's test facility.
7. Package the executable together with `Lang`, `Templates`, `Themes`, formatter/compiler tools and required runtime files.

## Validation

A release candidate should verify startup, project creation, source editing, save/load, compiler discovery, build/clean, debugger launch, formatter invocation, localization and portable mode.

## CI direction

The repository should eventually use a Windows GitHub Actions runner to perform dependency validation, static checks, Delphi compilation, smoke tests and artifact packaging. CI must fail on missing source units rather than silently producing a partial package.
