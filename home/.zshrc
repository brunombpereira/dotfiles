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
# Starship prompt (last)
# ──────────────────────────────────────────────────────────────────────
command -v starship >/dev/null && eval "$(starship init zsh)"
