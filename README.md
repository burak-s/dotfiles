# dotfiles

Kişisel NixOS, Neovim, tmux, zsh ve Ghostty ayarlarım.

## Ortam

- **NixOS** — flake tabanlı sistem yapılandırması, KDE Plasma, Tailscale, AdGuard Home ve Vaultwarden.
- **Neovim 0.12+** — yerleşik `vim.pack`, LSP ve completion; Gruvbox, fzf-lua, Treesitter, Gitsigns ve Diffview. Go, Rust, JS/TS, Lua ve altyapı dosyaları için dil sunucuları.
- **tmux** — `Ctrl-a` prefix, Vim tarzı pane gezinmesi, Türkçe klavyeye uygun bölme tuşları ve pi popup.
- **zsh** — Oh My Zsh / Eastwood, autosuggestions, syntax highlighting, fzf ve zoxide.
- **Ghostty** — açık/koyu Gruvbox, JetBrains Mono ve clipboard kısayolları.

## Araçlar

Go, Rust, Node.js 26, kubectl, AWS CLI v2, MongoDB Database Tools; git, ripgrep, fzf ve sistem teşhis araçları.

## Dizinler

```text
config/
├── ghostty/       # Terminal
├── nvim/          # Editör, Lua modülleri ve plugin lockfile
├── tmux/          # Multiplexer
└── zsh/           # Ortak shell ayarları
nixos/
├── configuration.nix
├── hardware-configuration.nix
├── server-tools.nix
├── editors.nix
├── shell.zsh
├── adguardhome.nix
├── vaultwarden.nix
└── experiments/
flake.nix
flake.lock
```

NixOS yapılandırması kendi donanımıma ve kullanıcı hesabıma özeldir.
