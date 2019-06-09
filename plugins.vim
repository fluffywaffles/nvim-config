" Denite - the asynchronous successor to Unite.
call dein#add('Shougo/denite.nvim')
" Context filetype. Applies filetype in nested code, e.g. JS in HTML.
call dein#add('Shougo/context_filetype.vim')
" LanguageClient-neovim - support language server protocol.
call dein#add('autozimu/LanguageClient-neovim', {
  \ 'rev'   : 'next',
  \ 'build' : 'bash install.sh',
  \ })
" Don't update too fast; I like to have a little time to type
let g:LanguageClient_changeThrottle = 0.5
let g:LanguageClient_serverCommands = {
  \ 'cpp': [
  \   '/usr/bin/cquery',
  \   '--logfile=/tmp/cq.log',
  \   '--init={
  \       "cacheDirectory": "/tmp/cquery",
  \       "completion": { "filterAndSort": false }
  \     }'
  \   ]
  \ }

" Add ternjs :TernDef, :TernJump, :TernRename, etc.
call dein#add('ternjs/tern_for_vim')
" Use configuration taken from https://github.com/carlitux/deoplete-ternjs
let g:tern#command = [ 'tern' ]
" let g:tern#arguments = [ '--persistent' ]

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion Engine - Deoplete and all sources.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Deoplete - because YCM is a PITA.
call dein#add('Shougo/deoplete.nvim')
" Syntax completion source for deoplete. (Loads from syntax files.)
call dein#add('Shougo/neco-syntax')
" Vim completion source for deoplete.
call dein#add('Shougo/neco-vim')
" Import/include/file path completion source for deoplete.
call dein#add('Shougo/neoinclude.vim')
" JS source. See its configuration in Github before using.
" call dein#add('carlitux/deoplete-ternjs', { 'build': 'npm i -g tern' })
" call deoplete#custom#source('ternjs', 'types', 1) " Show types
" call deoplete#custom#source('ternjs', 'filetypes', [ 'javascript' ])
" Tmux?! (THIS IS COOL. Automatically complete from nearby Tmux panes.)
call dein#add('wellle/tmux-complete.vim')
" TODO: lazyload the following completion sources. (See dein docs.)
" C/C++/Objective-C clang_complete source.
" call dein#add('Rip-Rip/clang_complete', { 'build': 'make install' })
" TypeScript source.
" call dein#add('mhartington/deoplete-typescript')
" Java completion
" call dein#add('artur-shaik/vim-javacomplete2')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Airline! For the winningest.
" call dein#add('vim-airline/vim-airline')
" Wakatime tracker.
call dein#add('wakatime/vim-wakatime')
" Javascript syntax highlighting.
call dein#add('pangloss/vim-javascript')
" TypeScript syntax highlighting.
call dein#add('leafgarland/typescript-vim')
" Update the builtin HTML syntax files.
call dein#add('othree/html5.vim')
" Pug (jade) syntax highlighting.
call dein#add('digitaltoad/vim-pug')
" Stylus syntax highlighting.
call dein#add('wavded/vim-stylus')
" Racket syntax highlighting.
call dein#add('wlangstroth/vim-racket')
" Tmux configuration syntax highlighting.
call dein#add('tmux-plugins/vim-tmux')
" Syntax highlighting inside of ES6 template strings.
call dein#add('Quramy/vim-js-pretty-template') " :JsPreTempl
" Highlight hexcode colors.
call dein#add('chrisbra/Colorizer')
" Self-explanatory.
let g:colorizer_auto_filetype='stylus,css,html'
" <Leader>cC toggle, <Leader>cT cycle contrast, <Leader>cF cycle fg/bg.
let g:colorizer_auto_map = 1
" Nice indentation guides.
call dein#add('nathanaelkane/vim-indent-guides')
let g:indent_guides_enable_on_vim_startup = 1
" LLVM TableGen and .ll syntax
call dein#add(expand('<sfile>:p:h') . '/llvm')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is the shrine to tpope. Hi HATERS http://tpo.pe
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Surround! This is what gives me S and ysiw and cs and ds.
call dein#add('tpope/vim-surround')
" Repeat! Makes more commands repeatable via '.'.
call dein#add('tpope/vim-repeat')
" Abolish and Subvert - for to fix the spelung.
" Also adds case coercions: crs sn_ake, cru UP_PER, crc cAmel, crm PasCal.
call dein#add('tpope/vim-abolish')
" Endwise - for adding `end`s to languages that need them.
call dein#add('tpope/vim-endwise')
" Characterize - better `ga` output for character data.
call dein#add('tpope/vim-characterize')
" Eunuch - Unix wrappers. But what matters is: makes #! files executable.
call dein#add('tpope/vim-eunuch')
" Commentary - comment and uncomment things using `gc`.
call dein#add('tpope/vim-commentary')
" Fugitive - the \"dangerously good\" git plugin. (Other plugins use it.)
call dein#add('tpope/vim-fugitive')
" Rhubarb - adds GitHub specific stuff to Fugitive.
call dein#add('tpope/vim-rhubarb')
" Obsession - automatic session save/restore.
" call dein#add('tpope/vim-obsession')
" Sleuth - auto-detect and set shiftwidth and tabstop.
call dein#add('tpope/vim-sleuth')
" Tbone - Tmux mappings; mostly Tyank and Tput to access its clipboard.
call dein#add('tpope/vim-tbone')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git gutter - +/- in sidebar gutter.
call dein#add('airblade/vim-gitgutter')
" Multiple cursors!!!!!!
call dein#add('terryma/vim-multiple-cursors')
" Don't let multiple cursors break deoplete!
function! g:Multiple_cursors_before()
  call deoplete#custom#buffer_option('auto_complete', v:false)
