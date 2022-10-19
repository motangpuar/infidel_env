" infidel


call plug#begin('~/.vim/plugged')

" Essentials 
Plug 'tpope/vim-sensible'         " Sensible defaults
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'gyim/vim-boxdraw'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Auto Completes
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc.nvim', 
Plug 'evanleck/vim-svelte', 
" Plug 'sheerun/vim-polyglot'
" Plug 'maralla/completor.vim'
" 

" Color Schemes
Plug 'rakr/vim-two-firewatch' 
Plug 'lifepillar/vim-gruvbox8' 
Plug 'drewtempelmeyer/palenight.vim'
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
" Plug 'UndeadLeech/vim-undead'
" Plug 'sainnhe/everforest' 
Plug 'sainnhe/vim-color-forest-night' 
Plug 'karoliskoncevicius/sacredforest-vim'

" Misc
" Plug 'preservim/vim-markdown'
Plug 'lervag/vimtex'

call plug#end()

" Kitty Patch
let &t_ut=''
if has('gui_running') || has('nvim') 
    hi Normal 		guifg=#f6f3e8 guibg=#242424 
else
    " Set the terminal default background and foreground colors, thereby
    " improving performance by not needing to set these colors on empty cells.
    hi Normal guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
    let &t_ti = &t_ti . "\033]10;#f6f3e8\007\033]11;#242424\007"
    let &t_te = &t_te . "\033]110\007\033]111\007"
endif

let mapleader = ","
syntax on
set re=1
set nocompatible

set number                                          " Show numbers on the left
set hlsearch                                        " Highlight search results
set ignorecase                                      " Search ingnoring case
set smartcase                                       " Do not ignore case if the search patter has uppercase set noerrorbells
set tabstop=4                                       " Tab size of 4 spaces
set softtabstop=4                                   " On insert use 4 spaces for tab
set shiftwidth=4
set expandtab                                       " Use apropiate number of spaces
                                                    " set nowrap                " Wrapping sucks (except on markdown); Now smart
autocmd BufRead,BufNewFile *.md,*.txt setlocal wrap " DO wrap on markdown files set noswapfile
set mouse=a                                         " Enable mouse on all modes
set clipboard=unnamed,unnamedplus                   " Use the OS clipboard
set showmatch
set termguicolors 
" set t_Co=256
set splitright splitbelow
set list lcs=tab:\¦\      "(here is a space)
let &t_SI = "\e[6 q"      " Make cursor a line in insert
let &t_EI = "\e[2 q"      " Make cursor a line in insert

" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv
"
" Move Visual blocks with J an K
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Autocomand to remember las editing position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" let g:everforest_better_performance = 1
" let g:everforest_background = 'soft'
set background=dark
" colo gruvbox8_hard
colorscheme everforest

map <C-k><C-k> :NERDTreeToggle<cr> " Use Ctrl-P to open the fuzzy file opener
nnoremap <C-p> :Files<cr>

"Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Lightlime Setup
" Lighlime Shortcut
nmap <Leader>l :Limelight!!<cr>

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
" let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
" let g:limelight_bop = '^\s'
" let g:limelight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

"CoC 
let g:coc_disable_startup_warning = 1
"Tab Navigation
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
      let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction
                     
"Coc vimlsp Highlighting
let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]


"Goyo Setup
autocmd! User GoyoEnter Limelight       "Call Limelight every time enter Goyo
autocmd! User GoyoLeave Limelight!
nmap <F8> : Goyo<cr>                    " Toggle Goyo

"Airline 
let g:airline_theme = 'everforest'
let g:airline_powerline_fonts = 1

"Smart Indent for Wrapped Lines
set breakindent
set breakindentopt=shift:3,min:40,sbr
set showbreak=...

" This is necessary for VimTeX to load properly. The "indent" is optional.
" Note that most plugin managers will do this automatically.
filetype plugin indent on

" This enables Vim's and neovim's syntax-related features. Without this, some
" VimTeX features will not work (see ":help vimtex-requirements" for more
" info).
syntax enable

" Viewer options: One may configure the viewer either by specifying a built-in
" viewer method:
let g:vimtex_view_method = 'zathura'

" Or with a generic interface:
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_quickfix_autoclose_after_keystrokes = 1
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

" VimTeX uses latexmk as the default compiler backend. If you use it, which is
" strongly recommended, you probably don't need to configure anything. If you
" want another compiler backend, you can change it as follows. The list of
" supported backends and further explanation is provided in the documentation,
" see ":help vimtex-compiler".
let g:vimtex_compiler_method = 'latexmk'

" Most VimTeX mappings rely on localleader and this can be changed with the
" following line. The default is usually fine and is the symbol "\".
let maplocalleader = ","

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
