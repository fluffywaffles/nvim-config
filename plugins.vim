""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion and IDE - Deoplete, sources, language-specific plugins.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LanguageClient-neovim - language server protocol client.
call dein#add('autozimu/LanguageClient-neovim', {
  \ 'rev'   : 'next',
  \ 'build' : 'bash install.sh',
  \ })
let g:LanguageClient_serverCommands = {
  \ 'cpp': [
  \   '/usr/bin/cquery',
  \   '--logfile=/tmp/cq.log',
  \   '--init={
  \       "cacheDirectory": "/tmp/cquery",
  \       "completion": { "filterAndSort": false }
  \     }'
  \   ],
  \ 'go': [ '~/go/bin/gopls' ]
  \ }
" Deoplete - because YCM is a PITA.
call dein#add('Shougo/deoplete.nvim')
" Syntax completion source for deoplete. (Loads from syntax files.)
call dein#add('Shougo/neco-syntax')
" Vim completion source for deoplete.
call dein#add('Shougo/neco-vim')
" Import/include/file path completion source for deoplete.
call dein#add('Shougo/neoinclude.vim')
" Tmux - complete from nearby tmux panes.
call dein#add('wellle/tmux-complete.vim')
" Add ternjs :TernDef, :TernJump, :TernRename, etc.
" Use configuration taken from https://github.com/carlitux/deoplete-ternjs
" call dein#add('ternjs/tern_for_vim')
" let g:tern#command = [ 'tern' ]

" zshcompsys completion within zsh files
" NOTE(jordan): requires module zsh/zpty to have been zmodload-ed
call dein#add('deoplete-plugins/deoplete-zsh')

"
" NOTE(jordan): nvim-typescript tries to typecheck python files, plaintext
" files, and anything I load into a buffer when a TypeScript file *was*
" open in the last-focused vim window; it's needlessly slow; and it is
" buggy as all heck and has been for months. I'm out. Run tsc -w in a tmux
" pane; get completion from something else. (Tsuquyomi?)
"
" TypeScript completion & commands (e.g. :TSDef, :TSRename, ...)
call dein#add('mhartington/nvim-typescript', {
  \ 'build': './install.sh',
  \ })
" let g:nvim_typescript#diagnostics_enable=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pretty colors.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('rakr/vim-two-firewatch')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax plugins.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Javascript syntax highlighting.
call dein#add('pangloss/vim-javascript')
" Alternative to yats.
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
" <Leader>cC toggle, <Leader>cT cycle contrast, <Leader>cF cycle fg/bg.
call dein#add('chrisbra/Colorizer')
let g:colorizer_auto_map      = 1
let g:colorizer_auto_filetype = 'stylus,css,html'
" Nice indentation guides.
call dein#add('nathanaelkane/vim-indent-guides')
let g:indent_guides_enable_on_vim_startup = 1
" Disable indent guides in manpages opened using :Man.
augroup manpage_indent_guides
  autocmd!
  autocmd BufAdd,BufEnter    man://* :call indent_guides#disable()
  autocmd BufLeave,BufUnload man://* :call indent_guides#enable()
augroup END
" LLVM TableGen and .ll syntax
call dein#add(expand('<sfile>:p:h') . '/llvm')
" Ember Handlebars
call dein#add('joukevandermaas/vim-ember-hbs')
" Terraform
call dein#add('hashivim/vim-terraform')

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
" Fugitive - the \"dangerously good\" git plugin. (:Gblame is from here.)
call dein#add('tpope/vim-fugitive')
" Rhubarb - adds GitHub specific stuff to Fugitive.
call dein#add('tpope/vim-rhubarb')
" Sleuth - auto-detect and set shiftwidth and tabstop.
call dein#add('tpope/vim-sleuth')
" Tbone - Tmux mappings; mostly Tyank and Tput to access its clipboard.
call dein#add('tpope/vim-tbone')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Miscellaneous.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Denite - the asynchronous successor to Unite.
call dein#add('Shougo/denite.nvim')
" Context filetype. Applies filetype in nested code, e.g. JS in HTML.
call dein#add('Shougo/context_filetype.vim')
" Wakatime tracker.
call dein#add('wakatime/vim-wakatime')
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
" Mundo - visualize the vim undotree.
call dein#add('simnalamburt/vim-mundo')
" Tabular - for to align all of the things!
call dein#add('godlygeek/tabular')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Currently UNUSED colors. (No reason to load them.)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" call dein#add('ayu-theme/ayu-vim')
" call dein#add('chriskempson/tomorrow-theme')
" call dein#add('morhetz/gruvbox')
" call dein#add('mhartington/oceanic-next')
" call dein#add('vim-scripts/chlordane.vim')
" call dein#add('jnurmine/Zenburn')
" call dein#add('junegunn/seoul256.vim')
" call dein#add('arcticicestudio/nord-vim')
" call dein#add('tomasr/molokai')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Currently DISABLED syntax.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" YAJS - better js syntax.
" call dein#add('othree/yajs')
" Syntax highlighting for (almost) everything, but *fastly*.
" NOTE: can't highlight typescript to save its life.
" call dein#add('sheerun/vim-polyglot')
" let g:polyglot_disabled = []
" (Improved) CPP syntax highlighting.
" call dein#add('octol/vim-cpp-enhanced-highlight')
" TypeScript syntax highlighting.
" call dein#add('HerringtonDarkholme/yats.vim')
" Elixir syntax highlighting.
" call dein#add('elixir-lang/vim-elixir')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Currently DISABLED plugins.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Obsession - automatic session save/restore.
" call dein#add('tpope/vim-obsession')
" Syntastic - because I am not my own best keeper
" call dein#add('scrooloose/syntastic')
" Tagbar - for visualizing an outline of a file via ctags.
" call dein#add('majutsushi/tagbar') " Requires ctags
" WebAPI and Gist.vim - gist it und rapido.
" call dein#add('mattn/webapi-vim')
" call dein#add('mattn/gist-vim')
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
" Autopairs - better than Townk/autoclose?
" call dein#add('jiangmiao/auto-pairs')
" let g:AutoPairsShortcutBackInsert = "<C-q><C-q>"
" let g:AutoPairsShortcutToggle     = "<C-q><C-t>"
" let g:AutoPairsShortcutFastWrap   = "<C-q><C-w>"
" let g:AutoPairsShortcutJump       = "<C-q><C-j>"
" let g:AutoPairsFlyMode            = 0
" let g:AutoPairsMultilineClose     = 0
" autocmd FileType typescript let b:AutoPairs = AutoPairsDefine({ '<': '>' })
