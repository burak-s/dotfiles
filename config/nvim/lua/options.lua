-- ~/.config/nvim/lua/options.lua
local o = vim.opt

-- look
o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.termguicolors = true
o.laststatus = 3
o.showmode = false
o.fillchars = { eob = ' ' }
-- Gorunmez karakter isaretleri KAPALI (tab -> "» ", satir sonu bosluk -> "·").
-- Ara sira bakmak istersen:  :set list    (kapatmak: :set nolist)
-- listchars duruyor ki :set list yaptiginda yine ayni isaretler ciksin.
o.list = false
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- behaviour
o.mouse = 'a'
-- Silme/degistirme sistem panosunu ezmesin; Space y/p ile acikca kullan.
o.clipboard = ''
o.ignorecase = true
o.smartcase = true
o.inccommand = 'split'                   -- live preview of :s/// - big for refactors
o.splitright = true
o.splitbelow = true
o.updatetime = 250
o.timeoutlen = 1000
o.swapfile = false
o.confirm = true

-- indentation defaults (Go and JS/TS get their own below)
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2

-- persistent undo: survives restarts, per repo
local undodir = vim.fn.stdpath('state') .. '/undo'
vim.fn.mkdir(undodir, 'p')
o.undodir = undodir
o.undofile = true

-- completion menu: <C-n>/<C-p> to navigate, <C-y> (or <CR>) to accept
o.completeopt = { 'menuone', 'noselect', 'popup' }
o.pumheight = 12

-- Yerlesik dosya agaci: netrw. Neovim'in kendi parcasi, eklenti degil.
-- Acmak icin <Space>e (sol panel) veya :Explore / :Vexplore / :Sex
vim.g.netrw_banner = 0        -- ustteki bilgi/reklam satirini kapat
vim.g.netrw_liststyle = 3     -- 3 = agac gorunumu
vim.g.netrw_winsize = 25      -- sol panel genisligi (yuzde)
vim.g.netrw_browse_split = 4  -- dosya onceki (sag) pencerede acilsin, agac yerinde kalsin

-- Normal mod blok, insert modu cizgi: hangi modda oldugun belli olsun.
vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'

-- Dosya tipi kayitlari: bazi LSP'ler bu filetype'lari bekliyor ama Neovim onlari
-- tanimiyor; :checkhealth'teki "Unknown filetype" uyarilari buradan geliyordu.
-- yamlls ayni tipleri destekledigi icin yaml sema dogrulamasi kaybolmuyor.
-- Kullanici pattern'leri extension'dan ONCE kontrol edilir (:h vim.filetype.match),
-- o yuzden chart icindeki .tpl dosyalari 'helm', tek basina .tpl 'gotmpl' olur.
-- Kullanici pattern'lerini Neovim KENDISI ^...$ ile sarar
-- (runtime/lua/vim/filetype.lua: "User patterns are assumed to be implicitly anchored").
-- Bu yuzden buraya '$' EKLEME: pattern '...$$' olur ve hicbir dosyayla eslesmez.
vim.filetype.add({
  pattern = {
    ['docker%-compose[^/]*%.ya?ml'] = 'yaml.docker-compose',
    ['compose[^/]*%.ya?ml'] = 'yaml.docker-compose',
    ['.*/templates/.*%.ya?ml'] = 'helm',       -- helm chart sablonlari
    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*/values%.ya?ml'] = 'yaml.helm-values', -- helm values dosyalari
    ['[^/]*%.gitlab%-ci%.ya?ml'] = 'yaml.gitlab', -- .gitlab-ci.yml / x.gitlab-ci.yml
    ['gitlab%-ci%.ya?ml'] = 'yaml.gitlab',
  },
  extension = {
    tpl = 'gotmpl', -- Go template dosyalari
    tmpl = 'gotmpl',
    gotmpl = 'gotmpl',
  },
})

-- Reload files changed on disk. Without this you will review stale buffers
-- while pi edits files underneath you, and clobber agent work on :w.
-- Depends on tmux `set -g focus-events on`.
o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('AutoReadReload', { clear = true }),
  callback = function()
    -- 'c' = currently in a command-line window; checktime there is harmless but noisy
    if vim.fn.mode() ~= 'c' then vim.cmd.checktime() end
  end,
})

-- Your mf-* repos run Biome with "indentStyle": "tab", so tabs it is.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('UserFiletypeIndent', { clear = true }),
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json', 'jsonc' },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- YAML/Helm girintisinde tab gecersiz; dotted YAML filetype'lari da dahil.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('UserYamlIndent', { clear = true }),
  pattern = { 'yaml', 'yaml.*', 'helm' },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- yank highlight
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('UserHighlightYank', { clear = true }),
  callback = function() vim.hl.on_yank({ timeout = 120 }) end,
})

-- No trailing whitespace autostrip on save: your formatters own that.
