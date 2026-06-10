#!/usr/bin/env bash

install_tmux() {
    local target="$1"

    local home="$HOME"
    if [ "$target" = "root" ]; then
        home="/root"
    fi

    mkdir -p "$home/.tmux/plugins"

    if [ ! -d "$home/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$home/.tmux/plugins/tpm"
    fi
}
