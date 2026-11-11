{ lib, pkgs, ... }:

{
  # Mevcut ~/.config dosyalari varsa XDG varsayilanlarindan once okunur.
  # Yerel dosyalara dokunulmaz; temiz kurulumda bu ortak config kullanilir.
  environment.etc."xdg/nvim".source = ../config/nvim;

  assertions = [
    {
      assertion = lib.versionAtLeast pkgs.neovim.version "0.12";
      message = "Ortak Neovim configi vim.pack icin Neovim 0.12+ gerektiriyor.";
    }
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../config/tmux/tmux.conf;
  };

  environment.systemPackages = with pkgs; [
    # git, fzf ve ripgrep server-tools.nix tarafindan saglanir.
    # Treesitter ve pano gereksinimleri.
    tree-sitter
    gcc
    gnumake
    unzip
    wl-clipboard
    xclip

    # Mason yerine Nix tarafindan saglanan dil sunuculari.
    gopls
    rust-analyzer
    biome
    typescript
    typescript-language-server
    lua-language-server
    vscode-langservers-extracted
    yaml-language-server
    helm-ls
    bash-language-server
    dockerfile-language-server
    docker-compose-language-service
    tailwindcss-language-server
  ];
}
