{pkgs, ...}: let
  namecheap-caddy = with pkgs; caddy.override {
    buildGoModule = args:
      buildGoModule (args
        // {
          src = stdenv.mkDerivation rec {
            pname = "caddy-using-xcaddy-${xcaddy.version}";
            inherit (caddy) version;

            dontUnpack = true;
            dontFixup = true;

            nativeBuildInputs = [
              cacert
              go
            ];

            plugins = [
              # https://github.com/caddy-dns/namecheap
              "github.com/caddy-dns/namecheap@7095083a353829fc83632c34e8988fd8eb72f43d"
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

            outputHash = "sha256-7Xa5fS9hbmkhdRso1mSwsEaBRNbW8u7S+L7JuNG/VOA=";
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

    package = namecheap-caddy;

    virtualHosts."nocodb.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:32271

      import /run/agenix/namecheap-dns
    '';


    virtualHosts."deluge.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:8112

      import /run/agenix/namecheap-dns
    '';


    virtualHosts."sonarr.sirstoke.me".extraConfig = ''
      reverse_proxy localhost:8989

      import /run/agenix/namecheap-dns
    '';
  };
}
