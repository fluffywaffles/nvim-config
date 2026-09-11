--- A floating markdown buffer for writing a note, since virtual text cannot be edited or selected.
local float = require('annotate.float')

local M = {}

--- Opens `text` in a float under `line`. `:w` commits it through `on_write`, `:q!` discards.
function M.open(opts)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(opts.text or '', '\n', { plain = true })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].buftype = 'acwrite'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].filetype = 'markdown'
  vim.api.nvim_buf_set_name(bufnr, opts.name)
  vim.bo[bufnr].modified = false

  local height = math.min(math.max(#lines, 5), 15)
  local winid = float.open(bufnr, opts.first, opts.last, height)
  vim.wo[winid].wrap = true
  vim.wo[winid].linebreak = true

  -- The window is left open deliberately: closing it here means :x runs its quit
  -- against whatever window came next, which exits the editor when there is none.
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = bufnr,
    callback = function()
      local note = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
      note = note:gsub('^%s+', ''):gsub('%s+$', '')
      vim.bo[bufnr].modified = false
      opts.on_write(note)
    end,
  })

  if #lines == 1 and lines[1] == '' then vim.cmd('startinsert') end
end

return M
