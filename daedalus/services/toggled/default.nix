{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    toggled = {
      image = "ghcr.io/sirstoke/toggled:c0d54b1366f15c12b0dda75f69efe063599ef2eb";

      environmentFiles = [
        "/run/agenix/toggled-secrets"
      ];

      login = {
        registry = "ghcr.io";
        username = "SirStoke";
        passwordFile = "/run/agenix/toggled-docker-pwd";
      };
    };
  };
}
