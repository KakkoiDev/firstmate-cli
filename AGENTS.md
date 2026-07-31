# Project agent memory

This repo ships two standalone CLI companions for the firstmate agent fleet: `firstmate` (boots/attaches the `firstmate-main` tmux session with Pi) and `secondmate` (adopts a git worktree into the fleet). See `README.md` for usage.

## Layout

- `bin/firstmate`, `bin/secondmate` — the commands; must pass `shellcheck` clean
- `install.sh` — symlinks `bin/` into `~/.local/bin`; works both from a checkout and piped via curl (`BASH_SOURCE[0]` is empty in the piped case, so it downloads from GitHub raw then)
- `Makefile` — `install` / `uninstall` targets

## Sharp edges

- `secondmate` is self-contained on purpose: it does detect/register/clone itself (mirroring firstmate's `fm-adopt.sh`) rather than depending on it, so the CLI works without firstmate's bin scripts. `--persist` does shell out to firstmate's `fm-home-seed.sh` (optional; warns if absent).
- Registry format contract: `secondmate` writes `- <name> [<mode> +yolo] - <desc> (added <date>)` to firstmate's `data/projects.md`. The authoritative parser is firstmate's `bin/fm-project-mode.sh` — keep entries compatible with it. Only `<name>`, the bracketed mode tag, and yolo matter; everything after is prose.
- Detect "is a git repo" with `git rev-parse --git-dir`, not `[ -d .git ]` — linked worktrees have `.git` as a file.
- tmux targeting: `firstmate` sends keys to the session's first window by name (`$SESSION:firstmate`) rather than numeric indexes; user configs set 1-based indexes, so numeric targets are fragile.
- Both commands support `FIRSTMATE_DIR` (and `FM_HOME` for secondmate) env overrides — used to point at a test home.
- `firstmate` must not fail when run outside a TTY; it prints attach instructions and exits 0.

## Testing

- `shellcheck bin/*.sh install.sh` must be clean (gate).
- Test `secondmate` without touching the real fleet: set `FM_HOME` to a temp dir and adopt a scratch worktree clone.
- `make install`/`uninstall` and `install.sh` (both modes) are exercised before shipping.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
