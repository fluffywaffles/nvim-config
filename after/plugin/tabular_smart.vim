if !exists(':Tabularize')
  finish
endif

" Custom pipeline to align backslashes without stripping indentation
AddTabularPipeline! AlignBackslash /\\/
  \ map(a:lines, "substitute(v:val, '^ *', '\\=repeat(\"\u00A0\", len(submatch(0)))', '')")
  \ | tabular#TabularizeStrings(a:lines, '\\', 'l1')
  \ | map(a:lines, "substitute(v:val, '\u00A0', ' ', 'g')")

" SmartTabularize command to automatically use AlignBackslash for backslash pattern
command! -nargs=* -range -bang SmartTabularize <line1>,<line2>call s:SmartTabularize(<bang>0, <q-args>)

function! s:SmartTabularize(bang, args) range
  let l:args = a:args

  " Check if the pattern is trying to match backslash.
  " Patterns: /\\ (manual), /\\/ (full regex), /\ (incomplete but maybe intended?)
  let use_custom = 0
  if l:args =~# '^/\\$' || l:args =~# '^/\\/$' || l:args =~# '^/\\\\$' || l:args =~# '^/\\\\/$'
    let use_custom = 1
  endif

  if use_custom
    execute a:firstline . ',' . a:lastline . 'Tabularize AlignBackslash'
  else
    execute a:firstline . ',' . a:lastline . 'Tabularize' . (a:bang ? '!' : '') . ' ' . l:args
  endif
endfunction
