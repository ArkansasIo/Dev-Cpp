// UML — runtime: values, environment, objects/classes (OOP), interpreter
use crate::parser::{Expr, Stmt, FunDecl};
use std::collections::HashMap;
use std::rc::Rc;
use std::cell::RefCell;

#[derive(Debug, Clone)]
pub enum Value {
    Int(i64),
    Real(f64),
    Str(String),
    Bool(bool),
    Object(Rc<RefCell<Obj>>),
    Class(Rc<Class>),
    Fun(Rc<FunDecl>),
    Nil,
}

#[derive(Debug, Clone)]
pub struct Obj {
    pub class_name: String,
    pub fields: HashMap<String, Value>,
}

#[derive(Debug, Clone)]
pub struct Class {
    pub name: String,
    pub parent: Option<String>,
    pub fields: Vec<String>,
    pub methods: HashMap<String, Rc<FunDecl>>,
}

#[derive(Debug, Clone)]
pub struct UmlError(pub String);

type Env = HashMap<String, Value>;

pub struct Interp {
    globals: Env,
    classes: HashMap<String, Class>,
    out: String,
}

impl Value {
    pub fn truthy(&self) -> bool {
        match self {
            Value::Bool(b) => *b,
            Value::Int(i) => *i != 0,
            Value::Real(r) => *r != 0.0,
            Value::Nil => false,
            _ => true,
        }
    }
    #[allow(dead_code)] // part of the public Value API (used by future type checker)
    pub fn type_name(&self) -> &'static str {
        match self {
            Value::Int(_) => "Integer", Value::Real(_) => "Real",
            Value::Str(_) => "String", Value::Bool(_) => "Boolean",
            Value::Object(_) => "Object", Value::Class(_) => "Class",
            Value::Fun(_) => "Function", Value::Nil => "Nil",
        }
    }
}

pub fn interp(stmts: Vec<Stmt>) -> Result<String, UmlError> {
    let mut it = Interp { globals: HashMap::new(), classes: HashMap::new(), out: String::new() };
    let mut e: Env = HashMap::new();
    it.exec_block(stmts, &mut e)?;
    Ok(it.out)
}

impl Interp {
    fn exec_block(&mut self, stmts: Vec<Stmt>, env: &mut Env) -> Result<(), UmlError> {
        for s in stmts { self.exec(s, env)?; }
        Ok(())
    }

    fn exec(&mut self, stmt: Stmt, env: &mut Env) -> Result<(), UmlError> {
        match stmt {
            Stmt::Let(name, e) => { let v = self.eval(e, env)?; env.insert(name, v); Ok(()) }
            Stmt::Assign(name, e) => {
                let v = self.eval(e, env)?;
                if env.contains_key(&name) || self.globals.contains_key(&name) { env.insert(name, v); }
                else { return Err(UmlError(format!("undefined variable '{}'", name))); }
                Ok(())
            }
            Stmt::Expr(e) => { self.eval(e, env)?; Ok(()) }
            Stmt::Print(e) => {
                let v = self.eval(e, env)?;
                self.out.push_str(&self.to_str(&v)); self.out.push('\n');
                println!("{}", self.to_str(&v));
                Ok(())
            }
            Stmt::Return(e) => {
                let v = match e { Some(x) => self.eval(x, env)?, None => Value::Nil };
                Err(UmlError(format!("__return__{}", self.to_str(&v))))
            }
            Stmt::If { cond, then, elseifs, els } => {
                if self.eval(cond, env)?.truthy() { self.exec_block(then, env)? }
                else {
                    let mut done = false;
                    for (c, b) in elseifs {
                        if self.eval(c, env)?.truthy() { self.exec_block(b, env)?; done = true; break; }
                    }
                    if !done { self.exec_block(els, env)? }
                }
                Ok(())
            }
            Stmt::While { cond, body } => {
                while self.eval(cond.clone(), env)?.truthy() { self.exec_block(body.clone(), env)? }
                Ok(())
            }
            Stmt::For { var, from, to, body } => {
                let a = self.eval(from, env)?;
                let b = self.eval(to, env)?;
                let (start, end) = match (a, b) {
                    (Value::Int(s), Value::Int(e)) => (s, e),
                    _ => return Err(UmlError("for range needs integers".into())),
                };
                let mut i = start;
                while i <= end {
                    env.insert(var.clone(), Value::Int(i));
                    self.exec_block(body.clone(), env)?;
                    i += 1;
                }
                Ok(())
            }
            Stmt::FunDecl { name, params, body } => {
                env.insert(name.clone(), Value::Fun(Rc::new(FunDecl { name, params, body })));
                Ok(())
            }
            Stmt::ClassDecl { name, extends, fields, methods } => {
                let mut m = HashMap::new();
                for fd in methods { m.insert(fd.name.clone(), Rc::new(fd)); }
                let cls = Class { name: name.clone(), parent: extends, fields, methods: m };
                self.classes.insert(name.clone(), cls.clone());
                env.insert(name, Value::Class(Rc::new(cls)));
                Ok(())
            }
        }
    }

