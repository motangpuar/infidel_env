#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------
# Go toolchain + formatter tools.
# Manager-agnostic: official tarball from go.dev (checksum verified) plus
# "go install" — no pacman/apt/dnf involvement.
# ------------------------------------------------------------------
GO_VERSION="1.27.3"              # pinned baseline; --go-latest resolves newest stable
GO_DL_API="https://go.dev/dl/?mode=json"
GO_TOOLS=(
  "golang.org/x/tools/cmd/goimports:goimports"
  "mvdan.cc/gofumpt:gofumpt"
)
GO_LATEST=0

# ------------------------------------------------------------------
# CoC.nvim extensions — installed only when missing from the Coc data
# dir (~/.config/coc/extensions/node_modules).
# ------------------------------------------------------------------
COC_EXTENSIONS=(
  "coc-vimlsp"
  "coc-sh"
  "coc-python"
  "coc-spell-checker"
)

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
  cat <<EOF
Usage: install.sh [OPTIONS]

Options:
  -t, --target <user|root>   Target user for install (default: user)
  -l, --links-only           Create symlinks only (no network/git)
  -d, --deps-only            Check dependencies only
  -a, --all                  Install for both user and root
  -T, --test                 Headless vim smoke test (no env changes)
      --go-latest            Install newest stable Go instead of pinned v$GO_VERSION
  -h, --help                 Show this help

Examples:
  install.sh                          # install for current user (links + plugins)
  install.sh -t root                  # install for root
  install.sh -l                       # symlinks only, current user
  install.sh -t root -l               # symlinks only, for root
  install.sh -a                       # install for user and root
  install.sh --go-latest              # install newest stable Go + formatter tools
  install.sh -T                       # headless vim test, touches nothing
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
  if command -v go >/dev/null 2>&1; then
    printf '[OK] go found: %s\n' "$(command -v go)"
  elif [ -x "$HOME/.local/go/bin/go" ]; then
    printf '[OK] go found: %s\n' "$HOME/.local/go/bin/go"
  else
    printf '[WARN] go not found. Go formatters (gofmt/goimports) need it.\n'
  fi
  local t
  for t in gofmt goimports gofumpt; do
    if command -v "$t" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$t" ]; then
      printf '[OK] %s found\n' "$t"
    else
      printf '[WARN] %s not found (install.sh installs it)\n' "$t"
    fi
  done
}

# ------------------------------------------------------------------
# Go helpers — no jq dependency, no package manager.
# ------------------------------------------------------------------
go_latest_version() {
  curl -fsSL "$GO_DL_API" 2>/dev/null \
    | sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' | head -1
}

go_tarball_sha256() {
  local file="$1"
  curl -fsSL "${GO_DL_API}&include=all" 2>/dev/null | awk -v f="$file" '
    $0 ~ "\"filename\": \"" f "\"" {found=1}
    found && /"sha256":/ {gsub(/[^0-9a-f]/,"",$2); print $2; exit}'
}

