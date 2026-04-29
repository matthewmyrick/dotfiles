# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal macOS dotfiles. `install.sh` is the single orchestrator; all other directories are either source configs that get copied into `~/.config/*`, `~/`, or `~/.claude/`, or runtime-loaded shell modules.

## Common Commands

```bash
# Full install (interactive — prompts y/n). One-way, destructive for some configs.
./install.sh

# Targeted install — preferred for iterating on a single component.
./install.sh --install <target>
# Targets: brew, nvim, nvim-dbee, nvim-postgres, nvim-aws-s3, nvim-aws-secrets,
#          sketchybar, ghostty, scripts, hammerspoon, claude, prompt, ssm,
#          procrastinate, git, zshrc, kubernetes
./install.sh --help   # authoritative list

# Verify after install
./scripts/verify_installation.sh

# Test a single install step directly (bypasses the y/n prompt)
bash install/<category>/<script>.sh
```

## Architecture

### Install system (`install.sh` + `install/`)

`install.sh` is ~1200 lines of bash. It has two modes:

1. **Full install** (`installDotfiles`): runs a hard-coded, phased sequence (dependencies → SDKs → macOS → CLIs → dotfiles → applications). Steps are numbered and print `Step N/total` headers.
2. **Targeted install** (`install<Target>Only` functions): one function per `--install <target>`. When adding a new target, you must update **three** places: the `case` in argument parsing (validation), the main `case` at the bottom (the interactive prompt block), and the `unset` cleanup line at EOF.

`install/` is organized by category (`dependencies/`, `dotfiles/`, `sdks/`, `clis/`, `development/`, `macos/`, `ai/`). Individual scripts are idempotent: they check for existing installs before acting and use `|| true` for non-critical commands. The per-step scripts in `install/dotfiles/*.sh` are the actual copy/symlink logic — `install.sh` just dispatches to them.

### Shell module system (`scripts/shell/`)

Shell functions are split into category subdirs (`git/`, `navigation/`, `aws/`, `utilities/`, etc.) and loaded eagerly by `scripts/shell/loader.sh`, which `find`s and sources every `*.sh` under `SHELL_MODULES_DIR` except itself. Despite README claims of lazy loading, the current loader sources everything at startup.

Runtime path: `~/GitHub/matthewmyrick/dotfiles/scripts/shell/` (note the capitalized `GitHub` — the source repo is at `~/Github/matthewmyrick/dotfiles/` on some machines). `.zshrc` sources the loader from the runtime path; changes to `scripts/shell/*` in this repo only take effect after `./install.sh --install scripts` copies them over.

Adding a new module: drop `scripts/shell/<category>/<name>.sh` defining functions, then add a detection line to `shell_loaded()` in `loader.sh` if you want it to show up in status output.

### Multiple Neovim configs

Five separate Neovim configurations coexist, each installed to `~/.config/<name>/` and launched via `NVIM_APPNAME`:

- `nvim/` — primary LazyVim-based config
- `nvim-dbee/` — generic DB client (`dbc` alias)
- `nvim-postgres/` — PostgreSQL-specific, seeds `~/.local/share/nvim-postgres/postgres/connections.json` with a localhost default on install
- `nvim-aws-s3/` — S3 browser, requires configured AWS CLI
- `nvim-aws-secrets/` — Secrets Manager viewer (`aws-secrets` alias)

Each has its own install target; they do not share plugin state.

### Other components

- `sre-agent/`, `ssh-manager/` — standalone subprojects with their own code, not just config
- `keyboard/` — Karabiner-Elements JSON config
- `hammerspoon/`, `sketchybar/`, `ghostty/`, `raycast/`, `lazygit/`, `ptpython/` — application configs, installed by the matching `install/dotfiles/*.sh` script
- `.claude/settings.local.json` — project-local Claude Code settings

### Sketchybar config reloads

`sketchybar/sketchybarrc` is symlinked into `~/.config/sketchybar/sketchybarrc` by `install/dotfiles/sketchybar.sh`, so edits to the source file are immediately visible to sketchybar on disk — but a running sketchybar process will not pick them up until the config is re-sourced. After editing `sketchybarrc`, use `sketchybar --reload` (re-sources the config; picks up new/changed item scripts). `sketchybar --update` only re-fires the already-loaded scripts and will keep running stale logic. `brew services restart felixkratz/formulae/sketchybar` also works but is heavier.

## Conventions

- Install scripts print `═══` banner headers and `✓` / `⚠️` status markers; match this style when adding new scripts so `install.sh`'s output stays consistent.
- `install.sh` writes its installed configs to `$HOME/GitHub/matthewmyrick/dotfiles/...` (capitalized), which is the canonical runtime location referenced by `.zshrc` and shell modules. Do not hardcode the lowercase `~/Github/` path.
- Every install function echoes a "Next Steps" section at the end. Preserve this — users rely on it to know what to restart.
