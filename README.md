# firstmate-cli

Two CLI companions that make [firstmate](https://github.com/KakkoiDev/firstmate) usable from anywhere, with zero manual steps:

| Command       | What it does                                                        |
| ------------- | ------------------------------------------------------------------- |
| `firstmate`   | Boot (or attach to) the firstmate tmux session with Pi loaded       |
| `secondmate`  | Adopt any git worktree into the firstmate fleet                     |

- `firstmate` works from any directory — no need to `cd ~/Code/firstmate` first.
- `secondmate` registers a project with firstmate in one command, so crewmates can be dispatched for it.

## Requirements

- **tmux** — `brew install tmux`
- **pi** (the Pi coding agent) — `npm i -g @earendil-works/pi-coding-agent`
- **firstmate repo** at `~/Code/firstmate` — `git clone https://github.com/KakkoiDev/firstmate.git ~/Code/firstmate`
- **`~/.local/bin` on your PATH** (see [Troubleshooting](#troubleshooting))

## Install

From a checkout:

```sh
./install.sh
# or
make install
```

Remote, one command:

```sh
curl -fsSL https://raw.githubusercontent.com/KakkoiDev/firstmate-cli/main/install.sh | bash
```

Install symlinks `bin/firstmate` and `bin/secondmate` into `~/.local/bin` (creating it if needed). Run it again any time to refresh the links after updating the repo.

### Uninstall

```sh
make uninstall
# or
rm -f ~/.local/bin/firstmate ~/.local/bin/secondmate
```

## `firstmate`

Boots the firstmate session in `~/Code/firstmate` with Pi loaded. If the session already exists, attaches to it instead.

```sh
firstmate
```

```
Starting firstmate in /Users/you/Code/firstmate ...
Firstmate session 'firstmate-main' started with Pi.
  Attach:  tmux attach -t firstmate-main
  Detach:  prefix + d
```

The session is named `firstmate-main`. Detach with your tmux prefix + `d`, and `firstmate` will reattach you next time. Run outside a terminal (e.g. from a script)? It prints attach instructions instead of attaching.

Environment overrides:

| Variable           | Default                    | Purpose                         |
| ------------------ | -------------------------- | ------------------------------- |
| `FIRSTMATE_DIR`    | `~/Code/firstmate`         | Where the firstmate repo lives  |
| `FIRSTMATE_SESSION`| `firstmate-main`           | tmux session name               |
| `PI_STARTUP_WAIT`  | `3`                        | Seconds to wait for Pi to boot  |

## `secondmate`

Adopts any git worktree into the firstmate fleet: detects the project from the worktree's `origin` remote, registers it in firstmate's `data/projects.md`, and clones it into `projects/<name>/`. Firstmate becomes immediately aware of the project and can dispatch crewmates for it.

```sh
secondmate ~/Code/my-app            # adopt, default mode (no-mistakes)
secondmate ~/Code/my-app --persist  # adopt + persistent secondmate home
secondmate ~/Code/my-app --yolo     # adopt, yolo merges on
secondmate ~/Code/my-app --cleanup  # unregister + remove the clone
```

```
=== my-app is ready ===

  Worktree:    ~/Code/my-app
  Clone:       ~/Code/firstmate/projects/my-app
  Mode:        no-mistakes

  You can now say:
    'fix the login bug in my-app'
    'review PR #42 in my-app'
    'add tests for the auth module in my-app'

  Firstmate will dispatch crewmates in isolated treehouse worktrees.
  After PRs merge, fleet sync updates ~/Code/firstmate/projects/my-app.

  Pull into your worktree when ready:
    git -C ~/Code/my-app pull origin main
```

Flags:

| Flag               | Description                                                          |
| ------------------ | -------------------------------------------------------------------- |
| `--name <id>`      | Secondmate id (default: derived from the project name)               |
| `--mode <mode>`    | Delivery mode: `no-mistakes`, `direct-PR`, or `local-only` (default `no-mistakes`) |
| `--yolo`           | Let firstmate make routine merge decisions                           |
| `--persist`        | Create a persistent secondmate home (survives restarts)              |
| `--cleanup`        | Unregister the project and remove its clone; **the worktree is never touched** |
| `-h`, `--help`     | Show help                                                            |

`--persist` provisions a dedicated secondmate home under `~/.local/share/firstmate-secondmates/<name>` (via firstmate's `fm-home-seed.sh`). Tear it down later with `~/Code/firstmate/bin/fm-teardown.sh <name>` — it refuses while work is in flight.

## How adoption works

1. The project name is derived from the worktree's `origin` remote URL.
2. A line is written to firstmate's `data/projects.md` in the format firstmate's own tooling parses: `- <name> [<mode> +yolo] - secondmate adoption (added <date>)`.
3. The project is cloned into `~/Code/firstmate/projects/<name>/`; fleet sync keeps that clone up to date after merges.
4. Crewmates are dispatched into isolated treehouse worktrees; your original worktree is untouched.

## Troubleshooting

- **`firstmate: command not found`** — `~/.local/bin` isn't on your PATH. Add it: `export PATH="$HOME/.local/bin:$PATH"` (put it in `~/.zshrc`).
- **`error: tmux is not installed`** — `brew install tmux`.
- **`error: pi is not installed`** — `npm i -g @earendil-works/pi-coding-agent`.
- **`error: firstmate repo not found`** — clone it: `git clone https://github.com/KakkoiDev/firstmate.git ~/Code/firstmate`.
- **`error: no 'origin' remote`** — the worktree has no origin: `git -C <path> remote add origin <url>`.
- **`--cleanup` warns the clone's origin differs** — the clone directory wasn't removed because it isn't the clone this adoption created; remove it by hand if it's safe.
