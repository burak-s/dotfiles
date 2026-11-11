-- ~/.config/nvim/lua/keymaps.lua
--
-- KURAL: Vim/Neovim'in varsayılan olarak atadığı hiçbir tuş ezilmez.
-- Eklenen her şey <Space> (leader) altında; varsayılanlarla çakışamaz.
-- İstisna yok: gd, K, H, L, J, n, N, ]d, [d, <C-l>, <C-s>, <Esc> hepsi varsayılan.
--
-- Neovim 0.12'nin hazır verdikleri (map gerekmez, :h defaults):
--   grn rename      gra code action   grr references    gri implementation
--   grt type def    grx codelens      gO  semboller     gx  dosya/URL aç
--   ]d [d ]D [D diagnostic   <C-W>d diagnostic float
--   ]b [b buffer    gc gcc yorum      gd yerel tanım    gD global tanım
--   K keywordprg    <C-w>h/j/k/l pencere   <Tab> snippet   <C-l> redraw

local map = vim.keymap.set
local fzf = function(fn)
  return function()
    local root = vim.fs.root(0, { '.git' }) or vim.fn.getcwd()
    require('fzf-lua')[fn]({ cwd = root })
  end
end

-- ---------------------------------------------------------------- pickers
map('n', '<leader><space>', fzf('files'), { desc = 'Dosyalar' })
map('n', '<leader>ff', fzf('files'), { desc = 'Dosyalar' })
map('n', '<leader>fg', fzf('live_grep'), { desc = 'Grep' })
map('n', '<leader>fw', fzf('grep_cword'), { desc = 'Imlecteki kelimeyi grep' })
map('n', '<leader>fb', fzf('buffers'), { desc = 'Bufferlar' })
map('n', '<leader>fr', fzf('oldfiles'), { desc = 'Son dosyalar' })
map('n', '<leader>fR', fzf('resume'), { desc = 'Son picker' })
map('n', '<leader>fs', fzf('git_status'), { desc = 'Degisen dosyalar (git)' })
map('n', '<leader>fc', fzf('git_commits'), { desc = 'Commitler' })
map('n', '<leader>fd', fzf('diagnostics_document'), { desc = 'Diagnostic (buffer)' })
map('n', '<leader>fD', fzf('diagnostics_workspace'), { desc = 'Diagnostic (repo)' })
map('n', '<leader>fh', fzf('help_tags'), { desc = 'Help' })
map('n', '<leader>dk', fzf('keymaps'), { desc = 'Tum keymapleri ara' })

-- --------------------------------------------------------- sistem panosu
-- yy/p Vim register'larini kullanir; sistem panosu sadece bu tuslarla degisir.
map({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'Sistem panosuna kopyala (hareket/secim)' })
map('n', '<leader>Y', '"+yy', { desc = 'Satiri sistem panosuna kopyala' })
map('n', '<leader>p', '"+p', { desc = 'Sistem panosundan yapistir' })
-- Secimin yerine yapistirirken eski secim sistem panosunu ezmesin.
map('x', '<leader>p', '"_d"+P', { desc = 'Secimi sistem panosuyla degistir' })

-- ------------------------------------------------------------- dosyalar
-- Yerlesik dosya agaci (netrw): sol panelde acar/kapatir. Tek pencere, ust uste binmez.
map('n', '<leader>e', function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'netrw' then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  vim.cmd('Lexplore')
end, { desc = 'Dosya agaci (netrw) ac/kapa' })
map('n', '<leader>E', '<Cmd>Explore<CR>', { desc = 'Dosya agaci (bu pencerede)' })

-- ----------------------------------------------------------------- buffer
-- mini.bufremove: buffer'i kapatir ama pencere duzenini bozmaz (bdelete gibi
-- pencereleri kaydirmaz). bD = kaydedilmemis degisiklikleri zorla at.
map('n', '<leader>bd', function() require('mini.bufremove').delete(0, false) end, { desc = 'Buffer kapat' })
map('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { desc = 'Buffer kapat (zorla)' })

-- --------------------------------------------------------- yaz / kaydet
map('n', '<leader>ww', '<Cmd>write<CR>', { desc = 'Kaydet' })
map('n', '<leader>wq', '<Cmd>wq<CR>', { desc = 'Kaydet ve cik' })
map('n', '<leader>qq', '<Cmd>qa<CR>', { desc = 'Hepsini kapat' })

-- ------------------------------------------------------- meta / bakim
map('n', '<leader>li', function()
  local names = vim.iter(vim.pack.get()):map(function(p) return p.spec.name end):totable()
  table.sort(names)
  vim.notify('vim.pack (' .. #names .. '):\n' .. table.concat(names, '\n'))
end, { desc = 'Kurulu pluginler' })

map('n', '<leader>lL', function()
  vim.cmd.edit(vim.fn.stdpath('config') .. '/nvim-pack-lock.json')
end, { desc = 'Plugin lockfile' })

map('n', '<leader>ll', function()
  vim.cmd.edit(vim.fn.stdpath('log') .. '/nvim-pack.log')
end, { desc = 'Plugin update log' })

map('n', '<leader>lm', '<Cmd>Mason<CR>', { desc = 'Mason (sunucular)' })
map('n', '<leader>lh', '<Cmd>checkhealth<CR>', { desc = 'checkhealth' })
map('n', '<leader>lu', function() vim.pack.update() end, { desc = 'Pluginleri guncelle' })
map('n', '<leader>ld', '<Cmd>lua vim.diagnostic.setloclist()<CR>', { desc = 'Diagnosticleri listeye al' })
