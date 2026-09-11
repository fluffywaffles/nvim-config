local capture = require('annotate.capture')
local export = require('annotate.export')
local render = require('annotate.render')
local store = require('annotate.store')

local M = {}

local function command(name, fn, opts)
  vim.api.nvim_create_user_command(name, fn, opts or {})
end

function M.setup()
  render.setup_highlights()

  command('Annotate', capture.add,
    { nargs = '?', range = true, bang = true, desc = 'Annotate the line or selection; ! marks it blocking' })

  command('AnnotateEdit', capture.edit, { desc = 'Edit the annotation under the cursor' })
  command('AnnotateBlocking', capture.toggle_blocking,
    { desc = 'Toggle blocking on the annotation under the cursor, or start a blocking one' })
  command('AnnotateDelete', capture.delete, { desc = 'Delete the annotation under the cursor' })
  command('AnnotateList', capture.quickfix, { desc = 'Send all annotations to the quickfix list' })

  local function step(fn, what)
    return function()
      local ok, err = fn()
      if not ok then
        vim.notify('annotate: ' .. err, vim.log.levels.WARN)
        return
      end
      render.refresh_all()
      vim.notify('annotate: ' .. what, vim.log.levels.INFO)
    end
  end

  command('AnnotateUndo', step(store.undo, 'undone'), { desc = 'Undo the last annotation change' })
  command('AnnotateRedo', step(store.redo, 'redone'), { desc = 'Redo the last undone annotation change' })

  command('AnnotateToggle', function()
    vim.notify('annotate: notes ' .. (render.toggle() and 'shown' or 'hidden'), vim.log.levels.INFO)
  end, { desc = 'Show or hide the note text, leaving the signs' })

  command('AnnotateExport', function()
    local path, err = export.markdown()
    if not path then
      vim.notify('annotate: ' .. err, vim.log.levels.WARN)
      return
    end
    vim.notify(path, vim.log.levels.INFO)
  end, { desc = 'Write the annotations as markdown and report the path' })

  command('AnnotateWhere', function()
    local path = store.path()
    vim.notify(path or 'not in a git repository', vim.log.levels.INFO)
  end, { desc = 'Report the path of the current review file' })

  local group = vim.api.nvim_create_augroup('annotate', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
    group = group,
    callback = function(args) render.refresh(args.buf) end,
  })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = render.setup_highlights,
  })
end

return M
