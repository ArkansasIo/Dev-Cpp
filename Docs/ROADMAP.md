# IDE 2.5.0 Alpha Roadmap

## Alpha 1 — Foundation

- [x] Architecture documentation
- [x] Build documentation
- [x] Plugin API specification
- [ ] Version metadata migration
- [ ] Dependency inventory
- [ ] Automated source-unit completeness check

## Alpha 2 — Toolchains

- [ ] GCC discovery service
- [ ] Clang/LLVM discovery
- [ ] MSVC discovery
- [ ] CMake generator integration
- [ ] Ninja integration
- [ ] Structured compiler diagnostics

## Alpha 3 — Language Services

- [ ] LSP transport abstraction
- [ ] C/C++ diagnostics adapter
- [ ] Completion adapter
- [ ] Symbol/index service
- [ ] Formatting service abstraction

## Alpha 4 — Debugging

- [ ] GDB adapter cleanup
- [ ] LLDB adapter
- [ ] Breakpoint service
- [ ] Watch/locals model
- [ ] Stack and thread model

## Beta

- [ ] Plugin manager
- [ ] Workspace model
- [ ] Modern settings service
- [ ] Crash-safe recovery
- [ ] CI packaging
- [ ] Installer and portable artifacts

## Release gate

A release requires reproducible builds, startup smoke tests, project build tests, debugger smoke tests, formatter tests, localization validation and a clean portable installation.