    fn to_str(&self, v: &Value) -> String {
        match v {
            Value::Int(i) => i.to_string(),
            Value::Real(r) => r.to_string(),
            Value::Str(s) => s.clone(),
            Value::Bool(b) => b.to_string(),
            Value::Nil => "nil".into(),
            Value::Object(o) => format!("<object {}>", o.borrow().class_name),
            Value::Class(c) => format!("<class {}>", c.name),
            Value::Fun(f) => format!("<function {}>", f.name),
        }
    }

    fn eval(&mut self, e: Expr, env: &mut Env) -> Result<Value, UmlError> {
        match e {
            Expr::Int(v) => Ok(Value::Int(v)),
            Expr::Real(v) => Ok(Value::Real(v)),
            Expr::Str(s) => Ok(Value::Str(s)),
            Expr::Bool(b) => Ok(Value::Bool(b)),
            Expr::Var(name) => env.get(&name).cloned()
                .ok_or_else(|| UmlError(format!("undefined variable '{}'", name))),
            Expr::Unary(op, x) => {
                let v = self.eval(*x, env)?;
                match (op.as_str(), v) {
                    ("-", Value::Int(i)) => Ok(Value::Int(-i)),
                    ("-", Value::Real(r)) => Ok(Value::Real(-r)),
                    ("not", v) => Ok(Value::Bool(!v.truthy())),
                    _ => Err(UmlError("bad unary".into())),
                }
            }
            Expr::Binary(op, l, r) => {
                let lv = self.eval((*l).clone(), env)?;
                let rv = self.eval((*r).clone(), env)?;
                self.binop(op, lv, rv)
            }
            Expr::Call(name, args) => self.call(name, args, env),
            Expr::Method(obj, name, args) => {
                let ov = self.eval((*obj).clone(), env)?;
                self.call_method(ov, name, args, env)
            }
            Expr::Field(obj, name) => {
                let ov = self.eval((*obj).clone(), env)?;
                match ov {
                    Value::Object(o) => o.borrow().fields.get(&name).cloned()
                        .ok_or_else(|| UmlError(format!("no field '{}'", name))),
                    _ => Err(UmlError("field access on non-object".into())),
                }
            }
        }
    }

    fn binop(&mut self, op: String, l: Value, r: Value) -> Result<Value, UmlError> {
        use Value::*;
        let nums = |l: &Value, r: &Value| -> Option<(f64, f64)> {
            match (l, r) {
                (Int(a), Int(b)) => Some((*a as f64, *b as f64)),
                (Real(a), Real(b)) => Some((*a, *b)),
                (Int(a), Real(b)) => Some((*a as f64, *b)),
                (Real(a), Int(b)) => Some((*a, *b as f64)),
                _ => None,
            }
        };
        match op.as_str() {
            "+" => match (l.clone(), r.clone()) {
                (Str(a), Str(b)) => Ok(Str(a + &b)),
                (Int(a), Int(b)) => Ok(Int(a.wrapping_add(b))),
                _ => nums(&l, &r).map(|(a, b)| if matches!(l, Int(_)) && matches!(r, Int(_)) { Int(a as i64 + b as i64) } else { Real(a + b) }).ok_or_else(|| UmlError("bad +".into())),
            },
            "-" => nums(&l, &r).map(|(a, b)| if matches!(l, Int(_)) && matches!(r, Int(_)) { Int(a as i64 - b as i64) } else { Real(a - b) }).ok_or_else(|| UmlError("bad -".into())),
            "*" => nums(&l, &r).map(|(a, b)| if matches!(l, Int(_)) && matches!(r, Int(_)) { Int(a as i64 * b as i64) } else { Real(a * b) }).ok_or_else(|| UmlError("bad *".into())),
            "/" => nums(&l, &r).map(|(a, b)| { if b == 0.0 { Real(f64::NAN) } else if matches!(l, Int(_)) && matches!(r, Int(_)) { Int(a as i64 / b as i64) } else { Real(a / b) } }).ok_or_else(|| UmlError("bad /".into())),
            "%" => if let (Int(a), Int(b)) = (&l, &r) { Ok(Int(a % b)) } else { Err(UmlError("bad %".into())) },
            "^" => nums(&l, &r).map(|(a, b)| Real(a.powf(b))).ok_or_else(|| UmlError("bad ^".into())),
            "==" => Ok(Bool(self.to_str(&l) == self.to_str(&r))),
            "!=" => Ok(Bool(self.to_str(&l) != self.to_str(&r))),
            "<" => nums(&l, &r).map(|(a, b)| Bool(a < b)).ok_or_else(|| UmlError("bad <".into())),
            ">" => nums(&l, &r).map(|(a, b)| Bool(a > b)).ok_or_else(|| UmlError("bad >".into())),
            "<=" => nums(&l, &r).map(|(a, b)| Bool(a <= b)).ok_or_else(|| UmlError("bad <=".into())),
            ">=" => nums(&l, &r).map(|(a, b)| Bool(a >= b)).ok_or_else(|| UmlError("bad >=".into())),
            "and" => Ok(if l.truthy() { r } else { l }),
            "or" => Ok(if l.truthy() { l } else { r }),
            _ => Err(UmlError(format!("unknown operator '{}'", op))),
        }
    }

