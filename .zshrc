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
alias cleanbuild="cd .. && rm -rf build && take build"

alias godot="$HOME/Software/Godot_v3.4.4-stable_x11.64"

# Arduino
export PATH="$HOME/Software/bin:$PATH"
alias ard="arduino-cli"

# Julia
export PATH="$HOME/Software/julia-1.7.1/bin:$PATH"
alias julia6="$HOME/Software/julia-1.6.5/bin/julia"

# Rust
# export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library
# source "$HOME/.cargo/env"

# Pardiso
export JULIA_PARDISO="$HOME/Software/pardiso-6.0"
export PARDISO_LIC_PATH="$HOME/Software/pardiso-6.0"

# HSL
export HSL_MA97_PATH="$HOME/Software/hsl"
export HSL_MA86_PATH="$HOME/Software/hsl"
export COINHSL_PATH="$HOME/Software/hsl"
export HSL_COIN_PATH="$HOME/Software/hsl"

# Intel MKL
alias mklenv="source $HOME/intel/oneapi/setvars.sh"

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
alias vnvim="vi ~/.config/nvim/init.vim"

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

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
