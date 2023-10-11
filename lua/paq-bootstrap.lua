local function bootstrap(paq_url)
  local install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  local is_installed = vim.fn.empty(vim.fn.glob(install_path)) == 0
  if not is_installed then
    print('installing paq.nvim into ' .. install_path .. '...')
    vim.fn.system { 'git', 'clone', '--depth=1', paq_url, install_path }
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
