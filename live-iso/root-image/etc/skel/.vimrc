" by noptrix

" file type and syntax highliting on
filetype plugin indent on
syntax on

" whitespaces
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
autocmd InsertLeave * redraw!
match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd BufWritePre * :%s/\s\+$//e

" color scheme
color leet

" specific settings
set nocursorline
set title
set bs=2
set noautoindent
set ruler
set shortmess=aoOTI
set nocompatible
set showmode
set splitbelow
set laststatus=2
set nomodeline
set showcmd
set showmatch
set tabstop=4
set shiftwidth=4
set expandtab
set cinoptions=(0,m1,:1
set tw=80
set formatoptions=tcqro2
set smartindent
set laststatus=2
set nomodeline
set clipboard=unnamed
set softtabstop=4
set showtabline=1
set smartcase
set sidescroll=5
set scrolloff=4
set hlsearch
set foldmethod=marker
set ttyfast
set history=10000
set hidden
set colorcolumn=81
set number
