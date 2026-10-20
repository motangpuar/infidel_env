# Memories / State Ledger

- **Current Status:** vimrc hardened + Go toolchain/formatter installer + CI workflows (GitHub + Gitea Actions) with README badges. Branch `test/refactor-install` @ `7de8a96` (local only; `7fb0a3e` is the last pushed commit).
- **Active State:** `install.sh` (Go install flow), `config/vim/vimrc` (autocmd pattern fix), `AGENTS.md` (push policy + commit identity), `MEMORIES.md` (this ledger).
- **Known Blockers:** None.
- **Next Steps:**
  1. User validation of vim (coc completion, TAB/S-TAB) after the CoC install fix.
  2. Decide remaining Neoformat formatters for py/js/yaml/json (`black`/`ruff`/`prettier` are absent).
  3. **Push:** `origin test/refactor-install` + `gitea test/refactor-install` both carried `bd9be0a`; GitHub Actions workflow registered (`ci.yml`, active) — badges will now show CI status.
  4. Update the Gitea badge URL if the active branch name changes (it currently is `test/refactor-install`).
  5. Run CI locally (manual `./install.sh -h ./install.sh -l` then `vim -es`) to confirm the banner matches reality; or wait for CI runs on push.
- **Regression fixes (2nd pass):**
  - Kitty OSC bg was changed `#242424` -> `#f6f6ee` while fg stayed `#f6f3e8` => near-white on near-white => **invisible text**. Restored original `#242424`.
  - Dropped `set termguicolors` (was in original) => colours fell back to 256 mode. Restored.
  - Dropped the whole CoC insert-mode block (`s:check_back_space` + `<TAB>`/`<CR>` inoremap) => **TAB no longer triggered coc autocomplete**. Restored + added explicit `<S-TAB>`.
  - Removed the `ColorScheme` autocmd that forced `hi Normal ... NONE` — it fought the light scheme (dark canvas + light-scheme colours = bad contrast). Original had no such override.
- **Verified (PTY tests, not just file inspection):**
  - `ESC[Z` (kitty Shift+Tab) -> buffer contains `\t` — via real PTY, real terminfo (`t_kB`).
  - kitty OSC emitted: `OSC 10 = #f6f3e8`, `OSC 11 = #242424`.
  - Truecolor active: `termguicolors=1`, 110 truecolor fg + 104 bg SGR seqs, bg `#fbf1c7` / fg `#654735`.
  - `colors=gruvbox-material`, harness exit 0 (no load errors, no hang).
