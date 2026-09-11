-- set up our fancy new neovim package manager, paq
local paq = require('paq-bootstrap').bootstrap('git@github.com:fluffywaffles/paq-nvim', 'waffles/packed-refs')

local paq_config = {
  -- opt = true, -- auto-lazy if true
  verbose = false,                  -- tell me when a package is installed
  url_format = 'git@github.com:%s', -- prefer ssh over https
  -- partial clones: retain commit history (vs. shallow), but only the most-recent version of each file
  -- (inspired by lazy.nvim)
  clone_args = { '--filter=blob:none' },
}

paq:setup(paq_config) {
  { 'fluffywaffles/paq-nvim', branch = 'waffles/packed-refs' },
  -- install community-supplied well-known lsp configurations
  'neovim/nvim-lspconfig',
  -- coq-y autocompletion, very boisterous
  'ms-jpq/coq_nvim',
  -- add coq third-party sources
  'ms-jpq/coq.thirdparty',
  -- multiple cursors support; terryma/vim-multiple-cursors is deprecated!
  'mg979/vim-visual-multi',
  -- easier user-defined textobj
  'kana/vim-textobj-user',
  -- textobj definitions for folds
  -- NOTE: depends on vim-textobj-user
  'kana/vim-textobj-fold',
  -- textobj definitions for matchit pairs (finally)
  -- NOTE: depends on vim-textobj-user
  'adriaanzon/vim-textobj-matchit',
  -- elixir ftplugin
  'elixir-editors/vim-elixir',
  -- faster gitgutter
  'lewis6991/gitsigns.nvim',
  -- treesitter
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  -- treesitter curent context header
  'nvim-treesitter/nvim-treesitter-context',
  -- indent guides
  'nathanaelkane/vim-indent-guides',
  -- plenary.nvim, a standard library of sorts
  'nvim-lua/plenary.nvim',
  -- conform.nvim, a lightweight formatter plugin
  'stevearc/conform.nvim',
  -- windsurf / codeium
  -- 'Exafunction/windsurf.nvim',
  -- diff viewer
  'esmuellert/codediff.nvim',
  -- tint for dimming when focus lost
  'TaDaa/vimade',
  -- color picker and highlighter
  'uga-rosa/ccc.nvim',
  -- distraction free mode
  'folke/zen-mode.nvim',
}

-- always run PaqInstall
paq:install()

-- helper functions
function GetOs()
  local uname_s = vim.uv.os_uname().sysname:lower()
  if not ({linux = true, darwin = true})[uname_s] then
    error("Operating system unsupported: " .. uname_s)
  else
    return uname_s
  end
end

function GetArch()
  local uname_m = vim.uv.os_uname().machine

  local remapped = ({
    x86_64 = 'amd64'
  })[uname_m]

  return remapped or uname_m
end

function GetRoot()
  local toplevel = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 and toplevel ~= nil and toplevel ~= '' then
    return toplevel
  else
    return vim.fn.getcwd()
  end
end

-- general editor configuration
vim.o.scrolloff = 10
vim.o.completetimeout = 1880
vim.o.statusline = '%<%f %h%m%r%=%-14.(%l,%c%V%) %P'
-- vim.o.statusline = vim.o.statusline .. '%3{v:lua.require("codeium.virtual_text").status_string()}'

-- in visual multi we need <CR> to work nicely when pumvisible()
vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = 'visual_multi_mappings',
  callback = function()
    -- ensure that we accept completion without adding a newline
    vim.keymap.set('i', '<CR>', function()
      return vim.fn.pumvisible() == 1 and '<C-Y>' or '<Plug>(VM-I-Return)'
    end, { expr = true, buffer = true })
  end
})

-- set up treesitter
require('nvim-treesitter').setup({
  ensure_installed = { 'lua', 'vim', 'python' },
  -- highlighting configuration
  highlight = {
    enable = true,
    -- disable highlighting under various conditions
    disable = function(_, _)
      return false
        -- turn off elixir treesitter highlighting, it's not good
        or vim.o.filetype == 'elixir'
        -- disable highlighting on files larger than 1MB
        or (function()
          local counts = vim.fn.wordcount()
          return counts['bytes'] > (1024 * 1024)
        end)()
    end
  },
})

-- set up treesitter-context
require('treesitter-context').setup({
  enable = true,
  separator = '─',
})

-- set up vim-indent-guides
vim.g.indent_guides_guide_size = 1
-- do not show indent guides in help files and man pages
vim.g.indent_guides_exclude_filetypes = { 'help', 'man' }
vim.g.indent_guides_enable_on_vim_startup = 1

-- fix netrw / coq_nvim buffer invalidation error
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  callback = function(args)
    -- force netrw buffers to hide instead of wipe when leaving the window,
    -- keeping the buffer ID valid so coq_nvim's BufEnter doesn't crash on it.
    vim.bo[args.buf].bufhidden = 'hide'
  end
})

