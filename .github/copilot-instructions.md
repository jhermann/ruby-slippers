# Copilot Instructions for ruby-slippers

This repository is a **dotfiles and developer environment automation** framework for Linux/WSL. Its metaphor is Wizard of Oz: "There's no place like home." It provisions a reproducible developer environment via three orchestration scripts.

## Setup Scripts

The three main entry points (run in order):

```bash
./click-click-click.sh        # Symlink home/ skeleton into $HOME; link AI skills to Copilot dir
./tinmans-heart.sh all        # Install system packages via apt from packages/deb-*.txt lists
./scarecrows-brain.sh         # Install user-level Python tools into isolated venvs
```

Dry-run support (previews without making changes):
```bash
./click-click-click.sh -n           # Preview all links
./click-click-click.sh -n bashrc    # Preview only files matching *bashrc*
```

Sort/deduplicate a package list:
```bash
./tinmans-heart.sh sort
```

## Architecture

```
ruby-slippers/
├── home/               # Dotfiles → symlinked into $HOME by click-click-click.sh
│   ├── .bashrc.d/      # Modular bash init: one file per tool/platform (python.sh, git.sh, …)
│   ├── .bash_completion.d/
│   ├── .config/eg/examples/   # eg tool examples (shell, ffmpeg, pandoc, web-apis, …)
│   ├── bin/            # Custom scripts; .sh/.py extensions are stripped on install
│   └── …               # .gitconfig, .vimrc, .pylintrc, .ansible.cfg, etc.
├── packages/           # Plain-text apt package lists (deb-core.txt, deb-dev.txt, …)
├── ai/skills/          # GitHub Copilot custom agent skills
│   └── technical-writing/SKILL.md
├── apps/               # App-specific installers (gedit/, git/)
├── python/             # Standalone Python utilities (sftpsync.py)
├── etc/profile.d/      # System-wide shell profile snippets
├── wsl/                # Windows Subsystem for Linux extras
├── click-click-click.sh
├── tinmans-heart.sh
└── scarecrows-brain.sh
```

**Symlinking logic** (`click-click-click.sh`):
- Missing target → `ln -s` to create
- Existing symlink pointing elsewhere → `ln -nfs` to update
- Existing regular file with different content → warn and skip (manual resolution needed)
- `home/bin/script.sh` → `~/.local/bin/script` (extension stripped)
- Stale symlinks (broken target) are cleaned up automatically

**AI skills integration**: `click-click-click.sh` also symlinks every subdirectory of `ai/skills/` into `~/.local/share/copilot/skills/` so GitHub Copilot picks them up as custom agent skills.

## Conventions

### Shell scripts
- Dry-run pattern: `test "$1" = "-n" && DRY="echo WOULD call:"; shift`
- Platform detection: test `$SYSTEMROOT` and `$WINDIR` for Windows/WSL
- Skip-if-present pattern for packages: `dpkg -l "$pkg" | egrep "^ii"`
- Scripts use `#!/bin/bash` and POSIX-friendly constructs where possible

### Package lists (`packages/deb-*.txt`)
- One package name per line; comments start with `#`
- Categories: `deb-core.txt`, `deb-dev.txt`, `deb-reporting.txt`, `deb-tools.txt`, `desktop.txt`

### Bash init files (`home/.bashrc.d/`)
- One file per language/tool/platform: `python.sh`, `java.sh`, `go.sh`, `ruby.sh`, `rust.sh`, `git.sh`, `docker.sh`, `windows.sh`, `debian.sh`, `nvm.sh`, `linuxbrew.sh`
- Loaded in alphabetical order; `0util.rc` loads first (utility functions)

### AI skills (`ai/skills/<skill-name>/SKILL.md`)
- YAML frontmatter with `name`, `description`, `when_to_use`, `instructions`, `examples`
- Follow the template in `ai/skills/technical-writing/SKILL.md`

## WSL (Windows Subsystem for Linux)

`wsl/bin/` contains thin wrapper scripts that forward commands to Windows executables (e.g. `wsl/bin/firefox` execs `firefox.exe` from `Program Files`). These are symlinked into `~/.local/bin/` by `click-click-click.sh` like any other `bin/` script.

WSL/Windows environment setup lives in `home/.bashrc.d/windows.sh`, which branches on two cases:

- **WSL v1** (`/proc/version` contains `Microsoft`): sets `DISPLAY=:0`, `LIBGL_ALWAYS_INDIRECT=1`, `BROWSER=wslview`, aliases `xdg-open` → `wslview`, starts `ssh-agent`
- **Git Bash / MinGW** (`$SYSTEMROOT` + `$WINDIR` set): scrubs broken Java/WindowsApps entries from `PATH`, sets UTF-8 env vars (`LANG`, `PYTHONIOENCODING`, `PYTHONUTF8`), aliases `xdg-open` → `start`, wraps `docker`/`python3` with `winpty`, remaps ImageMagick commands (`convert` → `magick convert`, etc.)

When adding new Windows-bridging scripts, place them in `wsl/bin/` (not `home/bin/`) and add corresponding aliases or env vars to `windows.sh` if shell integration is needed.

## Key Files

| File | Purpose |
|------|---------|
| `home/.gitconfig` | Global git config (symlinked) |
| `home/.pylintrc` | Pylint defaults for all Python work |
| `home/.invoke.yaml` | Invoke task-runner defaults |
| `home/.env` | Environment variable stubs |
| `home/.bashrc.d/` | Modular bash init files (one per tool/platform) |
| `packages/deb-*.txt` | Apt package lists (core, dev, reporting, tools, desktop) |
| `ai/skills/` | Custom GitHub Copilot agent skills (symlinked) |
| `apps/` | App-specific installers (e.g. `apps/gedit/install.sh`) |
| `python/` | Standalone Python utilities (e.g. `python/sftpsync.py`) |
| `wsl/bin/` | | Windows-bridging scripts for WSL (e.g. `wsl/bin/firefox`) |
| `click-click-click.sh` | Symlink home/ skeleton and AI skills |
| `tinmans-heart.sh` | Install apt packages from lists |
| `scarecrows-brain.sh` | Install user-level Python tools into venvs |
