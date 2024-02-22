-- set up our fancy new neovim package manager, paq
local paq = require('paq-bootstrap').bootstrap('git@github.com:savq/paq-nvim')

local paq_config = {
  -- opt = true, -- auto-lazy if true
  verbose = true, -- tell me when a package is installed
  url_format = 'git@github.com:%s', -- prefer ssh over https
}

paq:setup(paq_config) {
  -- let paq manage itself
  'savq/paq-nvim',
  -- install community-supplied well-known lsp configurations
  'neovim/nvim-lspconfig',
  -- coq-y autocompletion, very boisterous
  { 'ms-jpq/coq_nvim',
    -- automatically run coq.deps() and set coq to auto start with vim
    build = function()
      require('coq').deps()
    end
  },
  -- add coq third-party sources
  'ms-jpq/coq.thirdparty',
}

paq.install()

-- start coq for autocompletion
vim.g.coq_settings = {
  auto_start = true,
  limits = {
    completion_auto_timeout = 1,
    completion_manual_timeout = 1.88,
  },
  clients = {
    snippets = {
      warn = {}
    },
    tmux        = { weight_adjust = -0.1 },
    buffers     = { weight_adjust =  0.1 },
    third_party = { weight_adjust =  0.1 },
    lsp         = { weight_adjust =  0.2 },
    paths       = { weight_adjust =  0.3 },
  },
  display = {
    icons = {
      mode = "none",
    },
  },
  keymap = {
    bigger_preview = "",
  },
}

-- add third-party sources
require('coq_3p') {
  -- scientific calculator
  { src = "bc", precision = 6 },
  -- shell repl
  {
    src = "repl",
    sh = "zsh",
    deadline = 1000, -- ms to wait for response
    unsafe = { "mv", "rm", "poweroff", "suspend" },
  },
  -- automatically enable nvimlua for the neovim lua api
  { src = "nvimlua", short_name = "nLUA", conf_only = true },
  -- vim builtin sources
  { src = "builtin/syntax", short_name = "SYN" },
  { src = "builtin/js" },
  { src = "builtin/css" },
  { src = "builtin/html" },
}

local coq = require('coq')

-- configure some language servers
local lsp = require('lspconfig')
-- lua_ls
lsp.lua_ls.setup(coq.lsp_ensure_capabilities{
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    }
  }
})

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

local au_elixir = vim.api.nvim_create_augroup('elixir', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_elixir,
  pattern = { 'elixir', 'heex' },
  callback = function()
    -- start the language server
    StartElixirLS()
    -- set up some custom keybindings
    vim.keymap.set('n', ']}', [[?\s*\<def\%(p\=\|module\)\>?e<cr>/\<do:\=\>/e<cr><Plug>(MatchitNormalForward):nohl<cr>]], { silent = true })
    vim.keymap.set('n', '[{', [[/\s*\<end\>/e<cr><Plug>(MatchitNormalBackward):nohl<cr>]], { silent = true })
    -- don't shade the first indent level, that's defmodule
    vim.g.indent_guides_start_level = 2
  end
})

-- typescript tsserver
function StartTsserver()
  -- find the typescript-language-server binary in global npm/yarn bins
  local bin_path = vim.fn.systemlist('yarn global bin typescript-language-server')[1]
  local lang_server = bin_path .. '/typescript-language-server'
  -- if the binary does not exist, error out
  if not vim.fn.filereadable(lang_server) then
    print('cannot find typescript-language-server in yarn global bin')
    return
  end
  print(
    'found typescript-language-server binary: '
    .. vim.fn.fnamemodify(lang_server, ':~:.')
  )
  -- look for a tsserver.js local to the current buffer's project
  local node_modules = vim.fn.fnamemodify(
    vim.fn.systemlist('yarn bin tsc')[1],
    ':p:h:h'
  )
  local tsserverjs = node_modules .. '/typescript/lib/tsserver.js'
  -- if the tslib tsserver.js file does not exist, error out
  if not vim.fn.filereadable(tsserverjs) then
    print 'cannot find tslib path for a project relative to this buffer'
    return
  end
  print('found local tsserver: ' .. vim.fn.pathshorten(tsserverjs, 4))
  -- actually start the language server and enable completion
  vim.lsp.start(coq.lsp_ensure_capabilities({
    name = 'typescript-language-server',
    cmd = { lang_server, '--stdio' },
    root_dir = vim.fs.dirname(vim.fs.find('package.json', { upward = true })[1]),
    -- initialize the language server to use the local tsserver.js lib
    init_options = {
      tsserver = {
        path = tsserverjs
      }
    }
  }))
