# UML — Universal Math Language

A Rust-implemented scripting language with Lua-like syntax, object-oriented
programming, logic statements, a built-in math engine, and an Unreal-Engine-5-style
**Blueprint** graph system.

## Build
```powershell
cargo build --release
# binary: target\release\uml.exe
```

## Usage
```powershell
uml run file.uml          # run a program
uml eval "print(2+2)"     # evaluate a snippet
uml repl                  # interactive REPL
uml math prime 97         # direct math: prime|gcd|factor|fib|fact|lcm|solve
uml blueprint graph.json 9   # execute a blueprint graph with input 9
```

## Language features

- **Lua-like syntax**: `let`, `function ... end`, `if/then/elseif/else/end`,
  `while ... do ... end`, `for i in a..b do ... end`
- **Logic**: `and`, `or`, `not`, comparisons `== != < > <= >=`
- **OOP**: `class`, fields, constructors (`function new`), methods,
  `ClassName.new(args)`, `obj.method()`, `obj.field`
- **Math built-ins**: `sqrt abs floor ceil sin cos tan ln log prime gcd factor`
- **Power operator**: `^`; modulo `%`; integer + real arithmetic

Example (`examples/oop.uml`):
```
class Number
    value: Real

    function new(v)
        value = v
    end

    function square()
        return value * value
    end
end

let x = Number.new(7)
print(x.square())        // -> 49
```

## Blueprint system (UE5-style)
Node graphs with typed inputs; execute as a DAG with cycle detection.
Ops include arithmetic (`add sub mul div pow mod`), functions (`sqrt sin cos
clamp lerp min max`), logic (`and or not eq ne gt lt`), UE-style `select`
and `branch` nodes. See `examples/graph1.json` and `src/blueprint.rs`.

## Tests
```powershell
cargo test    # 6 tests: math engine + blueprint graph execution
```

## Layout
```
src/
  lexer.rs      tokenizer (Lua-like keywords, // -- # comments)
  parser.rs     AST + recursive-descent parser with precedence climbing
  runtime.rs    tree-walking interpreter, OOP runtime, built-ins
  math.rs       math engine (primes, gcd/lcm, factorization, fib, quadratic solver)
  blueprint.rs  UE5-style node-graph executor
  main.rs       CLI: run | eval | repl | math | blueprint
```
