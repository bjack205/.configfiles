# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="miloshadzic"
# ZSH_THEME="agnoster"
ZSH_THEME="cloud"

plugins=(
    git
    extract
)

source $ZSH/oh-my-zsh.sh
alias cleanbuild="cd .. && rm -rf build && take build"
alias lg=lazygit

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Julia
export PATH="$HOME/.juliaup/bin:$PATH"
export PATH="$HOME/.julia/bin:$PATH"
export JULIA_PKG_USE_CLI_GIT=true
alias jtest="julia --project=. -e 'import Pkg; Pkg.test()'"

# Edit this file
alias vz="nvim ~/.zshrc"
alias sz="source ~/.zshrc"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# mise Node shims
export PATH="$HOME/.local/share/mise/shims:$PATH"
