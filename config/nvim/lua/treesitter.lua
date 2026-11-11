-- ~/.config/nvim/lua/treesitter.lua
-- nvim-treesitter `main` branch (requires Neovim >= 0.12, tree-sitter-cli, a C compiler).
-- The plugin only supplies parsers + queries; Neovim does the highlighting.

require('nvim-treesitter').setup({})

-- Async. Run :checkhealth nvim-treesitter if a parser fails to build.
require('nvim-treesitter').install({
  -- your stack
  'go', 'gomod', 'gosum', 'gotmpl', 'helm', 'rust',
  'javascript', 'tsx', 'typescript', 'html', 'css',
  'json', 'yaml', 'toml', 'dockerfile', 'sql',
  -- the config itself + shell/CI
  'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'bash', 'gitignore',
})

-- Highlighting is NOT automatic. 0.12 bundles parsers for c/lua/markdown/query/vim/vimdoc.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true }),
  callback = function()
    local ok = pcall(vim.treesitter.start)
    if not ok then return end
    -- treesitter folds, opened by default
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldlevel = 99
  end,
})
