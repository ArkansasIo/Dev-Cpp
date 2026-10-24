# IDE 2.5.0 Alpha Release Process

## Versioning

Use `2.5.0-alpha.N` for pre-release builds and increment `N` for each distributable alpha.

## Required artifacts

- Windows installer
- Portable ZIP
- SHA-256 checksums
- Release notes
- Source archive

## Pre-release checks

1. Run `DevKit/tools/check_source_units.ps1`.
2. Build `Source/devcpp.dpr` with the supported Delphi toolchain.
3. Run the internal test suite.
4. Run the smoke-test checklist from `Docs/TESTING.md`.
5. Verify portable mode and configuration isolation.
6. Record compiler/debugger versions used for the build.

## Release notes

Every alpha release should document new files, changed interfaces, known defects, dependency changes and any compatibility limitations.
