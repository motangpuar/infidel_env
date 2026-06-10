#!/usr/bin/env bash

link_file() {
    local src="$1"
    local dst="$2"

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
