#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$ROOT_DIR/modules/deps.sh"
source "$ROOT_DIR/modules/links.sh"
source "$ROOT_DIR/modules/vim.sh"
source "$ROOT_DIR/modules/tmux.sh"

usage() {
    echo "Usage:"
    echo "  $0 -i user"
    echo "  $0 -i root"
    echo "  $0 -a"
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

MODE="$1"

case "$MODE" in
    -i)
        TARGET="$2"
        if [ "$TARGET" != "user" ] && [ "$TARGET" != "root" ]; then
            usage
            exit 1
        fi

        install_deps
        install_links "$TARGET"
        install_vim "$TARGET"
        install_tmux "$TARGET"
        ;;
    -a)
        install_deps
        install_links "user"
        install_vim "user"
        install_tmux "user"

        install_links "root"
        install_vim "root"
        install_tmux "root"
        ;;
    *)
        usage
        exit 1
        ;;
esac
