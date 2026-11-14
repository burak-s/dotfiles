-- ~/.config/nvim/lua/plugins.lua
-- Plugin manager is built in: vim.pack (:h vim.pack).
-- Lockfile: ~/.config/nvim/nvim-pack-lock.json
-- Update:   :lua vim.pack.update()   -> review the diff, :w to accept, :q to discard
-- After the very first run: :restart

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  { src = gh('neovim/nvim-lspconfig') },            -- server config data for vim.lsp.config
  { src = gh('mason-org/mason.nvim') },             -- installs the server binaries
  { src = gh('mason-org/mason-lspconfig.nvim') },   -- glue
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  { src = gh('lewis6991/gitsigns.nvim') },
  { src = gh('sindrets/diffview.nvim') },
  { src = gh('ibhagwan/fzf-lua') },
  { src = gh('nvim-tree/nvim-tree.lua') },    -- dosya agaci + git durum renkleri
  { src = gh('echasnovski/mini.nvim') },
  { src = gh('olimorris/onedarkpro.nvim') }, -- tema: Zed'deki One Dark (Atom One Dark)
})

-- tema: Ghostty ile ayni.
-- Ghostty tarafi: theme=dark:Atom One Dark,light:Atom One Light -> masaustu koyu
-- oldugu icin terminal 'Atom One Dark' gosteriyor, arka plan #282c34 (Zed One Dark).
-- Masaustunu acik temaya alirsan iki satir degisir: buradaki colorscheme + ghostty config.
vim.o.background = 'dark'

