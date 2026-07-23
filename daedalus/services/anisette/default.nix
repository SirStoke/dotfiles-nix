{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    anisette = {
      image = "dadoum/anisette-v3-server";
      volumes = ["/var/data/anisette:/home/Alcoholic/.config/anisette-v3/lib/"];
      ports = ["127.0.0.1:6969:6969"];
    };
  };
}
