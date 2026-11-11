-- ~/.config/nvim/ftplugin/go.lua
-- Go indentation only. Formatting + organize-imports on save is handled in
-- lua/lsp.lua (format_buffer) so there is exactly one BufWritePre hook.

vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
