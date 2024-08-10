{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
   nocodb = {
      image = "nocodb/nocodb:0.252.0";
      volumes = [ "/var/data/nocodb:/usr/app/data/" ];
      ports = [ "32271:8080" ];
    };
  };
}
