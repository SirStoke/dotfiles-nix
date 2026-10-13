{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    toggled = {
      image = "ghcr.io/sirstoke/opencode-docker:latest";

      environmentFiles = [
        "/run/agenix/toggled-secrets"
      ];

      login = {
        registry = "ghcr.io";
        username = "SirStoke";
        passwordFile = "/run/agenix/opencode-docker-pwd";
      };
    };
  };
}
