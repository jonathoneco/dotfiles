"General Settings
syntax on

set guicursor=
set noshowmatch
set scrolloff=4

set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set relativenumber
set nu
set nowrap
set undodir=~/.vim/undodir
set undofile
set smartcase
set noswapfile

set incsearch
set hlsearch

set splitbelow splitright

set updatetime=50
set shortmess+=c

set termguicolors
set colorcolumn=120
highlight ColorColumn ctermbg=0 guibg=lightgrey

set mouse=a

"Plugins
call plug#begin('~/.config/nvim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'jremmen/vim-ripgrep'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'ctrlpvim/ctrlp.vim' " fuzzy find files

Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lervag/vimtex'
Plug 'rakr/vim-two-firewatch'

call plug#end()

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
set background=dark
let g:two_firewatch_italics=1
colo two-firewatch

let g:airline_theme='twofirewatch'

set showtabline=2

if executable('rg')
    let g:rg_derive_root='true'
endif

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let mapleader = " "

noremap <leader><space> :nohlsearch<CR>

nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

map <leader>f :setlocal formatoptions-=cro<CR>
map <leader>c :setlocal formatoptions=cro<CR>

"map <leader>r :w!<bar> !clang <c-r>%<CR><CR>
"map <leader>e :!./a.out <c-r>%<CR><CR>

inoremap ii <Esc>

let g:netrw_browse_split = 2
let g:netrw_banner = 0
let g:netrw_winsize = 25

let g:ctrlp_use_caching = 0

nnoremap <silent> <leader>h :wincmd h<CR>
nnoremap <silent> <leader>j :wincmd j<CR>
nnoremap <silent> <leader>k :wincmd k<CR>
nnoremap <silent> <leader>l :wincmd l<CR>
nnoremap <silent> <leader>v :vsplit<CR> <space>l
nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader><Tab> :bd<CR>
nnoremap <silent> <leader>q :q<CR>
nnoremap <silent> <leader>wq :wq<CR>
nnoremap <silent> <leader>d :tabnext<CR>
nnoremap <silent> <leader>a :tabprev<CR>
nnoremap <silent> <leader>n :tabnew<CR>
nnoremap <silent> <leader>c :tabclose<CR>

nnoremap gl $
nnoremap gh 0
nnoremap <leader>gk H
nnoremap <leader>gj L
nnoremap gt gg
nnoremap gb G

nnoremap <leader>S :%s//<Left>

nnoremap <leader>pw :Rg <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>phw :h <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>pt :NERDTreeToggle<CR>
nnoremap <silent> <leader>pv :NERDTreeFind<CR>
let g:NERDTreeGitStatusWithFlags = 1

nnoremap <Leader>ps :Rg<SPACE>
"nnoremap <C-p> :Files<CR>
"nnoremap <Leader>pf :GFiles<CR>
nnoremap <silent> <Leader>+ :vertical resize +10<CR>
nnoremap <silent> <Leader>- :vertical resize -10<CR>
nnoremap <Leader>rp :resize 100<CR>
vmap == <plug>NERDCommenterToggle
nmap == <plug>NERDCommenterToggle

nmap <Tab> :bn<CR>
nmap <S-Tab> :bp<CR>

" GoTo code navigation.
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gy <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rr <Plug>(coc-rename)
nmap <leader>g[ <Plug>(coc-diagnostic-prev)
nmap <leader>g] <Plug>(coc-diagnostic-next)
nmap <silent> <leader>gp <Plug>(coc-diagnostic-prev-error)
nmap <silent> <leader>gn <Plug>(coc-diagnostic-next-error)
nnoremap <leader>cr :CocRestart

" Sweet Sweet FuGITive
nmap <leader>gh :diffget //3<CR>
nmap <leader>gu :diffget //2<CR>
nmap <leader>gs :G<CR>

fun! TrimWhitespace()
let l:save = winsaveview()
keeppatterns %s/\s\+$//e
call winrestview(l:save)
endfun

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>ff  <Plug>(coc-fix-current)

autocmd FileType tex nmap  <C-T> :!xelatex %<CR> :!latexmk -c<CR>
autocmd FileType tex nmap  T :!open -a Skim %:r.pdf<CR><CR>
autocmd FileType tex set wrap linebreak
autocmd FileType tex nnoremap j gj
autocmd FileType tex nnoremap k gk
autocmd FileType tex imap <space><space> .<space>

autocmd BufWritePre * :call TrimWhitespace()
command! -nargs=0 Prettier :CocCommand prettier.formatFile

au vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let NERDTreeQuitOnOpen = 1

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
