// UML — AST + parser (Lua-like syntax with OOP)
use crate::lexer::Tok;

#[derive(Debug, Clone)]
pub enum Expr {
    Int(i64),
    Real(f64),
    Str(String),
    Bool(bool),
    Var(String),
    Unary(String, Box<Expr>),
    Binary(String, Box<Expr>, Box<Expr>),
    Call(String, Vec<Expr>),
    Method(Box<Expr>, String, Vec<Expr>), // obj.method(args)
    Field(Box<Expr>, String),             // obj.field
}

#[derive(Debug, Clone)]
pub enum Stmt {
    Let(String, Expr),
    Assign(String, Expr),
    Expr(Expr),
    Print(Expr),
    Return(Option<Expr>),
    If { cond: Expr, then: Vec<Stmt>, elseifs: Vec<(Expr, Vec<Stmt>)>, els: Vec<Stmt> },
    While { cond: Expr, body: Vec<Stmt> },
    For { var: String, from: Expr, to: Expr, body: Vec<Stmt> },
    FunDecl { name: String, params: Vec<String>, body: Vec<Stmt> },
    ClassDecl { name: String, extends: Option<String>, fields: Vec<String>, methods: Vec<FunDecl> },
}

#[derive(Debug, Clone)]
pub struct FunDecl { pub name: String, pub params: Vec<String>, pub body: Vec<Stmt> }

pub struct Parser { toks: Vec<Tok>, pos: usize }

pub fn parse(toks: Vec<Tok>) -> Result<Vec<Stmt>, String> {
    let mut p = Parser { toks, pos: 0 };
    let mut stmts = Vec::new();
    while !p.at(&Tok::Eof) {
        stmts.push(p.statement()?);
    }
    Ok(stmts)
}

impl Parser {
    fn at(&self, t: &Tok) -> bool { self.toks.get(self.pos) == Some(t) }
    fn eat(&mut self, t: &Tok) -> bool { if self.at(t) { self.pos += 1; true } else { false } }
    fn expect(&mut self, t: &Tok) -> Result<(), String> {
        if self.eat(t) { Ok(()) } else { Err(format!("expected {:?}, got {:?}", t, self.toks.get(self.pos))) }
    }
    fn ident(&mut self) -> Result<String, String> {
        if let Some(Tok::Ident(s)) = self.toks.get(self.pos).cloned() { self.pos += 1; Ok(s) }
        else { Err(format!("expected identifier, got {:?}", self.toks.get(self.pos))) }
    }

    fn statement(&mut self) -> Result<Stmt, String> {
        match self.toks.get(self.pos).cloned().unwrap_or(Tok::Eof) {
            Tok::Let => { self.pos += 1; let name = self.ident()?; self.expect(&Tok::Assign)?;
                Ok(Stmt::Let(name, self.expression()?)) }
            Tok::Print if matches!(self.toks.get(self.pos + 1), Some(Tok::LParen)) => {
                // print(...) with parens -> parse as a call expression (do NOT skip the token)
                Ok(Stmt::Expr(self.expression()?))
            }
            Tok::Print => { self.pos += 1; Ok(Stmt::Print(self.expression()?)) }
            Tok::Return => { self.pos += 1;
                let e = if self.at(&Tok::End) || self.at(&Tok::Else) || self.at(&Tok::Elseif) ||
                    self.at(&Tok::Until) || self.at(&Tok::Eof) { None } else { Some(self.expression()?) };
                Ok(Stmt::Return(e)) }
            Tok::If => self.if_stmt(),
            Tok::While => { self.pos += 1; let cond = self.expression()?; self.expect(&Tok::Do)?;
                let body = self.block(&[Tok::End])?; self.expect(&Tok::End)?;
                Ok(Stmt::While { cond, body }) }
            Tok::For => { self.pos += 1; let var = self.ident()?; self.expect(&Tok::In)?;
                let from = self.expression()?; self.expect(&Tok::Dot)?; self.expect(&Tok::Dot)?;
                let to = self.expression()?; self.expect(&Tok::Do)?;
                let body = self.block(&[Tok::End])?; self.expect(&Tok::End)?;
                Ok(Stmt::For { var, from, to, body }) }
            Tok::Function => { self.pos += 1; let name = self.ident()?; self.expect(&Tok::LParen)?;
                let params = self.param_list()?; self.expect(&Tok::RParen)?;
                let body = self.block(&[Tok::End])?; self.expect(&Tok::End)?;
                Ok(Stmt::FunDecl { name, params, body }) }
            Tok::Class => self.class_decl(),
            Tok::Ident(_) => {
                // statement starting with identifier: try `name = expr`; otherwise expression
                let save = self.pos;
                if let Some(Tok::Ident(name0)) = self.toks.get(self.pos).cloned() {
                    self.pos += 1;
                    if self.eat(&Tok::Assign) {
                        return Ok(Stmt::Assign(name0, self.expression()?));
                    }
                    self.pos = save;
                }
                let e = self.expression()?;
                Ok(Stmt::Expr(e))
            }
            _ => Err(format!("unexpected token STMT {:?}", self.toks.get(self.pos))),
        }
    }

