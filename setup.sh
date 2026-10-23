#!/usr/bin/env bash
# Symlink the configs in this repo into $HOME. Existing files are moved to
# <file>.bak.<timestamp> rather than deleted. Safe to re-run.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"

link() {
    local src="$DOTFILES/$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "ok      $dst"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak.$STAMP"
        echo "backup  $dst -> $dst.bak.$STAMP"
    fi
    ln -s "$src" "$dst"
    echo "link    $dst -> $src"
}

link zsh/.zshrc            "$HOME/.zshrc"
link zsh/.zshenv           "$HOME/.zshenv"
link tmux/.tmux.conf.local "$HOME/.tmux.conf.local"
link git/.gitconfig        "$HOME/.gitconfig"
link git/ignore            "$HOME/.config/git/ignore"
link mise/config.toml      "$HOME/.config/mise/config.toml"
link gh/config.yml         "$HOME/.config/gh/config.yml"
link nvim                  "$HOME/.config/nvim"

if [ "$(uname -s)" = "Darwin" ]; then
    link ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"
fi

# oh-my-tmux provides ~/.tmux.conf; our overrides live in ~/.tmux.conf.local
if [ ! -d "$HOME/.tmux" ]; then
    git clone git@github.com:gpakosz/.tmux.git "$HOME/.tmux"
fi
link_tmux="$HOME/.tmux/.tmux.conf"
if [ ! -L "$HOME/.tmux.conf" ]; then
    [ -e "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$STAMP"
    ln -s "$link_tmux" "$HOME/.tmux.conf"
    echo "link    $HOME/.tmux.conf -> $link_tmux"
fi

# Machine-specific git identity stays out of the repo
if [ ! -f "$HOME/.gitconfig.local" ]; then
    read -rp "git user.email for this machine: " email
    printf '[user]\n\temail = %s\n' "$email" > "$HOME/.gitconfig.local"
    echo "wrote   $HOME/.gitconfig.local"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "note    oh-my-zsh not installed; .zshrc expects it at ~/.oh-my-zsh"
fi
