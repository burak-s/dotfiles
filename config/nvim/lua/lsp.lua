-- ~/.config/nvim/lua/lsp.lua
-- Neovim 0.12 native LSP: vim.lsp.config() + vim.lsp.enable().
-- nvim-lspconfig supplies the per-server defaults; we only override what matters.

-- ---------------------------------------------------------------- servers

-- Go: run gofumpt, staticcheck, and don't crawl node_modules/dist/vendor.
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      analyses = { unusedparams = true, shadow = true, unusedwrite = true },
      directoryFilters = { '-.git', '-node_modules', '-dist', '-vendor' },
      codelenses = { generate = true, test = true, tidy = true, vendor = false },
    },
  },
})

-- JS/JSX/TS: nothing to configure. lspconfig's biome config already prefers
-- <root>/node_modules/.bin/biome over a global one, and finds the repo root via
-- package-lock.json / biome.json. Your mf-* repos all have biome.json.

-- ts_ls: js/ts gezinme (tanim, referans, hover). Biome'da bunlar YOK.
-- NOT: burada root_dir'i EZMIYORUZ. Denemistim, sunucu hic baglanmadi: Neovim'in
-- kendi belgesine gore root_dir'in fonksiyon hali `on_dir` cagirmak ZORUNDA,
-- `return root` yazan eski imza sessizce yok sayiliyor (:h vim.lsp.ClientConfig).
-- lspconfig'in varsayilani zaten dogru: package-lock/yarn/pnpm lock + .git markeri
-- ile proje kokunu bulup on_dir'i cagiriyor. Mason'in typescript-language-server
-- paketi kendi typescript'ini getiriyor, projelere "npm i typescript" gerekmiyor.

-- You are editing this config in Lua, so teach lua_ls about the `vim` global.
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- tailwindcss: lspconfig varsayilani 20+ sablon dilini (slim, ejs, mdx, django-html,
-- astro...) listeliyor. Bizde o diller yok; hem :checkhealth'te "Unknown filetype"
-- uyarisi uretiyor hem de bosuna dosya tipi eslemeye calisiyor. Sadece kullandigimiz
-- tiplere kisitliyoruz (JSX/TSX'te className tamamlama, css/html).
vim.lsp.config('tailwindcss', {
  filetypes = { 'html', 'css', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
})

-- Add/remove servers here, then :restart
vim.lsp.enable({
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
})

-- ------------------------------------------------------------- diagnostics

vim.diagnostic.config({
  virtual_text = { prefix = '●', spacing = 2, source = 'if_many' },
  severity_sort = true,
  float = { border = 'rounded', source = true },
  -- jump.float 0.12'de deprecated (0.14'te kalkacak). Yerine on_jump:
  -- zipladiktan sonra o satirin diagnostic'ini yüzen pencerede göster.
  -- focus = false: pencere odagi calmaz, yazmaya devam edersin.
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = 'cursor', focus = false })
    end,
  },
  underline = true,
})

-- ------------------------------------------------------ format on save (opt-out)

vim.g.autoformat = true

