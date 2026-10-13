{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    opencode = {
      image = "ghcr.io/sirstoke/opencode-docker:latest";
      cmd = ["web" "--hostname" "0.0.0.0" "--port" "4096"];
      ports = ["127.0.0.1:4096:4096"];

      environmentFiles = [
        "/run/agenix/opencode-env"
      ];

      login = {
        registry = "ghcr.io";
        username = "SirStoke";
        passwordFile = "/run/agenix/opencode-docker-pwd";
      };
    };
  };
}
