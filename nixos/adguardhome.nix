{ ... }:

{
  services.adguardhome = {
    enable = true;
    host = "192.168.1.30";
    port = 3000;

    mutableSettings = true;

    settings = {
      dns = {
        bind_hosts = [ "192.168.1.30" ];
        port = 53;

        upstream_dns = [
          "https://cloudflare-dns.com/dns-query"
        ];

        bootstrap_dns = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        cache_size = 4194304;
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };

      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 3000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
