# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="miloshadzic"
# ZSH_THEME="agnoster"

plugins=(
    git
    extract
)

source $ZSH/oh-my-zsh.sh

# Arduino
export PATH="$HOME/Software/bin:$PATH"

# Julia
export PATH="$HOME/Software/julia-1.6.0/bin:$PATH"

# Rust
# export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library

export MUJOCO_KEY_PATH="$HOME/mujoco200_linux/bin/mjkey.txt"
export SNOPT="$HOME/Software/snopt"
export GUROBI_HOME="$HOME/Software/gurobi801/linux64"
export PATH="$GUROBI_HOME/bin:$PATH"
export PYTHONPATH=$HOME/Code/mavlink
export LD_LIBRARY_PATH="$GUROBI_HOME/lib:$LD_LIBRARY_PATH"
export CPLEX_STUDIO_BINARIES="/opt/ibm/ILOG/CPLEX_Studio128/cplex/bin/x86-64_linux"
export PATH="$CPLEX_STUDIO_BINARIES:$PATH"
export LD_LIBRARY_PATH="$CPLEX_STUDIO_BINARIES:$LD_LIBRARY_PATH"

alias ctraj="cd ~/.julia/dev/TrajectoryOptimization"
alias cdev="~/.julia/dev"

# Copy github token
alias cpat="xclip -sel c < ~/.tokens/github"

# Edit this file
alias vz="vi ~/.zshrc"
alias ez="emacs ~/.zshrc"
alias sz="source ~/.zshrc"

# Ruby
export GEM_HOME=$HOME/gems
export PATH=$HOME/gems/bin:$PATH

# Other
alias grep="grep -P"
alias apngasm="/home/bjack205/Software/apng/apngasm"

# SNOPT
export SNOPT_LICENSE="/home/licenses/snopt7.lic"
export SNOPT_HOME="/home/bjack205/Software/snopt77"
export LD_LIBRARY_PATH="$SNOPT_HOME:$LD_LIBRARY_PATH" 

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/brian/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/brian/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/brian/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/brian/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
