#!/usr/bin/env bash
# Set up a new machine (macOS or Debian/Ubuntu Linux): install tools, set up
# GitHub SSH access, then symlink the configs in this repo into $HOME.
# Existing files are moved to <file>.bak.<timestamp> rather than deleted.
# Safe to re-run; steps that are already done are skipped.
#
#   ./setup.sh              install tools and link configs
#   ./setup.sh --link-only  only link configs
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
OS="$(uname -s)"
LINK_ONLY=false
[ "${1:-}" = "--link-only" ] && LINK_ONLY=true

# Tools installed to ~/.local/bin (claude, mise, fallbacks) must be found on re-runs
export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin"

have() { command -v "$1" >/dev/null 2>&1; }

# --- Packages --------------------------------------------------------------

install_packages_macos() {
    if ! have brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Apple Silicon installs to /opt/homebrew, Intel to /usr/local
    for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$brew" ] && eval "$("$brew" shellenv)" && break
    done
    # zsh and a C compiler (Xcode Command Line Tools) ship with macOS / Homebrew
    brew install git git-lfs tmux neovim ripgrep fd fzf gh lazygit mise
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
    install -m 755 "$tmp/lazygit" "$HOME/.local/bin/lazygit"
    rm -rf "$tmp"
}

# LazyVim needs Neovim 0.11.2+; prints the minor version (0.X) or 0 if missing
nvim_minor() {
    have nvim || { echo 0; return; }
    nvim --version | sed -n '1s/^NVIM v0\.\([0-9]*\).*/\1/p'
}

install_neovim_release() {
    local arch
    case "$(uname -m)" in
        x86_64)        arch=x86_64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) echo "note    no Neovim release for $(uname -m); install it manually"; return ;;
    esac
    rm -rf "$HOME/.local/opt/nvim"
    mkdir -p "$HOME/.local/opt/nvim"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" \
        | tar -xz -C "$HOME/.local/opt/nvim" --strip-components=1
    ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
}

install_packages_linux() {
    if ! have apt-get; then
        echo "note    no apt-get; install packages with your package manager"
        return
    fi
    sudo apt-get update
    sudo apt-get install -y zsh tmux git git-lfs curl unzip build-essential \
        openssh-client ripgrep fd-find fzf
    # Debian/Ubuntu name the fd binary fdfind
    have fd || ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"

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

    if [ "$(nvim_minor)" -lt 11 ]; then
        local candidate
        candidate="$(apt-cache policy neovim | sed -n 's/^ *Candidate: \([0-9]*:\)\{0,1\}0\.\([0-9]*\).*/\2/p')"
        if [ "${candidate:-0}" -ge 11 ]; then
            sudo apt-get install -y neovim
        else
            install_neovim_release
        fi
    fi

    have mise || curl -fsSL https://mise.run | sh
}

install_tools() {
    case "$OS" in
        Darwin) install_packages_macos ;;
        Linux)  install_packages_linux ;;
        *)      echo "note    unsupported OS $OS; skipping package installs" ;;
    esac
    # Native installer on both; auto-updates, installs to ~/.local/bin/claude
    have claude || curl -fsSL https://claude.ai/install.sh | bash
}

# Runs after setup_github_ssh: clones over SSH
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        # --keep-zshrc: link_configs installs ours; --unattended: no chsh, no new shell
        REMOTE=git@github.com:ohmyzsh/ohmyzsh.git sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            "" --unattended --keep-zshrc
    fi
}

# --- GitHub SSH ------------------------------------------------------------

github_ssh_ok() {
    # ssh -T exits 1 even on success, so match the greeting instead
    local out
    out="$(ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 || true)"
    case "$out" in *"successfully authenticated"*) return 0 ;; *) return 1 ;; esac
}

setup_github_ssh() {
    if ! github_ssh_ok; then
        local key="$HOME/.ssh/id_ed25519" status
        if [ ! -f "$key" ]; then
            ssh-keygen -t ed25519 -C "$(whoami)@$(hostname -s)" -f "$key"
        fi
        if ! gh auth status >/dev/null 2>&1; then
            gh auth login -h github.com -p ssh -w --skip-ssh-key -s admin:public_key
        else
            status="$(gh auth status 2>&1 || true)"
            case "$status" in
                *admin:public_key*) ;;
                *) gh auth refresh -h github.com -s admin:public_key ;;
            esac
        fi
        gh ssh-key add "$key.pub" --title "$(hostname -s)" || true
    fi
    if github_ssh_ok; then
        echo "ok      GitHub SSH"
    else
        echo "MISSING GitHub SSH access; check ssh -T git@github.com"
        exit 1
    fi
    # A fresh machine clones this repo over HTTPS; use SSH from now on
    git -C "$DOTFILES" remote set-url origin git@github.com:bjack205/.configfiles.git
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
    link tmux/.tmux.conf.local "$HOME/.tmux.conf.local"
    link git/.gitconfig        "$HOME/.gitconfig"
    link git/ignore            "$HOME/.config/git/ignore"
    link mise/config.toml      "$HOME/.config/mise/config.toml"
    link gh/config.yml         "$HOME/.config/gh/config.yml"
    link nvim                  "$HOME/.config/nvim"

    if [ "$OS" = "Darwin" ]; then
        link ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"
    fi

    # Personal Claude Code skills, one link each: ~/.claude/skills also holds
    # directories Claude Code manages itself
    if [ -d "$DOTFILES/claude/skills" ]; then
        for skill in "$DOTFILES"/claude/skills/*/; do
            [ -d "$skill" ] || continue
            skill="$(basename "$skill")"
            link "claude/skills/$skill" "$HOME/.claude/skills/$skill"
        done
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
    # Commits to this (public) repo use the personal address, whatever the machine default
    git -C "$DOTFILES" config user.name "Brian Jackson"
    git -C "$DOTFILES" config user.email bjack205@gmail.com

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "note    oh-my-zsh not installed; .zshrc expects it at ~/.oh-my-zsh"
    fi
}

# --- After linking ---------------------------------------------------------

finish() {
    # Node and tree-sitter (for LazyVim) come from mise/config.toml
    have mise && mise install

    local zsh_path
    zsh_path="$(command -v zsh || true)"
    if [ -n "$zsh_path" ] && [ "$(basename "${SHELL:-}")" != zsh ]; then
        echo "Changing login shell to $zsh_path (asks for your password)"
        chsh -s "$zsh_path"
    fi

    for tool in git git-lfs zsh tmux nvim rg fd fzf gh lazygit mise claude tree-sitter; do
        have "$tool" && echo "ok      $tool" || echo "MISSING $tool"
    done
}

if ! $LINK_ONLY; then
    install_tools
    setup_github_ssh
    install_oh_my_zsh
fi
link_configs
$LINK_ONLY || finish
