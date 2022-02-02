#!/bin/sh

pkg install -y vim tmux bash sudo 

if [[ $(id -u) -ne 0 ]]; then
    echo "Install as root"
    conf_dir="/root"
else
    echo "Install as $(whoami)"
    conf_dir="/home/$(whoami)"
fi


# Configuration

cp ./.vimrc  $conf_dir
cp -r ./.vim $conf_dir
cp -r ./.tmux.conf $conf_dir

mkdir -p "$conf_dir/.tmux/plugins"
[ -d "$conf_dir/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm /home/$(whoami)/.tmux/plugins/tpm
