# dotfiles

Shell, editor and tool configuration.

| Path | Installs to |
| --- | --- |
| `zsh/.zshrc`, `zsh/.zshenv` | `~/` (expects [oh-my-zsh](https://ohmyz.sh)) |
| `tmux/.tmux.conf.local` | `~/` (overrides for [oh-my-tmux](https://github.com/gpakosz/.tmux)) |
| `nvim/` | `~/.config/nvim` ([LazyVim](https://www.lazyvim.org)) |
| `git/.gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `gh/config.yml` | `~/.config/gh/config.yml` |
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` (macOS only) |
| `legacy/` | Old Ubuntu setup (vim, Atom, VS Code); not installed |

## Copying from remote tmux to the macOS clipboard

Ghostty on the Mac, `ssh` to the remote, tmux there. Yanking in tmux copy mode
(mouse drag, or `prefix [` then `v` / `y`) sends the text back as an OSC 52
escape sequence, which Ghostty writes to the macOS clipboard. This needs
`set-clipboard on` in `tmux/.tmux.conf.local` (remote side) and
`clipboard-write = allow` in `ghostty/config.ghostty` (Mac side). Hold Shift
while dragging to make a Ghostty selection that bypasses tmux.

## Install

```sh
git clone git@github.com:bjack205/.configfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

`setup.sh` installs gh, lazygit and Claude Code (Homebrew on macOS, apt on
Debian/Ubuntu), then symlinks each file into place, moving anything already there to
`<file>.bak.<timestamp>`. Git `user.email` is kept per machine in
`~/.gitconfig.local`, which the script creates on first run.

## Not tracked

Secrets and machine state stay out of this repo: `~/.config/gh/hosts.yml`
(auth token), `~/.gitconfig.local`, shell history, and Claude Code settings.
