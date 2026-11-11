{
  description = "burak'in dotfiles'i: NixOS sistem konfigurasyonu (flake)";

  inputs = {
    # Sistemdeki NixOS kanaliyla AYNI revizyona sabitlendi:
    #   26.05.13627.c56a87d8e41c (Yarara)
    # Boylece ilk flake rebuild'i birebir ayni sistemi uretir.
    #
    # Guncellemek icin iki secenek:
    #   1) nix flake update            -> lock dosyasindaki rev'i yeniler
    #   2) asagidaki URL'ye yeni rev yaz
    # (ya da URL'yi "github:NixOS/nixpkgs/nixos-unstable" yapin.)
    nixpkgs.url = "github:NixOS/nixpkgs/c56a87d8e41ce69bd2af57eb35dcc117a9dfca33";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # Hostname "nixos" (networking.hostName ile ayni olmali).
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./nixos/configuration.nix ];
      };
    };
}