-- set up gitsigns
require('gitsigns').setup({})

-- gitsigns: highlighting
vim.api.nvim_set_hl(0, 'GitsignsAdd',    { link = 'DiffAdd'    })
vim.api.nvim_set_hl(0, 'GitsignsChange', { link = 'DiffChange' })
vim.api.nvim_set_hl(0, 'GitsignsDelete', { link = 'DiffDelete' })

-- gitsigns: mappings for manipulating and navigating hunks
local gitsigns = require('gitsigns')
vim.keymap.set('n', '<Leader>gg',  gitsigns.toggle_signs)
vim.keymap.set('n', '<Leader>ghp', gitsigns.preview_hunk)
vim.keymap.set('n', '<Leader>ghu', gitsigns.reset_hunk)
vim.keymap.set('n', ']c', function() gitsigns.nav_hunk('next') end)
vim.keymap.set('n', '[c', function() gitsigns.nav_hunk('prev') end)
vim.keymap.set('n', 'gic', gitsigns.select_hunk)

-- gitsigns: quickfix
vim.keymap.set('n', '<Leader>gqf', function() gitsigns.setqflist('all') end)

-- gitsigns: text objects
vim.keymap.set({'o', 'x'}, 'ic', gitsigns.select_hunk)
vim.keymap.set({'o', 'x'}, 'ac', gitsigns.select_hunk)


-- set up annotate (local code review)
require('annotate').setup()

-- set up vimade
require('vimade').setup({
  recipe = { "default", { animate = false } },
  enablefocusfading = true,
  fadelevel = 0.4,
})

-- set up ccc (color picker + highlighter)
local ccc = require('ccc')
ccc.setup({
  highlighter = {
    auto_enable = true, -- Automatically highlight colors
    lsp = true,
    excludes = { "markdown", "text" },
  },
})
-- Use <Leader>cp to open the interactive color picker on the color under the cursor
vim.keymap.set('n', '<Leader>cp', '<Cmd>CccPick<CR>')
-- Use <Leader>ch to toggle color highlighting
vim.keymap.set('n', '<Leader>ch', '<Cmd>CccHighlighterToggle<CR>')

--[[
-- set up codeium
require('codeium').setup({
  enable_cmp_source = false,
  enable_chat = true,
  virtual_text = {
    enabled = true,
    default_filetype_enabled = true,
    map_keys = true,
    key_bindings = {
      accept = '<C-l>',
      next = '<C-]>',
      prev = '<C-[>',
      accept_word = '<C-;>',
      accept_line = '<C-\'>',
    },
  }
})
--]]

-- start coq for autocompletion
vim.g.coq_settings = {
  clients = {
    -- third_party = { weight_adjust = 0.1, always_on_top = { 'codeium' } },
    buffers     = { weight_adjust = 0.1 },
    lsp         = { weight_adjust = 0.2 },
    paths       = { weight_adjust = 0.3 }
  },
  display = {
    icons = {
      mode = 'none',
    },
  },
  keymap = {
    bigger_preview = '<c-k>',
  },
}
vim.keymap.set({ 'i', 's' }, '<C-h>', function() vim.snippet.jump(1) end)

-- add third-party sources
require('coq_3p') {
  -- windsurf / codeium
  -- { src = 'codeium', short_name = 'AI' },
  -- scientific calculator
  { src = 'bc', precision = 6 },
  -- shell repl
  {
    src = 'repl',
    sh = 'zsh',
    deadline = 1000, -- ms to wait for response
    unsafe = { 'mv', 'rm', 'poweroff', 'suspend' },
  },
  -- automatically enable nvimlua for the neovim lua api
  { src = 'nvimlua', short_name = 'nLUA', conf_only = true },
  -- vim builtin sources
  { src = 'builtin/syntax', short_name = 'SYN' },
  { src = 'builtin/js' },
  { src = 'builtin/css' },
  { src = 'builtin/html' },
}

local coq = require('coq')

-- configure some language servers
-- lua_ls
vim.lsp.config('lua_ls', {
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

local au_lua = vim.api.nvim_create_augroup('lua', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_lua,
  pattern = { 'lua' },
  callback = function()
    -- enable lua_ls
    vim.lsp.enable({ 'lua_ls' })
  end
})

-- setup sourcekit for swift
vim.lsp.config('sourcekit', {
  -- https://www.swift.org/documentation/articles/zero-to-swift-nvim.html#file-updating
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      }
    }
  }
})

local au_swift = vim.api.nvim_create_augroup('swift', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_swift,
  pattern = { 'swift' },
  callback = function()
    -- enable the sourcekit lsp server
    vim.lsp.enable('sourcekit')
    -- update filetype editor settings
    vim.g.indent_guides_guide_size = 3
  end
})

