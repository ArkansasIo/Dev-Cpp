
// UML — Universal Math Language: lexer
#[derive(Debug, Clone, PartialEq)]
pub enum Tok {
    // literals
    Int(i64),
    Real(f64),
    Str(String),
    Ident(String),
    // keywords
    Let, Function, End, Return, If, Then, Elseif, Else,
    While, Do, For, In, Repeat, Until, Class, Extends, SelfKw,
    True, False, And, Or, Not, Print, Module,
    // symbols
    Plus, Minus, Star, Slash, Percent, Caret, Dot, Comma, Colon,
    LParen, RParen, EqEq, Ne, Lt, Gt, Le, Ge, Assign,
    Eof,
}

pub struct Lexer {
    src: Vec<char>,
    pos: usize,
}

pub fn lex(src: &str) -> Result<Vec<Tok>, String> {
    Lexer { src: src.chars().collect(), pos: 0 }.run()
}

impl Lexer {
    fn peek(&self) -> Option<char> { self.src.get(self.pos).copied() }
    fn peek2(&self) -> Option<char> { self.src.get(self.pos + 1).copied() }
    fn bump(&mut self) -> Option<char> { let c = self.peek(); if c.is_some() { self.pos += 1; } c }

    fn run(&mut self) -> Result<Vec<Tok>, String> {
        let mut toks = Vec::new();
        loop {
            // skip whitespace and comments (-- to end of line)
            loop {
                match self.peek() {
                    Some(c) if c.is_whitespace() => { self.bump(); }
                    Some('-') if self.peek2() == Some('-') => {
                        while let Some(c) = self.bump() { if c == '\n' { break; } }
                    }
                    Some('/') if self.peek2() == Some('/') => {
                        while let Some(c) = self.bump() { if c == '\n' { break; } }
                    }
                    Some('#') => {
                        while let Some(c) = self.bump() { if c == '\n' { break; } }
                    }
                    _ => break,
                }
            }
            let c = match self.bump() { Some(c) => c, None => { toks.push(Tok::Eof); return Ok(toks); } };
            let tok = match c {
                '0'..='9' => self.number(c)?,
                'a'..='z' | 'A'..='Z' | '_' => self.ident(c),
                '"' => self.string()?,
                '+' => Tok::Plus,
                '*' => Tok::Star,
                '/' => Tok::Slash,
                '%' => Tok::Percent,
                '^' => Tok::Caret,
                '.' => Tok::Dot,
                ',' => Tok::Comma,
                '(' => Tok::LParen,
                ')' => Tok::RParen,
                '-' => Tok::Minus,
                ':' => Tok::Colon,
                '=' => if self.peek() == Some('=') { self.bump(); Tok::EqEq } else { Tok::Assign },
                '!' => if self.peek() == Some('=') { self.bump(); Tok::Ne } else { return Err("unexpected '!'".into()) },
                '<' => if self.peek() == Some('=') { self.bump(); Tok::Le } else { Tok::Lt },
                '>' => if self.peek() == Some('=') { self.bump(); Tok::Ge } else { Tok::Gt },
                _ => return Err(format!("unexpected character '{}'", c)),
            };
            toks.push(tok);
        }
    }

    fn number(&mut self, first: char) -> Result<Tok, String> {
        let mut s = String::new();
        s.push(first);
        while let Some(c) = self.peek() {
            if c.is_ascii_digit() { s.push(c); self.bump(); }
            else if c == '.' && self.peek2().map(|n| n.is_ascii_digit()).unwrap_or(false) {
                // real literal like 3.14 — but NOT the '..' range operator
                s.push(c); self.bump();
            }
            else { break; }
        }
        if s.contains('.') {
            s.parse::<f64>().map(Tok::Real).map_err(|e| e.to_string())
        } else {
            s.parse::<i64>().map(Tok::Int).map_err(|e| e.to_string())
        }
    }

    fn ident(&mut self, first: char) -> Tok {
        let mut s = String::new();
        s.push(first);
        while let Some(c) = self.peek() {
            if c.is_alphanumeric() || c == '_' { s.push(c); self.bump(); } else { break; }
        }
        match s.as_str() {
            "let" => Tok::Let, "function" => Tok::Function, "end" => Tok::End,
            "return" => Tok::Return, "if" => Tok::If, "then" => Tok::Then,
            "elseif" => Tok::Elseif, "else" => Tok::Else,
            "while" => Tok::While, "do" => Tok::Do, "for" => Tok::For, "in" => Tok::In,
            "repeat" => Tok::Repeat, "until" => Tok::Until,
            "class" => Tok::Class, "extends" => Tok::Extends,
            "self" => Tok::SelfKw,
            "true" => Tok::True, "false" => Tok::False,
            "and" => Tok::And, "or" => Tok::Or, "not" => Tok::Not,
            "print" => Tok::Print, "module" => Tok::Module,
            _ => Tok::Ident(s),
        }
    }

    fn string(&mut self) -> Result<Tok, String> {
        let mut s = String::new();
        loop {
            match self.bump() {
                Some('"') => break,
                Some(c) => s.push(c),
                None => return Err("unterminated string".into()),
            }
        }
        Ok(Tok::Str(s))
    }
}
