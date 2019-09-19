" Be SO nocompatible.
set nocompatible

" Tru Colors (the truest).
set termguicolors

" dein is Shougo's "asynchronous dark-powered plugin manager"
" Let's have plugins.
source ~/.config/nvim/setup-dein.vim
source ~/.config/nvim/plugins.vim
" THIS HAS TO COME AFTER PLUGINS.
call dein#end()

" Set <Leader>
let mapleader      = ' '
let maplocalleader = '_' " <LocalLeader> is for buffer-local mappings.

let g:python3_host_prog = '/usr/sbin/python' " Tell vim where python3 is.

" Plugin mappings
nmap   <Leader>gg :GitGutterToggle<CR>
noremap<Leader>t  :Tabularize/

" Deoplete configuration
" Tell deoplete to run on startup and be case-sensitive when using caps.
let g:deoplete#enable_at_startup=1
let g:deoplete#enable_smart_case=1
" Complete files from the CWD of the current file, not of the project.
" call deoplete#custom#option('refresh_always', v:false)
" call deoplete#custom#option('auto_refresh_delay', 5)
call deoplete#custom#source('file', 'enable_buffer_path', 1)
call deoplete#custom#option('prev_completion_mode', 'filter')
call deoplete#custom#option('auto_complete_delay', 200)
call deoplete#custom#option('num_processes', 3) " 0 = unlimited.
call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
" When completion is done, close the preview window.
autocmd CompleteDone * silent! pclose!

" NOTE: enable debugging sources in deoplete.
" call deoplete#custom#option('profile', v:true)
" call deoplete#enable_logging('DEBUG', 'deoplete.log')
" call deoplete#custom#source('jedi', 'is_debug_enabled', 1)

" Press (<Shift>)<Tab> to cycle through completions.
inoremap <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Look, let's be reasonable. Don't go too fast, but don't be so damn slow.
set updatetime=100

" Don't redraw during macro execution, register stuff, etc. Faster, vim!
set lazyredraw

" Map Ctrl+P in Normal Mode to FZF gitfiles.
nnoremap <C-p> :GFiles<CR>

" Show the outcome of :s in realtime before committing
set inccommand=split

" Things like textwidth, wrapping, shiftwidth, ...
syntax on                 " Yes, syntax highlighting.
filetype plugin indent on " Yes, filetype detection, indentation, etc.
set mouse=a               " Yes, enable mouse in all four modes.
scriptencoding utf-8      " Use UTF-8!
set formatoptions+=t      " Yes, auto-wrap text while typing.

set tw=74           " Column width: 74 characters.
set wrap            " Force hard-wrap lines after 74 characters.
set linebreak       " Force wrapping line-breaks on word boundaries.
set colorcolumn=+1  " Light up the column +1 after TextWidth.
set sw=2 ts=2 sts=2 " ShiftWidth = Tabstop = SoftTabstop = 2.
set expandtab       " Expand tabs into spaces.
set autoindent      " Indent automatically.
set smartindent     " Better auto-indent new code blocks.
set cursorline      " Highlights the line the cursor is on. Pretty.
set signcolumn=yes  " Always show the signcolumn. Reduces jitter.

" From :h 'smartindent': “If you don't want # to unindent, use this.”
inoremap # X#
" cindent is dumb as hell. Extra-definitely disable it, with prejudice.
autocmd FileType c   set nocindent
autocmd FileType cpp set nocindent

set autochdir    " Be more directory.
set autowrite    " Write file when you leave a buffer.
set history=1000 " Store bunches of history.
set nospell      " No spellchecking!
set hidden       " Don't unload a buffer when leaving, just hide it.

set clipboard+=unnamedplus " Always put things in '*' and '+'.

set undofile         " Plz keep
set undolevels=500   " A lot of
set undoreload=1000  " Undo history!

set nonumber   " Don't line numbers!
set ignorecase " Case-insensitive search.
set smartcase  " Case sensitive when part of the term is uppercase.

map <Leader>n :set number!<CR>

set scrolloff=1 " Keep 1 line of paddding above and below the cursor.
set list        " Display invisible characters given in listchars.
" Highlights problematic whitespace: tabs, trailing characters, etc.
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Wildmenu is the completion menu you get when in command mode.
" Test using <esc>:color <tab> to see the menu.
set wildmenu                    " Show a list instead of just completing.
set wildmode=list:longest,full  " View mode: show a big list for wildmenu.

" This has to do with status messages. See :h 'shortmess' for details.
set shortmess+=aoOtT

