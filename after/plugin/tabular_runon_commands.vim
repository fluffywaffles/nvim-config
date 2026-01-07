if !exists(':Tabularize')
  finish
endif

" Sets the default formatting parameters.
let g:tabular_runon_commands_format = 'l1'
" Sets the default pattern for smart alignment.
let g:tabular_smart_pattern = '\\'

" Default allowed filetypes for smart backslash alignment
if !exists('g:tabular_runon_commands_filetypes')
  let g:tabular_runon_commands_filetypes = ['dockerfile', 'sh', 'zsh', 'bash']
endif

function! TabularSmartDoAlign(lines)
  let l:aligned = tabular#TabularizeStrings(a:lines, g:tabular_smart_pattern, g:tabular_runon_commands_format)
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

  " Check if filetype is allowed and args look like a regex pattern (start with /)
  if index(g:tabular_runon_commands_filetypes, &filetype) != -1 && l:args =~# '^/'
    " Parse pattern and format by splitting on unescaped slashes.
    " Regex matches a slash not preceded by an odd number of backslashes.
    let l:parts = split(l:args, '\%(\%(\\\\\)*\\\)\@<!/', 1)

    " l:parts[0] is empty (text before first slash).
    if len(l:parts) >= 2
      let g:tabular_smart_pattern = l:parts[1]
      let l:format = get(l:parts, 2, '')

      if !empty(l:format)
        let g:tabular_runon_commands_format = l:format
      else
        let g:tabular_runon_commands_format = 'l1'
      endif

      " Call the global Tabularize function directly with the custom pipeline name
      execute a:firstline . ',' . a:lastline . 'call Tabularize("AlignBackslash")'
      return
    endif
  endif

  " Fallback to original behavior. Call the global Tabularize function directly.
  execute a:firstline . ',' . a:lastline . 'call Tabularize("' . escape(l:args, '"') . '")'
endfunction
