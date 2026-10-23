# dotfiles

Shell, editor and tool configuration for macOS and Debian/Ubuntu Linux.

| Path | Installs to |
| --- | --- |
| `zsh/.zshrc` | `~/` (expects [oh-my-zsh](https://ohmyz.sh)) |
| `tmux/.tmux.conf.local` | `~/` (overrides for [oh-my-tmux](https://github.com/gpakosz/.tmux)) |
| `nvim/` | `~/.config/nvim` ([LazyVim](https://www.lazyvim.org)) |
| `git/.gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| `mise/config.toml` | `~/.config/mise/config.toml` (Node, tree-sitter) |
| `gh/config.yml` | `~/.config/gh/config.yml` |
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` (macOS only) |
| `claude/skills/<name>/` | `~/.claude/skills/<name>` (personal Claude Code skills, if any) |
| `legacy/` | Old Ubuntu setup (vim, Atom, VS Code); not installed |

## Copying from remote tmux to the macOS clipboard

Ghostty on the Mac, `ssh` to the remote, tmux there. Yanking in tmux copy mode
(mouse drag, or `prefix [` then `v` / `y`) sends the text back as an OSC 52
escape sequence, which Ghostty writes to the macOS clipboard. This needs
`set-clipboard on` in `tmux/.tmux.conf.local` (remote side) and
`clipboard-write = allow` in `ghostty/config.ghostty` (Mac side). Hold Shift
while dragging to make a Ghostty selection that bypasses tmux.

## Install

On a new machine with no GitHub SSH key yet, clone over HTTPS (the repo is
public); `setup.sh` sets up SSH and switches the remote to SSH afterwards:

```sh
git clone https://github.com/bjack205/.configfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

If the machine already has SSH access to GitHub, clone with
`git@github.com:bjack205/.configfiles.git` instead. On macOS, the first `git`
command prompts to install the Xcode Command Line Tools.

`setup.sh` runs these steps, skipping any that are already done:

1. Installs packages: Homebrew on macOS, apt on Debian/Ubuntu (zsh, tmux, git,
   git-lfs, Neovim 0.11+, ripgrep, fd, fzf, gh, lazygit, mise, a C compiler),
   plus Claude Code from its native installer. Where apt's Neovim or lazygit
   is too old or missing, it uses the GitHub release in `~/.local`.
2. Sets up GitHub SSH: creates `~/.ssh/id_ed25519` if needed, signs in with
   `gh auth login`, and uploads the key.
3. Installs oh-my-zsh.
4. Symlinks each config into place, moving anything already there to
   `<file>.bak.<timestamp>`. Git `user.email` is kept per machine in
   `~/.gitconfig.local`, which the script asks for on first run. Commits to
   this repo always use the personal address.
5. Runs `mise install` (Node, tree-sitter), switches the login shell to zsh,
   and lists any tools still missing.

`./setup.sh --link-only` runs step 4 alone.

## Not tracked

Secrets and machine state stay out of this repo: `~/.config/gh/hosts.yml`
(auth token), `~/.gitconfig.local`, shell history, and Claude Code settings.