install_go() {
  local target="${1:-user}"
  local home="$HOME"; [ "$target" = "root" ] && home="/root"
  local goroot="$home/.local/go"
  local gobin="$home/.local/bin"

  local go_bin=""
  if command -v go >/dev/null 2>&1; then
    printf '[OK] go detected: %s\n' "$(command -v go)"
    go_bin="$(command -v go)"
  elif [ -x "$goroot/bin/go" ]; then
    printf '[OK] go already installed: %s\n' "$goroot/bin/go"
    go_bin="$goroot/bin/go"
  else
    local ver="$GO_VERSION"
    if [ "$GO_LATEST" -eq 1 ]; then
      ver="$(go_latest_version || true)"
      if [ -z "$ver" ]; then
        printf '[WARN] could not resolve latest Go version — falling back to pinned go%s\n' "$GO_VERSION"
        ver="go$GO_VERSION"
      else
        printf '[INFO] Using latest stable Go: %s\n' "$ver"
      fi
    else
      local latest; latest="$(go_latest_version || true)"
      if [ -n "$latest" ] && [ "$latest" != "go$ver" ]; then
        printf '[INFO] newer stable Go available: %s (pinned: go%s) — re-run with --go-latest\n' "$latest" "$ver"
      fi
    fi
    ver="${ver#go}"

    local arch
    case "$(uname -m)" in
      x86_64)        arch="amd64" ;;
      aarch64|arm64) arch="arm64" ;;
      *) printf '[WARN] unsupported architecture: %s\n' "$(uname -m)"; return 1 ;;
    esac

    local tarball="go${ver}.linux-${arch}.tar.gz"
    local url="https://go.dev/dl/${tarball}"
    local sha; sha="$(go_tarball_sha256 "$tarball" || true)"
    if [ -z "$sha" ]; then
      printf '[WARN] no checksum published for %s — refusing to install\n' "$tarball"
      return 1
    fi

    local tmp; tmp="$(mktemp -d)"
    printf '[INFO] Downloading %s\n' "$url"
    if ! curl -fsSL -o "$tmp/$tarball" "$url"; then
      printf '[WARN] download failed: %s\n' "$url"
      rm -rf "$tmp"; return 1
    fi
    if ! printf '%s  %s\n' "$sha" "$tmp/$tarball" | sha256sum -c - >/dev/null 2>&1; then
      printf '[WARN] checksum mismatch for %s — aborting\n' "$tarball"
      rm -rf "$tmp"; return 1
    fi
    mkdir -p "$home/.local"
    rm -rf "$goroot"
    if ! tar -C "$home/.local" -xzf "$tmp/$tarball"; then
      printf '[WARN] extraction failed\n'
      rm -rf "$tmp"; return 1
    fi
    rm -rf "$tmp"
    go_bin="$goroot/bin/go"
    printf '[OK] go %s installed -> %s\n' "$ver" "$go_bin"

    # Expose go + gofmt through the PATH-wired directory
    mkdir -p "$gobin"
    ln -sf "$goroot/bin/go" "$gobin/go"
    [ -x "$goroot/bin/gofmt" ] && ln -sf "$goroot/bin/gofmt" "$gobin/gofmt"
  fi

  # --- formatter tools ---
  local mods=() entry mod bin
  for entry in "${GO_TOOLS[@]}"; do
    mod="${entry%%:*}"
    bin="${entry##*:}"
    if [ -x "$gobin/$bin" ] || command -v "$bin" >/dev/null 2>&1; then
      printf '[OK] %s already installed\n' "$bin"
    else
      mods+=("$mod@latest")
    fi
  done
  if [ "${#mods[@]}" -eq 0 ]; then
    return 0
  fi
  local pkg rc=0
  for pkg in "${mods[@]}"; do
    printf '[INFO] go install %s -> %s\n' "$pkg" "$gobin"
    if ! GOBIN="$gobin" "$go_bin" install "$pkg"; then
      printf '[WARN] go install failed: %s\n' "$pkg"
      rc=1
    fi
  done
  return $rc
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
    coc_setup "$coc"
  else
    printf '[WARN] coc.nvim not found at %s\n' "$coc"
  fi
}

