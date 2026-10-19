## VIM

### Global Settings

- Leader key remapped to `,`
- `vim-sensible` — sane defaults
- `termguicolors` enabled
- Background set to **light** (seoul256-light colorscheme)
- 4-space indentation (`tabstop=4`, `softtabstop=4`, `shiftwidth=4`, `expandtab`)
- Line numbers (`set number`)
- Highlight search results (`set hlsearch`), ignorecase + smartcase
- Mouse enabled in all modes (`set mouse=a`)
- OS clipboard integration (`set clipboard=unnamed,unnamedplus`)
- Wrapped-line smart indent (`breakindent`, `breakindentopt=shift:3,min:40,sbr`, `showbreak=...`)
- Color column at 80 (`set colorcolumn=80`)
- Tab navigation via `<Leader>1`–`<Leader>9`
- `H`/`L` mapped to `:tabprevious`/`:tabnext`
- Swap files disabled (`set noswapfile`)
- Auto-wrap markdown/text (`autocmd BufRead,BufNewFile *.md,*.txt setlocal wrap`)

### Plugins (vim-plug)

| Category | Plugins |
|----------|---------|
| Essentials | `jasonccox/vim-wayland-clipboard`, `tpope/vim-sensible`, `scrooloose/nerdtree`, `junegunn/vim-easy-align`, `junegunn/fzf.vim`, `ojroques/vim-oscyank`, `ryanoasis/vim-devicons` |
| Focus/Writing | `junegunn/goyo.vim`, `junegunn/limelight.vim` |
| UI | `gyim/vim-boxdraw`, `vim-airline/vim-airline`, `vim-airline/vim-airline-themes`, `liuchengxu/vista.vim`, `wellle/context.vim` |
| Autocomplete | `neoclide/coc.nvim`, `evanleck/vim-svelte`, `sbdchd/neoformat` |
| LaTeX | `lervag/vimtex` |
| Markdown | `iamcco/markdown-preview.nvim` |
| Coding Practice | `motangpuar/leetcode.vim` (custom_path branch) |
| Colorschemes | `sainnhe/gruvbox-material`, `rakr/vim-two-firewatch`, `joshdick/onedark.vim`, `drewtempelmeyer/palenight.vim`, `kaicataldo/material.vim`, `sainnhe/vim-color-forest-night`, `karoliskoncevicius/sacredforest-vim`, `junegunn/seoul256.vim` |
| Misc | `wakatime/vim-wakatime` |

### Keybindings

| Key(s) | Action |
|--------|--------|
| `<C-k><C-k>` | Toggle NERDTree |
| `<C-p>` | FZF file picker |
| `ga` (visual/motion) | EasyAlign |
| `<F8>` | Toggle Goyo |
| `<Leader>l` | Toggle Limelight |
| `<Leader>1`-`<Leader>9` | Switch to tab N |
| `H` | Previous tab |
| `L` | Next tab |
| `<Leader>y` | OSCYank visual selection |
| `<Leader>ll` | LeetCodeList |
| `<Leader>lt` | LeetCodeTest |
| `<Leader>ls` | LeetCodeSubmit |
| `<Leader>li` | LeetCodeSignIn |

### NerdTree

Toggle with <CTRL-k><k>.

### EasyAlign

Perform multiline visual select then enter `ga`. Next enter your preference alignment.

### Goyo

Toggle from command input: `:Goyo`, or use `<F8>`. Limelight triggers automatically on Goyo enter/leave.

### Limelight

Toggle with `<Leader>l` or command: `:Limelight`.

Configuration:
- Conceal color: `#777777` / `240`
- Default coefficient: `0.7`
- Priority: `-1`

### CoC

Tab navigates completion menu; `<CR>` confirms selection when popup menu is visible (`coc#_select_confirm()`).

```vim
"Tab Navigation
function! s:check_back_space() abort
      let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
```

**CoC Extensions included**:

- `coc-vimlsp` — VIM script
- `coc-pyright` — Python
- `coc-sh` — SH scripts
- `coc-spell-checker` — General spell checker in EN

Other settings:
- Startup warnings disabled (`let g:coc_disable_startup_warning = 1`)
- Markdown fenced languages: `vim`, `help`

### Airline

Status bar with `sacredforest` theme and powerline fonts enabled. Tabline extensions configured with custom separators (`\uE0B4`, `\uE0B6`, `\u2022`).

### VimTeX

- View method: `zathura`
- Compiler: `latexmk`
- Quickfix auto-close after keystrokes

### Completor

> Completor is not good for servers, as it requires vim version with python support. (Commented out in config)

### vimbox-draw

Create ASCII diagrams:

- Visual select some box
- invoke `+o` to create box or `+O` to create box with label
- To add label into existing box, visual select the area then invoke `+c`

### LeetCode.vim

- Solution filetype: `golang`
- Cookie path: `/home/infidel/distrobox/archfox/.config/net.imput.helium/Default/Cookies` (for session persistence)

### Misc

- `vmap < <gv`, `vmap > >gv` — keep VisualMode after indent shift
- `vnoremap J :m '>+1<CR>gv=gv`, `vnoremap K :m '<-2<CR>gv=gv` — move visual blocks with J/K
- Neoformat auto-trigger on save: `*.js,*.py,*.cpp,*.go,*.yaml`
- Cursor position remembered on re-open
- Kitty terminal patch for background colors

## Distrobox

### Rootless Podman from Distrobox

We can enable podman access towards hosts' podman.sock by creating the distrobox with `--init` flag and adding the appropriate flags. This approach may lead to conflict of podman's storage cache between hosts and the box. One foolproof solution would be by properly symlink the hosts's podman bin into the box, this will allow the box to offload all of the podman activity into the host instead while we focus on coding in the box.

```bash
sudo ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
```