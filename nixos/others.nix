# "Diğerleri" — sunucu işlerine yarımayan ama yaşantımızı süren
# kapalı-kaynak masaüstü uygulamaları. Hepsi unfree; allowUnfree
# configuration.nix'te açık olduğu için ekstra ayar gerekmiyor.
{ config, lib, pkgs, ... }:

{

  users.users.burak.packages = with pkgs; [
    spotify
    discord-ptb
  ];

}