- **Key mapping semantics decided:** `<TAB>` = coc autocomplete (next candidate), `<S-TAB>` = previous candidate when popup open / literal tab when closed, `<CR>` = accept completion. Matches Vim's own docs (`insert.txt:1164`).
- **Colour scheme:** restored **seoul256-light** (user's original) as primary.
  - `silent! colorscheme seoul256-light` -> falls back to gruvbox-material if absent (guards E185, never blocks startup).
  - Earlier E10 (seoul256.vim:39 `\{` continuation) was **not reproducible in isolation** — the original HEAD vimrc loads clean via the harness. It was collateral damage from the broken intermediate vimrc (E518/E1511 errors left the sourced script in a bad state).
  - Verified: `colors=seoul256-light`, `bg=light`, `Normal: ctermfg=239 ctermbg=253 guifg=#616161 guibg=#E1E1E1`.
  - Painted truecolor: bg `48;2;225;225;225` (#E1E1E1) + fg `38;2;97;97;97` (#616161) = light theme, readable.
  - kitty OSC unchanged from original: fg `#f6f3e8`, bg `#242424` (terminal default only, outside the canvas).
- **Go toolchain + formatters (manager-agnostic):** `install.sh` now fetches Go itself via `curl`
  from the official go.dev tarball (sha256 verified against `https://go.dev/dl/?mode=json&include=all`),
  extracts to `~/.local/go`, symlinks `go`+`gofmt` into `~/.local/bin` (already on PATH via `.bashrc:15`),
  then `GOBIN=~/.local/bin go install` for `goimports` + `gofumpt`.
  - Pinned `GO_VERSION="1.27.3"`; `--go-latest` resolves newest stable from the JSON API.
  - Skip logic: `go` on PATH -> skip toolchain; `~/.local/go/bin/go` present -> skip; per-tool skip in `~/.local/bin`.
  - **Bug found in testing:** `go install a@latest b@latest` fails with "All packages must be provided by the same module" — must install one package per invocation.
  - **No jq dependency:** version parsed with `sed`, sha256 with `awk` (jq present but not required).
  - **go.dev `.sha256` sidecar URLs are dead** (HTML redirect) — checksums only via the JSON API.
  - `goimports` shells out to `go` -> requires `go` on `$PATH`; satisfied by the `~/.local/bin` symlink + vimrc `$PATH` prepend.
- **vimrc:** added `let $PATH = $HOME . '/.local/bin:' . $PATH` (formatters found regardless of launch path: lazygit, root, non-interactive shells).
- **Neofomat-on-save bug (critical, fixed in `a1ea4e0`):** format-on-save never worked for `.go`/`.py`/`.cpp`/`.yaml`/`.json`.
  - **Root cause 1 — `:autocmd` takes ONE pattern.** Multiple patterns must be **comma separated** (`autocmd.txt` §"autocmd-patterns": "{aupat} can be a comma-separated list"). The refactor had converted `*.js,*.py,*.cpp,*.go,*.yaml` into a **space separated** list => only `*.js` was registered, the rest became part of the *command* => `.js` saves raised `E492: Not an editor command: *.py`, other filetypes never fired at all. The pre-refactor original (`e5082a0`) had the commas right — the regression was mine.
  - **Root cause 2 — `|` is split at the Ex level.** `autocmd BufWritePre *.go undojoin | Neoformat` registers only `undojoin` and executes ` Neoformat` at *definition* time. The upstream README pattern (`undojoin | Neoformat`) is broken for the same reason. A bar inside an autocmd definition must be avoided entirely.
  - **Fix:** comma separated patterns + script-local functions with no bar: `s:NeoFormatOnSave()` (does `silent! undojoin` + `Neoformat`) and `s:RestoreCursorPos()` (replaces the `if ... | exe ... | endif` RecallCursorPos autocmd, which had the same bar problem).
  - **Verified (PTY):** `.go` save removes the unused `"os"` import and reindents; `exists('#NeoformatAuto#BufWritePre#*.go')` = 1; cursor recall still restores line 8; `vimcheck` exit 0; `colors=seoul256-light`, `bg=light`, `termguicolors=1` unchanged.
  - **Diagnostic lesson:** `:autocmd` listing shows pattern+command concatenated, so it *looks* like all six patterns were registered. Use `execute('autocmd <group>')` + `exists('#group#event#pat')` to check what is really registered.
- **Neoformat:** `g:neoformat_enabled_go = ['goimports', 'gofumpt']` (stock `gofmt` would shadow goimports, losing import fixing); autocmd calls `s:NeoFormatOnSave()`.
  - Note: `vim -es` headless makes Neoformat appear to no-op — verify formatter behaviour in a real PTY, not `-es`.
- **Commit identity:** all commits use `infidel <ninoagus@protonmail.com>` (repo-local `user.name`/`user.email` pinned). Two commits made with a wrong `-c user.name=pi` override were rewritten via `reset --mixed` + recommit before pushing; AGENTS.md now forbids identity overrides.
- **CI (GitHub Actions + Gitea Actions):** minimal, no-plugin-install workflows.
  - Files: `.github/workflows/ci.yml` (GitHub) and `.gitea/workflows/ci.yml` (Gitea). Content identical except checkout: Gitea uses `builtin:checkout` (no github.com download, no node required); GitHub uses `actions/checkout@v4`.
  - Job (4 steps): `bash -n install.sh scripts/*.sh` -> `./install.sh -h` -> `./install.sh -l` -> `vim -es --not-a-term -u ~/.vimrc -c 'qa!'` (installs vim via apt-get only if missing, root or sudo).
  - **Design decisions:** `install.sh -T` (full PlugInstall) deliberately NOT in CI — plugin download makes CI network-fragile and slow. `plug.vim` IS tracked in `config/vim/runtime/autoload/`, so the vimrc loads cleanly (via `silent!` colorscheme fallbacks) with zero plugins installed — only `-h`/`-l` are needed.
  - **vimrc validation = exit code.** Empirically verified: broken vimrc -> `vim -es` exits 1; clean -> exits 0. No message parsing needed.
  - **Validated locally:** both YAMLs parsed with the bundled `yaml` npm package; every CI step ran successfully in a clean sandbox HOME (`HOME=$(mktemp -d) ./install.sh -l` symlinks `.vimrc`/`.vim`); negative test (appended bad command to vimrc) -> exit 1, restored.
  - **Badge endpoints:** GitHub badge `.../actions/workflows/ci.yml/badge.svg?branch=test%2Frefactor-install` -> "CI - passing" (200). Gitea badge -> the native endpoint `.../badge.svg` renders "ci: success" (green #4c1) but **ignores `logo=`** (no logo support, and it is served directly, not redirected to shields), so the README uses a **shields.io dynamic JSON badge** instead: `img.shields.io/badge/dynamic/json?url=<gitea api>&query=$.workflow_runs[0].status&label=CI&color=4c1&logo=gitea&logoColor=white` -> "CI: success" with the real Gitea logo (base64 `<title>Gitea</title>` in the SVG). shields.io **cannot** derive the color from the data (color is static), so the *text* is the live status signal; color is Gitea brand green.
  - **Requires before Gitea runs:** Actions enabled on the repo (`Enable Repository Actions` in repo settings) + a registered Gitea runner with the `ubuntu-latest` label (default label).
  - Not pushed; runs only trigger after an explicit push.
- **Chronology:**
  - **Session: CoC install catering (commit pending):**
    - **Root cause of the `npm ci` EUSAGE failure:** the checkout is the **`release` branch of coc.nvim** (`coc.nvim-release@0.0.82`) — `package.json` has **zero dependencies** and upstream ships **no `package-lock.json`**; `build/index.js` is fully bundled (no external `require()`s). So `npm ci` can never succeed and was never needed. Release coc.nvim needs **no npm step at all**.
    - Rewrote the CoC block in `install_vim()` into a `coc_setup()` helper:
      - `build/index.js` present (release build) or `node_modules` present -> skip npm entirely.
      - source build -> `npm ci` only if a lockfile exists, else `npm install --no-audit --no-fund --no-progress` (npm ci would hard-fail EUSAGE without a lockfile).
      - extensions: checked against `${XDG_CONFIG_HOME:-~/.config}/coc/extensions/node_modules` (legacy `~/.vim/coc/extensions` preferred if it exists); only **missing** ones installed.
      - extension install is done **with npm directly** (`npm install --prefix <ext_root> ...` layout), mirroring coc's own installer — headless `CocInstall -sync` **deadlocks in `vim -es`** (timed out at 120s in test).
      - before npm install, existing `node_modules/*` entries are merged into `<ext_root>/package.json` (npm **prunes** packages not listed as deps — verified).
      - `test_vim()` CoC section trimmed to PlugInstall smoke test (CocInstall headless can hang).
    - Verified: sandbox (all-present -> full skip; missing ext -> npm install, all 4 present after) + real HOME rerun -> all skip, exit 0.
    - Gotcha while testing: the harness shell exports `XDG_CONFIG_HOME`/`XDG_DATA_HOME` -> sandbox tests must pin `XDG_CONFIG_HOME=$SB/.config` or they read the real user's coc data.
    - **User already ran `./install.sh` on real HOME:** Go 1.27.3 + gofmt/gofumpt/goimports installed in `~/.local/bin`; go imports fix verified working.
  - **Session: Go toolchain + Neoformat (commits `b231281`, `7fb0a3e`):**
    - `install.sh`: added `install_go()` — official go.dev tarball via `curl`, sha256 verified against the JSON API, extracted to `~/.local/go`, `go`+`gofmt` symlinked into `~/.local/bin`, `GOBIN=~/.local/bin go install` for `goimports` + `gofumpt`. Pinned `GO_VERSION="1.27.3"` + `--go-latest`. Idempotent skip logic. `--deps-only` reports go/gofmt/goimports/gofumpt. No pacman/apt involvement, no jq dependency, no shell-rc edits.
    - **Bugs found while testing:** (1) `go install a@latest b@latest` -> "All packages must be provided by the same module", fixed with one package per invocation; (2) go.dev `.sha256` sidecar URLs return an HTML redirect (dead) -> checksums only via `?mode=json&include=all`; (3) `goimports` shells out to `go`, so it needs `go` on `$PATH`; (4) `vim -es` headless makes Neoformat look like a no-op -> formatter behaviour must be verified in a real PTY, not `-es`.
    - `config/vim/vimrc`: `let $PATH = $HOME . '/.local/bin:' . $PATH`; `g:neoformat_enabled_go = ['goimports', 'gofumpt']` (stock `gofmt` shadows goimports and loses import fixing); autocmd -> `undojoin | Neoformat`.
    - Verified in an isolated HOME: download -> checksum -> extract -> `go install` -> tools built -> `exepath()` finds them in vim -> PTY session reformatted a messy `.go` file (unused import removed, indentation fixed).
    - **Pushed to origin + gitea (`861dc1e..7fb0a3e`) — done before the push-policy rule existed.**
    - **New rule (AGENTS.md): NEVER `git push` unless the user explicitly asks.** Commit locally; leave unpushed by default.
  - 08:00 session: **vimrc best-practice rewrite — MISTAKES made, lessons learned:**
    - (1) `vim -u vimrc -c 'qa!'` BLOCKS forever on "Press ENTER" when no TTY → 12m47s hang + abort. **Fix: always use `timeout 20 vim -es --not-a-term -u RC </dev/null` harness (saved as /tmp/vimcheck.sh); check exit 124 = hang.**
    - (2) Rewrote file but DROPPED entire `call plug#begin/end()` block → plugins missing from rtp → E185 `colo gruvbox-material` blocked user's lazygit. **Fix: restored plugin block; defensive colorscheme load with fallback chain; ALWAYS diff before/after write (verify key sections survive).**
    - (3) Introduced invalid vim options (E518: `noundoptore`, `nocup`, `updatepipe_name`...) — never emit options not verified with `vim -u NONE -es -c 'set X?'`.
  - Verified: harness exit 0, `colors=gruvbox-material`, `rtp_has_gruvbox=1`, both `~/.vimrc` (symlink) and repo path clean.
  - 02:40 session: consolidated modules, added kitty/ghostty/zellij links, updated README.
  - 02:41 session: headless vim (`-es` / `--headless`) added; `test_vim()` created.
  - 02:42 session: `test_vim` verified (29 plugins + coc installed in temp HOME); README dependencies section added (Arch Linux); AGENTS.md / MEMORIES.md created.
