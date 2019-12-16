set nocp                          " disable compatibility mode - keep @ top!  
syntax on                         " just turn this on already 
let mapleader=","                 " better than the use of the \

set ruler                         " show line # info, etc.
"set hidden                       
set encoding=utf-8

set textwidth=80                  " where to wrap
set shm=at                        " short message
set formatoptions=tcqrt2          " XXX - document this better
" set wrap
" set linebreak
" set wrapwidth=80

" UI element configuration 
set cmdheight=2                     " command line two lines high
set laststatus=2

set comments=b:#,:%,n:>,fb:[-],fb:- " see, help: comments
set viminfo=%,'50,\"100,:100,n~/.viminfo
set colorcolumn=90

set foldmethod=syntax      " fold on syntax, always
set foldcolumn=0           " 2 lines of column for fold showing, always
set foldlevelstart=3       " expand folds at start

set wildmode=longest:full
set wildignore+=*.o,*~,.lo " ignore object files
set wildmenu               " menu has tab completion

set visualbell             " disable the beep
set autoread               " if a file changes externally, update buffer

" address the tabs-vs-spaces debate ...
set softtabstop=2
set shiftwidth=2
set expandtab 
set smarttab                  

set autoindent 
"set smartindent

" make the copy/paste operation seamless w/the OS
set clipboard=unnamed

set showmode
set showcmd

set updatetime=100     " sets the update time to 100ms
set ttimeout
set ttimeoutlen=100

" per file type specifications
" this triggers the right defaults in programming lang modes
filetype on
filetype indent on
filetype plugin on
syntax enable

" notational velocity for vim
let g:nv_search_paths = ['~/.notes/deft']

" ghost-vim config elements
" let g:ghost_text_log_file = "~/tmp/ghost_log.txt"

" mode specific overrides - 
autocmd BufNewFile,BufRead mutt-* set syntax=mail spell tw=78 fo+=2n ai
autocmd BufNewFile,BufRead *.txt,*.tex 
 \ set wrap linebreak nolist textwidth=0 wrapmargin=0

" open markdown files in marked2
nnoremap <leader>m :silent !open -a Marked\ 2.app '%:p'<cr>

" nerdtree
map <F2> :NERDTreeToggle<CR>  

" map to something other than escape
inoremap <C-[> <Esc>

" trigger configuration. do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-tab>"
let g:UltiSnipsJumpForwardTrigger="<M-j>"
let g:UltiSnipsJumpBackwardTrigger="<M-k>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "custom-snippets"]


" search options
" ---------------------------------------------------------------------------
set incsearch                 " incremental search
set ignorecase                " search ignoring case
set smartcase                 " search w/a capital is case-sensitive
set hlsearch                  " highlight the search
set showmatch                 " show matching bracket
set diffopt=filler,iwhite     " ignore all whitespace and sync
nnoremap <leader><space> :noh<cr>


" abbreviations
ab seea  see attached ...
ab ssig  { snipped - misc .signatures }
ab sprev { snipped - misc previous correspondence }
ab x70- ----------------------------------------------------------------------
ab x70= ======================================================================
ab ccf comments / corrections / flames appreciated

" autoclose options
map <leader>ac :AutoCloseToggle<cr>


" spell check options. 
" note: use 'zg' to add the current word to the dictionary
"---------------------------------------------------------------------
set spelllang=en_us
" personal word list
set spellfile = "~/Dropbox/personal/config/en.utf-8.add"

set spellcapcheck=""                " ignore capitalization 
nnoremap <silent><leader>s :set spell!<cr>
nnoremap <silent><leader>S ea<C-X><C-S>
nnoremap <silent><leader>r 1z=      " replace current word with the first suggestion


" protect changes between writes. default values of
" updatecount (200 keystrokes) and updatetime
" (4 seconds) are fine
set swapfile
set directory^=~/.vim/swap//

" protect against crash-during-write
set writebackup
" but do not persist backup after successful write
set nobackup
" use rename-and-write-new method whenever safe
set backupcopy=auto
set backupdir^=~/.vim/backup//

" persist the undo tree for each file
set undofile
set undodir^=~/.vim/undo//


" dash options. 
"---------------------------------------------------------------------
nmap <silent><leader>d <Plug>DashSearch

" deal with window splits appropriately
set splitbelow
set splitright

" the following elements make solarized happy
set termguicolors 
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set background=dark
colorscheme solarized8
 

" do the needful for the statusline
let g:airline_enable_branch = 1
let g:airline_powerline_fonts = 1        " requires powerline fonts
let g:airline#extensions#ale#enabled = 1 " show ale errors on statusline
" let g:airline_theme='minimalist'
let g:airline_extensions = [ "ale", "branch", "netrw", "tabline", "virtualenv"  ]
" this following 2 lines need to be enabled together. 
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'

nmap <silent> <C-j> :ALEPrevious<cr>
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-k> :ALENext<cr>
" nmap <silent> <C-j> <Plug>(ale_next_wrap)

set runtimepath+=~/.vim/pack/default/start/vim-ultisnips
