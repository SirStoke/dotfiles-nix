{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    nginx-cors = {
      image = "nginx:alpine";
      volumes = ["/var/data/nginx-cors-anywhere/nginx.conf:/etc/nginx/nginx.conf:ro"];
      ports = ["127.0.0.1:6868:8080"];
    };
  };
}
