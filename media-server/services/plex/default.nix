{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  services.plex.enable = true;
  services.plex.openFirewall = true;
}