    fn call(&mut self, name: String, args: Vec<Expr>, env: &mut Env) -> Result<Value, UmlError> {
        // built-ins
        match name.as_str() {
            "print" => {
                let vals = args.into_iter().map(|a| self.eval(a, env)).collect::<Result<Vec<_>, _>>()?;
                let s: Vec<String> = vals.iter().map(|v| self.to_str(v)).collect();
                let line = s.join(" ");
                println!("{}", line);
                self.out.push_str(&line); self.out.push('\n');
                return Ok(Value::Nil);
            }
            "sqrt" | "abs" | "floor" | "ceil" | "sin" | "cos" | "tan" | "ln" | "log" => {
                let a = self.eval(args.into_iter().next().ok_or_else(|| UmlError("arg needed".into()))?, env)?;
                let f = match a { Value::Int(i) => i as f64, Value::Real(r) => r, _ => return Err(UmlError("math fn needs number".into())) };
                let out = match name.as_str() {
                    "sqrt" => f.sqrt(), "abs" => f.abs(), "floor" => f.floor(), "ceil" => f.ceil(),
                    "sin" => f.sin(), "cos" => f.cos(), "tan" => f.tan(),
                    "ln" => f.ln(), "log" => f.log10(),
                    _ => unreachable!(),
                };
                return Ok(Value::Real(out));
            }
            "prime" => {
                let a = self.eval(args.into_iter().next().ok_or_else(|| UmlError("arg needed".into()))?, env)?;
                let n = match a { Value::Int(i) => i, _ => return Err(UmlError("prime(n) needs integer".into())) };
                return Ok(Value::Bool(crate::math::is_prime(n)));
            }
            "gcd" => {
                let mut it = args.into_iter();
                let a = self.eval(it.next().ok_or_else(|| UmlError("arg needed".into()))?, env)?;
                let b = self.eval(it.next().ok_or_else(|| UmlError("arg needed".into()))?, env)?;
                if let (Value::Int(a), Value::Int(b)) = (a, b) {
                    return Ok(Value::Int(crate::math::gcd(a, b)));
                }
                return Err(UmlError("gcd needs integers".into()));
            }
            "factor" => {
                let a = self.eval(args.into_iter().next().ok_or_else(|| UmlError("arg needed".into()))?, env)?;
                if let Value::Int(n) = a {
                    let s = crate::math::factor(n).iter().map(|x| x.to_string()).collect::<Vec<_>>().join(" * ");
                    return Ok(Value::Str(s));
                }
                return Err(UmlError("factor needs integer".into()));
            }
            "random" => return Ok(Value::Real(rand_f64())),
            _ => {}
        }
        // user function
        let fd = match env.get(&name).cloned() {
            Some(Value::Fun(f)) => f,
            _ => return Err(UmlError(format!("unknown function '{}'", name))),
        };
        let argv = args.into_iter().map(|a| self.eval(a, env)).collect::<Result<Vec<_>, _>>()?;
        self.call_fun(fd, argv, env)
    }

    fn call_fun(&mut self, fd: Rc<FunDecl>, argv: Vec<Value>, _env: &mut Env) -> Result<Value, UmlError> {
        let mut local: Env = HashMap::new();
        for (i, p) in fd.params.iter().enumerate() {
            let v = argv.get(i).cloned().unwrap_or(Value::Nil);
            local.insert(p.clone(), v);
        }
        match self.exec_block(fd.body.clone(), &mut local) {
            Ok(()) => Ok(Value::Nil),
            Err(e) if e.0.starts_with("__return__") => {
                let s = e.0.trim_start_matches("__return__");
                Ok(match s { "true" => Value::Bool(true), "false" => Value::Bool(false),
                    other => other.parse::<i64>().map(Value::Int)
                        .or_else(|_| other.parse::<f64>().map(Value::Real))
                        .unwrap_or(Value::Str(other.to_string())) })
            }
            Err(e) => Err(e),
        }
    }

