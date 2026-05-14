# 🛠 dotfiles

> Reproducible WSL Ubuntu dev environment — from blank to working Rails + React in one command.

## Quickstart

On a fresh Ubuntu 24.04 (WSL or otherwise):

```bash
sudo apt-get install -y git
git clone https://github.com/brunombpereira/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh    # reload to pick up zsh + the custom PS1
```

In ~15 minutes you have:

- ✅ **zsh** as default shell + a custom **powerline prompt** (`~/.zsh/prompt.zsh`) + autosuggestions + syntax highlighting
- ✅ **fastfetch** banner on shell launch with a custom NEXO logo
- ✅ **asdf** with Ruby 3.3.6 and Node 22.x (latest LTS at install time)
- ✅ **PostgreSQL 16** with `trust` auth on localhost for your UNIX user
- ✅ **CLI tools**: fzf, ripgrep, bat, eza, lazygit, fastfetch, httpie, direnv, zoxide, jq, gh
- ✅ Sensible **git** + **neovim** config
- ✅ Aliases (`g`, `ll`, `be`, `ber`, `rs`, `rc`, …) and helper functions (`mkcd`, `gclone`, `dotfiles-update`)

### Windows Terminal setup (WSL only)

The prompt uses Nerd Font glyphs (powerline arrows, branch/folder/clock icons) and assumes a custom color scheme. After `install.sh`, run:

```bash
bash ~/.dotfiles/scripts/setup-windows-terminal.sh
```

This installs **CaskaydiaCove Nerd Font Mono** (user-level, no admin), adds the **Nexo Half Dark** color scheme to Windows Terminal, and sets the Nexo profile to use both. Restart Windows Terminal afterwards.

## Structure

```
lib/                  # bootstrap scripts, run in numerical order
  00-system.sh        # apt base packages + gh CLI
  10-shell.sh         # zsh + zsh plugins
  20-cli-tools.sh     # fzf, ripgrep, bat, eza, lazygit, fastfetch, direnv, httpie, zoxide
  30-langs.sh         # asdf + Ruby + Node
  40-postgres.sh      # postgres-16 + role + pg_hba trust
  50-symlinks.sh      # symlink home/* into ~/
  99-finish.sh        # next-steps banner
scripts/              # optional / manual scripts
  setup-windows-terminal.sh   # font + WT scheme for the Nexo profile
  uninstall.sh                # remove dotfiles symlinks (+ optional backup restore)
home/                 # user config (symlinked into ~/)
  .zshrc, .zsh/{aliases,exports,functions,prompt}.zsh
  .gitconfig, .gitignore_global
  .config/fastfetch/{config.jsonc,logo.txt}
  .config/nvim/init.lua
templates/            # opt-in user-specific configs (copy, edit, don't commit)
  envrc.example                  # .envrc for projects using direnv
  ssh-config.example             # ~/.ssh/config starter
  gitconfig-signing.example      # SSH/GPG commit-signing snippets
```

## Install flags

`./install.sh` accepts:

| Flag | Purpose |
| --- | --- |
| `--dry-run` | Print steps without executing. Useful before re-running on a working box. |
| `--only NN[,NN]` | Run only the listed numeric prefixes — e.g. `--only 10,20`. |
| `--skip NN[,NN]` | Skip the listed prefixes — e.g. `--skip 40` to skip Postgres. |
| `--force` | Allow running from a path other than `~/.dotfiles`. |
| `--no-log` | Don't tee output to `~/.dotfiles/install.log`. |
| `-h`, `--help` | Show help. |

## Updating

After pulling new changes from upstream (or making your own), re-run:

```bash
dotfiles-update      # shell function: cd ~/.dotfiles && git pull && ./install.sh
```

Or manually:

```bash
cd ~/.dotfiles && git pull && ./install.sh
```

Every `lib/*.sh` is idempotent — re-running is safe and fast.

## What gets backed up

`lib/50-symlinks.sh` backs up any existing file at a symlink target into `~/.dotfiles-backup-YYYYmmdd-HHMMSS/` before replacing it. Nothing is overwritten silently.

## Uninstall

To remove the symlinks (apt packages, asdf, postgres, and zsh plugins are left in place):

```bash
~/.dotfiles/scripts/uninstall.sh              # remove symlinks
~/.dotfiles/scripts/uninstall.sh --restore-backup   # also restore newest backup dir
~/.dotfiles/scripts/uninstall.sh --dry-run    # preview
```

## SSH keys & signed commits

Both are opt-in — neither is set up by `install.sh`. Starter templates live in `templates/`:

```bash
cp ~/.dotfiles/templates/ssh-config.example ~/.ssh/config && chmod 600 ~/.ssh/config
# Then edit ~/.ssh/config and run ssh-keygen -t ed25519 as needed.

# For signed commits, append snippets from this file into ~/.gitconfig:
less ~/.dotfiles/templates/gitconfig-signing.example
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — including how to add a new tool and the local lint commands CI runs.

## License

MIT — see [LICENSE](LICENSE)
