" Plugin setup.
" Required:
let deinbasepath = expand('<sfile>:p:h') . "/plugins"
let deinlocation = deinbasepath . "/repos/github.com/Shougo/dein.vim"
let &runtimepath .= ',' . deinlocation

" Required:
call dein#begin(deinbasepath)

" Let dein manage dein
" Required:
call dein#add('Shougo/dein.vim')
