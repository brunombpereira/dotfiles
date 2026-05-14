# ~/.zsh/prompt.zsh — managed by ~/.dotfiles
#
# Port of the bash PS1 used in the Ubuntu-24 WSL (see ~/.bashrc in
# that distro). Uses tput so the rendered colors track whatever
# color scheme Windows Terminal has set for this profile — match
# the same Nerd Font glyphs and structure to get a pixel-equivalent
# look. Replaces starship for the Nexo profile.

# Color escapes via tput. Same approach as Ubuntu-24's .bashrc.
typeset -g _PR_RED="$(tput setaf 1)"
typeset -g _PR_REDBG="$(tput setab 1)"
typeset -g _PR_GREEN="$(tput setaf 2)"
typeset -g _PR_GREENBG="$(tput setab 2)"
typeset -g _PR_BROWN="$(tput setaf 3)"
typeset -g _PR_BROWNBG="$(tput setab 3)"
typeset -g _PR_CYAN="$(tput setaf 6)"
typeset -g _PR_CYANBG="$(tput setab 6)"
typeset -g _PR_NC="$(tput sgr0)"

# Nerd Font glyphs — same codepoints used by Ubuntu-24's PS1.
typeset -g _PR_LCAP=$''      # left cap shape
typeset -g _PR_RCAP=$''      # right cap / transition arrow
typeset -g _PR_BRANCH=$''    # diamond before branch name
typeset -g _PR_FOLDER=$''    # icon before working directory
typeset -g _PR_CLOCK=$''     # clock icon before time

# Emits the leading green/red [branch] block when inside a git repo;
# empty otherwise. Wrap colour escapes in %{%} so zsh counts widths
# correctly.
_nexo_prompt_git_block() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
        || branch=$(git rev-parse --short HEAD 2>/dev/null)
    [[ -z $branch ]] && return

    # Use --untracked-files=no: --porcelain scans the whole worktree for
    # untracked files which is O(N) in repo size and noticeable on big
    # monorepos. Tradeoff: a brand-new file doesn't redden the prompt
    # until it's `git add`ed. Worth it for sub-100ms renders.
    local fg bg
    if [[ -z $(git status --porcelain --untracked-files=no 2>/dev/null) ]]; then
        fg=$_PR_GREEN; bg=$_PR_GREENBG     # clean → green
    else
        fg=$_PR_RED;   bg=$_PR_REDBG       # dirty → red
    fi

    print -rn -- "%{${fg}${bg}%}${_PR_LCAP} %{${_PR_NC}${bg}%}${_PR_BRANCH} ${branch} %{${_PR_BROWNBG}${fg}%}${_PR_RCAP}%{${_PR_NC}%}"
}

# Recompute PROMPT before each render. Two leading newlines match
# Ubuntu-24's `\n\n` spacing.
_nexo_prompt_build() {
    local git_block
    git_block="$(_nexo_prompt_git_block)"

    PROMPT=$'\n\n'"${git_block}"
    PROMPT+="%{${_PR_BROWNBG}%} ${_PR_FOLDER} %~ %{${_PR_NC}${_PR_BROWN}%}${_PR_RCAP}%{${_PR_NC}%}"
    PROMPT+=$'\n'
    PROMPT+="%{${_PR_NC}${_PR_CYAN}%}${_PR_LCAP}%{${_PR_NC}${_PR_CYANBG}%} ${_PR_CLOCK} %D{%H:%M:%S} %{${_PR_NC}${_PR_CYAN}%}${_PR_RCAP}%{${_PR_NC}%} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _nexo_prompt_build
