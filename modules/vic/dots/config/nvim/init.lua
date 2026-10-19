if vim.g.vscode then
	-- VSCode extension
else
	require("prelude")
	require("lazy-bootstrap")
	require("lazy").setup("plugins")
end