" Adapted from ":help [["
" To use ]] and [[ as: "go to next/previous section open/close"
map ]] /\%({\\|}\)<CR>
map [[ ?\%({\\|}\)<CR>

" Add the git root to vim's file path if in a git repo
function! AddGitRootToPath()
  let l:git_root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error
    return
  endif
  if stridx(&path, l:git_root . ',') == -1
    exe "setlocal path=" . l:git_root . ',' . &path
  endif
endfunction

" Add subfolders to vim's file path if in a git repo
function! AddGitRootSubfoldersToPath()
  let l:git_root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error
    return
  endif
  let l:git_root_listing = systemlist('ls -d ' . l:git_root . '/*')
  if v:shell_error
    return
  endif
  let l:path_update = ''
  for item in l:git_root_listing
    if isdirectory(item) && stridx(&path, item . ',') == -1
      let l:path_update .= item . ','
    endif
  endfor
  if strlen(l:path_update) > 0
    exe "setlocal path=" . l:path_update . ',' . &path
  endif
endfunction

augroup AddRootsToPath
  autocmd!
  autocmd BufEnter */dev/better/* call AddGitRootToPath()
  autocmd BufEnter */dev/better/* call AddGitRootSubfoldersToPath()
augroup END

" Retaining output in a world with updatetime=small
function! Retain(command)
  redir => b:retained_output
  exe a:command
endfunction
function! Retrieve()
  redir END
  call confirm(b:retained_output)
endfunction
" You can't increase updatetime, because plugins break
" You can't expect plugin authors to use `echom` because plugins suck
" The only recourse is to hack your way around it.
function! CharacterizeRetain()
  " NOTE(jordan): this is wonky; special keys have to be string + escape.
  call Retain("normal \<Plug>(characterize)")
  " NOTE(jordan): characterize is synchronous, we can Retrieve right away
  call Retrieve()
endfunction
" NOTE(jordan): must use autocmd in order to overwrite plugin...
" NOTE(jordan): could also use `after/` directory, but seems less obvious.
autocmd VimEnter *.* nmap ga :call CharacterizeRetain()<CR>

nnoremap <Leader>fp :call confirm(expand("%:p"))<CR>

" Automatically bind "goto definition" and "get info" to LangClient, when
" one is applicable for the current file type.
function! BindToLangClientIfServerExists()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
    nnoremap <buffer> <silent> <Leader>ee :call LanguageClient#explainErrorAtPoint()<CR>
  endif
endfunction
function! SendDidChangeLangClientIfServerExists()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    call LanguageClient#textDocument_didChange()
  endif
endfunction
augroup LangClient
  autocmd FileType * call BindToLangClientIfServerExists()
  autocmd CursorHold *.* call SendDidChangeLangClientIfServerExists()
augroup END

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

" Find merge conflict markers.
map <leader>gc /\v^[<\|=>]{7}( .*\|$)<CR>

" Visual shifting (does not exit Visual mode, much better).
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Colors.
let g:two_firewatch_italics=1
color two-firewatch
set bg=dark

" These `hi` commands MUST come after `color` is set! They overwrite some
" of the behavior of twofirewatch.

" Make search higlighting better by underlining matches.
" NOTE: this is specific to twofirewatch. Colors are taken from the theme.
hi Search guibg='FAF8F5' guifg='896724' gui=underline
" Make parens match in a way that's less confusing.
hi MatchParen gui=reverse

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

function! SetupTsserverPath ()
  let l:git_root = systemlist('git rev-parse --show-toplevel')[0]
  let l:tsconfig = findfile("tsconfig.json", ".;" . l:git_root)
  let l:ts_root  = fnamemodify(l:tsconfig, ":p:h")
  echom "ts_root: " . l:ts_root
  let l:tsserver = l:ts_root . "/node_modules/.bin/tsserver"
  if (filereadable(l:tsserver))
    let g:nvim_typescript#server_path = l:tsserver
  endif
endfunction

function! JsTsLocalMappings ()
  " remap ' to ` to encourage using template strings, just hit 2x to escape
  inoremap <buffer> ' `
  inoremap <buffer> '' '
  " map K to something reasonable
  nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  " shorthand for pipelining functions
  inoremap <C-Space><C-p><C-f> ᐅ
  inoremap <C-Space><C-p><C-d> ᐅdo
  inoremap <C-Space><C-p><C-i> ᐅif
  inoremap <C-Space><C-p><C-l> ᐅlog
  inoremap <C-Space><C-p><C-w> ᐅwhen
  inoremap <C-Space><C-p><C-e> ᐅeffect
endfunction

augroup javascript
  autocmd!
  autocmd FileType javascript call JsLocalMappings()
augroup END

augroup typescript
  autocmd!
  autocmd FileType typescript call TsLocalMappings()
  autocmd FileType typescript call SetupTsserverPath()
  autocmd BufEnter *.ts call SetupTsserverPath()
augroup END

" Can we create a GitAg like GitFiles using FZF? I think so.
" See https://github.com/junegunn/fzf.vim/issues/321 ! I asked Junegunn
" and he gave me this.
command! -bang -nargs=* GitAg call fzf#vim#ag(<q-args>, {
    \ 'dir': systemlist('git rev-parse --show-toplevel')[0]
  \ }, <bang>0)

" Okay let's do an SvnAg because Clang and LLVM are subversion projects
command! -bang -nargs=* SvnAg call fzf#vim#ag(<q-args>, {
    \ 'dir': systemlist('svn info --show-item wc-root')[0]
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
au Syntax * call matchadd('Todo', '\W\zs\EXPLANATION')

" Show me what I am doing
set showcmd

" Bad bad bags
augroup sizebag
  autocmd!
  autocmd VimResized * :redraw
augroup END

" Persistent per-file folds.
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent! loadview
