local edit = require('annotate.edit')
local render = require('annotate.render')
local select = require('annotate.select')
local store = require('annotate.store')

local M = {}

local function buffer_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then return nil end
  return vim.fn.fnamemodify(name, ':p')
end

--- The exact span the command covers: the visual selection's columns when it came from
--- charwise visual mode, whole lines otherwise. Columns are 0-indexed, end exclusive.
local function span(opts)
  local first, last = opts.line1, opts.line2
  local from, to = vim.fn.getpos("'<"), vim.fn.getpos("'>")
  if opts.range == 2 and vim.fn.visualmode() == 'v' and from[2] == first and to[2] == last then
    local last_len = #(vim.fn.getline(last))
    return first, from[3] - 1, last, math.min(to[3], last_len)
  end
  return first, 0, last, #(vim.fn.getline(last))
end

local function text_in(first, col, last, end_col)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  if #lines == 0 then return '' end
  lines[#lines] = lines[#lines]:sub(1, end_col)
  lines[1] = lines[1]:sub(col + 1)
  return table.concat(lines, '\n')
end

--- Runs `action` on the annotation under the cursor, asking which when several overlap.
--- `when_none` takes over if there is nothing here, otherwise that is a warning.
local function pick(action, when_none)
  local recs = render.all_at_cursor()
  if #recs == 0 then
    if when_none then return when_none() end
    vim.notify('annotate: no annotation here', vim.log.levels.WARN)
    return
  end
  if #recs == 1 then
    action(recs[1])
    return
  end
  select.open(recs, function(rec)
    return (rec.blocking and (render.marker(true) .. ' ') or '') .. rec.note
  end, function(choice)
    if choice then action(choice) end
  end)
end

function M.add(opts)
  local abs = buffer_path()
  if not abs then
    vim.notify('annotate: buffer has no file', vim.log.levels.ERROR)
    return
  end

  local first, col, last, end_col = span(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local created = nil

  local function commit(text)
    if not text or text == '' then return end
    if created then
      store.update(created.id, { note = text })
      render.refresh(bufnr)
      return
    end
    local rec, err = store.add({
      path = store.relative(abs),
      line = first,
      end_line = last ~= first and last or nil,
      col = col,
      end_col = end_col,
      text = text_in(first, col, last, end_col),
      blob = store.blob(abs),
      blocking = opts.bang and true or false,
      note = text,
    })
    if not rec then
      vim.notify('annotate: ' .. (err or 'could not write'), vim.log.levels.ERROR)
      return
    end
    created = rec
    render.refresh(bufnr)
  end

  if opts.args and opts.args ~= '' then
    commit(opts.args)
  else
    edit.open({
      text = '',
      name = 'annotate://new',
      first = first,
      last = last,
      on_write = commit,
    })
  end
end

function M.edit()
  local bufnr = vim.api.nvim_get_current_buf()
  pick(function(rec)
    edit.open({
      text = rec.note,
      name = 'annotate://' .. rec.path .. ':' .. rec.line,
      first = rec.line,
      last = rec.end_line or rec.line,
      on_write = function(text)
        if text == '' then return end
        store.update(rec.id, { note = text })
        render.refresh(bufnr)
      end,
    })
  end)
end

function M.toggle_blocking()
  pick(function(rec)
    store.update(rec.id, { blocking = not rec.blocking })
    render.refresh()
  end, function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    M.add({ line1 = line, line2 = line, range = 0, bang = true, args = '' })
  end)
end

function M.delete()
  pick(function(rec)
    store.delete(rec.id)
    render.refresh()
  end)
end

function M.quickfix()
  local root = store.root()
  local items = {}
  for _, rec in ipairs(store.all()) do
    items[#items + 1] = {
      filename = root and vim.fs.joinpath(root, rec.path) or rec.path,
      lnum = rec.line,
      text = (rec.blocking and '[blocking] ' or '') .. (rec.note:gsub('\n', ' ')),
    }
  end
  if #items == 0 then
    vim.notify('annotate: no annotations', vim.log.levels.INFO)
    return
  end
  vim.fn.setqflist({}, ' ', { title = 'annotations', items = items })
  vim.cmd('copen')
  local qf = vim.fn.getqflist({ winid = 0 }).winid
  if qf ~= 0 then vim.api.nvim_set_current_win(qf) end
end

return M
