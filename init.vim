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
noremap <Leader>gg :GitGutterToggle<CR>
noremap <Leader>t  :Tabularize/

" Frequently spammed shortcuts
noremap <Leader>w  :w<CR>
noremap <Leader>e  :e<CR>
noremap <Leader>x  :x<CR>
noremap <Leader>h  0
noremap <Leader>l  $
noremap <Leader>j  G
noremap <Leader>k  gg
noremap <Leader>/  :nohl<CR>

" gF will go to an embedded line number, like: file.txt:13
noremap gf gF

"
" GitGutter configuration
"
" Turn off default mappings
let g:gitgutter_map_keys = 0
" Preview ? hunk under cursor
nmap <Leader>ghp <Plug>(GitGutterPreviewHunk)
" Undo hunk under cursor
nmap <Leader>ghu <Plug>(GitGutterUndoHunk)
" Fold all unchanged lines
nnoremap ghf :GitGutterFold<CR>
" Load all hunks into list of links in quickfix
command! Gchanges GitGutterQuickFix | cope
nnoremap <Leader>gqf :Gchanges<CR>
" Hunk navigation
nmap ]c  <Plug>(GitGutterNextHunk)
nmap [c  <Plug>(GitGutterPrevHunk)
" Hunk textobjects?!
omap ic <Plug>(GitGutterTextObjectInnerPending)
omap ac <Plug>(GitGutterTextObjectOuterPending)
xmap ic <Plug>(GitGutterTextObjectInnerVisual)
xmap ac <Plug>(GitGutterTextObjectOuterVisual)
" Update GitGutter on buffer write
augroup GitGutter
  autocmd!
  autocmd BufWritePost *.* GitGutter
augroup END

"
" Deoplete configuration
"

" Tell deoplete to run on startup
let g:deoplete#enable_at_startup=1

" num_processes: if set to 1, disabled; 0, unlimited
"   Parallel completion increases completion speed, but increases screen
"   flicker; especially in combination with { refresh_always: v:true }
"   (which is the default value for 'refresh_always').
call deoplete#custom#option('num_processes', 1)

" Start completing syntax / viml after 1 character instead of 2
call deoplete#custom#source('vim',    'min_pattern_length', 1)
call deoplete#custom#source('syntax', 'min_pattern_length', 1)

" When vim starts or gets resized, set max widths for completion menu
autocmd VimEnter,VimResized * call UpdateMaxMenuWidth()
" With the exception of stupidly small clients, UpdateMaxMenuWidth() will
" ensure that most of the information for a completion candidate fits the
" popup, prioritizing abbreviation over kind over menu information.
function! UpdateMaxMenuWidth()
  let s:breakpoint = 60
  let s:twelfths = &columns / 12
  if &columns < s:breakpoint
    " the vim pane is tiny, prioritize the abbreviation and kind
    " at 60 cols worst case: 50 cols abbr, 10 cols kind, no menu
    " minimum usable width is 24 cols, only shows abbr, VERY small pane
    let b:abbr_width = max([10 * s:twelfths, 24])
    let b:kind_width = max([2  * s:twelfths,  6]) " [syntax] worst: [s..x]
    let b:menu_width = max([8  * s:twelfths,  0])
  else
    " the vim pane is large, reserve half of it for menu information
    " at 60 cols worst case: 20 cols abbr, 10 cols kind, 30 cols menu
    let b:abbr_width = 4 * s:twelfths
    let b:kind_width = 2 * s:twelfths
    let b:menu_width = 6 * s:twelfths
  endif
  " abbr, kind, and menu strings are displayed in the popup window
  call deoplete#custom#source('_', 'max_abbr_width', b:abbr_width)
  call deoplete#custom#source('_', 'max_kind_width', b:kind_width)
  call deoplete#custom#source('_', 'max_menu_width', b:menu_width)
  echom "columns " . &columns . " abbr_width " . b:abbr_width . " kind_width " . b:kind_width . " menu_width " . b:menu_width
endfunction

" Alternative parallel completion configuration for faster completion:
" NOTE: works quite nicely on a half-decent OS, but it's murder on a mac.
if has('unix')
  call deoplete#custom#option('num_processes', 3)
  call deoplete#custom#option('refresh_always', v:false)
endif

" Complete files from the cwd of the current file, not of the project.
call deoplete#custom#source('file', 'enable_buffer_path', 1)
" Don't default filtering by first character / string prefix; use fuzzy.
call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
" When completion is done, close the preview window.
autocmd CompleteDone * silent! pclose!
" Show a completion menu, even if only one candidate, and show additional
" information in a popup preview window
set completeopt=menuone,preview

" NOTE: enable debugging sources in deoplete.
" call deoplete#custom#option('profile', v:true)
" call deoplete#enable_logging('DEBUG', 'deoplete.log')
" call deoplete#custom#source('jedi', 'is_debug_enabled', 1)

" manually trigger completion with CTRL-X_CTRL-X
inoremap <expr> <C-X><C-X> deoplete#manual_complete()
" Press (<Shift>)<Tab> to cycle through completions.
inoremap <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <C-L>   pumvisible()
      \ ? deoplete#complete_common_string()
      \ : "\<C-L>"

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
set autoindent      " Keep the indentation of the previous line.
set smartindent     " Better auto-indent new code blocks.
set cursorline      " Highlights the line the cursor is on. Pretty.
set signcolumn=yes  " Always show the signcolumn. Reduces jitter.


set nojoinspaces " When joining lines: compress spaces into 1.
set splitright   " Vsplits go right.
set splitbelow   " Hsplits go below.

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
set wildmode=list:longest,full  " Complete common prefix and list options.

" This has to do with status messages. See :h 'shortmess' for details.
set shortmess+=aoOtTc

" Adapted from ":help [["
" To use ]] and [[ as: "go to next/previous section open/close"
map  ]] /\%({\\|}\)<CR>:nohl<CR>
map  [[ ?\%({\\|}\)<CR>:nohl<CR>
vmap ]] /\%({\\|}\)<CR>
vmap [[ ?\%({\\|}\)<CR>

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
autocmd VimEnter * nmap ga :call CharacterizeRetain()<CR>

nnoremap <Leader>fp :call confirm(expand("%:p"))<CR>

" Automatically bind "goto definition" and "get info" to LangClient, when
" one is applicable for the current file type.
function! BindToLangClientIfServerExists()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <C-W>d     :call GoToDefinitionInSplit()<CR>
    nnoremap <buffer> <silent> <C-w><C-d> :call GoToDefinitionInSplit()<CR>
    nnoremap <buffer> <silent> <Leader>ee :call LanguageClient#explainErrorAtPoint()<CR>
    nnoremap <buffer> <silent> <Leader>rn :call LanguageClient_textDocument_rename()<CR>
    nnoremap <buffer> <silent> <Leader>rf :call LanguageClient_textDocument_references()<CR>
  endif
endfunction

function GoToDefinitionInSplit()
  let cols = winwidth(0)
  let rows = winheight(0)
  echom "width" cols "height" (rows * 2) "height > width" (rows * 2) > cols
  if (rows * 2) > cols
    split
  else
    vsplit
  endif
  call LanguageClient_textDocument_definition()
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

" Stolen and simplified from spf13.
function! StripTrailingWhitespace()
  let previous_search=@/
  let row = line(".")
  let col = col(".")
  %s/\s\+$//e
  let @/=previous_search
  call cursor(row, col)
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

" Load merge conflicts into quickfix list.
map <Leader>gc :Git mergetool<CR>

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

" Language-specific autocmds.
function! JSConfigure()
  call JsTsLocalMappings()
endfunction

function! TSConfigure()
  call JsTsLocalMappings()
  call SetupTsserverPath()
  let &makeprg = "npx tsc"
endfunction

function! SetupTsserverPath()
  let l:git_root = systemlist('git rev-parse --show-toplevel')[0]
  let l:tsconfig = findfile("tsconfig.json", ".;" . l:git_root)
  let l:ts_root  = fnamemodify(l:tsconfig, ":p:h")
  echom "ts_root: " . l:ts_root
  let l:tsserver = l:ts_root . "/node_modules/.bin/tsserver"
  if (filereadable(l:tsserver))
    let g:nvim_typescript#server_path = l:tsserver
  endif
endfunction

function! JsTsLocalMappings()
  " remap ' to ` to encourage using template strings, just hit 2x to escape
  inoremap <buffer> ' `
  inoremap <buffer> '' '
  " shorthand for fallible functions
  inoremap <C-Space><C-f> ƒ
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
  autocmd FileType javascript call JSConfigure()
augroup END

augroup typescript
  autocmd!
  autocmd FileType typescript call TSConfigure()
augroup END

function GolangConfigure()
  set textwidth=100                        " more characters per line
  set noexpandtab                          " don't expand tabs to spaces
  set tabstop=2 softtabstop=2 shiftwidth=2 " tabs render as 2 spaces
  let g:neomake_go_enabled_makers = [ 'go' ]
endfunction

function GoLint()
  let l:pane_cmds = [
        \ 'tmux set-option -p remain-on-exit on',
        \ 'zsh -ic \"devenv repo lint go.git\"',
        \ ]
  execute 'Tmux' 'split-window' '-d' "'" . join(l:pane_cmds, ' && ') . "'"
endfunction

augroup golang
  autocmd!
  autocmd FileType go nnoremap <Leader>gl       :call GoLint()<CR>
  autocmd FileType go nnoremap <Leader>gf       :call LanguageClient_textDocument_formatting()<CR>
  autocmd FileType go inoremap <C-g><C-f>  <C-O>:call LanguageClient_textDocument_formatting()<CR>
  autocmd FileType go call GolangConfigure()
  command! Lint :call GoLint()
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

" Bad bad bags
augroup sizebag
  autocmd!
  autocmd VimResized * :redraw
augroup END

" NOTE(jordan): this seems to introduce weird behavior. :(
" Persistent per-file folds.
" set viewoptions="folds,cursor,curdir"
" autocmd BufWinLeave *.* mkview
" autocmd BufWinEnter *.* silent! loadview
