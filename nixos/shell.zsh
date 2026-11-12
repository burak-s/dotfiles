# Ortak shell ayarlari config/zsh/common.zsh icinde.
# Bu dosya mevcut NixOS makinesine ozel kisayollari tutar.

# --- Konsol / KDE Plasma yönetimi -------------------------------------------
# Plasma (Wayland) oturumunu bulundugun tty'de baslat (display manager yok).
# Oturumu kapatinca ayni tty'de shell promptuna donersin.
alias plasma='exec startplasma-wayland'

# Artik gereksiz: display manager yok. Plasma'da "Oturumu Kapat" yeterli.
alias nogui='echo "Display manager yok; Plasma oturumundan cikman yeterli."'

# Ekranı SSH'den hemen kapat / aç. NOPASSWD sudo kuralı sayesinde
# şifre sormadan, SSH oturumundan bile çalışır.
alias monitor='sudo -n /run/current-system/sw/bin/monoff'
alias monitor-on='sudo -n /run/current-system/sw/bin/monon'

# NixOS shortened aliases (dotfiles / flake tabanli)
alias ncd='cd ~/dotfiles/nixos'
alias nrbuild='sudo nixos-rebuild build --flake ~/dotfiles#nixos'
alias nrdry='sudo nixos-rebuild dry-build --flake ~/dotfiles#nixos'
alias nrtest='sudo nixos-rebuild test --flake ~/dotfiles#nixos'
alias nrswitch='sudo nixos-rebuild switch --flake ~/dotfiles#nixos'
alias nix-garbage='sudo nix-collect-garbage -d'

# Open Proxy
alias proxied='sudo tailscale set --exit-node=100.125.42.25'
alias not-proxied='sudo tailscale set --exit-node='
