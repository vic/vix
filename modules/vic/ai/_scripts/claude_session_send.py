#!/usr/bin/env python3
"""Send a message to a running Claude Code session from a shell script.

Claude Code registers every live session in its own file, `~/.claude/sessions/<pid>.json`,
and listens on the unix socket named there (`/tmp/cc-socks/<pid>.sock`). This writes one
JSON line to that socket; the session picks the text up as if a peer session had messaged
it.

The registry is the only reliable index: sockets in /tmp/cc-socks outlive their
processes, so the directory lists dead sessions too.

The protocol is undocumented and can change between Claude Code releases.
"""

import argparse
import json
import os
import re
import socket
import sys
import uuid
from dataclasses import dataclass
from pathlib import Path

REGISTRY = Path.home() / ".claude" / "sessions"
SOCKET_TIMEOUT = 5.0
TAG = "cross-session-message"
DEFAULT_SENDER = "script"
# The receiver parses the wrapper with a regex and only accepts these characters in the
# from-address; anything else is dropped silently.
SENDER_RE = re.compile(r"^[A-Za-z0-9%:_/.-]+$")
# The receiver knows exactly two sender modes: "prompting" and "bypass". A message whose
# mode does not match the receiving session's permission mode class is not shown right
# away — it is parked as a held peer message until the user releases it.
MODES = ("prompting", "bypass")


@dataclass(frozen=True, slots=True)
class Session:
    """A live Claude Code session with a message socket."""

    pid: int
    name: str | None
    socket: Path
    cwd: str | None
    session_id: str | None = None


def running(pid: int) -> bool:
    """Whether the process exists. PermissionError means it exists but is not ours."""
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    except OSError:
        return False
    return True


def parse_record(text: str) -> Session | None:
    """Registry record -> session, or None if it has no message socket."""
    try:
        data = json.loads(text)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return None
    pid, socket_path = data.get("pid"), data.get("messagingSocketPath")
    if not isinstance(pid, int) or not socket_path:
        return None
    return Session(
        pid=pid,
        name=data.get("name"),
        socket=Path(socket_path),
        cwd=data.get("cwd"),
        session_id=data.get("sessionId"),
    )


def live(registry: Path | None = None) -> list[Session]:
    """Sessions whose process is alive and whose socket file is present."""
    found: list[Session] = []
    for path in sorted((registry or REGISTRY).glob("*.json")):
        try:
            session = parse_record(path.read_text(encoding="utf-8"))
        except OSError:
            continue
        if session and running(session.pid) and session.socket.exists():
            found.append(session)
    return found


def pick_by_name(candidates: list[Session], name: str) -> tuple[Session | None, str]:
    """The single live session with this name; otherwise a reason listing candidates.

    Session names are not unique, so an ambiguous name means delivering nothing at all
    rather than delivering to a namesake that is not expecting the message.
    """
    matched = [s for s in candidates if s.name == name]
    if not matched:
        return None, f"no live session named {name!r}"
    if len(matched) > 1:
        pids = ", ".join(str(s.pid) for s in matched)
        return None, f"several live sessions named {name!r} (pids {pids}) — be explicit with --pid"
    return matched[0], ""


def pick_by_pid(candidates: list[Session], pid: int) -> tuple[Session | None, str]:
    """The live session with this pid, or a reason."""
    for session in candidates:
        if session.pid == pid:
            return session, ""
    return None, f"no live session with pid {pid}"


def wrap(body: str, sender: str, sender_name: str, mode: str) -> str:
    """The receiver's wrapper markup; deviations are silently dropped."""
    return (
        f'<{TAG} from="{sender}" from-name="{sender_name}" from-mode="{mode}">\n'
        f"{body}\n</{TAG}>"
    )


def frame(body: str, sender: str, sender_name: str, mode: str) -> bytes:
    """One cc-socks protocol frame: a single line of JSON."""
    payload = {
        "msgV": 1,
        "msg_id": str(uuid.uuid4()),
        "type": "user",
        "message": {"role": "user", "content": wrap(body, sender, sender_name, mode)},
        "priority": "next",
        "from": sender,
    }
    return (json.dumps(payload, ensure_ascii=False) + "\n").encode()


