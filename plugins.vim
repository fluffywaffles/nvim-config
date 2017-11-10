" Unite - the UI thing that Shougo did. It's cool but hard to explain/understand.
" call dein#add('Shougo/unite.vim')
" Denite - the asynchronou successor to Unite
call dein#add('Shougo/denite.nvim')
" vimproc - the async thing that Shougo did. (Do I need this for anything anymore?)
call dein#add('Shougo/vimproc.vim', { 'build': 'make' })
" Context filetype. Applies filetype for completion in nested code, e.g. JS fenced in HTML
call dein#add('Shougo/context_filetype.vim')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion Engine - Deoplete and all sources.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Deoplete - because YCM is a PITA.
call dein#add('Shougo/deoplete.nvim')
" Vim files source.
call dein#add('Shougo/neco-vim')
" Syntax-based. (Loads completion from syntax files.)
call dein#add('Shougo/neco-syntax')
" Complete autopairs when accepting a completion that starts with a ({['" etc.
call dein#add('Shougo/neopairs.vim')
" JS source. See its configuration in Github before using.
" call dein#add('carlitux/deoplete-ternjs') " Requires tern to be instaled globally
" Tmux?!?! (HOLY SHIT THIS IS COOL. Automatically complete from nearby Tmux panes.)
call dein#add('wellle/tmux-complete.vim')
" GitHub?! (It'll actually complete from GitHub itself.)
"call dein#add('SevereOverfl0w/deoplete-github') " Requires fugitive and rhubarb
" ^^ Currently broke af.
" C/C++/Objective-C clang_complete source.
call dein#add('Rip-Rip/clang_complete', { 'build': 'make install' })
" Elixir source.
call dein#add('awetzel/elixir.nvim', { 'build': 'yes \| ./install.sh' })
" TypeScript source. Compare to Tsuquyomi?
call dein#add('mhartington/deoplete-typescript')
" Java completion
call dein#add('artur-shaik/vim-javacomplete2')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pretty colors.
call dein#add('rakr/vim-two-firewatch')
" Airline! For the winningest.
call dein#add('vim-airline/vim-airline')
" Wakatime tracker.
call dein#add('wakatime/vim-wakatime')
" Syntax highlighting for (almost) everything, but *fastly*.
call dein#add('sheerun/vim-polyglot')
let g:polyglot_disabled = [] " This list is used to disabled specific syntaxes elsewhere.
" Racket syntax highlighting.
call dein#add('wlangstroth/vim-racket')
" Syntax highlighting inside of ES6 template strings.
call dein#add('Quramy/vim-js-pretty-template')
" Highlight hexcode colors.
call dein#add('chrisbra/Colorizer')
" Self-explanatory.
let g:colorizer_auto_filetype='css,html'
" Sets <Leader>cC to toggle on/off, <Leader>cT to cycle contrast mode, <Leader>cF toggle fg/bg.
let g:colorizer_auto_map = 1
" Nice indentation guides.
call dein#add('nathanaelkane/vim-indent-guides')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is the shrine to tpope. Hi HATERS http://tpo.pe
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Surround! This is what gives me S and ysiw and cs and ds.
call dein#add('tpope/vim-surround')
" Repeat! Makes more commands repeatable via '.'.
call dein#add('tpope/vim-repeat')
" Abolish and Subvert - for to fix the spelung.
" Also provides casing coercions: crs snake_case, cru UPPER_CASE, crc camelCase, crm PascalCase.
call dein#add('tpope/vim-abolish')
" Endwise - for adding `end`s to languages that need them.
call dein#add('tpope/vim-endwise')
" Characterize - better `ga` output for character data.
call dein#add('tpope/vim-characterize')
" Eunuch - Unix wrappers. But what matters is: \"shebang files are automatically made executable.\"
call dein#add('tpope/vim-eunuch')
" Commentary - comment and uncomment things using `gc`.
call dein#add('tpope/vim-commentary')
" Speeddating - <C-x> and <C-a> for Date-formatted strings.
call dein#add('tpope/vim-speeddating')
" Fugitive - the \"dangerously good\" vim git plugin. (Other plugins use it.)
call dein#add('tpope/vim-fugitive')
" Rhubarb - adds GitHub specific stuff to Fugitive.
call dein#add('tpope/vim-rhubarb')
" Obsession - better session saving/restoration.
call dein#add('tpope/vim-obsession') " Used by tmux-resurrect.
" Sleuth - auto-detect and set shiftwidth and tabstop.
call dein#add('tpope/vim-sleuth')
" Tbone - Tmux mappings for lots of things, but mostly Tyank and Tput to access its clipboard.
call dein#add('tpope/vim-tbone')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git gutter - +/- in sidebar gutter.
call dein#add('airblade/vim-gitgutter')
" Ack.vim - use ag for searching stuff.
call dein#add('mileszs/ack.vim')
" This config is copied wholesale from spf13. Might want to rethink it later.
let g:ackprog='ag --nogroup --nocolor --column --smart-case'
" Multiple cursors!!!!!!
call dein#add('terryma/vim-multiple-cursors')
" Don't let multiple cursors break deoplete!
function! Multiple_cursors_before()
    let b:deoplete_disable_auto_complete = 1
