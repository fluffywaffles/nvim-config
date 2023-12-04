" Turn off vi compatability and turn on various basic vim features.
set nocompatible

" Turn on true color mode, enabling millions of colors in terminal vim.
set termguicolors

" Source plugin manager setup for dein.nvim.
" Dein is Shougo's 'asynchronous dark-powered plugin manager'.
source ~/.config/nvim/setup-dein.vim
" Source plugin configurations.
source ~/.config/nvim/plugins.vim
" Notify dein that no more plugins will be `dein#add(...)`ed.
call dein#end()

" Set up python for the various plugins and neovim features that need it.
let g:python3_host_prog = '/usr/sbin/python' " Tell vim where python3 is.

" Set <Leader> to space.
" Ensure the spacebar is loud and clicky for maximum satisfaction.
let mapleader = ' '
" <LocalLeader> should not be the same as <Leader>.
" Generally only used by plugin authors so as to avoid mapping conflicts
" with user-defined maps that use <Leader>.
let maplocalleader = '_'

"
" Vanilla neovim global mappings.
"

" Frequently spammed shortcuts
noremap <Leader>w  :w<CR>
noremap <Leader>e  :e<CR>
noremap <Leader>x  :x<CR>
noremap <Leader>h  0
noremap <Leader>l  $
noremap <Leader>j  G
noremap <Leader>k  gg
noremap <Leader>/  :nohl<CR>
noremap <Leader>rc :source ~/.config/nvim/init.vim<CR>
noremap <Leader>fp  :echom expand("%:p")<CR>
noremap <Leader>cqf :call setqflist([])<CR>

" Adapted from ":help [["
" To use ]] and [[ as: "go to next/previous section open/close"
map  ]] /\%({\\|}\)<CR>:nohl<CR>
map  [[ ?\%({\\|}\)<CR>:nohl<CR>
vmap ]] /\%({\\|}\)<CR>
vmap [[ ?\%({\\|}\)<CR>

" spit out the full path to the current file
nnoremap <Leader>fp :call confirm(expand("%:p"))<CR>

" toggle line numbers in sidebar
map <Leader>n :set number!<CR>
" toggle spell checking
map <Leader>s :set spell! spelllang=en_us<CR>

" gF will go to an embedded line number, like: file.txt:13
noremap gf gF

" Wrapped lines goes down/up to next row, rather than next line in file.
noremap j gj
noremap k gk

" Visual shifting (does not exit Visual mode, much better).
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo... Really Write the file.
cmap w!! w !sudo tee % >/dev/null

"
" Less vanilla global mappings.
"

" Map Ctrl+P in Normal Mode to FZF gitfiles.
nnoremap <C-p> :GFiles<CR>

" Load merge conflicts into quickfix list.
map <Leader>gc :Git mergetool<CR>

" Can we create a GitAg like GitFiles using FZF? I think so.
" See https://github.com/junegunn/fzf.vim/issues/321 ! I asked Junegunn
" and he gave me this.
command! -bang -nargs=* GitAg call fzf#vim#ag(<q-args>, {
    \ 'dir': systemlist('git rev-parse --show-toplevel')[0]
  \ }, <bang>0)

" Run GitAg with word-under-cursor when I hit C-k.
nmap <C-k> "zyiw:exe "GitAg " . @z . ""<CR>

" Okay let's do an SvnAg because Clang and LLVM are subversion projects
command! -bang -nargs=* SvnAg call fzf#vim#ag(<q-args>, {
    \ 'dir': systemlist('svn info --show-item wc-root')[0]
  \ }, <bang>0)

"
" Plugin-dependent global settings.
"

" Helper to map dein#check_install() output to booleans for conditions
function! s:is_installed(plugins)
  let result = dein#check_install(a:plugins)
  if     result ==  0 | return v:true  " plugins are installed
  elseif result == -1 | return v:false " plugins are invalid
  elseif result !=  0 | return v:false " plugins are not installed
  endif
endfunction

" GitGutter configuration
"
if s:is_installed(['vim-gitgutter'])
  noremap <Leader>gg :GitGutterToggle<CR>
  " Turn off default mappings
  let g:gitgutter_map_keys = 0
  " Preview hunk under cursor
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
    autocmd BufWritePost * GitGutter
  augroup END
endif

" Tabular
"
if s:is_installed(['tabular'])
  noremap <Leader>t  :Tabularize/
endif

"
" Deoplete configuration
"

" num_processes: if set to 1, disabled; 0, unlimited
"   Parallel completion increases completion speed, but increases screen
"   flicker; especially in combination with { refresh_always: v:true }
"   (which is the default value for 'refresh_always').
call deoplete#custom#option('num_processes', 1)

" Alternative parallel completion configuration for faster completion:
" NOTE: didn't used to work nicely on a mac, could be better now.
if has('unix')
  call deoplete#custom#option('num_processes', 3)
  call deoplete#custom#option('refresh_always', v:false)
endif

" Start completing syntax / viml after 1 character instead of 2
call deoplete#custom#source('vim',    'min_pattern_length', 1)
call deoplete#custom#source('syntax', 'min_pattern_length', 1)

" Complete files from the cwd of the current file, not of the project.
call deoplete#custom#source('file', 'enable_buffer_path', 1)
" Don't default filtering by first character / string prefix; use fuzzy.
call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])

" default keyword_patterns: '[a-zA-Z_]\k*'
" add a '.' to {Java,Type}Script's pattern for object properties
call deoplete#custom#option('keyword_patterns', {
\ 'typescript': '[a-zA-Z_.]\k*',
\ 'javascript': '[a-zA-Z_.]\k*',
\})

