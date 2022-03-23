#!/bin/bash

# cp ./.vimrc /home/$(whoami)/
# cp -r ./.vim/ /home/$(whoami)/
# cp -r ./.tmux.conf /home/$(whoami)/

echo "VIM Conf"
ln -sf $(pwd)/.vimrc /home/$(whoami)/
ln -sf $(pwd)/.vim/ /home/$(whoami)/
vim -c 'PlugInstall'

echo "TMUX Conf"
ln -sf $(pwd)/.vimrc /home/$(whoami)/
ln -sf $(pwd)/.tmux.conf /home/$(whoami)/

echo "TMUX Plugin"
mkdir -p "/home/$(whoami)/.tmux/plugins"
[ -d "/home/$(whoami)/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm /home/$(whoami)/.tmux/plugins/tpm
