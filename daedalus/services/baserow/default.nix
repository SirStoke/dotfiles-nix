{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    baserow = {
      image = "baserow/baserow:1.26.1";
      volumes = ["/var/data/baserow:/baserow/data"];
      ports = ["127.0.0.1:32271:80"];
      environment = {
        BASEROW_PUBLIC_URL = "https://nocodb.sirstoke.me";
      };
    };
  };
}
