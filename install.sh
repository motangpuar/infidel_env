#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------
# Config manifest — links applied for user or root target.
# Format: "relative_src  dst_path" (dst expanded with ~)
# ------------------------------------------------------------------
LINKS=(
  "config/vim/runtime         ~/.vim"
  "config/vim/vimrc          ~/.vimrc"
  "config/tmux/tmux.conf     ~/.tmux.conf"
  "config/kitty/kitty.conf              ~/.config/kitty/kitty.conf"
  "config/kitty/colors.conf             ~/.config/kitty/colors.conf"
  "config/kitty/chalk.conf              ~/.config/kitty/chalk.conf"
  "config/kitty/seoul256-light.conf     ~/.config/kitty/seoul256-light.conf"
  "config/kitty/tab_bar.py              ~/.config/kitty/tab_bar.py"
  "config/ghostty/config                ~/.config/ghostty/config"
  "config/ghostty/config.ghostty        ~/.config/ghostty/config.ghostty"
  "config/ghostty/auto/theme.ghostty    ~/.config/ghostty/auto/theme.ghostty"
  "config/zellij/config.kdl             ~/.config/zellij/config.kdl"
  "config/zellij/layouts                ~/.config/zellij/layouts"
  "config/zellij/plugins                ~/.config/zellij/plugins"
)

# ------------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Options:
  -t, --target <user|root>   Target user for install (default: user)
  -l, --links-only           Create symlinks only (no network/git)
  -d, --deps-only            Check dependencies only
  -a, --all                  Install for both user and root
  -h, --help                 Show this help

Examples:
  install.sh                          # install for current user (links + plugins)
  install.sh -t root                  # install for root
  install.sh -l                       # symlinks only, current user
  install.sh -t root -l               # symlinks only, for root
  install.sh -a                       # install for user and root
EOF
}

# ------------------------------------------------------------------
expand_home() {
  local p="$1" h="$2"
  [ "${p:0:1}" = "~" ] && printf '%s%s' "$h" "${p:1}" || printf '%s' "$p"
}

link_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%s)"
  fi
  ln -sf "$src" "$dst"
  printf '  linked  %s -> %s\n' "$dst" "$src"
}

install_links() {
  local target="${1:-user}"
  local base="$HOME"
  [ "$target" = "root" ] && base="/root"
  printf '[INFO] Linking configs for target=%s (home=%s)\n' "$target" "$base"
  for entry in "${LINKS[@]}"; do
    local src="${entry%% *}" dst="${entry##* }"
    link_file "$ROOT_DIR/$src" "$(expand_home "$dst" "$base")"
  done
}

install_deps() {
  printf '[INFO] Checking dependencies\n'
  if ! command -v node >/dev/null 2>&1; then
    printf '[WARN] node not found. CoC.nvim needs it. Install manually.\n'
  else
    printf '[OK] node found\n'
  fi
}

install_vim() {
  local target="${1:-user}"
  [ "$target" = "root" ] && { printf '[INFO] Skipping vim plugins for root (run manually)\n'; return; }
  command -v nvim >/dev/null 2>&1 || command -v vim >/dev/null 2>&1 || { printf '[WARN] neither nvim nor vim found, skipping\n'; return; }

  if command -v nvim >/dev/null 2>&1; then
    CMD="nvim --headless"
  else
    CMD="vim -es"
  fi

  printf '[INFO] Installing vim plugins (headless via %s)\n' "$CMD"
  $CMD -u "$ROOT_DIR/config/vim/vimrc" +PlugInstall +qall 2>/dev/null || printf '[WARN] PlugInstall returned non-zero\n'

  local coc="$HOME/.vim/plugged/coc.nvim"
  if [ -d "$coc" ]; then
    printf '[INFO] Installing CoC extensions\n'
    (cd "$coc" && npm ci) || printf '[WARN] npm ci failed for coc.nvim\n'
    $CMD -c "CocInstall coc-vimlsp coc-sh coc-python coc-spell-checker" || true
  else
    printf '[WARN] coc.nvim not found at %s\n' "$coc"
  fi
}

install_tmux() {
  local target="${1:-user}"
  local home="$HOME"; [ "$target" = "root" ] && home="/root"
  local tpm="$home/.tmux/plugins/tpm"
  if [ -d "$tpm" ]; then
    printf '[OK] TPM already installed\n'
  else
    printf '[INFO] Installing TPM (tmux plugin manager)\n'
    git clone https://github.com/tmux-plugins/tpm "$tpm"
  fi
}

# ------------------------------------------------------------------
# CLI parsing with getopts (short) + manual long-opt support
# ------------------------------------------------------------------
TARGET="user"
LINKS_ONLY=0
DEPS_ONLY=0
ALL=0

# Convert long opts to short for getopts
for arg; do
  case "$arg" in
    --target=*) set -- "$@" "-t" "${arg#*=}"; shift ;;
    --target)   set -- "$@" "-t" "${2:-}"; shift 2 ;;
    --links-only)  set -- "$@" "-l"; shift ;;
    --deps-only)   set -- "$@" "-d"; shift ;;
    --all)         set -- "$@" "-a"; shift ;;
    --help)        set -- "$@" "-h"; shift ;;
    *)            set -- "$@" "$arg"; shift ;;
  esac
done

while getopts ":t:ldah" opt; do
  case $opt in
    t) TARGET="$OPTARG" ;;
    l) LINKS_ONLY=1 ;;
    d) DEPS_ONLY=1 ;;
    a) ALL=1 ;;
    h) usage; exit 0 ;;
    :) printf 'Missing argument for -%s\n' "$OPTARG" >&2; usage; exit 1 ;;
    \?) printf 'Unknown option: -%s\n' "$OPTARG" >&2; usage; exit 1 ;;
  esac
done

# Validate target
[ "$TARGET" = "user" ] || [ "$TARGET" = "root" ] || { printf 'Invalid target: %s (must be user|root)\n' "$TARGET" >&2; exit 1; }

# ------------------------------------------------------------------
# Execution
# ------------------------------------------------------------------
if [ "$DEPS_ONLY" -eq 1 ]; then
  install_deps
  exit 0
fi

if [ "$ALL" -eq 1 ]; then
  install_links user
  install_deps
  install_vim user
  install_tmux user
  install_links root
  install_vim root
  install_tmux root
  exit 0
fi

if [ "$LINKS_ONLY" -eq 1 ]; then
  install_links "$TARGET"
  exit 0
fi

# Default: links + plugins + deps
install_links "$TARGET"
install_deps
install_vim "$TARGET"
install_tmux "$TARGET"