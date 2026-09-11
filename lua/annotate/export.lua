--- Markdown for an agent to read. A pure function of the store.
local store = require('annotate.store')

local M = {}

local function render_markdown()
  local by_path = {}
  local order = {}
  for _, rec in ipairs(store.all()) do
    if not by_path[rec.path] then
      by_path[rec.path] = {}
      order[#order + 1] = rec.path
    end
    table.insert(by_path[rec.path], rec)
  end
  table.sort(order)

  local out = {}
  for _, path in ipairs(order) do
    local recs = by_path[path]
    table.sort(recs, function(a, b) return a.line < b.line end)
    out[#out + 1] = '## ' .. path
    out[#out + 1] = ''
    for _, rec in ipairs(recs) do
      local where = rec.end_line and (rec.line .. '-' .. rec.end_line) or tostring(rec.line)
      out[#out + 1] = string.format('- **%s:%s**%s %s',
        path, where, rec.blocking and ' *(blocking)*' or '',
        -- continuation lines are indented into the bullet, so a multi-line note stays one item
        (rec.note:gsub('\n([^\n])', '\n  %1')))
      for _, line in ipairs(vim.split(rec.text, '\n', { plain = true })) do
        out[#out + 1] = '  > ' .. line
      end
      out[#out + 1] = ''
    end
  end
  return out
end

--- Writes the markdown beside the store and returns its path.
function M.markdown()
  local jsonl = store.path()
  if not jsonl then
    return nil, 'not in a git repository'
  end
  if #store.all() == 0 then
    return nil, 'no annotations'
  end
  local path = (jsonl:gsub('%.jsonl$', '.md'))
  local fd, err = io.open(path, 'w')
  if not fd then return nil, err end
  fd:write(table.concat(render_markdown(), '\n'), '\n')
  fd:close()
  return path
end

return M
