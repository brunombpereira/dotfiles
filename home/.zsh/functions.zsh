# mkcd path/to/dir — create and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# gclone owner/repo — clone into ~/projects/<repo> and cd
gclone() {
    local repo="$1"
    if [ -z "$repo" ]; then
        echo "usage: gclone owner/repo" >&2
        return 1
    fi
    local name="${repo##*/}"
    mkdir -p "$HOME/projects"
    git clone "https://github.com/$repo.git" "$HOME/projects/$name"
    cd "$HOME/projects/$name"
}

# dotfiles-update — pull latest and re-run install.sh
dotfiles-update() {
    (cd "$HOME/.dotfiles" && git pull --ff-only && ./install.sh)
}