# Bootstrap coc.nvim + install only the missing CoC extensions.
# - release builds (build/index.js present) ship fully bundled — no npm
#   step at all; upstream releases have no package-lock.json, so the old
#   unconditional `npm ci` always died with EUSAGE on existing installs.
# - source builds: `npm ci` when a lockfile exists, else `npm install`.
# - extensions already present in the Coc data dir are never reinstalled.
coc_setup() {
  local coc="$1"

  if [ -f "$coc/build/index.js" ]; then
    printf '[OK] coc.nvim present (release build, self-contained) — skipping npm\n'
  elif [ -d "$coc/node_modules" ]; then
    printf '[OK] coc.nvim deps present — skipping npm\n'
  elif [ ! -f "$coc/package.json" ]; then
    printf '[WARN] no package.json in %s — cannot bootstrap dependencies\n' "$coc"
  elif command -v npm >/dev/null 2>&1; then
    printf '[INFO] Installing coc.nvim dependencies (source build)\n'
    if [ -f "$coc/package-lock.json" ]; then
      (cd "$coc" && npm ci --no-audit --no-fund --no-progress) || printf '[WARN] npm ci failed for coc.nvim\n'
    else
      # upstream ships no lockfile; npm ci would hard-fail with EUSAGE
      (cd "$coc" && npm install --no-audit --no-fund --no-progress) || printf '[WARN] npm install failed for coc.nvim\n'
    fi
  else
    printf '[WARN] npm not found — CoC.nvim source build needs node/npm\n'
  fi

  # CoC data dir: XDG first, then legacy ~/.vim/coc
  local ext_root="${XDG_CONFIG_HOME:-$HOME/.config}/coc/extensions"
  [ -d "$HOME/.vim/coc/extensions" ] && ext_root="$HOME/.vim/coc/extensions"

  local missing=()
  local ext
  for ext in "${COC_EXTENSIONS[@]}"; do
    if [ -d "$ext_root/node_modules/$ext" ]; then
      printf '[OK] %s already installed — skipping\n' "$ext"
    else
      missing+=("$ext")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    if command -v npm >/dev/null 2>&1; then
      # Install with npm directly — same layout coc's own installer uses
      # (node_modules under the data dir). Headless `CocInstall -sync` can
      # deadlock in `vim -es`, so we mirror it deterministically.
      printf '[INFO] Installing CoC extensions: %s\n' "${missing[*]}"
      mkdir -p "$ext_root/node_modules"
      # Merge existing extensions into package.json first: npm prunes
      # packages that are not listed as dependencies.
      if command -v node >/dev/null 2>&1; then
        node -e '
          const fs = require("fs"), path = require("path");
          const root = process.argv[1], add = process.argv.slice(2);
          const pj = path.join(root, "package.json");
          let pkg = { dependencies: {} };
          try { pkg = JSON.parse(fs.readFileSync(pj, "utf8")); } catch (e) {}
          pkg.dependencies = pkg.dependencies || {};
          const nm = path.join(root, "node_modules");
          const names = [];
          if (fs.existsSync(nm)) {
            for (const e of fs.readdirSync(nm)) {
              if (e.startsWith("@")) {
                for (const s of fs.readdirSync(path.join(nm, e))) names.push(e + "/" + s);
              } else names.push(e);
            }
          }
          for (const n of names) {
            try {
              const meta = JSON.parse(fs.readFileSync(path.join(nm, n, "package.json"), "utf8"));
              const key = meta.name || n;
              if (!(key in pkg.dependencies)) pkg.dependencies[key] = "*";
            } catch (e) {}
          }
          for (const a of add) if (!(a in pkg.dependencies)) pkg.dependencies[a] = "*";
          fs.writeFileSync(pj, JSON.stringify(pkg, null, 2) + "\n");
        ' "$ext_root" "${missing[@]}" 2>/dev/null \
          || printf '[WARN] could not merge extension package.json\n'
      elif [ ! -f "$ext_root/package.json" ]; then
        printf '{\n  "dependencies": {}\n}\n' > "$ext_root/package.json"
      fi
      (cd "$ext_root" && npm install --no-audit --no-fund --no-progress "${missing[@]}") \
        || printf '[WARN] npm install failed for CoC extensions\n'
      local m
      for m in "${missing[@]}"; do
        if [ -d "$ext_root/node_modules/$m" ]; then
          printf '[OK] %s installed\n' "$m"
        else
          printf '[WARN] %s NOT installed\n' "$m"
        fi
      done
    else
      printf '[WARN] npm not found — install CoC extensions manually: %s\n' "${missing[*]}"
    fi
  else
    printf '[OK] All CoC extensions present — nothing to install\n'
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

test_vim() {
  local tmp; tmp=$(mktemp -d)
  local test_vimrc; test_vimrc="$tmp/vimrc"
  local test_home; test_home="$tmp/home"
  mkdir -p "$test_home/.vim"
  cp -r "$ROOT_DIR/config/vim/runtime/"* "$test_home/.vim/" 2>/dev/null || cp -r "$ROOT_DIR/config/vim/runtime/autoload" "$test_home/.vim/"
  cp "$ROOT_DIR/config/vim/vimrc" "$test_vimrc" 2>/dev/null || true
  printf '[INFO] Headless test: %s (temp dir %s, home %s)\n' "${CMD:-vim -es}" "$tmp" "$test_home"
  # PlugInstall smoke test only; CoC extension install is covered by
  # coc_setup() (CocInstall headless can hang in `vim -es`).
  if command -v nvim >/dev/null 2>&1; then
    HOME="$test_home" nvim --headless -u "$test_vimrc" +PlugInstall +qall
    printf '[OK] nvim PlugInstall exit %d\n' $?
  else
    HOME="$test_home" vim -es -u "$test_vimrc" +PlugInstall +qall
    printf '[OK] vim PlugInstall exit %d\n' $?
  fi
  printf '[INFO] Temp kept: %s (plugins under %s/.vim/plugged)\n' "$tmp" "$test_home"
  # rm -rf "$tmp"  # uncomment to auto-clean; kept for inspection
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
# ------------------------------------------------------------------
# CLI parsing with getopts (short) + manual long-opt support
# ------------------------------------------------------------------
TARGET="user"
LINKS_ONLY=0
DEPS_ONLY=0
ALL=0
TEST_ONLY=0

# Convert long opts to short for getopts
for arg; do
  case "$arg" in
    --target=*) set -- "$@" "-t" "${arg#*=}"; shift ;;
    --target)   set -- "$@" "-t" "${2:-}"; shift 2 ;;
    --links-only)  set -- "$@" "-l"; shift ;;
    --deps-only)   set -- "$@" "-d"; shift ;;
    --all)         set -- "$@" "-a"; shift ;;
    --test)        set -- "$@" "-T"; shift ;;
    --go-latest)   set -- "$@" "-G"; shift ;;
    --help)        set -- "$@" "-h"; shift ;;
    *)            set -- "$@" "$arg"; shift ;;
  esac
done

while getopts ":t:ldahTG" opt; do
  case $opt in
    t) TARGET="$OPTARG" ;;
    l) LINKS_ONLY=1 ;;
    d) DEPS_ONLY=1 ;;
    a) ALL=1 ;;
    T) TEST_ONLY=1 ;;
    G) GO_LATEST=1 ;;
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
if [ "$TEST_ONLY" -eq 1 ]; then
  test_vim
  exit 0
fi

if [ "$DEPS_ONLY" -eq 1 ]; then
  install_deps
  exit 0
fi

if [ "$ALL" -eq 1 ]; then
  install_links user
  install_deps
  install_go user
  install_vim user
  install_tmux user
  install_links root
  install_go root
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
install_go "$TARGET"
install_vim "$TARGET"
install_tmux "$TARGET"
fi