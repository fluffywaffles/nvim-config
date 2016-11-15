syntax on
filetype plugin indent on
set mouse=a
set mousehide
scriptencoding utf-8

set tw=100 wrap nolist
set autoindent sw=2 ts=2 sts=2 et

" Simple clipboard setup because nvim has good defaults.
set clipboard+=unnamedplus

" Automatically change to the working directory.
autocmd BufEnter * if bufname("") !~ "^\[A-Za-z-0-9]*://" | lcd %:p:h

" Write file when you leave a buffer.
set autowrite
set shortmess+=filmnrxoOtT
" Apparently adds a "virtual" character to every line... hm.
set virtualedit=onemore
" Store bunches of history.
set history=5000
" No spellchecking!!!
set nospell
" Hide buffers so you can switch w/o save.
set hidden
" Set some "end of word" designators to make navigation easier.
set iskeyword-=.
set iskeyword-=# " Maybe I don't want this one? Or just in Cpp files?
set iskeyword-=- " Not sure I want this one, either.

" Sets the cursor to first col when you open a new commit message.
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Restore cursor to previous file position when re-entering a file.
"function! ResumeCursorPosition()
"  if line("\") <= line("$")
"    silent! normal! g`"
"    return 1
"  endif
"endfunction
"
"augroup resumeCursorPosition
"  autocmd!
"  autocmd BufWinEnter * call ResumeCursorPosition()
"augroup END

" Tell vim to automagically keep backups of files.
" set backup

" Plz persist undo history!
if has('persistent_undo')
  set undofile
  set undolevels=5000
  set undoreload=10000
endif

" set showmode " Display the current mode? I don't think I need this to be explicit here.
" These appear to have to do with vim's weird default line stylings. Neovim doesn't need these.
" highlight clear SignColumn
" highlight clear LineNr

" What is this? I don't really know.
" Stolen wholesale from spf13 .vimrc.
if has('cmdline_info')
  set ruler
  set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
  set showcmd
endif

set number " Show line numbers!
set ignorecase " Case-insensitive search.
set smartcase " Case sensitive when part of the term is uppercase.
set wildmenu " Show a list instead of just completing ... ? What does that mean?
set wildmode=list:longest,full " Competion mode for the wildmenu thing.
set scrolloff=1 " Keep a number of lines above and below the cursor at all times.
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

set autoindent
set nojoinspaces " Keep the line above's indentation by default.
set splitright   " Vsplits go right.
set splitbelow   " Hsplits go below.

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

let mapleader = ','
let maplocalleader = '_' " How is this different?

" Easier window movement.
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

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

" By default, ,/ will search and then clear the highlight.
nmap <silent> <leader>/ :nohlsearch<CR>

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Not sure why I care about this?
" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Not sure what this does.
" Some helpers to edit mode
" http://vimcasts.org/e/14
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%