-- elixir official lsp: expert-ls
vim.lsp.config('expert', {
  cmd = { os.getenv('HOME') .. '/software/expert_' .. GetOs() .. '_' .. GetArch(), '--stdio' },
  root_markers = { 'mix.exs', '.git' },
  filetypes = { 'elixir', 'eelixir', 'heex' },
  settings = {
    -- cf. https://github.com/elixir-lang/expert/tree/main/apps/expert/lib/expert/configuration.ex
    dialyzerEnabled = false
  }
})

local au_elixir = vim.api.nvim_create_augroup('elixir', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_elixir,
  pattern = { 'elixir', 'eelixir', 'heex' },
  callback = function()
    -- enable the expert lsp server
    vim.lsp.enable('expert')
    -- don't fold defmodules
    vim.b.foldlevelstart = 2
  end
})

function NodeGetGlobalBinPaths()
  local results = {}
  -- try to find a global binary path for npm
  local npm_prefix_maybe = vim.fn.systemlist('npm config get prefix')
  if vim.v.shell_error == 0 then
    table.insert(results, npm_prefix_maybe[1] .. '/bin')
  end
  -- try to find a global binary path for yarn
  local yarn_bin_maybe = vim.fn.systemlist('yarn global bin')
  if vim.v.shell_error == 0 then
    table.insert(results, yarn_bin_maybe[1])
  end
  -- return the final list, which will only contain found binary paths
  return results
end

function NodeFindGlobalBin(binary_name)
  local paths = NodeGetGlobalBinPaths()
  -- search for a readable binary with the expected name in any bin path
  for _, path in ipairs(paths) do
    local expected_bin_path = path .. '/' .. binary_name
    if vim.fn.filereadable(path .. '/' .. binary_name) then
      return expected_bin_path
    end
  end
  -- if nothing is found, return nil
  return nil
end

-- typescript tsserver
function StartTsserver()
  -- find the typescript-language-server binary in global npm/yarn bins
  local lang_server_bin = NodeFindGlobalBin('typescript-language-server')
  -- if the binary does not exist, error out
  if lang_server_bin == nil then
    print('cannot find typescript-language-server in npm global bin')
    return
  end
  -- look for a tsserver.js local to the current buffer's project
  local gitroot = GetRoot()
  local node_modules_hierarchy = vim.fs.find('node_modules', {
    upward = true,
    stop = gitroot,
    type = 'directory',
    limit = math.huge, -- no effective limit
  })
  -- use the topmost node_modules in the repo, because workspaces
  local root_node_modules = node_modules_hierarchy[#node_modules_hierarchy]
  if root_node_modules == nil then
    print 'cannot find node_modules path in any directory above this buffer up to the git root'
    return
  end
  -- find the local installation of tsserver
  local tsserverjs = root_node_modules .. '/typescript/lib/tsserver.js'
  -- if the tslib tsserver.js file does not exist, error out
  if not vim.fn.filereadable(tsserverjs) then
    print 'cannot find tslib path for a project relative to this buffer'
    return
  end
  -- actually start the language server and enable completion
  vim.lsp.start({
    name = 'typescript-language-server',
    cmd = { lang_server_bin, '--stdio' },
    root_dir = gitroot,
    -- initialize the language server to use the local tsserver.js lib
    init_options = {
      tsserver = {
        path = tsserverjs
      }
    }
  })
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
    -- update filetype editor settings
    vim.g.indent_guides_guide_size = 3
    -- fix formatoptions.
    --
    -- :help fo-table
    --
    -- c: auto-wrap comments
    -- q: allow formatting comments with gq (indenting)
    -- j: remove comment leaders when joining lines
    -- t: auto-wrap text past textwidth
    -- c: auto-wrap comments past textwidth
    -- r: automatically continue comments when <Enter> is pressed
    -- o: automatically continue comments when o or O are pressed
    --
    -- for some reason vim-solidity gets this wrong by default.
    --
    vim.bo.formatoptions = "cqjtro"
    -- no hard-wrapping, no vertical rule
    vim.bo.textwidth = 0
    -- don't softwrap at the edges of the window
    vim.o.wrap = false
    -- :help commentary -- relies on commentstring to format comments
    vim.bo.commentstring = "// %s"
    -- start a solidity language server
    StartSolidityLanguageServer()
    -- add local keybinding overrides
    vim.api.nvim_create_autocmd({ 'LspAttach' }, {
      pattern = { 'solidity' },
      callback = function(ev)
        -- Buffer local mappings.
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', '<space>f', function()
          vim.cmd([[ !${HOME}/.config/.foundry/bin/forge fmt % ]])
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
  local lang_server_bin = NodeFindGlobalBin('vscode-solidity-server')
  -- if the binary does not exist, error out
  if lang_server_bin == nil then
    print('cannot find vscode-solidity-server in global node binary paths')
    return
  end
  print(
    'found vscode-solidity-server binary: '
    .. vim.fn.fnamemodify(lang_server_bin, ':~:.')
  )
  -- load remappings
  -- local remappings = vim.fn.readfile(vim.fs.normalize(vim.fs.find('remappings.txt', { upward = true })[1]));
  -- actually start the language server and enable completion
  vim.lsp.start({
    name = 'vscode-solidity-server',
    cmd = { lang_server_bin, '--stdio' },
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
        -- NOTE: valid versions can be found at:
        --  https://github.com/ethereum/solc-bin/blob/gh-pages/linux-amd64/list.txt
        compileUsingRemoteVersion = "v0.8.24+commit.e11b9ed9",
        formatter = "forge"
        -- need remappings...
        -- remappings = remappings,
      },
    },
  })
end

-- run rust setup script on FileType
local au_rust = vim.api.nvim_create_augroup('rust', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_rust,
  pattern = { 'rust' },
  callback = function()
    -- update filetype editor settings
    vim.g.indent_guides_guide_size = 3
  end
})

