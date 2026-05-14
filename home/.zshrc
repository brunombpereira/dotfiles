# ~/.zshrc — managed by ~/.dotfiles (symlinked here)

# ──────────────────────────────────────────────────────────────────────
# History
# ──────────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS

# ──────────────────────────────────────────────────────────────────────
# Source partials (aliases, exports, functions)
# ──────────────────────────────────────────────────────────────────────
for file in ~/.zsh/*.zsh; do
    [ -r "$file" ] && source "$file"
done

# ──────────────────────────────────────────────────────────────────────
# asdf (Ruby, Node version manager)
# ──────────────────────────────────────────────────────────────────────
if [ -d "$HOME/.asdf" ]; then
    . "$HOME/.asdf/asdf.sh"
    fpath=("${HOME}/.asdf/completions" $fpath)
fi

# ──────────────────────────────────────────────────────────────────────
# Completion (must come after fpath edits)
# ──────────────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# ──────────────────────────────────────────────────────────────────────
# Plugins (load late, syntax-highlighting MUST be last)
# ──────────────────────────────────────────────────────────────────────
ZSH_PLUGINS="$HOME/.local/share/zsh-plugins"
[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ──────────────────────────────────────────────────────────────────────
# direnv (per-directory env)
# ──────────────────────────────────────────────────────────────────────
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# ──────────────────────────────────────────────────────────────────────
# fzf keybindings + completion (Ctrl-R history, Ctrl-T files, Alt-C cd)
# Ubuntu ships these examples; sourcing is the supported way to enable
# them when installed via apt (no `fzf --zsh` like the brew build).
# ──────────────────────────────────────────────────────────────────────
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] \
    && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] \
    && source /usr/share/doc/fzf/examples/completion.zsh

# ──────────────────────────────────────────────────────────────────────
# zoxide (smarter cd: `z foo` jumps to a frecent dir matching foo)
# ──────────────────────────────────────────────────────────────────────
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ──────────────────────────────────────────────────────────────────────
# Prompt: a port of Ubuntu-24's bash PS1 lives in ~/.zsh/prompt.zsh
# (loaded by the partials block above). Starship is intentionally
# not initialised here.
# ──────────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────────
# Banner on shell launch (once per terminal tab, not in subshells)
# ──────────────────────────────────────────────────────────────────────
if [[ -o interactive ]] && [[ -z "$NEXO_BANNER_SHOWN" ]] && command -v fastfetch >/dev/null 2>&1; then
    export NEXO_BANNER_SHOWN=1
    fastfetch
fi
