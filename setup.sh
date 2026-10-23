#!/usr/bin/env bash
# Set up a new machine (macOS or Debian/Ubuntu Linux): install CLI tools, then
# symlink the configs in this repo into $HOME. Existing files are moved to
# <file>.bak.<timestamp> rather than deleted. Safe to re-run.
#
#   ./setup.sh              install tools and link configs
#   ./setup.sh --link-only  only link configs
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
OS="$(uname -s)"
LINK_ONLY=false
[ "${1:-}" = "--link-only" ] && LINK_ONLY=true

# Tools installed to ~/.local/bin (claude, lazygit fallback) must be found on re-runs
export PATH="$HOME/.local/bin:$PATH"

have() { command -v "$1" >/dev/null 2>&1; }

# --- Tools -----------------------------------------------------------------

install_tools_macos() {
    if ! have brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Apple Silicon installs to /opt/homebrew, Intel to /usr/local
    for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$brew" ] && eval "$("$brew" shellenv)" && break
    done
    have gh      || brew install gh
    have lazygit || brew install lazygit
}

install_lazygit_release() {
    local arch version tmp
    case "$(uname -m)" in
        x86_64)        arch=x86_64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) echo "note    no lazygit release for $(uname -m); install it manually"; return ;;
    esac
    version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')"
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/lazygit.tar.gz" \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_linux_${arch}.tar.gz"
    tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$tmp/lazygit" "$HOME/.local/bin/lazygit"
    rm -rf "$tmp"
}

install_tools_linux() {
    if ! have apt-get; then
        echo "note    no apt-get; install gh and lazygit with your package manager"
        return
    fi
    have curl || { sudo apt-get update && sudo apt-get install -y curl; }

    if ! have gh; then
        # GitHub's own apt repo; distro packages of gh lag behind
        sudo mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        sudo apt-get update
        sudo apt-get install -y gh
    fi

    if ! have lazygit; then
        # Packaged in Ubuntu 25.10+ and Debian 13+; older releases use the GitHub release
        if apt-cache show lazygit >/dev/null 2>&1; then
            sudo apt-get install -y lazygit
        else
            install_lazygit_release
        fi
    fi
}

install_tools() {
    case "$OS" in
        Darwin) install_tools_macos ;;
        Linux)  install_tools_linux ;;
        *)      echo "note    unsupported OS $OS; skipping tool installs"; return ;;
    esac
    # Native installer on both; auto-updates, installs to ~/.local/bin/claude
    have claude || curl -fsSL https://claude.ai/install.sh | bash
    for tool in gh lazygit claude; do
        have "$tool" && echo "ok      $tool" || echo "MISSING $tool"
    done
}

# --- Configs ---------------------------------------------------------------

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

link_configs() {
    link zsh/.zshrc            "$HOME/.zshrc"
    link zsh/.zshenv           "$HOME/.zshenv"
    link tmux/.tmux.conf.local "$HOME/.tmux.conf.local"
    link git/.gitconfig        "$HOME/.gitconfig"
    link git/ignore            "$HOME/.config/git/ignore"
    link mise/config.toml      "$HOME/.config/mise/config.toml"
    link gh/config.yml         "$HOME/.config/gh/config.yml"
    link nvim                  "$HOME/.config/nvim"

    if [ "$OS" = "Darwin" ]; then
        link ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"
    fi

    # oh-my-tmux provides ~/.tmux.conf; our overrides live in ~/.tmux.conf.local
    if [ ! -d "$HOME/.tmux" ]; then
        git clone git@github.com:gpakosz/.tmux.git "$HOME/.tmux"
    fi
    local link_tmux="$HOME/.tmux/.tmux.conf"
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
}

$LINK_ONLY || install_tools
link_configs
