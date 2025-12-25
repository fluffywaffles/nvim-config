if vim.fn.exists(':Tabularize') == 0 then
  return
end

-- Sets the default formatting parameters.
vim.g.tabular_runon_commands_format = 'l1'

-- Default allowed filetypes for smart backslash alignment
if vim.g.tabular_runon_commands_filetypes == nil then
  vim.g.tabular_runon_commands_filetypes = {'dockerfile', 'sh', 'zsh', 'bash'}
end

-- Helper function to perform alignment.
-- Must be globally accessible via v:lua.
_G.TabularSmartDoAlign = function(lines)
  -- TabularizeStrings returns a new list of strings
  local aligned = vim.fn['tabular#TabularizeStrings'](lines, '\\', vim.g.tabular_runon_commands_format)
  -- Return the aligned lines to replace the original lines in the pipeline
  return aligned
end

-- Custom pipeline to align backslashes without stripping indentation.
-- We use \u00A0 (NBSP) to preserve leading whitespace because Tabular strips regular spaces.
-- We use strdisplaywidth() to ensure we generate enough NBSPs to match the visual width (handling tabs).
vim.cmd([[
  AddTabularPipeline! AlignBackslash /\\/
    \ map(a:lines, "substitute(v:val, '^\\s*', '\\=repeat(\"\u00A0\", strdisplaywidth(submatch(0)))', '')")
    \ | let rv = v:lua.TabularSmartDoAlign(a:lines)
    \ | map(a:lines, "substitute(v:val, '\u00A0', ' ', 'g')")
]])

-- Wrapper around Tabularize to selectively use AlignBackslash
-- We overwrite the original :Tabularize command.
vim.api.nvim_create_user_command('Tabularize', function(opts)
  local args = opts.args
  local bang = opts.bang and '!' or ''

  local filetype = vim.bo.filetype
  local allowed_filetypes = vim.g.tabular_runon_commands_filetypes
  local filetype_allowed = false
  for _, ft in ipairs(allowed_filetypes) do
    if ft == filetype then
      filetype_allowed = true
      break
    end
  end

  local use_custom = false
  -- Check for patterns starting with /\ or /\\
  if filetype_allowed and args:match('^/\\/?') then
    use_custom = true
    -- Extract format if present
    -- Regex: ^/\\/?\zs.*
    -- Lua pattern: ^/\\/?(.*)
    local format = args:match('^/\\/?(.*)')
    if format and format ~= '' then
      vim.g.tabular_runon_commands_format = format
    else
      vim.g.tabular_runon_commands_format = 'l1'
    end
  end

  if use_custom then
    -- Call the global Tabularize function directly with the custom pipeline name
    -- We use vim.cmd to pass the range and call the Vimscript function
    vim.cmd(opts.line1 .. ',' .. opts.line2 .. 'call Tabularize("AlignBackslash")')
  else
    -- Fallback to original behavior.
    -- Escape quotes in args
    local escaped_args = args:gsub('"', '\\"')
    vim.cmd(opts.line1 .. ',' .. opts.line2 .. 'call Tabularize("' .. escaped_args .. '")')
  end
end, {
  nargs = '*',
  range = true,
  bang = true,
  force = true
})
