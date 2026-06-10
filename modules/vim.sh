#!/usr/bin/env bash

install_vim() {
    local target="$1"

    local home="$HOME"
    if [ "$target" = "root" ]; then
        home="/root"
    fi

    vim +PlugInstall +qall

    vim -c "CocInstall coc-vimlsp coc-sh coc-python coc-spell-checker" || true
}
