set number
set expandtab
set smartindent
set autoindent
set tabstop=2
set shiftwidth=2
set t_Co=256
syntax on

set nocompatible
filetype off

filetype plugin indent on

if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
  set termguicolors
endif

let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }

let g:airline_powerline_fonts = 1

let $FZF_DEFAULT_COMMAND='fd --type f'

" Better search
set incsearch
set ignorecase
set smartcase
set gdefault

" Relative lines
set number relativenumber

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

set background=dark
colorscheme base16-ocean

let mapleader = ','

" Permanent undo
set undodir=~/.vimdid
set undofile

" CtrlP mappings
nnoremap <SPACE><SPACE> :FZF<CR>
nnoremap <SPACE>b :Buffers<CR>

" NERDTree mappings
nnoremap <SPACE>f :ex .<CR>

" Vim-fugitive mappings
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>ga :Gcommit -a<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gl :Glog<CR>
nnoremap <Leader>gps :Gpush<CR>
nnoremap <Leader>gpl :Gpull<CR>

" Buffer mappings
nnoremap <Leader>n :bnext<CR>
nnoremap <Leader>p :bprev<CR>

nnoremap <Leader>l :nohl<CR>

" Split mappings
nnoremap <Leader>= <C-W>=

