# Oh My Zsh ve eklentileri NixOS yüklüyor.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

# Sağ ok / End ile öneriyi kabul et.
bindkey '^[[C' autosuggest-accept
bindkey '^[[F' autosuggest-accept

# --- Konsol / KDE Plasma yönetimi -------------------------------------------
# Plasma (Wayland) oturumunu bulundugun tty'de baslat (display manager yok).
# Oturumu kapatinca ayni tty'de shell promptuna donersin.
alias plasma='exec startplasma-wayland'

# Artik gereksiz: display manager yok. Plasma'da "Oturumu Kapat" yeterli.
alias nogui='echo "Display manager yok; Plasma oturumundan cikman yeterli."'

# Ekranı SSH'den hemen kapat.
alias monitor='sudo sh -c "echo 1 > /sys/class/graphics/fb0/blank"'

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
