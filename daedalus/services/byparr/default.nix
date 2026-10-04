{
  config,
  pkgs,
  lib,
  ...
}: {
  # docker run -d -p 8191:8191 --rm -ti ghcr.io/thephaseless/byparr:latest
  virtualisation.oci-containers.containers = {
    byparr = {
      image = "ghcr.io/thephaseless/byparr:latest";
      ports = ["127.0.0.1:8191:8191"];
    };
  };
}
