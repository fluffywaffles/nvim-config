" Be SO nocompatible.
set nocompatible

" Tru Colors (the truest).
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

" dein is the name of the "asynchronous dark-powered plugin manager" by Shuogo.
" Let's have plugins.
source ~/.config/nvim/setup-dein.vim
source ~/.config/nvim/plugins.vim
" THIS HAS TO COME AFTER PLUGINS.
call dein#end()

" Set <Leader>
let mapleader = ','
let maplocalleader = '_' " How is this different? I don't think I need this line.

" Tell deoplete to work on startup and to be case-sensitive when using caps.
let g:deoplete#enable_at_startup=1
let g:deoplete#enable_smart_case=1
set completeopt-=preview " Don't open that weird little pane/window at the bottom of the screen.
" Complete files from the CWD of the current file, not of the project.
" DISABLE because behavior is not as expected.
" let g:deoplete#file#enable_buffer_path=1

" Press <Tab> to cycle between completions when completions are available.
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<tab>"
" Press <C-j> <C-k> to move between completions.
inoremap <silent><expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <silent><expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
" Press <CR> (enter) to trigger completion selection.
inoremap <silent> <CR> <C-r>=<SID>select_completion_on_cr()<CR>
function! s:select_completion_on_cr() abort
  return deoplete#close_popup() . "\<CR>"
endfunction

" Map Ctrl+P in Normal Mode to FZF gitfiles.
nnoremap <C-p> :GFiles<CR>

" Things like textwidth, wrapping, shiftwidth, ...
syntax on                 " Yes, syntax highlighting.
filetype plugin indent on " Yes, filetype detection, automatic indentation, etc.
set mouse=a               " I don't know what this does.
set mousehide             " Or this.
scriptencoding utf-8      " Use UTF-8!

set tw=100 wrap nolist    " TextWidth: 100 chars. Wrap lines. No "list" - no line break.
set colorcolumn=+1        " Light up the column +1 after TextWidth.
set sw=2 ts=2 sts=2 et    " ShiftWidth = Tabstop = SoftTabstop = 2. Expand tabs to spaces.
set autoindent            " Indent automatically.

" Save folds to disk!
augroup AutoSaveFolds
  autocmd!
  autocmd BufWinLeave *.* mkview
  autocmd BufWinEnter *.* silent! loadview
augroup END

" Simple clipboard setup because nvim has good defaults.
" Set system (X win) clipboard to be default clipboard.
" http://vim.wikia.com/wiki/Accessing_the_system_clipboard#Using_the_clipboard_as_the_default_register
set clipboard+=unnamedplus

" Automatically change window local director to the working directory when you edit a file.
autocmd BufEnter * if bufname("") !~ "^\[A-Za-z-0-9]*://" | lcd %:p:h

" Write file when you leave a buffer.
set autowrite
" This has something to do with vim messages? I think?
" It has to do with status messages. See:
" http://vimdoc.sourceforge.net/htmldoc/options.html#'shortmess'
set shortmess+=filmnrxoOtT
" Apparently adds a "virtual" character to every line... hm.
" set virtualedit=onemore
" Store bunches of history.
set history=5000
" No spellchecking!!!
set nospell
" Hide buffers so you can switch w/o save.
set hidden
" Set some "end of word" designators to make navigation easier.
set iskeyword-=.
set iskeyword-=#
set iskeyword-=-

