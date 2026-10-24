# IDE 2.5.0 Testing Strategy

## Existing coverage

The legacy application already contains an internal `Tests.pas` suite covering editor lists, actions, compiler options and editor behavior.

## New coverage

### Unit

- Path/config handling
- Toolchain discovery
- Compiler command construction
- Diagnostic parsing
- Plugin registration
- Project serialization

### Integration

- Create/open/save project
- Configure GCC and Clang
- Build and clean a sample project
- Start and stop a debugger
- Format a source file
- Install/remove a package

### Smoke

- Application startup
- Portable mode
- New project wizard
- Editor open/save
- Compile/run
- Debug
- Exit without data loss

Tests must be deterministic and must not require credentials, network access or a developer-specific filesystem layout unless explicitly marked as integration-only.
