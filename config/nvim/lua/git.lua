-- ~/.config/nvim/lua/git.lua
-- The git/diff surface: hunks in the gutter, whole-repo diff review,
-- pi in floating terminals.

require('gitsigns').setup({
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '▁' },
    topdelete = { text = '▔' },
    changedelete = { text = '▎' },
    untracked = { text = '▎' },
  },
  current_line_blame = false,
  current_line_blame_opts = { delay = 300, virt_text_pos = 'eol' },
})

-- Git tuslari (hunk islemleri) GLOBAL: onceden gitsigns'in on_attach'i icindeydi,
-- yani sadece gitsigns'in baglandigi dosya buffer'inda tanimliydi. Dosya olmayan
-- buffer'larda (agac, diffview, bos buffer) tus "yok" gibi davraniyordu.
-- Artik her yerde var; gitsigns o buffer'a bagli degilse uyari verir.
local gs = require('gitsigns')

local function guard(fn)
  return function()
    if vim.b.gitsigns_status_dict == nil then
      vim.notify('gitsigns bu buffer\'da aktif degil (git repo icinde bir dosya ac)', vim.log.levels.WARN)
      return
    end
    fn()
  end
end

-- ]c/[c Vim'in diff gezinmesi olarak kalsin (Turkce Q'da Space gn/gp daha kolay).
local function nav_hunk(direction)
  return function()
    if vim.wo.diff then
      vim.cmd.normal({ direction == 'next' and ']c' or '[c', bang = true })
    else
      guard(function() gs.nav_hunk(direction) end)()
    end
  end
end
vim.keymap.set('n', '<leader>gn', nav_hunk('next'), { desc = 'Sonraki degisiklik' })
vim.keymap.set('n', '<leader>gp', nav_hunk('prev'), { desc = 'Onceki degisiklik' })
vim.keymap.set('n', '<leader>gN', guard(function() gs.nav_hunk('next', { target = 'staged' }) end), { desc = 'Sonraki staged hunk' })
vim.keymap.set('n', '<leader>gP', guard(function() gs.nav_hunk('prev', { target = 'staged' }) end), { desc = 'Onceki staged hunk' })
-- stage_hunk() zaten staged bir hunk uzerinde cagrilirsa unstaged yapar
vim.keymap.set('n', '<leader>gs', guard(gs.stage_hunk), { desc = 'Hunk stage/unstage' })
vim.keymap.set('v', '<leader>gs', guard(function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end), { desc = 'Secili hunk(lar)i stage' })
vim.keymap.set('n', '<leader>gS', guard(gs.stage_buffer), { desc = 'Dosyayi stage' })
local function confirm_reset(message, fn)
  if vim.fn.confirm(message, '&Evet\n&Hayir', 2) == 1 then fn() end
