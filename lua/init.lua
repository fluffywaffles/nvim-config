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
  display = { icons = { mode = "none" } },
}
local coq = require('coq')
coq.Now()

-- add third-party sources
require('coq_3p') {
  -- automatically enable nvimlua for the neovim lua api
  { src = "nvimlua", conf_only = true },
  -- scientific calculator
  { src = "bc", precision = 6 },
  -- vim builtin sources
  { src = "builtin/js" },
  { src = "builtin/syntax" },
}

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
    -- start a tsserver connection if none is attached
    if vim.b.tsserver_running == nil then
      StartTsserver()
      -- set a tsserver_running flag for this buffer
      vim.b.tsserver_running = true
    end
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
  end
})

-- start solidity language server
-- NOTE: server instances are re-used for the same name and rootdir
-- so right now the published package is @llllvvuu/vscode-solidity-langserver
-- ... although presumably in the future it'll be @juanfranblanco/...
function StartSolidityLanguageServer()
  vim.lsp.set_log_level('debug')
  -- find the vscode-solidity-langserver binary in global npm/yarn bins
  local bin_path = vim.fn.systemlist('yarn global bin vscode-solidity-langserver')[1]
  local lang_server = bin_path .. '/vscode-solidity-langserver'
  -- if the binary does not exist, error out
  if not vim.fn.filereadable(lang_server) then
    print('cannot find vscode-solidity-langserver in yarn global bin')
    return
  end
  print(
    'found vscode-solidity-langserver binary: '
    .. vim.fn.fnamemodify(lang_server, ':~:.')
  )
  -- load remappings
  -- local remappings = vim.fn.readfile(vim.fs.normalize(vim.fs.find('remappings.txt', { upward = true })[1]));
  -- actually start the language server and enable completion
  vim.lsp.start(coq.lsp_ensure_capabilities({
    name = 'vscode-solidity-langserver',
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
    init_options = vim.fn.stdpath('cache') .. '/solidity-language-server',
    settings = {
      solidity = {
        defaultCompiler = 'embedded',
        compileUsingRemoteVersion = 'v0.8.23+commit.f704f362',
        formatter = 'forge',
        -- need remappings...
        -- ["solidity.remappings"] = remappings,
      }
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
