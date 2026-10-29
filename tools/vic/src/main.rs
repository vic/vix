mod clock;
mod error;
mod guard;
mod jq;
mod ledger;
mod statusline;

use error::VicError;
use lexopt::prelude::*;
use std::process::ExitCode;

enum Cmd {
    Statusline,
    HookGuard,
    HookLedger,
}

fn parse_args() -> Result<Cmd, VicError> {
    let usage = |m: &str| VicError::Usage(m.to_owned());
    let mut p = lexopt::Parser::from_env();
    let mut words: Vec<String> = Vec::new();
    while let Some(a) = p.next().map_err(|e| VicError::Usage(e.to_string()))? {
        match a {
            Value(v) => words.push(v.to_string_lossy().into_owned()),
            _ => return Err(usage("vic statusline | vic hook guard | vic hook ledger")),
        }
    }
    match words
        .iter()
        .map(String::as_str)
        .collect::<Vec<_>>()
        .as_slice()
    {
        ["statusline"] => Ok(Cmd::Statusline),
        ["hook", "guard"] => Ok(Cmd::HookGuard),
        ["hook", "ledger"] => Ok(Cmd::HookLedger),
        _ => Err(usage("vic statusline | vic hook guard | vic hook ledger")),
    }
}

fn main() -> ExitCode {
    let code = match parse_args() {
        Ok(Cmd::HookGuard) => guard::run(),
        Ok(Cmd::HookLedger) => ledger::run(),
        Ok(Cmd::Statusline) => match statusline::run() {
            Ok(()) => 0,
            Err(e) => {
                eprintln!("vic: {e}");
                1
            }
        },
        Err(e) => {
            eprintln!("vic: {e}");
            64
        }
    };
    ExitCode::from(u8::try_from(code).unwrap_or(1))
}
