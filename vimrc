" vimrc configuration converted from neovim lua files
" this provides similar functionality without any additional plugins

" basic settings
set nocompatible
filetype plugin indent on
syntax on

" leader key configuration
let mapleader = " "
let maplocalleader = "\\"

" interface elements
set termguicolors          " enable 24-bit color
set background=dark        " dark background (auto not available in standard vim)

set encoding=utf-8         " self-explanatory
set textwidth=80           " where to wrap
set shortmess=at           " abbreviate and truncate file messages
set showmatch              " briefly flash to the matching element
set visualbell             " disable the beep
set autoread               " if a file changes externally, update buffer

" address the tabs-vs-spaces debate ...
set softtabstop=2
set shiftwidth=2
set tabstop=2
set expandtab

" interface configuration
set cmdheight=2            " command line two lines high
set laststatus=2
set ruler                  " show line # info, etc.
set showmode               " show the mode in the status line
set showcmd                " show selection info

set wildmode=longest:full
set wildignore=*.o,*~,.lo  " ignore object files
set wildmenu               " menu has tab completion

" make the copy/paste operation seamless w/the OS
set clipboard=unnamed

" delay before swap is written to the disk (100ms)
set updatetime=100
set ttimeout
set ttimeoutlen=100

" split preferences
set splitbelow
set splitright

" search settings
set incsearch              " incremental search
set ignorecase             " search ignoring case
set smartcase              " search w/a capital is case-sensitive
set hlsearch               " highlight the search

" misc. vim support files and settings: swap, backup, etc.
set swapfile
set directory=$HOME/.vim/swap//
set nowritebackup          " set for coc integration
set nobackup               " but do not persist backup after successful write
set backupcopy=auto        " use rename-and-write-new method whenever safe
set backupdir=$HOME/.vim/backup//
set undofile               " persist the undo tree for each file
set undodir=$HOME/.vim/undo//

" spell check configuration
set spelllang=en_us
set spellcapcheck=""       " ignore capitalization

" diff settings
set diffopt=filler,iwhite  " ignore all whitespace and sync

" filetype: markdown
let g:markdown_folding = 1
let g:markdown_fenced_languages = ['html', 'python', 'javascript', 'bash=sh', 'shell=sh']

" disable json quote concealing
let g:vim_json_conceal=0

" create directories if they don't exist
if !isdirectory($HOME."/.vim/swap")
  call mkdir($HOME."/.vim/swap", "p", 0700)
endif
if !isdirectory($HOME."/.vim/backup")
  call mkdir($HOME."/.vim/backup", "p", 0700)
endif
if !isdirectory($HOME."/.vim/undo")
  call mkdir($HOME."/.vim/undo", "p", 0700)
endif

" keybindings
" --------------------------------------------------------------------

" escape with kj
inoremap kj <Esc>

" trim trailing whitespace
nnoremap <leader>w :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" spell check mappings
" note: use 'zg' to add the current word to the dictionary
" use z= to get a list of the possible spelling suggestions
" --------------------------------------------------------------------
" spell check the buffer
nnoremap <leader>s :set spell!<cr>
nnoremap <leader>S ea<C-X><C-S>
" replace the current word with the 1st suggestion
nnoremap <leader>r 1z=
inoremap <C-;> <Esc>[s1z=`]a

" clear search highlights
nnoremap <leader><space> :nohlsearch<cr>

" open markdown files in marked2 (mac specific)
nnoremap <leader>m :!open -a 'Marked 2.app' "%:p"<cr>

" search for the visual selection with //
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" terminal stuff (limited support in standard vim)
nnoremap <leader>t :terminal<CR>
nnoremap <leader>j :botright new \| resize 10 \| terminal<CR>

" allow clipboard copy paste in vim (mac specific)
map <D-v> "+p<CR>
map! <D-v> <C-R>+

" window resizing
nnoremap <leader><left> :vertical resize +20<cr>
nnoremap <leader><right> :vertical resize -20<cr>
nnoremap <leader><up> :resize +10<cr>
nnoremap <leader><down> :resize -10<cr>

" editorconfig compatibility with git
autocmd FileType gitcommit let b:EditorConfig_disable = 1

" custom statusline
set statusline=%f\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)

" basic lsp-like functionality using built-in vim features
" this is a simple approximation of some of the lsp bindings
nnoremap gd :tag <c-r><c-w><cr>
nnoremap K :help <c-r><c-w><cr>
nnoremap <leader>f :!prettier --write %<cr>:e<cr>

" enable filetype settings
filetype plugin indent on
syntax enable

" make sure directories exist
silent !mkdir -p ~/.vim/undo ~/.vim/backup ~/.vim/swap
