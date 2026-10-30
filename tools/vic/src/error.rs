use std::fmt;

/// Every failure a subcommand can surface; `main` maps it to an exit code.
#[derive(Debug)]
pub(crate) enum VicError {
    Usage(String),
    Io(std::io::Error),
    Regex(regex::Error),
    Recall(String),
}

impl fmt::Display for VicError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            VicError::Usage(m) => write!(f, "usage: {m}"),
            VicError::Io(e) => write!(f, "io: {e}"),
            VicError::Regex(e) => write!(f, "regex: {e}"),
            VicError::Recall(m) => write!(f, "recall: {m}"),
        }
    }
}

impl std::error::Error for VicError {}

impl From<std::io::Error> for VicError {
    fn from(e: std::io::Error) -> Self {
        VicError::Io(e)
    }
}

impl From<regex::Error> for VicError {
    fn from(e: regex::Error) -> Self {
        VicError::Regex(e)
    }
}
