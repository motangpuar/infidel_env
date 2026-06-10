#!/usr/bin/env bash

install_deps() {
    echo "[INFO] Installing dependencies"

    # Node is intentionally separated so it is visible and controllable
    if ! command -v node >/dev/null 2>&1; then
        echo "[INFO] Node not found, installing via script"
        bash "$ROOT_DIR/scripts/node_install.sh"
    fi
}
