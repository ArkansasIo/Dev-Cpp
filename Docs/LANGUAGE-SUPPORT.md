# Language and Toolchain Support

## Primary

- C
- C++

## Compiler families

- GCC / MinGW
- Clang / LLVM
- Microsoft Visual C++

## Build systems

- Native Dev-C++ project files
- Makefiles
- CMake
- Ninja

## Language-service direction

Language services should be isolated behind adapters so completion, diagnostics, symbols, formatting and navigation can evolve independently of the VCL editor. The initial implementation should preserve the existing editor behavior and add services incrementally.

## File extensions

The legacy `Version.pas` already defines C/C++ source and header extensions. New language adapters should extend that mapping without breaking existing project loading.
