# ~/dotfiles

Bu depo, `/etc/nixos` altindaki NixOS konfigürasyonunun dotfiles'a tasinmis halidir.
Flake tabanlidir: `nixosConfigurations.nixos`.

## Yapi

```
~/dotfiles/
├── flake.nix                  # Giriş noktası; nixpkgs rev'i sisteme sabitli
├── flake.lock                 # nix build tarafından üretilir
├── README.md
└── nixos/
    ├── configuration.nix      # Ana konfigürasyon
    ├── hardware-configuration.nix
    ├── server-tools.nix       # zsh, oh-my-zsh, zoxide vb.
    ├── shell.zsh              # server-tools.nix tarafından readFile ile çekilir
    ├── adguardhome.nix
    ├── vaultwarden.nix
    └── experiments/
        └── streaming.nix      # SDDM+Sunshine varyantı; İMPORT EDİLMEDİ (deneme)
```

## Rebuild

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

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
nix flake update        # yeni rev'i lock'a isler
sudo nixos-rebuild switch --flake .#nixos
```

## Sonraki adim (opsiyonel): home-manager

`~/.config` (ghostty, btop, KDE rc dosyalari) henuz dotfiles'ta degil.
Istenirse home-manager modul olarak eklenebilir:

- `inputs.home-manager.url = "github:nix-community/home-manager/master"`
  (nixpkgs rev'ine uygun sürüm seçilir; 26.05 çıkmadıysa master/unstable kullanılır)
- `nixosConfigurations.nixos` modullerine `home-manager.nixosModules.home-manager`
  eklenir; kullanici ayarlari `nixos/home/` altinda toplanir.