    #[allow(dead_code)] // kept for future direct instantiation syntax (new ClassName(...))
    fn new_object(&mut self, cname: String, args: Vec<Expr>, env: &mut Env) -> Result<Value, UmlError> {
        self.instantiate(&cname, args, env)
    }

    fn instantiate(&mut self, cname: &str, args: Vec<Expr>, env: &mut Env) -> Result<Value, UmlError> {
        let class = self.classes.get(cname).cloned()
            .ok_or_else(|| UmlError(format!("unknown class '{}'", cname)))?;
        let mut obj = Obj { class_name: cname.to_string(), fields: HashMap::new() };
        // collect fields from the whole inheritance chain (parent first)
        let mut chain = vec![class.clone()];
        let mut cur = class.parent.clone();
        while let Some(p) = cur {
            match self.classes.get(&p) {
                Some(pc) => { chain.insert(0, pc.clone()); cur = pc.parent.clone(); }
                None => break,
            }
        }
        for c in &chain { for f in &c.fields { obj.fields.insert(f.clone(), Value::Nil); } }
        let rc = Rc::new(RefCell::new(obj));
        // call constructor `new` if present
        if let Some(ctor) = class.methods.get("new").cloned() {
            let mut local: Env = HashMap::new();
            local.insert("self".into(), Value::Object(rc.clone()));
            for (k, v) in rc.borrow().fields.clone() { local.insert(k, v); }
            let argv = args.into_iter().map(|a| self.eval(a, env)).collect::<Result<Vec<_>, _>>()?;
            for (i, p) in ctor.params.iter().enumerate() {
                local.insert(p.clone(), argv.get(i).cloned().unwrap_or(Value::Nil));
            }
            self.exec_block(ctor.body.clone(), &mut local)?;
            // sync fields back into the object
            for (k, v) in local.iter() {
                if k != "self" && rc.borrow().fields.contains_key(k) {
                    rc.borrow_mut().fields.insert(k.clone(), v.clone());
                }
            }
        }
        Ok(Value::Object(rc))
    }

    fn call_method(&mut self, target: Value, name: String, args: Vec<Expr>, env: &mut Env) -> Result<Value, UmlError> {
        match target {
            Value::Class(c) => {
                // static-ish: ClassName.new(args)
                if name == "new" { self.instantiate(&c.name, args, env) }
                else { Err(UmlError(format!("class '{}' has no static '{}'", c.name, name))) }
            }
            Value::Object(ref o) => {
                let cname = o.borrow().class_name.clone();
                let class = self.classes.get(&cname).cloned()
                    .ok_or_else(|| UmlError(format!("missing class '{}'", cname)))?;
                let m = class.methods.get(&name).cloned().or_else(|| {
                    // walk parent chain for inherited methods
                    let mut cur = class.parent.clone();
                    while let Some(p) = cur {
                        if let Some(pc) = self.classes.get(&p) {
                            if let Some(pm) = pc.methods.get(&name) { return Some(pm.clone()); }
                            cur = pc.parent.clone();
                        } else { break; }
                    }
                    None
                })
                    .ok_or_else(|| UmlError(format!("class '{}' has no method '{}'", cname, name)))?;
                let mut local: Env = HashMap::new();
                local.insert("self".into(), target.clone());
                for (k, v) in o.borrow().fields.clone() { local.insert(k, v); }
                let argv = args.into_iter().map(|a| self.eval(a, env)).collect::<Result<Vec<_>, _>>()?;
                for (i, p) in m.params.iter().enumerate() {
                    local.insert(p.clone(), argv.get(i).cloned().unwrap_or(Value::Nil));
                }
                let ret = match self.exec_block(m.body.clone(), &mut local) {
                    Ok(()) => Value::Nil,
                    Err(e) if e.0.starts_with("__return__") => {
                        let s = e.0.trim_start_matches("__return__").to_string();
                        match s.as_str() {
                            "true" => Value::Bool(true),
                            "false" => Value::Bool(false),
                            other => match other.parse::<i64>() {
                                Ok(i) => Value::Int(i),
                                Err(_) => match other.parse::<f64>() {
                                    Ok(f) => Value::Real(f),
                                    Err(_) => Value::Str(other.to_string()),
                                },
                            },
                        }
                    }
                    Err(e) => return Err(e),
                };
                // sync fields back
                for (k, v) in local.iter() {
                    if k != "self" && o.borrow().fields.contains_key(k) {
                        o.borrow_mut().fields.insert(k.clone(), v.clone());
                    }
                }
                Ok(ret)
            }
            _ => Err(UmlError("method call on non-object".into())),
        }
    }
}

fn rand_f64() -> f64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    let n = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().subsec_nanos();
    (n % 1_000_000) as f64 / 1_000_000.0
}
