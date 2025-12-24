if !exists(':Tabularize')
  finish
endif

let s:target_format = 'l1'

function! s:DoAlign(lines)
  " TabularizeStrings returns a new list of strings, so we must map it back to a:lines
  let l:aligned = tabular#TabularizeStrings(a:lines, '\\', s:target_format)
  call map(a:lines, 'l:aligned[v:key]')
  return []
endfunction

" Custom pipeline to align backslashes without stripping indentation
" We use \u00A0 (NBSP) to preserve leading whitespace because Tabular strips regular spaces.
" We use strdisplaywidth() to ensure we generate enough NBSPs to match the visual width (handling tabs).
AddTabularPipeline! AlignBackslash /\\/
  \ map(a:lines, "substitute(v:val, '^\\s*', '\\=repeat(\"\u00A0\", strdisplaywidth(submatch(0)))', '')")
  \ | call s:DoAlign(a:lines)
  \ | map(a:lines, "substitute(v:val, '\u00A0', ' ', 'g')")

" SmartTabularize command to automatically use AlignBackslash for backslash pattern
command! -nargs=* -range -bang SmartTabularize <line1>,<line2>call s:SmartTabularize(<bang>0, <q-args>)

function! s:SmartTabularize(bang, args) range
  let l:args = a:args
  let l:format = 'l1'
  let l:use_custom = 0

  " Check for patterns starting with /\ or /\\
  " Matches:
  " /\\       (exact match)
  " /\\/      (regex pattern)
  " /\\/format (pattern with format)
  " Regex: matches start of string, / followed by literal \, optional /, optional format chars
  if l:args =~# '^/\\\\/\?'
    let l:use_custom = 1
    let l:extracted_format = matchstr(l:args, '^/\\\\/\?\zs.*')
    if !empty(l:extracted_format)
      let l:format = l:extracted_format
    endif
  endif

  if l:use_custom
    let s:target_format = l:format
    execute a:firstline . ',' . a:lastline . 'Tabularize AlignBackslash'
  else
    execute a:firstline . ',' . a:lastline . 'Tabularize' . (a:bang ? '!' : '') . ' ' . l:args
  endif
endfunction
