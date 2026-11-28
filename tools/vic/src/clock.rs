//! Time helpers on std only. UTC math is done by hand; local time is delegated
//! to `date(1)` because std has no timezone database
//! (shortcut: one fork per local-time need, upgrade = parse /etc/localtime TZif).
use std::process::{Command, Stdio};
use std::time::{SystemTime, UNIX_EPOCH};

pub(crate) fn now_epoch() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_or(0, |d| i64::try_from(d.as_secs()).unwrap_or(0))
}

/// Days since 1970-01-01 for a proleptic Gregorian date (Hinnant).
fn days_from_civil(y: i64, m: i64, d: i64) -> i64 {
    let y = if m <= 2 { y - 1 } else { y };
    let era = y.div_euclid(400);
    let yoe = y.rem_euclid(400);
    let doy = (153 * (if m > 2 { m - 3 } else { m + 9 }) + 2) / 5 + d - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146_097 + doe - 719_468
}

fn civil_from_days(z: i64) -> (i64, i64, i64) {
    let z = z + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z.rem_euclid(146_097);
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = yoe + era * 400 + i64::from(m <= 2);
    (y, m, d)
}

/// jq `todate`: `YYYY-MM-DDTHH:MM:SSZ` in UTC.
pub(crate) fn iso_utc(epoch: i64) -> String {
    let (y, m, d) = civil_from_days(epoch.div_euclid(86_400));
    let s = epoch.rem_euclid(86_400);
    format!(
        "{y:04}-{m:02}-{d:02}T{:02}:{:02}:{:02}Z",
        s / 3600,
        (s % 3600) / 60,
        s % 60
    )
}

fn num(b: &[u8], from: usize, len: usize) -> Option<i64> {
    let s = b.get(from..from + len)?;
    if !s.iter().all(u8::is_ascii_digit) {
        return None;
    }
    std::str::from_utf8(s).ok()?.parse().ok()
}

/// jq `fromdateiso8601`: strictly `%Y-%m-%dT%H:%M:%SZ`, else None (jq errors).
/// shortcut: stricter than glibc strptime (no 1-digit fields), upgrade if headroom ever emits them.
pub(crate) fn parse_iso_z(s: &str) -> Option<i64> {
    let b = s.as_bytes();
    if b.len() != 20
        || b[4] != b'-'
        || b[7] != b'-'
        || b[10] != b'T'
        || b[13] != b':'
        || b[16] != b':'
        || b[19] != b'Z'
    {
        return None;
    }
    let (y, mo, d) = (num(b, 0, 4)?, num(b, 5, 2)?, num(b, 8, 2)?);
    let (h, mi, sec) = (num(b, 11, 2)?, num(b, 14, 2)?, num(b, 17, 2)?);
    if !(1..=12).contains(&mo) || !(1..=31).contains(&d) || h > 23 || mi > 59 || sec > 61 {
        return None;
    }
    Some(days_from_civil(y, mo, d) * 86_400 + h * 3600 + mi * 60 + sec)
}

/// Run `date <args>` and return stdout without trailing newlines (bash `$(...)`).
pub(crate) fn date(args: &[&str]) -> String {
    Command::new("date")
        .args(args)
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .map(|o| {
            String::from_utf8_lossy(&o.stdout)
                .trim_end_matches('\n')
                .to_owned()
        })
        .unwrap_or_default()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn iso_roundtrip() {
        let t = 1_793_304_000; // 2026-10-29T20:00:00Z
        assert_eq!(iso_utc(t), "2026-10-29T20:00:00Z");
        assert_eq!(parse_iso_z("2026-10-29T20:00:00Z"), Some(t));
    }

    #[test]
    fn iso_rejects_fraction() {
        assert_eq!(parse_iso_z("2026-10-29T21:20:00.5Z"), None);
    }

    #[test]
    fn epoch_zero() {
        assert_eq!(iso_utc(0), "1970-01-01T00:00:00Z");
    }
}
