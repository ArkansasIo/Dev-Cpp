// UML — Universal Math Language IDE: CLI + REPL
mod lexer;
mod parser;
mod runtime;
mod math;
mod blueprint;

use std::io::{Write, BufRead};

fn run_source(src: &str) -> Result<String, String> {
    let toks = lexer::lex(src)?;
    let stmts = parser::parse(toks)?;
    runtime::interp(stmts).map_err(|e| e.0)
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let cmd = args.get(1).map(|s| s.as_str()).unwrap_or("repl");

    match cmd {
        "run" => {
            let path = args.get(2).expect("usage: uml run <file.uml>");
            let src = std::fs::read_to_string(path).expect("cannot read file");
            match run_source(&src) {
                Ok(_) => {}
                Err(e) => { eprintln!("error: {}", e); std::process::exit(1); }
            }
        }
        "eval" => {
            let expr = args.get(2).expect("usage: uml eval \"<code>\"");
            match run_source(expr) {
                Ok(_) => {}
                Err(e) => { eprintln!("error: {}", e); std::process::exit(1); }
            }
        }
        "math" => {
            // direct math shortcuts: uml math prime 97 | gcd 54 24 | factor 144 | fib 10
            let sub = args.get(2).map(|s| s.as_str()).unwrap_or("");
            let a = args.get(3).and_then(|s| s.parse::<i64>().ok());
            let b = args.get(4).and_then(|s| s.parse::<i64>().ok());
            match (sub, a, b) {
                ("prime", Some(n), _) => println!("{}", math::is_prime(n)),
                ("gcd", Some(a), Some(b)) => println!("{}", math::gcd(a, b)),
                ("factor", Some(n), _) => println!("{:?}", math::factor(n)),
                ("fib", Some(n), _) => println!("{}", math::fibonacci(n as u64)),
                ("fact", Some(n), _) => println!("{}", math::factorial(n as u64)),
                ("lcm", Some(a), Some(b)) => println!("{}", math::lcm(a, b)),
                ("solve", Some(a), Some(b)) => {
                    let c = args.get(5).and_then(|s| s.parse::<f64>().ok()).unwrap_or(0.0);
                    let (r1, r2) = math::solve_quadratic(a as f64, b as f64, c);
                    println!("x1={}, x2={}", r1, r2);
                }
                _ => eprintln!("usage: uml math prime|gcd|factor|fib|fact|lcm|solve <args>"),
            }
        }
        "blueprint" => {
            // blueprint graph execution: uml blueprint <file.json> [input]
            let path = args.get(2).expect("usage: uml blueprint <graph.json> [input]");
            let input: f64 = args.get(3).and_then(|s| s.parse().ok()).unwrap_or(0.0);
            let json = std::fs::read_to_string(path).expect("cannot read graph");
            match blueprint::run_json(&json, input) {
                Ok(out) => println!("result: {}", out),
                Err(e) => { eprintln!("error: {}", e); std::process::exit(1); }
            }
        }
        "repl" | _ => repl(),
    }
}

fn repl() {
    println!("UML — Universal Math Language REPL (type :quit to exit, :help for help)");
    loop {
        print!("UML> ");
        std::io::stdout().flush().unwrap();
        let mut line = String::new();
        if std::io::stdin().lock().read_line(&mut line).unwrap_or(0) == 0 { break; }
        let line = line.trim();
        match line {
            "" => continue,
            ":quit" | ":q" => break,
            ":help" => {
                println!("commands: :quit :help :blueprint <file> [in]");
                println!("examples: let x = 5 + 3   |   print(prime(97))   |   function f(n) return n*2 end  print(f(4))");
                continue;
            }
            _ => {}
        }
        if let Some(rest) = line.strip_prefix(":blueprint") {
            let parts: Vec<&str> = rest.trim().split_whitespace().collect();
            if let Some(file) = parts.first() {
                let input: f64 = parts.get(1).and_then(|s| s.parse().ok()).unwrap_or(0.0);
                match std::fs::read_to_string(file).map_err(|e| e.to_string())
                    .and_then(|j| blueprint::run_json(&j, input)) {
                    Ok(out) => println!("result: {}", out),
                    Err(e) => println!("error: {}", e),
                }
            }
            continue;
        }
        match run_source(line) {
            Ok(_) => {}
            Err(e) => println!("error: {}", e),
        }
    }
}
