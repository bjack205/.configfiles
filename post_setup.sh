ZSHRC=$HOME/.zshrc
VIMRC=$HOME/.vimrc
if [ -f "$ZSHRC" ]; then
    rm $ZSHRC 
    echo "removing zshrc"
fi
if [ -f "$VIMRC" ]; then
    rm $VIMRC 
    echo "removing vimrc"
fi
sudo ln -s $PWD/.zshrc $ZSHRC
sudo ln -s $PWD/.vimrc $VIMRC 

VSKEYS=$HOME/.config/Code/User/keybindings.json
VSSET=$HOME/.config/Code/User/settings.json
if [ -f "$VSKEYS" ]; then
    rm $VSKEYS
fi
if [ -f "$VSSET" ]; then
    rm $VSSET
fi
sudo ln -s $PWD/keybindings.json $VSKEYS
sudo ln -s $PWD/settings.json $VSSET

