" Only apply this plugin patch if the :Tabularize command is loaded.
if !exists(':Tabularize')
  finish
endif

" Default formatting spec to use when none is specified.
let g:tabular_runon_commands_default_format = 'l1'

" Global formatting spec and the run-on commands match pattern.
let g:tabular_runon_commands_format = g:tabular_runon_commands_default_format
let g:tabular_runon_commands_pattern = '\\'

" By default, run-on commands are supported for shell-script-like filetypes.
if !exists('g:tabular_runon_commands_filetypes')
  let g:tabular_runon_commands_filetypes = ['dockerfile', 'sh', 'zsh', 'bash']
endif

function! TabularRunOnCommandDoAlign(lines)
  " Invoke Tabularize and capture the return value in a local variable...
  let l:aligned = tabular#TabularizeStrings(
        \ a:lines,
        \ g:tabular_runon_commands_pattern,
        \ g:tabular_runon_commands_format
    \ )
  " ... then map over the input "lines" and replace each line with the
  " newly-aligned line from l:aligned. This mutation is a typical
  " vimscript idiom, although it may look strange. In effect, since
  " a:lines is passed by reference and the return value of this function
  " will typically be discarded by the caller, we need to modify the
  " referenced data in the context of the caller to achieve our goal of
  " "passing" the lines on to the next function in our pipeline.
  map(a:lines, 'l:aligned[v:key]')
endfunction

" Custom pipeline to align backslashes without stripping indentation
" We use \u00A0 (NBSP) to preserve leading whitespace because Tabular strips regular spaces.
" We use strdisplaywidth() to ensure we generate enough NBSPs to match the visual width (handling tabs).
"
" NOTE: tabs will be replaced with single spaces, which is maybe awkward.
" Probably not the desired behavior for someone using tab alignment.
"
AddTabularPipeline! AlignRunOnCommandBackslashes /\\/
  \ map(a:lines, "substitute(v:val, '^\\s*', '\\=repeat(\"\u00A0\", strdisplaywidth(submatch(0)))', '')")
  \ | call('TabularRunOnCommandDoAlign', [a:lines])
  \ | map(a:lines, "substitute(v:val, '\u00A0', ' ', 'g')")

" Wrapper around Tabularize to selectively use AlignRunOnCommandBackslashes
" whenever the filetype allows run-on commands and whenever the match
" string starts with a backslash.
command! -nargs=* -range -bang Tabularize <line1>,<line2>call s:TabularizeWrapper(<bang>0, <q-args>)

" Tabularize wrapper that detects cases where we want to apply our custom
" run-on commands alignment pipeline, and intercepts those commands; and
" otherwise, transparently proxies requests to the 'real' Tabularize.
"
" NOTE: the 'range' postfix function argument indicates that when this
" function is called on a range, it will handle the whole range itself,
" rather than applying the default behavior where the function is mapped
" over each line individually.
"
function! s:TabularizeWrapper(bang, args) range
  let l:args = a:args

  " Trigger run-on commands alignment iff:
  "   - filetype is enabled for run-on commands
  "   - the match string starts with a backslash regexp pattern ('/\\')
  if index(g:tabular_runon_commands_filetypes, &filetype) != -1 && l:args =~# '^/\\'
    " Parse pattern and format by splitting on unescaped slashes.
    "
    " Regex: a forward slash NOT preceded by an odd number of backslashes:
    "
    "       \\\\    two consecutive backslashes
    "    \%(    \)    non-capturing group
    "    \%(\\\\\)*     zero or more pairs of backslashes
    "              \\     followed by one backslash
    " \%(     ...    \)     in a non-capturing group
    " \%(\%(\\\\\)*\\\)       which is: any odd number of backslashes
    "         ...      \@<!    as a negative lookbehind clause
    "         ...          \/  followed by a single forward slash
    "
    " \%(\%(\\\\\)*\\\)\@<!\/  in toto: exactly one forward slash, NOT
    "                            preceded by an odd number of backslashes.
    "
    " Any forward slash NOT preceded by an odd number of backslashes, in
    " other words, is an unescaped forward slash. This is the separator on
    " which we should split the components of a Tabularize command; e.g.:
    "
    "     :Tabularize/\\$/l1r0    ->  ['Tabularize', '\\$', 'l1r0']
    "     :Tabularize/\//         ->  ['Tabularize', '\/']
    "
    " Note how in the 2nd example the escaped forward slash is not treated
    " as a separator for the purposes of splitting the command string.
    "
    let l:parts = split(l:args, '\%(\%(\\\\\)*\\\)\@<!/', 1)

    " The pattern must contain at least 2 components separated by forward
    " slashes, or it is not actually a valid Tabularize command, and we
    " should not intercept it -- we'll fallthrough and let the global
    " Tabularize function do the validation and present the user an error.
    if len(l:parts) >= 2
      " The 2nd element is the pattern to match.
      let g:tabular_runon_commands_pattern = l:parts[1]
      " The 3rd, optional, argument is an alignment specifier; if none
      " specified, default to l1.
      let g:tabular_runon_commands_format = get(l:parts, 2, 'l1')

      " Execute Tabluarize with our custom pipeline for smart alignment of
      " trailing backslashes within multiline shell commands; that is,
      " properly align what we are calling "run-on commands" without
      " arbitrarily stripping leading whitespace indentation.
      execute a:firstline . ',' . a:lastline . 'call Tabularize("AlignRunOnCommandBackslashes")'
      return
    endif
  endif

  " Proxy all other Tabularize commands to the 'real' Tabularize.
  execute a:firstline . ',' . a:lastline . 'call Tabularize("' . escape(l:args, '"') . '")'
endfunction
