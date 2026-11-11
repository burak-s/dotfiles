# ~/dotfiles

NixOS sistem ayarları ve ortak tmux, Neovim, zsh, Ghostty configleri.
Flake çıktısı: `nixosConfigurations.nixos`. Mevcut yerel configler kopyalanmıştır;
kaynak dosyalar taşınmaz veya silinmez.

## Yapi

```
~/dotfiles/
├── flake.nix                  # Giriş noktası; nixpkgs rev'i sisteme sabitli
├── flake.lock                 # Sabitlenmiş input revizyonları
├── README.md
├── config/
│   ├── nvim/                  # Lua configleri ve vim.pack lockfile
│   ├── tmux/tmux.conf
│   ├── zsh/common.zsh          # Ortak shell davranışı ve güvenli PATH ayarları
│   └── ghostty/config.ghostty
└── nixos/
    ├── configuration.nix      # Ana konfigürasyon
    ├── hardware-configuration.nix
    ├── server-tools.nix       # Shell, CLI araçları, dil araçları ve font
    ├── editors.nix            # Neovim, tmux, LSP ve editör gereksinimleri
    ├── shell.zsh              # Makineye özel NixOS kısayolları
    ├── adguardhome.nix
    ├── vaultwarden.nix
    └── experiments/
        └── streaming.nix      # SDDM+Sunshine varyantı; İMPORT EDİLMEDİ (deneme)
```

## Rebuild

```bash
cd ~/dotfiles
# Yeni dosyalar flake tarafından görülebilmek için Git'e eklenmiş olmalı.
git add config nixos
sudo nixos-rebuild dry-build --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

### Paketler ve configlerin uygulanması

- `server-tools.nix`: zsh / Oh My Zsh (Eastwood), öneriler, completion,
  zoxide (`z` / `zi`), git, fzf, ripgrep ve sistem teşhis araçları.
- Geliştirme: Go, Node 26, Rust (`rustc`, `cargo`, `rustfmt`, `clippy`).
  Rust standart kütüphane kaynakları `RUST_SRC_PATH` ile sağlanır.
- Altyapı: `kubectl`, AWS CLI v2 (`aws`), MongoDB Database Tools
  (`mongodump`, `mongorestore`, `mongoimport`, `mongoexport` vb.).
- Font: JetBrains Mono. Ghostty ve Discord PTB kullanıcı paketleridir.
- `editors.nix`, tmux configini `/etc/tmux.conf` içine ekler. Prefix `Ctrl-a`;
  `v` / `-` ile bölme, `h/j/k/l` ile gezinme, `r` ile yeniden yükleme.
- Neovim 0.12+ gereklidir. Config `/etc/xdg/nvim` üzerinden yüklenir;
  pluginler `vim.pack` ile yönetilir. İlk açılışta pluginler ve Treesitter
  parserları için internet gerekir. Lockfile'ın yazılabilir kopyası ilk
  açılışta kullanıcı config dizininde oluşturulur.
- NixOS'ta LSP sunucuları Mason yerine Nix paketlerinden gelir; Go, Rust,
  JS/TS, Lua, JSON, YAML, Helm, Bash, Docker ve Tailwind desteği vardır.
- Var olan `~/.config/nvim/init.lua` ve kullanıcı tmux configi ortak
  varsayılanları gölgeleyebilir. Rebuild bu yerel dosyaları değiştirmez.
- Ghostty configi repoda saklanır, henüz NixOS tarafından otomatik kurulmaz.
  Kullanmak istediğin makinede mevcut configini kontrol edip gerekirse yedekleyerek
  `config/ghostty/config.ghostty` dosyasını `~/.config/ghostty/config.ghostty`
  konumuna kopyala.

Ortak zsh ayarları `~/.zshrc` / `~/.zshenv` dosyalarını değiştirmez.
Makineye özel SDK yolları, otomatik SSH agent başlatma ve `als`/cheatsheet
aktarılmamıştır. SSH anahtarları, AWS kimlik bilgileri, kubeconfig ve tokenları
repoya ekleme.

Kolaylik icin zsh alias'lari kondu: `nrswitch`, `nrtest`, `nrdry`, `nrbuild`, `ncd`.

Not: Sistemde `git` kurulduktan sonra depo `git init` edilirse, root olarak
calisan nixos-rebuild "dubious ownership" hatasi verebilir. Cozum (bir kez):

```bash
sudo git config --global --add safe.directory /home/burak/dotfiles
```

## Ilk gecis (eski /etc/nixos'tan)

1. `git init` ve ilk commit (git switch sonrasi kurulacak):
   ```bash
   git config --global user.name  "burak"
   git config --global user.email "burak@ornek.com"
   git init && git add -A && git commit -m "dotfiles: NixOS config'i /etc/nixos'tan tasindi"
   ```
2. Ileride istersen eski yedegi kaldirabilirsin:
   `sudo mv /etc/nixos /etc/nixos.eski-depoda` (simdilik dokunulmadi, yedek olarak duruyor).
   - Not: /etc/nixos silinmedigi surece `nixos-rebuild switch --flake`
     kullanmaya devam edin; aliases bunu yapar, eski `nixos-rebuild switch`
     (flakesiz) /etc/nixos'u okur.
3. Eski deneysel dosyalar `~/nix/` altinda duruyor:
   - `vaultwarden.nix`: vaultwarden.nix'in ESKI kopyasi (SIGNUPS_ALLOWED=true);
     guncel olan dotfiles'ta. Silinebilir.
   - `streaming.nix`: dotfiles'a `nixos/experiments/` altina kopyalandi.
     Bu varyant SDDM + graphical.target kullanir; guncel konfigurasyon ise
     bilerek SDDM'siz, multi-user target + tty1 otologin kullanir. Ikisini
     AYNI ANDA import etmeyin (cakisir).

## nixpkgs guncellemesi

flake.nix icinde rev sisteme sabitli (26.05.13627.c56a87d8e41c):

```bash
cd ~/dotfiles
# Önce flake.nix içindeki sabit nixpkgs revizyonunu güncelle.
nix flake update        # Seçilen input revizyonunu lock'a işler
sudo nixos-rebuild switch --flake .#nixos
```

## Sonraki adim (opsiyonel): home-manager

Ghostty, Neovim ve tmux configleri `config/` altında tutulur;
btop ve KDE kullanıcı ayarları henüz yönetilmez. Mevcut flake tek makineyi
(`nixos`) tanımlar; desktop/laptop için ayrı host çıktıları henüz yoktur.
Istenirse home-manager modul olarak eklenebilir:

- `inputs.home-manager.url = "github:nix-community/home-manager/master"`
  (nixpkgs rev'ine uygun sürüm seçilir; 26.05 çıkmadıysa master/unstable kullanılır)
- `nixosConfigurations.nixos` modullerine `home-manager.nixosModules.home-manager`
  eklenir; kullanici ayarlari `nixos/home/` altinda toplanir.
