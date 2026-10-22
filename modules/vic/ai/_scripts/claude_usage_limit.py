#!/usr/bin/env python3
"""Report how much of the current Claude Code 5-hour usage window is already spent.

Three sources, in order of accuracy and of what they cost:

  oauth    the account usage endpoint, read with Claude Code's own OAuth token.
           Exact, spends no quota, but the endpoint is undocumented.
  probe    one tiny `claude -p` call; the server attaches a `rate_limit_event` to
           the stream. Officially visible numbers, costs one model call per reading.
  ccusage  `npx ccusage blocks --active --json`: local transcript accounting.
           Knows your spend, not your limit — a share of a budget you name.

Exit status: 0 below the threshold, 1 at or above it, 2 nothing could be measured.

    python3 claude_usage_limit.py
    python3 claude_usage_limit.py --json --source oauth
    python3 claude_usage_limit.py --warn-pct 90 --cache-sec 600

Stdlib only, Python 3.11+.
"""

import argparse
import hashlib
import json
import os
import subprocess
import sys
import unicodedata
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path

USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
OAUTH_BETA = "oauth-2025-04-20"
KEYCHAIN_SERVICE = "Claude Code-credentials"
CREDENTIALS_FILE = ".credentials.json"
BLOCK_HOURS = 5
APP_NAME = "claude-usage-limit"
DEFAULT_WARN_PCT = 90.0
DEFAULT_CACHE_SEC = 600
DEFAULT_BUDGET_USD = 100.0
SOURCE_ORDER = ("oauth", "probe", "ccusage")

# Plain alias rather than PEP 695 `type`: this has to import on Python 3.11.
Reading = dict[str, object]


# --- where Claude Code keeps its credentials -------------------------------------------


def config_dir() -> Path:
    """Claude Code's config directory: CLAUDE_CONFIG_DIR, else ~/.claude."""
    return Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude")


def keychain_service() -> str:
    """Name of the macOS Keychain item holding the credentials.

    Claude Code appends the first 8 hex characters of the SHA-256 of the NFC-normalized
    config directory path whenever CLAUDE_CONFIG_DIR is set, so parallel configs get
    separate Keychain items; with the variable unset the name carries no suffix.
    """
    configured = os.environ.get("CLAUDE_CONFIG_DIR")
    if not configured:
        return KEYCHAIN_SERVICE
    normalized = unicodedata.normalize("NFC", configured)
    digest = hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:8]
    return f"{KEYCHAIN_SERVICE}-{digest}"


def token_from_keychain() -> str | None:
    """Access token out of the macOS Keychain, or None off macOS / when absent."""
    if sys.platform != "darwin":
        return None
    try:
        raw = subprocess.run(
            ["security", "find-generic-password", "-s", keychain_service(), "-w"],
            capture_output=True, text=True, timeout=20, check=True,
        ).stdout
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError):
        return None
    return token_from_json(raw)


def token_from_file(path: Path) -> str | None:
    """Access token out of a .credentials.json file, or None if unreadable."""
    try:
        return token_from_json(path.read_text(encoding="utf-8"))
    except OSError:
        return None


def token_from_json(raw: str) -> str | None:
    """Pull claudeAiOauth.accessToken out of a credentials blob."""
    try:
        oauth = json.loads(raw).get("claudeAiOauth")
    except (json.JSONDecodeError, AttributeError):
        return None
    if not isinstance(oauth, dict):
        return None
    token = oauth.get("accessToken")
    return token if isinstance(token, str) and token else None


def read_token(spec: str) -> str | None:
    """Access token per --token-from: a named source, or a path to a credentials file.

    The token is re-read on every run rather than remembered: Claude Code refreshes it
    while it works, and a stale copy just earns a 401. Refreshing it here would be
    worse than useless — a competing refresh can invalidate the running session's login.
    """
    if spec == "env":
        return os.environ.get("CLAUDE_CODE_OAUTH_TOKEN") or None
    if spec == "keychain":
        return token_from_keychain()
    if spec == "credentials-file":
        return token_from_file(config_dir() / CREDENTIALS_FILE)
    if spec == "auto":
        return (os.environ.get("CLAUDE_CODE_OAUTH_TOKEN") or None) or token_from_keychain() \
            or token_from_file(config_dir() / CREDENTIALS_FILE)
    return token_from_file(Path(spec).expanduser())