def send_frame(socket_path: Path, payload: bytes, timeout: float = SOCKET_TIMEOUT) -> None:
    """Write a frame to the session socket. The receiver sends no reply."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        sock.connect(str(socket_path))
        sock.sendall(payload)
        sock.shutdown(socket.SHUT_WR)


def ping(socket_path: Path, timeout: float = SOCKET_TIMEOUT) -> bool:
    """Connect without sending a byte, which delivers nothing and only probes the listener.

    A socket file left behind by a dead session refuses the connection, so the file's
    existence proves nothing on its own.
    """
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            sock.connect(str(socket_path))
    except OSError:
        return False
    return True


def send_to(target: Session, body: str, sender: str, sender_name: str, mode: str) -> str:
    """Deliver text to one session. Empty string on success, otherwise the reason.

    The sender has no socket of its own, so the session cannot reply over cc-socks. If it
    tries, the attempt fails visibly on its side rather than vanishing without a trace.
    """
    try:
        send_frame(target.socket, frame(body, sender, sender_name, mode))
    except OSError as error:
        return f"session pid {target.pid} did not accept the message: {type(error).__name__}"
    return ""


def format_list(sessions: list[Session]) -> str:
    """Human-readable table of live sessions."""
    if not sessions:
        return "no live sessions"
    rows = [("PID", "NAME", "CWD", "SOCKET")]
    rows += [
        (str(s.pid), s.name or "-", s.cwd or "-", str(s.socket))
        for s in sessions
    ]
    widths = [max(len(row[i]) for row in rows) for i in range(3)]
    return "\n".join(
        f"{r[0]:<{widths[0]}}  {r[1]:<{widths[1]}}  {r[2]:<{widths[2]}}  {r[3]}" for r in rows
    )


def read_body(text: str | None) -> str:
    """Message body from the argument, or from stdin when it is '-' or missing."""
    if text is None or text == "-":
        return sys.stdin.read().strip()
    return text


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Send a message to a running Claude Code session over its cc-socks socket."
    )
    target = parser.add_mutually_exclusive_group()
    target.add_argument("--name", help="target session name (must match exactly one)")
    target.add_argument("--pid", type=int, help="target session pid")
    parser.add_argument("--list", action="store_true", help="list live sessions and exit")
    parser.add_argument("--ping", action="store_true", help="probe the target, send nothing")
    parser.add_argument("--from", dest="sender", default=DEFAULT_SENDER,
                        help=f"sender address (default: {DEFAULT_SENDER})")
    parser.add_argument("--from-name", help="human-readable sender label (default: --from)")
    parser.add_argument("--mode", choices=MODES, default=MODES[0],
                        help="sender permission mode class (default: prompting)")
    parser.add_argument("--registry", type=Path, default=None,
                        help=f"session registry directory (default: {REGISTRY})")
    parser.add_argument("text", nargs="?", help="message text, or '-' to read stdin")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    sessions = live(args.registry)

    if args.list:
        print(format_list(sessions))
        return 0

    if not SENDER_RE.match(args.sender):
        print(f"--from must match {SENDER_RE.pattern}", file=sys.stderr)
        return 2

    if args.name:
        target, reason = pick_by_name(sessions, args.name)
    elif args.pid is not None:
        target, reason = pick_by_pid(sessions, args.pid)
    else:
        print("give --name or --pid (or --list)", file=sys.stderr)
        return 2

    if target is None:
        print(reason, file=sys.stderr)
        if sessions:
            print(format_list(sessions), file=sys.stderr)
        return 1

    if args.ping:
        alive = ping(target.socket)
        print(f"{'ok' if alive else 'no listener'}: pid {target.pid} {target.socket}")
        return 0 if alive else 1

    body = read_body(args.text)
    if not body:
        print("empty message", file=sys.stderr)
        return 2

    failure = send_to(target, body, args.sender, args.from_name or args.sender, args.mode)
    if failure:
        print(failure, file=sys.stderr)
        return 1
    print(f"sent to pid {target.pid} ({target.name or '-'})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