endfunction
function! Multiple_cursors_after()
    let b:deoplete_disable_auto_complete = 0
endfunction
" Show list of buffers under the statusline.
call dein#add('bling/vim-bufferline')
" Easymotion! <leader><leader> where art thou?
call dein#add('easymotion/vim-easymotion')
" Preview substitutions (%s, s)
call dein#add('osyo-manga/vim-over')
" Wildfire - quickly select the nearest text object.
call dein#add('gcmt/wildfire.vim')
" Neomake - because it's better than syntastic.
call dein#add('neomake/neomake')
" FZF. Per https://github.com/Shougo/dein.vim/issues/74.
call dein#add('junegunn/fzf', { 'build': './install --all', 'merged': 0 })
call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
" Handlebars mode.
call add(g:polyglot_disabled, 'handlebars') " Disable polyglot syntax plugin in favor of this one.
call dein#add('mustache/vim-mustache-handlebars')
" Vim Tmux Navigator - Seamless Tmux navigation!
call dein#add('christoomey/vim-tmux-navigator')
" Make the keymappings match my Tmux configuration.
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-\> :TmuxNavigatePrevious<cr>
" Vim-autoclose - autoclose pairs of ('" etc.
call dein#add('Townk/vim-autoclose')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Currently DISABLED plugins.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ember development plugin. (Adds a lot of features, particularly leader bindings for shortcuts.)
" call dein#add('dsawardekar/ember.vim')
" Tsuquyomi - TypeScript omnicompletion magic. (deoplete-typescript does not depend on it any more.)
" call dein#add('Quramy/tsuquyomi') " Requires vimproc
" let g:tsuquyomi_disable_quickfix=1 " Don't check syntax
" let g:tsuquyomi_completion_detail=1 " Tell me more
" YAJS - better js syntax. (replaced by polyglot.)
" call dein#add('othree/yajs')
" (Improved) CPP syntax highlighting. (replaced by polyglot.)
" call dein#add('octol/vim-cpp-enhanced-highlight')
" TypeScript syntax highlighting. (replaced by polyglot.)
" call dein#add('leafgarland/typescript-vim')
" Alternative to typescript-vim. (does not work.)
"call dein#add('HerringtonDarkholme/yats.vim')
" Pug (jade) syntax highlighting. (replaced by polyglot.)
" call dein#add('digitaltoad/vim-pug')
" Elixir syntax highlighting. (replaced by polyglot.)
" call dein#add('elixir-lang/vim-elixir')
" Stylus syntax highlighting. (replaced by polyglot.)
" call dein#add('wavded/vim-stylus')
" Typings - wrapper around all the typings stuff, but in vim. :TypingsInstall et al
" call dein#add('mhartington/vim-typings') " Requires unite
" Syntastic - because I am not my own best keeper
" call dein#add('scrooloose/syntastic')
" Tagbar - for visualizing an outline of a file via ctags.
" call dein#add('majutsushi/tagbar') " Requires ctags
" NERD tree?
" call dein#add('scrooloose/nerdtree')
" Very opinionated NERDtree defaults (incl. ONE tree in ALL instances.) https://github.com/jistr/vim-nerdtree-tabs
" call dein#add('jistr/vim-nerdtree-tabs')
" Indent Guides?
" call dein#add('nathanaelkane/vim-indent-guides')
" WebAPI and Gist.vim - gist it und rapido.
" call dein#add('mattn/webapi-vim')
" call dein#add('mattn/gist-vim')
" Tabular - for to align all of the things! (But what about smart tabs? Other alternatives?)
" call dein#add('godlygeek/tabular')
" Tmuxline - makes Tmux look like Airline. (does not work.)
"call dein#add('edkolev/tmuxline.vim')
" Additional Airline themes.
"call dein#add('vim-airline/vim-airline-themes')
"
