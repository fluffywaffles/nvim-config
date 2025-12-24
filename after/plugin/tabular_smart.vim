if !exists(':Tabularize')
  finish
endif

" Variable to pass the alignment format (e.g., 'l1') from the s:TabularizeWrapper
" command to the DoAlign function.
" Note: Must be global or accessible by the global function.
let g:tabular_smart_target_format = 'l1'

" Default allowed filetypes for smart backslash alignment
if !exists('g:tabular_smart_filetypes')
  let g:tabular_smart_filetypes = ['dockerfile', 'sh', 'zsh', 'bash']
endif

" Helper function to perform alignment.
" Must be global because it is called via 'exe' in the Tabular plugin context.
function! TabularSmartDoAlign(lines)
  " TabularizeStrings returns a new list of strings, so we must map it back to a:lines
  let l:aligned = tabular#TabularizeStrings(a:lines, '\\', g:tabular_smart_target_format)
  call map(a:lines, 'l:aligned[v:key]')
  " Return 0 to indicate no replacement of lines list (we modified in-place)
  return 0
endfunction

" Custom pipeline to align backslashes without stripping indentation
" We use \u00A0 (NBSP) to preserve leading whitespace because Tabular strips regular spaces.
" We use strdisplaywidth() to ensure we generate enough NBSPs to match the visual width (handling tabs).
AddTabularPipeline! AlignBackslash /\\/
  \ map(a:lines, "substitute(v:val, '^\\s*', '\\=repeat(\"\u00A0\", strdisplaywidth(submatch(0)))', '')")
  \ | TabularSmartDoAlign(a:lines)
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
    let g:tabular_smart_target_format = l:format
    " Call the global Tabularize function directly with the custom pipeline name
    execute a:firstline . ',' . a:lastline . 'call Tabularize("AlignBackslash")'
  else
    " Fallback to original behavior. Call the global Tabularize function directly.
    execute a:firstline . ',' . a:lastline . 'call Tabularize("' . escape(l:args, '"') . '")'
  endif
endfunction
