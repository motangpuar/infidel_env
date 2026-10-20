# Memories / State Ledger

- **Current Status:** vimrc rewritten with best practices; plugin block restored after accidental deletion; clean load verified.
- **Active State:** `config/vim/vimrc` rewritten (179→225 lines, organized sections); safe test harness `/tmp/vimcheck.sh` created.
- **Known Blockers:** None.
- **Next Steps:** User to review vimrc in lazygit/editor; decide on seoul256-light (colors file has E10 bug at line 39 — plugin-side, report upstream or patch).
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
- **Neoformat:** `g:neoformat_enabled_go = ['goimports', 'gofumpt']` (stock `gofmt` would shadow goimports, losing import fixing); autocmd now uses `undojoin | Neoformat` per upstream README.
  - Note: `vim -es` headless makes Neoformat appear to no-op — verify formatter behaviour in a real PTY, not `-es`.
- **Chronology:**
  - 08:00 session: **vimrc best-practice rewrite — MISTAKES made, lessons learned:**
    - (1) `vim -u vimrc -c 'qa!'` BLOCKS forever on "Press ENTER" when no TTY → 12m47s hang + abort. **Fix: always use `timeout 20 vim -es --not-a-term -u RC </dev/null` harness (saved as /tmp/vimcheck.sh); check exit 124 = hang.**
    - (2) Rewrote file but DROPPED entire `call plug#begin/end()` block → plugins missing from rtp → E185 `colo gruvbox-material` blocked user's lazygit. **Fix: restored plugin block; defensive colorscheme load with fallback chain; ALWAYS diff before/after write (verify key sections survive).**
    - (3) Introduced invalid vim options (E518: `noundoptore`, `nocup`, `updatepipe_name`...) — never emit options not verified with `vim -u NONE -es -c 'set X?'`.
  - Verified: harness exit 0, `colors=gruvbox-material`, `rtp_has_gruvbox=1`, both `~/.vimrc` (symlink) and repo path clean.
  - 02:40 session: consolidated modules, added kitty/ghostty/zellij links, updated README.
  - 02:41 session: headless vim (`-es` / `--headless`) added; `test_vim()` created.
  - 02:42 session: `test_vim` verified (29 plugins + coc installed in temp HOME); README dependencies section added (Arch Linux); AGENTS.md / MEMORIES.md created.
