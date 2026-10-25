# IDE 2.5.0 Plugin API

The plugin layer is intended to provide a stable boundary around commands, menus, editor services, project services and toolchain adapters.

## Lifecycle

```pascal
type
  IIDEPlugin = interface
    ['{00000000-0000-0000-0000-000000000250}']
    function Id: string;
    function Name: string;
    procedure Initialize;
    procedure Shutdown;
  end;
```

## Rules

- Plugins declare a unique identifier and supported API version.
- Plugin initialization must not block the UI thread for external process work.
- Plugins must release registrations during shutdown.
- Host-owned interfaces should be capability based so optional services can be absent.
- Plugin configuration belongs under the IDE configuration directory.

## Planned extension points

- `IIDECommandProvider`
- `IIDEEditorProvider`
- `IIDEProjectProvider`
- `IIDECompilerProvider`
- `IDEDebuggerProvider`
- `IDELanguageProvider`
- `IDEFormatterProvider`
- `IDEPackagingProvider`
