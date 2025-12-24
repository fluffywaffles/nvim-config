if !exists(':Tabularize')
  finish
endif

let s:target_format = 'l1'

" Default allowed filetypes for smart backslash alignment
if !exists('g:tabular_smart_filetypes')
  let g:tabular_smart_filetypes = ['dockerfile', 'sh', 'zsh', 'bash']
endif

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

" Wrapper around Tabularize to selectively use AlignBackslash
" We overwrite the original :Tabularize command.
command! -nargs=* -range -bang Tabularize <line1>,<line2>call s:TabularizeWrapper(<bang>0, <q-args>)

function! s:TabularizeWrapper(bang, args) range
  let l:args = a:args
  let l:format = 'l1'
  let l:use_custom = 0

  " Check if filetype is allowed
  if index(g:tabular_smart_filetypes, &filetype) != -1
    " Check for patterns starting with /\ or /\\
    " Matches:
    " /\\       (standard usage)
    " /\\/      (regex pattern)
    " /\\/format (pattern with format)
    " Regex matches: Start, Slash, Backslash, Optional Slash.
    if l:args =~# '^/\\/\?'
      let l:use_custom = 1
      let l:extracted_format = matchstr(l:args, '^/\\/\?\zs.*')
      if !empty(l:extracted_format)
        let l:format = l:extracted_format
      endif
    endif
  endif

  if l:use_custom
    let s:target_format = l:format
    " Call the global Tabularize function directly with the custom pipeline name
    execute a:firstline . ',' . a:lastline . 'call Tabularize("AlignBackslash")'
  else
    " Fallback to original behavior. Call the global Tabularize function directly.
    execute a:firstline . ',' . a:lastline . 'call Tabularize("' . escape(l:args, '"') . '")'
  endif
endfunction
