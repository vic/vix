vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = not vim.g.vscode
vim.api.nvim_create_user_command("Q", "qa!", { bang = true })

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