# --- source 1: the account usage endpoint ----------------------------------------------


def fetch_oauth_usage(token: str | None, timeout: int = 15) -> dict | None:
    """Decoded /api/oauth/usage response, or None when it cannot be read.

    401 and 429 are both routine: the token may have just rotated, and the endpoint
    itself is rate limited. The reason goes to stderr; otherwise a silent switch to a
    paid source looks like the numbers simply changed shape.
    """
    if not token:
        return None
    request = urllib.request.Request(USAGE_URL, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "anthropic-beta": OAUTH_BETA,
    })
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as error:
        print(f"oauth: HTTP {error.code}", file=sys.stderr)
        return None
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, OSError) as error:
        print(f"oauth: {type(error).__name__}", file=sys.stderr)
        return None
    return payload if isinstance(payload, dict) else None


def oauth_reading(payload: dict | None) -> Reading | None:
    """Normalize the usage payload, or None when it carries no 5-hour window.

    Percentages here are already 0..100. The `limits` list spells out the same numbers a
    second way and covers the moment right at a window boundary, where the server has
    been seen to return an empty `five_hour` object.
    """
    if payload is None:
        return None
    five = payload.get("five_hour") or {}
    pct, resets = five.get("utilization"), five.get("resets_at")
    if pct is None or not resets:
        for row in payload.get("limits") or []:
            if row.get("kind") == "session" and row.get("percent") is not None:
                pct, resets = row["percent"], row.get("resets_at")
                break
    if pct is None or not resets:
        return None
    week = (payload.get("seven_day") or {}).get("utilization")
    return {
        "source": "oauth",
        "pct": round(float(pct), 1),
        "pct_seven_day": round(float(week), 1) if week is not None else None,
        "resets_at": resets,
        "severity": session_severity(payload),
    }


def session_severity(payload: dict) -> str | None:
    """The server's own label for the 5-hour limit (normal, warning, ...)."""
    for row in payload.get("limits") or []:
        if row.get("kind") == "session":
            return row.get("severity")
    return None


# --- source 2: a probe call that makes the server report its own limits -----------------


def probe_rate_limits(model: str, timeout: int = 180) -> dict | None:
    """rate_limit_info from a minimal `claude -p` call, or None if the probe fails."""
    command = [
        "claude", "-p", "ok", "--model", model, "--max-turns", "1",
        "--output-format", "stream-json", "--verbose",
    ]
    # A non-zero exit is ignored on purpose: the event is already on stdout, and the
    # CLI can still fail afterwards on something unrelated, such as a hook or plugin.
    try:
        out = subprocess.run(command, capture_output=True, text=True, timeout=timeout,
                             check=False).stdout
    except (subprocess.TimeoutExpired, OSError):
        return None
    return parse_rate_limit_event(out)


def parse_rate_limit_event(stream: str) -> dict | None:
    """rate_limit_info out of a line-delimited stream-json transcript."""
    for raw in stream.splitlines():
        line = raw.strip()
        if not line.startswith("{"):
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "rate_limit_event":
            info = event.get("rate_limit_info")
            return info if isinstance(info, dict) else None
    return None


def probe_reading(info: dict | None) -> Reading | None:
    """Normalize rate_limit_info; utilization is 0..1 here, unlike the usage endpoint."""
    windows = (info or {}).get("unifiedWindows") or {}
    five = windows.get("five_hour") or {}
    if five.get("utilization") is None or not five.get("resetsAt"):
        return None
    week = (windows.get("seven_day") or {}).get("utilization")
    resets = datetime.fromtimestamp(float(five["resetsAt"]), timezone.utc)
    return {
        "source": "probe",
        "pct": round(float(five["utilization"]) * 100, 1),
        "pct_seven_day": round(float(week) * 100, 1) if week is not None else None,
        "resets_at": resets.isoformat(),
        "severity": (info or {}).get("status"),
    }


