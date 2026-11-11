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

    # Sadece bazi paketleri daha yeni surumden cekmek icin (orn. Immich 3.x):
    #   nixos/immich.nix icerisinde pkgs-unstable.immich kullaniliyor.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # Hostname "nixos" (networking.hostName ile ayni olmali).
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Moduller icinden `pkgs-unstable` argumani olarak erisilir.
          ({ _module.args.pkgs-unstable =
            import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
          ./nixos/configuration.nix
        ];
      };
    };
}