    fn block(&mut self, stops: &[Tok]) -> Result<Vec<Stmt>, String> {
        let mut out = Vec::new();
        while !self.at(&Tok::Eof) && !stops.iter().any(|t| self.at(t)) {
            out.push(self.statement()?);
        }
        Ok(out)
    }

    fn if_stmt(&mut self) -> Result<Stmt, String> {
        self.pos += 1; // if
        let cond = self.expression()?; self.expect(&Tok::Then)?;
        let then = self.block(&[Tok::Elseif, Tok::Else, Tok::End])?;
        let mut elseifs = Vec::new();
        let mut els = Vec::new();
        loop {
            if self.eat(&Tok::Elseif) {
                let c = self.expression()?; self.expect(&Tok::Then)?;
                let b = self.block(&[Tok::Elseif, Tok::Else, Tok::End])?;
                elseifs.push((c, b));
            } else if self.eat(&Tok::Else) {
                els = self.block(&[Tok::End])?;
                self.expect(&Tok::End)?;
                break;
            } else { self.expect(&Tok::End)?; break; }
        }
        Ok(Stmt::If { cond, then, elseifs, els })
    }

    fn class_decl(&mut self) -> Result<Stmt, String> {
        self.pos += 1;
        let name = self.ident()?;
        let extends = if self.eat(&Tok::Extends) { Some(self.ident()?) } else { None };
        let mut fields = Vec::new();
        let mut methods = Vec::new();
        while !self.eat(&Tok::End) {
            match self.toks.get(self.pos).cloned().unwrap_or(Tok::Eof) {
                Tok::Ident(ref f) if {
                    // field declaration:  name: Type
                    self.pos += 1;
                    if self.eat(&Tok::Colon) { let _ty = self.ident()?; fields.push(f.clone()); true }
                    else { self.pos -= 1; false }
                } => {}
                Tok::Function => {
                    self.pos += 1;
                    let mname = self.ident()?;
                    self.expect(&Tok::LParen)?;
                    let params = self.param_list()?;
                    self.expect(&Tok::RParen)?;
                    let body = self.block(&[Tok::End])?;
                    self.expect(&Tok::End)?;
                    methods.push(FunDecl { name: mname, params, body });
                }
                t => return Err(format!("unexpected token in class: {:?}", t)),
            }
        }
        Ok(Stmt::ClassDecl { name, extends, fields, methods })
    }

    fn param_list(&mut self) -> Result<Vec<String>, String> {
        let mut params = Vec::new();
        if self.at(&Tok::RParen) { return Ok(params); }
        loop {
            params.push(self.ident()?);
            if self.eat(&Tok::Colon) { let _ty = self.ident()?; } // optional type
            if !self.eat(&Tok::Comma) { break; }
        }
        Ok(params)
    }

    // ---- expressions (precedence climbing) ----
    fn expression(&mut self) -> Result<Expr, String> { self.logic() }

    fn logic(&mut self) -> Result<Expr, String> {
        let mut left = self.compare()?;
        loop {
            let op = match self.toks.get(self.pos) {
                Some(Tok::And) => "and", Some(Tok::Or) => "or",
                _ => break,
            };
            self.pos += 1;
            let right = self.compare()?;
            left = Expr::Binary(op.to_string(), Box::new(left), Box::new(right));
        }
        Ok(left)
    }

