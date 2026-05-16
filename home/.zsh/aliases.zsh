# Listing (eza replaces ls)
alias ls='eza'
alias ll='eza -la --git --group-directories-first'
alias la='eza -a'
alias tree='eza --tree'

# Git
alias g='git'
alias gst='git status -sb'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull --ff-only'
alias glog='git log --oneline --graph --decorate --all -20'
alias gd='git diff'

# Rails / Ruby
alias be='bundle exec'
alias ber='bundle exec rspec'
alias r='bundle exec rails'
alias rs='bundle exec rails server'
alias rc='bundle exec rails console'

# Docker (when needed)
alias dc='docker compose'

# Safety
alias rm='rm -i'

# Shell — re-exec zsh as a login shell to pick up changes to
# .zshrc / .zshenv / asdf / env without losing the current cwd.
# Unsets NEXO_BANNER_SHOWN so the fastfetch banner is re-shown.
# Does not restart the WSL distro itself; use `wsl.exe --terminate <name>`
# from a Windows shell for that.
alias reload='unset NEXO_BANNER_SHOWN; exec zsh -l'
