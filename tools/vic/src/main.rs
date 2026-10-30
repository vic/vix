mod boot;
mod clock;
mod error;
mod guard;
mod jq;
mod ledger;
mod mark;
mod recall;
mod statusline;

use error::VicError;
use lexopt::prelude::*;
use std::path::PathBuf;
use std::process::ExitCode;

enum Cmd {
    Statusline,
    HookGuard,
    HookLedger,
    HookBoot,
    HookRecall,
    HookMark,
    RecallBuild(Option<PathBuf>),
}

const USAGE: &str =
    "vic statusline | vic hook guard|ledger|boot|recall|mark | vic recall build [--db PATH]";

fn parse_args() -> Result<Cmd, VicError> {
    let usage = || VicError::Usage(USAGE.to_owned());
    let mut p = lexopt::Parser::from_env();
    let mut words: Vec<String> = Vec::new();
    let mut db: Option<PathBuf> = None;
    while let Some(a) = p.next().map_err(|e| VicError::Usage(e.to_string()))? {
        match a {
            Value(v) => words.push(v.to_string_lossy().into_owned()),
            Long("db") => {
                db = Some(PathBuf::from(
                    p.value().map_err(|e| VicError::Usage(e.to_string()))?,
                ));
            }
            _ => return Err(usage()),
        }
    }
    match (
        words
            .iter()
            .map(String::as_str)
            .collect::<Vec<_>>()
            .as_slice(),
        db,
    ) {
        (["statusline"], None) => Ok(Cmd::Statusline),
        (["hook", "guard"], None) => Ok(Cmd::HookGuard),
        (["hook", "ledger"], None) => Ok(Cmd::HookLedger),
        (["hook", "boot"], None) => Ok(Cmd::HookBoot),
        (["hook", "recall"], None) => Ok(Cmd::HookRecall),
        (["hook", "mark"], None) => Ok(Cmd::HookMark),
        (["recall", "build"], db) => Ok(Cmd::RecallBuild(db)),
        _ => Err(usage()),
    }
}

fn main() -> ExitCode {
    let code = match parse_args() {
        Ok(Cmd::HookGuard) => guard::run(),
        Ok(Cmd::HookLedger) => ledger::run(),
        Ok(Cmd::HookBoot) => boot::run(),
        Ok(Cmd::HookRecall) => recall::run_hook(),
        Ok(Cmd::HookMark) => mark::run(),
        Ok(Cmd::RecallBuild(db)) => match recall::build(db) {
            Ok(()) => 0,
            Err(e) => {
                eprintln!("vic: {e}");
                1
            }
        },
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
