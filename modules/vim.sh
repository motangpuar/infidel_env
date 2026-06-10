#!/usr/bin/env bash

install_vim() {
    local target="$1"

    local home="$HOME"
    if [ "$target" = "root" ]; then
        home="/root"
    fi

    vim +PlugInstall +qall

    COC_DIR="$HOME/.vim/plugged/coc.nvim"
    
    if [ -d "$COC_DIR" ]; then
        echo "[INFO] Installing coc.nvim dependencies"
        cd "$COC_DIR"
        npm ci
    else
        echo "[WARN] coc.nvim not found"
    fi

    vim -c "CocInstall coc-vimlsp coc-sh coc-python coc-spell-checker" || true
}
