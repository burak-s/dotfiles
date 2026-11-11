{ pkgs, ... }:

{
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
      plugins = [ ];
    };
    interactiveShellInit = builtins.readFile ./shell.zsh;
  };

  programs.zoxide.enable = true;

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
    nodejs_26  # Node 26
    # Ghostty uygulaması değil, SSH için yalnız terminal tanımı.
    ghostty.terminfo
  ];

  users.users.burak.packages = with pkgs; [
    ghostty
    discord-ptb
  ];
}
