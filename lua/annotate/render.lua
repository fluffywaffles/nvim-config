--- Draws annotations as gutter signs and virtual text. Shape only, never colour.
local store = require('annotate.store')

local M = {}

local ns = vim.api.nvim_create_namespace('annotate')

-- Not bars, so they do not read as gitsigns' signs, and without the fine horizontal
-- strokes that smear in the italics these inherit from Comment.
local SIGN = { note = '∗', blocking = '×' }

-- Only for the note text, where a bar has nothing to collide with.
local RULE = '│'

-- widest a rendered note line gets, indent and marker included
local MAX_WIDTH = 74

--- Underline styles rather than colours, so a duotone theme can still tell these apart.
function M.setup_highlights()
  vim.api.nvim_set_hl(0, 'AnnotateVirtText', { link = 'Comment', default = true })
  vim.api.nvim_set_hl(0, 'AnnotateSign', { link = 'Comment', default = true })
  vim.api.nvim_set_hl(0, 'AnnotateBlockingSign', { link = 'Comment', default = true })
  vim.api.nvim_set_hl(0, 'AnnotateRange', { underdotted = true, default = true })
  vim.api.nvim_set_hl(0, 'AnnotateBlockingRange', { undercurl = true, default = true })
end

function M.marker(blocking)
  return blocking and SIGN.blocking or SIGN.note
end

local show_notes = true

function M.toggle()
  show_notes = not show_notes
  M.refresh_all()
  return show_notes
end

local function wrap(text, width)
  local out = {}
  for _, paragraph in ipairs(vim.split(text, '\n', { plain = true })) do
    local line = ''
    for word in paragraph:gmatch('%S+') do
      if line == '' then
        line = word
      elseif #line + #word + 1 <= width then
        line = line .. ' ' .. word
      else
        out[#out + 1] = line
        line = word
      end
    end
    out[#out + 1] = line
  end
  return out
end

--- The note as virt_lines beneath its anchor, wrapped by hand since virt_lines does not.
--- Each note opens with its own mark and runs down a rule, so two stacked annotations
--- separate at the mark rather than needing anything to close them.
local function note_lines(rec, indent)
  local width = math.max(math.min(MAX_WIDTH, vim.fn.winwidth(0) - 8) - #indent - 2, 20)
  local out = {}
  for i, line in ipairs(wrap(rec.note, width)) do
    local mark = i == 1 and (rec.blocking and SIGN.blocking or SIGN.note) or RULE
    out[#out + 1] = { { indent .. mark .. ' ' .. line, 'AnnotateVirtText' } }
  end
  return out
end

function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then return end

  local total = vim.api.nvim_buf_line_count(bufnr)
  local notes_by_row = {}
  local rows = {}

  for _, rec in ipairs(store.for_path(store.relative(name))) do
    if rec.line >= 1 and rec.line <= total then
      local blocking = rec.blocking and true or false
      local last = math.min(rec.end_line or rec.line, total)
      local anchor = vim.api.nvim_buf_get_lines(bufnr, last - 1, last, false)[1] or ''
      local opening = vim.api.nvim_buf_get_lines(bufnr, rec.line - 1, rec.line, false)[1] or ''
      vim.api.nvim_buf_set_extmark(bufnr, ns, rec.line - 1, math.min(rec.col or 0, #opening), {
        end_row = last - 1,
        -- an explicit end: without it a single-line span would be zero-width
        end_col = math.min(rec.end_col or #anchor, #anchor),
        sign_text = blocking and SIGN.blocking or SIGN.note,
        sign_hl_group = blocking and 'AnnotateBlockingSign' or 'AnnotateSign',
        hl_group = blocking and 'AnnotateBlockingRange' or 'AnnotateRange',
        priority = 20,
      })

      if show_notes then
        if not notes_by_row[last] then
          notes_by_row[last] = {}
          rows[#rows + 1] = last
        end
        vim.list_extend(notes_by_row[last], note_lines(rec, anchor:match('^%s*') or ''))
      end
    end
  end

  -- One extmark per anchor row, because several on the same row render in reverse order.
  -- virt_lines also hang below the extmark's start row, so this sits on the range's last line.
  for _, row in ipairs(rows) do
    vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, 0, {
      virt_lines = notes_by_row[row],
      priority = 20,
    })
  end
end

function M.refresh_all()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then M.refresh(bufnr) end
  end
end

local function span(rec)
  return (rec.end_line or rec.line) - rec.line
end

--- Every annotation whose range covers the cursor, innermost first.
function M.all_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then return {} end
  local out = {}
  for _, rec in ipairs(store.for_path(store.relative(name))) do
    if line >= rec.line and line <= (rec.end_line or rec.line) then
      out[#out + 1] = rec
    end
  end
  table.sort(out, function(a, b) return span(a) < span(b) end)
  return out
end

function M.at_cursor()
  return M.all_at_cursor()[1]
end

return M
