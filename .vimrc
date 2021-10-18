call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
Plug 'rafalbromirski/vim-aurora'
Plug 'jiangmiao/auto-pairs'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'vim-airline/vim-airline'
Plug 'nlknguyen/papercolor-theme'
Plug 'ewilazarus/preto'
Plug 'scrooloose/nerdtree'
Plug 'vimsence/vimsence'
call plug#end()

cd ~/Desktop/Code

inoremap jk <ESC>
set shiftwidth=4
set expandtab
set relativenumber
set cindent
set tabstop=2
set clipboard=unnamed
syntax on

noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
:autocmd BufNewFile *.cpp 0r ~/.vim/templates/skeleton.cpp 
:autocmd BufNewFile *.c 0r ~/.vim/templates/skeleton.c
autocmd filetype cpp nnoremap <F9> :w <bar> !g++ -std=c++17 -O2 -Wall -Wshadow -Wextra % -o %:r<CR>
autocmd filetype cpp nnoremap <F10> :!%:r<CR>
autocmd filetype c nnoremap<F9> :w <bar> !gcc % -o %:r && ./%:r <CR>
set termguicolors
set background=dark
colorscheme yin

nnoremap <C-n> :NERDTreeToggle<CR>
vnoremap <C-c> "+y
nnoremap <C-a> ggvG
map <C-v> "+pap <C-v> "+p
