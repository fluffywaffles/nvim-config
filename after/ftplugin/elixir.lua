-- needed for coq.lsp_ensure_capabilities
local coq = require('coq')

-- don't shade the first indent level, that's defmodule
vim.g.indent_guides_start_level = 2

-- set up some custom keybindings, needs to override ones from vim-elixir
vim.keymap.set('n', ']]', [[/\<\%(do\|fn\|def|defp|defmodule|defmacro|defmacrop\)\>/e<CR>:nohl<CR>]], { buffer = true })
vim.keymap.set('n', '[[', [[?\<\%(do\|fn\|def|defp|defmodule|defmacro|defmacrop\)\>?e<CR>:nohl<CR>]], { buffer = true })
vim.keymap.set('n', '][', [[/\<end\>/e<CR>:nohl<CR>]], { buffer = true })
vim.keymap.set('n', '[]', [[?\<end\>?e<CR>:nohl<CR>]], { buffer = true })
-- NOTE: vim.keymap.set('', '[{', 'vam<ESC>%') does not work, but
-- vim.cmd works fine--i don't know, the lua API maybe isn't the best?
vim.cmd([[
  nmap <buffer> [{ vam<ESC>%
  nmap <buffer> ]} vam<ESC>
  vmap <buffer> [{ vam%
  vmap <buffer> ]} vam
]])

-- elixirls
function StartElixirLS()
  -- find the binary installed from the AUR package elixir-ls
  local lang_server = vim.fn.systemlist('which elixir-ls')[1]
  -- if the binary does not exist, error out
  if string.match(lang_server, '.*not found') ~= nil then
    print('cannot find elixir-ls server in path')
    return
  end
  -- find all mix project configuration files up to $HOME
  local mix_hierarchy = vim.fs.find('mix.exs', {
    upward = true,
    stop = vim.loop.os_homedir(),
    limit = math.huge, -- no effective limit
  })
  -- start the language server
  vim.lsp.start(coq.lsp_ensure_capabilities({
    name = 'elixirls',
    cmd_env = { SHELL = "bash" },
    cmd = { lang_server },
    -- assume the topmost mix.esx file is the root of the project
    --   ** use topmost assuming we may be in an umbrella app
    root_dir = vim.fs.dirname(mix_hierarchy[1]),
  }))
end

-- start elixir-ls via autocmd
local au_elixir = vim.api.nvim_create_augroup('elixir', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_elixir,
  pattern = { 'elixir', 'heex' },
  callback = function()
    -- start the language server
    StartElixirLS()
  end
})