# --- source 3: local transcript accounting ---------------------------------------------


def ccusage_block(timeout: int = 180) -> dict | None:
    """The active 5-hour block reported by ccusage, or None if there is none."""
    try:
        out = subprocess.run(
            ["npx", "-y", "ccusage@latest", "blocks", "--active", "--json"],
            capture_output=True, text=True, timeout=timeout, check=True,
        ).stdout
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError):
        return None
    try:
        blocks = json.loads(out).get("blocks") or []
    except (json.JSONDecodeError, AttributeError):
        return None
    return blocks[0] if blocks else None


def ccusage_reading(block: dict | None, budget_usd: float) -> Reading | None:
    """Normalize a ccusage block. The percentage is a share of `budget_usd`, not of a
    limit: ccusage reads local transcripts and has no idea what the account allows."""
    if block is None or not block.get("endTime"):
        return None
    cost = float(block.get("costUSD") or 0.0)
    return {
        "source": "ccusage",
        "note": "share of a budget you set, not of the real limit",
        "pct": round(cost / budget_usd * 100, 1) if budget_usd else 0.0,
        "pct_seven_day": None,
        "resets_at": block["endTime"].replace("Z", "+00:00"),
        "cost_usd": round(cost, 2),
        "budget_usd": budget_usd,
        "total_tokens": block.get("totalTokens"),
    }


# --- cache ------------------------------------------------------------------------------


def cache_path() -> Path:
    """Per-user cache file, in the conventional cache directory for the platform."""
    if sys.platform == "darwin":
        base = Path.home() / "Library" / "Caches"
    elif sys.platform == "win32":
        base = Path(os.environ.get("LOCALAPPDATA") or Path.home() / "AppData" / "Local")
    else:
        base = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
    return base / APP_NAME / "reading.json"


def write_cache(reading: Reading) -> None:
    """Remember a live reading so a later failure has something to fall back on."""
    body = {"cached_at": datetime.now(timezone.utc).isoformat(), "reading": reading}
    try:
        path = cache_path()
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(body), encoding="utf-8")
    except OSError:
        pass


def read_cache(max_age_sec: int, now: datetime) -> tuple[Reading | None, int]:
    """(cached reading, its age in seconds), or (None, 0) when there is nothing usable.

    The cache is a fallback, never a shortcut: it is consulted only after the live read
    has already failed, so a 429 on the usage endpoint does not push the run onto a
    source that costs a model call.
    """
    try:
        body = json.loads(cache_path().read_text(encoding="utf-8"))
        cached_at = datetime.fromisoformat(body["cached_at"])
        reading = body["reading"]
    except (OSError, json.JSONDecodeError, KeyError, TypeError, ValueError):
        return None, 0
    age = (now - cached_at).total_seconds()
    if not 0 <= age <= max_age_sec:
        return None, 0
    return reading, round(age)


# --- measuring --------------------------------------------------------------------------


def round_to_minute(moment: datetime) -> datetime:
    """UTC copy of `moment` rounded to the nearest minute.

    The reset timestamp jitters by fractions of a second between responses, which makes
    two readings of the same window look like two different windows.
    """
    return (moment.astimezone(timezone.utc) + timedelta(seconds=30)).replace(
        second=0, microsecond=0)


def finalize(reading: Reading, warn_pct: float, now: datetime,
             cache_age_sec: int | None) -> dict:
    """Turn a normalized reading into the reported status."""
    end = round_to_minute(datetime.fromisoformat(str(reading["resets_at"])))
    pct = float(reading["pct"])
    status = dict(reading)
    status.update({
        "ok": True,
        "warn_pct": warn_pct,
        "over_warn": pct >= warn_pct,
        "window_hours": BLOCK_HOURS,
        "window_start": (end - timedelta(hours=BLOCK_HOURS)).isoformat(),
        "resets_at": end.isoformat(),
        "resets_at_local": end.astimezone().isoformat(),
        "minutes_to_reset": max(0, round((end - now).total_seconds() / 60)),
        "from_cache": cache_age_sec is not None,
        "cache_age_sec": cache_age_sec,
        "measured_at": now.isoformat(),
    })
    return status


