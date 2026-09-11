--- A one-line-per-item list you move the cursor through, rather than a numbered prompt.
local float = require('annotate.float')

local M = {}

local BULLET = '•'
-- not the annotation marker: in here it means "the row you are on", not "an annotation"
local POINTER = '→'
local GUTTER = '  '
local MAX_ITEM = 50

local ns = vim.api.nvim_create_namespace('annotate_select')

local function truncate(s, width)
  s = s:gsub('%s+', ' ')
  if vim.fn.strdisplaywidth(s) <= width then return s end
  return vim.fn.strcharpart(s, 0, width - 1) .. '…'
end

local function highlights()
  vim.api.nvim_set_hl(0, 'AnnotateBullet', { link = 'Comment', default = true })
  vim.api.nvim_set_hl(0, 'AnnotatePointer', { bold = true, default = true })
  vim.api.nvim_set_hl(0, 'AnnotateCurrentItem', { bold = true, default = true })
end

function M.open(items, format, on_choice)
  highlights()

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local bufnr = vim.api.nvim_create_buf(false, true)
  local lines = {}
  for i, item in ipairs(items) do
    lines[i] = GUTTER .. BULLET .. ' ' .. truncate(format(item), MAX_ITEM)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].bufhidden = 'wipe'

  local winid = float.open(bufnr, line, line, #lines)
  vim.wo[winid].cursorline = true
  vim.wo[winid].wrap = false

  -- The pointer follows the cursor, so the row you would choose is marked rather than merely lit.
  local function mark()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    local row = vim.api.nvim_win_get_cursor(winid)[1] - 1
    for i = 0, #lines - 1 do
      vim.api.nvim_buf_set_extmark(bufnr, ns, i, #GUTTER, {
        end_col = #GUTTER + #BULLET,
        hl_group = 'AnnotateBullet',
      })
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
      virt_text = { { POINTER, 'AnnotatePointer' } },
      virt_text_pos = 'overlay',
      virt_text_win_col = 0,
    })
    vim.api.nvim_buf_set_extmark(bufnr, ns, row, #GUTTER, {
      end_col = #lines[row + 1],
      hl_group = 'AnnotateCurrentItem',
      -- position and keys ride the current row: a borderless float has no footer to put them in
      virt_text = { { string.format('  %d/%d  ⏎ choose  q cancel', row + 1, #items), 'AnnotateBullet' } },
      virt_text_pos = 'eol',
    })
  end

  vim.api.nvim_create_autocmd('CursorMoved', { buffer = bufnr, callback = mark })
  mark()

  local function close()
    if vim.api.nvim_win_is_valid(winid) then vim.api.nvim_win_close(winid, true) end
  end

  vim.keymap.set('n', '<CR>', function()
    local index = vim.api.nvim_win_get_cursor(winid)[1]
    close()
    on_choice(items[index])
  end, { buffer = bufnr, nowait = true })

  for _, lhs in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', lhs, close, { buffer = bufnr, nowait = true })
  end
end

return M
