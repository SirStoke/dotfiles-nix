{
  pkgs,
  lib,
  ...
}: let
  cloudflare-caddy = with pkgs;
    caddy.override {
      buildGoModule = args:
        buildGoModule (args
          // {
            src = stdenv.mkDerivation rec {
              pname = "caddy-using-xcaddy-${xcaddy.version}-cloudflare";
              inherit (caddy) version;

              dontUnpack = true;
              dontFixup = true;

              nativeBuildInputs = [
                cacert
                go
              ];

              plugins = [
                # https://github.com/caddy-dns/cloudflare
                "github.com/caddy-dns/cloudflare@89f16b99c18ef49c8bb470a82f895bce01cbaece"
              ];

              configurePhase = ''
                export GOCACHE=$TMPDIR/go-cache
                export GOPATH="$TMPDIR/go"
                export XCADDY_SKIP_BUILD=1
              '';

              buildPhase = ''
                ${xcaddy}/bin/xcaddy build "${caddy.src.rev}" ${lib.concatMapStringsSep " " (plugin: "--with ${plugin}") plugins}
                cd buildenv*
                go mod vendor
              '';

              installPhase = ''
                cp -r --reflink=auto . $out
              '';

              outputHash = "sha256-Aqu2st8blQr/Ekia2KrH1AP/2BVZIN4jOJpdLc1Rr4g=";
              outputHashMode = "recursive";
            };

            subPackages = ["."];
            ldflags = ["-s" "-w"]; ## don't include version info twice
            vendorHash = null;
          });
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
