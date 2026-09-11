--- JSONL annotation records, one file per repo and branch.
local M = {}

local records = nil
local loaded_path = nil

local function git(args)
  local out = vim.fn.systemlist('git ' .. args)
  if vim.v.shell_error ~= 0 or not out[1] or out[1] == '' then return nil end
  return out[1]
end

local function slug(s)
  return (s:gsub('[^%w%-_.]', '-'))
end

function M.root()
  return git('rev-parse --show-toplevel')
end

--- Path of the current review file, and the directory holding it.
function M.path()
  local root = M.root()
  if not root then return nil end
  local branch = git('rev-parse --abbrev-ref HEAD') or 'detached'
  local dir = vim.fs.joinpath(vim.fn.stdpath('state'), 'review', slug(vim.fn.fnamemodify(root, ':t')))
  return vim.fs.joinpath(dir, slug(branch) .. '.jsonl'), dir
end

function M.relative(abs)
  local root = M.root()
  if not root then return abs end
  return (abs:gsub('^' .. vim.pesc(root) .. '/', ''))
end

--- Blob of the file's current contents on disk, the anchor a moved line is found by.
function M.blob(abs)
  return git('hash-object ' .. vim.fn.fnameescape(abs))
end

local function read(path)
  local out = {}
  local fd = io.open(path, 'r')
  if not fd then return out end
  for line in fd:lines() do
    if line ~= '' then
      local ok, rec = pcall(vim.json.decode, line)
      if ok then out[#out + 1] = rec end
    end
  end
  fd:close()
  return out
end

function M.all()
  local path = M.path()
  if not path then return {} end
  if records == nil or loaded_path ~= path then
    records = read(path)
    loaded_path = path
  end
  return records
end

function M.reload()
  records = nil
  return M.all()
end

local function write()
  local path, dir = M.path()
  if not path then return false, 'not in a git repository' end
  vim.fn.mkdir(dir, 'p')
  local fd, err = io.open(path, 'w')
  if not fd then return false, err end
  for _, rec in ipairs(records) do
    fd:write(vim.json.encode(rec), '\n')
  end
  fd:close()
  return true
end

local function id()
  return vim.fn.sha256(tostring(vim.uv.hrtime()) .. tostring(math.random())):sub(1, 12)
end

-- Whole-list snapshots rather than inverse operations: a review is small enough that
-- correctness is worth more than the bytes, and there is no inverse to get wrong.
local undo_stack, redo_stack = {}, {}
local UNDO_LIMIT = 50

local function snapshot()
  M.all()
  undo_stack[#undo_stack + 1] = vim.deepcopy(records)
  if #undo_stack > UNDO_LIMIT then table.remove(undo_stack, 1) end
  redo_stack = {}
end

local function restore(from, to)
  if #from == 0 then return false end
  M.all()
  to[#to + 1] = vim.deepcopy(records)
  records = table.remove(from)
  return true
end

function M.add(rec)
  snapshot()
  rec.id = id()
  rec.created = os.time()
  records[#records + 1] = rec
  local ok, err = write()
  if not ok then return nil, err end
  return rec
end

function M.get(rec_id)
  for _, rec in ipairs(M.all()) do
    if rec.id == rec_id then return rec end
  end
end

function M.update(rec_id, fields)
  if not M.get(rec_id) then return nil, 'no such annotation' end
  snapshot()
  local rec = M.get(rec_id)
  for k, v in pairs(fields) do rec[k] = v end
  local ok, err = write()
  if not ok then return nil, err end
  return rec
end

function M.delete(rec_id)
  if not M.get(rec_id) then return nil, 'no such annotation' end
  snapshot()
  for i, rec in ipairs(records) do
    if rec.id == rec_id then
      table.remove(records, i)
      local ok, err = write()
      if not ok then return nil, err end
      return rec
    end
  end
  return nil, 'no such annotation'
end

function M.undo()
  if not restore(undo_stack, redo_stack) then return false, 'nothing to undo' end
  return write()
end

function M.redo()
  if not restore(redo_stack, undo_stack) then return false, 'nothing to redo' end
  return write()
end

--- Records for one file, in line order.
function M.for_path(rel)
  local found = {}
  for i, rec in ipairs(M.all()) do
    if rec.path == rel then found[#found + 1] = { rec = rec, at = i } end
  end
  -- Lua's sort is unstable and `created` only has second resolution, so ties fall back to
  -- position in the file, which is the order they were written in.
  table.sort(found, function(a, b)
    if a.rec.line ~= b.rec.line then return a.rec.line < b.rec.line end
    return a.at < b.at
  end)
  local out = {}
  for i, entry in ipairs(found) do out[i] = entry.rec end
  return out
end

return M