endfunction
function! g:Multiple_cursors_after()
  call deoplete#custom#buffer_option('auto_complete', v:true)
endfunction
" Show list of buffers in the statusline.
call dein#add('bling/vim-bufferline')
" Easymotion! <leader><leader> where art thou?
call dein#add('easymotion/vim-easymotion')
" Neomake - because it's better than syntastic.
call dein#add('neomake/neomake')
" FZF. Per https://github.com/Shougo/dein.vim/issues/74.
call dein#add('junegunn/fzf', { 'build': './install --all', 'merged': 0 })
call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
" Vim Tmux Navigator - Seamless Tmux navigation!
call dein#add('christoomey/vim-tmux-navigator')
let g:tmux_navigator_no_mappings = 1
nnoremap <C-a><C-j> :TmuxNavigateDown<CR>
nnoremap <C-a><C-k> :TmuxNavigateUp<CR>
nnoremap <C-a><C-l> :TmuxNavigateRight<CR>
nnoremap <C-a><C-h> :TmuxNavigateLeft<CR>
" Mundo - visualize the vim undotree.
call dein#add('simnalamburt/vim-mundo')
" Tabular - for to align all of the things! (But what about smart tabs?
call dein#add('godlygeek/tabular')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pretty colors.
call dein#add('rakr/vim-two-firewatch')
" call dein#add('ayu-theme/ayu-vim')
" call dein#add('chriskempson/tomorrow-theme')
" call dein#add('morhetz/gruvbox')
" call dein#add('mhartington/oceanic-next')
" call dein#add('mhartington/oceanic-next')
" call dein#add('vim-scripts/chlordane.vim')
" call dein#add('jnurmine/Zenburn')
" call dein#add('junegunn/seoul256.vim')
" call dein#add('arcticicestudio/nord-vim')
" call dein#add('tomasr/molokai')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Currently DISABLED plugins.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" YAJS - better js syntax.
" call dein#add('othree/yajs')
" Syntax highlighting for (almost) everything, but *fastly*.
" NOTE: can't highlight typescript to save its life.
" call dein#add('sheerun/vim-polyglot')
" let g:polyglot_disabled = []
" (Improved) CPP syntax highlighting.
" call dein#add('octol/vim-cpp-enhanced-highlight')
" Alternative to typescript-vim. (does not work.)
" call dein#add('HerringtonDarkholme/yats.vim')
" Elixir syntax highlighting. (replaced by polyglot.)
" call dein#add('elixir-lang/vim-elixir')
" Stylus syntax highlighting. (replaced by polyglot.)
" call dein#add('wavded/vim-stylus')
" Syntastic - because I am not my own best keeper
" call dein#add('scrooloose/syntastic')
" Tagbar - for visualizing an outline of a file via ctags.
" call dein#add('majutsushi/tagbar') " Requires ctags
" NERD tree?
" call dein#add('scrooloose/nerdtree')
" Very opinionated NERDtree defaults (incl. ONE tree in ALL instances.)
" https://github.com/jistr/vim-nerdtree-tabs
" call dein#add('jistr/vim-nerdtree-tabs')
" WebAPI and Gist.vim - gist it und rapido.
" call dein#add('mattn/webapi-vim')
" call dein#add('mattn/gist-vim')
" Tmuxline - makes Tmux look like Airline. (does not work.)
" call dein#add('edkolev/tmuxline.vim')
" Additional Airline themes.
" call dein#add('vim-airline/vim-airline-themes')
" Ack.vim - use ag for searching stuff.
" call dein#add('mileszs/ack.vim')
" Wildfire - quickly select the nearest text object.
" NOTE(jordan): this cruddy thing maps like a motherfucker and won't be
" overridden.
" call dein#add('gcmt/wildfire.vim')
" Vim-autoclose - autoclose pairs of ('" etc. NOTE: breaks <Esc> to end
" completion for deoplete.
" call dein#add('Townk/vim-autoclose')
" Complete autopairs when accepting a completion that starts with a ({['"
" etc. NOTE: obsoleted by the good autopairs plugin
" call dein#add('Shougo/neopairs.vim')
" Set up server command for javascript files.
" NOTE: tern is better.
" let g:LanguageClient_serverCommands = {
"   \ 'javascript': [ 'javascript-typescript-stdio' ],
"   \ 'javascript.jsx': [ 'javascript-typescript-stdio' ],
"   \ }
" Autopairs - better than Townk/autoclose? NOTE: not good enough, still
" annoying
" call dein#add('jiangmiao/auto-pairs')
"
