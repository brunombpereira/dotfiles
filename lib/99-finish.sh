#!/usr/bin/env bash
# Friendly finish message — does not exit non-zero on its own
set +e

cat <<'EOF'

═══════════════════════════════════════════════════════════════════════
  Dotfiles bootstrap complete
═══════════════════════════════════════════════════════════════════════

Next steps:

  1. Close this WSL session and open a fresh one so your default shell
     becomes zsh and your starship prompt loads.

       $ exit
       (then open a new WSL terminal)

  2. Verify (in the new shell):

       $ echo $SHELL          # /usr/bin/zsh
       $ ruby -v              # 3.3.6
       $ node -v              # v22.x
       $ psql -d postgres -c "SELECT 1"   # 1 row, no password

  3. Personalize ~/.dotfiles/home/.gitconfig if needed.

Issues? Open one at: https://github.com/brunombpereira/dotfiles/issues

EOF
