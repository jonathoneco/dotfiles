"SETTINGS
"Editing
syntax on
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smartcase

"Number Line
set nu
set relativenumber

"Navigation
set mouse=a
set guicursor=
set incsearch
set hlsearch
set splitbelow splitright

"Misc
set scrolloff=4
set hidden
set noerrorbells
set nowrap
set undodir=~/.vim/undodir
set undofile
set noswapfile
set updatetime=50
set shortmess+=c

"Code Folding
set foldmethod=indent
set foldlevel=99

set colorcolumn=120
highlight ColorColumn ctermbg=0 guibg=lightgrey

"Plugins
call plug#begin('~/.config/nvim/plugged')

"Language Shit
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'scrooloose/nerdcommenter'
Plug 'lervag/vimtex'

"Management
Plug 'tpope/vim-fugitive'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'ctrlpvim/ctrlp.vim' " fuzzy find files
Plug 'preservim/tagbar'

"QOL
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'patstockwell/vim-monokai-tasty'
Plug 'jmcantrell/vim-virtualenv'

call plug#end()

"Coloscheme
let g:vim_monokai_tasty_italic = 1
colorscheme vim-monokai-tasty

let g:airline_theme='monokai_tasty'
let g:airline#extensions#bufferline#enabled = 1

"MAPS
let mapleader = " "

"Window
nnoremap <silent> <leader>h :wincmd h<CR>
nnoremap <silent> <leader>j :wincmd j<CR>
nnoremap <silent> <leader>k :wincmd k<CR>
nnoremap <silent> <leader>l :wincmd l<CR>

"Buffer
nmap <Tab> :bn<CR>
nmap <S-Tab> :bp<CR>
nnoremap <silent> <leader>1 :b 1<CR>
nnoremap <silent> <leader>2 :b 2<CR>
nnoremap <silent> <leader>3 :b 3<CR>
nnoremap <silent> <leader>4 :b 4<CR>
nnoremap <silent> <leader>5 :b 5<CR>
nnoremap <silent> <leader>6 :b 6<CR>
nnoremap <silent> <leader>7 :b 7<CR>
nnoremap <silent> <leader>8 :b 8<CR>
nnoremap <silent> <leader>9 :b 9<CR>
nnoremap <silent> <leader>0 :b 10<CR>

"Tab
nnoremap <silent> <leader>d :tabnext<CR>
nnoremap <silent> <leader>a :tabprev<CR>
nnoremap <silent> <leader>n :tabnew<CR>
nnoremap <silent> <leader>c :tabclose<CR>

"Text
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>
nnoremap gl $
nnoremap gh 0
nnoremap <leader>gk H
nnoremap <leader>gj L
nnoremap gt gg
nnoremap gb G

"File
inoremap ii <Esc>
map <leader>f :setlocal formatoptions-=cro<CR>
map <leader>c :setlocal formatoptions=cro<CR>
vmap == <plug>NERDCommenterToggle
nmap == <plug>NERDCommenterToggle
noremap <leader><space> :nohlsearch<CR>
nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader>w<Tab> :wbd<CR>
nnoremap <silent> <leader><Tab> :bd<CR>
nnoremap <silent> <leader>q :q<CR>
nnoremap <silent> <leader>wq :wq<CR>
nnoremap <silent> <leader>v :vsplit<CR> <space>l
nnoremap <silent> <Leader>+ :vertical resize +10<CR>
nnoremap <silent> <Leader>- :vertical resize -10<CR>
nnoremap <Leader>rp :resize 100<CR>
nnoremap <leader>S :%s//<Left>
nnoremap <leader>u :UndotreeShow<CR>

"Directory
nnoremap <leader>pw :Rg <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>phw :h <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>pt :NERDTreeToggle<CR>
nnoremap <silent> <leader>pv :NERDTreeFind<CR>
let g:NERDTreeGitStatusWithFlags = 1
nnoremap <Leader>ps :Rg<SPACE>

"GoTo code navigation.
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

"FuGITive
nmap <leader>gh :diffget //3<CR>
nmap <leader>gu :diffget //2<CR>
nmap <leader>gs :G<CR>

"NerdTree
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let NERDTreeQuitOnOpen = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
au vimenter * if !argc() | NERDTree | endif

"Coc
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
autocmd BufWritePre * :call TrimWhitespace()
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>ff  <Plug>(coc-fix-current)

"MISC
map <leader>t :TagbarToggle<CR>

if executable('rg')
    let g:rg_derive_root='true'
endif

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

let g:netrw_browse_split = 2
let g:netrw_banner = 0
let g:netrw_winsize = 25

let g:ctrlp_use_caching = 0

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

"LATEX
let g:tex_flavor = 'latex'
autocmd FileType tex nmap  <C-T> :!xelatex %<CR> :!latexmk -c<CR>
autocmd FileType tex nmap  T :!open -a Skim %:r.pdf<CR><CR>
autocmd FileType tex set wrap linebreak
autocmd FileType tex nnoremap j gj
autocmd FileType tex nnoremap k gk
autocmd FileType tex imap <space><space> .<space>


