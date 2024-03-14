-- don't shade the first indent level, that's defmodule
vim.g.indent_guides_guide_size = 1
vim.g.indent_guides_start_level = 2

-- set up some custom keybindings, needs to override ones from vim-elixir
vim.keymap.set('n', ']]', [[/\<\%(do\|fn\|def|defp|defmodule|defmacro|defmacrop\)\>/e<CR>:nohl<CR>]], { buffer = true })
vim.keymap.set('n', '[[', [[?\<\%(do\|fn\|def|defp|defmodule|defmacro|defmacrop\)\>?e<CR>:nohl<CR>]], { buffer = true })
vim.keymap.set('n', '][', [[/\<end\>/e<CR>:nohl<CR>]], { buffer = true })
vim.keymap.set('n', '[]', [[?\<end\>?e<CR>:nohl<CR>]], { buffer = true })
-- NOTE: vim.keymap.set('', '[{', 'vam<ESC>%') does not work, but
-- vim.cmd works fine--i don't know, the lua API maybe isn't the best?
vim.cmd([[
  nmap <buffer> [{ vam<ESC>%e
  nmap <buffer> ]} vam<ESC>e
  vmap <buffer> [{ vam%
  vmap <buffer> ]} vam
]])
