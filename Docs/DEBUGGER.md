# Debugger Architecture

The debugger layer should expose a debugger-independent model to the UI.

## Core model

- Process
- Thread
- Stack frame
- Source location
- Breakpoint
- Watch expression
- Register set
- Memory region

## Adapters

The first adapter remains the existing GDB integration. LLDB can be added through the same service interface.

## Safety

Debugger process lifetime must be owned by a service object, all pipe/stream reads must handle process termination, and UI updates must be marshalled to the main VCL thread.
