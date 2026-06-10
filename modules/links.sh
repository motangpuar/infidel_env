#!/usr/bin/env bash

link_file() {
    local src="$1"
    local dst="$2"


    if [ "$target" = "root" ]; then
        base="/root"
    fi

    # Check Path or file exist already
    # If path exist, move to *.bak
    if [ -e "$dst" ]; then
        mv "$dst" "$dst.bak"
    fi
    
    # Do the linking
    ln -sf "$src" "$dst"
}

install_links() {
    local target="$1"

    local base="$HOME"
    if [ "$target" = "root" ]; then
        base="/root"
    fi

    link_file "$ROOT_DIR/config/vim/runtime" "$base/.vim"
    link_file "$ROOT_DIR/config/vim/vimrc" "$base/.vimrc"
    link_file "$ROOT_DIR/config/tmux/tmux.conf" "$base/.tmux.conf"
}