" When vim starts or gets resized, set max widths for completion menu
autocmd VimEnter,VimResized * call UpdateDeopleteMenuWidth()
" With the exception of stupidly small clients, UpdateDeopleteMenuWidth()
" will ensure that most of the information for a completion candidate fits
" the popup, prioritizing abbreviation over kind over menu information.
function! UpdateDeopleteMenuWidth()
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
  echom "columns " . &columns
    \ . " abbr_width " . b:abbr_width
    \ . " kind_width " . b:kind_width
    \ . " menu_width " . b:menu_width
endfunction

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
set cursorline      " Highlights the line the cursor is on. Pretty.
set signcolumn=yes  " Always show the signcolumn. Reduces jitter.

set autoindent      " Keep the indentation of the previous line.
set smartindent     " Better auto-indent new code blocks.
" From :h 'smartindent': “If you don't want # to unindent, use this.”
inoremap # X#

" cindent is dumb. Extra-definitely disable it, with prejudice.
autocmd FileType c   set nocindent
autocmd FileType cpp set nocindent

set nojoinspaces " When joining lines: compress spaces into 1.
set splitright   " Vsplits go right.
set splitbelow   " Hsplits go below.

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

" Automatically bind "goto definition" and "get info" to LangClient, when
" one is applicable for the current file type.
function! BindToLangClientIfServerExists()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <C-W>d     :call GoToDefinitionInSplit()<CR>
    nnoremap <buffer> <silent> <C-w><C-d> :call GoToDefinitionInSplit()<CR>
    nnoremap <buffer> <silent> <Leader>gi :call LanguageClient_textDocument_implementation()<CR>
    nnoremap <buffer> <silent> <Leader>gt :call LanguageClient_textDocument_typeDefinition()<CR>
    nnoremap <buffer> <silent> <Leader>ee :call LanguageClient#explainErrorAtPoint()<CR>
    nnoremap <buffer> <silent> <Leader>rn :call LanguageClient_textDocument_rename()<CR>
    nnoremap <buffer> <silent> <Leader>rf :call LanguageClient_textDocument_references()<CR>
    nnoremap <buffer> <silent> <Leader>ca :call LanguageClient_textDocument_codeAction()<CR>
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
  autocmd!
  autocmd FileType      *   call BindToLangClientIfServerExists()
  autocmd ModeChanged   *:n call SendDidChangeLangClientIfServerExists()
  autocmd FileWritePost *   call SendDidChangeLangClientIfServerExists()
augroup END

" NOTE(jordan): smartindent isn't perfect. Old attempts to improve it:
" inoremap {<CR> <ESC>"xDa{<CR>}<ESC>O<C-r>x
" inoremap {<CR> {<CR>}<ESC>O

" Sets the cursor to first col when you open a new commit message.
autocmd FileType gitcommit
  \ autocmd! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Turn off deoplete conditional on the byte size of the buffer
function! DisableDeopleteIfBufferSizeGte(size_bytes)
  let counts = wordcount()
  echom "file is" counts["bytes"] "bytes, limit for completion is" a:size_bytes
  if counts["bytes"] >= a:size_bytes
    call deoplete#disable()
    autocmd BufLeave ++once call deoplete#enable()
  endif
endfunction

" Turn off deoplete in gitcommit edit panes with a patch larger than 10MB
autocmd FileType gitcommit
  \ autocmd! BufEnter COMMIT_EDITMSG
    \ call DisableDeopleteIfBufferSizeGte(1024 * 1024 * 10)

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

" Neomake configuration.
" Open location list when make has errors, but don't move the cursor.
let g:neomake_open_list=2

let g:LanguageClient_loggingFile = '/home/fluffywaffles/lsp.log'

function! SetupTypescriptLSP()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    return
  endif
  "" look for typescript-language-server
  let l:bin_path     = systemlist('yarn global bin typescript-language-server')[0]
  let l:lang_server  = l:bin_path . '/typescript-language-server'
  if (filereadable(l:lang_server))
    echom 'found typescript-language-server: ' . fnamemodify(l:lang_server, ':~:.')
  else
    echom 'cannot find typescript-language-server in yarn global bin'
    return
  endif
  "" look for local tsserver.js
  let l:node_modules = fnamemodify(systemlist('yarn bin tsc')[0], ':p:h:h')
  let l:tsserverjs   = l:node_modules . '/typescript/lib/tsserver.js'
  if (filereadable(l:tsserverjs))
    echom 'found local tsserver: ' . pathshorten(l:tsserverjs, 4)
    let g:LanguageClient_serverCommands[&filetype] = {
          \ 'name': 'typescript-language-server',
          \ 'command': [ l:lang_server, '--stdio' ],
          \ 'initializationOptions': {
          \     'tsserver': {
          \       'path': l:tsserverjs
          \     }
          \   }
          \ }
  else
    echom 'cannot find tslib path for this typescript project'
  endif
endfunction

function! TSConfigure()
  call SetupTypescriptLSP()
  let &makeprg = "npx tsc"
endfunction

augroup typescript
  autocmd!
  " FIXME: npx may not be correct if you're using yarn... sigh
  " autocmd FileType typescript call TSConfigure()
  "
  " npx --global typescript-language-server
  " we should in fact set up the command to be PATH-resilient, as before
  " except now we want to use nvim's builtin lsp, which means we need to
  " set this up in ./lua/init.lua
augroup END

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

lua require('init')
