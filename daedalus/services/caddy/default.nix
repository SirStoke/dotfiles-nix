{
  pkgs,
  lib,
  ...
}: let
  cloudflare-caddy = pkgs.caddy.withPlugins {
    plugins = [
      # https://github.com/caddy-dns/cloudflare
      "github.com/caddy-dns/cloudflare@2fc25ee62f40fe21b240f83ab2fb6e2be6dbb953"
    ];

    hash = "sha256-Z8nPh4OI3/R1nn667ZC5VgE+Q9vDenaQ3QPKxmqPNkc=";

    doInstallCheck = false;
  };

  virtualHost = subdomain: port: {
    virtualHosts."${subdomain}.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:${toString port}

      import /run/agenix/cloudflare-dns
    '';
  };

  serveStatic = subdomain: {
    virtualHosts."${subdomain}.sirstoke.me".extraConfig = ''
      handle_path /* {
        root * /var/data/static
        file_server {
            root /var/data/static
            browse
        }
      }

      encode gzip
      import /run/agenix/cloudflare-dns
    '';
  };

  # Deeply merge a list of attrsets with each other
  recursiveUpdateList = attrsets:
    with lib;
      if attrsets == []
      then {}
      else lib.recursiveUpdate (head attrsets) (recursiveUpdateList (tail attrsets));
in {
  services.caddy =
    {
      enable = true;

      logFormat = "level DEBUG";

      package = cloudflare-caddy;
    }
    // (recursiveUpdateList [
      (virtualHost "nocodb" 32271)
      (virtualHost "deluge" 8112)
      (virtualHost "sonarr" 8989)
      (virtualHost "radarr" 7878)
      (virtualHost "bazarr" 6767)
      (virtualHost "grafana" 3000)
      (virtualHost "mealie" 9000)
      (serveStatic "static")
    ]);

  systemd.services.caddy.serviceConfig.SupplementaryGroups = "media";
}
