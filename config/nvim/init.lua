-- ~/.config/nvim/init.lua
-- Bare Neovim 0.12+ config. No distro, no plugin manager plugin.
-- Plugin management: vim.pack    (:h vim.pack)
-- LSP:               vim.lsp.config / vim.lsp.enable
-- Completion:        vim.lsp.completion
-- Snippets:          vim.snippet

if vim.fn.has('nvim-0.12') == 0 then
  vim.notify(
    'This config targets Neovim 0.12+. You are on ' .. tostring(vim.version()),
    vim.log.levels.ERROR
  )
end

-- /etc/xdg/nvim salt okunur; vim.pack lockfile'i kullanici configinde tutar.
-- Ilk acilista repodaki sabitlenmis surumleri kullan, sonraki guncellemeler
-- kullanicinin yazilabilir kopyasinda kalsin.
local config_dir = vim.fn.stdpath('config')
local lockfile = config_dir .. '/nvim-pack-lock.json'
if vim.fn.filereadable(lockfile) == 0 then
  local source = debug.getinfo(1, 'S').source:sub(2)
  local bundled_lock = vim.fs.dirname(source) .. '/nvim-pack-lock.json'
  if vim.fn.filereadable(bundled_lock) == 1 then
    vim.fn.mkdir(config_dir, 'p')
    vim.fn.writefile(vim.fn.readfile(bundled_lock), lockfile)
  end
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('options')     -- vim options, autoread, filetype defaults
require('plugins')     -- vim.pack.add + per-plugin setup (must run before the rest)
require('treesitter')  -- parsers + treesitter highlighting/folds
require('lsp')         -- servers, attach keymaps, built-in completion, autoformat
require('git')         -- gitsigns, diffview + pi floating terminals
require('keymaps')     -- pickers and general keymaps
