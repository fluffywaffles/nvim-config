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
    run = function()
      require('coq').deps()
    end
  },
  -- add coq third-party sources
  {
    'ms-jpq/coq.thirdparty',
    run = function()
      require('coq_3p') {
        -- automatically enable nvimlua for the neovim lua api
        { src = "nvimlua" },
        -- scientific calculator
        { src = "bc", precision = 6 },
        -- vim builtin sources
        { src = "builtin/js" },
        { src = "builtin/syntax" },
      }
    end
  }
}

paq.install()

-- start coq for autocompletion
vim.g.coq_settings = {
  auto_start = true,
  display = { icons = { mode = "none" } },
}
local coq = require('coq')
coq.Now()

-- configure some language servers
local lsp = require('lspconfig')
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
