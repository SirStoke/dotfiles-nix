{pkgs, ...}: let
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

              outputHash = "sha256-BQZY7NGHDIXKtTqRsm9pOWm8hw26OawGrMlNU5gf7d8";
              outputHashMode = "recursive";
            };

            subPackages = ["."];
            ldflags = ["-s" "-w"]; ## don't include version info twice
            vendorHash = null;
          });
    };
in {
  services.caddy = {
    enable = true;

    package = cloudflare-caddy;

    virtualHosts."nocodb.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:32271

      import /run/agenix/cloudflare-dns
    '';

    virtualHosts."deluge.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:8112

      import /run/agenix/cloudflare-dns
    '';

    virtualHosts."sonarr.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:8989

      import /run/agenix/cloudflare-dns
    '';

    virtualHosts."radarr.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:7878

      import /run/agenix/cloudflare-dns
    '';

    virtualHosts."bazarr.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:6767

      import /run/agenix/cloudflare-dns
    '';
  };
}
