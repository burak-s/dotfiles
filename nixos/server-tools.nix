{ pkgs, ... }:

{
  imports = [ ./editors.nix ];

  # Mevcut sunucu kullanıcının adı farklıysa burak kısmını değiştir.
  users.users.burak.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "eastwood";
      plugins = [ "git" "kubectl" "docker" "docker-compose" "fzf" "man" ];
    };
    interactiveShellInit = ''
      source ${../config/zsh/common.zsh}
    '' + builtins.readFile ./shell.zsh;
  };

  programs.zoxide.enable = true;

  fonts.packages = with pkgs; [ jetbrains-mono ];
  environment.variables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  environment.systemPackages = with pkgs; [
    git
    fzf
    ripgrep
    btop       # CPU / RAM / süreç takibi
    ncdu       # Diskte ne yer kaplıyor?
    lsof       # Dosya / port hangi süreçte?
    dnsutils   # dig / DNS teşhisi
    curl       # HTTP / health check
    jq         # JSON çıktıları
    kubectl
    awscli2    # AWS CLI v2
    mongodb-tools # mongodump, mongorestore, mongoimport, mongoexport
    nodejs_26  # Node 26
    go
    rustc
    cargo
    rustfmt
    clippy
    # Ghostty uygulaması değil, SSH için yalnız terminal tanımı.
    ghostty.terminfo
  ];

  users.users.burak.packages = with pkgs; [
    ghostty
    discord-ptb
  ];
}
