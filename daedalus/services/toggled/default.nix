{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    toggled = {
      image = "ghcr.io/sirstoke/opencode-web:fbcb5853dcf3f4b88bc8706c8709b15ef4b0e4fe";

      login = {
        registry = "ghcr.io";
        username = "SirStoke";
        passwordFile = "/run/agenix/opencode-docker-pwd";
      };
    };
  };
}