def live_reading(source: str, options: argparse.Namespace) -> Reading | None:
    """One attempt at the named source, without any cache involved."""
    if source == "oauth":
        return oauth_reading(fetch_oauth_usage(read_token(options.token_from)))
    if source == "probe":
        return probe_reading(probe_rate_limits(options.probe_model))
    return ccusage_reading(ccusage_block(), options.budget_usd)


def measure(options: argparse.Namespace, now: datetime | None = None) -> dict:
    """Current status: try the requested sources, then fall back to a fresh cache entry."""
    now = now or datetime.now(timezone.utc)
    sources = SOURCE_ORDER if options.source == "auto" else (options.source,)
    for source in sources:
        reading = live_reading(source, options)
        if reading is not None:
            write_cache(reading)
            return finalize(reading, options.warn_pct, now, None)
    cached, age = read_cache(options.cache_sec, now)
    if cached is not None:
        status = finalize(cached, options.warn_pct, now, age)
        # A cached reading is worthless once its window has rolled over: the spend it
        # reports belongs to a window that no longer exists.
        if status["minutes_to_reset"] > 0:
            return status
    tried = ", ".join(sources)
    return {"ok": False, "reason": f"no source could measure the window (tried: {tried})"}


# --- output -----------------------------------------------------------------------------


def render(status: dict) -> str:
    """One human-readable line."""
    if not status["ok"]:
        return f"usage: {status['reason']}"
    local = datetime.fromisoformat(status["resets_at_local"]).strftime("%H:%M")
    parts = [
        f"5h window: {status['pct']}% used",
        f"[{status['source']}" + (f", cached {status['cache_age_sec']}s ago]"
                                  if status["from_cache"] else "]"),
        f"resets {status['resets_at']} ({local} local, in {status['minutes_to_reset']} min)",
    ]
    if status.get("pct_seven_day") is not None:
        parts.append(f"7d window: {status['pct_seven_day']}%")
    if status.get("note"):
        parts.append(str(status["note"]))
    if status["over_warn"]:
        parts.append(f"OVER {status['warn_pct']}%")
    return " | ".join(parts)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Command line, with --token-from accepting a named source or a file path."""
    parser = argparse.ArgumentParser(
        description=__doc__.split("\n", 1)[0],
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="exit 0 below the threshold, 1 at or above it, 2 nothing measured",
    )
    parser.add_argument("--source", default="auto", choices=("auto", *SOURCE_ORDER),
                        help="where to read from; auto tries each in turn (default: auto)")
    parser.add_argument("--json", action="store_true", help="machine-readable output")
    parser.add_argument("--warn-pct", type=float, default=DEFAULT_WARN_PCT,
                        help=f"threshold for exit status 1 (default: {DEFAULT_WARN_PCT})")
    parser.add_argument("--cache-sec", type=int, default=DEFAULT_CACHE_SEC,
                        help=f"how stale a fallback may be (default: {DEFAULT_CACHE_SEC})")
    parser.add_argument("--token-from", default="auto", metavar="SOURCE",
                        help="keychain | credentials-file | env | auto | path to a "
                             "credentials JSON file (default: auto)")
    parser.add_argument("--probe-model", default="haiku",
                        help="model used by --source probe (default: haiku)")
    parser.add_argument("--budget-usd", type=float, default=DEFAULT_BUDGET_USD,
                        help=f"budget the ccusage percentage is a share of "
                             f"(default: {DEFAULT_BUDGET_USD})")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    options = parse_args(argv)
    status = measure(options)
    print(json.dumps(status, indent=2) if options.json else render(status))
    if not status["ok"]:
        return 2
    return 1 if status["over_warn"] else 0


if __name__ == "__main__":
    sys.exit(main())
