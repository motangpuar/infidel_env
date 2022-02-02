#!/bin/bash

cp ./.vimrc /home/$(whoami)/
cp -r ./.vim/ /home/$(whoami)/
cp -r ./.tmux.conf /home/$(whoami)/

mkdir -p "/home/$(whoami)/.tmux/plugins"
[ -d "/home/$(whoami)/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm /home/$(whoami)/.tmux/plugins/tpm
