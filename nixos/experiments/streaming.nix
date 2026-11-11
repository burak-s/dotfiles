# Android TV'yi "sadece istemci" yapan düzenek (Sunshine sunucu + Moonlight TV).
#
# Mevcut düzen korunuyor: Plasma 6 + SDDM. Sadece otomatik giriş, ekran
# yakalama ve kodlama ayarları ekleniyor.
#
# Neden `capture = kms`: nixpkgs'teki Plasma 6.8.2 yalnızca Wayland oturumu
# sağlıyor (sağlanan oturumlar: ["plasma"]), yani Sunshine'ın `x11` backend'i
# kullanılamıyor. KMS yakalama doğrudan DRM üzerinden okur, DRM master'ı
# almaya çalışmaz → KWin ile çakışmaz; sadece cap_sys_admin ister.
#
# configuration.nix içinde 1 değişiklik şart:
#   systemd.defaultUnit = lib.mkForce "multi-user.target";  ->  yorum satırı yap
#   (yoksa aşağıdaki tanımla çakışır)
{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # 1) Açılışta grafik oturum olsun (Sunshine yakalayacak bir ekran bulmalı)
  # ---------------------------------------------------------------------------
  systemd.defaultUnit = lib.mkForce "graphical.target";

  # ---------------------------------------------------------------------------
  # 2) Plasma oturumuna otomatik giriş
  # ---------------------------------------------------------------------------
  # SDDM + Plasma 6 zaten configuration.nix'te açık; tek gereken oturumun
  # kendiliğinden açılması. Wayland oturumu SDDM'de varsayılan.
  services.displayManager.autoLogin = {
    enable = true;
    user = "burak";
  };
  services.displayManager.defaultSession = "plasma";

  # ---------------------------------------------------------------------------
  # 3) Sunshine (yakalama + VAAPI donanım kodlama)
  # ---------------------------------------------------------------------------
  services.sunshine = {
    enable = true;
    openFirewall = true; # TCP 47984-47990, UDP 47998-48010
    autoStart = true;
    capSysAdmin = true; # kms yakalama için zorunlu

    # NOT: settings doluyken web arayüzünden yapılan değişiklikler kalıcı olmaz.
    # Değişiklik = bu dosyayı düzenle + `nixos-rebuild switch`.
    settings = {
      sunshine_name = "nixos-tv";
      capture = "kms";            # alternatifler: kwin | portal
      encoder = "vaapi";          # AMD Renoir (VCN) donanım kodlayıcı
      vaapi_quality = "balanced"; # speed | balanced | quality
      fps = 60;
      max_bitrate = 20000;        # kbps; WiFi'de 12000-15000 daha güvenli
      address_family = "ipv4";
      upnp = "off";
    };
  };

  # ---------------------------------------------------------------------------
  # 4) İzinler / donanım erişimi
  # ---------------------------------------------------------------------------
  hardware.uinput.enable = true; # sanal klavye/gamepad enjeksiyonu
  users.users.burak.extraGroups = [ "video" "render" "input" "uinput" ];

  hardware.graphics.enable = true; # VAAPI sürücüsü (radeonsi_drv_video.so)
  environment.systemPackages = [ pkgs.libva-utils ];
}
