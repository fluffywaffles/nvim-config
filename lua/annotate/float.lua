--- Floating windows placed in the margin beside the span they concern.
local M = {}

local MAX_WIDTH = 100
local MIN_WIDTH = 30
local GAP = 2

-- A rule down the left edge only: enough to separate it from the code, no box around it.
local BORDER = { '', '', '', '', '', '', '', '│' }

local function widest(bufnr, first, last)
  local widest_seen = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false)) do
    widest_seen = math.max(widest_seen, vim.fn.strdisplaywidth(line))
  end
  return widest_seen
end

--- Opens `bufnr` beside lines `first`..`last`, or beneath them when the margin is too narrow.
function M.open(bufnr, first, last, height)
  local parent = vim.api.nvim_get_current_win()
  local parent_buf = vim.api.nvim_win_get_buf(parent)
  local textoff = vim.fn.getwininfo(parent)[1].textoff
  local usable = vim.api.nvim_win_get_width(parent) - textoff

  local offset = widest(parent_buf, first, last) + GAP
  local margin = usable - offset - 1

  local config = {
    relative = 'win',
    win = parent,
    height = height,
    border = BORDER,
    style = 'minimal',
  }

  if margin >= MIN_WIDTH then
    config.bufpos = { first - 1, 0 }
    config.row = 0
    config.col = offset
    config.width = math.min(MAX_WIDTH, margin)
  else
    config.bufpos = { last - 1, 0 }
    config.row = 1
    config.col = 0
    config.width = math.min(MAX_WIDTH, usable - 1)
  end

  return vim.api.nvim_open_win(bufnr, true, config)
end

return M