-- Zed'in 'One Dark' temasinin birebir paleti (zed-industries/zed assets/themes/one/one.json).
-- onedarkpro'nun default'u Atom One Dark; Zedinki daha desature, beyaz agirlikli.
-- Fark: Zed degiskenleri BEYAZ (#acb2be), onedarkpro ise kirmizi basiyor.
-- @variable ve @module en onemli override'lar; kalanlari palet override'i hallediyor.
require('onedarkpro').setup({
  colors = { onedark = {
    fg = '#acb2be', white = '#acb2be',      -- Zed primary/variable/punctuation
    red = '#d07277',                          -- property/parameter/title
    green = '#a1c181',                        -- string
    yellow = '#dfc184',                       -- constant/selector
    blue = '#73ade9',                         -- function
    purple = '#b477cf',                       -- keyword
    orange = '#bf956a',                       -- number/boolean/variable.special
    cyan = '#6eb4bf',                         -- type/operator/enum
    comment = '#5d636f',                      -- comment (doc yorumlari icin ayrica #878e98)
    gray = '#878e98',
    -- onedarkpro git renklerini sign column icin karartiyor (darken 30-35%);
    -- gutter isaretleri ince '▎' ama parlak renk yine iyi
    git_add = '#a1c181', git_change = '#73ade9', git_delete = '#d07277',
  } },
  highlights = {
    -- onedarkpro'da degiskenler kirmizi; Zed'de beyaz
    ['@variable'] = { fg = '#acb2be' },
    ['@variable.builtin'] = { fg = '#bf956a' },    -- Zed: variable.special (this, self)
    ['@variable.parameter'] = { fg = '#d07277' },
    ['@variable.member'] = { fg = '#d07277' },
    ['@property'] = { fg = '#d07277' },
    ['@module'] = { fg = '#dce0e5' },              -- Zed: namespace (nerdeyse beyaz)
    ['@function.builtin'] = { fg = '#73ade9' },    -- Zed'de builtin fonksiyonlar da mavi
    ['@constructor'] = { fg = '#73ade9' },
    Type = { fg = '#6eb4bf' },                     -- Zed: type teal (@type buna link)
    ['@constant'] = { fg = '#dfc184' },
    ['@constant.builtin'] = { fg = '#bf956a' },    -- Zed: boolean (true/false/nil)
    ['@attribute'] = { fg = '#74ade8' },
    ['@tag'] = { fg = '#74ade8' },
    ['@label'] = { fg = '#74ade8' },
    ['@string.escape'] = { fg = '#878e98' },
    ['@string.regex'] = { fg = '#bf956a' },
    ['@string.special'] = { fg = '#bf956a' },
  },
  styles = { comments = 'italic' },
  filetypes = { -- ft-ozel renk gruplarini kapat: kod dili fark etmeksizin ayni palet
    c = false, comment = false, go = false, html = false, java = false,
    javascript = false, json = false, latex = false, lua = false, markdown = false,
    php = false, python = false, ruby = false, rust = false, scss = false,
    toml = false, typescript = false, typescriptreact = false, vue = false,
    xml = false, yaml = false,
  },
})

-- pcall: ilk calistirmada eklenti henuz diske inmemis olabilir
pcall(vim.cmd.colorscheme, 'onedark')

-- Language servers for THIS stack and nothing more.
--   gopls   -> the ~40 Go services
--   biome   -> every JSX microfrontend (uses the repo's own biome binary)
--   ts_ls   -> only the 3 repos that actually have TypeScript
--   lua_ls  -> you are now editing Lua
--   yamlls/helm_ls -> deployment/, Chart.yaml
--   tailwindcss -> the mf-* Tailwind 4 frontends
-- NixOS'ta indirilen genel Linux binary'leri yerine Nix paketlerini kullan.
local on_nixos = vim.fn.executable('nixos-version') == 1
require('mason').setup({ PATH = on_nixos and 'skip' or 'prepend' })
-- NOTE: mason.nvim has no `ensure_installed` option; LSP servers are declared
-- through mason-lspconfig below. For a standalone tool (formatter/linter) use
-- `:MasonInstall <name>`, e.g. `:MasonInstall stylua` if you ever want Lua
-- formatting -- nothing in this config calls it today.
require('mason-lspconfig').setup({
  automatic_enable = false, -- enabled explicitly in lsp.lua
  -- Names must be lspconfig server names (mason-lspconfig resolves them to
  -- packages via the registry's neovim.lspconfig field).
  ensure_installed = on_nixos and {} or {
    'gopls',
    'rust_analyzer',
    'biome',
    'ts_ls',
    'lua_ls',
    'jsonls',
    'yamlls',
    'helm_ls',
    'bashls',
    'dockerls',
    'docker_compose_language_service',
    'tailwindcss',
  },
})

-- mini.nvim: six tiny modules instead of six plugins.
require('mini.ai').setup()         -- a/i textobjects (function, class, argument...)
require('mini.pairs').setup()      -- bracket/quote pairs
require('mini.surround').setup({
  mappings = {
    add = '<leader>sa', delete = '<leader>sd', replace = '<leader>sr',
    find = '<leader>sf', find_left = '<leader>sF', highlight = '<leader>sh',
    update_n_lines = '<leader>sn',
  },
})
-- mini.comment YOK: Neovim 0.12'de gc/gcc yerlesik (vim/_core/defaults.lua)
require('mini.icons').setup()
require('mini.move').setup()       -- Alt+h/j/k/l: satiri / gorsel secimi tasi
require('mini.bufremove').setup()  -- buffer kapatirken pencere duzenini bozmaz
require('mini.notify').setup()     -- vim.notify mesajlari icin duzgun bildirim penceresi
-- nvim-web-devicons bekleyen eklentiler icin ikon saglayici (fzf-lua picker'lari
-- dosya ikonlarini bundan aliyor).
MiniIcons.mock_nvim_web_devicons()
-- Durum cubugu: varsayilan mini.statusline sag tarafta satir/kolon, arama
-- sayaci ve dosya tipi basiyor. Sag tarafi tamamen kaldirdik; solda kalani var.
require('mini.statusline').setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
      })
    end,
  },
})

require('fzf-lua').setup({ 'default-title' })