end

local au_typescript = vim.api.nvim_create_augroup('typescript', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_typescript,
  pattern = { 'typescript' },
  callback = function()
    StartTsserver()
  end
})

-- run solidity setup script on FileType
local au_solidity = vim.api.nvim_create_augroup('solidity', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_solidity,
  pattern = { 'solidity' },
  callback = function()
    -- set the lsp log level really high
    vim.lsp.set_log_level('debug')
    -- update filetype editor settings
    vim.cmd([[
      set tw=0
    ]])
    -- start a solidity language server
    StartSolidityLanguageServer()
    -- add keybindings
    vim.api.nvim_create_autocmd({ 'LspAttach' }, {
      callback = function(ev)
        -- Buffer local mappings.
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', '<space>f', function()
          vim.cmd([[ !${HOME}/.config/.foundry/bin/forge fmt ]])
        end, opts)
      end
    })
  end
})

-- start solidity language server
-- NOTE: server instances are re-used for the same name and rootdir
-- so right now the published package is @llllvvuu/vscode-solidity-langserver
-- ... although presumably in the future it'll be @juanfranblanco/...
function StartSolidityLanguageServer()
  -- find the vscode-solidity-langserver binary in global npm/yarn bins
  local bin_path = vim.fn.systemlist('yarn global bin vscode-solidity-server')[1]
  local lang_server = bin_path .. '/vscode-solidity-server'
  -- if the binary does not exist, error out
  if not vim.fn.filereadable(lang_server) then
    print('cannot find vscode-solidity-server in yarn global bin')
    return
  end
  print(
    'found vscode-solidity-server binary: '
    .. vim.fn.fnamemodify(lang_server, ':~:.')
  )
  -- load remappings
  -- local remappings = vim.fn.readfile(vim.fs.normalize(vim.fs.find('remappings.txt', { upward = true })[1]));
  -- actually start the language server and enable completion
  vim.lsp.start(coq.lsp_ensure_capabilities({
    name = 'vscode-solidity-server',
    cmd = { lang_server, '--stdio' },
    root_dir = vim.fs.dirname(vim.fs.find(
      { 'foundry.toml', 'remappings.txt', '.git' },
      {
        upward = true,
        -- it seems like autochdir changes the directory after this
        -- autocmd runs, which causes the current working directory to be
        -- used instead of the directory containing the file loaded in the
        -- buffer unless we add this flag. NOTE: 0 = current buffer.
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      }
    )[1]),
    init_options = vim.fn.stdpath('cache') .. '/vscode-solidity-server',
    settings = {
      solidity = {
        -- seems like remoteversion is broken since 0.0.165:
        --   https://github.com/juanfranblanco/vscode-solidity/issues/431#issuecomment-1933086248
        -- maintainer seems to not care / not understand.
        compileUsingRemoteVersion = "v0.8.23+commit.f704f362",
        formatter = "forge"
        -- need remappings...
        -- remappings = remappings,
      },
    },
  }))
end

-- set up lsp keybindings for normal mode in any buffer with a server
vim.api.nvim_create_autocmd({ 'LspAttach' }, {
  callback = function(ev)
    -- Buffer local mappings.
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>td', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<space>rf', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>d', vim.diagnostic.setloclist, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end
})
