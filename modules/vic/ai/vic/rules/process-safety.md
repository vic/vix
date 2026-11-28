# Processes: kill and wait by PID

- Never `pkill -f`, `killall`, or `kill` on `pgrep -f` output. `-f` matches the full
  command line, and the shell running the command contains the pattern, so it matches
  itself and its parent (it has killed the orchestrator). Kill only PIDs captured with
  `$!` at launch.
- Wait on a `$!` PID (`while kill -0 "$pid"`) or a marker the producer writes, always
  under `timeout`. Never `pgrep -f` from the waiting shell: it never ends.
- A foreground command that hits the tool timeout keeps running in the background. End
  your own waiters before starting new ones.
