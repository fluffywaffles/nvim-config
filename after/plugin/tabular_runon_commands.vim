if !exists(':Tabularize')
  finish
endif

" Sets the default formatting parameters.
let g:tabular_runon_commands_format = 'l1'

" Default allowed filetypes for smart backslash alignment
if !exists('g:tabular_runon_commands_filetypes')
  let g:tabular_runon_commands_filetypes = ['dockerfile', 'sh', 'zsh', 'bash']
endif

function! TabularSmartDoAlign(lines)
  let l:aligned = tabular#TabularizeStrings(a:lines, '\\', g:tabular_runon_commands_format)
  call map(a:lines, 'l:aligned[v:key]')
endfunction

" Custom pipeline to align backslashes without stripping indentation
" We use \u00A0 (NBSP) to preserve leading whitespace because Tabular strips regular spaces.
" We use strdisplaywidth() to ensure we generate enough NBSPs to match the visual width (handling tabs).
AddTabularPipeline! AlignBackslash /\\/
  \ map(a:lines, "substitute(v:val, '^\\s*', '\\=repeat(\"\u00A0\", strdisplaywidth(submatch(0)))', '')")
  \ | call('TabularSmartDoAlign', [a:lines])
  \ | map(a:lines, "substitute(v:val, '\u00A0', ' ', 'g')")

" Wrapper around Tabularize to selectively use AlignBackslash
" We overwrite the original :Tabularize command.
command! -nargs=* -range -bang Tabularize <line1>,<line2>call s:TabularizeWrapper(<bang>0, <q-args>)

function! s:TabularizeWrapper(bang, args) range
  let l:args = a:args

  " Check if filetype is allowed and args match backslash pattern
  if index(g:tabular_runon_commands_filetypes, &filetype) != -1 && l:args =~# '^/\\/\?'
    " Extract format if present
    let l:extracted_format = matchstr(l:args, '^/\\/\?\zs.*')
    " If the extraction picked up a regex anchor '$' (e.g. from /\\$), strip it.
    if l:extracted_format =~# '^\$'
      let l:extracted_format = strpart(l:extracted_format, 1)
    endif

    if !empty(l:extracted_format)
      let g:tabular_runon_commands_format = l:extracted_format
    else
      let g:tabular_runon_commands_format = 'l1'
    endif

    " Call the global Tabularize function directly with the custom pipeline name
    execute a:firstline . ',' . a:lastline . 'call Tabularize("AlignBackslash")'
  else
    " Fallback to original behavior. Call the global Tabularize function directly.
    execute a:firstline . ',' . a:lastline . 'call Tabularize("' . escape(l:args, '"') . '")'
  endif
endfunction