    fn compare(&mut self) -> Result<Expr, String> {
        let mut left = self.term()?;
        loop {
            let op = match self.toks.get(self.pos) {
                Some(Tok::EqEq) => "==", Some(Tok::Ne) => "!=",
                Some(Tok::Lt) => "<", Some(Tok::Gt) => ">",
                Some(Tok::Le) => "<=", Some(Tok::Ge) => ">=",
                _ => break,
            };
            self.pos += 1;
            let right = self.term()?;
            left = Expr::Binary(op.to_string(), Box::new(left), Box::new(right));
        }
        Ok(left)
    }

    fn term(&mut self) -> Result<Expr, String> {
        let mut left = self.factor()?;
        loop {
            let op = match self.toks.get(self.pos) {
                Some(Tok::Plus) => "+", Some(Tok::Minus) => "-",
                _ => break,
            };
            self.pos += 1;
            let right = self.factor()?;
            left = Expr::Binary(op.to_string(), Box::new(left), Box::new(right));
        }
        Ok(left)
    }

    fn factor(&mut self) -> Result<Expr, String> {
        let mut left = self.power()?;
        loop {
            let op = match self.toks.get(self.pos) {
                Some(Tok::Star) => "*", Some(Tok::Slash) => "/", Some(Tok::Percent) => "%",
                _ => break,
            };
            self.pos += 1;
            let right = self.power()?;
            left = Expr::Binary(op.to_string(), Box::new(left), Box::new(right));
        }
        Ok(left)
    }

    fn power(&mut self) -> Result<Expr, String> {
        let base = self.unary()?;
        if self.eat(&Tok::Caret) {
            let exp = self.power()?;
            Ok(Expr::Binary("^".into(), Box::new(base), Box::new(exp)))
        } else { Ok(base) }
    }

    fn unary(&mut self) -> Result<Expr, String> {
        match self.toks.get(self.pos).cloned().unwrap_or(Tok::Eof) {
            Tok::Minus => { self.pos += 1; Ok(Expr::Unary("-".into(), Box::new(self.unary()?))) }
            Tok::Not => { self.pos += 1; Ok(Expr::Unary("not".into(), Box::new(self.unary()?))) }
            _ => self.postfix(),
        }
    }

    fn postfix(&mut self) -> Result<Expr, String> {
        let mut e = self.primary()?;
        loop {
            // field/method access only when NOT the '..' range operator
            if self.at(&Tok::Dot) && !matches!(self.toks.get(self.pos + 1), Some(Tok::Dot)) {
                self.pos += 1; // consume '.'
                let name = self.ident()?;
                if self.eat(&Tok::LParen) {
                    let args = self.arg_list()?;
                    e = Expr::Method(Box::new(e), name, args);
                } else {
                    e = Expr::Field(Box::new(e), name);
                }
            } else { break; }
        }
        Ok(e)
    }

    fn arg_list(&mut self) -> Result<Vec<Expr>, String> {
        // NOTE: caller has already consumed '('; this function consumes args AND the closing ')'
        let mut args = Vec::new();
        if self.eat(&Tok::RParen) { return Ok(args); }
        loop {
            args.push(self.expression()?);
            if !self.eat(&Tok::Comma) { break; }
        }
        self.expect(&Tok::RParen)?;
        Ok(args)
    }

    fn primary(&mut self) -> Result<Expr, String> {
        let tok = self.toks.get(self.pos).cloned().unwrap_or(Tok::Eof);
        match tok {
            Tok::Int(v) => { self.pos += 1; Ok(Expr::Int(v)) }
            Tok::Real(v) => { self.pos += 1; Ok(Expr::Real(v)) }
            Tok::Str(s) => { self.pos += 1; Ok(Expr::Str(s)) }
            Tok::True => { self.pos += 1; Ok(Expr::Bool(true)) }
            Tok::False => { self.pos += 1; Ok(Expr::Bool(false)) }
            Tok::LParen => { self.pos += 1; let e = self.expression()?; self.expect(&Tok::RParen)?; Ok(e) }
            Tok::Print => { self.pos += 1; // print(...) as expression call
                self.expect(&Tok::LParen)?; let a = self.arg_list()?;
                Ok(Expr::Call("print".into(), a)) }
            Tok::Ident(name) => {
                self.pos += 1;
                if self.eat(&Tok::LParen) {
                    let args = self.arg_list()?;
                    Ok(Expr::Call(name, args))
                } else { Ok(Expr::Var(name)) }
            }
            t => Err(format!("unexpected token in expression: ?{:?}", t)),
        }
    }
}

