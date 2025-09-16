vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = not vim.g.vscode
vim.api.nvim_create_user_command("Q", "qa!", { bang = true })