local function format_buffer(buf, manual)
  if (not manual and not vim.g.autoformat) or not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= '' then return end
  local clients = vim.lsp.get_clients({ bufnr = buf, method = 'textDocument/formatting' })
  if #clients == 0 then return end

  -- BufWritePre bitmeden import duzenlemesi tamamlansin; code_action() asenkrondur.
  if vim.bo[buf].filetype == 'go' then
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, name = 'gopls', method = 'textDocument/codeAction' })) do
      local response, err = client:request_sync('textDocument/codeAction', {
        textDocument = { uri = vim.uri_from_bufnr(buf) },
        range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 0 } },
        context = { only = { 'source.organizeImports' }, diagnostics = {} },
      }, 3000, buf)
      if err or (response and response.err) then
        vim.notify('Go import duzenleme basarisiz: ' .. vim.inspect(err or response.err), vim.log.levels.WARN)
        return
      end
      for _, action in ipairs(response and response.result or {}) do
        if not action.disabled then
          if action.data and not action.edit and client:supports_method('codeAction/resolve') then
            local resolved, resolve_err = client:request_sync('codeAction/resolve', action, 3000, buf)
            if resolve_err or not resolved or resolved.err or not resolved.result then
              vim.notify('Go import action cozulemedi: ' .. vim.inspect(resolve_err or resolved), vim.log.levels.WARN)
              return
            end
            action = resolved.result
          end
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
          end
          local command = type(action.command) == 'table' and action.command
            or (type(action.command) == 'string' and action or nil)
          if command then
            local executed, command_err = client:request_sync('workspace/executeCommand', {
              command = command.command,
              arguments = command.arguments,
            }, 3000, buf)
            if command_err or (executed and executed.err) then
              vim.notify('Go import komutu basarisiz: ' .. vim.inspect(command_err or executed.err), vim.log.levels.WARN)
              return
            end
          end
        end
      end
    end
  end

  local ids = {}
  for _, c in ipairs(clients) do ids[c.id] = true end

  -- Biome da ts_ls de textDocument/formatting sunuyor. Ikisi birlikte calisirsa
  -- ayni buffer iki kez farkli kurallarla formatlanir (Biome tab, tsserver bosluk).
  -- Biome varsa formati o yapsin; ts_ls formattan cikarilir.
  local has_biome = false
  for _, c in ipairs(clients) do
    if c.name == 'biome' then has_biome = true end
  end

  vim.lsp.buf.format({
    bufnr = buf,
    async = false,
    timeout_ms = 3000,
    filter = function(c)
      return ids[c.id] == true and not (has_biome and c.name == 'ts_ls')
    end,
  })
end

vim.keymap.set('n', '<leader>uf', function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify('format on save: ' .. (vim.g.autoformat and 'on' or 'off'))
end, { desc = 'Toggle format on save' })

-- ------------------------------------------------------------------ attach

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    -- Neovim 0.12 varsayilanlari: grn gra grr gri grt grx gO [d ]d <C-W>d
    -- Yerlesik tuslar durur; gezinme icin Space c altinda ortak bir aile de var.
    map('n', '<leader>cd', vim.lsp.buf.definition, 'Tanima git (LSP)')
    map('n', '<leader>cr', function() require('fzf-lua').lsp_references() end, 'Referanslari bul (LSP)')
    map('n', '<leader>ci', function() require('fzf-lua').lsp_implementations() end, 'Implementasyona git (LSP)')
    map('n', '<leader>ct', vim.lsp.buf.type_definition, 'Tip tanimina git (LSP)')
    map('n', '<leader>ch', vim.lsp.buf.hover, 'Hover / imza')
    map('n', '<leader>cf', function()
      format_buffer(ev.buf, true)
    end, 'Buffer formatla')
    -- gd  = Vim: yerel tanim          gD  = Vim: global tanim
    -- K   = Vim: keywordprg           gr  = Vim: virtual replace
    -- gI  = Vim: satir basina insert  (hepsi varsayilanda kaldi)

    -- built-in tamamlama: <C-n>/<C-p> ile gez, <C-y> ile kabul et
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- register format-on-save once per buffer (several servers may attach)
    if not vim.b[ev.buf].autoformat_registered then
      vim.b[ev.buf].autoformat_registered = true
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('UserAutoFormat', { clear = false }),
        buffer = ev.buf,
        callback = function() format_buffer(ev.buf) end,
      })
    end
  end,
})

-- Tamamlama ve snippet tuslari: Neovim 0.12 varsayilani.
--   <C-n>/<C-p> ile sec, <C-y> ile kabul et
--   <Tab>/<S-Tab> snippet alanlari arasinda gez (varsa), yoksa normal davranis
-- Bu yuzden burada hicbir insert-mode mapping yok.
