" Be SO nocompatible.
set nocompatible

" Tru Colors (the truest).
set termguicolors

" dein is Shougo's \"asynchronous dark-powered plugin manager\"
" Let's have plugins.
source ~/.config/nvim/setup-dein.vim
source ~/.config/nvim/plugins.vim
" THIS HAS TO COME AFTER PLUGINS.
call dein#end()

" Set <Leader>
let mapleader = ' '
let maplocalleader = '_' " What is local leader?

" Deoplete configuration
" Tell deoplete to run on startup and be case-sensitive when using caps.
let g:deoplete#enable_at_startup=1
let g:deoplete#enable_smart_case=1
" Complete files from the CWD of the current file, not of the project.
let g:deoplete#file#enable_buffer_path=1
" Don't show the preview window during completions.
set completeopt-=preview

" Press (<Shift>)<Tab> to cycle through completions.
inoremap <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Press <C-j> <C-k> to move between completions.
inoremap <silent><expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <silent><expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" Look, let's be reasonable. Don't go too fast, but don't be so damn slow.
set updatetime=750

" Map Ctrl+P in Normal Mode to FZF gitfiles.
nnoremap <C-p> :GFiles<CR>

" Things like textwidth, wrapping, shiftwidth, ...
syntax on                 " Yes, syntax highlighting.
filetype plugin indent on " Yes, filetype detection, indentation, etc.
set mouse=a               " Yes, enable mouse in all four modes.
scriptencoding utf-8      " Use UTF-8!

set tw=74           " Column width: 74 characters.
set wrap            " Force hard-wrap lines after 74 characters.
set colorcolumn=+1  " Light up the column +1 after TextWidth.
set sw=2 ts=2 sts=2 " ShiftWidth = Tabstop = SoftTabstop = 2.
set expandtab       " Expand tabs into spaces.
set autoindent      " Indent automatically.
set smartindent     " Better auto-indent new code blocks.

set autochdir    " Be more directory.
set autowrite    " Write file when you leave a buffer.
set history=5000 " Store bunches of history.
set nospell      " No spellchecking!
set hidden       " Don't unload a buffer when leaving, just hide it.

set undofile         " Plz keep
set undolevels=5000  " A lot of
set undoreload=10000 " Undo history!

set number     " Show line numbers!
set ignorecase " Case-insensitive search.
set smartcase  " Case sensitive when part of the term is uppercase.

set scrolloff=1 " Keep 1 line of paddding above and below the cursor.
set list        " Display invisible characters given in listchars.
 " Highlights problematic whitespace: tabs, trailing characters, etc.
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Wildmenu is the completion menu you get when in command mode.
" Test using <esc>:color <tab> to see the menu.
set wildmenu                    " Show a list instead of just completing.
set wildmode=list:longest,full  " View mode: show a big list for wildmenu.

" This has something to do with vim messages? I think?
" It has to do with status messages. See:
" http://vimdoc.sourceforge.net/htmldoc/options.html#'shortmess'
set shortmess+=filmnrxoOtT

" Automatically change window local directory to the working directory
" when you edit a file.
" NOTE(jordan): replaced by autochdir?
" autocmd BufEnter * if bufname("") !~ "^\[A-Za-z-0-9]*://" | lcd %:p:h

" NOTE(jordan): smartindent isn't perfect. Old attempts to improve it:
" inoremap {<CR> <ESC>"xDa{<CR>}<ESC>O<C-r>x
" inoremap {<CR> {<CR>}<ESC>O

" Sets the cursor to first col when you open a new commit message.
autocmd FileType gitcommit
  \ autocmd! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

set autoindent   " Keep the indentation of the previous line.
set nojoinspaces " When joining lines: compress spaces into 1.
set splitright   " Vsplits go right.
set splitbelow   " Hsplits go below.

" Stolen wholesale from spf13's .vimrc. Does what it says.
function! StripTrailingWhitespace()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  %s/\s\+$//e
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

autocmd BufWritePre <buffer> call StripTrailingWhitespace()

" Wrapped lines goes down/up to next row, rather than next line in file.
noremap j gj
noremap k gk

" Fix accidental shiftkey presses.
command! -bang -nargs=* -complete=file E e<bang> <args>
command! -bang -nargs=* -complete=file W w<bang> <args>
command! -bang -nargs=* -complete=file Wq wq<bang> <args>
command! -bang -nargs=* -complete=file WQ wq<bang> <args>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>

" Find merge conflict markers. (Need to remember to use this!)
map <leader>gc /\v^[<\|=>]{7}( .*\|$)<CR>

" Visual shifting (does not exit Visual mode, much better).
vnoremap < <gv
vnoremap > >gv

" Not sure why I care about this?
" Answer: Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Colors.
source ~/.config/nvim/airline/themes/twofirewatch.vim
let g:two_firewatch_italics=1
let g:airline_theme='twofirewatch'
color two-firewatch
set bg=dark

" These `hi` commands MUST come after `color` is set! They overwrite some
" of the behavior of twofirewatch.

" Make search higlighting better by underlining matches.
" NOTE: this is specific to twofirewatch. Colors are taken from the theme.
hi Search guibg='FAF8F5' guifg='896724' gui=underline
" Make parens match in a way that's less confusing.
hi MatchParen gui=reverse

" Prettier Airline.
let g:Powerline_symbols='fancy'
let g:airline_powerline_fonts=1

" Neomake configuration.
" Open location list when make has errors, but don't move the cursor.
let g:neomake_open_list=2

function! JsLocalMappings ()
  call JsTsLocalMappings()
  " tern_for_vim bindings
  nnoremap <silent> K :TernType<CR>
  nnoremap <silent> gd :TernDef<CR>
endfunction

function! TsLocalMappings ()
  call JsTsLocalMappings()
endfunction

function! JsTsLocalMappings ()
  " remap ' to ` to encourage using template strings, just hit 2x to escape
  inoremap <buffer> ' `
  inoremap <buffer> '' '
  " map K to something reasonable
  nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
endfunction

augroup javascript
  autocmd!
  autocmd FileType javascript call JsLocalMappings()
augroup END

augroup typescript
  autocmd!
  autocmd FileType typescript call TsLocalMappings()
augroup END

" Can we create a GitAg like GitFiles using FZF? I think so.
" See https://github.com/junegunn/fzf.vim/issues/321 ! I asked Junegunn
" and he gave me this.
command! -bang -nargs=* GitAg call fzf#vim#ag(<q-args>, {
    \ 'dir': systemlist('git rev-parse --show-toplevel')[0]
  \ }, <bang>0)

" Run GitAg with word-under-cursor when I hit C-k.
nmap <C-k> "zyiw:exe "GitAg " . @z . ""<CR>

au Syntax * call matchadd('Todo', '\W\zs\IDEA')
au Syntax * call matchadd('Todo', '\W\zs\NOTE')
au Syntax * call matchadd('Todo', '\W\zs\TODO')
au Syntax * call matchadd('Todo', '\W\zs\FIXME')
au Syntax * call matchadd('Todo', '\W\zs\FAILING')
au Syntax * call matchadd('Todo', '\W\zs\OPTIMIZE')
au Syntax * call matchadd('Todo', '\W\zs\QUESTION')
au Syntax * call matchadd('Todo', '\W\zs\REFACTOR')
au Syntax * call matchadd('Todo', '\W\zs\DEPRECATED')

" Show me what I am doing
set showcmd

" Use <CR>/<BS> to go down 30 / up 30
map <CR> 30gj
map <BS> 30gk
