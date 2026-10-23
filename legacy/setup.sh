#!/bin/bash

# Install the basics
sudo apt-get install git -y
sudo apt-get install emacs -y
sudo apt-get install vim -y
sudo apt-get install curl -y
sudo apt-get install cmake -y
sudo apt-get install cmake-qt-gui -y
sudo apt-get install ninja-build -y
sudo apt-get install clang-13 -y
sudo apt-get install clangd-13 -y
sudo apt-get install gfortran-11 -y

# More tools
sudo apt-get install hdf5-tools -y
sudo apt-get install hdfview -y
sudo apt-get install ffmpeg -y
sudo apt-get install libeigen3-dev -y
sudo apt-get install gnome-tweaks -y
sudo apt-get install xclip
sudo apt-get install valgrind -y
sudo apt-get install clang -y
sudo apt-get install clang-tidy -y
sudo apt-get install clang-format -y
sudo apt-get install nodejs -y
sudo apt-get install yarn -y
sudo apt-get install ratbagd -y  # for piper mouse config
snap install arduino-cli

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
git config --global init.defaultBranch main

git config --global user.name "Brian Jackson"
git config --global user.email "bjack205@gmail.com"

# Install Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Install Jekyll (y/n)?"
read check_install
if [ $check_install = "y" ]; then
    sudo apt-get install ruby-full build-essential zlib1g-dev
    echo '# Install Ruby Gems to ~/gems' >> ~/.zshrc
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.zshrc
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    gem install jekyll bundler
fi

# Create Symlinks
if [ ! -f "~/.zshrc" ]; then
    rm ~/.zshrc
fi
if [ ! -f "~/.vimrc" ]; then
    rm ~/.vimrc
fi
sudo ln -s $PWD/.zshrc ~/.zshrc
sudo ln -s $PWD/.vimrc ~/.vimrc

# Install Oh-My-Zsh
sudo apt-get install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo chsh -s $(which zsh)
sudo apt-get install fonts-powerline -y

