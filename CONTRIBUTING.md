# Contributing

This repo is primarily a personal WSL Ubuntu dev environment, but PRs and
forks are welcome. The goal is **idempotent, fast bootstrap**: every step
must be safe to re-run.

## Local checks

CI runs four jobs (see `.github/workflows/shellcheck.yml`). Run them
locally before pushing:

```bash
# Syntax
bash -n install.sh lib/*.sh scripts/*.sh
for f in home/.zshrc home/.zsh/*.zsh; do zsh -n "$f"; done

# Lint + format
shellcheck install.sh lib/*.sh scripts/*.sh
shfmt -bn -i 4 -ci -d install.sh lib/*.sh scripts/*.sh

# End-to-end dry run
./install.sh --dry-run --no-log
```

Optional: `pre-commit install` (uses `.pre-commit-config.yaml`) runs
shellcheck + shfmt on each commit.

## Style

- 4-space indent for `.sh` / `.zsh` (enforced by `.editorconfig` + shfmt).
- shfmt flags: `-bn -i 4 -ci` (binary ops may start a line, indent switch cases).
- Every `lib/*.sh` script must be idempotent. Use `command -v X` /
  `[ -d X ]` / `grep -q` guards before installing or modifying state.
- Prefer apt → official tarballs → script-installers, in that order, when
  there's a choice.

## Adding a new tool

1. **Decide where it goes.** Most tools belong in
   `lib/20-cli-tools.sh`. If it's a language toolchain, extend
   `lib/30-langs.sh`. If it needs its own step (long-running, distinct
   responsibility), add a new numbered script: `lib/NN-foo.sh`.
2. **Add config** under `home/` (e.g., `home/.config/<tool>/`).
3. **Symlink it** by appending to `LINKS=(...)` in `lib/50-symlinks.sh`
   *and* the matching list in `scripts/uninstall.sh`.
4. **Shell integration** (aliases, init eval) goes in `home/.zsh/aliases.zsh`,
   `home/.zsh/exports.zsh`, or `home/.zshrc` as appropriate.
5. **Test** with `./install.sh --dry-run` and then `./install.sh --only NN`
   to run just your new step.
6. **Document** in `README.md` under the relevant section.

## Filing issues

Use the templates under `.github/ISSUE_TEMPLATE/`. The most useful
reports include the `install.log` file (auto-written next to `install.sh`).
