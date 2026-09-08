local function bootstrap(paq_url, paq_branch)
  local install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  local is_installed = vim.fn.empty(vim.fn.glob(install_path)) == 0
  if not is_installed then
    print('installing paq.nvim into ' .. install_path .. '...')
    local clone_cmd = { 'git', 'clone', '--depth=1' }
    if paq_branch then
      table.insert(clone_cmd, '-b')
      table.insert(clone_cmd, paq_branch)
    end
    table.insert(clone_cmd, paq_url)
    table.insert(clone_cmd, install_path)
    vim.fn.system(clone_cmd)
    io.write(' done.\n')
  end
  -- add paq to the runtimepath
  vim.cmd.packadd('paq-nvim')
  -- return the paq module after requiring it
  return require('paq')
end

return {
  bootstrap = bootstrap,
}
