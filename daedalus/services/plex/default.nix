{
  config,
  pkgs,
  unstablePkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  services.plex.enable = true;
  services.plex.openFirewall = true;
  services.plex.package = unstablePkgs.plex;
}