-- dosya agaci: netrw yerine nvim-tree. Git durumu ikonlarda + dosya adini
-- boyan: degistirilmis (yesil "*" degil, M), staged, untracked, ignored.
-- Devicons mini.icons'tan geliyor (yukarida mock_nvim_web_devicons var).
require('nvim-tree').setup({
  disable_netrw = true,
  hijack_netrw = true,
  git = { enable = true, timeout = 500 },
  modified = { enable = true },       -- kaydedilmemis buffer degisiklikleri
  filters = { dotfiles = false, git_ignored = false },
  diagnostics = { enable = false },   -- agacta H/W linter harfleri olmasin; diagnostics buffer'da zaten var
  renderer = {
    highlight_git = 'name',           -- dosya adini git durumuna gore boya
    highlight_modified = 'name',
    highlight_opened_files = 'name',
    indent_markers = { enable = true }, -- agac dallari cizgiyle belli olsun
  },
  actions = {
    open_file = {
      quit_on_open = true,            -- dosya secince agac kapansin (eski <leader>e davranişi)
      resize_window = true,
    },
  },
})

-- ------------------------------------------------------- oturum geri yukleme
-- mini.sessions'in kendi 'autoread'ini bilerek kullanmiyoruz: read(isim=nil)
-- "en son degistirilen oturumu" acar (kaynak: get_latest() mtime karsilastirir,
-- detected tablosunun anahtari sadece dosya adidir) - cwd'ye gore esleme YOK.
-- 15 repo'da bu yanlis repo'nun dosyalarini acardi. Bunun yerine oturum adini
-- cwd'den turetirip o adla okuyoruz/yaziyoruz.
require('mini.sessions').setup({
  autoread = false, -- sebep: yukarisi
  autowrite = false, -- asagida ilk oturumu da olusturan otomatik kayit var
  file = '', -- yerel 'Session.vim' kullanma (repo icinde dosya olusmasin)
  directory = vim.fn.stdpath('data') .. '/session',
})

-- cwd -> oturum adi ('/' dosya adinda olamaz, '%' yapiyoruz)
local function session_name()
  return (vim.fn.getcwd():gsub('/', '%%'))
end

-- nvim'i argumansiz actiginda o dizinin oturumu varsa geri yukle
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  desc = 'Bu dizinin oturumunu geri yukle',
  callback = function()
    if vim.fn.argc() > 0 then return end -- dosya argumaniyla acildiysa dokunma
    local name = session_name()
    if MiniSessions.detected[name] then MiniSessions.read(name) end
  end,
})

-- Terminal uygulamalarini yeniden baslatma; sadece editor duzenini sakla.
vim.opt.sessionoptions:remove('terminal')
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('UserSessionSave', { clear = true }),
  desc = 'Bu dizinin oturumunu otomatik kaydet (ilk kullanim dahil)',
  callback = function()
    -- Headless kontroller / script calistirmalari kullanici oturumunu ezmesin.
    if #vim.api.nvim_list_uis() == 0 then return end
    MiniSessions.write(session_name(), { force = true })
  end,
})

vim.keymap.set('n', '<leader>qs', function()
  MiniSessions.write(session_name(), { force = true })
end, { desc = 'Oturumu kaydet (bu dizin)' })

vim.keymap.set('n', '<leader>ql', function()
  local name = session_name()
  if not MiniSessions.detected[name] then
    vim.notify('Bu dizinin oturumu yok: ' .. name)
    return
  end
  MiniSessions.read(name)
end, { desc = 'Oturumu yukle (bu dizin)' })

vim.keymap.set('n', '<leader>qd', function()
  local name = session_name()
  if not MiniSessions.detected[name] then return end
  MiniSessions.delete(name, { force = true })
end, { desc = 'Oturumu sil (bu dizin)' })

-- NOTE: no formatter plugin (conform) and no completion plugin (cmp/blink).
-- gopls and biome both implement textDocument/formatting, and 0.12 ships
-- vim.lsp.completion + vim.snippet. See lsp.lua.
