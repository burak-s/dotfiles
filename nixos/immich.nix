# Immich — kendi fotoğraf cloud'un (Google Photos alternatifi).
#
# iOS kullanımı:
#   1) App Store'dan "Immich" uygulamasını kur.
#   2) Server URL: https://nixos.tail46b1f7.ts.net:8443
#   3) Web arayüzünden oluşturduğun hesapla giriş yap, backup'ı aç.
#
# Notlar:
#   - Native NixOS modülü kullanıyoruz (Docker yok). PostgreSQL + vectorchord,
#     Redis ve machine-learning servisi modül tarafından otomatik kurulur.
#   - Fotoğraflar /var/lib/immich altında saklanır. Farklı disk istersen
#     mediaLocation'u değiştir (dizini önceden immich kullanıcısına açman gerekir).
#   - Tailscale Serve HTTPS verir; iOS app WebSocket dahil sorunsuz çalışır.
#   - Vaultwarden :443'ü kullanıyor olduğu için Immich :8443'te yayınlanır
#     (aynı tailscale hostname'inde farklı portlar çakışmaz).
{ config, lib, pkgs, pkgs-unstable, ... }:

let
  tailnetSuffix = "tail46b1f7.ts.net";
  immichDomain = "nixos.${tailnetSuffix}";
in
{
  services.immich = {
    enable = true;

    # 26.05 kanalındaki Immich 2.7.5 insecure işaretli (2.x bakım dışı + CVE).
    # Immich'i nixos-unstable'daki 3.x'ten çekiyoruz; sistem 26.05 kalır.
    package = pkgs-unstable.immich;

    # Fotoğraf kütüphanesi konumu (varsayılan /var/lib/immich).
    # mediaLocation = "/data/immich";  # farklı disk/bölüm istersen aç

    # Yalnızca localhost'u dinle; dışarıya Tailscale Serve HTTPS açar.
    host = "127.0.0.1";
    port = 2283;

    # ML servisi kapalı (yüz tanıma/akıllı arama yok; yedekleme etkilenmez).
    # İsteyince: enable = true yapıp tekrar rebuild et — kütüphane
    # sonradan taranarak indekslenir.
    machine-learning.enable = false;

    # DB şifresi gerekmez: modül varsayılan olarak unix socket
    # (/run/postgresql) üzerinden bağlanır.
  };

  # --- Tailscale Serve: https://nixos.<tailnet>.ts.net:8443 -> 127.0.0.1:2283 ---
  # tailscaled durumu /var/lib/tailscale'de kalıcı olduğu için serve
  # yapılandırması reboot sonrası da korunur; bu servis sadece (yeniden) uygular.
  systemd.services.immich-tailscale-serve = {
    description = "Immich'i Tailscale HTTPS ile yayınla";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "tailscaled.service"
      "network-online.target"
    ];
    after = [
      "tailscaled.service"
      "immich-server.service"
      "network-online.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 15;
    };
    script = ''
      ${config.services.tailscale.package}/bin/tailscale serve --bg --https=8443 http://127.0.0.1:2283
    '';
  };

  # Firewall'da açılacak port YOK: immich 127.0.0.1'de, erişim tailscale0 üzerinden.
}
