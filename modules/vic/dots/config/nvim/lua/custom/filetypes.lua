vim.filetype.add {
  extension = {
    caddy = 'caddy',
  },
  filename = {
    ['Caddyfile'] = 'caddy',
  },
}

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = 'Caddyfile.*',
  callback = function()
    vim.bo.filetype = 'caddy'
  end,
})