-- python ty lsp server
local au_python = vim.api.nvim_create_augroup('python', {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = au_python,
  pattern = { 'python' },
  callback = function()
    -- start python ty lsp server
    local gitroot = GetRoot()
    vim.lsp.start({
      name = 'ty',
      cmd = { 'uv', 'run', 'ty', 'server' },
      root_dir = gitroot,
    })

    -- start python ruff lsp server
    vim.lsp.start({
      name = 'ruff',
      cmd = { 'uv', 'run', 'ruff', 'server' },
      root_dir = gitroot,
    })

    -- configure syntax-based folding with treesitter
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end
})

-- set up conform.nvim
require('conform').setup({
  default_format_opts = {
    lsp_format = "fallback",
  },
})

-- set up lsp keybindings for normal mode in any buffer with a server
vim.api.nvim_create_autocmd({ 'LspAttach' }, {
  callback = function(ev)
    -- Buffer local mappings.
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gk', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<Leader>td', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<Leader>rf', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<Leader>d', vim.diagnostic.setloclist, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<Leader>f', function()
      require('conform').format({ async = true, lsp_format = "fallback" })
      -- don't refold markdown files when they change
      if vim.bo.filetype ~= 'markdown' then
        PostFmt(ev.buf)
      end
    end, opts)
  end
})

function PostFmt(bufnr)
  vim.api.nvim_create_autocmd({ 'LspNotify' }, {
    once = true,
    callback = function(ev)
      if (bufnr == ev.buf and ev.data.method == "textDocument/didChange") then
        vim.cmd([[normal zv]])
      end
    end,
  })
end

if vim.env.KITTY_SCROLLBACK_NVIM == 'true' then
  vim.cmd.colorscheme('default')
  vim.o.signcolumn = 'no'
end

-- Helper for dynamic Zen Mode width
local function get_zen_width()
  return math.max(vim.bo.textwidth, 100)
end

-- set up zen-mode
require('zen-mode').setup({
  window = {
    width = 100,
    options = {
      number = false,
      relativenumber = false,
      signcolumn = "no",
      colorcolumn = "",
    }
  },
  on_open = function()
    -- Disable Vimade so it doesn't conflict with Zen's backdrop
    vim.cmd('VimadeDisable')
  end,
  on_close = function()
    -- Re-enable Vimade when leaving
    vim.cmd('VimadeEnable')
  end,
})

-- Toggle Zen Mode
vim.keymap.set('n', '<Leader>z', function()
  require('zen-mode').toggle({ window = { width = get_zen_width() } })
end, { silent = true })

-- Automatically open Zen Mode for plain text files once when opened
local au_zen = vim.api.nvim_create_augroup('zen_mode_auto', {})
vim.api.nvim_create_autocmd('BufEnter', {
  group = au_zen,
  pattern = { '*.txt', '*.md', '*.markdown' },
  callback = function(args)
    if vim.b[args.buf].zen_auto_opened then return end
    vim.b[args.buf].zen_auto_opened = true
    
    local function do_zen()
      -- Ensure we are still in the markdown buffer if this was deferred
      if vim.api.nvim_get_current_buf() == args.buf then
        require('zen-mode').open({ window = { width = get_zen_width() } })
      end
    end

    if vim.v.vim_did_enter == 1 then
      -- Neovim is already running, open synchronously to avoid flicker
      do_zen()
    else
      -- Neovim is starting up. VimEnter fires before the first redraw, preventing the jump.
      vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        callback = do_zen
      })
    end
  end
})