" Sets the cursor to first col when you open a new commit message.
autocmd FileType gitcommit autocmd! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Restore cursor to previous file position when re-entering a file.
" Is this slow? Might slow down vim start time.
function! ResumeCursorPosition()
  if line("'\"") <= line("$")
    silent! normal! g`"
    return 1
  endif
endfunction

augroup resumeCursorPosition
  autocmd!
  autocmd BufWinEnter * call ResumeCursorPosition()
augroup END

" Tell vim to automagically keep backups of files.
" set backup " Takes a bunch of disk space and sometimes slows down vim startup.

" Plz persist undo history!
set undofile
set undolevels=5000
set undoreload=10000

set number     " Show line numbers!
set ignorecase " Case-insensitive search.
set smartcase  " Case sensitive when part of the term is uppercase.
" Wildmenu is the menu you get when in command mode. Test using <esc>:color <tab> to see the menu.
set wildmenu                                   " Show a list instead of just completing commands.
set wildmode=list:longest,full                 " View mode: show a big list for wildmenu.
set scrolloff=1                                " Keep a number of lines above and below the cursor at all times.
set list                                       " Display invisible characters using the below rules.
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace.

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
map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

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
colors two-firewatch
set bg=dark

" Make search higlighting better. Keep default bg/fg and underline instead of whatever.
" NOTE: this is specific to twofirewatch. Colors are taken from the theme.
hi Search guibg='FAF8F5' guifg='896724' gui=underline

" Make parens match in a way that's less confusing.
" This MUST come after the `colors` set, or it gets overwritten.
hi MatchParen gui=reverse

" Prettier Airline.
let g:Powerline_symbols='fancy'
let g:airline_powerline_fonts=1

" Neomake configuration.
" Open location list when make has errors, but don't move the cursor.
let g:neomake_open_list=2
nnoremap <Leader>. :lnext <CR>
nnoremap <Leader>m :lprev <CR>
nnoremap <Leader>x :lclose <CR>

" Neomake configuration for TypeScript.
" Tell tsc where to look for tsconfig!
function! SetupNeomakeTSC()
  let g:neomake_typescript_tsc_maker = neomake#makers#ft#typescript#tsc()

  " If there's a tsconfig here, just use that.
  silent let can_init = system('tsc --init')
  " Use the TS error code for "tsconfig.json already exists"
  if can_init =~ "error TS5054"
    " It seems there was a tsconfig! Don't manually look elsewhere.
    " `silent!` means try to unlet and don't complain no matter what.
    silent! unlet g:neomake_typescript_tsc_maker
    return
  else
    " Remove our dummy tsconfig
    silent let rm = system('rm ./tsconfig.json')
    " Try looking in the top-level 'config' folder of the repo.
    silent let git_project_dir = systemlist('git rev-parse --show-toplevel')[0]
    silent let find_tsconfig = system('test -e ' . git_project_dir . '/config/tsconfig.json')
    if v:shell_error == 0
      let g:neomake_typescript_tsc_maker.args = [ '-p', git_project_dir.'/config', '--noEmit', '--pretty', 'false' ]
      return
    endif
    " That failed - try looking in the 'config' folder of the nearest parent (depth <=5) having a
    " package.json file in it.
    for depth in [ 1, 2, 3, 4, 5 ]
      let dots = repeat('..', depth)
      silent let find_tsconfig = system('test -e '.dots.'/config/tsconfig.json')
      if v:shell_error == 0
        silent let real_path = systemlist('realpath '.dots.'/config')[0]
        let g:neomake_typescript_tsc_maker.args = [ '--project', real_path, '--noEmit', '--pretty', 'false' ]
        return
      endif
    endfor
  endif
endfunction

augroup typescript
  autocmd!
  autocmd FileType typescript call SetupNeomakeTSC()
  autocmd BufEnter *.ts call SetupNeomakeTSC()
  autocmd FileType typescript :TSStart
augroup END

" Can we create a GitAg like GitFiles using FZF? I think so.
" See https://github.com/junegunn/fzf.vim/issues/321 ! I asked Junegunn and he gave me this.
command! -bang -nargs=* GitAg call fzf#vim#ag(<q-args>, {
    \ 'dir': systemlist('git rev-parse --show-toplevel')[0]
  \ }, <bang>0)

" Let's make a mapping that runs GitAg with word-under-cursor when I hit C-k.
nmap <C-k> "zyiw:exe "GitAg " . @z . ""<CR>

