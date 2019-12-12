#!/bin/bash

# Install the basics
sudo apt-get install git -y
sudo apt-get install emacs -y
sudo apt-get install vim -y
sudo apt-get install curl -y
sudo apt-get install cmake -y

# Install Oh-My-Zsh
sudo apt-get install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo chsh -s $(which zsh)
sudo apt-get install fonts-powerline -y

# More tools
sudo apt-get install hdf5-tools -y
sudo apt-get install hdfview -y
sudo apt-get install ffmpeg -y
sudo apt-get install libeigen3-dev -y


echo "Install Python (y/n)?"
read check_install
if [ $check_install = "y" ]; then
    sudo apt install python3-pip -y
    pip3 install --upgrade pip
    pip3 install jupyter
fi

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

echo "Install Spotify (y/n)?"
read spotify_install
if [ $spotify_install = "y" ]; then
    sudo apt install snapd
   snap install spotify
fi

echo "Install Atom (y/n)?"
read atom_install
if [ $atom_install = "y"]; then
    snap install atom --classic
fi

echo "Install Chromium (y/n)?"
read check_install
if [ $check_install = "y" ]; then
    sudo apt-get install chromium-browser -y
fi

# Copy Atom files 
if [ ! -d "$HOME/.atom" ]; then
    mkdir $HOME/.atom
fi
cp -a .atom/. ~/.atom/

# Create Symlinks
sudo ln -s .vimrc ~/.vimrc
sudo ln -s .zshrc ~/.zshrc

