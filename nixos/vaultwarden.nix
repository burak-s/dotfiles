# Vaultwarden (Bitwarden uyumlu kendi sunucun) — Tailscale HTTPS arkasında.
#
# İlk kurulum sırası:
#   1) Bu dosyayla rebuild et (SIGNUPS_ALLOWED = true).
#   2) https://nixos.tail46b1f7.ts.net adresinden hesabını oluştur.
#   3) SIGNUPS_ALLOWED = false yap, tekrar rebuild et.
#
# Neden Tailscale Serve? Web vault (tarayıcı) HTTPS olmadan çalışmaz
# (WebCrypto / crypto.subtle güvenli bağlam ister). Tailscale Serve,
# port açmadan ve domain/DNS/ACME uğraşmadan geçerli bir Let's Encrypt
# sertifikası verir: https://nixos.<tailnet>.ts.net
{ config, lib, pkgs, ... }:

let
  # `tailscale status --json | jq -r .MagicDNSSuffix`
  tailnetSuffix = "tail46b1f7.ts.net";
  vaultDomain = "nixos.${tailnetSuffix}";
in
{
  services.vaultwarden = {
    enable = true;

    # Ev/tek kullanıcı sunucusu için sqlite fazlasıyla yeterli.
    dbBackend = "sqlite";

    # Günlük otomatik yedek: db.sqlite3 + rsa_key'ler + ekler (attachments)
    # /var/backup/vaultwarden içine, her gün 23:00'da.
    backupDir = "/var/backup/vaultwarden";

    config = {
      # Bitwarden istemcilerinin (mobil/masaüstü/eklenti) kullanacağı adres.
      # Tailscale Serve kullanmasan bile bu değer eriştiğin URL olmalı.
      DOMAIN = "https://${vaultDomain}";

      # Yalnızca localhost'u dinle; dışarıya Tailscale Serve HTTPS açar.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      WEB_VAULT_ENABLED = true;

      # İlk hesabı açtıktan sonra MUTLAKA false yap.
      SIGNUPS_ALLOWED = false;
      # Admin panelinden yeni kullanıcı davet etmeye izin ver.
      INVITATIONS_ALLOWED = true;

      # Yedekten geri dönme / şifre sıfırlama için e-posta istiyorsan:
      # SMTP_HOST = "smtp.example.com";
      # SMTP_FROM = "vault@example.com";
      # SMTP_PORT = 587;
      # SMTP_SECURITY = "starttls";
      # SMTP_USERNAME = "vault@example.com";
      # SMTP_PASSWORD = "...";  # sır -> /var/lib/vaultwarden.env (environmentFile)
    };

    # Sırlar (ADMIN_TOKEN, SMTP_PASSWORD) Nix store'a yazılmasın diye
    # ayrı dosyadan okunur. Admin panelini açmak için:
    #   sudo -u vaultwarden /run/current-system/sw/bin/vaultwarden hash
    #   (parolayı gir, çıkan $argon2id$... değerini kullan)
    #   sudo install -m 600 -o vaultwarden -g vaultwarden /dev/null /var/lib/vaultwarden.env
    #   echo "ADMIN_TOKEN='<hash>'" | sudo tee /var/lib/vaultwarden.env
    # Sonra aşağıdaki satırın yorumunu kaldır:
    # environmentFile = [ "/var/lib/vaultwarden.env" ];
  };

  # --- Tailscale Serve: https://nixos.tail46b1f7.ts.net -> 127.0.0.1:8222 ---
  # tailscaled durumu /var/lib/tailscale'de kalıcı olduğu için serve yapılandırması
  # reboot sonrası da korunur; bu servis sadece (yeniden) uygular.
  systemd.services.vaultwarden-tailscale-serve = {
    description = "Vaultwarden'i Tailscale HTTPS ile yayınla";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "tailscaled.service"
      "network-online.target"
    ];
    after = [
      "tailscaled.service"
      "vaultwarden.service"
      "network-online.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 15;
    };
    script = ''
      ${config.services.tailscale.package}/bin/tailscale serve --bg --https=443 http://127.0.0.1:8222
    '';
  };

  # Firewall'da açılacak port YOK: vaultwarden 127.0.0.1'de, erişim tailscale0 üzerinden.
}