end
vim.keymap.set('n', '<leader>gr', guard(function()
  confirm_reset('Bu degisiklik parcasi geri alinsin mi?', gs.reset_hunk)
end), { desc = 'Hunk revert (onayli)' })
vim.keymap.set('x', '<leader>gr', guard(function()
  local range = { vim.fn.line('.'), vim.fn.line('v') }
  confirm_reset('Secili degisiklikler geri alinsin mi?', function() gs.reset_hunk(range) end)
end), { desc = 'Secili hunk revert (onayli)' })
vim.keymap.set('n', '<leader>gR', guard(function()
  confirm_reset('Dosyanin stage edilmemis TUM degisiklikleri geri alinsin mi?', gs.reset_buffer)
end), { desc = 'Dosyayi revert (onayli)' })
vim.keymap.set('n', '<leader>gB', guard(function() gs.blame_line({ full = true }) end), { desc = 'Satir blame' })
-- Hunk'in eski/yeni halini satir ici goster: silinen satirlar sanal metin olarak
-- ustunde, degisen kelimeler renkli. Tekrar basarsan kapanir.
-- (gD/gd/gv/gL dosya-repo diff'lerinde; burasi hunk-preview icin ayri)
vim.keymap.set('n', '<leader>gI', guard(gs.preview_hunk_inline), { desc = 'Hunk satir-ici diff' })
vim.keymap.set('n', '<leader>gi', guard(gs.preview_hunk), { desc = 'Hunk diff (float pencere)' })
vim.keymap.set('n', '<leader>gt', guard(gs.toggle_current_line_blame), { desc = 'Satir-ici blame ac/kapa' })

require('diffview').setup({})

-- ------------------------------------------------------- floating terminals

-- Her komut/repo icin tek terminal: gizle/goster, oturumu oldurme.
local floats = {}
local function float(cmd, opts)
  opts = opts or {}
  local key = vim.json.encode({ cmd, opts.cwd or vim.fn.getcwd() })
  local entry = floats[key]
  if entry and vim.api.nvim_buf_is_valid(entry.buf) and vim.api.nvim_win_is_valid(entry.win) then
    vim.cmd.stopinsert()
    vim.api.nvim_win_close(entry.win, true)
    return
  end
  if vim.fn.executable(cmd[1]) == 0 then
    vim.notify(cmd[1] .. ' PATH icinde bulunamadi', vim.log.levels.ERROR)
    return
  end
  local fresh = not entry or not vim.api.nvim_buf_is_valid(entry.buf)
  if fresh then
    entry = { buf = vim.api.nvim_create_buf(false, true) }
    vim.bo[entry.buf].bufhidden = 'hide'
    floats[key] = entry
  end
  local cols, lines = vim.o.columns, vim.o.lines
  local width = math.max(1, math.floor(cols * (opts.width or 0.92)))
  local height = math.max(1, math.floor((lines - 2) * (opts.height or 0.88)))
  entry.win = vim.api.nvim_open_win(entry.buf, true, {
    relative = 'editor', style = 'minimal', border = 'rounded',
    width = width, height = height,
    row = math.max(0, math.floor((lines - height) / 2) - 1),
    col = math.max(0, math.floor((cols - width) / 2)),
    title = ' ' .. (opts.title or cmd[1]) .. ' | Ctrl-q: gizle ',
    title_pos = 'center',
  })
  local function hide()
    vim.cmd.stopinsert()
    if vim.api.nvim_win_is_valid(entry.win) then vim.api.nvim_win_close(entry.win, true) end
  end
  if fresh then
    local function cleanup()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(entry.win) then vim.api.nvim_win_close(entry.win, true) end
        if vim.api.nvim_buf_is_valid(entry.buf) then vim.api.nvim_buf_delete(entry.buf, { force = true }) end
        if floats[key] == entry then floats[key] = nil end
      end)
    end
    local job = vim.fn.jobstart(cmd, { term = true, cwd = opts.cwd, on_exit = cleanup })
    if job <= 0 then
      cleanup()
      vim.notify(cmd[1] .. ' baslatilamadi', vim.log.levels.ERROR)
      return
    end
    vim.keymap.set({ 'n', 't' }, '<C-q>', hide, { buffer = entry.buf, desc = 'Terminali gizle (oturum devam eder)' })
    vim.keymap.set('n', 'q', hide, { buffer = entry.buf, desc = 'Terminali gizle' })
    vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = entry.buf, desc = 'Terminal modundan cik' })
  end
  vim.cmd.startinsert()
  return entry.win
end

-- git root of the current buffer, not the cwd: matters when you cd into a
-- subpackage inside a service.
local function git_root()
  return vim.fs.root(0, { '.git' }) or vim.fn.getcwd()
end

-- Tek diff arayuzu: dosya da repo da Diffview'da acilir, Space gx ile kapanir.
local function open_diff(revision, current_file)
  local file = vim.api.nvim_buf_get_name(0)
  if current_file and (file == '' or vim.bo.buftype ~= '') then
    vim.notify('Once bir dosya ac', vim.log.levels.WARN)
    return
  end
  local root = git_root()
  local cmd = 'DiffviewOpen -C=' .. vim.fn.fnameescape(root)
  if revision then cmd = cmd .. ' ' .. revision end
  if current_file then cmd = cmd .. ' -- ' .. vim.fn.fnameescape(file) end
  vim.cmd(cmd)
end
vim.keymap.set('n', '<leader>gd', function() open_diff(nil, true) end, { desc = 'Dosya diff (index)' })
vim.keymap.set('n', '<leader>gD', function() open_diff('HEAD', true) end, { desc = 'Dosya diff (HEAD, staged dahil)' })
vim.keymap.set('n', '<leader>gv', function() open_diff() end, { desc = 'Repo diff (working tree)' })
vim.keymap.set('n', '<leader>gV', function() open_diff() end, { desc = 'Repo diff (working tree)' })
vim.keymap.set('n', '<leader>gL', function() open_diff('HEAD~1..HEAD') end, { desc = 'Diff last commit' })
vim.keymap.set('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = 'File history' })
vim.keymap.set('n', '<leader>gH', '<Cmd>DiffviewFileHistory<CR>', { desc = 'Repo history' })
vim.keymap.set('n', '<leader>gx', '<Cmd>DiffviewClose<CR>', { desc = 'Close diffview' })

-- pi, always scoped to the git root so it sees the whole service.
vim.keymap.set('n', '<leader>ai', function()
  float({ 'pi' }, { cwd = git_root(), title = 'pi' })
end, { desc = 'pi (new session)' })

vim.keymap.set('n', '<leader>ac', function()
  float({ 'pi', '--continue' }, { cwd = git_root(), title = 'pi --continue' })
end, { desc = 'pi (continue session)' })

vim.keymap.set('n', '<leader>ar', function()
  float({ 'pi', '--resume' }, { cwd = git_root(), title = 'pi --resume' })
end, { desc = 'pi (pick session)' })
